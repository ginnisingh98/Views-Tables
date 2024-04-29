--------------------------------------------------------
--  DDL for Package Body FA_SHORT_TAX_YEARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_SHORT_TAX_YEARS_PKG" AS
/* $Header: FAXSTYB.pls 120.7.12010000.2 2009/07/19 11:10:26 glchen ship $ */


--
-- PROCEDURE Calculate_Short_Tax_Vals
--

PROCEDURE Calculate_Short_Tax_Vals (
	X_Asset_Id		IN	NUMBER,
	X_Book_Type_Code	IN	VARCHAR2,
	X_Short_Fiscal_Year_Flag IN	VARCHAR2,
	X_Date_Placed_In_Service IN	DATE := NULL,
	X_Deprn_Start_Date       IN	DATE := NULL,
        X_Prorate_date          IN      DATE := NULL,
	X_Conversion_Date	IN	DATE := NULL,
	X_Orig_deprn_Start_Date	IN	DATE := NULL,
	X_Curr_Fy_Start_Date	IN	DATE := NULL,
	X_Curr_Fy_End_Date	IN	DATE := NULL,
	C_Date_Placed_In_Service IN 	VARCHAR2 := NULL,
	C_Deprn_Start_Date	IN	VARCHAR2 := NULL,
        C_Prorate_date          IN      VARCHAR2 := NULL,
	C_Conversion_Date	IN	VARCHAR2 := NULL,
	C_Orig_Deprn_Start_Date IN      VARCHAR2 := NULL,
	C_Curr_Fy_Start_Date	IN	VARCHAR2 := NULL,
	C_Curr_Fy_End_Date	IN	VARCHAR2 := NULL,
	X_Life_In_Months	IN	NUMBER,
	X_Rate_Source_Rule	IN	VARCHAR2,
	X_Fiscal_Year		IN	NUMBER,
	X_Method_Code		IN	VARCHAR2,
	X_Current_Period	IN	NUMBER,
	X_Remaining_Life1	OUT NOCOPY NUMBER,
	X_Remaining_Life2	OUT NOCOPY NUMBER,
	X_Success               OUT NOCOPY VARCHAR2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
	h_deprn_start_date	DATE := X_Deprn_Start_Date;
        h_prorate_date          DATE := X_Prorate_Date;
	h_conversion_date	DATE := X_Conversion_Date;
	h_orig_deprn_start_date	DATE := X_Orig_deprn_Start_Date;
	h_curr_fy_start_date	DATE := X_Curr_Fy_Start_Date;
	h_curr_fy_end_date	DATE := X_Curr_Fy_End_Date;
	h_dpis			DATE := X_Date_Placed_In_Service;
	h_num_days		NUMBER;

	-- added new variable to handle calculation of remaining life in non
	-- short tax asset scenario at the end of fiscal year when
	-- depreciation calls this from fadp5.lpc to calculate
	-- remaining life for the next fiscal year
	h_temp_fy_start_date	DATE := X_Curr_Fy_Start_Date;

	h_fy_name		varchar2(30);
	h_calendar_type		varchar2(15);
	h_cp_open_date		date;
	h_deprn_basis_rule_name	varchar2(80);

	cache_exception         EXCEPTION;

        l_period_rec            FA_API_TYPES.period_rec_type;
        l_amort_date            date;

        -- Bug4169773
        Cursor c_get_trx_date is
           select cp.start_date trx_date
           from   fa_transaction_headers th
                , fa_calendar_periods cp
           where  th.asset_id = X_Asset_Id
           and    th.book_type_code = X_Book_Type_Code
           and    cp.calendar_type = h_calendar_type
           and    nvl(th.amortization_start_date, th.transaction_date_entered)
                        between cp.start_date and cp.end_date
           and    th.transaction_subtype = 'AMORTIZED'
           and    nvl(th.amortization_start_date, th.transaction_date_entered)
                        between h_curr_fy_start_date and l_period_rec.calendar_period_close_date
           order by trx_date;

CURSOR check_date IS
    SELECT decode(X_Short_Fiscal_Year_Flag,
                  'YES',decode(fy.fiscal_year - bc.current_fiscal_year,
                            0, greatest(h_conversion_date, h_deprn_start_date),
                            h_conversion_date),
                  h_conversion_date),
	   decode(fy.fiscal_year - bc.current_fiscal_year,
		  0, h_deprn_start_date,
		  decode(h_curr_fy_start_date,
			 NULL,to_date(C_Curr_Fy_Start_Date, 'DD/MM/YYYY'),
			 h_curr_fy_start_date))
    FROM  fa_fiscal_year fy,
          fa_book_controls bc
    WHERE  h_dpis between fy.start_date
                                    and fy.end_date
    AND   bc.book_type_code = X_Book_Type_Code
    AND   bc.fiscal_year_name = fy.fiscal_year_name;

CURSOR get_cp_date IS
      select cp.start_date
      from fa_calendar_periods cp,
	   fa_fiscal_year fy
      where cp.calendar_type = h_calendar_type
      and   cp.period_num = X_Current_Period
      and   cp.start_date >= fy.start_date
      and   cp.end_date <= fy.end_date
      and   fy.fiscal_year_name = h_fy_name
      and   fy.fiscal_year = X_Fiscal_Year;


BEGIN

    -- Check if the depreciation method is a FORMULA method.  If not,
    -- return NULL values for remaining lives,
    -- as these values are not used for non-formula methods.
    IF (X_Rate_Source_Rule <> 'FORMULA') THEN
	X_Remaining_Life1 := NULL;
	X_Remaining_Life2 := NULL;
	X_Success := 'YES';
	RETURN;
    END IF;


    IF (X_Deprn_Start_Date IS NULL) THEN
    -- Pro*C function called this procedure.
	h_deprn_start_date := to_date(C_Deprn_Start_Date, 'DD/MM/YYYY');
	h_conversion_date := to_date(C_Conversion_Date,  'DD/MM/YYYY');
	h_orig_deprn_start_date := to_date(C_Orig_Deprn_Start_Date,
						'DD/MM/YYYY');
	h_curr_fy_start_date := to_date(C_Curr_Fy_Start_Date,
					'DD/MM/YYYY');
	h_curr_fy_end_date := to_date(C_Curr_Fy_End_Date,
				      'DD/MM/YYYY');
	h_dpis := to_date(C_Date_Placed_In_Service, 'DD/MM/YYYY');
        h_prorate_date := to_date(C_Prorate_Date, 'DD/MM/YYYY');

	-- when depreciation calls this from fadp5.lpc the value
	-- for C_Curr_Fy_Start_Date is actually the next fiscal year
	-- hold this in temp varibale and use this to calculate
	-- remaining life when called for last period of fiscal year
	-- since this will be greater than h_curr_fy_start_date
	-- in this routine
	h_temp_fy_start_date := to_date(C_Curr_Fy_Start_Date,
					'DD/MM/YYYY');
    END IF;

    /*------------------------------------------------------------------+
     | Set remaining lives.	 					|
     +------------------------------------------------------------------*/


    -- Check if life_in_months is null.  If so, remaining_life values
    -- need not be calculated.
    IF (nvl(X_Life_In_Months, 0) = 0) THEN
    -- life_in_months is either a non-zero value or null.
	X_Remaining_Life1 := NULL;
	X_Remaining_Life2 := NULL;
	X_Success := 'YES';
	RETURN;
    END IF;

    /* Set remaining_life1.  Should re-calculate every time as below
       instead of reducing by one year, since deprn_start_date may have changed
       if prorate_convention has changed.
       remaining_life1 := deprn_start_date + life_in_months
			- conversion_date */
    OPEN check_date;
    FETCH check_date into h_conversion_date,
			  h_curr_fy_start_date;
    CLOSE check_date;

    /* ****************************************************************
       Fix for Bug 1095275. Set conversion date and fy_start_date
       always to the first day of the month since months_between
       will give +1 or -1 months depending on which day of the month
       it is. This will result in different rate being returned
       for an asset added in the same month but different dates for
       example 01-JAN as opposed to 20-JAN
    **************************************************************** */

    h_num_days := to_number(to_char(h_conversion_date, 'DD'));
    h_conversion_date := h_conversion_date - h_num_days + 1;

    h_num_days := to_number(to_char(h_curr_fy_start_date, 'DD'));
    h_curr_fy_start_date := h_curr_fy_start_date - h_num_days + 1;

    h_num_days := to_number(to_char(h_temp_fy_start_date, 'DD'));
    h_temp_fy_start_date := h_temp_fy_start_date - h_num_days + 1;


    X_Remaining_Life1 :=
        trunc(months_between(add_months(h_orig_deprn_start_date,
					X_Life_In_Months),
                             (h_conversion_date)));
    /* Set remaining_life2.
       remaining_life2 := deprn_start_date + life_in_months
			- (the first day of the following fiscal year of the
			   purchasing company). */

    IF (h_conversion_date IS NULL) THEN
    -- Not a short-tax year asset but uses FORMULA method.
    -- Set remaining_life1..2 to be based from the current fiscal year
    -- start date.

        if (not fa_cache_pkg.fazccmt (
           X_Method => X_Method_Code,
           X_Life   => X_Life_In_Months
        , p_log_level_rec => p_log_level_rec)) then
           RAISE cache_exception;
        end if;

	h_deprn_basis_rule_name := fa_cache_pkg.fazcdbr_record.rule_name;

        -- Bug4169773: Relocated to outside of following if because it
        -- is used in else as well.
        if (not fa_cache_pkg.fazcbc(X_Book_Type_Code, p_log_level_rec => p_log_level_rec)) then
           RAISE cache_exception;
        end if;

        h_calendar_type := fa_cache_pkg.fazcbc_record.deprn_calendar;

	if (h_deprn_basis_rule_name in ('PERIOD END AVERAGE', 'BEGINNING PERIOD')) then

	   h_fy_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;
	   open get_cp_date;
	   fetch get_cp_date into h_cp_open_date;
	   close get_cp_date;

	   X_Remaining_Life1 :=
	            trunc(months_between(add_months(h_prorate_date,
                                                    X_Life_In_Months),
                                (h_cp_open_date)));

	else
           -- Fix for bug 2005996 calculate X_Remaining_Life1 from
	   -- prorate date instead of deprn_start_date

           -- Bug4169773: Remaining_Life1 cannot be the one as of
           -- beginning of fy if there is an amortized adj during
           -- current fy.
           -- This fix is only for non-short tax year case.

           if nvl(X_Short_Fiscal_Year_Flag, 'NO') = 'YES' then
              X_Remaining_Life1 :=
               trunc(months_between(add_months(h_prorate_date,
                                               X_Life_In_Months),
                                   (h_curr_fy_start_date)));

              if (h_temp_fy_start_date > h_curr_fy_start_date) then
                  X_Remaining_Life1 :=
                      trunc(months_between(add_months(h_prorate_date,
                                                   X_Life_In_Months),
                                   (h_temp_fy_start_date)));
              end if;

           else

              if not FA_UTIL_PVT.get_period_rec
                 (p_book           => X_Book_Type_Code,
                  p_effective_date => NULL,
                  x_period_rec     => l_period_rec, p_log_level_rec => p_log_level_rec) then

                 raise cache_exception;
              end if;

              open c_get_trx_date;
              fetch c_get_trx_date into l_amort_date;

              if c_get_trx_date%notfound then

                 X_Remaining_Life1 :=
                  trunc(months_between(add_months(h_prorate_date,
                                               X_Life_In_Months),
                                       (greatest(h_curr_fy_start_date, h_prorate_date))));

                 if (h_temp_fy_start_date > h_curr_fy_start_date) then
                 X_Remaining_Life1 :=
                               trunc(months_between(add_months(h_prorate_date,
                                                            X_Life_In_Months),
                                                    (h_temp_fy_start_date)));
                 end if;
              else

                 X_Remaining_Life1 :=
                    trunc(months_between(add_months(h_prorate_date,
                                                    X_Life_In_Months),
                                         (l_amort_date)));


              end if;

              close c_get_trx_date;

           end if; -- nvl(X_Short_Fiscal_Year_Flag, 'NO') = 'YES'

	end if;

	X_Remaining_Life2 := X_Remaining_Life1;
    ELSE
	-- Remaining_life2 can be a negative value at the last year of asset life.
	-- To get a correct depreciation amount, we should use FLOOR function
	-- instead of TRUNC so that remainig_life is not inflated, when
	-- remaining_life2 is a negative value(for positive value, FLOOR
	-- functionality is exactly the same as TRUNC functionality.)
	-- Also we do not want to take ABS value, since this generates
	-- an incorrect depreciation rate.
	X_Remaining_Life2 :=
		floor(months_between(add_months(h_orig_deprn_start_date,
					        X_Life_In_Months),
                                    (h_curr_fy_start_date)));
    END IF;
    X_Success := 'YES';



EXCEPTION
    WHEN OTHERS THEN
	X_Remaining_Life1 := NULL;
	X_Remaining_Life2 := NULL;
	X_Success := 'NO';
END Calculate_Short_Tax_Vals;


END FA_SHORT_TAX_YEARS_PKG;

/
