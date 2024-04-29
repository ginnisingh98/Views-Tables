--------------------------------------------------------
--  DDL for Package Body IGI_IAC_DEPRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_DEPRN_PKG" AS
-- $Header: igiiaprb.pls 120.20.12000000.2 2007/10/16 14:21:40 sharoy ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER;
g_proc_level  NUMBER;
g_event_level NUMBER;
g_excep_level NUMBER;
g_error_level NUMBER;
g_unexp_level NUMBER;
g_path        VARCHAR2(100);

--===========================FND_LOG.END=======================================

/*=========================================================================+
 | Function Name:                                                          |
 |    Synchronize_Calendars                                                |
 |                                                                         |
 | Description:                                                            |
 |    This function synchronizes calendars used in IAC with the 	   |
 |    corresponding FA calendar.                			   |
 |                                                                         |
 +=========================================================================*/
    FUNCTION Synchronize_Calendars(p_book_type_code IN VARCHAR2) RETURN BOOLEAN IS

        /* Cursor for getting distinct calendar price index combinations */
        CURSOR c_get_cal_price_indexes IS
            SELECT DISTINCT cal_price_index_link_id
            FROM igi_iac_category_books
            WHERE book_type_code = p_book_type_code;

        /* Cursor for getting the last calendar period from Oracle Assets */
        CURSOR c_fa_max_date(p_cal_price_index_link_id igi_iac_cal_price_indexes.cal_price_index_link_id%TYPE) IS
            SELECT max(end_date)
            FROM fa_calendar_periods
            WHERE calendar_type = (
                SELECT calendar_type
                FROM igi_iac_cal_price_indexes
                WHERE cal_price_index_link_id = p_cal_price_index_link_id );

        /* Cursor for getting the last period from Inflation Accounting */
        CURSOR c_iac_max_date(p_cal_price_index_link_id igi_iac_cal_price_indexes.cal_price_index_link_id%TYPE) IS
            SELECT max(date_to)
            FROM igi_iac_cal_idx_values
            WHERE cal_price_index_link_id = p_cal_price_index_link_id;

        /* Cursor for getting the Price Index value defined for the last period defined in IAC */
        CURSOR c_current_price_index(p_max_date_to date ,
                            p_cal_price_index_link_id igi_iac_cal_price_indexes.cal_price_index_link_id%TYPE) IS
            SELECT current_price_index_value
            FROM igi_iac_cal_idx_values
            WHERE trunc(date_to) = trunc(p_max_date_to)
            AND cal_price_index_link_id = p_cal_price_index_link_id ;

        /* Cursor to get all periods from FA which are greater than the last period defined in IAC */
        CURSOR c_get_fa_periods(p_max_date_to date ,
                    p_cal_price_index_link_id igi_iac_cal_price_indexes.cal_price_index_link_id%TYPE) IS
            SELECT start_date, end_date
            FROM fa_calendar_periods
            WHERE trunc(end_date) > trunc(p_max_date_to)
            AND calendar_type = (
                    SELECT calendar_type
                    FROM igi_iac_cal_price_indexes
                    WHERE cal_price_index_link_id = p_cal_price_index_link_id );

        l_fa_max_date	date;
        l_iac_max_date	date;
        l_rowid		varchar2(25);
        l_curr_price_idx_value igi_iac_cal_idx_values.current_price_index_value%TYPE;
        l_path 	 	VARCHAR2(100);
    BEGIN
        l_path := g_path||'Synchronize_Calendars';
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Start of Synchronizing IAC Calendars');
        FOR l_get_cal_price_indexes IN c_get_cal_price_indexes LOOP

            OPEN c_fa_max_date(l_get_cal_price_indexes.cal_price_index_link_id);
            FETCH c_fa_max_date INTO l_fa_max_date;
            CLOSE c_fa_max_date;

            OPEN c_iac_max_date(l_get_cal_price_indexes.cal_price_index_link_id);
            FETCH c_iac_max_date INTO l_iac_max_date;
            CLOSE c_iac_max_date;

            IF trunc(l_iac_max_date) < trunc(l_fa_max_date) THEN
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Synchronizing for cal_price_index_link_id :'||to_char(l_get_cal_price_indexes.cal_price_index_link_id));
                /* Commented for bug 3197000 vgadde 19_dec-2003 Start(1)
                OPEN c_current_price_index(l_iac_max_date ,
            	    			l_get_cal_price_indexes.cal_price_index_link_id);
                FETCH c_current_price_index INTO l_curr_price_idx_value;
                CLOSE c_current_price_index;
                Commented for bug 3197000 vgadde 19_dec-2003 End(1) */

                /* Insert a record into IAC for each period that is defined in FA and not yet defined in IAC */
                FOR l_get_fa_period IN c_get_fa_periods(l_iac_max_date ,
            	    					    l_get_cal_price_indexes.cal_price_index_link_id) LOOP

                    l_rowid := NULL;

                    igi_iac_cal_idx_values_pkg.insert_row(
            	        	X_rowid		=> l_rowid ,
            	        	X_cal_price_index_link_id => l_get_cal_price_indexes.cal_price_index_link_id,
            	        	X_date_from	=> l_get_fa_period.start_date ,
            	        	X_date_to	=> l_get_fa_period.end_date ,
            	        	X_original_price_index_value => NULL ,
            	        	X_current_price_index_value => 9999.99 );
                END LOOP;
            END IF;
        END LOOP;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Successful completion of Synchronizing calendars');
        RETURN true;

    EXCEPTION
        WHEN OTHERS THEN
            igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'***Error in IAC synchronize_calendars :'||sqlerrm);
            RETURN false;
    END Synchronize_calendars;

/*=========================================================================+
 | Function Name:                                                          |
 |    Process_non_Deprn_Assets                                             |
 |                                                                         |
 | Description:                                                            |
 |    This function calls additions catch-up process for non-depreciating  |
 |    assets.  This function added for bug 2906034                         |
 |                                                                         |
 +=========================================================================*/
    /*FUNCTION Process_non_Deprn_Assets(
        p_book_type_code    IN VARCHAR2,
        p_calling_function  IN VARCHAR2
        ) return BOOLEAN IS

        CURSOR c_get_non_deprn_assets IS
            SELECT bk.asset_id, ad.asset_category_id
        	FROM fa_books bk, fa_additions ad
        	WHERE bk.book_type_code = p_book_type_code
        	AND bk.transaction_header_id_out IS NULL
        	AND bk.depreciate_flag = 'NO'
        	AND bk.adjustment_required_status = 'ADD'
        	AND bk.asset_id = ad.asset_id
        	AND NOT EXISTS (SELECT 'X'
				FROM igi_iac_asset_balances ab
				WHERE book_type_code = p_book_type_code
				AND  ab.asset_id = bk.asset_id);
        l_path 	 	VARCHAR2(100);

    BEGIN
        l_path 	:= g_path||'Process_non_Deprn_Assets';
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Start of processing for non-depreciation assets');
        FOR l_asset IN c_get_non_deprn_assets LOOP
            IF NOT igi_iac_additions_pkg.do_prior_addition (
                            p_book_type_code        => p_book_type_code,
                            p_asset_id              => l_asset.asset_id,
                            p_category_id           => l_asset.asset_category_id,
                            p_deprn_method_code     => NULL,
                            p_cost                  => NULL,
                            p_adjusted_cost         => NULL,
                            p_salvage_value         => NULL,
                            p_current_unit          => NULL,
                            p_life_in_months        => NULL,
                            p_calling_function      => p_calling_function,
                            p_event_id              => p_event_id ) THEN
                return FALSE;
            END IF;
        END LOOP;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'End of processing of non-depreciation assets');
        return TRUE;
    EXCEPTION
        WHEN OTHERS THEN
        igi_iac_debug_pkg.debug_unexpected_msg(l_path);
        return FALSE;
    END Process_non_Deprn_Assets;*/


