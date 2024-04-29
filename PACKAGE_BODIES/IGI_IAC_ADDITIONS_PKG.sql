--------------------------------------------------------
--  DDL for Package Body IGI_IAC_ADDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_ADDITIONS_PKG" AS
-- $Header: igiiapab.pls 120.13.12000000.3 2007/11/02 15:13:05 sharoy ship $

    --===========================FND_LOG.START=====================================

    g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
    g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiapab.igi_iac_additions_pkg.';

    --===========================FND_LOG.END=====================================

    PROCEDURE Debug_Period(p_period igi_iac_types.prd_rec) IS
  	l_path_name VARCHAR2(150) := g_path||'debug_period';
    BEGIN
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Period counter :'||to_char(p_period.period_counter));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Period Num :'||to_char(p_period.period_num));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Fiscal Year :'||to_char(p_period.fiscal_year));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Period Name :'||p_period.period_name);
    END Debug_Period;

    PROCEDURE Debug_Asset(p_asset igi_iac_types.iac_reval_input_asset) IS
  	l_path_name VARCHAR2(150) := g_path||'debug_asset';
    BEGIN
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '==============================================================');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Net book value :'||to_char(p_asset.net_book_value));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Adjusted Cost :'||to_char(p_asset.adjusted_cost));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Operating Account :'||to_char(p_asset.operating_acct));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Reval Reserve :'||to_char(p_asset.reval_reserve));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Deprn Amount :'||to_char(p_asset.deprn_amount));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Deprn Reserve :'||to_char(p_asset.deprn_reserve));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Backlog Deprn Reserve :'||to_char(p_asset.backlog_deprn_reserve));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         General Fund :'||to_char(p_asset.general_fund));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Current Reval Factor :'||to_char(p_asset.current_reval_factor));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '         Cumulative Reval Factor :'||to_char(p_asset.Cumulative_reval_factor));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '==============================================================');
    END Debug_Asset;

/*=========================================================================+
 | Function Name:                                                          |
 |    Is_Default_Index_Found                                               |
 |                                                                         |
 | Description:                                                            |
 |    This function finds if the price indexes are defined for all the     |
 |    revaluation catchup periods and all periods after final revaluation  |
 |    until the current open period. If any of them still has the default  |
 |    value 9999.99, then the function returns FALSE.			   |
 +=========================================================================*/
    FUNCTION Is_Default_Index_Found(
    	p_book_type_code		VARCHAR2,
    	p_asset_id			NUMBER,
    	p_dpis_period_counter		NUMBER,
    	p_open_period_counter		NUMBER,
    	p_reval_catchup_period		NUMBER
    ) return BOOLEAN IS

    	l_period_info			igi_iac_types.prd_rec;
    	l_price_index_value		NUMBER;
    	l_last_reval_period		NUMBER DEFAULT NULL;
  	l_path_name VARCHAR2(150) := g_path||'is_default_index_found';
    BEGIN

    	FOR l_period_counter IN p_dpis_period_counter..(p_open_period_counter-1) LOOP

		l_price_index_value := 0;
    		IF NOT igi_iac_common_utils.get_period_info_for_counter(
    							p_book_type_code,
    							l_period_counter,
    							l_period_info) THEN
    			return FALSE;
    		END IF;

    		IF (p_dpis_period_counter = l_period_counter) OR (l_period_info.period_num = p_reval_catchup_period) THEN
    			IF NOT igi_iac_common_utils.get_price_index_value(
    							p_book_type_code,
    							p_asset_id,
    							l_period_info.period_name,
    							l_price_index_value) THEN
    				return FALSE;
    			END IF;

    			IF l_price_index_value = 9999.99 THEN
    				return FALSE;
    			END IF;

    			IF (l_period_info.period_num = p_reval_catchup_period) THEN
    				l_last_reval_period := l_period_counter;
    			END IF;
    		END IF;

    	END LOOP;

    	IF l_last_reval_period IS NOT NULL THEN
    	    FOR l_period_counter IN (l_last_reval_period+1)..p_open_period_counter LOOP

		l_price_index_value := 0;
    		IF NOT igi_iac_common_utils.get_period_info_for_counter(
    							p_book_type_code,
    							l_period_counter,
    							l_period_info) THEN
    			return FALSE;
    		END IF;

     		IF NOT igi_iac_common_utils.get_price_index_value(
    						p_book_type_code,
    						p_asset_id,
    						l_period_info.period_name,
    						l_price_index_value) THEN
    			return FALSE;
    		END IF;

    		IF l_price_index_value = 9999.99 THEN
    			return FALSE;
    		END IF;
    	    END LOOP;
	END IF;

    	return TRUE;

        EXCEPTION
            WHEN OTHERS THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                return FALSE;

    END Is_Default_Index_Found;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Prior_Addition                                                    |
 |                                                                         |
 | Description:                                                            |
 |    This function is called from codehook provided from FA Prior         |
 |    Additions program. This function calls do_addition which does the    |
 |    IAC Prior Addition processing.                                       |
 |    R12                                                                  |
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
        p_event_id                       NUMBER,  --R12 uptake
        p_calling_function               VARCHAR2
    ) return BOOLEAN IS
  	l_path_name VARCHAR2(150) := g_path||'do_prior_addition';
    BEGIN
        IF NOT Do_Addition(
                p_book_type_code,
                p_asset_id,
                p_category_id,
                p_deprn_method_code,
                p_cost,
                p_adjusted_cost,
                p_salvage_value,
                p_current_unit,
                p_life_in_months,
                NULL,  -- p_deprn_reserve
                NULL,  -- p_deprn_ytd
                p_calling_function,
                p_event_id) THEN
            return FALSE;
        END IF;
        return TRUE;
        EXCEPTION
            WHEN OTHERS THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                return FALSE;
    END Do_Prior_Addition;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Addition_Wrapper                                                  |
 |                                                                         |
 | Description:                                                            |
 |    This IAC function is for wrapping up the the Do_Prior_Addition() 	   |
 |    procedure.                                                           |
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
    ) return BOOLEAN IS
    l_path_name VARCHAR2(150) := g_path||'Do_Addition_Wrapper';
    BEGIN

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '********************************************');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => ' Start of Do_Addition_Wrapper ');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '********************************************');

        IF NOT Do_Prior_Addition(
                p_book_type_code,
                p_asset_id,
                p_category_id,
                p_deprn_method_code,
                p_cost,
                p_adjusted_cost,
                p_salvage_value,
                p_current_unit,
                p_life_in_months,
                p_event_id,
                p_calling_function) THEN
            return FALSE;
        END IF;
        return TRUE;
        EXCEPTION
            WHEN OTHERS THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                return FALSE;
    END;

