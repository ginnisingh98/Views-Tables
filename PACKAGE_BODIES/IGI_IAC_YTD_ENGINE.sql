--------------------------------------------------------
--  DDL for Package Body IGI_IAC_YTD_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_YTD_ENGINE" AS
-- $Header: igiiaytb.pls 120.2.12010000.2 2010/06/24 17:59:06 schakkin ship $
--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiareb.IGI_IAC_YTD_ENGINE.';

--===========================FND_LOG.END=======================================
    g_debug BOOLEAN := FALSE;
    PROCEDURE Debug(p_debug varchar2) IS
    BEGIN
        IF g_debug THEN
            --fnd_file.put_line(fnd_file.log,'YTD Engine***'||p_debug);
            igi_iac_debug_pkg.debug_other_string( p_level => g_state_level,
		                                          p_full_path => g_path,
		                                          p_string => p_debug);
        END IF;
    END Debug;

    procedure do_round ( p_amount in out NOCOPY number, p_book_type_code in varchar2) is
      l_path varchar2(150) := g_path||'do_round(p_amount,p_book_type_code)';
      l_amount number     := p_amount;
      l_amount_old number := p_amount;
      --l_path varchar2(150) := g_path||'do_round';
    begin
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'--- Inside Round() ---');
       IF IGI_IAC_COMMON_UTILS.Iac_Round(X_Amount => l_amount, X_Book => p_book_type_code)
       THEN
          p_amount := l_amount;
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IGI_IAC_COMMON_UTILS.Iac_Round is TRUE');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_amount = '||p_amount);
       ELSE
          p_amount := round( l_amount, 2);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IGI_IAC_COMMON_UTILS.Iac_Round is FALSE');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_amount = '||p_amount);
       END IF;
    exception when others then
      p_amount := l_amount_old;
      igi_iac_debug_pkg.debug_unexpected_msg(l_path);
      Raise;
    end;

    FUNCTION Calculate_YTD
        ( p_book_type_code IN VARCHAR2,
        p_asset_id         IN NUMBER,
        p_asset_info       IN OUT NOCOPY igi_iac_types.fa_hist_asset_info,
        p_start_period     IN OUT NOCOPY NUMBER,
        p_end_period       IN OUT NOCOPY NUMBER,
        p_calling_program  IN VARCHAR2
        ) RETURN BOOLEAN
    IS

        CURSOR c_get_dpis IS
        SELECT date_placed_in_service
        FROM fa_books
        WHERE book_type_code = p_book_type_code
        AND asset_id = p_asset_id;

        CURSOR c_get_deprn_calendar IS
        SELECT deprn_calendar
        FROM fa_book_controls
        WHERE book_type_code like p_book_type_code;

        CURSOR c_get_periods_in_year(p_calendar_type fa_calendar_types.calendar_type%TYPE) IS
        SELECT number_per_fiscal_year
        FROM fa_calendar_types
        WHERE calendar_type = p_calendar_type;

        l_start_period          igi_iac_types.prd_rec;
        l_end_period            igi_iac_types.prd_rec;
        l_dpis_period           igi_iac_types.prd_rec;
        l_open_period           igi_iac_types.prd_rec;
        l_last_period           igi_iac_types.prd_rec;
        l_deprn_reserve         NUMBER;
        l_max_deprn_period      NUMBER(15);
        l_deprn_calendar        fa_book_controls.deprn_calendar%TYPE;
        l_periods_per_FY        fa_calendar_types.number_per_fiscal_year%TYPE;
        l_total_periods         NUMBER;
        l_last_period_counter   NUMBER;
        l_last_deprn_period     igi_iac_types.prd_rec;
        l_deprn_periods_elapsed      NUMBER;
        l_deprn_periods_current_year NUMBER;

    BEGIN
        IF FND_PROFILE.VALUE('IGI_DEBUG_OPTION') = 'Y'  THEN
            g_debug := TRUE;
        END IF;

        Debug('Start of processing for YTD Engine');
        IF (p_asset_info.date_placed_in_service IS NULL) THEN
            OPEN c_get_dpis;
            FETCH c_get_dpis INTO p_asset_info.date_placed_in_service;
            CLOSE c_get_dpis;
        END IF;

        IF NOT igi_iac_common_utils.get_period_info_for_date(p_book_type_code,
                                                             p_asset_info.date_placed_in_service,
                                                             l_dpis_period) THEN
            RETURN FALSE;
        END IF;

        IF (p_start_period IS NULL) THEN
            l_start_period := l_dpis_period;
        ELSE
            IF NOT igi_iac_common_utils.get_period_info_for_counter(p_book_type_code,
                                                                p_start_period,
                                                                l_start_period) THEN
                RETURN FALSE;
            END IF;
        END IF;

        IF NOT igi_iac_common_utils.get_open_period_info(p_book_type_code,
                                                         l_open_period) THEN
            RETURN FALSE;
        END IF;

        IF (p_end_period IS NULL) THEN
            l_end_period := l_open_period;
        ELSE
            IF NOT igi_iac_common_utils.get_period_info_for_counter(p_book_type_code,
                                                                p_end_period,
                                                                l_end_period) THEN
                RETURN FALSE;
            END IF;
        END IF;

        OPEN c_get_deprn_calendar;
        FETCH c_get_deprn_calendar INTO l_deprn_calendar;
        CLOSE c_get_deprn_calendar;

        OPEN c_get_periods_in_year(l_deprn_calendar);
        FETCH c_get_periods_in_year INTO l_periods_per_FY;
        CLOSE c_get_periods_in_year;

        l_total_periods := ceil((p_asset_info.life_in_months*l_periods_per_FY)/12);
        l_last_period_counter := (l_dpis_period.period_counter + l_total_periods - 1);

        l_deprn_periods_elapsed := l_end_period.period_counter - l_dpis_period.period_counter + 1;
        l_deprn_periods_current_year := l_end_period.period_num;
        Debug('+l_deprn_periods_elapsed : '||l_deprn_periods_elapsed);
        Debug('+l_deprn_periods_current_year :'||l_deprn_periods_current_year);
        IF (l_end_period.fiscal_year = l_dpis_period.fiscal_year) THEN
            l_deprn_periods_current_year := l_end_period.period_counter - l_dpis_period.period_counter + 1;
            l_deprn_periods_elapsed := l_deprn_periods_current_year;
        END IF;

        IF (l_last_period_counter < l_end_period.period_counter) THEN
            IF NOT igi_iac_common_utils.get_period_info_for_counter(p_book_type_code,
                                                                l_last_period_counter,
                                                                l_last_deprn_period) THEN
                RETURN FALSE;
            END IF;
            l_deprn_periods_elapsed := l_last_deprn_period.period_counter - l_dpis_period.period_counter + 1;
            IF (l_end_period.fiscal_year = l_last_deprn_period.fiscal_year) THEN
                l_deprn_periods_current_year := l_last_deprn_period.period_num;
            END IF;

            IF (l_dpis_period.fiscal_year = l_last_deprn_period.fiscal_year) THEN
                l_deprn_periods_current_year := l_last_deprn_period.period_num - l_dpis_period.period_num + 1;
            END IF;

            IF (l_last_deprn_period.fiscal_year < l_end_period.fiscal_year ) THEN
                l_deprn_periods_current_year := 0;
            END IF;

        END IF;
        Debug('++l_deprn_periods_elapsed : '||l_deprn_periods_elapsed);
        Debug('++l_deprn_periods_current_year :'||l_deprn_periods_current_year);
        IF nvl(p_asset_info.depreciate_flag,'NO') <> 'YES' THEN
            p_asset_info.deprn_periods_current_year := l_deprn_periods_current_year;
            p_asset_info.deprn_periods_elapsed := l_deprn_periods_elapsed;
            p_asset_info.deprn_periods_prior_year := l_deprn_periods_elapsed - l_deprn_periods_current_year;
            p_asset_info.ytd_deprn := 0;
            p_asset_info.pys_deprn_reserve := 0;
            p_asset_info.deprn_amount := 0;
        ELSE
            p_asset_info.deprn_periods_current_year := l_deprn_periods_current_year;
            p_asset_info.deprn_periods_elapsed := l_deprn_periods_elapsed;
            p_asset_info.deprn_periods_prior_year := l_deprn_periods_elapsed - l_deprn_periods_current_year;
            p_asset_info.ytd_deprn := p_asset_info.deprn_reserve * (l_deprn_periods_current_year/l_deprn_periods_elapsed);
            do_round(p_asset_info.ytd_deprn,p_book_type_code);
            p_asset_info.pys_deprn_reserve := p_asset_info.deprn_reserve - p_asset_info.ytd_deprn;
            IF (l_last_period_counter < l_end_period.period_counter) AND (p_calling_program <> 'EXPENSED') THEN
                p_asset_info.deprn_amount := 0;
            ELSE
                p_asset_info.deprn_amount := p_asset_info.deprn_reserve / l_deprn_periods_elapsed;
                do_round(p_asset_info.deprn_amount,p_book_type_code);
            END IF;
            p_asset_info.last_period_counter := l_last_period_counter;
        END IF;
       return TRUE ;
    EXCEPTION
      WHEN others THEN
          return FALSE ;
    END Calculate_YTD;

END igi_iac_ytd_engine;


/