/*=========================================================================+
 | Function Name:                                                          |
 |    Periodic_Reval_of_Deprn                                              |
 |                                                                         |
 | Description:                                                            |
 |    This function calculates complemetary depreciation amounts for IAC   |
 |    corresponding FA depreciation amounts for each period.		   |
 |                                                                         |
 +=========================================================================*/
    FUNCTION Periodic_Reval_of_Deprn( p_book_type_code varchar2
        				 , p_period_counter number) RETURN BOOLEAN IS

        /* Cursor to get the assets that are depreciated in the current period by FA */
        CURSOR c_fa_deprn_records IS
   	        SELECT asset_id, deprn_amount
   	        FROM fa_deprn_summary
   	        WHERE book_type_code = p_book_type_code
   	        AND   period_counter = p_period_counter ;

   	    /* Cursor to get the depreciation amount for the period for the asset */
   	    CURSOR c_get_deprn_amount(p_asset_id fa_deprn_detail.asset_id%TYPE) IS
   	    	SELECT sum(nvl(deprn_amount,0)), sum(nvl(deprn_adjustment_amount,0))
   	    	FROM fa_deprn_detail
   	    	WHERE book_type_code = p_book_type_code
   	    	AND   period_counter = p_period_counter
   	    	AND   asset_id = p_asset_id;

   	    /* Cursor to get the depreciation amount for the period for the asset */
   	    CURSOR c_get_dist_deprn_amount(p_asset_id fa_deprn_detail.asset_id%TYPE,cp_distribution_id fa_deprn_detail.distribution_id%TYPE) IS
   	    	SELECT nvl(deprn_amount,0) deprn_amount, nvl(deprn_adjustment_amount,0) deprn_adjustment_amount, nvl(deprn_reserve,0) deprn_reserve
   	    	FROM fa_deprn_detail
   	    	WHERE book_type_code = p_book_type_code
   	    	AND   period_counter = p_period_counter
   	    	AND   asset_id = p_asset_id
   	    	AND   distribution_id = cp_distribution_id;

   	    /* Cursor to get fully reserved, fully retired info for the asset from FA */
   	    CURSOR c_fa_books(p_asset_id fa_books.asset_id%TYPE) IS
   	        SELECT period_counter_fully_reserved, period_counter_fully_retired,
   	        	life_in_months, transaction_header_id_in, depreciate_flag,salvage_value,rate_adjustment_factor,cost
   	        FROM fa_books
   	        WHERE book_type_code = p_book_type_code
   	        AND   asset_id = p_asset_id
   	        AND   date_ineffective is NULL ;

	    /* Cursor to get previous life of asset */
	    CURSOR c_get_prev_asset_life(p_asset_id fa_books.asset_id%TYPE,
	    				p_transaction_id fa_books.transaction_header_id_in%TYPE) IS
   	        SELECT life_in_months
   	        FROM fa_books
   	        WHERE book_type_code = p_book_type_code
   	        AND   asset_id = p_asset_id
   	        AND   transaction_header_id_out = p_transaction_id
   	        AND   adjustment_required_status <> 'ADD';

	    /* Cursor to get the date of the transaction */
	    CURSOR c_get_transaction_info(p_transaction_id fa_books.transaction_header_id_in%TYPE) IS
	    	SELECT transaction_date_entered
	    	FROM fa_transaction_headers
	    	WHERE transaction_header_id = p_transaction_id;

   	    /* Cursor to get Current active transaction for asset from IAC */
   	    CURSOR c_get_prev_adjustment(p_asset_id igi_iac_transaction_headers.asset_id%TYPE) IS
   	        SELECT adjustment_id
   	        FROM igi_iac_transaction_headers
   	        WHERE asset_id = p_asset_id
   	        AND book_type_code = p_book_type_code
   	        AND adjustment_id_out is NULL ;

	    /* Cursor to get the latest period for the asset for which balances exist */
	    CURSOR c_get_max_period_counter(p_asset_id igi_iac_asset_balances.asset_id%TYPE) IS
	    	SELECT max(period_counter)
	    	FROM igi_iac_asset_balances
	    	WHERE asset_id = p_asset_id
	    	AND book_type_code = p_book_type_code
	    	AND period_counter <= p_period_counter;

   	    /* Cursor to get balance information for the Asset */
   	    CURSOR c_get_asset_balance (p_asset_id igi_iac_asset_balances.asset_id%TYPE,
                                                      p_period_counter  igi_iac_asset_balances.period_counter%TYPE ) IS
   	        SELECT *
   	        FROM igi_iac_asset_balances
   	        WHERE asset_id = p_asset_id
   	        AND book_type_code = p_book_type_code
   	        AND period_counter = p_period_counter ;

   	    /* Cursor to get total units assigned for the Asset from FA */
   	    CURSOR c_get_fa_asset(p_asset_id fa_additions.asset_id%TYPE) IS
   	        SELECT asset_category_id,current_units
   	        FROM fa_additions
   	        WHERE asset_id = p_asset_id;

   	    /* Cursor to get balance information for each distribution of asset */
   	    CURSOR c_get_detail_balance(p_asset_id igi_iac_det_balances.asset_id%TYPE
   	    			      ,p_prev_adjustment_id igi_iac_det_balances.adjustment_id%TYPE) IS
   	        SELECT *
   	        FROM igi_iac_det_balances
   	        WHERE asset_id = p_asset_id
   	        AND book_type_code = p_book_type_code
   	        AND adjustment_id =  p_prev_adjustment_id ;

   	    /* Cursor to get number of units assigned for each distribution from FA */
   	    CURSOR c_get_distribution_units(p_distribution_id igi_iac_det_balances.distribution_id%TYPE) IS
   	        SELECT units_assigned
   	        FROM fa_distribution_history
   	        WHERE distribution_id = p_distribution_id ;

	    /* Bug 2434532 vgadde 28/06/2002 Start(1) */
	    CURSOR c_get_deprn_calendar IS
        	SELECT deprn_calendar
        	FROM fa_book_controls
        	WHERE book_type_code like p_book_type_code;

        CURSOR c_get_periods_in_year(p_calendar_type fa_calendar_types.calendar_type%TYPE) IS
        	SELECT number_per_fiscal_year
        	FROM fa_calendar_types
        	WHERE calendar_type = p_calendar_type;
            /* Bug 2434532 vgadde 28/06/2002 End(1) */

        CURSOR c_get_prev_year_inactive_dist(cp_asset_id igi_iac_det_balances.asset_id%TYPE
            					,cp_distribution_id igi_iac_det_balances.distribution_id%TYPE) IS
            SELECT 'X'
            FROM igi_iac_det_balances
            WHERE book_type_code = p_book_type_code
            AND asset_id = cp_asset_id
            AND distribution_id = cp_distribution_id
            AND period_counter = p_period_counter - 1
            AND nvl(active_flag,'Y') = 'N';

	    CURSOR c_get_iac_fa_deprn_dists(cp_asset_id igi_iac_fa_deprn.asset_id%TYPE
	    				  ,cp_adjustment_id igi_iac_fa_deprn.adjustment_id%TYPE) IS
            SELECT *
            FROM igi_iac_fa_deprn
            WHERE book_type_code = p_book_type_code
            AND asset_id = cp_asset_id
            AND adjustment_id = cp_adjustment_id;

        CURSOR c_get_prev_year_fa_inactive(cp_asset_id igi_iac_fa_deprn.asset_id%TYPE
            					,cp_distribution_id igi_iac_fa_deprn.distribution_id%TYPE) IS
            SELECT 'X'
            FROM igi_iac_fa_deprn
            WHERE book_type_code = p_book_type_code
            AND asset_id = cp_asset_id
            AND distribution_id = cp_distribution_id
            AND period_counter = p_period_counter - 1
            AND nvl(active_flag,'Y') = 'N';

        l_fully_reserved 	 fa_books.period_counter_fully_reserved%TYPE ;
        l_fully_retired  	 fa_books.period_counter_fully_retired%TYPE ;
        l_life_in_months	 fa_books.life_in_months%TYPE ;
        l_depreciate_flag    fa_books.depreciate_flag%TYPE;
        l_prev_life_months	 fa_books.life_in_months%TYPE ;
        l_asset_balance  	 igi_iac_asset_balances%ROWTYPE;
        l_asset_balance_next igi_iac_asset_balances%ROWTYPE;
        l_asset_balance_curr igi_iac_asset_balances%ROWTYPE;
        l_detail_balance	 igi_iac_det_balances%ROWTYPE;
        l_adjustment_id  	 igi_iac_adjustments.adjustment_id%TYPE;
        l_adjustment_id_out  igi_iac_adjustments.adjustment_id%TYPE;
        l_prev_adjustment_id igi_iac_adjustments.adjustment_id%TYPE;
        l_category_id    	 fa_additions.asset_category_id%TYPE;
        l_asset_units	     fa_additions.current_units%TYPE;
        l_distribution_units fa_distribution_history.units_assigned%TYPE;
        l_deprn_ytd 	     igi_iac_det_balances.deprn_ytd%TYPE ;
        l_deprn_amount	     igi_iac_asset_balances.deprn_amount%TYPE;
        l_deprn_adj_amount	 fa_deprn_detail.deprn_adjustment_amount%TYPE;
        l_reval_reserve  	 igi_iac_asset_balances.reval_reserve%TYPE;
        l_general_fund   	 igi_iac_asset_balances.general_fund%TYPE;
        l_reval_rsv_net  	 igi_iac_det_balances.reval_reserve_net%TYPE;
        l_reval_rsv_gen_fund igi_iac_det_balances.reval_reserve_gen_fund%TYPE;
        l_gen_fund_per   	 igi_iac_det_balances.general_fund_per%TYPE;
        l_gen_fund_acc   	 igi_iac_det_balances.general_fund_acc%TYPE;
        l_prd_rec		     igi_iac_types.prd_rec ;
        l_errbuf		     varchar2(2000) ;
        l_is_first_period 	 boolean ;
        l_amount		     number ;
        l_deprn_expense	     number ;
        l_rowid  		     varchar2(25) ;
        l_account_ccid	     number(15) ;
        l_reval_reserve_ccid number(15) ;
        l_set_of_books_id	 number(15) ;
        l_chart_of_accts_id	 number(15) ;
        l_currency_code	     varchar2(15) ;
        l_precision		     varchar2(1) ;
        l_dpis_period_counter igi_iac_asset_balances.period_counter%TYPE;
        l_deprn_calendar      fa_calendar_types.calendar_type%TYPE;
        l_periods_in_year     fa_calendar_types.number_per_fiscal_year%TYPE;
        l_total_periods       NUMBER;
        l_last_period_counter NUMBER;
        l_max_period_counter  NUMBER;
        l_fa_transaction_id   fa_books.transaction_header_id_in%TYPE;
        l_transaction_date	  fa_transaction_headers.transaction_date_entered%TYPE;
        l_Transaction_Type_Code	igi_iac_transaction_headers.transaction_type_code%TYPE;
        l_Transaction_Id      igi_iac_transaction_headers.transaction_header_id%TYPE;
        l_Mass_Reference_ID	  igi_iac_transaction_headers.mass_reference_id%TYPE;
        l_Adjustment_Status   igi_iac_transaction_headers.adjustment_status%TYPE;
        l_prev_year_inactive_dist varchar2(1);
        l_salvage_value            Number;
        l_salvage_value_correction Number;
        l_rate_adjustment_factor   Number;
        l_cost                     Number;
        l_remaining_units          Number;
        l_remaining_amount         Number;

	    l_path 		       VARCHAR2(100);
	    p_event_id         NUMBER(15);

        -- Bulk changes
        TYPE asset_id_tbl_type IS TABLE OF   FA_DEPRN_SUMMARY. ASSET_ID%TYPE
                                           INDEX BY BINARY_INTEGER;
        TYPE deprn_amount_tbl_type IS TABLE OF   FA_DEPRN_SUMMARY. DEPRN_AMOUNT%TYPE
                                           INDEX BY BINARY_INTEGER;
        l_fa_asset_id asset_id_tbl_type;
        l_fa_deprn_amount deprn_amount_tbl_type;
        l_loop_count                 number;
        -- Bulk changes

        FUNCTION is_asset_revalued_once(p_asset_id igi_iac_asset_balances.asset_id%TYPE )
                RETURN boolean IS
	    /* This function returns True if asset is revalued atleast once in IAC else returns False */
            CURSOR c_asset_reval_info IS
                SELECT count(*) from igi_iac_asset_balances
                WHERE asset_id = p_asset_id
                AND   book_type_code = p_book_type_code ;

            l_reval_count number;
        BEGIN
            OPEN c_asset_reval_info;
            FETCH c_asset_reval_info INTO l_reval_count;
            CLOSE c_asset_reval_info;

            IF (l_reval_count > 0) THEN
                RETURN true;
            ELSE
                RETURN false;
            END IF;
        END is_asset_revalued_once;

    BEGIN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Start of Depreciation Processing');

        l_Transaction_Type_Code	:= NULL;
        l_Transaction_Id      := NULL;
        l_Mass_Reference_ID	  := NULL;
        l_Adjustment_Status   := NULL;
	    l_path 		:= g_path||'Periodic_Reval_of_Deprn';

        /* Get GL set_of_books_id for the IAC book */
        IF NOT (igi_iac_common_utils.get_book_gl_info(p_book_type_code ,
			    				  l_set_of_books_id ,
			    				  l_chart_of_accts_id ,
			    				  l_currency_code ,
			    				  l_precision )) THEN

            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'***Error in get_book_gl_info');
            RETURN false;
        END IF;

        /* Get period information from FA for the current period */
        IF NOT (igi_iac_common_utils.Get_Period_Info_for_Counter(p_book_type_code,
	    							     p_period_counter,
	    							     l_prd_rec )) THEN

            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'***Error in get_period_info_for_counter for current open period');
            RETURN false;
        END IF;

        IF NOT igi_iac_common_utils.populate_iac_fa_deprn_data(p_book_type_code,
	    							  'DEPRECIATION') THEN
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'*** Error in Synchronizing Depreciation Data ***');
            return FALSE;
        END IF;

        --FOR l_fa_deprn_record IN c_fa_deprn_records LOOP
        OPEN c_fa_deprn_records;
        FETCH c_fa_deprn_records BULK COLLECT INTO
                                       l_fa_asset_id,   l_fa_deprn_amount;
        CLOSE c_fa_deprn_records;

        FOR l_loop_count IN 1.. l_fa_asset_id.count
        LOOP

            OPEN c_fa_books(l_fa_asset_id(l_loop_count));
            FETCH c_fa_books into l_fully_reserved,
                                    l_fully_retired,
                                    l_life_in_months,
                                    l_fa_transaction_id,
                                    l_depreciate_flag,
                                    l_salvage_value,
                                    l_rate_adjustment_factor,
                                    l_cost;
            CLOSE c_fa_books;
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Asset_id :'||to_char(l_fa_asset_id(l_loop_count)));
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	    FA Transaction id :'||to_char(l_fa_transaction_id));

            l_transaction_date := NULL;
            OPEN c_get_transaction_info(l_fa_transaction_id);
            FETCH c_get_transaction_info INTO l_transaction_date;
            CLOSE c_get_transaction_info;
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	    FA Adjustment Transaction Date :'||to_char(l_transaction_date));

            l_prev_life_months := NULL;
            IF (l_transaction_date IS NOT NULL) THEN
                IF (l_transaction_date >= l_prd_rec.period_start_date AND l_transaction_date <= l_prd_rec.period_end_date) THEN
                    OPEN c_get_prev_asset_life(l_fa_asset_id(l_loop_count),l_fa_transaction_id);
                    FETCH c_get_prev_asset_life INTO l_prev_life_months;
                    CLOSE c_get_prev_asset_life;

                    l_fully_reserved := NULL;
                END IF;
            END IF;
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	    Previous Life in months :'||to_char(l_prev_life_months));

            /* Bug 2434532 vgadde 28/06/2002 Start(2) */
            IF NOT igi_iac_common_utils.get_dpis_period_counter(p_book_type_code,
                                                            l_fa_asset_id(l_loop_count),
                                                            l_dpis_period_counter) THEN
                igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'*** Error in Fetching DPIS period counter');
                return FALSE;
            END IF;

            OPEN c_get_deprn_calendar;
            FETCH c_get_deprn_calendar INTO l_deprn_calendar;
            CLOSE c_get_deprn_calendar;

            OPEN c_get_periods_in_year(l_deprn_calendar);
            FETCH c_get_periods_in_year INTO l_periods_in_year;
            CLOSE c_get_periods_in_year;

            l_total_periods := ceil((l_life_in_months*l_periods_in_year)/12);
            l_last_period_counter := (l_dpis_period_counter + l_total_periods - 1);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'		Last Period Counter :'||to_char(l_last_period_counter));

            IF (l_last_period_counter = p_period_counter) THEN
                l_fully_reserved := NULL;
            END IF;
            /* Bug 2434532 vgadde 28/06/2002 End(2) */

            IF(( l_fully_reserved is NULL ) AND
                ( l_fully_retired  is NULL ) AND
                l_depreciate_flag = 'YES' AND
                is_asset_revalued_once(l_fa_asset_id(l_loop_count))) THEN

                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Asset getting processed by depreciation ');

                l_Transaction_Type_Code := NULL;
                l_Transaction_Id := NULL;
                l_Mass_Reference_ID := NULL;
                l_adjustment_id_out := NULL;
                l_prev_adjustment_id := NULL;
                l_Adjustment_Status := NULL;

                IF NOT igi_iac_common_utils.Get_Latest_Transaction (
                       		X_book_type_code    => p_book_type_code,
                       		X_asset_id          => l_fa_asset_id(l_loop_count),
                       		X_Transaction_Type_Code	=> l_Transaction_Type_Code,
                       		X_Transaction_Id	=> l_Transaction_Id,
                       		X_Mass_Reference_ID	=> l_Mass_Reference_ID,
                       		X_Adjustment_Id		=> l_adjustment_id_out,
                       		X_Prev_Adjustment_Id => l_prev_adjustment_id,
                       		X_Adjustment_Status	=> l_Adjustment_Status) THEN
                    igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'*** Error in fetching the latest transaction');
                    return FALSE;
                END IF;

                    /* Commented for bug 2450345 vgadde 31-Jul-2002 Start
                OPEN c_get_prev_adjustment(l_fa_deprn_record.asset_id);
                FETCH c_get_prev_adjustment INTO l_prev_adjustment_id;
                CLOSE c_get_prev_adjustment;
                    Commenting for bug 2450345 vgadde 31-Jul-2002 End */
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Previous actual adjustment id :'||to_char(l_prev_adjustment_id));
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Previous adjustment id :'||to_char(l_adjustment_id_out));

                OPEN c_get_fa_asset(l_fa_asset_id(l_loop_count));
                FETCH c_get_fa_asset INTO l_category_id,l_asset_units;
                CLOSE c_get_fa_asset;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Units assigned for the asset :'||to_char(l_asset_units));
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Inserting into igi_iac_transaction_headers');
                l_adjustment_id := NULL;
                l_rowid := NULL;

                -- Fetching the event_id from fa_deprn_summary as in case of depreciation
                -- fa is not supplying the event_id
                -- R12 uptake
                select event_id into p_event_id from fa_deprn_summary
                    where asset_id=l_fa_asset_id(l_loop_count)
                    and book_type_code=p_book_type_code
                    and period_counter=p_period_counter;

                igi_iac_trans_headers_pkg.insert_row(
                    X_rowid		 => l_rowid ,
                    X_adjustment_id	 => l_adjustment_id ,
                    X_transaction_header_id => NULL ,
                    X_adjustment_id_out	 => NULL ,
                    X_transaction_type_code => 'DEPRECIATION' ,
                    X_transaction_date_entered => sysdate ,
                    X_mass_refrence_id	 => NULL ,
                    X_transaction_sub_type	 => NULL ,
                    X_book_type_code	 => p_book_type_code ,
                    X_asset_id		 => l_fa_asset_id(l_loop_count) ,
                    X_category_id		 => l_category_id ,
                    X_adj_deprn_start_date	 => l_prd_rec.period_end_date ,
                    X_revaluation_type_flag => NULL,
                    X_adjustment_status	 => 'COMPLETE' ,
                    X_period_counter	 => p_period_counter,
                    X_event_id           => p_event_id ) ;

                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     New adjustment id :'||to_char(l_adjustment_id));

                OPEN c_get_max_period_counter(l_fa_asset_id(l_loop_count));
                FETCH c_get_max_period_counter INTO l_max_period_counter;
                CLOSE c_get_max_period_counter;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'	 Max asset balances period counter :'||to_char(l_max_period_counter));

                OPEN c_get_asset_balance(l_fa_asset_id(l_loop_count),l_max_period_counter);
                FETCH c_get_asset_balance INTO l_asset_balance;
                CLOSE c_get_asset_balance;

                OPEN c_get_deprn_amount(l_fa_asset_id(l_loop_count));
                FETCH c_get_deprn_amount INTO l_deprn_amount,l_deprn_adj_amount;
                CLOSE c_get_deprn_amount;

                /* Modified for adjustments sekhar Start*/
                /*IF ((nvl(l_prev_life_months,0)=0) OR (nvl(l_prev_life_months,0)=l_life_in_months)) THEN
		    	l_deprn_amount := l_deprn_amount - l_deprn_adj_amount;
                END IF;*/

                l_deprn_amount := l_deprn_amount - l_deprn_adj_amount;
                /* Modified for adjustments sekhar  end*/

                /* salvage value correction */
                If l_salvage_value <> 0 Then
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     FA Deprn amount for period before salvage correction:'||to_char(l_deprn_amount));
                    IF NOT igi_iac_salvage_pkg.correction(p_asset_id => l_fa_asset_id(l_loop_count),
                                                      P_book_type_code =>p_book_type_code,
                                                      P_value=>l_deprn_amount,
                                                      P_cost=>l_cost,
                                                      P_salvage_value=>l_salvage_value,
                                                      P_calling_program=>'DEPRECIATION') THEN
                        igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+Salavge Value Correction Failed : ');
                        return false;
                    END IF;
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     FA Deprn amount for period after salvage correction:'||to_char(l_deprn_amount));
                END IF;
	            /* salvage value correction */

                IF NOT (igi_iac_common_utils.iac_round(l_deprn_amount,p_book_type_code)) THEN
                    RETURN false;
                END IF;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     FA Deprn amount for period :'||to_char(l_deprn_amount));

                l_deprn_expense := (l_deprn_amount * l_asset_balance.cumulative_reval_factor) - l_deprn_amount;

                IF NOT (igi_iac_common_utils.iac_round(l_deprn_expense,p_book_type_code)) THEN
                    RETURN false;
                END IF;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Cumulative revaluation rate :'||to_char(l_asset_balance.cumulative_reval_factor));
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     IAC Deprn amount for period :'||to_char(l_deprn_expense));

                l_remaining_units := l_asset_units;
                l_remaining_amount := l_deprn_expense;

                FOR l_detail_balance IN c_get_detail_balance(l_fa_asset_id(l_loop_count),l_prev_adjustment_id) LOOP

                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Distribution Id :'||to_char(l_detail_balance.distribution_id));
                    IF ( l_prd_rec.period_num = 1) THEN
                        l_deprn_ytd := 0 ;
                        l_is_first_period := TRUE ;
                    ELSE
                        l_deprn_ytd := l_detail_balance.deprn_ytd ;
                        l_is_first_period := FALSE ;
                    END IF;

                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Current YTD for the distribution :'||to_char(l_deprn_ytd));
                    IF (nvl(l_detail_balance.active_flag,'Y') <> 'N') THEN

                        OPEN c_get_distribution_units(l_detail_balance.distribution_id);
                        FETCH c_get_distribution_units INTO l_distribution_units;
                        CLOSE c_get_distribution_units;
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Active distribution - Units :'||to_char(l_distribution_units));

                        l_remaining_units := l_remaining_units - l_distribution_units;
                        IF l_remaining_units = 0 THEN
                            l_amount := l_remaining_amount;
                        ELSE
                            l_amount := (l_distribution_units / l_asset_units) * l_deprn_expense;
                            IF NOT (igi_iac_common_utils.iac_round(l_amount,p_book_type_code)) THEN
                                RETURN false;
                            END IF;
                            l_remaining_amount := l_remaining_amount - l_amount;
                        END IF;
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Prorated amount for the distribution :'||to_char(l_amount));

                        IF (nvl(l_amount,0) <> 0) THEN
                        /* Create accounting entries for non zero values */
                            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Creating accounting entries in igi_iac_adjustments');
                            l_rowid := NULL;
                            l_account_ccid := NULL ;

                            IF NOT (igi_iac_common_utils.get_account_ccid(p_book_type_code ,
			    						  l_asset_balance.asset_id ,
			    						  l_detail_balance.distribution_id ,
			    						  'DEPRN_EXPENSE_ACCT' ,
			    						  l_account_ccid )) THEN

                                RETURN false;
                            END IF;
                            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Deprn Expense ccid :'||to_char(l_account_ccid));
                            igi_iac_adjustments_pkg.insert_row(
                                X_rowid			=> l_rowid ,
                                X_adjustment_id		=> l_adjustment_id ,
                                X_book_type_code	=> p_book_type_code ,
                                X_code_combination_id	=> l_account_ccid,
                                X_set_of_books_id	=> l_set_of_books_id ,
                                X_dr_cr_flag   		=> 'DR' ,
                                X_amount               	=> l_amount ,
                                X_adjustment_type      	=> 'EXPENSE' ,
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned        => l_distribution_units ,
                                X_asset_id		=> l_asset_balance.asset_id ,
                                X_distribution_id      	=> l_detail_balance.distribution_id ,
                                X_period_counter       	=> p_period_counter,
                                X_adjustment_offset_type => 'RESERVE',
                                X_report_ccid            => NULL,
                                x_mode                  => 'R',
                                X_event_id           => p_event_id ) ;

                            l_rowid := NULL;
                            l_account_ccid := NULL ;

                            IF NOT (igi_iac_common_utils.get_account_ccid(p_book_type_code ,
			    						  l_asset_balance.asset_id ,
			    						  l_detail_balance.distribution_id ,
			    						  'DEPRN_RESERVE_ACCT' ,
			    						  l_account_ccid )) THEN

                                RETURN false;
                            END IF;
                            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Deprn Reserve ccid :'||to_char(l_account_ccid));
                            igi_iac_adjustments_pkg.insert_row(
                                X_rowid			=> l_rowid ,
                                X_adjustment_id		=> l_adjustment_id ,
                                X_book_type_code	=> p_book_type_code ,
                                X_code_combination_id	=> l_account_ccid,
                                X_set_of_books_id	=> l_set_of_books_id ,
                                X_dr_cr_flag   		=> 'CR' ,
                                X_amount               	=> l_amount ,
                                X_adjustment_type      	=> 'RESERVE' ,
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned        => l_distribution_units ,
                                X_asset_id		=> l_asset_balance.asset_id ,
                                X_distribution_id      	=> l_detail_balance.distribution_id ,
                                X_period_counter       	=> p_period_counter,
                                X_adjustment_offset_type => 'EXPENSE',
                                X_report_ccid            => NULL,
                                x_mode                  => 'R',
                                X_event_id              => p_event_id ) ;

                            IF (l_asset_balance.adjusted_cost > 0) THEN

                                l_rowid := NULL;
                                l_account_ccid := NULL ;

                                IF NOT (igi_iac_common_utils.get_account_ccid(p_book_type_code ,
			    						  l_asset_balance.asset_id ,
			    						  l_detail_balance.distribution_id ,
			    						  'REVAL_RESERVE_ACCT' ,
			    						  l_account_ccid )) THEN

                                    RETURN false;
                                END IF;
                                l_reval_reserve_ccid := l_account_ccid;

                                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Reval reserve ccid :'||to_char(l_account_ccid));
                                igi_iac_adjustments_pkg.insert_row(
                                    X_rowid			=> l_rowid ,
                                    X_adjustment_id		=> l_adjustment_id ,
                                    X_book_type_code	=> p_book_type_code ,
                                    X_code_combination_id	=> l_account_ccid,
                                    X_set_of_books_id	=> l_set_of_books_id ,
                                    X_dr_cr_flag   		=> 'DR' ,
                                    X_amount               	=> l_amount ,
                                    X_adjustment_type      	=> 'REVAL RESERVE' ,
                                    X_transfer_to_gl_flag  	=> 'Y' ,
                                    X_units_assigned        => l_distribution_units ,
                                    X_asset_id		=> l_asset_balance.asset_id ,
                                    X_distribution_id      	=> l_detail_balance.distribution_id ,
                                    X_period_counter       	=> p_period_counter,
                                    X_adjustment_offset_type => 'GENERAL FUND',
                                    X_report_ccid            => NULL,
                                    x_mode                  => 'R',
                                    X_event_id              => p_event_id ) ;

                                l_rowid := NULL;
                                l_account_ccid := NULL ;

                                IF NOT (igi_iac_common_utils.get_account_ccid(p_book_type_code ,
			    						  l_asset_balance.asset_id ,
			    						  l_detail_balance.distribution_id ,
			    						  'GENERAL_FUND_ACCT' ,
			    						  l_account_ccid )) THEN

                                    RETURN false;
                                END IF;
                                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     General Fund ccid :'||to_char(l_account_ccid));
                                igi_iac_adjustments_pkg.insert_row(
                                    X_rowid			=> l_rowid ,
                                    X_adjustment_id		=> l_adjustment_id ,
                                    X_book_type_code	=> p_book_type_code ,
                                    X_code_combination_id	=> l_account_ccid,
                                    X_set_of_books_id	=> l_set_of_books_id ,
                                    X_dr_cr_flag   		=> 'CR' ,
                                    X_amount               	=> l_amount ,
                                    X_adjustment_type      	=> 'GENERAL FUND' ,
                                    X_transfer_to_gl_flag  	=> 'Y' ,
                                    X_units_assigned        => l_distribution_units ,
                                    X_asset_id		=> l_asset_balance.asset_id ,
                                    X_distribution_id      	=> l_detail_balance.distribution_id ,
                                    X_period_counter       	=> p_period_counter,
                                    X_adjustment_offset_type => 'REVAL RESERVE',
                                    X_report_ccid            => l_reval_reserve_ccid,
                                    x_mode                  => 'R',
                                    X_event_id              => p_event_id ) ;
                            END IF;
                        END IF; /* Creating accounting entries for non zero values */

                        l_rowid := null ;

                        IF (nvl(l_detail_balance.active_flag,'Y') <> 'N') THEN
                            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Inserting into igi_iac_det_balances');
            	    		/*  Bug 2407393 vgadde 07/06/2002 Start(1) */
                            IF (l_asset_balance.adjusted_cost > 0) THEN
                                l_reval_rsv_net := l_detail_balance.reval_reserve_net - l_amount;
                                l_reval_rsv_gen_fund := l_detail_balance.reval_reserve_gen_fund + l_amount;
                                l_gen_fund_acc := l_detail_balance.general_fund_acc + l_amount;
                                l_gen_fund_per := l_amount;
                            ELSE
                                l_reval_rsv_net := l_detail_balance.reval_reserve_net;
                                l_reval_rsv_gen_fund := l_detail_balance.reval_reserve_gen_fund;
                                l_gen_fund_acc := l_detail_balance.general_fund_acc;
                                l_gen_fund_per := 0;
                            END IF;
            	    		/*  Bug 2407393 vgadde 07/06/2002 Start(1) */

                            igi_iac_det_balances_pkg.insert_row(
                                X_rowid			 => l_rowid ,
                                X_adjustment_id		 => l_adjustment_id ,
                                X_asset_id		 => l_asset_balance.asset_id ,
                                X_distribution_id	 => l_detail_balance.distribution_id ,
                                X_book_type_code	 => p_book_type_code ,
                                X_period_counter	 => p_period_counter ,
                                X_adjustment_cost	 => l_detail_balance.adjustment_cost ,
                                X_net_book_value	 => l_detail_balance.net_book_value - l_amount ,
                                X_reval_reserve_cost	 => l_detail_balance.reval_reserve_cost ,
                                X_reval_reserve_backlog  => l_detail_balance.reval_reserve_backlog ,
                                X_reval_reserve_gen_fund => l_reval_rsv_gen_fund ,
                                X_reval_reserve_net	 => l_reval_rsv_net ,
                                X_operating_acct_cost	 => l_detail_balance.operating_acct_cost ,
                                X_operating_acct_backlog => l_detail_balance.operating_acct_backlog ,
                                X_operating_acct_net	 => l_detail_balance.operating_acct_net ,
                                X_operating_acct_ytd	 => l_detail_balance.operating_acct_ytd ,
                                X_deprn_period		 => l_amount ,
                                X_deprn_ytd		 => l_deprn_ytd + l_amount ,
                                X_deprn_reserve		 => l_detail_balance.deprn_reserve + l_amount ,
                                X_deprn_reserve_backlog	 => l_detail_balance.deprn_reserve_backlog ,
                                X_general_fund_per	 => l_gen_fund_per ,
                                X_general_fund_acc	 => l_gen_fund_acc ,
                                X_last_reval_date	 => l_detail_balance.last_reval_date ,
                                X_current_reval_factor	 => l_detail_balance.current_reval_factor ,
                                X_cumulative_reval_factor =>l_detail_balance.cumulative_reval_factor ,
                                X_active_flag		 => l_detail_balance.active_flag ) ;
                        END IF;

                    END IF;

                    IF ((nvl(l_detail_balance.active_flag,'Y') = 'N') AND (NOT l_is_first_period)) THEN
                        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Processing inactive distribution');
                        l_rowid := null;
                        igi_iac_det_balances_pkg.insert_row(
                            X_rowid			 => l_rowid ,
                            X_adjustment_id		 => l_adjustment_id ,
                            X_asset_id		 => l_asset_balance.asset_id ,
                            X_distribution_id	 => l_detail_balance.distribution_id ,
                            X_book_type_code	 => p_book_type_code ,
                            X_period_counter	 => p_period_counter ,
                            X_adjustment_cost	 => l_detail_balance.adjustment_cost ,
                            X_net_book_value	 => l_detail_balance.net_book_value ,
                            X_reval_reserve_cost	 => l_detail_balance.reval_reserve_cost ,
                            X_reval_reserve_backlog  => l_detail_balance.reval_reserve_backlog ,
                            X_reval_reserve_gen_fund => l_detail_balance.reval_reserve_gen_fund ,
                            X_reval_reserve_net	 => l_detail_balance.reval_reserve_net ,
                            X_operating_acct_cost	 => l_detail_balance.operating_acct_cost ,
                            X_operating_acct_backlog => l_detail_balance.operating_acct_backlog ,
                            X_operating_acct_net	 => l_detail_balance.operating_acct_net ,
                            X_operating_acct_ytd	 => l_detail_balance.operating_acct_ytd ,
                            X_deprn_period		 => l_detail_balance.deprn_period ,
                            X_deprn_ytd		 => l_detail_balance.deprn_ytd ,
                            X_deprn_reserve		 => l_detail_balance.deprn_reserve ,
                            X_deprn_reserve_backlog	 => l_detail_balance.deprn_reserve_backlog ,
                            X_general_fund_per	 => l_detail_balance.general_fund_per ,
                            X_general_fund_acc	 => l_detail_balance.general_fund_acc ,
                            X_last_reval_date	 => l_detail_balance.last_reval_date ,
                            X_current_reval_factor	 => l_detail_balance.current_reval_factor ,
                            X_cumulative_reval_factor =>l_detail_balance.cumulative_reval_factor ,
                            X_active_flag		 => l_detail_balance.active_flag ) ;

                    END IF;

                    IF ((nvl(l_detail_balance.active_flag,'Y') = 'N') AND (l_is_first_period)) THEN
                        l_prev_year_inactive_dist := NULL;
                        OPEN c_get_prev_year_inactive_dist(  l_asset_balance.asset_id
 			    					,l_detail_balance.distribution_id);
                        FETCH c_get_prev_year_inactive_dist INTO l_prev_year_inactive_dist;
                        CLOSE c_get_prev_year_inactive_dist;

                        IF l_prev_year_inactive_dist IS NULL THEN
                            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Processing inactive distribution in first period');
                            l_rowid := null;
                            igi_iac_det_balances_pkg.insert_row(
                                X_rowid			 => l_rowid ,
                                X_adjustment_id		 => l_adjustment_id ,
                                X_asset_id		 => l_asset_balance.asset_id ,
                                X_distribution_id	 => l_detail_balance.distribution_id ,
                                X_book_type_code	 => p_book_type_code ,
                                X_period_counter	 => p_period_counter ,
                                X_adjustment_cost	 => 0 ,
                                X_net_book_value	 => 0 ,
                                X_reval_reserve_cost	 => 0 ,
                                X_reval_reserve_backlog  => 0 ,
                                X_reval_reserve_gen_fund => 0 ,
                                X_reval_reserve_net	 => 0 ,
                                X_operating_acct_cost	 => 0 ,
                                X_operating_acct_backlog => 0 ,
                                X_operating_acct_net	 => 0 ,
                                X_operating_acct_ytd	 => 0 ,
                                X_deprn_period		 => 0 ,
                                X_deprn_ytd		 => 0 ,
                                X_deprn_reserve		 => 0 ,
                                X_deprn_reserve_backlog	 => 0 ,
                                X_general_fund_per	 => 0 ,
                                X_general_fund_acc	 => 0 ,
                                X_last_reval_date	 => l_detail_balance.last_reval_date ,
                                X_current_reval_factor	 => l_detail_balance.current_reval_factor ,
                                X_cumulative_reval_factor =>l_detail_balance.cumulative_reval_factor ,
                                X_active_flag		 => l_detail_balance.active_flag ) ;
                        END IF;
                    END IF;

                END LOOP;

                FOR l_iac_fa_deprn_dist IN c_get_iac_fa_deprn_dists(l_asset_balance.asset_id,
		    							     l_prev_adjustment_id) LOOP
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Distribution Id :'||to_char(l_iac_fa_deprn_dist.distribution_id));
                    IF ( l_prd_rec.period_num = 1) THEN
                        l_deprn_ytd := 0 ;
                        l_is_first_period := TRUE ;
                    ELSE
                        l_deprn_ytd := l_iac_fa_deprn_dist.deprn_ytd ;
                        l_is_first_period := FALSE ;
                    END IF;

                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Current YTD for the distribution :'||to_char(l_deprn_ytd));
                    IF (nvl(l_iac_fa_deprn_dist.active_flag,'Y') <> 'N') THEN

                        FOR l_fa_dist_amounts IN c_get_dist_deprn_amount(l_asset_balance.asset_id,l_iac_fa_deprn_dist.distribution_id) LOOP
                            l_rowid := NULL;
                            igi_iac_fa_deprn_pkg.insert_row(
                                x_rowid			=> l_rowid,
                                x_book_type_code	=> p_book_type_code,
                                x_asset_id		=> l_asset_balance.asset_id,
                                x_distribution_id	=> l_iac_fa_deprn_dist.distribution_id,
                                x_period_counter	=> p_period_counter,
                                x_adjustment_id		=> l_adjustment_id,
                                x_deprn_period		=> l_fa_dist_amounts.deprn_amount - l_fa_dist_amounts.deprn_adjustment_amount,
                                x_deprn_ytd		=> l_deprn_ytd +
							        (l_fa_dist_amounts.deprn_amount - l_fa_dist_amounts.deprn_adjustment_amount),
                                x_deprn_reserve		=> l_fa_dist_amounts.deprn_reserve,
                                x_active_flag		=> l_iac_fa_deprn_dist.active_flag,
                                x_mode			=> 'R');
                        END LOOP;

                    END IF;

                    IF ((nvl(l_iac_fa_deprn_dist.active_flag,'Y') = 'N') AND (NOT l_is_first_period)) THEN
                        l_rowid := NULL;
                        igi_iac_fa_deprn_pkg.insert_row(
                            x_rowid			=> l_rowid,
                            x_book_type_code	=> l_iac_fa_deprn_dist.book_type_code,
                            x_asset_id		=> l_iac_fa_deprn_dist.asset_id,
                            x_distribution_id	=> l_iac_fa_deprn_dist.distribution_id,
                            x_period_counter	=> p_period_counter,
                            x_adjustment_id		=> l_adjustment_id,
                            x_deprn_period		=> l_iac_fa_deprn_dist.deprn_period,
                            x_deprn_ytd		=> l_iac_fa_deprn_dist.deprn_ytd,
                            x_deprn_reserve		=> l_iac_fa_deprn_dist.deprn_reserve,
                            x_active_flag		=> l_iac_fa_deprn_dist.active_flag,
                            x_mode			=> 'R');

                    END IF;

                    IF ((nvl(l_iac_fa_deprn_dist.active_flag,'Y') = 'N') AND (l_is_first_period)) THEN
                        l_prev_year_inactive_dist := NULL;
                        OPEN c_get_prev_year_fa_inactive(  l_iac_fa_deprn_dist.asset_id
 			    					,l_iac_fa_deprn_dist.distribution_id);
                        FETCH c_get_prev_year_fa_inactive INTO l_prev_year_inactive_dist;
                        CLOSE c_get_prev_year_fa_inactive;

                        IF l_prev_year_inactive_dist IS NULL THEN
                            l_rowid := NULL;
                            igi_iac_fa_deprn_pkg.insert_row(
                                x_rowid			=> l_rowid,
                                x_book_type_code	=> l_iac_fa_deprn_dist.book_type_code,
                                x_asset_id		=> l_iac_fa_deprn_dist.asset_id,
                                x_distribution_id	=> l_iac_fa_deprn_dist.distribution_id,
                                x_period_counter	=> p_period_counter,
                                x_adjustment_id		=> l_adjustment_id,
                                x_deprn_period		=> 0,
                                x_deprn_ytd		=> 0,
                                x_deprn_reserve		=> 0,
                                x_active_flag		=> l_iac_fa_deprn_dist.active_flag,
                                x_mode			=> 'R');
                        END IF;
                    END IF;
                END LOOP;

                /*  Bug 2407393 vgadde 07/06/2002 Start(2) */
                IF (l_asset_balance.adjusted_cost > 0) THEN
                    l_reval_reserve := l_asset_balance.reval_reserve - l_deprn_expense;
                    l_general_fund := l_asset_balance.general_fund + l_deprn_expense;
                ELSE
                    l_reval_reserve := l_asset_balance.reval_reserve;
                    l_general_fund := l_asset_balance.general_fund;
                END IF;
                /*  Bug 2407393 vgadde 07/06/2002 End(2) */

                OPEN c_get_asset_balance(l_fa_asset_id(l_loop_count),p_period_counter );
                FETCH c_get_asset_balance INTO l_asset_balance_curr;
                IF c_get_asset_balance%FOUND THEN

                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Updating  asset balances for the current period');
                    igi_iac_asset_balances_pkg.update_row(
                        X_asset_id		=> l_asset_balance.asset_id ,
                        X_book_type_code	=> p_book_type_code ,
                        X_period_counter	=> p_period_counter ,
                        X_net_book_value	=> l_asset_balance.net_book_value - l_deprn_expense ,
                        X_adjusted_cost		=> l_asset_balance.adjusted_cost ,
                        X_operating_acct	=> l_asset_balance.operating_acct ,
                        X_reval_reserve		=> l_reval_reserve ,
                        X_deprn_amount		=> l_deprn_expense ,
                        X_deprn_reserve		=> l_asset_balance.deprn_reserve + l_deprn_expense ,
                        X_backlog_deprn_reserve => l_asset_balance.backlog_deprn_reserve ,
                        X_general_fund		=> l_general_fund ,
                        X_last_reval_date	=> l_asset_balance.last_reval_date ,
                        X_current_reval_factor	=> l_asset_balance.current_reval_factor ,
                        X_cumulative_reval_factor => l_asset_balance.cumulative_reval_factor ) ;
                ELSE
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    Inserting asset balances for the current period');
                    l_rowid := NULL;
                    igi_iac_asset_balances_pkg.insert_row(
                        X_rowid			=> l_rowid ,
                        X_asset_id		=> l_asset_balance.asset_id ,
                        X_book_type_code	=> p_book_type_code ,
                        X_period_counter	=> p_period_counter ,
                        X_net_book_value	=> l_asset_balance.net_book_value - l_deprn_expense ,
                        X_adjusted_cost		=> l_asset_balance.adjusted_cost ,
                        X_operating_acct	=> l_asset_balance.operating_acct ,
                        X_reval_reserve		=> l_reval_reserve ,
                        X_deprn_amount		=> l_deprn_expense ,
                        X_deprn_reserve		=> l_asset_balance.deprn_reserve + l_deprn_expense ,
                        X_backlog_deprn_reserve => l_asset_balance.backlog_deprn_reserve ,
                        X_general_fund		=> l_general_fund ,
                        X_last_reval_date	=> l_asset_balance.last_reval_date ,
                        X_current_reval_factor	=> l_asset_balance.current_reval_factor ,
                        X_cumulative_reval_factor => l_asset_balance.cumulative_reval_factor ) ;
                END IF;
    		    CLOSE c_get_asset_balance;

                OPEN c_get_asset_balance(l_fa_asset_id(l_loop_count),p_period_counter +1);
                FETCH c_get_asset_balance INTO l_asset_balance_next;
                IF c_get_asset_balance%FOUND THEN

                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Updating  asset balances for the next period');
                    igi_iac_asset_balances_pkg.update_row(
                        X_asset_id		=> l_asset_balance.asset_id ,
                        X_book_type_code	=> p_book_type_code ,
                        X_period_counter	=> p_period_counter + 1 ,
                        X_net_book_value	=> l_asset_balance.net_book_value - l_deprn_expense ,
                        X_adjusted_cost		=> l_asset_balance.adjusted_cost ,
                        X_operating_acct	=> l_asset_balance.operating_acct ,
                        X_reval_reserve		=> l_reval_reserve ,
                        X_deprn_amount		=> l_deprn_expense ,
                        X_deprn_reserve		=> l_asset_balance.deprn_reserve + l_deprn_expense ,
                        X_backlog_deprn_reserve => l_asset_balance.backlog_deprn_reserve ,
                        X_general_fund		=> l_general_fund ,
                        X_last_reval_date	=> l_asset_balance.last_reval_date ,
                        X_current_reval_factor	=> l_asset_balance.current_reval_factor ,
                        X_cumulative_reval_factor => l_asset_balance.cumulative_reval_factor ) ;
                ELSE
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Inserting  asset balances for the next period');
                    l_rowid := NULL;
                    igi_iac_asset_balances_pkg.insert_row(
                        X_rowid			=> l_rowid ,
                        X_asset_id		=> l_asset_balance.asset_id ,
                        X_book_type_code	=> p_book_type_code ,
                        X_period_counter	=> p_period_counter + 1 ,
                        X_net_book_value	=> l_asset_balance.net_book_value - l_deprn_expense ,
                        X_adjusted_cost		=> l_asset_balance.adjusted_cost ,
                        X_operating_acct	=> l_asset_balance.operating_acct ,
                        X_reval_reserve		=> l_reval_reserve ,
                        X_deprn_amount		=> l_deprn_expense ,
                        X_deprn_reserve		=> l_asset_balance.deprn_reserve + l_deprn_expense ,
                        X_backlog_deprn_reserve => l_asset_balance.backlog_deprn_reserve ,
                        X_general_fund		=> l_general_fund ,
                        X_last_reval_date	=> l_asset_balance.last_reval_date ,
                        X_current_reval_factor	=> l_asset_balance.current_reval_factor ,
                        X_cumulative_reval_factor => l_asset_balance.cumulative_reval_factor ) ;
                END IF;
                CLOSE c_get_asset_balance;

                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Making previous transaction inactive.');
                igi_iac_trans_headers_pkg.update_row(
                    X_prev_adjustment_id	=> l_adjustment_id_out ,
                    X_adjustment_id		=> l_adjustment_id ) ;

            END IF;
        END LOOP;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Successful completion of periodic_reval_of_deprn');
        RETURN true;

    EXCEPTION
        WHEN OTHERS THEN
            igi_iac_debug_pkg.debug_unexpected_msg(l_path);
            RETURN false;
    END Periodic_Reval_of_Deprn;

    FUNCTION Synchronize_Accounts(
        p_book_type_code    IN VARCHAR2,
        p_period_counter    IN NUMBER,
        p_calling_function  IN VARCHAR2
        ) return BOOLEAN IS

        CURSOR c_get_adjustments(c_adjustment_id number)  IS
        SELECT rowid,
            adjustment_id,
            book_type_code,
            code_combination_id,
            adjustment_type,
            asset_id,
            distribution_id,
            period_counter
        FROM igi_iac_adjustments
        WHERE book_type_code = p_book_type_code
        AND period_counter = p_period_counter
        AND adjustment_type IN ('COST','RESERVE','EXPENSE')
        AND adjustment_id = c_adjustment_id for update;

        CURSOR c_get_transaction IS
        SELECT adjustment_id,
                transaction_header_id,
                transaction_type_code
        FROM igi_iac_transaction_headers
        WHERE book_type_code = p_book_type_code
        AND period_counter = p_period_counter
        AND transaction_type_code in ('RECLASS','ADDITION','DEPRECIATION');

        CURSOR c_get_cost_reserve_ccid ( c_asset_id NUMBER,
                                        c_distribution_id NUMBER,
                                        c_adjustment_source_type_code VARCHAR2,
                                        c_adjustment_type   VARCHAR2,
                                        c_transaction_header_id NUMBER) IS
        SELECT code_combination_id
        FROM fa_adjustments
        WHERE book_type_code = p_book_type_code
        AND  asset_id = c_asset_id
        AND distribution_id = c_distribution_id
        AND period_counter_created = p_period_counter
        AND source_type_code = c_adjustment_source_type_code
        AND adjustment_type = c_adjustment_type;
        --AND transaction_header_id = nvl(c_transaction_header_id,transaction_header_id);

        CURSOR c_get_expense_ccid ( c_asset_id NUMBER,
                                    c_distribution_id NUMBER,
                                    c_transaction_header_id NUMBER) IS
        SELECT code_combination_id
        FROM fa_distribution_history
        WHERE book_type_code = p_book_type_code
        AND  asset_id = c_asset_id
        AND distribution_id = c_distribution_id
        AND transaction_header_id_in  = nvl(c_transaction_header_id,transaction_header_id_in);

        CURSOR c_get_accounts (c_distribution_id NUMBER) IS
        SELECT  nvl(ASSET_COST_ACCOUNT_CCID, -1),
                nvl(DEPRN_EXPENSE_ACCOUNT_CCID, -1),
                nvl(DEPRN_RESERVE_ACCOUNT_CCID, -1),
                bc.accounting_flex_structure
        FROM    FA_DISTRIBUTION_ACCOUNTS da,
                    FA_BOOK_CONTROLS bc
        WHERE  bc.book_type_code = p_book_type_code
        AND      da.book_type_code = bc.book_type_code
        AND      da.distribution_id = c_distribution_id;

        CURSOR c_get_account_ccid ( c_asset_id NUMBER,
                                        c_distribution_id NUMBER,
                                        c_adjustment_source_type_code VARCHAR2,
                                        c_adjustment_type   VARCHAR2,
                                        c_transaction_header_id NUMBER) IS
        SELECT code_combination_id
        FROM fa_adjustments
        WHERE book_type_code = p_book_type_code
        AND  asset_id = c_asset_id
        AND distribution_id = c_distribution_id
        AND adjustment_type = c_adjustment_type;

        l_account_ccid NUMBER;
        l_adjustment_type VARCHAR2(50);
        l_rowid rowid;
        l_cost_ccid NUMBER;
        l_expense_ccid NUMBER;
        l_reserve_ccid NUMBER;
        l_flex_num NUMBER;
        l_account_type VARCHAR2(100);
        l_result BOOLEAN;
        l_asset_cost_acct VARCHAR2(25);
		l_dep_exp_acct VARCHAR2(25);
		l_dep_res_acct VARCHAR2(25);
		l_asset_cost_account_ccid NUMBER;
		l_reserve_account_ccid NUMBER;
        l_default_ccid NUMBER;
        l_category_id NUMBER;
        l_path		 VARCHAR2(100);
        l_validation_date date;
	l_account_seg_val VARCHAR2(25);
	l_acct_ccid NUMBER;

        -- bulk fecthes
        TYPE rowed_type_tbl_type   IS TABLE OF ROWID  INDEX BY BINARY_INTEGER;
        TYPE adj_id_tbl_type IS TABLE OF  IGI_IAC_ADJUSTMENTS. ADJUSTMENT_ID%TYPE
                  INDEX BY BINARY_INTEGER;
        TYPE book_type_tbl_type IS TABLE OF   IGI_IAC_ADJUSTMENTS.BOOK_TYPE_CODE%TYPE
              INDEX BY BINARY_INTEGER;
        TYPE code_comb_tbl_type IS TABLE OF IGI_IAC_ADJUSTMENTS.CODE_COMBINATION_ID%TYPE
              INDEX BY BINARY_INTEGER;
        TYPE adjustment_type_tbl_type IS TABLE OF  IGI_IAC_ADJUSTMENTS. ADJUSTMENT_TYPE%TYPE
              INDEX BY BINARY_INTEGER;
        TYPE asset_id_tbl_type IS TABLE OF   IGI_IAC_ADJUSTMENTS.ASSET_ID%TYPE
              INDEX BY BINARY_INTEGER;
        TYPE dist_id_tbl_type IS TABLE OF IGI_IAC_ADJUSTMENTS.DISTRIBUTION_ID%TYPE
              INDEX BY BINARY_INTEGER;
        TYPE period_counter_tbl_type IS TABLE OF IGI_IAC_ADJUSTMENTS.PERIOD_COUNTER%TYPE
              INDEX BY BINARY_INTEGER;

        l_row_id rowed_type_tbl_type;
        l_adj_id adj_id_tbl_type;
        l_book_code book_type_tbl_type;
        l_code_comb_id code_comb_tbl_type;
        l_adj_type adjustment_type_tbl_type;
        l_asset_id asset_id_tbl_type;
        l_dist_id dist_id_tbl_type;
        l_period_ctr period_counter_tbl_type;
        l_loop_count                 number;
        -- Bug 4714606
        l_dist_ccid number;
        -- Bug 4714606

    BEGIN
        l_path	:= g_path||'Synchronize_Accounts';
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Start of processing for synchronize accounts ');
        FOR l_get_transaction IN c_get_transaction LOOP
            --get the  adjustments in the current period
            --FOR l_adjustment IN c_get_adjustments(l_get_transaction.adjustment_id) LOOP

            OPEN c_get_adjustments(l_get_transaction.adjustment_id);
            FETCH c_get_adjustments   BULK COLLECT INTO
                l_row_id,
                l_adj_id,
                l_book_code,
                l_code_comb_id,
                l_adj_type,
                l_asset_id,
                l_dist_id,
                l_period_ctr;
            CLOSE c_get_adjustments;

            FOR l_loop_count IN 1.. l_adj_id.count
            LOOP

                -- Bug 4714606
                l_dist_ccid := l_code_comb_id(l_loop_count);
                -- Bug 4714606
                l_rowid := l_row_id(l_loop_count);
                l_account_ccid := -1;

                -- fecth the required accounts form the fa_dsitribution accounts for the
                --expense,cost and reserve

                OPEN c_get_accounts(l_dist_id(l_loop_count));
                FETCH c_get_accounts INTO
                        l_cost_ccid,
                        l_expense_ccid,
                        l_reserve_ccid,
                        l_flex_num;
                IF (c_get_accounts%FOUND) THEN
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Success in  get account ccid  from distribution  accounts ');
                    IF (l_adj_type(l_loop_count) = 'COST') THEN
                        l_account_ccid := l_cost_ccid;
                    ELSIF (l_adj_type(l_loop_count) = 'RESERVE') THEN
                        l_account_ccid := l_reserve_ccid;
                    ELSIF (l_adj_type(l_loop_count) = 'EXPENSE') THEN
                         l_account_ccid := l_expense_ccid;
                    END IF;
                END IF;
                CLOSE c_get_accounts;
                --- get the account from the fa_adjustmemts and fa_distribution_history if not found im
                -- fa_distribution_accounts.

                IF (l_account_ccid = -1)  THEN
                    igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Could not get account ccid  from distribution  accounts  ');