/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Addition                                                          |
 |                                                                         |
 | Description:                                                            |
 |    This function calculates IAC catchup amounts for the asset added in  |
 |    prior period. This function is called from do_prior_addition and     |
 |    IAC Implementation Data Preparation program. This function call      |
 |    functions in igi_iac_catchup_pkg and igi_iac_reval_wrapper packages. |
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
        p_event_id                       NUMBER  --R12 uptake
    ) return BOOLEAN IS

        CURSOR c_allow_indexed_reval_flag IS
        SELECT allow_indexed_reval_flag
        FROM igi_iac_category_books
        WHERE book_type_code = p_book_type_code
        AND category_id = p_category_id;

        CURSOR c_period_num_for_catchup IS
        SELECT period_num_for_catchup
        FROM igi_iac_book_controls
        WHERE book_type_code = p_book_type_code;

        /* Added for bug 2411707 vgadde 12/06/2002 */
        /* This cursor is used for fetching deprn reserve amount entered at the time of adding asset */
        CURSOR c_get_deprn_acc IS
        SELECT deprn_reserve
        FROM fa_deprn_summary
        WHERE book_type_code = p_book_type_code
        AND asset_id = p_asset_id
        AND deprn_source_code = 'BOOKS';

        /* bug 2450796 sekhar   need to update the reval rates ..only one record should have staus = 'Y'  for an asset */
        Cursor C_Reval_Rates is
        SELECT max(adjustment_id)
        FROM   igi_iac_transaction_headers ith
        WHERE  ith.book_type_code =p_book_type_code
        AND    ith.asset_id = p_asset_id
        AND    (ith.transaction_type_code = 'ADDITION' AND  ith.Transaction_sub_type ='REVALUATION');

        /* Cursor to get cost and salvage value for the asset from FA */
   	    CURSOR c_fa_books(p_asset_id fa_books.asset_id%TYPE) IS
   	        SELECT salvage_value,cost
   	        FROM fa_books
   	        WHERE book_type_code = p_book_type_code
   	        AND   asset_id = p_asset_id
   	        AND   transactioN_header_id_out is NULL ;

        l_dpis_period_counter       NUMBER;
        l_open_period               igi_iac_types.prd_rec;
        l_period_info               igi_iac_types.prd_rec;
        l_allow_indexed_reval_flag  igi_iac_category_books.allow_indexed_reval_flag%TYPE;
        l_period_num_for_catchup    igi_iac_book_controls.period_num_for_catchup%TYPE;
        l_idx1                      BINARY_INTEGER DEFAULT 0;
        l_idx2                      BINARY_INTEGER DEFAULT 0;
        l_reval_control             igi_iac_types.iac_reval_control_tab;
        l_reval_asset_params        igi_iac_types.iac_reval_asset_params_tab;
        l_reval_input_asset         igi_iac_types.iac_reval_asset_tab;
        l_reval_output_asset        igi_iac_types.iac_reval_asset_tab;
        l_reval_output_asset_mvmt   igi_iac_types.iac_reval_asset_tab;
        l_reval_asset_rules         igi_iac_types.iac_reval_asset_rules_tab;
        l_prev_rate_info            igi_iac_types.iac_reval_rates_tab;
        l_curr_rate_info_first      igi_iac_types.iac_reval_rates_tab;
        l_curr_rate_info_next       igi_iac_types.iac_reval_rates_tab;
        l_curr_rate_info            igi_iac_types.iac_reval_rates_tab;
        l_reval_exceptions          igi_iac_types.iac_reval_exceptions_tab;
        l_fa_asset_info             igi_iac_types.iac_reval_fa_asset_info_tab;
        l_reval_params              igi_iac_types.iac_reval_params;
        l_reval_asset               igi_iac_types.iac_reval_input_asset;
        l_reval_asset_out           igi_iac_types.iac_reval_output_asset;
        l_revaluation_id            igi_iac_revaluations.revaluation_id%TYPE;
        l_user_id                   NUMBER DEFAULT fnd_global.user_id;
        l_login_id                  NUMBER DEFAULT fnd_global.login_id;
        l_current_reval_factor      igi_iac_asset_balances.current_reval_factor%TYPE;
        l_cumulative_reval_factor   igi_iac_asset_balances.cumulative_reval_factor%TYPE;
        l_last_reval_period         igi_iac_asset_balances.period_counter%TYPE;
        l_rowid			    VARCHAR2(25);
        l_deprn_acc                 fa_deprn_summary.deprn_reserve%TYPE;
        l_get_latest_adjustment_id  number;
	/* Bug 2961656 vgadde 08-jul-2003 Start(1) */
        l_calling_function          VARCHAR2(80);
        l_fa_deprn_amount_py        NUMBER;
        l_fa_deprn_amount_cy        NUMBER;
        l_last_asset_period         NUMBER;
        l_salvage_value             NUMBER;
        l_cost                      NUMBER;
	/* Bug 2961656 vgadde 08-jul-2003 End(1) */
  	l_path_name VARCHAR2(150) := g_path||'do_addition';

        /* This function checks if the category is attched to the book in IAC setup */
        FUNCTION is_iac_cat_book_defined(l_book_type_code VARCHAR2,
                                     l_category_id    NUMBER) return BOOLEAN IS
        CURSOR c_cat_book_defined IS
        SELECT 'X'
        FROM IGI_IAC_CATEGORY_BOOKS
        WHERE book_type_code = l_book_type_code
        AND   category_id = l_category_id
        AND   rownum = 1;

        l_dummy VARCHAR2(1) DEFAULT NULL;
        BEGIN
            OPEN c_cat_book_defined;
            FETCH c_cat_book_defined INTO l_dummy;

            IF c_cat_book_defined%FOUND THEN
	            CLOSE c_cat_book_defined;
	            return TRUE;
            ELSE
	            CLOSE c_cat_book_defined;
            	return  FALSE;
            END IF;

            EXCEPTION
                WHEN OTHERS THEN
  		   igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                   return FALSE ;
        END is_iac_cat_book_defined;

    BEGIN
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '********************************************');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => ' Start of IAC Prior Additions  Processing');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '********************************************');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '	  Parameters from FA code hook');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Book type code  :'||p_book_type_code);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Category Id     :'||to_char(p_category_id));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Asset Id        :'||to_char(p_asset_id));

        IF NOT igi_iac_common_utils.is_iac_book(p_book_type_code) THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     This book is not an IAC book');
            return TRUE;
        END IF;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     This book is an IAC book');

        IF NOT is_iac_cat_book_defined(p_book_type_code,
                                        p_category_id) THEN
  	    FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	    FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_additions_pkg');
	    FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','The category is not set up for book in IAC Options', TRUE);
  	    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	p_full_path => l_path_name,
		  	p_remove_from_stack => FALSE);
	    fnd_file.put_line(fnd_file.log, fnd_message.get);
            return FALSE;
        END IF;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     This Category defined for book in IAC setup');

        -- 30/07/2003, check if asset is a negative asset, if it is return TRUE
        IF (p_cost < 0) THEN
  	   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Asset '||to_char(p_asset_id)||' is a negative asset. Cost '||to_char(p_cost));
           RETURN TRUE;
        END IF;

        OPEN c_allow_indexed_reval_flag;
        FETCH c_allow_indexed_reval_flag INTO l_allow_indexed_reval_flag;
        CLOSE c_allow_indexed_reval_flag;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Allow Indexed reval flag :'||l_allow_indexed_reval_flag);
        IF (nvl(l_allow_indexed_reval_flag,'Y') = 'N') THEN
            return TRUE;
        END IF;

        IF NOT igi_iac_common_utils.get_dpis_period_counter(p_book_type_code,
                                                            p_asset_id,
                                                            l_dpis_period_counter) THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_string => '*** Error in Fetching DPIS period counter');
            return FALSE;
        END IF;

        IF NOT igi_iac_common_utils.get_open_period_info(p_book_type_code,
                                                         l_open_period) THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_string => '*** Error in fetching Open period info for book');
            return FALSE;
        END IF;

	/* Bug 2961656 vgadde 08-jul-2003 Start(2) */
        IF p_calling_function = 'UPGRADE' THEN
            l_calling_function := p_calling_function;
        ELSE
            l_calling_function := 'ADDITION';
        END IF;
	/* Bug 2961656 vgadde 08-jul-2003 End(2) */

	/* Bug 2906034 vgadde 25/04/2002 Start(1) */
        IF p_calling_function = 'DEPRECIATION' THEN
            l_open_period.period_counter := l_open_period.period_counter - 1;
        END IF;
	/* Bug 2906034 vgadde 25/04/2002 End(1) */

        /* Bug 2407352 vgadde 07/06/2002 Start */
        IF (l_dpis_period_counter = l_open_period.period_counter) THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     The asset is added in the current period');
            return TRUE;
        END IF;
        /* Bug 2407352 vgadde 07/06/2002 End */

	/* Bugs 2411707 and 2411561 vgadde 12/06/2002 Start(1) */
	/* Bug 2961656 vgadde 08-jul-2003 Start(3) commented */
        /*OPEN c_get_deprn_acc;
        FETCH c_get_deprn_acc INTO l_deprn_acc;
        CLOSE c_get_deprn_acc;

        Debug('     Catchup Depreciation reserve entered by user :' || to_char(l_deprn_acc));
        IF (nvl(l_deprn_acc,0) <> 0) THEN
            return TRUE;
        END IF;*/
	/* Bug 2961656 vgadde 08-jul-2003 End(3) commented */
	/* Bugs 2411707 and 2411561 vgadde 12/06/2002 End(1) */

        OPEN c_period_num_for_catchup;
        FETCH c_period_num_for_catchup INTO l_period_num_for_catchup;
        CLOSE c_period_num_for_catchup;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Checking for default price index values in catchup periods');
	IF NOT Is_Default_Index_Found(p_book_type_code,
    					p_asset_id,
    					l_dpis_period_counter,
    					l_open_period.period_counter,
    					l_period_num_for_catchup) THEN
  	        FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	        FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_additions_pkg');
	        FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','The price indexes are not setup properly. Atleast one period in catchup has the index 9999.99', TRUE);
  	        igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	p_full_path => l_path_name,
		  	p_remove_from_stack => FALSE);
	        fnd_file.put_line(fnd_file.log, fnd_message.get);
    		return FALSE;
    	END IF;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Revaluation catchup period for the book :'||to_char(l_period_num_for_catchup));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Revaluation catchup periods for the asset ');
        FOR l_period_counter IN l_dpis_period_counter..(l_open_period.period_counter-1) LOOP

            IF NOT igi_iac_common_utils.get_period_info_for_counter(p_book_type_code,
                                                                    l_period_counter,
                                                                    l_period_info) THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Error in fetching period information');
                return FALSE;
            END IF;

	    /* if the period in the loop is a catchup period for revaluation
	      then initialize revaluation structures              */
            IF (l_period_num_for_catchup = l_period_info.period_num) THEN
                Debug_Period(l_period_info);
                l_idx1 := l_idx1 + 1;
                l_reval_control(l_idx1).revaluation_mode := 'L'; -- Live Mode
                l_reval_asset_rules(l_idx1).revaluation_type := 'O'; -- Occasional
                l_reval_asset_params(l_idx1).asset_id := p_asset_id;
                l_reval_asset_params(l_idx1).category_id := p_category_id;
                l_reval_asset_params(l_idx1).book_type_code := p_book_type_code;
                l_reval_asset_params(l_idx1).period_counter := l_period_counter;

            END IF;
        END LOOP;


        IF (l_idx1 = 0) THEN /* No catch-up required */
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '    No revaluation catchup periods found');
            return TRUE;
        END IF;

        IF NOT igi_iac_catchup_pkg.get_FA_Deprn_Expense(p_asset_id,
                                 p_book_type_code,
                                 l_open_period.period_counter,
                                 l_calling_function,
                                 p_deprn_reserve,
                                 p_deprn_ytd,
                                 l_fa_deprn_amount_py,
                                 l_fa_deprn_amount_cy,
                                 l_last_asset_period) THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Error in get_FA_Deprn_Expense function');
                return FALSE;
        END IF;
               /*Salavge value correction*/
                -- resreve
               IF (p_salvage_value Is Null) Or (P_cost is Null) THEN

                    OPEN c_fa_books(p_asset_id);
                	FETCH c_fa_books into   l_salvage_value,
                                            l_cost;
                	CLOSE c_fa_books;
               ELSE
                    l_salvage_value := p_salvage_value;
                    l_cost          := P_cost;
               END IF;

               IF l_salvage_value <> 0 Then
  		 igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Salavge Value Correction deprn_amount_py before :' ||l_fa_deprn_amount_py);
                 -- deprn amount l_fa_deprn_amount_py
                IF NOT igi_iac_salvage_pkg.correction(p_asset_id => p_asset_id,
                                                      P_book_type_code =>p_book_type_code,
                                                      P_value=>l_fa_deprn_amount_py,
                                                      P_cost=>l_cost,
                                                      P_salvage_value=>l_salvage_value,
                                                      P_calling_program=>'ADDITION') THEN
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Salavge Value Correction Failed : ');
                    return false;
                   END IF;
  		  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Salavge Value Correction deprn_amount_py after :' ||l_fa_deprn_amount_py );
  		  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Salavge Value Correction deprn_amount_cy before :' ||l_fa_deprn_amount_cy);
                   -- deprn l_fa_deprn_amount_cy
                   IF NOT igi_iac_salvage_pkg.correction(p_asset_id => p_asset_id,
                                                      P_book_type_code =>p_book_type_code,
                                                      P_value=>l_fa_deprn_amount_cy,
                                                      P_cost=>l_cost,
                                                      P_salvage_value=>l_salvage_value,
                                                      P_calling_program=>'ADDITION') THEN

  		    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Salavge Value Correction Failed : ');
                    return false;
                  END IF;
  		  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+Salavge Value Correction deprn_amount_cy after :' ||l_fa_deprn_amount_cy);
                 END IF;
                /*salvage value correction*/


  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Calling Revaluation Initialization program ');
        IF NOT igi_iac_catchup_pkg.do_reval_init_struct(l_open_period.period_counter,
                                                        l_reval_control,
                                                        l_reval_asset_params,
                                                        l_reval_input_asset,
                                                        l_reval_output_asset,
                                                        l_reval_output_asset_mvmt,
                                                        l_reval_asset_rules,
                                                        l_prev_rate_info,
                                                        l_curr_rate_info_first,
                                                        l_curr_rate_info_next,
                                                        l_curr_rate_info,
                                                        l_reval_exceptions,
                                                        l_fa_asset_info,
                                                        l_fa_deprn_amount_py,
                                                        l_fa_deprn_amount_cy,
                                                        l_last_asset_period,
                                                        l_calling_function) THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	p_full_path => l_path_name,
		     	p_string => '*** Error in catchup pkg for revaluation initialization');
            return FALSE;
        END IF;
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Back from Revaluation Initialization');

        FOR l_idx2 IN 1..l_idx1 LOOP

            IF (l_idx2 <> 1) THEN

                l_reval_asset := l_reval_output_asset(l_idx2 - 1);

		/* Added + 1 for the first 2 parameters for bug 2411478 vgadde */
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => ' Doing depreciation catchup for the periods between revaluation');
                IF NOT igi_iac_catchup_pkg.do_deprn_catchup(l_reval_asset_params(l_idx2 - 1).period_counter + 1,
                                                     l_reval_asset_params(l_idx2).period_counter + 1,
                                                     l_open_period.period_counter,
                                                     FALSE,
                                                     l_calling_function,
                                                     l_fa_deprn_amount_py,
                                                     l_fa_deprn_amount_cy,
                                                     l_last_asset_period,
                                                     p_deprn_reserve,
                                                     p_deprn_ytd,
                                                     l_reval_asset,
                                                     p_event_id )THEN
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '*** Error in depreciation catchup');
                    return FALSE;
                END IF;
  	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '	Back from depreciation catchup');

                l_current_reval_factor := l_reval_input_asset(l_idx2).current_reval_factor;
                l_cumulative_reval_factor := l_reval_input_asset(l_idx2).cumulative_reval_factor;
                l_reval_input_asset(l_idx2) := l_reval_asset;
                l_reval_input_asset(l_idx2).current_reval_factor := l_current_reval_factor;
                l_reval_input_asset(l_idx2).cumulative_reval_factor := l_cumulative_reval_factor;
            END IF;

            IF (l_idx2 = l_idx1) THEN
                /* Last revaluation - Insert records into revaluation tables*/
                IF (p_calling_function <> 'UPGRADE') THEN
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '		Last Revaluation - Inserting into igi_iac_revaluations');

			l_rowid := NULL;
			l_revaluation_id := NULL;

                	igi_iac_revaluations_pkg.insert_row
                       		(l_rowid,
                       		l_revaluation_id,
                        	p_book_type_code,
                        	sysdate,
                        	l_reval_asset_params(l_idx1).period_counter,
                        	'NEW',
                        	NULL,
                        	NULL,
                        	'ADDITION',
                            X_event_id => p_event_id);
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '		Revaluation Id :'||to_char(l_revaluation_id));

  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '		Inserting into igi_iac_reval_asset_rules');
                	l_rowid := NULL;
                	igi_iac_reval_asset_rules_pkg.insert_row
                       		(l_rowid,
                       		l_revaluation_id,
                        	l_reval_asset_params(l_idx1).book_type_code,
                        	l_reval_asset_params(l_idx1).category_id,
                        	l_reval_asset_params(l_idx1).asset_id,
                        	l_reval_asset_rules(l_idx1).revaluation_factor,
                        	l_reval_asset_rules(l_idx1).revaluation_type,
                        	l_reval_asset_rules(l_idx1).new_cost,
                        	l_reval_input_asset(l_idx2).adjusted_cost,
                        	'Y',
                        	'N',
                        	NULL
                            );
                END IF; /* End of checking for UPGRADE */

		l_last_reval_period := l_reval_asset_params(l_idx2).period_counter;
		l_reval_asset_params(l_idx2).period_counter := l_open_period.period_counter;
		l_reval_input_asset(l_idx2).period_counter := l_open_period.period_counter;
		l_reval_asset_params(l_idx2).revaluation_id := l_revaluation_id;
		l_reval_asset_rules(l_idx2).revaluation_id := l_revaluation_id;

        	IF (p_calling_function = 'UPGRADE') THEN
        		l_reval_control(l_idx2).calling_program := 'UPGRADE';
        	END IF;
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '		Period counter passed to Reval CRUD :'||to_char(l_open_period.period_counter ));

            END IF;

            l_reval_params.reval_control := l_reval_control(l_idx2);
            l_reval_params.reval_asset_params := l_reval_asset_params(l_idx2);
            l_reval_params.reval_input_asset := l_reval_input_asset(l_idx2);
            l_reval_params.reval_output_asset := l_reval_input_asset(l_idx2);
            l_reval_params.reval_output_asset_mvmt := l_reval_output_asset_mvmt(l_idx2);
            l_reval_params.reval_asset_rules := l_reval_asset_rules(l_idx2);
            l_reval_params.reval_prev_rate_info := l_prev_rate_info(l_idx2);
            l_reval_params.reval_curr_rate_info_first := l_curr_rate_info_first(l_idx2);
            l_reval_params.reval_curr_rate_info_next := l_curr_rate_info_next(l_idx2);
            l_reval_params.reval_asset_exceptions := l_reval_exceptions(l_idx2);
            l_reval_params.fa_asset_info := l_fa_asset_info(l_idx2);

            /* call revaluation processing function here */
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Input asset balances to revaluation program');
            Debug_Asset(l_reval_input_asset(l_idx2));

            IF NOT igi_iac_reval_wrapper.do_reval_calc_asset(l_reval_params,
                                                             l_reval_asset_out) THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	p_full_path => l_path_name,
		     	p_string => '*** Error in Revaluation Program');
                return FALSE;
            END IF;

            l_current_reval_factor := l_reval_output_asset(l_idx2).current_reval_factor;
            l_cumulative_reval_factor := l_reval_output_asset(l_idx2).cumulative_reval_factor;
            l_reval_output_asset(l_idx2) := l_reval_asset_out;
            l_reval_output_asset(l_idx2).current_reval_factor := l_current_reval_factor;
            l_reval_output_asset(l_idx2).cumulative_reval_factor := l_cumulative_reval_factor;

            /* Bug 2425856 vgadde 20/06/2002 Start(1) */
            BEGIN
                IF (l_idx2 = l_idx1 and p_calling_function <> 'UPGRADE') THEN /* Last Revaluation */
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     Last revaluation period :'||to_char(l_last_reval_period));
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     Revaluation Id :'||to_char(l_revaluation_id));
                    UPDATE igi_iac_revaluation_rates
                    SET period_counter = l_last_reval_period
                    WHERE revaluation_id =  l_revaluation_id
                    AND asset_id = p_asset_id
                    AND book_type_code = p_book_type_code;

                    IF SQL%FOUND then
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     Records in reval rates updated for correct period');
                    ELSE
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '***  No record found in reval rates table to update');
                        return FALSE;
                    END IF;
                END IF;
            END;
            /* Bug 2425856 vgadde 20/06/2002 End(1) */

        END LOOP;

        IF (l_last_reval_period < l_open_period.period_counter) THEN

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '	Doing the final catchup for depreciation');

            l_reval_asset := l_reval_output_asset(l_idx1);
		/* Added + 1 for the first parameter for bug 2411478 vgadde 12/06/2002 */
            IF NOT igi_iac_catchup_pkg.do_deprn_catchup(l_last_reval_period + 1,
                                                 l_open_period.period_counter,
                                                 l_open_period.period_counter,
                                                 TRUE,
                                                 l_calling_function,
                                                 l_fa_deprn_amount_py,
                                                 l_fa_deprn_amount_cy,
                                                 l_last_asset_period,
                                                 p_deprn_reserve,
                                                 p_deprn_ytd,
                                                 l_reval_asset,
                                                 p_event_id )THEN
  		        igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     			p_full_path => l_path_name,
		     			p_string => '*** Error in depreciation catchup for final run');
                	return FALSE;
            END IF;
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Output from final catchup');
            Debug_Asset(l_reval_asset);

        END IF;

        /* bug 2502128 need to update the reval rates ..only one record should have staus = 'Y'  for an asset */
	    IF (p_calling_function <> 'UPGRADE') THEN
               l_get_latest_adjustment_id :=0;
            	OPEN C_Reval_Rates;
            	FETCH C_Reval_Rates into l_get_latest_adjustment_id;
            	CLOSE C_Reval_Rates;
            	IF NOT  IGI_IAC_REVAL_CRUD.update_reval_rates (fp_adjustment_id =>  l_get_latest_adjustment_id) THEN
  			igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     			p_full_path => l_path_name,
		     			p_string => '*** Failed to Update REVAL RATES');
              		return FALSE;
             	END IF;
	    END IF;

        -- Added by Venkat Gadde
        IF p_calling_function <> 'UPGRADE' THEN
        UPDATE igi_iac_transaction_headers
        SET event_id = p_event_id
        WHERE book_type_code = p_book_type_code
        AND asset_id = p_asset_id;

        UPDATE igi_iac_adjustments
        SET event_id = p_event_id
        WHERE book_type_code = p_book_type_code
        AND asset_id = p_asset_id;
        END IF;
        -- End of code added by Venkat Gadde
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '******* End of IAC Prior addition processing for asset *****');
        return TRUE;

        EXCEPTION
            WHEN OTHERS THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                return FALSE;
    END Do_Addition;


    FUNCTION Do_Rollback_Addition(
       p_book_type_code                 VARCHAR2,
       p_period_counter                 NUMBER,
       p_calling_function               VARCHAR2
    ) return BOOLEAN IS

    CURSOR c_get_asset_add_info IS
    SELECT asset_id,adjustment_id,transaction_sub_type
    FROM igi_iac_transaction_headers
    WHERE book_type_code = p_book_type_code
    AND period_counter = p_period_counter
    AND transaction_type_code = 'ADDITION';

    CURSOR c_get_distributions(p_asset_id igi_iac_det_balances.asset_id%TYPE,
                                p_adjustment_id igi_iac_det_balances.adjustment_id%TYPE) IS
    SELECT distribution_id
    FROM igi_iac_det_balances
    WHERE book_type_code = p_book_type_code
    AND asset_id = p_asset_id;

    /* Bug 2425914 vgadde 21/06/2002 */
    /* Modified query to fecth records created by ADDITION only */
    CURSOR c_get_revaluation_info(p_asset_id igi_iac_det_balances.asset_id%TYPE) IS
    SELECT a.revaluation_id
    FROM igi_iac_revaluations r,igi_iac_reval_asset_rules a
    WHERE a.revaluation_id = r.revaluation_id
    AND a.book_type_code = p_book_type_code
    AND a.asset_id = p_asset_id
    AND r.calling_program = 'ADDITION';

    CURSOR c_get_adjustments(p_asset_id igi_iac_adjustments.asset_id%TYPE,
                            p_adjustment_id igi_iac_adjustments.adjustment_id%TYPE) IS
    SELECT 'X'
    FROM igi_iac_adjustments
    WHERE adjustment_id = p_adjustment_id
    AND book_type_code = p_book_type_code
    AND asset_id = p_asset_id
    AND rownum = 1;

    CURSOR c_get_asset_balances(p_asset_id igi_iac_asset_balances.asset_id%TYPE,
                                cp_period_counter igi_iac_asset_balances.period_counter%TYPE) IS
    SELECT 'X'
    FROM igi_iac_asset_balances
    WHERE book_type_code = p_book_type_code
    AND asset_id = p_asset_id
    AND period_counter = cp_period_counter;

    CURSOR c_get_revaluation_rates(p_asset_id igi_iac_revaluation_rates.asset_id%TYPE,
                            p_revaluation_id igi_iac_revaluation_rates.revaluation_id%TYPE) IS
    SELECT 'X'
    FROM igi_iac_revaluation_rates
    WHERE asset_id = p_asset_id
    AND book_type_code = p_book_type_code
    AND revaluation_id = p_revaluation_id;

    CURSOR c_get_fa_distributions(cp_asset_id igi_iac_det_balances.asset_id%TYPE,
                                cp_adjustment_id igi_iac_det_balances.adjustment_id%TYPE) IS
    SELECT distribution_id
    FROM igi_iac_fa_deprn
    WHERE book_type_code = p_book_type_code
    AND asset_id = cp_asset_id
    AND adjustment_id = cp_adjustment_id;

    l_revaluation_id    igi_iac_revaluations.revaluation_id%TYPE;
    l_dummy             VARCHAR2(1);
    l_path_name VARCHAR2(150) := g_path||'do_rollback_addition';

    BEGIN
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '********* Start of IAC Additions Rollback **********');
        FOR l_asset_info IN c_get_asset_add_info LOOP
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => ' Processing for Asset :'||to_char(l_asset_info.asset_id));
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => ' Adjustment           :'||to_char(l_asset_info.adjustment_id));
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => ' Transaction          :'||l_asset_info.transaction_sub_type);

            /* Delete records from igi_iac_adjustments */
            l_dummy := NULL;
            OPEN c_get_adjustments(l_asset_info.asset_id,l_asset_info.adjustment_id);
            FETCH c_get_adjustments INTO l_dummy;

            IF c_get_adjustments%FOUND THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			     p_full_path => l_path_name,
		    	     p_string => '     Deleting records from igi_iac_adjustments');
                igi_iac_adjustments_pkg.delete_row(
                        x_adjustment_id => l_asset_info.adjustment_id);
            ELSIF c_get_adjustments%NOTFOUND THEN
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			     p_full_path => l_path_name,
		    	     p_string => '     No records found in igi_iac_adjustments for delete');
            END IF;

            CLOSE c_get_adjustments;

            /* Delete records from igi_iac_det_balances */
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Deleting records from igi_iac_det_balances');
            FOR l_det_balance IN c_get_distributions(l_asset_info.asset_id,
                                                    l_asset_info.adjustment_id) LOOP
                    igi_iac_det_balances_pkg.delete_row(
                        x_adjustment_id     => l_asset_info.adjustment_id,
                        x_asset_id          => l_asset_info.asset_id,
                        x_distribution_id   => l_det_balance.distribution_id,
                        x_book_type_code    => p_book_type_code,
                        x_period_counter    => p_period_counter);
            END LOOP;

            /* Delete records from igi_iac_fa_deprn */
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Deleting records from igi_iac_fa_deprn');
            FOR l_iac_fa_det_balance IN c_get_fa_distributions(l_asset_info.asset_id,
                                                    l_asset_info.adjustment_id) LOOP
                    igi_iac_fa_deprn_pkg.delete_row(
                    	x_book_type_code    => p_book_type_code,
                        x_asset_id          => l_asset_info.asset_id,
                        x_period_counter    => p_period_counter,
                        x_adjustment_id     => l_asset_info.adjustment_id,
                        x_distribution_id   => l_iac_fa_det_balance.distribution_id);
            END LOOP;

            /* Delete records from igi_iac_asset_balances */
            IF l_asset_info.transaction_sub_type <> 'CATCHUP' THEN

                OPEN c_get_asset_balances(l_asset_info.asset_id,p_period_counter);
                FETCH c_get_asset_balances INTO l_dummy;

                IF c_get_asset_balances%FOUND THEN
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     Deleting records from igi_iac_asset_balances for current period');
                    igi_iac_asset_balances_pkg.delete_row(
                        x_asset_id          => l_asset_info.asset_id,
                        x_book_type_code    => p_book_type_code,
                        x_period_counter    => p_period_counter);
                ELSIF c_get_asset_balances%NOTFOUND THEN
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     No records found in igi_iac_asset_balances to delete');
                END IF;

                CLOSE c_get_asset_balances;

                OPEN c_get_asset_balances(l_asset_info.asset_id, p_period_counter+1);
                FETCH c_get_asset_balances INTO l_dummy;
                IF c_get_asset_balances%FOUND THEN
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     Deleting records from igi_iac_asset_balances for next period');
                    igi_iac_asset_balances_pkg.delete_row(
                        x_asset_id          => l_asset_info.asset_id,
                        x_book_type_code    => p_book_type_code,
                        x_period_counter    => p_period_counter+1);
                ELSE
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     No records found in igi_iac_asset_balances to delete');
                END IF;
                CLOSE c_get_asset_balances; -- Bug 2417394 this cursor was not gettign closed previously
            END IF;

            /* Delete records from igi_iac_transaction_headers */
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     Deleting records from igi_iac_transaction_headers');
                igi_iac_trans_headers_pkg.delete_row(
                        x_adjustment_id     => l_asset_info.adjustment_id);

            IF l_asset_info.transaction_sub_type <> 'CATCHUP' THEN

                l_revaluation_id := NULL;
                OPEN c_get_revaluation_info(l_asset_info.asset_id);
                FETCH c_get_revaluation_info INTO l_revaluation_id;
                CLOSE c_get_revaluation_info;
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => ' Revaluation Id :'||to_char(l_revaluation_id));

                /* Delete records from igi_iac_reval_asset_rules */
                IF (l_revaluation_id IS NOT NULL) THEN

  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     Deleting records from igi_iac_reval_asset_rules');
                    igi_iac_reval_asset_rules_pkg.delete_row(
                        x_asset_id          => l_asset_info.asset_id,
                        x_book_type_code    => p_book_type_code,
                        x_revaluation_id    => l_revaluation_id);

                    /* Delete records from igi_iac_revaluations */
  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '     Deleting records from igi_iac_revaluations');
                    igi_iac_revaluations_pkg.delete_row(
                        x_revaluation_id    => l_revaluation_id);

                    /* Delete records from igi_iac_revaluation_rates */
                    OPEN c_get_revaluation_rates(l_asset_info.asset_id,l_revaluation_id);
                    FETCH c_get_revaluation_rates INTO l_dummy;

                    IF c_get_revaluation_rates%FOUND THEN
  		        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '	    Deleting records from igi_iac_revaluation_rates');
                        DELETE FROM igi_iac_revaluation_rates
                        WHERE asset_id = l_asset_info.asset_id
                        AND book_type_code = p_book_type_code
                        AND revaluation_id = l_revaluation_id;
                    END IF;

                    CLOSE c_get_revaluation_rates;

                END IF;

            END IF;

        END LOOP;
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '********* End of IAC Additions Rollback **********');
        return TRUE;

        EXCEPTION
            WHEN OTHERS THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                return FALSE;

    END Do_Rollback_Addition;

END igi_iac_additions_pkg; -- Package body

/
