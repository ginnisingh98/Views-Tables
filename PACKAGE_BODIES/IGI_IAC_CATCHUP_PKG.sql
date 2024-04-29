--------------------------------------------------------
--  DDL for Package Body IGI_IAC_CATCHUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_CATCHUP_PKG" AS
-- $Header: igiiactb.pls 120.22.12010000.2 2010/06/25 05:29:15 schakkin ship $

     g_debug BOOLEAN ;

    --===========================FND_LOG.START=====================================

    g_state_level NUMBER	    ;
    g_proc_level  NUMBER	    ;
    g_event_level NUMBER	    ;
    g_excep_level NUMBER	    ;
    g_error_level NUMBER	    ;
    g_unexp_level NUMBER	    ;
    g_path        VARCHAR2(100) ;

    --===========================FND_LOG.END=====================================

    PROCEDURE Debug_Period(p_period igi_iac_types.prd_rec) IS
  	l_path_name VARCHAR2(150) ;
    BEGIN
  	    l_path_name := g_path||'debug_period';

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

    procedure do_round ( p_amount in out NOCOPY number, p_book_type_code in varchar2) is
        l_amount number     := p_amount;
        l_amount_old number := p_amount;
        l_path varchar2(150) := g_path||'do_round';
    begin
       IF IGI_IAC_COMMON_UTILS.Iac_Round(X_Amount => l_amount, X_Book => p_book_type_code)
       THEN
          p_amount := l_amount;
       ELSE
          p_amount := round( l_amount, 2);
       END IF;
    exception when others then
      p_amount := l_amount_old;
      igi_iac_debug_pkg.debug_unexpected_msg(l_path);
      Raise;
    end;

    PROCEDURE Debug_Asset(p_asset igi_iac_types.iac_reval_input_asset) IS
  	l_path_name VARCHAR2(150);
    BEGIN
  	    l_path_name := g_path||'debug_asset';

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
    END Debug_Asset;

    FUNCTION get_FA_Deprn_Expense(
                    p_asset_id          IN NUMBER,
                    p_book_type_code    IN VARCHAR2,
                    p_period_counter    IN NUMBER,
                    p_calling_function  IN VARCHAR2,
                    p_deprn_reserve     IN NUMBER,
                    p_deprn_YTD         IN NUMBER,
                    p_deprn_expense_py  OUT NOCOPY NUMBER,
                    p_deprn_expense_cy  OUT NOCOPY NUMBER,
                    p_last_asset_period OUT NOCOPY NUMBER
                    ) return BOOLEAN IS

        CURSOR c_get_fa_asset_info IS
        SELECT cost,
               salvage_value,
               date_placed_in_service,
               depreciate_flag,
               period_counter_fully_reserved,
               period_counter_fully_retired,
               transaction_header_id_in,
               life_in_months,
               add_months(date_placed_in_service,life_in_months) last_date
        FROM   fa_books
        WHERE  book_type_code = p_book_type_code
        AND    asset_id  = p_asset_id
        AND    transaction_header_id_out IS NULL;

	/* Bug 2961656 vgadde 08-jul-03 Start(1) */
        CURSOR c_get_user_deprn IS
        SELECT period_counter,deprn_reserve,YTD_deprn
        FROM fa_deprn_summary
        WHERE book_type_code = p_book_type_code
        AND asset_id = p_asset_id
        AND deprn_source_code = 'BOOKS';
	/* Bug 2961656 vgadde 08-jul-03 End(1) */

        /* Cursor for fetching latest deprn_reserve for RECLASS */
	CURSOR c_get_deprn_reserve IS
        SELECT period_counter, deprn_reserve
        FROM fa_deprn_summary
        WHERE book_type_code = p_book_type_code
        AND asset_id = p_asset_id
        AND period_counter = (SELECT max(period_counter)
                              FROM fa_deprn_summary
                              WHERE book_type_code = p_book_type_code
                              AND asset_id = p_asset_id);

        CURSOR c_get_deprn_calendar IS
        SELECT deprn_calendar
        FROM fa_book_controls
        WHERE book_type_code like p_book_type_code;

        CURSOR c_get_periods_in_year(p_calendar_type fa_calendar_types.calendar_type%TYPE) IS
        SELECT number_per_fiscal_year
        FROM fa_calendar_types
        WHERE calendar_type = p_calendar_type;

        l_fa_deprn_acc      fa_adjustments.adjustment_amount%TYPE;
        l_dpis_period       igi_iac_types.prd_rec;
        l_current_period    igi_iac_types.prd_rec;
        l_last_period        igi_iac_types.prd_rec;
        l_booksrow_period_rec igi_iac_types.prd_rec;
        l_deprn_calendar    fa_calendar_types.calendar_type%TYPE;
        l_periods_in_year   fa_calendar_types.number_per_fiscal_year%TYPE;
        l_booksrow_period   NUMBER;	-- added for bug 2961656
        l_booksrow_reserve  NUMBER;	-- added for bug 2961656
        l_deprn_reserve     NUMBER;
        l_reclass_period    fa_deprn_periods.period_counter%TYPE;
        l_total_periods     NUMBER;
        l_last_period_counter fa_deprn_periods.period_counter%TYPE;    -- added for bug 2411599
      	l_path_name VARCHAR2(150);
        l_booksrow_ytd_deprn  NUMBER;

    BEGIN
      	l_path_name := g_path||'get_fa_deprn_expense';
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Start of processing in get_FA_Deprn_Expense function');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     ---------Input Parameter Values---------');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Asset Id :'||to_char(p_asset_id));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Book Type Code :'||p_book_type_code);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Period Counter :'||to_char(p_period_counter));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Calling function :'||p_calling_function);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     ----------------------------------');

	/* Bug 2961656 vgadde 08-jul-03 Start(2) */
        IF (p_calling_function = 'UPGRADE') THEN

            OPEN c_get_deprn_calendar;
    	    FETCH c_get_deprn_calendar INTO l_deprn_calendar;
    	    CLOSE c_get_deprn_calendar;

    	    OPEN c_get_periods_in_year(l_deprn_calendar);
    	    FETCH c_get_periods_in_year INTO l_periods_in_year;
    	    CLOSE c_get_periods_in_year;
      	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Periods in Year for the calendar :'||to_char(l_periods_in_year));

            FOR l_asset_info IN c_get_fa_asset_info LOOP

                IF (l_asset_info.depreciate_flag = 'NO') THEN
          		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     Depreciate Flag is off. No depreciation required');
                    p_deprn_expense_py := 0;
                    p_deprn_expense_cy := 0;
                    p_last_asset_period := NULL;
                    return TRUE;
                END IF;

                IF NOT igi_iac_common_utils.get_period_info_for_date(p_book_type_code,
                                                                     l_asset_info.date_placed_in_service,
                                                                     l_dpis_period) THEN
          		    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '     Error in fetching dpis period information');
                    return FALSE;
                END IF;

                l_total_periods := ceil((l_asset_info.life_in_months*l_periods_in_year)/12);
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'l_total_periods =' || l_total_periods);
                l_last_period_counter := (l_dpis_period.period_counter + l_total_periods - 1);

                IF nvl(l_asset_info.period_counter_fully_reserved,l_last_period_counter) < l_last_period_counter THEN
                    l_last_period_counter := l_asset_info.period_counter_fully_reserved;
                END IF;

                IF l_last_period_counter > p_period_counter THEN
                    l_last_period_counter := NULL;
                END IF;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'l_last_period_counter =' || l_last_period_counter);

                IF NOT igi_iac_common_utils.get_period_info_for_counter(p_book_type_code,
                                                                     p_period_counter,
                                                                     l_current_period) THEN
          		    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		                                                 p_full_path => l_path_name,
                                                         p_string => '     Error in fetching open period information');
                    return FALSE;
                END IF;

                IF (l_last_period_counter IS NULL) THEN
  	            	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
    		                                                 p_full_path => l_path_name,
                                             	     		 p_string => '     Asset is not fully reserved.');
                    IF p_deprn_ytd IS NULL THEN
                        p_deprn_expense_py := p_deprn_reserve /  (p_period_counter - l_dpis_period.period_counter);
                        do_round(p_deprn_expense_py,p_book_type_code);
                        p_deprn_expense_cy := p_deprn_expense_py;
                        p_last_asset_period := NULL;
                    ELSE
                         p_last_asset_period := NULL;
                        p_deprn_expense_py := (p_deprn_reserve - p_deprn_ytd)/(p_period_counter - l_dpis_period.period_counter - l_current_period.period_num + 1);
                        do_round(p_deprn_expense_py,p_book_type_code);
                        p_deprn_expense_cy := p_deprn_ytd / (l_current_period.period_num - 1);
                        do_round(p_deprn_expense_cy,p_book_type_code);
                    END IF;
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'p_deprn_expense_py =' || p_deprn_expense_py);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'p_deprn_expense_cy =' || p_deprn_expense_cy);
                ELSE
          		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                          		p_full_path => l_path_name,
                                                		p_string => '     Asset is fully reserved');
                    IF NOT igi_iac_common_utils.get_period_info_for_counter(p_book_type_code,
                                                                         l_last_period_counter,
                                                                         l_last_period) THEN
                        return FALSE;
                    END IF;

                    IF p_deprn_ytd IS NULL THEN
                        p_deprn_expense_py := p_deprn_reserve / (l_last_period.period_counter - l_dpis_period.period_counter + 1);
                        do_round(p_deprn_expense_py,p_book_type_code);
                        p_deprn_expense_cy := p_deprn_expense_py;
                        p_last_asset_period := l_last_period_counter;
                    ELSE
                        IF l_last_period.fiscal_year = l_current_period.fiscal_year THEN
                            p_deprn_expense_py := (p_deprn_reserve - p_deprn_ytd)/(l_last_period_counter - l_dpis_period.period_counter - l_last_period.period_num + 1);
                            do_round(p_deprn_expense_py,p_book_type_code);
                            p_deprn_expense_cy := p_deprn_ytd / (l_last_period.period_counter);
                            do_round(p_deprn_expense_cy,p_book_type_code);
                            p_last_asset_period := l_last_period_counter;
                        ELSE
                            p_deprn_expense_py := p_deprn_reserve / (l_last_period_counter - l_dpis_period.period_counter + 1);
                            do_round(p_deprn_expense_py,p_book_type_code);
                            p_deprn_expense_cy := p_deprn_expense_py;
                            p_last_asset_period := l_last_period_counter;
                        END IF;
                        IF l_last_period.fiscal_year < l_current_period.fiscal_year THEN
                            p_deprn_expense_cy := 0;
                        END IF;
                    END IF;
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'p_deprn_expense_py =' || p_deprn_expense_py);
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'p_deprn_expense_cy =' || p_deprn_expense_cy);
                END IF;
            END LOOP;
        END IF;

	    IF ((p_calling_function = 'RECLASS') OR (p_calling_function = 'ADDITION') ) THEN

            OPEN c_get_user_deprn;
            FETCH c_get_user_deprn INTO l_booksrow_period, l_booksrow_reserve,l_booksrow_ytd_deprn;
            CLOSE c_get_user_deprn;

    	    OPEN c_get_deprn_calendar;
	        FETCH c_get_deprn_calendar INTO l_deprn_calendar;
	        CLOSE c_get_deprn_calendar;

    	    OPEN c_get_periods_in_year(l_deprn_calendar);
	        FETCH c_get_periods_in_year INTO l_periods_in_year;
	        CLOSE c_get_periods_in_year;
      	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	                                	     	p_full_path => l_path_name,
                                 		     	p_string => '     Periods in Year for the calendar :'||to_char(l_periods_in_year));

    	    FOR l_asset_info IN c_get_fa_asset_info LOOP

              		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                                 p_full_path => l_path_name,
                                                  		p_string => '         cost :'||to_char(l_asset_info.cost));
              		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                         		p_full_path => l_path_name,
                                    		     		p_string => '         salvage value :'||to_char(l_asset_info.salvage_value));
              		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                         		p_full_path => l_path_name,
                                    		     		p_string => '         date placed in service :'||to_char(l_asset_info.date_placed_in_service));
              		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                         		p_full_path => l_path_name,
                                    		     		p_string => '         depreciate flag :'||l_asset_info.depreciate_flag);
              		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                             		p_full_path => l_path_name,
                                        		     		p_string => '         period counter fully reserved :'||to_char(l_asset_info.period_counter_fully_reserved));
              		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                             		p_full_path => l_path_name,
                                        		     		p_string => '         transaction header id in :'||to_char(l_asset_info.transaction_header_id_in));
              		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                             		p_full_path => l_path_name,
                                        		     		p_string => '         life in months :'||to_char(l_asset_info.life_in_months));

                IF (l_asset_info.depreciate_flag = 'NO') THEN
                  		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	                                            	p_full_path => l_path_name,
                                            		     		p_string => '     Depreciate Flag is off. No depreciation calculation required');
                    p_deprn_expense_py := 0;
                    p_deprn_expense_cy := 0;
                    p_last_asset_period := NULL;
                    return TRUE;
               END IF;

                l_total_periods := ceil((l_asset_info.life_in_months*l_periods_in_year)/12);
              		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                         		p_full_path => l_path_name,
                                        	     		p_string => '     Total Periods in Asset life :'||to_char(l_total_periods));

            		/* Added for bug 2411599 vgadde 12/06/2002 Start(1)*/
            		/* Modified logic for getting last period in asset life */
                IF NOT igi_iac_common_utils.get_period_info_for_date(p_book_type_code,
                                                                     l_asset_info.date_placed_in_service,
                                                                     l_dpis_period) THEN
                    return FALSE;
                END IF;

                l_last_period_counter := (l_dpis_period.period_counter + l_total_periods - 1);
          		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                     		p_full_path => l_path_name,
                                		     		p_string => '     Last Period counter :'||to_char(l_last_period_counter));

                IF nvl(l_asset_info.period_counter_fully_reserved,l_last_period_counter) < l_last_period_counter THEN
                    l_last_period_counter := l_asset_info.period_counter_fully_reserved;
                END IF;

                IF (l_last_period_counter < p_period_counter) THEN
                    p_last_asset_period := l_last_period_counter;
                ELSE
                    p_last_asset_period := NULL;
                END IF;
        		/* Added for bug 2411599 vgadde 12/06/2002 End(1) */

                IF ((p_calling_function = 'ADDITION') AND (nvl(l_booksrow_reserve,0) <> 0) and p_last_asset_period IS NULL) THEN

              		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             		p_full_path => l_path_name,
        		     		p_string => '     Depreciation amount entered by user');

                        ------------- supplied YTD -----------------
                        IF Nvl(l_booksrow_ytd_deprn,0) <> 0 Then

                                 IF NOT igi_iac_common_utils.get_period_info_for_counter(p_book_type_code,
                                                                     p_period_counter-1,
                                                                     l_current_period) THEN
                                                   return FALSE;
                                 END IF;

                                    p_deprn_expense_py := (l_booksrow_reserve - l_booksrow_ytd_deprn)/(p_period_counter - l_dpis_period.period_counter - l_current_period.period_num );
                                    do_round(p_deprn_expense_py,p_book_type_code);
                                    p_deprn_expense_cy := l_booksrow_ytd_deprn/l_current_period.period_num;
                                    do_round(p_deprn_expense_cy,p_book_type_code);
                        Else
                                p_deprn_expense_py := l_booksrow_reserve/ (p_period_counter - l_dpis_period.period_counter);
                                do_round(p_deprn_expense_py,p_book_type_code);
                                p_deprn_expense_cy := p_deprn_expense_py;
                       END IF;
                       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'p_deprn_expense_py =' || p_deprn_expense_py);
                       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'p_deprn_expense_cy =' || p_deprn_expense_cy);

                ELSIF (p_calling_function = 'RECLASS') THEN
                         OPEN c_get_deprn_reserve;
                         FETCH c_get_deprn_reserve INTO l_reclass_period,l_deprn_reserve;
                         CLOSE c_get_deprn_reserve;

                          --Code added by Venkat Gadde
			  IF l_reclass_period <> l_booksrow_period THEN
                            IF l_last_period_counter is not null and l_last_period_counter < l_reclass_period Then
                              l_reclass_period := l_last_period_counter;
                            end if;
                            p_deprn_expense_py := l_deprn_reserve /(l_reclass_period - l_dpis_period.period_counter + 1);
                            do_round(p_deprn_expense_py,p_book_type_code);
                            p_deprn_expense_cy := p_deprn_expense_py;
                          ELSIF (nvl(l_booksrow_reserve,0) <> 0) THEN
                            p_deprn_expense_py := l_booksrow_reserve/ (p_period_counter - l_dpis_period.period_counter);
                            do_round(p_deprn_expense_py,p_book_type_code);
                            p_deprn_expense_cy := p_deprn_expense_py;
                          ELSE
                            p_deprn_expense_py := (l_asset_info.cost-l_asset_info.salvage_value)/l_total_periods;
                            do_round(p_deprn_expense_py,p_book_type_code);
                            p_deprn_expense_cy := p_deprn_expense_py;
                          END IF;

                          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             		p_full_path => l_path_name,
        		     		p_string => '     Calculated the deprn expense for '||l_reclass_period);
                          -- End of code added by Venkat Gadde
                    ELSE
                		    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             	                            	p_full_path => l_path_name,
                            		     	        	p_string => '     Depreciation amount calculated by FA');
                          p_deprn_expense_py := (l_asset_info.cost-l_asset_info.salvage_value)/l_total_periods;
                          do_round(p_deprn_expense_py,p_book_type_code);
                          p_deprn_expense_cy := p_deprn_expense_py;
              END IF;
              igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'p_deprn_expense_py =' || p_deprn_expense_py);
              igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'p_deprn_expense_cy =' || p_deprn_expense_cy);
            END LOOP;

        END IF;
	/* Bug 2961656 vgadde 08-jul-03 End(2) */
	do_round(p_deprn_expense_py,p_book_type_code);
	do_round(p_deprn_expense_cy,p_book_type_code);
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '-----Output from get_fa_deprn_expense function');
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     FA pys Depreciation Expense per period :'||to_char(p_deprn_expense_py));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     FA cys Depreciation Expense per period :'||to_char(p_deprn_expense_cy));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Last period for the asset :'||to_char(p_last_asset_period));
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '----------------------------------------------');
        return TRUE;

        EXCEPTION
            WHEN OTHERS THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                return FALSE;
    END get_FA_Deprn_Expense;

   FUNCTION Do_Deprn_Catchup(
                p_period_counter_from   IN  NUMBER,
                p_period_counter_to     IN  NUMBER,
                p_period_counter        IN  NUMBER,
                p_crud_iac_tables       IN  BOOLEAN,
                p_calling_function      IN  VARCHAR2,
                p_fa_deprn_expense_py   IN  NUMBER,
                p_fa_deprn_expense_cy   IN  NUMBER,
                p_asset_last_period     IN  NUMBER,
                p_fa_deprn_reserve      IN  NUMBER,
                p_fa_deprn_ytd          IN  NUMBER,
                p_asset_balance         IN OUT NOCOPY igi_iac_types.iac_reval_input_asset,
                p_event_id              IN  NUMBER    --R12 uptake
                ) return BOOLEAN IS

        l_deprn_catchup_amount      NUMBER;
        l_rowid                     VARCHAR2(25) ;
        l_adjustment_id             igi_iac_transaction_headers.adjustment_id%TYPE;
        l_transaction_sub_type      igi_iac_transaction_headers.transaction_sub_type%TYPE;
        l_distributions_tab         igi_iac_types.dist_amt_tab;
        l_fa_dist_catchup_tab	    igi_iac_types.dist_amt_tab;
        l_account_ccid	            NUMBER(15) ;
    	l_set_of_books_id           NUMBER(15) ;
    	l_chart_of_accts_id         NUMBER(15) ;
    	l_currency_code	            VARCHAR2(15) ;
    	l_precision                 VARCHAR2(1) ;
        l_idx                       NUMBER;
        l_detail_balance            igi_iac_det_balances%ROWTYPE;
        l_distribution_amount       NUMBER;
        l_dist_period_amount        NUMBER;
        l_last_catchup_prd_rec      igi_iac_types.prd_rec;
        l_last_reval_prd_rec        igi_iac_types.prd_rec;
        l_deprn_ytd                 NUMBER;
        l_reval_reserve_net         igi_iac_det_balances.reval_reserve_net%TYPE;
        l_reval_general_fund	    igi_iac_det_balances.reval_reserve_gen_fund%TYPE;
        l_general_fund_acc          igi_iac_det_balances.general_fund_acc%TYPE;
        l_fa_deprn_acc	    	    NUMBER;
        l_fa_deprn_catchup_amount   NUMBER;
        l_iac_fa_deprn_rec          igi_iac_fa_deprn%ROWTYPE;
        l_last_deprn_catchup_period NUMBER;
        l_periods_in_year           NUMBER;
        l_deprn_calendar            fa_calendar_types.calendar_type%TYPE;
        /* Bug 2961656 vgadde 08-jul-2003 Start(3) */
        l_iac_deprn_amount_py       NUMBER;
        l_iac_deprn_amount_cy       NUMBER;
        l_period_from               igi_iac_types.prd_rec;
        l_period_to                 igi_iac_types.prd_rec;
        l_period_open               igi_iac_types.prd_rec;
        l_period_reserved           igi_iac_types.prd_rec;
        /* Bug 2961656 vgadde 08-jul-2003 End(3) */
        l_path_name                 VARCHAR2(150);
        l_iac_deprn_period_amount   NUMBER;
        l_fa_deprn_period_amount    NUMBER;
        l_booksrow_period           NUMBER;
        l_booksrow_reserve          NUMBER;
        l_booksrow_YTD              NUMBER;
        l_reval_rsv_ccid            NUMBER;
        l_iac_active_dists_YTD      NUMBER;
        l_fa_active_dists_YTD       NUMBER;
        l_iac_inactive_dists_YTD    NUMBER;
        l_fa_inactive_dists_YTD     NUMBER;
        l_iac_all_dists_YTD         NUMBER;
        l_fa_all_dists_YTD          NUMBER;

        CURSOR c_get_transaction IS
        SELECT *
        FROM igi_iac_transaction_headers
        WHERE period_counter = p_period_counter
        AND book_type_code = p_asset_balance.book_type_code
        AND asset_id = p_asset_balance.asset_id
        AND transaction_type_code = p_calling_function
        AND transaction_sub_type = 'REVALUATION'
        AND adjustment_id_out is NULL;

        CURSOR c_get_detail_balances(p_adjustment_id NUMBER,p_distribution_id NUMBER) IS
        SELECT *
        FROM igi_iac_det_balances
        WHERE book_type_code = p_asset_balance.book_type_code
        AND asset_id = p_asset_balance.asset_id
        AND adjustment_id = p_adjustment_id
        AND distribution_id = p_distribution_id;

        CURSOR c_get_inactive_dists(p_adjustment_id NUMBER) IS
        SELECT *
        FROM igi_iac_det_balances
        WHERE adjustment_id = p_adjustment_id
        AND book_type_code = p_asset_balance.book_type_code
        AND asset_id = p_asset_balance.asset_id
        AND nvl(active_flag,'Y') = 'N';

        CURSOR c_get_upgrade_rec IS
        SELECT *
        FROM igi_imp_iac_interface_py_add
        WHERE book_type_code = p_asset_balance.book_type_code
        AND asset_id = p_asset_balance.asset_id
        AND period_counter = p_period_counter;

        CURSOR c_get_iac_fa_deprn_rec(cp_adjustment_id	igi_iac_fa_deprn.adjustment_id%TYPE
        			     ,cp_distribution_id igi_iac_fa_deprn.distribution_id%TYPE) IS
        SELECT *
        FROM igi_iac_fa_deprn
        WHERE book_type_code = p_asset_balance.book_type_code
        AND asset_id = p_asset_balance.asset_id
        AND adjustment_id = cp_adjustment_id
        AND distribution_id = cp_distribution_id;

        CURSOR c_get_iac_fa_inactive_dists(cp_adjustment_id igi_iac_fa_deprn.adjustment_id%TYPE) IS
        SELECT *
        FROM igi_iac_fa_deprn
        WHERE adjustment_id = cp_adjustment_id
        AND book_type_code = p_asset_balance.book_type_code
        AND asset_id = p_asset_balance.asset_id
        AND nvl(active_flag,'Y') = 'N';

        cursor c_asset_details_salvage is
        SELECT 	life_in_months,salvage_value,rate_adjustment_factor
 	    FROM fa_books
   	    WHERE book_type_code = p_asset_balance.book_type_code
   	    AND   asset_id = p_asset_balance.asset_id
   	    AND   date_ineffective is NULL ;

        l_asset_details_salvage c_asset_details_salvage%rowtype;
        l_salvage_value_correction number ;

        CURSOR c_get_deprn_calendar IS
        SELECT deprn_calendar
        FROM fa_book_controls
        WHERE book_type_code = p_asset_balance.book_type_code;

        CURSOR c_get_periods_in_year(p_calendar_type fa_calendar_types.calendar_type%TYPE) IS
        SELECT number_per_fiscal_year
        FROM fa_calendar_types
        WHERE calendar_type = p_calendar_type;

        CURSOR c_get_user_deprn IS
        SELECT period_counter,deprn_reserve,YTD_deprn
        FROM fa_deprn_summary
        WHERE book_type_code = p_asset_balance.book_type_code
        AND asset_id = p_asset_balance.asset_id
        AND deprn_source_code = 'BOOKS';


    BEGIN
        IF FND_PROFILE.VALUE('IGI_DEBUG_OPTION') = 'Y'  THEN
            g_debug := TRUE;
        END IF;
        l_path_name := g_path||'do_deprn_catchup';
        l_salvage_value_correction :=0;

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	                             p_full_path => l_path_name,
                                           	 p_string => '----------Start of processing by function Do_Deprn_Catchup....');
      	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	                             	     	 p_full_path => l_path_name,
                             		         p_string => '---- Input Parameters for the function ---------');
      	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	                            	         p_full_path => l_path_name,
		     	                             p_string => '     Period Counter From :'||to_char(p_period_counter_from));
      	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	                             	     	 p_full_path => l_path_name,
                                 	     	 p_string => '     Period Counter To :'||to_char(p_period_counter_to));
      	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	                                      	 p_full_path => l_path_name,
                             		     	 p_string => '     Current Open Period Counter :'||to_char(p_period_counter));
        If p_crud_iac_tables then
  	            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                             p_full_path => l_path_name,
                                     		     	 p_string => '     CRUD IAC tables is TRUE');
        Else
          	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                          	 p_full_path => l_path_name,
                                         	     	 p_string => '     CRUD IAC tables is FALSE');
        End If;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		  	                                 p_full_path => l_path_name,
                            		     	 p_string => '     Calling Function :'||p_calling_function);
    	Debug_Asset(p_asset_balance);
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                   	 p_full_path => l_path_name,
                                         	 p_string => '--------------------------------------------------');
        IF (p_period_counter_from >= p_period_counter_to) THEN
  	                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                            	p_full_path => l_path_name,
                                      		     		p_string => '     Returning from do_deprn_catchup as no catchup is required');
            return TRUE;
        END IF;

        /* Bug 2961656 vgadde 08-jul-2003 Start(4) */
        /*IF NOT get_FA_Deprn_Expense(p_asset_balance.asset_id,
                                 p_asset_balance.book_type_code,
                                 p_period_counter,
                                 p_calling_function,
                                 l_fa_deprn_amount,
                                 l_last_asset_period) THEN
                Debug('*** Error in get_FA_Deprn_Expense function');
                return FALSE;
        END IF;*/
        /* Bug 2961656 vgadde 08-jul-2003 End(4) */

        /* Bug 2961656 vgadde 08-jul-2003 Start(5) */
        IF (nvl(p_fa_deprn_expense_py,0) = 0 AND nvl(p_fa_deprn_expense_cy,0) = 0) THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Returning from do_deprn_catchup since no depreciation catchup is required');
            return TRUE;
        END IF;

        l_iac_deprn_amount_py := (p_fa_deprn_expense_py * p_asset_balance.cumulative_reval_factor)-p_fa_deprn_expense_py;
        do_round(l_iac_deprn_amount_py,p_asset_balance.book_type_code);
        l_iac_deprn_amount_cy := (p_fa_deprn_expense_cy * p_asset_balance.cumulative_reval_factor)-p_fa_deprn_expense_cy;
        do_round(l_iac_deprn_amount_cy,p_asset_balance.book_type_code);

      	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	                             p_full_path => l_path_name,
                             		     	 p_string => '     IAC pys Depreciation amount per period :'||to_char(l_iac_deprn_amount_py));
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                 	     	 p_full_path => l_path_name,
                                 	     	 p_string => '     IAC cys Depreciation amount per period :'||to_char(l_iac_deprn_amount_cy));
        Open  c_get_deprn_calendar;
        Fetch c_get_deprn_calendar into l_deprn_calendar;
        Close c_get_deprn_calendar;

        Open  c_get_periods_in_year(l_deprn_calendar);
        Fetch c_get_periods_in_year into l_periods_in_year;
        Close c_get_periods_in_year;

        IF (p_calling_function = 'ADDITION' OR p_calling_function = 'RECLASS') THEN

            -- Supplied  YTD
            OPEN c_get_user_deprn;
            FETCH c_get_user_deprn INTO l_booksrow_period, l_booksrow_reserve,l_booksrow_ytd;
            CLOSE c_get_user_deprn;

            IF  ((p_calling_function = 'ADDITION') AND (nvl(l_booksrow_YTD,0) <> 0) AND (p_asset_last_period IS NULL)) THEN

                IF NOT igi_iac_common_utils.get_period_info_for_counter(p_asset_balance.book_type_code,
                                                                        p_period_counter_from,l_period_from) THEN
                    return FALSE;
                END IF;

                IF NOT igi_iac_common_utils.get_period_info_for_counter(p_asset_balance.book_type_code,
                                                                 p_period_counter_to-1,l_period_to) THEN
                    return FALSE;
                END IF;

                IF NOT igi_iac_common_utils.get_period_info_for_counter(p_asset_balance.book_type_code,
                                                                 p_period_counter-1,
                                                                 l_period_open) THEN
                    return FALSE;
                END IF;
                -- get the deprn amt per period ---

                    IF (l_period_from.fiscal_year < l_period_open.fiscal_year) AND (l_period_to.fiscal_year < l_period_open.fiscal_year) THEN
                          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                 	     	 p_full_path => l_path_name,
                                 	     	 p_string => 'Depreciation catch up in previous years :');
                          l_deprn_catchup_amount := l_iac_deprn_amount_py * (p_period_counter_to - p_period_counter_from );
                          do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                          l_fa_deprn_catchup_amount := p_fa_deprn_expense_py * (p_period_counter_to - p_period_counter_from);
                          do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);

                    ELSIF (l_period_from.fiscal_year < l_period_open.fiscal_year) AND (l_period_to.fiscal_year = l_period_open.fiscal_year) THEN
                            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                 	     	 p_full_path => l_path_name,
                                 	     	 p_string => 'Depreciation catch up in previous year and current year :');


                        l_deprn_catchup_amount := (l_iac_deprn_amount_cy * l_period_to.period_num ) +
                            (l_iac_deprn_amount_py * (p_period_counter_to - p_period_counter_from - l_period_to.period_num ));
                        do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                        l_fa_deprn_catchup_amount := (p_fa_deprn_expense_cy * l_period_to.period_num ) +
                            (p_fa_deprn_expense_py * (p_period_counter_to - p_period_counter_from - l_period_to.period_num ));
                        do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);

                    ELSIF (l_period_from.fiscal_year = l_period_open.fiscal_year) AND (l_period_to.fiscal_year = l_period_open.fiscal_year) THEN
                           igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                 	     	 p_full_path => l_path_name,
                                 	     	 p_string => 'Depreciation catch up in current year :');

                          l_deprn_catchup_amount := l_iac_deprn_amount_cy *  (p_period_counter_to - p_period_counter_from );
                          do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                          l_fa_deprn_catchup_amount := p_fa_deprn_expense_cy * (p_period_counter_to - p_period_counter_from );
                          do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);
                    END IF;

            ELSE -- not supplied YTD

                IF (p_asset_last_period IS NULL) THEN
                    l_deprn_catchup_amount := l_iac_deprn_amount_py * ( p_period_counter_to - p_period_counter_from);
                    do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                    l_fa_deprn_catchup_amount := p_fa_deprn_expense_py * (p_period_counter_to - p_period_counter_from);
                    do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);
                ELSE
                    IF(p_asset_last_period < p_period_counter_from) THEN
                        return TRUE;
                    ELSIF (p_asset_last_period < p_period_counter_to) THEN
                        l_deprn_catchup_amount := l_iac_deprn_amount_py * (p_asset_last_period - p_period_counter_from + 1);
                        do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                        l_fa_deprn_catchup_amount := p_fa_deprn_expense_py * (p_asset_last_period - p_period_counter_from + 1);
                        do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);
                    ELSE
                        l_deprn_catchup_amount := l_iac_deprn_amount_py * ( p_period_counter_to - p_period_counter_from);
                        do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                        l_fa_deprn_catchup_amount := p_fa_deprn_expense_py * (p_period_counter_to - p_period_counter_from);
                        do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);
                    END IF;
                END IF;
            END IF;
        END IF; -- Addition and reclass

        IF (p_calling_function = 'UPGRADE') THEN
            IF NOT igi_iac_common_utils.get_period_info_for_counter(p_asset_balance.book_type_code,
                                                                 p_period_counter_from,
                                                                 l_period_from) THEN
                return FALSE;
            END IF;

            IF NOT igi_iac_common_utils.get_period_info_for_counter(p_asset_balance.book_type_code,
                                                                 p_period_counter_to-1,
                                                                 l_period_to) THEN
                return FALSE;
            END IF;
            IF NOT igi_iac_common_utils.get_period_info_for_counter(p_asset_balance.book_type_code,
                                                                 p_period_counter,
                                                                 l_period_open) THEN
                return FALSE;
            END IF;
            IF nvl(p_asset_last_period, l_period_to.period_counter) >= l_period_to.period_counter THEN
                IF l_period_to.fiscal_year < l_period_open.fiscal_year THEN
                    l_deprn_catchup_amount := l_iac_deprn_amount_py * (p_period_counter_to - p_period_counter_from);
                    do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                    l_fa_deprn_catchup_amount := p_fa_deprn_expense_py * (p_period_counter_to - p_period_counter_from);
                    do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);
                ELSE
                    IF l_period_from.fiscal_year < l_period_open.fiscal_year THEN
                        l_deprn_catchup_amount := (l_iac_deprn_amount_cy * l_period_to.period_num) +
                            (l_iac_deprn_amount_py * (p_period_counter_to - p_period_counter_from - l_period_to.period_num ));
                        do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                        l_fa_deprn_catchup_amount := (p_fa_deprn_expense_cy * l_period_to.period_num) +
                            (p_fa_deprn_expense_py * (p_period_counter_to - p_period_counter_from - l_period_to.period_num ));
                        do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);
                    ELSE
                        l_deprn_catchup_amount := l_iac_deprn_amount_cy * (p_period_counter_to - p_period_counter_from);
                        do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                        l_fa_deprn_catchup_amount := p_fa_deprn_expense_cy * (p_period_counter_to - p_period_counter_from);
                        do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);
                    END IF;
                END IF;
            ELSIF p_asset_last_period < p_period_counter_from THEN
                return TRUE;
            ELSE
                IF NOT igi_iac_common_utils.get_period_info_for_counter(p_asset_balance.book_type_code,
                                                                        p_asset_last_period,
                                                                        l_period_reserved) THEN
                    return FALSE;
                END IF;

                IF l_period_to.fiscal_year < l_period_open.fiscal_year THEN
                    l_deprn_catchup_amount := l_iac_deprn_amount_py * (p_asset_last_period - l_period_from.period_counter + 1);
                    do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                    l_fa_deprn_catchup_amount := p_fa_deprn_expense_py * (p_asset_last_period - l_period_from.period_counter + 1);
                    do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);
                ELSIF l_period_to.fiscal_year = l_period_open.fiscal_year THEN
                    IF l_period_from.fiscal_year < l_period_open.fiscal_year THEN
                        IF l_period_reserved.fiscal_year < l_period_open.fiscal_year THEN
                            l_deprn_catchup_amount := l_iac_deprn_amount_py * (p_asset_last_period - p_period_counter_from + 1);
                            do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                            l_fa_deprn_catchup_amount := p_fa_deprn_expense_py * (p_asset_last_period - p_period_counter_from + 1);
                            do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);
                        ELSIF l_period_reserved.fiscal_year = l_period_open.fiscal_year THEN
                            l_deprn_catchup_amount := (l_iac_deprn_amount_cy * l_period_reserved.period_num) +
                                (l_iac_deprn_amount_py * (l_period_reserved.period_counter - l_period_from.period_counter - l_period_reserved.period_num));
                            do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                            l_fa_deprn_catchup_amount := (p_fa_deprn_expense_cy * l_period_reserved.period_num) +
                                (p_fa_deprn_expense_py * (l_period_reserved.period_counter - l_period_from.period_counter - l_period_reserved.period_num));
                            do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);
                        END IF;
                    ELSIF l_period_from.fiscal_year = l_period_open.fiscal_year THEN
                        l_deprn_catchup_amount := l_iac_deprn_amount_cy * (p_asset_last_period - p_period_counter_from + 1);
                        do_round(l_deprn_catchup_amount,p_asset_balance.book_type_code);
                        l_fa_deprn_catchup_amount := p_fa_deprn_expense_cy * (p_asset_last_period - p_period_counter_from + 1);
                        do_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code);
                    END IF;
                END IF;
            END IF;

        END IF;
        /* Bug 2961656 vgadde 08-jul-2003 End(5) */

        IF NOT (igi_iac_common_utils.iac_round(l_deprn_catchup_amount,p_asset_balance.book_type_code)) THEN
            return FALSE;
        END IF;

         IF NOT (igi_iac_common_utils.iac_round(l_fa_deprn_catchup_amount,p_asset_balance.book_type_code)) THEN
            return FALSE;
        END IF;

        /* Bug 2961656 vgadde 08-jul-2003 Start(6) */
        IF NOT (igi_iac_common_utils.iac_round(l_iac_deprn_amount_py,p_asset_balance.book_type_code)) THEN
            return FALSE;
        END IF;

        IF NOT (igi_iac_common_utils.iac_round(l_iac_deprn_amount_cy,p_asset_balance.book_type_code)) THEN
            return FALSE;
        END IF;
        /* Bug 2961656 vgadde 08-jul-2003 End(6) */

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Total Depreciation catchup amount :'||to_char(l_deprn_catchup_amount));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '	    FA Depreciation catchup amount :'||to_char(l_fa_deprn_catchup_amount));

        p_asset_balance.deprn_amount := l_iac_deprn_amount_cy;
        p_asset_balance.net_book_value := nvl(p_asset_balance.net_book_value,0) - l_deprn_catchup_amount;
        p_asset_balance.deprn_reserve  := nvl(p_asset_balance.deprn_reserve,0) + l_deprn_catchup_amount;

        /* Bug 2423710 vgadde 19/06/2002 Start(1) */
        IF (p_asset_balance.adjusted_cost > 0) THEN
	        p_asset_balance.reval_reserve  := nvl(p_asset_balance.reval_reserve,0) - l_deprn_catchup_amount;
	        p_asset_balance.general_fund   := nvl(p_asset_balance.general_fund,0) + l_deprn_catchup_amount;
        END IF;
        /* Bug 2423710 vgadde 19/06/2002 End(1) */

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '------ Output Asset Record from do_deprn_catchup-----------');
        Debug_Asset(p_asset_balance);

        IF (p_crud_iac_tables) THEN

            IF (nvl(p_asset_last_period,p_period_counter) < (p_period_counter - 1)) THEN
                l_last_deprn_catchup_period := p_asset_last_period;
            ELSE
                l_last_deprn_catchup_period := p_period_counter - 1;
            END IF;

            IF NOT igi_iac_common_utils.get_period_info_for_counter(p_asset_balance.book_type_code,
                                                                        l_last_deprn_catchup_period,
                                                                        l_last_catchup_prd_rec) THEN
                   return FALSE;
            END IF;

            IF NOT igi_iac_common_utils.get_period_info_for_counter(p_asset_balance.book_type_code,
                                                                        p_period_counter_from-1,
                                                                        l_last_reval_prd_rec) THEN
                    return FALSE;
            END IF;

            IF (p_calling_function <> 'UPGRADE') THEN

                /* Accounting entries to be created */
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '     Inserting records into IAC tables');
                IF NOT (igi_iac_common_utils.get_book_gl_info(p_asset_balance.book_type_code ,
    		    				  l_set_of_books_id ,
			    				  l_chart_of_accts_id ,
			    				  l_currency_code ,
			    				  l_precision )) THEN
                    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                        p_full_path => l_path_name,
                        p_string => '*** Error in getting book GL info - do_deprn_catchup');
                    RETURN false;
                END IF;

                l_rowid := NULL;
                l_adjustment_id := NULL;

                FOR l_transaction IN c_get_transaction LOOP
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => '     Transaction ID created by revaluation :'||to_char(l_transaction.adjustment_id));
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => '     Inserting record into igi_iac_transaction_headers');
                    igi_iac_trans_headers_pkg.insert_row(
	                       	    X_rowid		            => l_rowid ,
                        		X_adjustment_id	        => l_adjustment_id ,
                        		X_transaction_header_id => NULL ,
                        		X_adjustment_id_out	    => NULL ,
                        		X_transaction_type_code => p_calling_function ,
                        		X_transaction_date_entered => sysdate ,
                        		X_mass_refrence_id	    => NULL ,
                        		X_transaction_sub_type	=> 'CATCHUP' ,
                        		X_book_type_code	    => l_transaction.book_type_code ,
                        		X_asset_id		        => l_transaction.asset_id ,
                        		X_category_id		    => l_transaction.category_id ,
                        		X_adj_deprn_start_date	=> l_transaction.adj_deprn_start_date ,
                        		X_revaluation_type_flag => NULL,
                        		X_adjustment_status	    => 'COMPLETE' ,
                        		X_period_counter	    => l_transaction.period_counter,
                                X_event_id              =>  p_event_id) ;

                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => '     New Adjustment Id for deprn catchup :'||to_char(l_adjustment_id));

                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => '	    Processing Inactive distributions');

                    l_iac_inactive_dists_YTD := 0;
                    l_fa_inactive_dists_YTD := 0;
                    l_iac_active_dists_YTD := 0;
                    l_fa_active_dists_YTD := 0;
                    l_iac_all_dists_YTD := 0;
                    l_fa_all_dists_YTD := 0;

                    FOR l_inactive_dist IN c_get_inactive_dists(l_transaction.adjustment_id) LOOP
                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                            p_full_path => l_path_name,
                            p_string => '	    Distribution Id :'||to_char(l_inactive_dist.distribution_id));

                        l_rowid := NULL;
                        igi_iac_det_balances_pkg.insert_row(
                            X_rowid                     => l_rowid ,
                            X_adjustment_id             => l_adjustment_id ,
                            X_asset_id                  => l_inactive_dist.asset_id ,
                            X_distribution_id           => l_inactive_dist.distribution_id ,
                            X_book_type_code            => l_inactive_dist.book_type_code ,
                            X_period_counter            => p_period_counter ,
                            X_adjustment_cost           => l_inactive_dist.adjustment_cost ,
                            X_net_book_value            => l_inactive_dist.net_book_value ,
                            X_reval_reserve_cost        => l_inactive_dist.reval_reserve_cost ,
                            X_reval_reserve_backlog     => l_inactive_dist.reval_reserve_backlog ,
                            X_reval_reserve_gen_fund    => l_inactive_dist.reval_reserve_gen_fund ,
                            X_reval_reserve_net         => l_inactive_dist.reval_reserve_net,
                            X_operating_acct_cost	    => l_inactive_dist.operating_acct_cost ,
                            X_operating_acct_backlog    => l_inactive_dist.operating_acct_backlog ,
                            X_operating_acct_net	    => l_inactive_dist.operating_acct_net ,
                            X_operating_acct_ytd	    => l_inactive_dist.operating_acct_ytd ,
                            X_deprn_period              => l_inactive_dist.deprn_period ,
                            X_deprn_ytd                 => l_inactive_dist.deprn_ytd ,
                            X_deprn_reserve             => l_inactive_dist.deprn_reserve ,
                            X_deprn_reserve_backlog	    => l_inactive_dist.deprn_reserve_backlog ,
                            X_general_fund_per          => l_inactive_dist.general_fund_per ,
                            X_general_fund_acc          => l_inactive_dist.general_fund_acc ,
                            X_last_reval_date           => l_inactive_dist.last_reval_date ,
                            X_current_reval_factor	    => l_inactive_dist.current_reval_factor ,
                            X_cumulative_reval_factor   => l_inactive_dist.cumulative_reval_factor ,
                            X_active_flag               => l_inactive_dist.active_flag ) ;

                            l_iac_inactive_dists_YTD := l_iac_inactive_dists_YTD + l_inactive_dist.deprn_ytd;
                    END LOOP; /* inactive distributions of igi_iac_det_balances */

                    FOR l_iac_fa_inactive_dist IN c_get_iac_fa_inactive_dists(l_transaction.adjustment_id) LOOP
                        l_rowid := NULL;
                        igi_iac_fa_deprn_pkg.insert_row(
                            x_rowid                     => l_rowid,
                            x_book_type_code            => l_iac_fa_inactive_dist.book_type_code,
                            x_asset_id                  => l_iac_fa_inactive_dist.asset_id,
                            x_distribution_id           => l_iac_fa_inactive_dist.distribution_id,
                            x_period_counter            => p_period_counter,
                            x_adjustment_id             => l_adjustment_id,
                            x_deprn_period              => l_iac_fa_inactive_dist.deprn_period,
                            x_deprn_ytd                 => l_iac_fa_inactive_dist.deprn_ytd ,
                            x_deprn_reserve             => l_iac_fa_inactive_dist.deprn_reserve ,
                            x_active_flag               => l_iac_fa_inactive_dist.active_flag,
                            x_mode                      => 'R');
                            l_fa_inactive_dists_YTD := l_fa_inactive_dists_YTD + l_iac_fa_inactive_dist.deprn_ytd;
                    END LOOP;

                    IF (l_last_catchup_prd_rec.period_num > l_last_reval_prd_rec.period_num) THEN
                        l_iac_all_dists_YTD := l_iac_deprn_amount_cy *
                                        (l_last_catchup_prd_rec.period_num - l_last_reval_prd_rec.period_num );
                        do_round(l_iac_all_dists_YTD,p_asset_balance.book_type_code);
                        l_fa_all_dists_YTD := p_fa_deprn_expense_cy *
                                        (l_last_catchup_prd_rec.period_num - l_last_reval_prd_rec.period_num );
                        do_round(l_fa_all_dists_YTD,p_asset_balance.book_type_code);

                        l_iac_active_dists_YTD := l_iac_all_dists_YTD ;
                        l_fa_active_dists_YTD := l_fa_all_dists_YTD ;
                    ELSE
                        l_iac_all_dists_YTD := l_iac_deprn_amount_cy * l_last_catchup_prd_rec.period_num;
                        do_round(l_iac_all_dists_YTD,p_asset_balance.book_type_code);
                        l_fa_all_dists_YTD := p_fa_deprn_expense_cy * l_last_catchup_prd_rec.period_num;
                        do_round(l_fa_all_dists_YTD,p_asset_balance.book_type_code);
                        l_iac_active_dists_YTD := l_iac_all_dists_YTD - l_iac_inactive_dists_YTD;
                        l_fa_active_dists_YTD := l_fa_all_dists_YTD - l_fa_inactive_dists_YTD;
                    END IF;


                    IF NOT igi_iac_common_utils.Prorate_Amt_to_Active_Dists( l_transaction.book_type_Code ,
                                                     l_transaction.Asset_id ,
                                                     l_deprn_catchup_amount ,
                                                     l_distributions_tab ) THEN
                        igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                            p_full_path => l_path_name,
                            p_string => '*** Error in prorating catchup amount to active distributions');
                        return FALSE;
                    END IF;

                    IF NOT igi_iac_common_utils.Prorate_Amt_to_Active_Dists( l_transaction.book_type_Code ,
                                                     l_transaction.Asset_id ,
                                                     l_fa_deprn_catchup_amount ,
                                                     l_fa_dist_catchup_tab ) THEN
                        igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                            p_full_path => l_path_name,
                            p_string => '*** Error in prorating period amount to active distributions');
                        return FALSE;
                    END IF;

                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => '     Total Number of Distributions For Asset:'||to_char(l_distributions_tab.LAST));
                    FOR l_idx IN l_distributions_tab.FIRST..l_distributions_tab.LAST LOOP
                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                            p_full_path => l_path_name,
                            p_string => '     Distribution id :'||to_char(l_distributions_tab(l_idx).distribution_id));
                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                            p_full_path => l_path_name,
                            p_string => '     Prorated Catchup Amount for the distribution :'||to_char(l_distributions_tab(l_idx).amount));
                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                            p_full_path => l_path_name,
                            p_string => '     Units for the distribution :'||to_char(l_distributions_tab(l_idx).units));
                        OPEN c_get_detail_balances(l_transaction.adjustment_id,
                                                l_distributions_tab(l_idx).distribution_id);
                        FETCH c_get_detail_balances INTO l_detail_balance;
                        CLOSE c_get_detail_balances;

                        l_distribution_amount := l_distributions_tab(l_idx).amount;
                        do_round(l_distribution_amount,p_asset_balance.book_type_code);
                        l_dist_period_amount := l_iac_deprn_amount_cy * l_distributions_tab(l_idx).prorate_factor;
                        do_round(l_dist_period_amount,p_asset_balance.book_type_code);

                        IF NOT igi_iac_common_utils.iac_round(l_distribution_amount,
                                                        l_transaction.book_type_code) THEN
                            return FALSE;
                        END IF;

                        IF NOT igi_iac_common_utils.iac_round(l_dist_period_amount,
                                                        l_transaction.book_type_code) THEN
                            return FALSE;
                        END IF;

                        IF (l_distribution_amount <> 0) THEN
            		    /* Do not create accounting entries if the amount is zero */

                            l_rowid := NULL;
                            l_account_ccid := NULL ;
                            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                p_full_path => l_path_name,
                                p_string => '     Inserting records into igi_iac_adjustments');
                            IF NOT (igi_iac_common_utils.get_account_ccid(l_transaction.book_type_code ,
			    						  l_transaction.asset_id ,
			    						  l_distributions_tab(l_idx).distribution_id ,
			    						  'DEPRN_EXPENSE_ACCT' ,
			    						  l_account_ccid )) THEN

                                RETURN false;
                            END IF;
                            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                p_full_path => l_path_name,
                                p_string => '     Deprn expense ccid :'||to_char(l_account_ccid));
                            igi_iac_adjustments_pkg.insert_row(
		     		    	    X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_adjustment_id ,
                                X_book_type_code		=> l_transaction.book_type_code ,
                                X_code_combination_id	=> l_account_ccid,
                                X_set_of_books_id		=> l_set_of_books_id ,
                                X_dr_cr_flag            => 'DR' ,
                                X_amount               	=> l_distribution_amount ,
                                X_adjustment_type      	=> 'EXPENSE' ,
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_distributions_tab(l_idx).units ,
                                X_asset_id		        => l_transaction.asset_id ,
                                X_distribution_id      	=> l_distributions_tab(l_idx).distribution_id ,
                                X_period_counter       	=> l_transaction.period_counter,
                                X_adjustment_offset_type => 'RESERVE' ,
                                X_report_ccid        	=> Null,
                                x_mode                  => 'R',
                                X_event_id              =>  p_event_id ) ;

                            l_rowid := NULL;
                            l_account_ccid := NULL ;
                            IF NOT (igi_iac_common_utils.get_account_ccid(l_transaction.book_type_code ,
			    						  l_transaction.asset_id ,
			    						  l_distributions_tab(l_idx).distribution_id ,
			    						  'DEPRN_RESERVE_ACCT' ,
			    						  l_account_ccid )) THEN

                                RETURN false;
                            END IF;
                            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                p_full_path => l_path_name,
                                p_string    => '     Deprn reserve ccid :'||to_char(l_account_ccid));
                            igi_iac_adjustments_pkg.insert_row(
                                X_rowid                 => l_rowid ,
                                X_adjustment_id         => l_adjustment_id ,
                                X_book_type_code		=> l_transaction.book_type_code ,
                                X_code_combination_id	=> l_account_ccid,
                                X_set_of_books_id		=> l_set_of_books_id ,
                                X_dr_cr_flag            => 'CR' ,
                                X_amount               	=> l_distribution_amount ,
                                X_adjustment_type      	=> 'RESERVE' ,
                                X_transfer_to_gl_flag  	=> 'Y' ,
                                X_units_assigned		=> l_distributions_tab(l_idx).units ,
                                X_asset_id		        => l_transaction.asset_id ,
                                X_distribution_id      	=> l_distributions_tab(l_idx).distribution_id ,
                                X_period_counter       	=> l_transaction.period_counter,
                                X_adjustment_offset_type => 'EXPENSE' ,
                                X_report_ccid        	=> Null,
                                x_mode                  => 'R',
                                X_event_id              =>  p_event_id ) ;

                            IF (p_asset_balance.adjusted_cost > 0) THEN

                                l_rowid := NULL;
                                l_account_ccid := NULL ;
                                l_reval_rsv_ccid := Null;

                                IF NOT (igi_iac_common_utils.get_account_ccid(l_transaction.book_type_code ,
			    						  l_transaction.asset_id ,
			    						  l_distributions_tab(l_idx).distribution_id ,
			    						  'REVAL_RESERVE_ACCT' ,
			    						  l_account_ccid )) THEN

                                    RETURN false;
                                END IF;
                                l_reval_rsv_ccid :=l_account_ccid;
                                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                    p_full_path => l_path_name,
                                    p_string => '     Reval reserve ccid :'||to_char(l_account_ccid));
                                igi_iac_adjustments_pkg.insert_row(
                                    X_rowid                 => l_rowid ,
                                    X_adjustment_id         => l_adjustment_id ,
                                    X_book_type_code        => l_transaction.book_type_code ,
                                    X_code_combination_id	=> l_account_ccid,
                                    X_set_of_books_id       => l_set_of_books_id ,
                                    X_dr_cr_flag            => 'DR' ,
                                    X_amount               	=> l_distribution_amount ,
                                    X_adjustment_type      	=> 'REVAL RESERVE' ,
                                    X_transfer_to_gl_flag  	=> 'Y' ,
                                    X_units_assigned        => l_distributions_tab(l_idx).units ,
                                    X_asset_id		        => l_transaction.asset_id ,
                                    X_distribution_id      	=> l_distributions_tab(l_idx).distribution_id ,
                                    X_period_counter       	=> l_transaction.period_counter,
                                    X_adjustment_offset_type => 'GENERAL FUND' ,
                                    X_report_ccid        	=> Null ,
                                    x_mode                  => 'R',
                                    X_event_id              =>  p_event_id ) ;

                                l_rowid := NULL;
                                l_account_ccid := NULL ;
                                IF NOT (igi_iac_common_utils.get_account_ccid(l_transaction.book_type_code ,
			    						  l_transaction.asset_id ,
			    						  l_distributions_tab(l_idx).distribution_id ,
			    						  'GENERAL_FUND_ACCT' ,
			    						  l_account_ccid )) THEN

                                    RETURN false;
                                END IF;
                                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                                    p_full_path => l_path_name,
                                    p_string => '     General Fund ccid :'||to_char(l_account_ccid));
                                igi_iac_adjustments_pkg.insert_row(
                                    X_rowid                 => l_rowid ,
                                    X_adjustment_id         => l_adjustment_id ,
                                    X_book_type_code		=> l_transaction.book_type_code ,
                                    X_code_combination_id	=> l_account_ccid,
                                    X_set_of_books_id       => l_set_of_books_id ,
                                    X_dr_cr_flag            => 'CR' ,
                                    X_amount               	=> l_distribution_amount ,
                                    X_adjustment_type      	=> 'GENERAL FUND' ,
                                    X_transfer_to_gl_flag  	=> 'Y' ,
                                    X_units_assigned		=> l_distributions_tab(l_idx).units ,
                                    X_asset_id		        => l_transaction.asset_id ,
                                    X_distribution_id      	=> l_distributions_tab(l_idx).distribution_id ,
                                    X_period_counter       	=> l_transaction.period_counter,
                                    X_adjustment_offset_type => 'REVAL RESERVE' ,
                                    X_report_ccid        	=> l_reval_rsv_ccid ,
                                    x_mode                  => 'R',
                                    X_event_id              =>  p_event_id ) ;

                            END IF; /* End of checking adjusted_cost > 0 */
                        END IF; /* End of distribution amount is not zero */

                        /* Bug 2423710 vgadde 19/06/2002 Start(2) */
                        IF (p_asset_balance.adjusted_cost > 0) THEN
                            l_reval_reserve_net := nvl(l_detail_balance.reval_reserve_net,0) - l_distribution_amount;
                            l_reval_general_fund := nvl(l_detail_balance.reval_reserve_gen_fund,0) + l_distribution_amount;
                            l_general_fund_acc := nvl(l_detail_balance.general_fund_acc,0) + l_distribution_amount;
                        ELSE
                            l_reval_reserve_net := nvl(l_detail_balance.reval_reserve_net,0) ;
                            l_reval_general_fund := nvl(l_detail_balance.reval_reserve_gen_fund,0) ;
                            l_general_fund_acc := nvl(l_detail_balance.general_fund_acc,0) ;
                        END IF;
                        /* Bug 2423710 vgadde 19/06/2002 End(2) */

                        IF (l_last_catchup_prd_rec.period_counter < p_period_counter - 1) THEN
                            l_iac_deprn_period_amount := 0;
                        ELSE
                            l_iac_deprn_period_amount := l_dist_period_amount;
                        END IF;

                        IF (l_last_catchup_prd_rec.period_num > l_last_reval_prd_rec.period_num) THEN
                            l_deprn_ytd := l_detail_balance.deprn_ytd + (l_iac_active_dists_YTD * l_distributions_tab(l_idx).prorate_factor);
                            do_round(l_deprn_ytd,p_asset_balance.book_type_code);
                        ELSE
                            l_deprn_ytd := (l_iac_active_dists_YTD * l_distributions_tab(l_idx).prorate_factor);
                            do_round(l_deprn_ytd,p_asset_balance.book_type_code);
                        END IF;

                        IF NOT igi_iac_common_utils.iac_round(l_deprn_ytd,
                                                        l_transaction.book_type_code) THEN
                            return FALSE;
                        END IF;

                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                            p_full_path => l_path_name,
                            p_string => '     Inserting into igi_iac_det_balances ');
                        l_rowid := NULL;
                        igi_iac_det_balances_pkg.insert_row(
                        		X_rowid                     => l_rowid ,
			     		    X_adjustment_id		    => l_adjustment_id ,
    					    X_asset_id		    => l_detail_balance.asset_id ,
	    				    X_distribution_id	    => l_detail_balance.distribution_id ,
		    			    X_book_type_code	    => l_detail_balance.book_type_code ,
			    		    X_period_counter	    => l_detail_balance.period_counter ,
				    	    X_adjustment_cost	    => l_detail_balance.adjustment_cost ,
                            X_net_book_value	    => l_detail_balance.net_book_value - l_distribution_amount ,
        				    X_reval_reserve_cost	    => l_detail_balance.reval_reserve_cost ,
		    			    X_reval_reserve_backlog     => l_detail_balance.reval_reserve_backlog ,
			    		    X_reval_reserve_gen_fund    => l_reval_general_fund ,
				    	    X_reval_reserve_net	    => l_reval_reserve_net,
                            X_operating_acct_cost	    => l_detail_balance.operating_acct_cost ,
    					    X_operating_acct_backlog    => l_detail_balance.operating_acct_backlog ,
	    				    X_operating_acct_net	    => l_detail_balance.operating_acct_net ,
 		    			    X_operating_acct_ytd	    => l_detail_balance.operating_acct_ytd ,
			    		    X_deprn_period		    => l_iac_deprn_period_amount ,
 				    	    X_deprn_ytd		    => l_deprn_ytd ,
                            X_deprn_reserve		    => l_detail_balance.deprn_reserve + l_distribution_amount ,
    					    X_deprn_reserve_backlog	    => l_detail_balance.deprn_reserve_backlog ,
	    				    X_general_fund_per	    => l_distribution_amount ,
		    			    X_general_fund_acc	    => l_general_fund_acc ,
 			    		    X_last_reval_date	    => l_detail_balance.last_reval_date ,
				    	    X_current_reval_factor	    => l_detail_balance.current_reval_factor ,
                            X_cumulative_reval_factor   =>l_detail_balance.cumulative_reval_factor ,
     					    X_active_flag		    => l_detail_balance.active_flag ) ;

                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                            p_full_path => l_path_name,
                            p_string => '     distribution YTD:'||to_char(l_deprn_ytd));

                    END LOOP; /* End of Processing each distribution */

                    IF (l_last_catchup_prd_rec.period_counter < p_period_counter - 1) THEN
                        l_iac_deprn_period_amount := 0;
                    ELSE
                        l_iac_deprn_period_amount := p_asset_balance.deprn_amount;
                    END IF;

                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => '     Updating asset balances record for the current period');
                    igi_iac_asset_balances_pkg.update_row(
		    			X_asset_id		=> p_asset_balance.asset_id ,
				    	X_book_type_code	=> p_asset_balance.book_type_code ,
    					X_period_counter	=> p_period_counter ,
	    				X_net_book_value	=> p_asset_balance.net_book_value ,
		    			X_adjusted_cost		=> p_asset_balance.adjusted_cost ,
			    		X_operating_acct	=> p_asset_balance.operating_acct ,
				    	X_reval_reserve		=> p_asset_balance.reval_reserve ,
                        X_deprn_amount		=> l_iac_deprn_period_amount ,
    					X_deprn_reserve		=> p_asset_balance.deprn_reserve ,
	    				X_backlog_deprn_reserve => p_asset_balance.backlog_deprn_reserve ,
		    			X_general_fund		=> p_asset_balance.general_fund ,
			    		X_last_reval_date	=> p_asset_balance.last_reval_date ,
				    	X_current_reval_factor	=> p_asset_balance.current_reval_factor ,
                        X_cumulative_reval_factor => p_asset_balance.cumulative_reval_factor ) ;

                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => '	    Updating asset balances record for the next period');
                    igi_iac_asset_balances_pkg.update_row(
		    			X_asset_id		=> p_asset_balance.asset_id ,
				    	X_book_type_code	=> p_asset_balance.book_type_code ,
    					X_period_counter	=> p_period_counter + 1 ,
	    				X_net_book_value	=> p_asset_balance.net_book_value ,
		    			X_adjusted_cost		=> p_asset_balance.adjusted_cost ,
			    		X_operating_acct	=> p_asset_balance.operating_acct ,
				    	X_reval_reserve		=> p_asset_balance.reval_reserve ,
                        X_deprn_amount		=> l_iac_deprn_period_amount ,
    					X_deprn_reserve		=> p_asset_balance.deprn_reserve ,
	    				X_backlog_deprn_reserve => p_asset_balance.backlog_deprn_reserve ,
		    			X_general_fund		=> p_asset_balance.general_fund ,
			    		X_last_reval_date	=> p_asset_balance.last_reval_date ,
				    	X_current_reval_factor	=> p_asset_balance.current_reval_factor ,
                        X_cumulative_reval_factor => p_asset_balance.cumulative_reval_factor ) ;


                    FOR l_idx IN l_fa_dist_catchup_tab.FIRST..l_fa_dist_catchup_tab.LAST LOOP

                        OPEN c_get_iac_fa_deprn_rec(l_transaction.adjustment_id, l_fa_dist_catchup_tab(l_idx).distribution_id);
                        FETCH c_get_iac_fa_deprn_rec INTO l_iac_fa_deprn_rec;
                        CLOSE c_get_iac_fa_deprn_rec;

                        IF (l_last_catchup_prd_rec.period_num > l_last_reval_prd_rec.period_num) THEN
                    		l_deprn_ytd := l_iac_fa_deprn_rec.deprn_ytd + (l_fa_active_dists_YTD * l_fa_dist_catchup_tab(l_idx).prorate_factor);
                        do_round(l_deprn_ytd,p_asset_balance.book_type_code);
                        ELSE
                    		l_deprn_ytd := (l_fa_active_dists_YTD * l_fa_dist_catchup_tab(l_idx).prorate_factor);
                        do_round(l_deprn_ytd,p_asset_balance.book_type_code);
                        END IF;

                        IF (l_last_catchup_prd_rec.period_counter < p_period_counter - 1) THEN
                    		l_fa_deprn_period_amount := 0;
                        ELSE
                    		l_fa_deprn_period_amount := p_fa_deprn_expense_cy * l_fa_dist_catchup_tab(l_idx).prorate_factor;
                        do_round(l_fa_deprn_period_amount,p_asset_balance.book_type_code);
                        END IF;

                        IF NOT igi_iac_common_utils.iac_round(l_fa_deprn_period_amount,
                                                        l_iac_fa_deprn_rec.book_type_code) THEN
                       		return FALSE;
                        END IF;

                        IF NOT igi_iac_common_utils.iac_round(l_deprn_ytd,
                                                        l_iac_fa_deprn_rec.book_type_code) THEN
                       		return FALSE;
                        END IF;

                        IF NOT igi_iac_common_utils.iac_round(l_fa_dist_catchup_tab(l_idx).amount,
                                                        l_iac_fa_deprn_rec.book_type_code) THEN
                       		return FALSE;
                        END IF;

                        l_rowid := NULL;
                        igi_iac_fa_deprn_pkg.insert_row(
                            x_rowid			=> l_rowid,
                            x_book_type_code	=> l_iac_fa_deprn_rec.book_type_code,
                            x_asset_id		=> l_iac_fa_deprn_rec.asset_id,
                            x_distribution_id	=> l_iac_fa_deprn_rec.distribution_id,
                            x_period_counter	=> p_period_counter,
                            x_adjustment_id		=> l_adjustment_id,
                            x_deprn_period		=> l_fa_deprn_period_amount,
                            x_deprn_ytd		=> l_deprn_ytd ,
                            x_deprn_reserve		=> l_iac_fa_deprn_rec.deprn_reserve + l_fa_dist_catchup_tab(l_idx).amount,
                            x_active_flag		=> l_iac_fa_deprn_rec.active_flag,
                            x_mode			=> 'R');
                        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                            p_full_path => l_path_name,
                            p_string => '     distribution FA YTD:'||to_char(l_deprn_ytd));

                    END LOOP; /* processing distributions for igi_iac_fa_deprn */


                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => '     Closing the previous transaction created by IAC revaluation');
                    igi_iac_trans_headers_pkg.update_row(
		    			X_prev_adjustment_id	=> l_transaction.adjustment_id ,
					    X_adjustment_id		    => l_adjustment_id ) ;

                END LOOP; /* End of Processing the transaction */
            ELSE /* calling function is UPGRADE */

                FOR l_upgrade_rec IN c_get_upgrade_rec LOOP
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => '     Processing for upgrade. Updating the record');

                    /* Bug 2961656 vgadde 08-Jul-2003 Start(7) */
            	    IF p_fa_deprn_ytd IS NOT NULL THEN
                        l_deprn_ytd := p_fa_deprn_ytd;
            	    ELSE
                        l_deprn_ytd := p_fa_deprn_expense_cy * l_last_catchup_prd_rec.period_num;
                        do_round(l_deprn_ytd,p_asset_balance.book_type_code);
            	    END IF;
                    l_fa_deprn_acc := p_fa_deprn_reserve;
                    /* Bug 2961656 vgadde 08-Jul-2003 End(7) */

                    IF (l_last_catchup_prd_rec.period_counter < p_period_counter - 1) THEN
                        l_iac_deprn_period_amount := 0;
                        l_fa_deprn_period_amount := 0;
                    ELSE
                        l_fa_deprn_period_amount := p_fa_deprn_expense_cy;
                        l_iac_deprn_period_amount := p_asset_balance.deprn_amount;
                    END IF;

                    UPDATE igi_imp_iac_interface_py_add
                    SET net_book_value  	= p_asset_balance.net_book_value,
                        adjusted_cost   	= p_asset_balance.adjusted_cost,
                        operating_acct  	= p_asset_balance.operating_acct,
                        reval_reserve   	= p_asset_balance.reval_reserve,
                        deprn_amount    	= l_iac_deprn_period_amount,
                        deprn_reserve   	= p_asset_balance.deprn_reserve,
                        backlog_deprn_reserve 	= p_asset_balance.backlog_deprn_reserve,
                        general_fund    	= p_asset_balance.general_fund,
                        hist_deprn_expense      = l_fa_deprn_period_amount,
                        hist_accum_deprn 	= l_fa_deprn_acc,
                        hist_ytd		= l_deprn_ytd,
                        hist_nbv		= l_upgrade_rec.hist_cost - l_fa_deprn_acc,
                        general_fund_periodic   = p_asset_balance.deprn_amount
                    WHERE   asset_id = l_upgrade_rec.asset_id
                    AND     book_type_code = l_upgrade_rec.book_type_code
                    AND     period_counter = l_upgrade_rec.period_counter;

                END LOOP;
            END IF; /* End of check for calling function */
        END IF; /* End of check for CRUD allowed */
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' End of Processing by Do_Deprn_Catchup');
        return TRUE;

        EXCEPTION
            WHEN OTHERS THEN
  		        igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                return FALSE;
    END Do_Deprn_Catchup;

    FUNCTION do_reval_init_struct(
                    p_period_counter        IN NUMBER,
                    p_reval_control         IN OUT NOCOPY igi_iac_types.iac_reval_control_tab,
                    p_reval_asset_params    IN OUT NOCOPY igi_iac_types.iac_reval_asset_params_tab,
                    p_reval_input_asset     IN OUT NOCOPY igi_iac_types.iac_reval_asset_tab,
                    p_reval_output_asset    IN OUT NOCOPY igi_iac_types.iac_reval_asset_tab,
                    p_reval_output_asset_mvmt IN OUT NOCOPY igi_iac_types.iac_reval_asset_tab,
                    p_reval_asset_rules     IN OUT NOCOPY igi_iac_types.iac_reval_asset_rules_tab,
                    p_prev_rate_info        IN OUT NOCOPY igi_iac_types.iac_reval_rates_tab,
                    p_curr_rate_info_first  IN OUT NOCOPY igi_iac_types.iac_reval_rates_tab,
                    p_curr_rate_info_next   IN OUT NOCOPY igi_iac_types.iac_reval_rates_tab,
                    p_curr_rate_info        IN OUT NOCOPY igi_iac_types.iac_reval_rates_tab,
                    p_reval_exceptions      IN OUT NOCOPY igi_iac_types.iac_reval_exceptions_tab,
                    p_fa_asset_info         IN OUT NOCOPY igi_iac_types.iac_reval_fa_asset_info_tab,
                    p_fa_deprn_expense_py   IN NUMBER,
                    p_fa_deprn_expense_cy   IN NUMBER,
                    p_asset_last_period     IN NUMBER,
                    p_calling_function      IN VARCHAR2
                    ) return BOOLEAN IS

        CURSOR c_fa_asset_info IS
        SELECT cost,
                adjusted_cost,
                original_cost,
                salvage_value,
                life_in_months,
                rate_adjustment_factor,
                period_counter_fully_reserved,
                adjusted_recoverable_cost,
                recoverable_cost,
                date_placed_in_service,
                0 deprn_periods_elapsed,
                0 deprn_periods_current_year,
                0 deprn_periods_prior_year,
                last_period_counter,
                gl_posting_allowed_flag,
                0 ytd_deprn,
                0 deprn_reserve,
                0 pys_deprn_reserve,
                0 deprn_amount,
                deprn_start_date,
                depreciate_flag
        FROM    fa_books b, fa_book_controls c
        WHERE   b.book_type_code = p_reval_asset_params(1).book_type_code
        AND     c.book_type_code = p_reval_asset_params(1).book_type_code
        AND     b.asset_id = p_reval_asset_params(1).asset_id
        AND     b.transaction_header_id_out IS NULL;


        CURSOR c_get_user_deprn IS
        SELECT period_counter,deprn_reserve,YTD_deprn
        FROM fa_deprn_summary
        WHERE book_type_code = p_reval_asset_params(1).book_type_code
        AND asset_id = p_reval_asset_params(1).asset_id
        AND deprn_source_code = 'BOOKS';


        l_user_id           NUMBER ;
        l_login_id          NUMBER ;
        l_prev_price_index  NUMBER;
        l_dpis_price_index  NUMBER;
        l_curr_price_index  NUMBER;
        l_curr_period       igi_iac_types.prd_rec;
        l_dpis_period       igi_iac_types.prd_rec;
	/* Bug 2961656 vgadde 08-jul-2003 Start(8) */
        l_open_period       igi_iac_types.prd_rec;
        l_last_catchup_period igi_iac_types.prd_rec;
        l_last_deprn_period igi_iac_types.prd_rec;
        l_fa_asset_info     igi_iac_types.fa_hist_asset_info;
        l_reval_factor      NUMBER;
        l_last_deprn_date   DATE;
	/* Bug 2961656 vgadde 08-jul-2003 End(8) */
        l_path_name VARCHAR2(150);
        l_booksrow_period_rec igi_iac_types.prd_rec;
        l_deprn_calendar    fa_calendar_types.calendar_type%TYPE;
        l_periods_in_year   fa_calendar_types.number_per_fiscal_year%TYPE;
        l_booksrow_period   NUMBER;
        l_booksrow_reserve  NUMBER;
        l_booksrow_YTD  NUMBER;
        l_fa_deprn_expense_py   NUMBER;
        l_fa_deprn_expense_cy   NUMBER;

    BEGIN
         IF FND_PROFILE.VALUE('IGI_DEBUG_OPTION') = 'Y'  THEN
                g_debug := TRUE;
         END IF;
        l_path_name := g_path||'do_reval_init_struct';
        l_user_id            := fnd_global.user_id;
        l_login_id           := fnd_global.login_id;

        	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                         p_full_path => l_path_name,
		                                         p_string => '-----------Start of processing by do_reval_init_struct');
        OPEN c_fa_asset_info;
        FETCH c_fa_asset_info INTO l_fa_asset_info;
        CLOSE c_fa_asset_info;

        IF NOT igi_iac_common_utils.get_period_info_for_date(
                                         p_reval_asset_params(1).book_type_code,
                                         l_fa_asset_info.date_placed_in_service,
                                         l_dpis_period) THEN
             return FALSE;
        END IF;
  	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                         p_full_path => l_path_name,
                                                 p_string => '    DPIS Period Info');
        	Debug_Period(l_dpis_period);

        IF NOT igi_iac_common_utils.get_price_index_value(
                                        p_reval_asset_params(1).book_type_code,
                                        p_reval_asset_params(1).asset_id,
                                        l_dpis_period.period_name,
                                        l_dpis_price_index) THEN
            return FALSE;
        END IF;
      	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	                                	     p_full_path => l_path_name,
                                		     p_string => '     Price Index for DPIS :'||to_char(l_dpis_price_index));
        l_prev_price_index := l_dpis_price_index;

	/* Bug 2961656 vgadde 08-jul-2003 Start(9) */
        /*IF NOT get_FA_Deprn_Expense(p_reval_asset_params(1).asset_id,
                                 p_reval_asset_params(1).book_type_code,
                                 p_period_counter,
                                 p_calling_function,
                                 l_fa_deprn_amount,
                                 l_last_asset_period) THEN
                return FALSE;
        END IF;*/
	/* Bug 2961656 vgadde 08-jul-2003 End(9) */

       ---Get the details for supplied depreciation and YTD --------
       IF (p_calling_function = 'ADDITION' OR p_calling_function = 'RECLASS') THEN

            OPEN c_get_user_deprn;
            FETCH c_get_user_deprn INTO l_booksrow_period, l_booksrow_reserve,l_booksrow_ytd;
            CLOSE c_get_user_deprn;

    	   /* OPEN c_get_deprn_calendar;
	        FETCH c_get_deprn_calendar INTO l_deprn_calendar;
	        CLOSE c_get_deprn_calendar;

    	    OPEN c_get_periods_in_year(l_deprn_calendar);
	        FETCH c_get_periods_in_year INTO l_periods_in_year;
	        CLOSE c_get_periods_in_year;*/

       END IF;
       ---Get the details for supplied depreciation and YTD --------


        FOR idx IN p_reval_control.FIRST..p_reval_control.LAST LOOP

            IF NOT (igi_iac_common_utils.get_period_info_for_counter(
                                        p_reval_asset_params(idx).book_type_code,
                                        p_reval_asset_params(idx).period_counter,
                                        l_curr_period)) THEN
                return FALSE;
            END IF;

            IF NOT (igi_iac_common_utils.get_price_index_value(
                                        p_reval_asset_params(idx).book_type_code,
                                        p_reval_asset_params(idx).asset_id,
                                        l_curr_period.period_name,
                                        l_curr_price_index)) THEN
                return FALSE;
            END IF;
  	             igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Price Index for current revaluation catchup period :'||to_char(l_curr_price_index));

            l_reval_factor := l_curr_price_index / l_prev_price_index ;
  	         igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Current Reval Factor : '||to_char(l_reval_factor));
            IF (idx = p_reval_control.FIRST) THEN
  		            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Initialization for First revaluation ');
                p_reval_control(idx).first_time_flag := TRUE;

  		                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Initializing reval input asset');
                p_reval_input_asset(idx).asset_id := p_reval_asset_params(idx).asset_id;
                p_reval_input_asset(idx).book_type_code := p_reval_asset_params(idx).book_type_code;
                p_reval_input_asset(idx).period_counter := p_reval_asset_params(idx).period_counter;
                p_reval_input_asset(idx).net_book_value := 0;
                p_reval_input_asset(idx).adjusted_cost := 0;
                p_reval_input_asset(idx).operating_acct := 0;
                p_reval_input_asset(idx).reval_reserve := 0;
                p_reval_input_asset(idx).deprn_amount := 0;
                p_reval_input_asset(idx).deprn_reserve := 0;
                p_reval_input_asset(idx).backlog_deprn_reserve := 0;
                p_reval_input_asset(idx).general_fund := 0;
                p_reval_input_asset(idx).last_reval_date := sysdate;
                p_reval_input_asset(idx).current_reval_factor := l_reval_factor;
                p_reval_input_asset(idx).cumulative_reval_factor := l_reval_factor;
                p_reval_input_asset(idx).created_by := l_user_id;
                p_reval_input_asset(idx).creation_date := sysdate;
                p_reval_input_asset(idx).last_update_login := l_login_id;
                p_reval_input_asset(idx).last_update_date := sysdate;
                p_reval_input_asset(idx).last_updated_by := l_user_id;

  	        	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Initializing previous rate info');
                p_prev_rate_info(idx).asset_id := p_reval_asset_params(idx).asset_id;
                p_prev_rate_info(idx).book_type_code := p_reval_asset_params(idx).book_type_code;
                p_prev_rate_info(idx).period_counter := p_reval_asset_params(idx).period_counter;
                p_prev_rate_info(idx).revaluation_id := 0;
                p_prev_rate_info(idx).current_reval_factor := 1;
                p_prev_rate_info(idx).cumulative_reval_factor := 1;
                p_prev_rate_info(idx).processed_flag := 'Y';
                p_prev_rate_info(idx).latest_record := 'Y';
                p_prev_rate_info(idx).created_by := l_user_id;
                p_prev_rate_info(idx).creation_date := sysdate;
                p_prev_rate_info(idx).last_update_login := l_login_id;
                p_prev_rate_info(idx).last_update_date := sysdate;
                p_prev_rate_info(idx).last_updated_by := l_user_id;
                p_prev_rate_info(idx).adjustment_id := 0;

                p_curr_rate_info(idx).cumulative_reval_factor := l_reval_factor;

            ELSE

                p_reval_control(idx).first_time_flag := FALSE;
                p_prev_rate_info(idx) := p_curr_rate_info(idx-1);
                p_curr_rate_info(idx).current_reval_factor := l_reval_factor;
                p_curr_rate_info(idx).cumulative_reval_factor :=
                                l_reval_factor * p_curr_rate_info(idx-1).cumulative_reval_factor;
                p_reval_input_asset(idx).current_reval_factor := l_reval_factor;
                p_reval_input_asset(idx).cumulative_reval_factor :=
                                p_curr_rate_info(idx).cumulative_reval_factor;
            END IF;

            IF (idx = p_reval_control.LAST) THEN
  		        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => '     Last revaluation - setting CRUD flags to TRUE');
                p_reval_control(idx).create_acctg_entries := TRUE;
                p_reval_control(idx).crud_allowed := TRUE;
                p_reval_control(idx).modify_balances := TRUE;
            ELSE
                p_reval_control(idx).create_acctg_entries := FALSE;
                p_reval_control(idx).crud_allowed := FALSE;
                p_reval_control(idx).modify_balances := FALSE;
            END IF;

  	             igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Initializing reval control structure');
            p_reval_control(idx).transaction_type_code := p_calling_function;
            p_reval_control(idx).transaction_sub_type := 'REVALUATION';
            p_reval_control(idx).adjustment_status := 'COMPLETE';
            p_reval_control(idx).validate_business_rules := FALSE;
            p_reval_control(idx).message_level := 3;
            p_reval_control(idx).commit_flag := FALSE;
            p_reval_control(idx).print_report := FALSE;
            p_reval_control(idx).mixed_scenario := FALSE;
            p_reval_control(idx).show_exceptions := FALSE;

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Initializing reval asset params');
            p_reval_asset_params(idx).revaluation_rate := l_reval_factor;
            p_reval_asset_params(idx).revaluation_date := sysdate;
            p_reval_asset_params(idx).first_set_adjustment_id := 0;
            p_reval_asset_params(idx).second_set_adjustment_id := 0;

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Initializing reval out NOCOPY put asset');
            p_reval_output_asset(idx) := p_reval_input_asset(idx);

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Initializing reval output asset mvmt ');
            p_reval_output_asset_mvmt(idx) := p_reval_input_asset(idx);
            p_reval_output_asset_mvmt(idx).net_book_value := 0;
            p_reval_output_asset_mvmt(idx).adjusted_cost := 0;
            p_reval_output_asset_mvmt(idx).operating_acct := 0;
            p_reval_output_asset_mvmt(idx).reval_reserve := 0;
            p_reval_output_asset_mvmt(idx).deprn_amount := 0;
            p_reval_output_asset_mvmt(idx).deprn_reserve := 0;
            p_reval_output_asset_mvmt(idx).backlog_deprn_reserve := 0;
            p_reval_output_asset_mvmt(idx).general_fund := 0;

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Initializing current rate info');
            p_curr_rate_info(idx).asset_id := p_reval_asset_params(idx).asset_id;
            p_curr_rate_info(idx).book_type_code := p_reval_asset_params(idx).book_type_code;
            p_curr_rate_info(idx).period_counter := p_reval_asset_params(idx).period_counter;
            p_curr_rate_info(idx).revaluation_id := 0;
            p_curr_rate_info(idx).reval_type := p_reval_asset_rules(idx).revaluation_type;
            p_curr_rate_info(idx).current_reval_factor := l_reval_factor;
            p_curr_rate_info(idx).processed_flag := 'Y';
            p_curr_rate_info(idx).latest_record := 'Y';
            p_curr_rate_info(idx).created_by := l_user_id;
            p_curr_rate_info(idx).creation_date := sysdate;
            p_curr_rate_info(idx).last_update_login := l_login_id;
            p_curr_rate_info(idx).last_update_date := sysdate;
            p_curr_rate_info(idx).last_updated_by := l_user_id;
            p_curr_rate_info(idx).adjustment_id := 0;

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Initializing current rate info first and current rate info next');
            p_curr_rate_info_first(idx) := p_curr_rate_info(idx);
            p_curr_rate_info_next(idx) := p_curr_rate_info(idx);

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Initializing reval asset rules');
            p_reval_asset_rules(idx).book_type_code := p_reval_asset_params(idx).book_type_code;
            p_reval_asset_rules(idx).asset_id := p_reval_asset_params(idx).asset_id;
            p_reval_asset_rules(idx).revaluation_factor := l_reval_factor;
            p_reval_asset_rules(idx).category_id := p_reval_asset_params(idx).category_id;
            p_reval_asset_rules(idx).revaluation_id := 0;

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Initializing fa asset info');
            p_fa_asset_info(idx) := l_fa_asset_info;

	    /* Bug 2961656 vgadde 08-jul-2003 Start(10) */
            IF (p_calling_function = 'ADDITION' OR p_calling_function = 'RECLASS') THEN

                 ---Get the details for supplied depreciation and YTD --------
                 IF ((p_calling_function = 'ADDITION') AND (NVL(l_booksrow_YTD,0) <> 0) AND (p_asset_last_period IS NuLL))  THEN -- supplied YYD

                        IF NOT (igi_iac_common_utils.get_period_info_for_counter(
                                        p_reval_asset_params(idx).book_type_code,
                                        p_period_counter-1,
                                        l_open_period)) THEN
                      		    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		                                                             p_full_path => l_path_name,
                                           		     		         p_string => '     Error in getting open period information');
                            return FALSE;
                        END IF;

                        IF (l_open_period.fiscal_year <> l_curr_period.fiscal_year) THEN -- If not addition year

                                    p_fa_asset_info(idx).deprn_amount := p_fa_deprn_expense_py;
                                    p_fa_asset_info(idx).deprn_periods_elapsed :=l_curr_period.period_counter - l_dpis_period.period_counter + 1;
                                    --p_fa_asset_info(idx).deprn_amount := (l_booksrow_reserve-l_booksrow_YTD)/p_fa_asset_info(idx).deprn_periods_elapsed;
                                    IF (l_dpis_period.fiscal_year = l_curr_period.fiscal_year AND l_dpis_period.period_num <= l_curr_period.period_num) THEN
                                	    p_fa_asset_info(idx).deprn_periods_current_year := l_curr_period.period_num - l_dpis_period.period_num + 1;
    		                        ELSE
                    	                p_fa_asset_info(idx).deprn_periods_current_year := l_curr_period.period_num ;
                            		END IF;
                                    p_fa_asset_info(idx).deprn_periods_prior_year :=
                                    p_fa_asset_info(idx).deprn_periods_elapsed - p_fa_asset_info(idx).deprn_periods_current_year;
                                    p_fa_asset_info(idx).deprn_reserve :=
                                    p_fa_asset_info(idx).deprn_periods_elapsed * p_fa_deprn_expense_py;
                                    do_round(p_fa_asset_info(idx).deprn_reserve,p_reval_asset_params(1).book_type_code);

                                    p_fa_asset_info(idx).ytd_deprn :=
                                    p_fa_asset_info(idx).deprn_periods_current_year * p_fa_deprn_expense_py;
                                    do_round(p_fa_asset_info(idx).ytd_deprn,p_reval_asset_params(1).book_type_code);
                                    p_fa_asset_info(idx).pys_deprn_reserve :=
                                    p_fa_asset_info(idx).deprn_reserve - p_fa_asset_info(idx).ytd_deprn;
                         ELSE /* Revaluation in the latest fiscal year */
                                        p_fa_asset_info(idx).deprn_periods_elapsed :=
                                        l_curr_period.period_counter - l_dpis_period.period_counter + 1;

                                        IF (l_dpis_period.fiscal_year = l_curr_period.fiscal_year AND l_dpis_period.period_num <= l_curr_period.period_num) THEN
                                               p_fa_asset_info(idx).deprn_periods_current_year := l_curr_period.period_num - l_dpis_period.period_num + 1;
                        		        ELSE
                                    	    p_fa_asset_info(idx).deprn_periods_current_year := l_curr_period.period_num ;
                                		END IF;
    		                            p_fa_asset_info(idx).deprn_periods_prior_year :=
                                        p_fa_asset_info(idx).deprn_periods_elapsed - p_fa_asset_info(idx).deprn_periods_current_year;
                                        p_fa_asset_info(idx).pys_deprn_reserve := p_fa_asset_info(idx).deprn_periods_prior_year*p_fa_deprn_expense_py;
                                        do_round(p_fa_asset_info(idx).pys_deprn_reserve,p_reval_asset_params(1).book_type_code);
                                        p_fa_asset_info(idx).ytd_deprn :=  p_fa_asset_info(idx).deprn_periods_current_year * p_fa_deprn_expense_cy;
                                        do_round(p_fa_asset_info(idx).ytd_deprn,p_reval_asset_params(1).book_type_code);
                                        p_fa_asset_info(idx).deprn_reserve :=p_fa_asset_info(idx).pys_deprn_reserve+p_fa_asset_info(idx).ytd_deprn;
                                        p_fa_asset_info(idx).deprn_amount :=p_fa_deprn_expense_cy;

                     END IF;
            ELSE      -- If no supplied YTD

                    IF (nvl(p_asset_last_period,l_curr_period.period_counter+1) >= l_curr_period.period_counter) THEN
                            p_fa_asset_info(idx).deprn_periods_elapsed :=
                                         l_curr_period.period_counter - l_dpis_period.period_counter + 1 ;
                    ELSE
                            p_fa_asset_info(idx).deprn_periods_elapsed :=
                                        p_asset_last_period - l_dpis_period.period_counter + 1;
                    END IF;
                    p_fa_asset_info(idx).deprn_reserve :=
                                p_fa_asset_info(idx).deprn_periods_elapsed * p_fa_deprn_expense_py;
                    do_round(p_fa_asset_info(idx).deprn_reserve,p_reval_asset_params(1).book_type_code);

                    IF NOT igi_iac_ytd_engine.Calculate_YTD
                                    ( p_reval_asset_params(1).book_type_code,
                                      p_reval_asset_params(1).asset_id,
                                      p_fa_asset_info(idx),
                                     l_dpis_period.period_counter,
                                     l_curr_period.period_counter,
                                    p_calling_function) THEN
                        RETURN FALSE;
                    END IF;

                END IF; -- supplied YTd

            ELSIF p_calling_function = 'UPGRADE' THEN

            IF (p_fa_deprn_expense_py = p_fa_deprn_expense_cy) THEN
                IF (nvl(p_asset_last_period,l_curr_period.period_counter+1) >= l_curr_period.period_counter) THEN
                    p_fa_asset_info(idx).deprn_periods_elapsed :=
                        l_curr_period.period_counter - l_dpis_period.period_counter + 1 ;
                ELSE
                    p_fa_asset_info(idx).deprn_periods_elapsed :=
                            p_asset_last_period - l_dpis_period.period_counter + 1;
                END IF;
                p_fa_asset_info(idx).deprn_reserve :=
                            p_fa_asset_info(idx).deprn_periods_elapsed * p_fa_deprn_expense_py;
                do_round(p_fa_asset_info(idx).deprn_reserve,p_reval_asset_params(1).book_type_code);

                igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                  p_full_path => l_path_name,
                  p_string => 'p_fa_asset_info(idx).deprn_periods_elapsed = ' || p_fa_asset_info(idx).deprn_periods_elapsed);

                igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                  p_full_path => l_path_name,
                  p_string => 'p_fa_asset_info(idx).deprn_reserve = ' || p_fa_asset_info(idx).deprn_reserve);

                IF NOT igi_iac_ytd_engine.Calculate_YTD
                                ( p_reval_asset_params(1).book_type_code,
                                p_reval_asset_params(1).asset_id,
                                p_fa_asset_info(idx),
                                l_dpis_period.period_counter,
                                l_curr_period.period_counter,
                                p_calling_function) THEN
                    RETURN FALSE;
                END IF;
            ELSE

                IF NOT (igi_iac_common_utils.get_period_info_for_counter(
                                        p_reval_asset_params(idx).book_type_code,
                                        p_period_counter,
                                        l_open_period)) THEN
          		    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     		p_full_path => l_path_name,
		     		p_string => '     Error in getting open period information');
                    return FALSE;
                END IF;

                IF p_asset_last_period IS NOT NULL THEN
                    IF NOT igi_iac_common_utils.get_period_info_for_counter(
                                                    p_reval_asset_params(idx).book_type_code,
                                                    p_asset_last_period,
                                                    l_last_deprn_period) THEN
                      			igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		         	                                 	p_full_path => l_path_name,
                            		             		p_string => '     Error in getting last depreciation period information');
                            return FALSE;
                    END IF;
                END IF;

                IF (l_open_period.fiscal_year <> l_curr_period.fiscal_year) THEN
                    IF (nvl(p_asset_last_period,l_curr_period.period_counter+1) >= l_curr_period.period_counter) THEN
                        p_fa_asset_info(idx).deprn_amount := p_fa_deprn_expense_py;
                        p_fa_asset_info(idx).deprn_periods_elapsed :=
                            l_curr_period.period_counter - l_dpis_period.period_counter + 1;
                        IF (l_dpis_period.fiscal_year = l_curr_period.fiscal_year AND l_dpis_period.period_num <= l_curr_period.period_num) THEN
                    	    p_fa_asset_info(idx).deprn_periods_current_year := l_curr_period.period_num - l_dpis_period.period_num + 1;
    		        ELSE
                    	    p_fa_asset_info(idx).deprn_periods_current_year := l_curr_period.period_num ;
            		END IF;
                        p_fa_asset_info(idx).deprn_periods_prior_year :=
                                p_fa_asset_info(idx).deprn_periods_elapsed - p_fa_asset_info(idx).deprn_periods_current_year;
                        p_fa_asset_info(idx).deprn_reserve :=
                                p_fa_asset_info(idx).deprn_periods_elapsed * p_fa_asset_info(idx).deprn_amount;
                        do_round(p_fa_asset_info(idx).deprn_reserve,p_reval_asset_params(1).book_type_code);
                        p_fa_asset_info(idx).ytd_deprn :=
                                p_fa_asset_info(idx).deprn_periods_current_year * p_fa_asset_info(idx).deprn_amount;
                        do_round(p_fa_asset_info(idx).ytd_deprn,p_reval_asset_params(1).book_type_code);
                        p_fa_asset_info(idx).pys_deprn_reserve :=
                                p_fa_asset_info(idx).deprn_reserve - p_fa_asset_info(idx).ytd_deprn;
                    ELSE
                        IF l_last_deprn_period.fiscal_year = l_curr_period.fiscal_year THEN
                            p_fa_asset_info(idx).deprn_amount := 0;
                            p_fa_asset_info(idx).deprn_periods_elapsed :=
                                l_last_deprn_period.period_counter - l_dpis_period.period_counter + 1;
                            IF (l_dpis_period.fiscal_year = l_last_deprn_period.fiscal_year AND l_dpis_period.period_num <= l_last_deprn_period.period_num) THEN
                    	        p_fa_asset_info(idx).deprn_periods_current_year := l_last_deprn_period.period_num - l_dpis_period.period_num + 1;
    		            ELSE
                    	        p_fa_asset_info(idx).deprn_periods_current_year := l_last_deprn_period.period_num ;
            		    END IF;
    		            p_fa_asset_info(idx).deprn_periods_prior_year :=
                                p_fa_asset_info(idx).deprn_periods_elapsed - p_fa_asset_info(idx).deprn_periods_current_year;
                            p_fa_asset_info(idx).deprn_reserve :=
                                p_fa_asset_info(idx).deprn_periods_elapsed * p_fa_deprn_expense_py;
                            do_round(p_fa_asset_info(idx).deprn_reserve,p_reval_asset_params(1).book_type_code);
                            p_fa_asset_info(idx).ytd_deprn :=
                                p_fa_asset_info(idx).deprn_periods_current_year * p_fa_deprn_expense_py;
                            do_round(p_fa_asset_info(idx).ytd_deprn,p_reval_asset_params(1).book_type_code);
                            p_fa_asset_info(idx).pys_deprn_reserve :=
                                p_fa_asset_info(idx).deprn_reserve - p_fa_asset_info(idx).ytd_deprn;
                        ELSE /* fully reserved in a year prior to current revaluation */
                            p_fa_asset_info(idx).deprn_amount := 0;
                            p_fa_asset_info(idx).deprn_periods_elapsed :=
                                l_last_deprn_period.period_counter - l_dpis_period.period_counter + 1;
                            p_fa_asset_info(idx).deprn_periods_current_year := 0;
    		            p_fa_asset_info(idx).deprn_periods_prior_year :=
                                p_fa_asset_info(idx).deprn_periods_elapsed - p_fa_asset_info(idx).deprn_periods_current_year;
                            p_fa_asset_info(idx).deprn_reserve :=
                                p_fa_asset_info(idx).deprn_periods_elapsed * p_fa_deprn_expense_py;
                            do_round(p_fa_asset_info(idx).deprn_reserve,p_reval_asset_params(1).book_type_code);
                            p_fa_asset_info(idx).ytd_deprn :=
                                p_fa_asset_info(idx).deprn_periods_current_year * p_fa_deprn_expense_py;
                            do_round(p_fa_asset_info(idx).ytd_deprn,p_reval_asset_params(1).book_type_code);
                            p_fa_asset_info(idx).pys_deprn_reserve :=
                                p_fa_asset_info(idx).deprn_reserve - p_fa_asset_info(idx).ytd_deprn;
                        END IF;
                    END IF;
                ELSE /* Revaluation in the latest fiscal year */
                    IF (nvl(p_asset_last_period,l_curr_period.period_counter+1) >= l_curr_period.period_counter) THEN
                        p_fa_asset_info(idx).deprn_amount := p_fa_deprn_expense_cy;
                        p_fa_asset_info(idx).deprn_periods_elapsed :=
                            l_curr_period.period_counter - l_dpis_period.period_counter + 1;
                        IF (l_dpis_period.fiscal_year = l_curr_period.fiscal_year AND l_dpis_period.period_num <= l_curr_period.period_num) THEN
                    	    p_fa_asset_info(idx).deprn_periods_current_year := l_curr_period.period_num - l_dpis_period.period_num + 1;
    		        ELSE
                    	    p_fa_asset_info(idx).deprn_periods_current_year := l_curr_period.period_num ;
            		END IF;
    		        p_fa_asset_info(idx).deprn_periods_prior_year :=
                                p_fa_asset_info(idx).deprn_periods_elapsed - p_fa_asset_info(idx).deprn_periods_current_year;
                        p_fa_asset_info(idx).deprn_reserve :=
                                p_fa_asset_info(idx).deprn_periods_prior_year * p_fa_deprn_expense_py +
                                p_fa_asset_info(idx).deprn_periods_current_year * p_fa_deprn_expense_cy;
                        do_round(p_fa_asset_info(idx).deprn_reserve,p_reval_asset_params(1).book_type_code);
                        p_fa_asset_info(idx).ytd_deprn :=
                                p_fa_asset_info(idx).deprn_periods_current_year * p_fa_deprn_expense_cy;
                        do_round(p_fa_asset_info(idx).ytd_deprn,p_reval_asset_params(1).book_type_code);
                        p_fa_asset_info(idx).pys_deprn_reserve :=
                                p_fa_asset_info(idx).deprn_reserve - p_fa_asset_info(idx).ytd_deprn;
                    ELSE
                        IF l_last_deprn_period.fiscal_year = l_curr_period.fiscal_year THEN
                            p_fa_asset_info(idx).deprn_amount := 0;
                            p_fa_asset_info(idx).deprn_periods_elapsed :=
                                l_last_deprn_period.period_counter - l_dpis_period.period_counter + 1;
                            IF (l_dpis_period.fiscal_year = l_last_deprn_period.fiscal_year AND l_dpis_period.period_num <= l_last_deprn_period.period_num) THEN
                    	        p_fa_asset_info(idx).deprn_periods_current_year := l_last_deprn_period.period_num - l_dpis_period.period_num + 1;
    		            ELSE
                    	        p_fa_asset_info(idx).deprn_periods_current_year := l_last_deprn_period.period_num ;
            		    END IF;
    		            p_fa_asset_info(idx).deprn_periods_prior_year :=
                                p_fa_asset_info(idx).deprn_periods_elapsed - p_fa_asset_info(idx).deprn_periods_current_year;
                            p_fa_asset_info(idx).deprn_reserve :=
                                p_fa_asset_info(idx).deprn_periods_prior_year * p_fa_deprn_expense_py +
                                p_fa_asset_info(idx).deprn_periods_current_year * p_fa_deprn_expense_cy;
                            do_round(p_fa_asset_info(idx).deprn_reserve,p_reval_asset_params(1).book_type_code);
                            p_fa_asset_info(idx).ytd_deprn :=
                                p_fa_asset_info(idx).deprn_periods_current_year * p_fa_deprn_expense_cy;
                            do_round(p_fa_asset_info(idx).ytd_deprn,p_reval_asset_params(1).book_type_code);
                            p_fa_asset_info(idx).pys_deprn_reserve :=
                                p_fa_asset_info(idx).deprn_reserve - p_fa_asset_info(idx).ytd_deprn;
                        ELSE /* fully reserved in a year prior to current revaluation */
                            p_fa_asset_info(idx).deprn_amount := 0;
                            p_fa_asset_info(idx).deprn_periods_elapsed :=
                                l_last_deprn_period.period_counter - l_dpis_period.period_counter + 1;
                            p_fa_asset_info(idx).deprn_periods_current_year := 0;
    		                p_fa_asset_info(idx).deprn_periods_prior_year :=
                                p_fa_asset_info(idx).deprn_periods_elapsed - p_fa_asset_info(idx).deprn_periods_current_year;
                            p_fa_asset_info(idx).deprn_reserve :=
                                p_fa_asset_info(idx).deprn_periods_prior_year * p_fa_deprn_expense_py;
                            do_round(p_fa_asset_info(idx).deprn_reserve,p_reval_asset_params(1).book_type_code);
                            p_fa_asset_info(idx).ytd_deprn := 0;
                            p_fa_asset_info(idx).pys_deprn_reserve := p_fa_asset_info(idx).deprn_reserve;
                        END IF;
                    END IF;
                END IF;
            END IF;
            END IF;
	        /* Bug 2961656 vgadde 08-jul-2003 End(10) */
      	     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                     p_full_path => l_path_name,
                                		     p_string => '         Deprn amount :'||to_char(p_fa_asset_info(idx).deprn_amount));
  	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                     p_full_path => l_path_name,
                                		     p_string => '         Deprn periods elapsed :'||to_char(p_fa_asset_info(idx).deprn_periods_elapsed));
      	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	                                    	     p_full_path => l_path_name,
                                    		     p_string => '         Deprn periods current year :'||to_char(p_fa_asset_info(idx).deprn_periods_current_year));
      	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	                                             p_full_path => l_path_name,
                                    		     p_string => '         Deprn periods prior year :'||to_char(p_fa_asset_info(idx).deprn_periods_prior_year));
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                         p_full_path => l_path_name,
                                    		     p_string => '         Deprn YTD :'||to_char(p_fa_asset_info(idx).ytd_deprn));
      	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		                                         p_full_path => l_path_name,
                                	    	     p_string => '         Prior years deprn reserve :'||to_char(p_fa_asset_info(idx).pys_deprn_reserve));
      	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	                                    	     p_full_path => l_path_name,
                                    		     p_string => '         Deprn Reserve :'||to_char(p_fa_asset_info(idx).deprn_reserve));
      	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	                                    	     p_full_path => l_path_name,
                                    		     p_string => '     Initializing reval exceptions');
                                                 p_reval_exceptions(idx).asset_id := p_reval_asset_params(idx).asset_id;
                                                    p_reval_exceptions(idx).book_type_code := p_reval_asset_params(idx).book_type_code;

            l_prev_price_index := l_curr_price_index;

        END LOOP;

      	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	                                	     p_full_path => l_path_name,
                                            p_string => ' End of initialization for revaluation in catchup pkg');
        return TRUE;

        EXCEPTION
            WHEN OTHERS THEN
          		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                return FALSE;
    END do_reval_init_struct;

 BEGIN

    g_debug := FALSE;

    --===========================FND_LOG.START=====================================

    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        := 'IGI.PLSQL.igiiactb.igi_iac_catchup_pkg.';

    --===========================FND_LOG.END=====================================



END igi_iac_catchup_pkg;

/