/*                    IF (l_adj_type(l_loop_count) in ('COST','RESERVE'  ) ) THEN
                        OPEN c_get_cost_reserve_ccid(l_asset_id(l_loop_count),l_dist_id(l_loop_count),
                                                            l_get_transaction.transaction_type_code ,
                                                            l_adj_type(l_loop_count),
                                                            l_get_transaction.transaction_header_id);
                        FETCH c_get_cost_reserve_ccid into l_account_ccid;
                        IF c_get_cost_reserve_ccid%NOTFOUND THEN
                            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'     Failed to get  COST/RESERVE ccid  in synchronize accounts *****');
                        END IF;
                        CLOSE  c_get_cost_reserve_ccid;
                    ELSIF (l_adj_type(l_loop_count) ='EXPENSE' ) THEN
                        OPEN c_get_expense_ccid(l_asset_id(l_loop_count),l_dist_id(l_loop_count),
                                                            l_get_transaction.transaction_header_id);
                        FETCH c_get_expense_ccid into l_account_ccid;
                        IF c_get_expense_ccid%NOTFOUND THEN
                            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'     Failed to get  EXPENSE ccid  in synchronize accounts *****');
                        END IF;
                        CLOSE c_get_expense_ccid;
                    END IF;
*/


                    OPEN c_get_account_ccid(l_asset_id(l_loop_count),l_dist_id(l_loop_count),
                                                            l_get_transaction.transaction_type_code ,
                                                            l_adj_type(l_loop_count),
                                                            l_get_transaction.transaction_header_id);
                    FETCH c_get_account_ccid into l_account_ccid;
                    IF c_get_account_ccid%NOTFOUND THEN
                        igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Could not get  '||l_adj_type(l_loop_count)|| 'ccid  from  fa_adjustments');
                        l_account_ccid := -1;
                    END IF;
                    CLOSE  c_get_account_ccid;

                END IF;

                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'   asset_id' || l_asset_id(l_loop_count));
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'   distribution' ||  l_dist_id(l_loop_count));
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'   adjustment type ' ||l_adj_type(l_loop_count));
                -- get the account ccid for the adjustment
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'   account ccid ' || l_account_ccid);
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     fetched ccid '|| l_code_comb_id(l_loop_count));

                IF l_account_ccid = -1 THEN

                   -- IF the accounts are not found
		   -- generate them using FA workflow
		   -- get the category ID for the asset

		   SELECT a.category_id
		   INTO  l_category_id
		   FROM fa_asset_history a
                       ,fa_distribution_history d
                   WHERE d.distribution_id =   l_dist_id(l_loop_count)
                   AND a.asset_id = d.asset_id
                   AND d.date_effective >= a.date_effective
                   AND d.date_effective < nvl(a.date_ineffective,sysdate);

		   -- Get the default accounts and ccids for a distributions

		   SELECT asset_cost_acct, deprn_expense_acct, deprn_reserve_acct,
		          asset_cost_account_ccid, reserve_account_ccid
		   INTO l_asset_cost_acct, l_dep_exp_acct, l_dep_res_acct,
		        l_asset_cost_account_ccid ,l_reserve_account_ccid
 	  	   FROM fa_category_books
		   WHERE book_type_code = p_book_type_code
  		   AND category_id = l_category_id;

		   -- get the flex_num and default CCID

		   SELECT accounting_flex_structure, flexbuilder_defaults_ccid
		   into l_flex_num, l_default_ccid
    		   FROM fa_book_controls
                   WHERE book_type_code =  p_book_type_code ;

                   IF (l_adj_type(l_loop_count) = 'COST') THEN
                      -- get the COST
 		      l_account_type := 'ASSET_COST';
 		      l_account_seg_val := l_asset_cost_acct;
 		      l_acct_ccid := l_asset_cost_account_ccid;
                   ELSIF (l_adj_type(l_loop_count) ='RESERVE' ) THEN
                      --  get the reserve account
   		      l_account_type := 'DEPRN_RSV';
		      l_account_seg_val := l_dep_res_acct;
		      l_acct_ccid := l_reserve_account_ccid ;
                   ELSIF (l_adj_type(l_loop_count) ='EXPENSE' ) THEN
	  	      -- get the expense account
		      l_account_type :=	'DEPRN_EXP' ;
		      l_account_seg_val := l_dep_exp_acct;
		      l_acct_ccid := l_code_comb_id(l_loop_count);
                      -- Bug 4714606
                      OPEN c_get_expense_ccid(l_asset_id(l_loop_count),
                                       l_dist_id(l_loop_count),
                                       l_get_transaction.transaction_header_id);
                      FETCH c_get_expense_ccid into l_dist_ccid;
                      IF c_get_expense_ccid%NOTFOUND THEN
                            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'     Failed to get  EXPENSE ccid  in synchronize accounts *****');
		         l_dist_ccid := l_code_comb_id(l_loop_count);
                      END IF;
                      CLOSE c_get_expense_ccid;
                      -- Bug 4714606
                   END IF;

                   Select calendar_period_close_date
                   into l_validation_date
                   From fa_deprn_periods
                   where book_type_code = p_book_type_code
                   and period_counter = p_period_counter;

		   l_result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => l_account_type,
                                X_book_type_code    => p_book_type_code,
                                X_flex_num          => l_flex_num,
                -- Bug 4714606
                                X_dist_ccid         => l_dist_ccid,
                -- Bug 4714606
                                X_acct_segval       => l_account_seg_val,
                                X_default_ccid      => l_default_ccid,
                                X_account_ccid      => l_acct_ccid,
                                X_distribution_id   => l_dist_id(l_loop_count),
                                X_validation_date   => l_validation_date,
                                X_return_ccid       => l_account_ccid);
                END IF;


                IF l_account_ccid = -1 THEN
                   FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_ACCOUNT_NOT_FOUND');
                   FND_MESSAGE.SET_TOKEN('PROCESS','Depreciation',TRUE);
                   igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
                                    p_full_path => l_path,
                                    p_remove_from_stack => FALSE);
                   fnd_file.put_line(fnd_file.log, fnd_message.get);

                   return FALSE;
                END IF;
                IF l_account_ccid <>   (l_code_comb_id(l_loop_count))  THEN
                    -- Update the ccid for the adjustment
                    UPDATE igi_iac_adjustments
                    SET code_combination_id= l_account_ccid
                    WHERE rowid=l_rowid;

                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'       Updated the adjusment with correct ccid' );
                END IF;

            END LOOP;
        END LOOP;
        return TRUE;

    EXCEPTION
        WHEN others THEN
        igi_iac_debug_pkg.debug_unexpected_msg(l_path);
        return FALSE;
    END Synchronize_Accounts;


