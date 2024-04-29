--------------------------------------------------------
--  DDL for Package Body FA_AMORT_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_AMORT_VAL_PKG" as
/* $Header: FAAMRTVB.pls 120.3.12010000.2 2009/07/19 12:37:22 glchen ship $ */

-- this function validates amortization start date entered by user
-- if there is any retirement/reinstatement/revaluation
-- after the amortization start date then new_amort_start_date
-- will be populated with same date as transaction date of retire/reinstate/reval
-- calling program will use new amortization start date as amortization date
-- if user choose to use it.
FUNCTION val_amort_date(x_amort_start_date		date,
			x_new_amort_start_date   out nocopy date,
			x_book			        varchar2,
			x_asset_id			number,
			x_dpis			        date,
			x_txns_exist	     in  out nocopy    varchar2,
			x_err_code	         out nocopy    varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean is

h_transaction_date		date;
h_period_close_date		date;
h_period_open_date		date;
h_prior_transaction_date 	date;
h_prior_date_effective 	 	date;
h_amort_date			date;
h_avail_date			date;
h_count				number;
dpis_jdate			number;
amort_jdate			number;
dpis_fy				number;
amort_fy			number;
dpis_per_num			number;
amort_per_num			number;
fy_name				varchar2(45);
cal_type			varchar2(15);
start_jdate			number;

CURSOR current_period_info IS
          select greatest(calendar_period_open_date,
                   least(sysdate, calendar_period_close_date)),
                   calendar_period_close_date, calendar_period_open_date
          from   fa_deprn_periods
          where  book_type_code = x_book
          and    period_close_date is null;

begin

     x_new_amort_start_date := x_amort_start_date;
     x_txns_exist := 'N';  -- sets to Y if any txn exist between current period
                           -- and amortization period

     -- x_amort_start_date cannot be future period

     open current_period_info;
     fetch current_period_info
     into h_transaction_date, h_period_close_date, h_period_open_date;
     close current_period_info;

     if (x_amort_start_date > h_period_close_date) then
         x_err_code := 'FA_SHARED_CANNOT_FUTURE';
         return FALSE;
     end if;

     -- x_amort_start_date cannot be less than DPIS

     if (x_amort_start_date < x_dpis) then
         x_new_amort_start_date := x_dpis;
         x_txns_exist := 'Y';
         --x_err_code := 'FA_AMORT_DATE_INVALID';
         --return FALSE;
     end if;

     select fiscal_year_name,deprn_calendar
     into fy_name, cal_type
     from fa_book_controls
     where book_type_code = x_book;

/* this check is already done in the books form

--   checks if dpis is valid dpis
     dpis_jdate := to_number(to_char(x_dpis,'J'));
     if (not fa_cache_pkg.fazccp(cal_type,fy_name,dpis_jdate,
                                 dpis_per_num,dpis_fy,start_jdate, p_log_level_rec => p_log_level_rec)) then
         x_err_code := 'FA_PROD_INCORRECT_DATE';
         return FALSE;
     end if;
*/

--   checks if amort start date is valid
     amort_jdate := to_number(to_char(x_new_amort_start_date,'J'));
     if (not fa_cache_pkg.fazccp(cal_type,fy_name,amort_jdate,
                                 amort_per_num,amort_fy,start_jdate, p_log_level_rec => p_log_level_rec)) then
         x_err_code := 'FA_PROD_INCORRECT_DATE';
         return FALSE;
     end if;

/*
     if (amort_fy = dpis_fy) then
         if (amort_per_num < dpis_per_num) then
            x_err_code := 'FA_AMORT_DATE_INVALID';
            return FALSE;
         end if;
     else
         if (amort_fy < dpis_fy) then
            x_err_code := 'FA_AMORT_DATE_INVALID';
            return FALSE;
         end if;
     end if;
*/


     -- check if amort start date is eariler than
     -- previous txn date, set txns_exist

     select MAX(transaction_date_entered),MAX(date_effective)
     into   h_prior_transaction_date,h_prior_date_effective
     from   fa_transaction_headers
     where  asset_id = x_asset_id
     and    book_type_code = x_book;

     if (x_new_amort_start_date < h_prior_transaction_date) then
         --x_err_code := 'FA_SHARED_OTHER_TRX_FOLLOW';
         x_txns_exist := 'Y';
     end if;


     select count(*)
     into h_count
     from fa_deprn_periods pdp, fa_deprn_periods adp
     where pdp.book_type_code = x_book
     and pdp.book_type_code = adp.book_type_code
     and pdp.period_counter > adp.period_counter
     and h_prior_date_effective between pdp.period_open_date
             and nvl(pdp.period_close_date, to_date('31-12-4712','DD-MM-YYYY'))
     and x_new_amort_start_date between
             adp.calendar_period_open_date and adp.calendar_period_close_date;

     if (h_count > 0) then
         --x_err_code := 'FA_SHARED_OTHER_TRX_FOLLOW';
         x_txns_exist := 'Y';
     end if;

     -- check to see if any retire/reinstate/reval txn is in between
     -- x_new_amort_start_date and current_period.
     -- this check covers for the prior period retire/reinste/reval
     -- set x_new_amort_start_date := latest txn date

     select MAX(date_effective)
     into   h_prior_date_effective
     from   fa_transaction_headers
     where  asset_id = x_asset_id
     and   book_type_code = x_book
     and   transaction_type_code in ('REVALUATION');

     if (h_prior_date_effective is not null) then

        -- get the latest available date
        select greatest(calendar_period_open_date,
                least(SYSDATE, calendar_period_close_date))
        into h_amort_date
        from fa_deprn_periods
        where book_type_code = X_book
        and h_prior_date_effective between
            period_open_date and
            nvl(period_close_date,sysdate);

        if (x_new_amort_start_date < h_amort_date) then
           x_new_amort_start_date := h_amort_date;
        end if;
     end if;

     return TRUE;

exception
     when others then
        x_err_code := sqlcode;
        return FALSE;
end;

END FA_AMORT_VAL_PKG;

/