/*=========================================================================+
 | Function Name:                                                          |
 |    Do_Depreciation                                                	   |
 |                                                                         |
 | Description:                                                            |
 |    This is IAC Depreciation function. Called from 		 	   |
 |    fa_igi_ext_pkg.Do_Depreciation                			   |
 |                                                                         |
 +=========================================================================*/
    FUNCTION Do_Depreciation(
        p_book_type_code	in varchar2 ,
        p_period_counter	in number ,
        p_calling_function  in varchar2
    ) RETURN boolean IS
        l_path 	 VARCHAR2(100);
    BEGIN
        l_path 	 := g_path||'Do_Depreciation';
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'*****************************************************');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Start of IAC Depreciation Processing');
        IF NOT igi_iac_common_utils.is_iac_book(p_book_type_code) THEN
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     The book is not an IAC book');
            RETURN true;
        ELSE
            IF NOT Synchronize_Calendars(p_book_type_code) THEN
                RETURN false;
            END IF;

            /* Bug 2906034 vgadde 25/04/2003 Start(2) */
            /*IF NOT Process_non_Deprn_Assets(p_book_type_code, 'DEPRECIATION',p_event_id) THEN
            	return FALSE;
            END IF;*/
            /* in 11i we need this explicit call for non depreciating assets,
               but in R12 we no longer need this explicit call as we are calling do_prior_additions() */
            /* Bug 2906034 vgadde 25/04/2003 End(2) */

            /* Added for Adjustments processing  Sekhar */
            IF NOT igi_iac_adj_pkg.do_process_adjustments ( p_book_type_code,
                                                         p_period_counter,
                                                         'DEPRECIATION') THEN
                RETURN false;
            END IF;
            /* Added for Adjustments processing  Sekhar */

            IF NOT Periodic_Reval_of_Deprn( p_book_type_code, p_period_counter ) THEN
                RETURN false;
            END IF;

            IF NOT Synchronize_Accounts(
                            p_book_type_code   => p_book_type_code,
                            p_period_counter    => p_period_counter,
                            p_calling_function  =>  'ADDITION'
                            ) THEN
                RETURN false;
            END IF;

            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Successful completion of IAC Depreciation Processing');
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'******************************************************');
            RETURN true;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            igi_iac_debug_pkg.debug_unexpected_msg(l_path);
            RETURN false;
    END Do_Depreciation;
BEGIN
    --===========================FND_LOG.START=====================================

    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        := 'IGI.PLSQL.igiiaprb.IGI_IAC_DEPRN_PKG.';

    --===========================FND_LOG.END=======================================

END igi_iac_deprn_pkg; -- Package body

/
