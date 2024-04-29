--------------------------------------------------------
--  DDL for Package Body XTR_CALC_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_CALC_P" as
/* $Header: xtrcalcb.pls 120.13.12010000.2 2008/08/06 10:42:31 srsampat ship $ */
----------------------------------------------------------------------------------------------------------------
-- This is just a cover function that determines whether CALC_DAYS_RUN or
-- CALC_DAYS_RUN_B should be called
-- use this procedure instead of CALC_DAYS_RUN if ACT/ACT-BOND day count basis
-- is used
-- When this procedure is called, and if the method is ACT/ACT-BOND,be aware of
-- the fact that year_basis will be
-- calculated incorrectly if start_date and end_date combined do not form a
-- coupon period. So, if year_basis are needed, make sure that, coupon periods
-- are sent in as parameters. num_days are calculated correctly all the time
PROCEDURE CALC_DAYS_RUN_C(start_date IN DATE,
                          end_date   IN DATE,
                          method     IN VARCHAR2,
                          frequency  IN NUMBER,
                          num_days   IN OUT NOCOPY NUMBER,
                          year_basis IN OUT NOCOPY NUMBER,
                          fwd_adjust IN NUMBER,
			  day_count_type IN VARCHAR2,
			  first_trans_flag IN VARCHAR2) is
--
begin
  XTR_MM_COVERS.CALC_DAYS_RUN_C(start_date,end_date,method,frequency,num_days,year_basis,fwd_adjust,day_count_type,first_trans_flag);
end CALC_DAYS_RUN_C;


-- This calculates the number of days and year basis for bond only day count
-- basis(ACT/ACT-BOND)
-- For ACT/ACT-BOND day count basis, this procedure must be used or preferably
-- through CALC_DAYS_RUN_C. CALC_DAYS_RUN must not be used for the day count
-- basis
-- When this procedure is called, be aware of the fact that year_basis will be
-- calculated incorrectly if start_date and end_date combined do not form a
-- coupon period. So, if year_basis are needed, make sure that, coupon periods
-- are sent in as parameters. num_days are calculated correctly all the time
PROCEDURE CALC_DAYS_RUN_B(start_date IN DATE,
                          end_date   IN DATE,
                          method     IN VARCHAR2,
                          frequency  IN NUMBER,
                          num_days   IN OUT NOCOPY NUMBER,
                          year_basis IN OUT NOCOPY NUMBER) is
begin
  XTR_MM_COVERS.CALC_DAYS_RUN_B(start_date,end_date,method,frequency,num_days,year_basis);
end CALC_DAYS_RUN_B;


-- Calculate over a Year Basis and Number of Days ased on different calc
-- methods.  Note that this procedure now supports ACTUAL/365L day count basis,
-- but it does not support ACT/ACT-BOND day count basis. In order to use the day
-- count basis, CALC_DAYS_RUN_C must be used
PROCEDURE CALC_DAYS_RUN(start_date IN DATE,
                        end_date   IN DATE,
                        method     IN VARCHAR2,
                        num_days   IN OUT NOCOPY NUMBER,
                        year_basis IN OUT NOCOPY NUMBER,
                        fwd_adjust IN NUMBER,
			day_count_type IN VARCHAR2,
			first_trans_flag IN VARCHAR2) is
begin
  XTR_MM_COVERS.CALC_DAYS_RUN(start_date,end_date,method,num_days,year_basis,fwd_adjust,day_count_type,first_trans_flag);
end CALC_DAYS_RUN;
-----------
/**************************************************/
/* New procedure added to handle IG calc_days_run */
/* calculation only. Made for bug 5349167         */
/**************************************************/
PROCEDURE CALC_DAYS_RUN_IG(start_date IN DATE,
                        end_date   IN DATE,
                        method     IN VARCHAR2,
                        num_days   IN OUT NOCOPY NUMBER,
                        year_basis IN OUT NOCOPY NUMBER,
                        fwd_adjust IN NUMBER DEFAULT NULL,
                        day_count_type IN VARCHAR2 DEFAULT NULL,
                        first_trans_flag IN VARCHAR2 DEFAULT NULL) is
--
   l_start_date DATE := start_date;
   l_end_date   DATE := end_date;
   l_start_year NUMBER := to_number(to_char(start_date,'YYYY'));
   l_end_year NUMBER := to_number(to_char(end_date,'YYYY'));
   start_year_basis     NUMBER;
   end_year_basis       NUMBER;
   l_total_days         NUMBER;
   l_total_year NUMBER:= l_end_year - l_start_year;
--
begin
   if start_date is not null and end_date is not null and method is not null then

      if l_end_date <l_start_date then
         FND_MESSAGE.Set_Name('XTR', 'XTR_1059');
         APP_EXCEPTION.raise_exception;

      else

         -------------------------------
         -- For all ACTUAL year basis --
         -------------------------------
         if substr(method,1,6) = 'ACTUAL' then
            num_days := l_end_date - l_start_date;
            year_basis := 365;

            if method = 'ACTUAL360' then
               year_basis := 360;
            elsif method = 'ACTUAL365' then
               year_basis := 365;
            elsif method = 'ACTUAL365L' then
               -- if the "to year" is a leap year use 366 day count basis. Otherwise, use 365
               if to_char(last_day(to_date('01/02'||to_char(l_end_date,'YYYY'),'DD/MM/YYYY')),'DD') = '29' then
                  year_basis:=366;
               else
                  year_basis:=365;
               end if;
            elsif method = 'ACTUAL/ACTUAL' then

            /***************************************************************/
            /* Bug 3887142. Correct Actual/Actual calculation for IG only. */
            /***************************************************************/
               If l_end_year = l_start_year then -- same year. Determine whether it's leap year.
                  if to_char(last_day(to_date('01/02'||to_char(l_end_date,'YYYY'),
                     'DD/MM/YYYY')),'DD') = '29' then
                     year_basis := 366;
                  else
                     year_basis := 365;
                  end if;
               else
                  if to_char(last_day(to_date('01/02'||to_char(l_start_date,'YYYY'),
                     'DD/MM/YYYY')),'DD') = '29' then
                     IF day_count_type='B' AND first_trans_flag ='Y' THEN
                        start_year_basis := (to_date('1/1/'||to_char(l_start_year+1),'DD/MM/YYYY')                                - l_start_date + 1) /366;
                     else
                        start_year_basis := (to_date('1/1/'||to_char(l_start_year+1),'DD/MM/YYYY')
                                - l_start_date) /366;
                     end if;
                  else
                     IF day_count_type='B' AND first_trans_flag ='Y' THEN
                        start_year_basis := (to_date('1/1/'||to_char(l_start_year+1),'DD/MM/YYYY')                                    - l_start_date + 1) / 365;
                     else
                        start_year_basis := (to_date('1/1/'||to_char(l_start_year+1),'DD/MM/YYYY')                                    - l_start_date) / 365;
                     end if;
                  end if;

                  if to_char(last_day(to_date('01/02'||to_char(l_end_date,'YYYY'),
                     'DD/MM/YYYY')),'DD') = '29' then
                     end_year_basis := (l_end_date - to_date('1/1/'||to_char(l_end_year),
                                        'DD/MM/YYYY')) / 366;
                  else
                     end_year_basis := (l_end_date - to_date('1/1/'||to_char(l_end_year),
                                        'DD/MM/YYYY')) / 365;
                  end if;

                  IF day_count_type='B' AND first_trans_flag ='Y' THEN
                      l_total_days := num_days +1;
                  else
                      l_total_days := num_days;
                  END IF;

                   Year_basis := l_total_days / (start_year_basis + (l_total_year -1)
                                 + end_year_basis);
                End if;
	    End if;

            -------------------------------
            -- Interest Override feature --
            -- Adde Day count type logic --
            -------------------------------
            IF day_count_type='B' AND first_trans_flag ='Y' THEN
               num_days := num_days +1;
            END IF;
         ------------------------------
         -- For all other year basis --
         ------------------------------
         else

            /*-------------------------------------------------------------------------------------------*/
            /* AW 2113171       This date is adjusted when called in CALCULATE_ACCRUAL_AMORTISATION.     */
            /* Need to add one day back to it for FORWARD, and then adjust later in num_days
(see below).*/
            /* The 'fwd_adjust' parameter is used 30/360, 30E/360, 30E+/360 calculations.
            */
            /* If it is 1, then it is Forward, if it is 0, then it is Arrear.
            */
            /*-------------------------------------------------------------------------------------------*/
               l_start_date := start_date + nvl(fwd_adjust,0);
            /*-------------------------------------------------------------------------------------------*/

            -- Calculate over a 360 basis based on different calc methods
            year_basis :=360;

            if method = '30/' then
               if to_number(to_char(start_date + nvl(fwd_adjust,0),'DD')) = 31 then
-- AW 2113171
                  -- make start date = 30th ie add 1 day
                  l_start_date := start_date + nvl(fwd_adjust,0) - 1;
-- AW 2113171
               end if;
               if to_number(to_char(end_date,'DD')) = 31 then
                  if to_number(to_char(start_date + nvl(fwd_adjust,0),'DD')) in(30,31) then
-- AW 2113171
                     -- make end date = 30th if end date = 31st
                     -- only if start date is 30th or 31st ie minus 1 day from calc
                     l_end_date := end_date  - 1;
                  end if;
               end if;
            elsif method = '30E/' then
               if to_number(to_char(start_date + nvl(fwd_adjust,0),'DD')) = 31 then
-- AW 2113171
                  -- make start date = 30th ie add 1 day
                  l_start_date := start_date + nvl(fwd_adjust,0)  - 1;
-- AW 2113171
               end if;
               if to_number(to_char(end_date,'DD')) = 31 then
                  -- make end date = 30th ie minus 1 day
                  l_end_date := end_date - 1;
               end if;
            elsif method = '30E+/' then
               if to_number(to_char(start_date + nvl(fwd_adjust,0),'DD')) = 31 then
-- AW 2113171
                  -- make start date = 30th ie add 1 day
                  l_start_date := start_date + nvl(fwd_adjust,0)  - 1;
-- AW 2113171
               end if;
               if to_number(to_char(end_date,'DD')) = 31 then
                  -- make end date = 1st of the next month
                  l_end_date := end_date + 1;
               end if;
            end if;

            -- Calculate based on basic 30/360 method
            --with the above modifications
            num_days := to_number(to_char(l_end_date,'DD')) -
                        to_number(to_char(l_start_date,'DD')) +
                        (30 * (
                        to_number(to_char(l_end_date,'MM')) -
                        to_number(to_char(l_start_date,'MM')))) +
                        (360 * (
                        to_number(to_char(l_end_date,'YYYY')) -
                        to_number(to_char(l_start_date,'YYYY'))));

            /*-----------------------------------------------*/
            /* AW 2113171                                    */
            /*-----------------------------------------------*/
             num_days := num_days + nvl(fwd_adjust,0);
            /*-----------------------------------------------*/

         end if;

      end if;

   end if;

end CALC_DAYS_RUN_IG;
-------------

/* Bug 2358592 - this procedure is now a stub function for the similar procedure found in xtr_mm_covers */
PROCEDURE CALCULATE_BOND_PRICE_YIELD(p_bond_issue_code        	IN VARCHAR2,
			             p_settlement_date        	IN DATE,
				     p_ex_cum_next_coupon    	IN VARCHAR2,-- EX,CUM
				     p_calculate_yield_or_price	IN VARCHAR2,-- Y,P
				     p_yield                  	IN OUT NOCOPY NUMBER,
				     p_accrued_interest    	IN OUT NOCOPY NUMBER,
				     p_clean_price            	IN OUT NOCOPY NUMBER,
				     p_dirty_price           	IN OUT NOCOPY NUMBER,
				     p_input_or_calculator	IN VARCHAR2, -- C,I
				     p_commence_date		IN DATE,
				     p_maturity_date		IN DATE,
			             p_prev_coupon_date        	IN DATE,
			             p_next_coupon_date        	IN DATE,
				     p_calc_type		IN VARCHAR2,
				     p_year_calc_type		IN VARCHAR2,
				     p_accrued_int_calc_basis	IN VARCHAR2,
				     p_coupon_freq		IN NUMBER,
                                     p_calc_rounding            IN NUMBER,
				     p_price_rounding           IN NUMBER,
                                     p_price_round_type         IN VARCHAR2,
				     p_yield_rounding		IN NUMBER,
				     p_yield_round_type         IN VARCHAR2,
				     p_coupon_rate		IN NUMBER,
				     p_num_coupons_remain	IN NUMBER,
                                     p_day_count_type	        IN VARCHAR2,
                                     p_first_trans_flag		IN VARCHAR2,
				     p_deal_subtype		IN VARCHAR2,
				     p_currency     	        IN VARCHAR2,
				     p_face_value  		IN NUMBER,
				     p_consideration		IN NUMBER,
				     p_rounding_type		IN VARCHAR2) IS

p_py_in                              XTR_MM_COVERS.BOND_PRICE_YIELD_IN_REC_TYPE;
p_py_out                             XTR_MM_COVERS.BOND_PRICE_YIELD_OUT_REC_TYPE;

BEGIN
p_py_in.p_bond_issue_code:=          p_bond_issue_code;
p_py_in.p_settlement_date:=          p_settlement_date;
p_py_in.p_ex_cum_next_coupon:=       p_ex_cum_next_coupon;
p_py_in.p_calculate_yield_or_price:= p_calculate_yield_or_price;
p_py_in.p_yield:=                    p_yield;
p_py_in.p_accrued_interest:=         p_accrued_interest;
p_py_in.p_clean_price:=              p_clean_price;
p_py_in.p_dirty_price:=              p_dirty_price;
p_py_in.p_input_or_calculator:=      p_input_or_calculator;
p_py_in.p_commence_date:=            p_commence_date;
p_py_in.p_maturity_date:=            p_maturity_date;
p_py_in.p_prev_coupon_date:=         p_prev_coupon_date;
p_py_in.p_next_coupon_date:=         p_next_coupon_date;
p_py_in.p_calc_type:=                p_calc_type;
p_py_in.p_year_calc_type:=           p_year_calc_type;
p_py_in.p_accrued_int_calc_basis:=   p_accrued_int_calc_basis;
p_py_in.p_coupon_freq:=              p_coupon_freq;
p_py_in.p_calc_rounding:=            p_calc_rounding;
p_py_in.p_price_rounding:=           p_price_rounding;
p_py_in.p_price_round_type:=         p_price_round_type;
p_py_in.p_yield_rounding:=           p_yield_rounding;
p_py_in.p_yield_round_type:=         p_yield_round_type;
p_py_in.p_coupon_rate:=              p_coupon_rate;
p_py_in.p_num_coupons_remain:=       p_num_coupons_remain;
p_py_in.p_day_count_type:=           p_day_count_type;
p_py_in.p_first_trans_flag:=         p_first_trans_flag;
p_py_in.p_deal_subtype:=             p_deal_subtype;


p_py_in.p_currency                := p_currency;             -- COMPOUND COUPON
p_py_in.p_face_value              := p_face_value;           -- COMPOUND COUPON
p_py_in.p_consideration           := p_consideration;        -- COMPOUND COUPON
p_py_in.p_rounding_type           := p_rounding_type;        -- COMPOUND COUPON

  XTR_MM_COVERS.CALCULATE_BOND_PRICE_YIELD(p_py_in,p_py_out);

  p_yield:=                          p_py_out.p_yield;
  p_accrued_interest:=               p_py_out.p_accrued_interest;
  p_clean_price:=                    p_py_out.p_clean_price;
  p_dirty_price:=                    p_py_out.p_dirty_price;

END CALCULATE_BOND_PRICE_YIELD;


/*  Procedure to calculate the coupon amounts. */

PROCEDURE Calculate_Bond_Coupon_Amounts (
		p_bond_issue_code        	IN VARCHAR2,
		p_next_coupon_date		IN DATE,
		p_settlement_date        	IN DATE,
		p_deal_number			IN NUMBER,
		p_deal_date			IN DATE,
		p_company_code			IN VARCHAR2,
		p_cparty_code			IN VARCHAR2,
		p_dealer_code			IN VARCHAR2,
		p_status_code			IN VARCHAR2,
		p_client_code			IN VARCHAR2,
		p_acceptor_code			IN VARCHAR2,
		p_maturity_account_number	IN VARCHAR2,
		p_maturity_amount		IN NUMBER,
		p_deal_subtype			IN VARCHAR2,
		p_product_type			IN VARCHAR2,
		p_portfolio_code		IN VARCHAR2,
		p_rounding_type                 IN VARCHAR2,
                p_day_count_type                IN VARCHAR2,
		p_income_tax_ref		IN VARCHAR2,
		p_income_tax_rate		IN OUT NOCOPY NUMBER,
		p_income_tax_settled_ref	IN OUT NOCOPY NUMBER) is

	l_last_coupon_date	date;
	l_coupon_date		date := p_next_coupon_date;
	l_bond_start_date	date;
	l_bond_maturity_date	date;
	l_precision		number;
	l_ext_precision		number;
	l_min_acct_unit		number;
	l_coupon_amt		number;
	l_currency		varchar2(15);
	l_coupon_rate		number;
	l_frequency		number;
	l_year_calc_type	varchar2(15);
	l_year_basis		number;
	l_nbr_days_in_period	number;
	l_transaction_number	number;
	l_fnd_user		number(15);
	l_xtr_user		varchar2(30);
	errnum			number;
	errmsg			varchar2(100);
	l_errmsg		varchar2(120);
	l_calc_type		varchar2(15);
	-- Added for Interest Override
	l_original_amount       NUMBER;
	l_first_trans_flag      VARCHAR2(1);
	--
	l_income_tax_out	NUMBER;
	l_dummy_num		NUMBER;
	l_dummy_char		VARCHAR2(20);
        l_tax_settle_method	VARCHAR2(15);
	-- Bug 7023669 For Short First Coupon Fix Start
	l_flg_first_flat_coupon VARCHAR2(1) := 'N';
	l_orig_freq NUMBER;
	l_first_orig_coupon_date DATE;
	l_chk_commence DATE;
	l_default_first_date DATE ;
	-- Bug 7023669 For Short First Coupon Fix End



       one_step_rec XTR_FPS2_P.ONE_STEP_REC_TYPE;
       l_one_step_error VARCHAR2(40);
--
	cursor BOND_DETAILS is
	select currency,
	       coupon_rate,
	       no_of_coupons_per_year,
	       maturity_date,
	       year_calc_type,
	       commence_date,
	       calc_type
	from xtr_bond_issues
	where bond_issue_code = p_bond_issue_code;
--
       -- Bug 7023669 For Short First Coupon Fix Start
       cursor CHK_OVERRIDE is
       select commence_date,no_of_coupons_per_year,
       first_coupon_date
        from xtr_bond_issues
	where bond_issue_code = p_bond_issue_code;
	-- Bug 7023669 For Short First Coupon Fix End


--
	cursor GET_NEXT_COUPON_DATE is
	select coupon_date,
	due_date,rate --bug 2804548
	from xtr_bond_coupon_dates
	where bond_issue_code = p_bond_issue_code
	and coupon_date > l_coupon_date
	order by coupon_date;
--
	cursor GET_LAST_COUPON_DATE is
	select max(coupon_date)
	from xtr_bond_coupon_dates
	where bond_issue_code = p_bond_issue_code
	and coupon_date < p_next_coupon_date;
--
        cursor FIND_USER is
        select dealer_code
        from xtr_dealer_codes_v
        where user_id = l_fnd_user;
--
 	cursor GET_SETTLE_METHOD(p_tax_code VARCHAR2) is
	select TAX_SETTLE_METHOD
  	from   XTR_TAX_BROKERAGE_SETUP
  	where  REFERENCE_CODE = p_tax_code;
--
        cursor TOTAL_FULL_COUPONS (p_issue_code VARCHAR2) is
        select count(*)-1, min(coupon_date)
        from   xtr_bond_coupon_dates
        where  bond_issue_code = p_issue_code;

        l_no_quasi_coupon       NUMBER;
        l_total_coupon_days     NUMBER;
        l_odd_coupon_start      DATE;
        l_odd_coupon_maturity   DATE;
        l_comp_coupon           XTR_MM_COVERS.COMPOUND_CPN_REC_TYPE;

        --bug 2804548
        cursor get_cpn_info(p_cpn_date DATE,
			p_bond_issue_code VARCHAR2) is
           select due_date,rate
           from xtr_bond_coupon_dates
           where bond_issue_code=p_bond_issue_code
           and coupon_date=p_cpn_date;

        v_due_date DATE;

Begin

   /* Setup user info. */
   l_fnd_user := fnd_global.user_id;
   Open FIND_USER;
   Fetch FIND_USER into l_xtr_user;
   If (FIND_USER%NOTFOUND) then
      l_xtr_user := null;
   End If;
   Close FIND_USER;

   /* Obtain pertinent info on bond. */

   Open  BOND_DETAILS;
   Fetch BOND_DETAILS into l_currency, l_coupon_rate, l_frequency, l_bond_maturity_date,
                           l_year_calc_type, l_bond_start_date, l_calc_type;
   If (BOND_DETAILS%NOTFOUND) then
      Close BOND_DETAILS;
      FND_MESSAGE.Set_Name('XTR','XTR_2171');
      APP_EXCEPTION.Raise_Exception;
   End If;
   Close BOND_DETAILS;

   -- Bug 7023669 For Short First Coupon Fix Start
   open CHK_OVERRIDE ;
   fetch CHK_OVERRIDE into l_chk_commence,l_orig_freq,l_first_orig_coupon_date;
   If (CHK_OVERRIDE%NOTFOUND) then
      Close CHK_OVERRIDE;
      FND_MESSAGE.Set_Name('XTR','XTR_2171');
      APP_EXCEPTION.Raise_Exception;
   End If;
   close CHK_OVERRIDE;

if to_char(l_chk_commence,'MM') =  to_char(l_chk_commence-3,'MM') then
  l_default_first_date := add_months(l_chk_commence-3, (12 / l_orig_freq)) +3;
else
  l_default_first_date := add_months(l_chk_commence, (12 / l_orig_freq)) ;
end if;

 -- Bug 7023669 For Short First Coupon Fix End

 /* Obtain currency precision for bond. */

   FND_CURRENCY.Get_Info (
   			l_currency,
   			l_precision,
   			l_ext_precision,
   			l_min_acct_unit);

   /* Obtain last coupon date before the next coupon date.
      In the case of an 'EX' status bond, this last coupon date is > the settlement date.
      In the case of an 'CUM' status bond, this last coupon date is <= the settlement date.
      We need to determine this date in order to compute the 'nbr of days' between the coupon
      period, with consideration given for the days calc method. */

   Open  GET_LAST_COUPON_DATE;
   Fetch GET_LAST_COUPON_DATE into l_last_coupon_date;
   If (l_last_coupon_date is NULL) then

      -- NOTE:  Can't check for cursor %NOTFOUND since the 'max' will return a NULL row,
      --        which is considered a 'found' case.

      Close GET_LAST_COUPON_DATE;
      l_last_coupon_date := nvl(l_bond_start_date,p_settlement_date);
      -- Bug 7023669 For Short First Coupon Fix Start
      l_flg_first_flat_coupon := 'Y' ;
      -- Bug 7023669 For Short First Coupon Fix End
   Else
      Close GET_LAST_COUPON_DATE;
   End If;

   /* Open cursor to obtain next coupon date for process in loop. */

   Open GET_NEXT_COUPON_DATE;

   /* Compute coupon amounts and populate XTR_ROLLOVER_TRANSACTION and XTR_DEAL_DATE_AMOUNTS tables. */
   /* NOTE: Start transaction number off at 2 since the 'commence' tasks' transaction number
            would have been set to 1 when the bond deal was committed. */

   l_transaction_number := 1;

   --start bug 2804548
   open get_cpn_info(l_coupon_date,p_bond_issue_code);
   fetch get_cpn_info into v_due_date,l_coupon_rate;
   close get_cpn_info;
   --end bug 2804548

   LOOP
      l_transaction_number := l_transaction_number + 1;

      -- Added for Interest Override
      IF l_transaction_number = 2 and l_calc_type <> 'COMPOUND COUPON' THEN
	 l_first_trans_flag :='Y';
      ELSE
	 l_first_trans_flag := NULL;
      END IF;
      --

      If (l_calc_type in ('VARIABLE COUPON','FL IRREGULAR')) then

         /* Need to compute # of days between the coupon period and determine # of days in the year
            (l_year_basis) based on the year_calc_type. */

         -- Bug 2358549.
         -- Changed call to Calc_Days_Run_C from Calc_Days_Run in order
         -- to properly handle the year calc type of 'Actual/Actual-Bond'
         -- which was introduced in patchset C.

         XTR_CALC_P.Calc_Days_Run_C (
   			l_last_coupon_date,
	   		l_coupon_date,
   			l_year_calc_type,
   			l_frequency,
   			l_nbr_days_in_period,
			l_year_basis,
			NULL,
		        p_day_count_type,  -- Added for Override feature
			l_first_trans_flag --  Added for Override feature
				   );

	 -- Changed for Interest Override
         -- l_coupon_amt := round((p_maturity_amount * (l_coupon_rate / 100) * (l_nbr_days_in_period / l_year_basis)), l_precision);
         l_original_amount := xtr_fps2_p.interest_round((p_maturity_amount * (l_coupon_rate / 100) * (l_nbr_days_in_period / l_year_basis)), l_precision,p_rounding_type);
	  l_coupon_amt := l_original_amount;

      Elsif (l_calc_type = 'COMPOUND COUPON') then

         l_coupon_date      := l_bond_maturity_date;
         l_no_quasi_coupon  := 0;
         l_last_coupon_date := nvl(l_bond_start_date,p_settlement_date);  -- l_bond_start_date should have a value

         open  TOTAL_FULL_COUPONS (p_bond_issue_code);
         fetch TOTAL_FULL_COUPONS into l_no_quasi_coupon, l_odd_coupon_maturity;
         close TOTAL_FULL_COUPONS;

         l_odd_coupon_start := XTR_MM_COVERS.ODD_COUPON_DATE(l_bond_start_date,l_coupon_date,l_frequency,'S');

         l_comp_coupon.p_bond_start_date       := l_bond_start_date;
         l_comp_coupon.p_odd_coupon_start      := l_odd_coupon_start;
         l_comp_coupon.p_odd_coupon_maturity   := l_odd_coupon_maturity;
         l_comp_coupon.p_full_coupon           := l_no_quasi_coupon;
         l_comp_coupon.p_coupon_rate           := l_coupon_rate;
         l_comp_coupon.p_maturity_amount       := p_maturity_amount;  -- Face Value
         l_comp_coupon.p_precision             := l_precision;
         l_comp_coupon.p_rounding_type         := p_rounding_type;
         l_comp_coupon.p_year_calc_type        := l_year_calc_type;
         l_comp_coupon.p_frequency             := l_frequency;
         l_comp_coupon.p_day_count_type        := p_day_count_type;
         l_comp_coupon.p_amount_redemption_ind := 'A';

         l_original_amount := XTR_MM_COVERS.CALC_COMPOUND_COUPON_AMT(l_comp_coupon);

         l_coupon_amt := l_original_amount;

      Else
         /* Flat coupons do not need to take day count basis into consideration. */

         /* We need to call this to calculate NO_OF_DAYS even though we are not using */
         /* in coupon calculation.*/

         -- Bug 2358549.
         -- Changed call from Calc_Days_Run to Calc_Days_Run_C in order
         -- to properly handle the year calc type of 'Actual/Actual-Bond'
         -- which was introduced in patchset C.

         XTR_CALC_P.Calc_Days_Run_C (
   			l_last_coupon_date,
	   		l_coupon_date,
   			l_year_calc_type,
   			l_frequency,
   			l_nbr_days_in_period,
			l_year_basis,
			NULL,
		        p_day_count_type,  -- Added for Override feature
			l_first_trans_flag --  Added for Override feature
			);
	 -- Changed for Interest Override
         -- l_coupon_amt := round((p_maturity_amount * (l_coupon_rate / 100) / nvl(l_frequency,2)), l_precision);
	 l_original_amount := xtr_fps2_p.interest_round((p_maturity_amount * (l_coupon_rate / 100) / nvl(l_frequency,2)),
					     l_precision,p_rounding_type);
	 l_coupon_amt := l_original_amount;
	-- Bug 7023669 For Short First Coupon Fix Start
	if ( l_flg_first_flat_coupon = 'Y' and  l_default_first_date <> l_first_orig_coupon_date )
        then
	  l_flg_first_flat_coupon := 'N' ;
	  l_original_amount := xtr_fps2_p.interest_round((p_maturity_amount * (l_coupon_rate / 100) * (l_nbr_days_in_period / l_year_basis)), l_precision,p_rounding_type);
	  l_coupon_amt := l_original_amount;
        end if;
	-- Bug 7023669 For Short First Coupon Fix End

      End If;

      -- added by fhu 7/16/2002
      -- calculate taxes
      IF (p_income_tax_ref IS NOT NULL) THEN
           XTR_FPS1_P.calc_tax_amount('BOND',
				 p_deal_date,
				 null,
				 p_income_tax_ref,
				 l_currency,
				 null,
				 0,
				 0,
				 null,
				 l_dummy_num,
				 l_coupon_amt,
				 p_income_tax_rate,
				 l_dummy_num,
				 l_income_tax_out,
				 l_dummy_num,
				 l_dummy_char);
       END IF;

  -- add by fhu 7/18/2002 for tax witholding project
  -- check settle method for principal tax, generate one-step if needed
     IF (p_income_tax_ref IS NOT NULL) THEN
        OPEN get_settle_method(p_income_tax_ref);
        FETCH get_settle_method INTO l_tax_settle_method;
        IF (l_tax_settle_method = 'OSG') THEN
	  one_step_rec.p_source := 'TAX';
   	  one_step_rec.p_schedule_code := p_income_tax_ref;
	  one_step_rec.p_currency := l_currency;
	  one_step_rec.p_amount := l_income_tax_out;--bug 2488604
	  one_step_rec.p_settlement_date := v_due_date;--bug 2488604
	  one_step_rec.p_settlement_account := p_maturity_account_number;
	  one_step_rec.p_company_code := p_company_code;
	  one_step_rec.p_cparty_code := p_cparty_code;
	  one_step_rec.p_error := l_one_step_error;
	  one_step_rec.p_settle_method := l_tax_settle_method;
	  one_step_rec.p_exp_number := p_income_tax_settled_ref;
	  XTR_FPS2_P.one_step_settlement(one_step_rec);
	  p_income_tax_settled_ref := one_step_rec.p_exp_number;
        END IF;
        CLOSE get_settle_method;
      END IF;

      Begin
         Insert into XTR_ROLLOVER_TRANSACTIONS (
      			deal_number,
      			transaction_number,
      			deal_type,
      			start_date,
      			no_of_days,
      			maturity_date,
      			interest_rate,
      			interest,
			orig_coupon_amount,
      			deal_subtype,
      			product_type,
      			portfolio_code,
      			company_code,
      			cparty_code,
      			client_code,
      			currency,
      			deal_date,
      			status_code,
      			created_by,
      			created_on,
			settle_date,
			original_amount,  --Added for Interest Override
			tax_code,
			tax_rate,
			tax_amount,
			tax_settled_reference,
			coupon_due_date --bug 2804548
		       )
            Values (p_deal_number,
		    l_transaction_number,
		    'BOND',
		    l_last_coupon_date,
		    l_nbr_days_in_period,
		    l_coupon_date,
      		    l_coupon_rate,
      		    l_coupon_amt,
      		    l_coupon_amt,
      		    p_deal_subtype,
      		    p_product_type,
      		    p_portfolio_code,
      		    p_company_code,
      		    p_cparty_code,
      		    p_client_code,
      		    l_currency,
      		    p_deal_date,
      		    'CURRENT',
      		    l_xtr_user,
      		    sysdate,
      		    v_due_date,
		    l_original_amount,-- Added for Interest Override
		    p_income_tax_ref,
		    p_income_tax_rate,
		    l_income_tax_out,
		    p_income_tax_settled_ref,
		    v_due_date
		    );

      EXCEPTION
      WHEN OTHERS then
         errnum := SQLCODE;
         errmsg := SUBSTR(SQLERRM,1,100);
         l_errmsg := to_char(errnum) || ' - ' || errmsg;
         FND_MESSAGE.Set_Name ('XTR', 'XTR_2172');
         FND_MESSAGE.Set_Token ('TABLE', 'XTR_ROLLOVER_TRANSACTIONS');
         FND_MESSAGE.Set_Token ('ERRCODE_TEXT', l_errmsg);
         APP_EXCEPTION.Raise_Exception;
      END;

      BEGIN
	 -- if tax settle method = Netted Income Amount,
	 -- then net coupon amount with tax amount
	 -- also need to insert new tax row
	 IF (l_tax_settle_method IS NOT NULL) THEN
	    IF (l_tax_settle_method = 'NIA') THEN
		-- for netting the coupon interest
	        l_coupon_amt := l_coupon_amt - l_income_tax_out;
		-- insert new row with just tax
         	Insert into XTR_DEAL_DATE_AMOUNTS (
      			deal_type,
      			amount_type,
      			date_type,
      			deal_number,
      			transaction_number,
      			transaction_date,
      			currency,
      			amount,
      			amount_date,
      			transaction_rate,
      			cashflow_amount,
      			company_code,
      			deal_subtype,
			product_type,
			status_code,
			client_code,
			portfolio_code,
    			cparty_code,
      			settle,
			dealer_code)
		Values ('BOND',
			'TAX',
			'INCUR',
			p_deal_number,
			l_transaction_number,
			l_coupon_date,
			l_currency,
			l_income_tax_out,
			l_coupon_date,
			0, -- ONC currently saves tax rate as 0
			0, -- ONC currently saves cashflow amount as 0
			p_company_code,
			p_deal_subtype,
			p_product_type,
			'CURRENT',
			p_client_code,
			nvl(p_portfolio_code, 'NOTAPPL'),
			p_cparty_code,
			'N',
			p_dealer_code);

	    END IF;
	 END IF;
         Insert into XTR_DEAL_DATE_AMOUNTS (
      			deal_type,
      			amount_type,
      			date_type,
      			deal_number,
      			transaction_number,
      			transaction_date,
      			currency,
      			amount,
      			amount_date,
      			transaction_rate,
      			cashflow_amount,
      			company_code,
      			account_no,
      			status_code,
      			portfolio_code,
      			dealer_code,
      			client_code,
      			deal_subtype,
      			cparty_code,
      			settle,
      			product_type)
         Values ('BOND',
              	'COUPON',
              	'COUPON',
              	p_deal_number,
              	l_transaction_number,
              	p_deal_date,
              	l_currency,
              	l_coupon_amt,
              	v_due_date,--bug 2804548
              	l_coupon_rate,
              	decode(p_deal_subtype,'BUY',1,-1) * l_coupon_amt,
              	p_company_code,
              	p_maturity_account_number,
              	p_status_code,
              	p_portfolio_code,
              	p_dealer_code,
              	p_client_code,
              	p_deal_subtype,
              	p_acceptor_code,
              	'N',
              	p_product_type);
      EXCEPTION
      WHEN OTHERS then
         errnum := SQLCODE;
         errmsg := SUBSTR(SQLERRM,1,100);
         l_errmsg := to_char(errnum) || '. ' || errmsg;
         FND_MESSAGE.Set_Name ('XTR', 'XTR_2172');
         FND_MESSAGE.Set_Token ('TABLE', 'XTR_DEAL_DATE_AMOUNTS');
         FND_MESSAGE.Set_Token ('ERRCODE_TEXT', l_errmsg);
         APP_EXCEPTION.Raise_Exception;
      END;

      l_last_coupon_date := l_coupon_date;
      Fetch GET_NEXT_COUPON_DATE into l_coupon_date,v_due_date,l_coupon_rate;

   EXIT WHEN (GET_NEXT_COUPON_DATE%NOTFOUND) or (l_coupon_date > l_bond_maturity_date) or
             (l_calc_type = 'COMPOUND COUPON');
   END LOOP;

   Close GET_NEXT_COUPON_DATE;
End Calculate_Bond_Coupon_Amounts;



PROCEDURE RECALC_DT_DETAILS (
                             l_deal_no        		IN NUMBER,
                             l_least_inserted 		IN VARCHAR2,
                             l_ref_date       		IN DATE,
                             l_trans_num      		IN NUMBER,
                             l_last_row       		IN VARCHAR2,
			     g_chk_bal        		IN VARCHAR2,
                             g_expected_balance_bf 	IN OUT NOCOPY NUMBER,
                             g_balance_out_bf		IN OUT NOCOPY NUMBER,
                             g_accum_interest_bf       	IN OUT NOCOPY NUMBER,
                             g_principal_adjust	       	IN OUT NOCOPY NUMBER,
			     c_principal_action		IN VARCHAR2,
			     c_principal_amount_type	IN VARCHAR2,
			     c_principal_adjust		IN NUMBER,
			     c_writoff_int		IN NUMBER,
			     c_increase_effective_from  IN DATE,
			     l_rounding_type            IN VARCHAR2, --Add Interest Override
			     l_day_count_type           IN VARCHAR2) IS  --Add Interest Override

  l_deal_date      	DATE;
  l_company        	VARCHAR2(7);
  l_subtype        	VARCHAR2(7);
  l_product        	VARCHAR2(10);
  l_portfolio      	VARCHAR2(7);
  l_ccy            	VARCHAR2(15);
  l_maturity       	DATE;
  l_settle_acct    	VARCHAR2(20);
  l_cparty         	VARCHAR2(7);
  l_client         	VARCHAR2(7);
  l_dealer         	VARCHAR2(10);
  l_cparty_acct    	VARCHAR2(20);
  l_year_calc_type 	VARCHAR2(15);
  l_limit_code     	VARCHAR2(7);
  l_internal_ticket_no	VARCHAR2(15);
  l_face_value_amount	NUMBER;
  l_cparty_ref		VARCHAR2(7);

  chk_off          VARCHAR2(1);
  l_comments       VARCHAR2(30);
  l_nill_date      DATE;
  l_compound       VARCHAR2(10);
  l_prv_row_exists VARCHAR2(1);
  l_start_date     DATE;
  l_prin_decr      NUMBER;
  new_exp_bal      NUMBER;
  new_accum_int    NUMBER;
  new_balbf        NUMBER;
  new_start_date   DATE;
  year_basis       NUMBER;
  no_of_days       NUMBER;
  rounding_fac     NUMBER;
  l_hce_rate       NUMBER;
  hce_interest     NUMBER;
  hce_settled      NUMBER;
  hce_accum_int_bf NUMBER;
  hce_decr         NUMBER;
  hce_accum_int    NUMBER;
  hce_balbf        NUMBER;
  hce_balos        NUMBER;
  hce_princ        NUMBER;
  hce_due          NUMBER;
  l_exp_int        NUMBER;
  l_cum_int        NUMBER;
  l_prin_adj       NUMBER;
  l_mark           VARCHAR2(1);
  cnt              NUMBER;

-- 3958736
 l_dual_authorisation_by xtr_deals.dual_authorisation_by%type ;
 l_dual_authorisation_on xtr_deals.dual_authorisation_on%type ;

  cursor THIS_DEAL is
    select DEAL_DATE, COMPANY_CODE, DEAL_SUBTYPE,
           PRODUCT_TYPE, PORTFOLIO_CODE, CURRENCY,
           MATURITY_DATE, SETTLE_ACCOUNT_NO, CPARTY_CODE,
           CLIENT_CODE, DEALER_CODE, YEAR_CALC_TYPE,
	   LIMIT_CODE, INTERNAL_TICKET_NO,
           FACE_VALUE_AMOUNT, cparty_ref,
           start_date,	   --Add Interest Override
           DUAL_AUTHORISATION_BY, -- bug 3958736
           DUAL_AUTHORISATION_ON
    from   XTR_DEALS
    where  DEAL_NO = l_deal_no
    and    DEAL_TYPE = 'RTMM';

  cursor CHK_REF is
    select ACCOUNT_NUMBER
    from  XTR_BANK_ACCOUNTS_V
    where PARTY_CODE = l_cparty
    and   BANK_SHORT_CODE = l_cparty_ref
    and   CURRENCY = l_ccy;

  cursor RND_YR is
    select ROUNDING_FACTOR,YEAR_BASIS,nvl(HCE_RATE,1) HCE_RATE
    from  XTR_MASTER_CURRENCIES_V
    where CURRENCY = l_ccy;

  cursor START_ROW is
    select max(START_DATE)
    from XTR_ROLLOVER_TRANSACTIONS
    where DEAL_NUMBER = l_deal_no
    and START_DATE <= l_ref_date  --- <
    and STATUS_CODE = 'CURRENT'
    and TRANSACTION_NUMBER <>l_trans_num;

  cursor LAST_ROW is
    select rowid
    from XTR_ROLLOVER_TRANSACTIONS
    where DEAL_NUMBER = l_deal_no
    and START_DATE >= l_start_date
    and (MATURITY_DATE > l_start_date or l_last_row='Y')     --- add
    and STATUS_CODE = 'CURRENT'
    -- and ((nvl(g_chk_bal,'N')='Y' and TRANSACTION_NUMBER=l_trans_num)
    --	or nvl(g_chk_bal,'N')='N')
    order by START_DATE desc,TRANSACTION_NUMBER desc;

  last_pmt LAST_ROW%ROWTYPE;

  cursor DT_ROW is
    select START_DATE,MATURITY_DATE,NO_OF_DAYS,BALANCE_OUT_BF,
           BALANCE_OUT,PRINCIPAL_ADJUST,INTEREST_RATE,INTEREST,
           INTEREST_SETTLED,PRINCIPAL_ACTION,TRANSACTION_NUMBER,
           SETTLE_DATE,ACCUM_INTEREST_BF,PI_AMOUNT_DUE,PI_AMOUNT_RECEIVED,
           ACCUM_INTEREST,ROWID,ADJUSTED_BALANCE,COMMENTS,
           EXPECTED_BALANCE_BF,EXPECTED_BALANCE_OUT,PRINCIPAL_AMOUNT_TYPE,
           ENDORSER_CODE,RATE_FIXING_DATE
    from XTR_ROLLOVER_TRANSACTIONS
    where DEAL_NUMBER = l_deal_no
    and START_DATE >= l_start_date
    and (MATURITY_DATE > l_start_date or l_last_row = 'Y')
    and STATUS_CODE = 'CURRENT'
    -- and ((nvl(g_chk_bal,'N') = 'Y' and TRANSACTION_NUMBER = l_trans_num)
    --      or nvl(g_chk_bal,'N') = 'N')
    order by START_DATE asc,TRANSACTION_NUMBER asc
    for UPDATE OF START_DATE; --lock all rows until commit

  pmt DT_ROW%ROWTYPE;

  cursor COMP is
    select b.INTEREST_ACTION
    from XTR_DEALS_V a,
         XTR_PAYMENT_SCHEDULE_V b
    where a.DEAL_NO = l_deal_no
    and  b.PAYMENT_SCHEDULE_CODE = a.PAYMENT_SCHEDULE_CODE;

  l_date_exits varchar2(1);

  cursor chk_date_exits is
    select NULL
    from XTR_ROLLOVER_TRANSACTIONS
    where DEAL_NUMBER = l_deal_no
    and (START_DATE = l_ref_date or MATURITY_DATE = l_ref_date)
    and transaction_number <>l_trans_num
    order by START_DATE desc,TRANSACTION_NUMBER desc ;

  -- Add Interest Override
  l_first_trans_flag  VARCHAR2(1);
  l_max_trans_no      NUMBER;
  l_deal_start_date   DATE;
  -- End of Change

BEGIN

  open THIS_DEAL;
    fetch THIS_DEAL INTO l_deal_date, l_company, l_subtype,
                         l_product, l_portfolio, l_ccy,
                         l_maturity, l_settle_acct,l_cparty,
                         l_client, l_dealer, l_year_calc_type,
                         l_limit_code, l_internal_ticket_no,
                         l_face_value_amount, l_cparty_ref,
                         l_deal_start_date,
                         l_dual_authorisation_by,
                         l_dual_authorisation_on;

  close THIS_DEAL;

  if l_cparty_ref is NOT NULL then
    open CHK_REF;
    fetch CHK_REF into l_cparty_acct;
    if CHK_REF%NOTFOUND then
      l_cparty_acct := NULL;
    end if;
    close CHK_REF;
  end if;

  open RND_YR;
    fetch RND_YR INTO rounding_fac,year_basis,l_hce_rate;
  close RND_YR;

  open COMP;
    fetch COMP INTO l_compound;
  close COMP;

  l_hce_rate   := nvl(l_hce_rate,1);
  rounding_fac := nvl(rounding_fac,2);
  l_compound   := nvl(l_compound,'N');
  l_comments   := NULL;
  l_start_date := NULL;
  l_nill_date  := NULL;

  open START_ROW;
    fetch START_ROW INTO l_start_date;
  close START_ROW;

  -- fnd_message.debug('l_start_date = ' || l_start_date);
  -- fnd_message.debug('l_ref_date = ' || l_ref_date);
  -- fnd_message.debug(' l_trans_num = ' || l_trans_num);

  if l_start_date is NULL then
    l_start_date := l_ref_date;
    l_prv_row_exists := 'N';
  else
    l_prv_row_exists := 'Y';
  end if;


  open LAST_ROW;
    fetch LAST_ROW INTO last_pmt;
  close LAST_ROW;
  --
  --
  --
  open DT_ROW;
  l_nill_date := NULL;
  fetch DT_ROW INTO pmt;

  WHILE DT_ROW%FOUND LOOP
--Add Interest Override
    IF pmt.start_date = l_deal_start_date
      AND nvl(l_day_count_type,'F') = 'B' THEN

       SELECT MAX(transaction_number)
       INTO l_max_trans_no
       FROM xtr_rollover_transactions_v
       WHERE deal_number = l_deal_no
       AND start_date = pmt.start_date;

       IF pmt.transaction_number = Nvl(l_max_trans_no,1) THEN
         l_first_trans_flag := 'Y';
       ELSE
         l_first_trans_flag := 'N';
       END IF;
    ELSE
      l_first_trans_flag := 'N';
    END IF;
--End of Addition

    -- Reset balance bf and start date from previous row information except
    -- for the first row
    l_date_exits :=NULL;
    l_mark :='N';

    if nvl(pmt.PRINCIPAL_ACTION,'@#@') = 'DECRSE' then
      l_prin_adj := (-1) * nvl(pmt.PRINCIPAL_ADJUST,0);
    else
      l_prin_adj := nvl(pmt.PRINCIPAL_ADJUST,0);
    end if;
    --
    -- Initialize
    if DT_ROW%ROWCOUNT <> 1 then
      pmt.EXPECTED_BALANCE_BF := new_exp_bal;
      pmt.ACCUM_INTEREST_BF := new_accum_int;
      pmt.BALANCE_OUT_BF    := new_balbf;
      pmt.START_DATE        := new_start_date;
      pmt.COMMENTS          := l_comments;
    elsif DT_ROW%ROWCOUNT = 1 then
      if l_prv_row_exists = 'Y' and (nvl(l_least_inserted,'N') = 'Y' or l_trans_num = -1)
      and nvl(g_chk_bal,'N') = 'N'
      or  nvl(g_chk_bal,'N') = 'Y'                           then
         -- This is the row before the EARLIEST ROW CHANGED
         -- ie reset its maturity date to the Start date of the row changed.
         -- This is because the earliest row may have been inserted.

        if nvl(c_principal_action,'@#@') = 'DECRSE' then
          if nvl(c_principal_amount_type,'PRINFLW') = 'PRINFLW' then
            pmt.PI_AMOUNT_DUE := nvl(c_principal_adjust,0);
            l_date_exits := 'W';
            l_mark := 'Y';
          else
            pmt.PI_AMOUNT_DUE := 0;
          end if;
        elsif l_trans_num <> -1 then
          pmt.PI_AMOUNT_DUE :=0;
        end if;
        --
        if nvl(g_chk_bal,'N') = 'N' then
          pmt.PI_AMOUNT_RECEIVED := 0;
        end if;
        --
        pmt.MATURITY_DATE := l_ref_date;

        XTR_CALC_P.CALC_DAYS_RUN(pmt.START_DATE,
                      pmt.MATURITY_DATE,
                      l_year_calc_type,
                      no_of_days,
		      year_basis,
		      NULL,
		      l_day_count_type,    --Add Interest Override
		      l_first_trans_flag); --Add Interest Override

--Add Interest Override
        l_cum_int := XTR_FPS2_P.interest_round(pmt.EXPECTED_BALANCE_BF
                    + l_prin_adj
                    * pmt.INTEREST_RATE / 100
                    * (no_of_days)
                    / year_basis,rounding_fac,l_rounding_type);
--Original
--        l_cum_int := round(pmt.EXPECTED_BALANCE_BF
--                    + l_prin_adj
--                    * pmt.INTEREST_RATE / 100
--                    * (no_of_days)
--                    / year_basis,rounding_fac);
--End of Change
      else
        l_cum_int := 0;
        if nvl(c_principal_action,'@#@') = 'DECRSE'
        and nvl(c_principal_amount_type,'PRINFLW') = 'PRINFLW'
        and nvl(g_chk_bal,'N') = 'Y' then
          l_date_exits := 'W';
        end if;
      end if;
    end if;
    -- End Initialize

    -- Recalc interest amount
    l_prin_decr := 0;
    pmt.ADJUSTED_BALANCE := nvl(pmt.BALANCE_OUT_BF,0) + nvl(l_prin_adj,0);
    -- added
    XTR_CALC_P.CALC_DAYS_RUN(pmt.START_DATE,
                  pmt.MATURITY_DATE,
                  l_year_calc_type,
                  pmt.NO_OF_DAYS,
                  year_basis,
		  NULL,
                  l_day_count_type,   --Add Interest Override
                  l_first_trans_flag);--Add Interest Override

    if nvl(pmt.ADJUSTED_BALANCE,0) > 0  then

--Add Interest Override
      pmt.INTEREST := XTR_FPS2_P.interest_round(pmt.ADJUSTED_BALANCE * pmt.INTEREST_RATE / 100 *
                         pmt.NO_OF_DAYS / year_basis,rounding_fac,l_rounding_type);
--Original
--      pmt.INTEREST := round(pmt.ADJUSTED_BALANCE * pmt.INTEREST_RATE / 100 *
--                         pmt.NO_OF_DAYS / year_basis,rounding_fac);
--End of Change
    else
      pmt.INTEREST := 0;
    end if;
    --
    pmt.ACCUM_INTEREST := nvl(pmt.ACCUM_INTEREST_BF,0) + nvl(pmt.INTEREST,0);
    -- Added
    if pmt.NO_OF_DAYS = 0 and l_mark = 'N' then
      pmt.PI_AMOUNT_DUE := 0;
      pmt.PI_AMOUNT_RECEIVED := 0;
    end if;
    --
    --
    if pmt.SETTLE_DATE is NOT NULL then
      -- added if 'W' not split for decrese on different day.
      if nvl(pmt.ENDORSER_CODE,'N') = 'W' then
        l_prin_decr := pmt.PI_AMOUNT_RECEIVED;
        pmt.INTEREST_SETTLED := 0;
      else
        if pmt.PI_AMOUNT_RECEIVED >= pmt.ACCUM_INTEREST then
          l_prin_decr := pmt.PI_AMOUNT_RECEIVED - nvl(pmt.ACCUM_INTEREST,0);
          pmt.INTEREST_SETTLED := nvl(pmt.ACCUM_INTEREST,0);
          pmt.ACCUM_INTEREST := 0;
        else
          l_prin_decr := 0;
          pmt.INTEREST_SETTLED := abs(nvl(pmt.PI_AMOUNT_RECEIVED,0) - nvl(pmt.ACCUM_INTEREST,0));
          pmt.ACCUM_INTEREST := pmt.ACCUM_INTEREST - nvl(pmt.PI_AMOUNT_RECEIVED,0);
        end if;
      end if;
    else
      NULL;
    end if;
    --
    if l_compound in('C','COMPOUND') then
      pmt.BALANCE_OUT := nvl(pmt.ADJUSTED_BALANCE,0) - nvl(l_prin_decr,0) +
                     nvl(pmt.ACCUM_INTEREST,0);
      pmt.ACCUM_INTEREST := 0;
    else
      pmt.BALANCE_OUT := nvl(pmt.ADJUSTED_BALANCE,0) - nvl(l_prin_decr,0);
    end if;

    pmt.EXPECTED_BALANCE_OUT := nvl(pmt.EXPECTED_BALANCE_BF,0) +
                             nvl(l_prin_adj,0);
    if nvl(pmt.EXPECTED_BALANCE_OUT,0) > 0 then -- added

--Add Interest Override
      l_exp_int := XTR_FPS2_P.interest_round(nvl(pmt.EXPECTED_BALANCE_OUT,0) * nvl(pmt.INTEREST_RATE,0)
                     / 100 * pmt.NO_OF_DAYS / year_basis,rounding_fac,l_rounding_type);
--Original
--      l_exp_int := round(nvl(pmt.EXPECTED_BALANCE_OUT,0) *
--                   nvl(pmt.INTEREST_RATE,0)
--                     / 100 * pmt.NO_OF_DAYS / year_basis,rounding_fac);
--End of Change
    else
      l_exp_int := 0;
    end if;

    pmt.EXPECTED_BALANCE_OUT := nvl(pmt.EXPECTED_BALANCE_OUT,0)
	 		     - nvl(pmt.PI_AMOUNT_DUE,0) + nvl(l_exp_int,0);

    if nvl(pmt.EXPECTED_BALANCE_OUT, 0) < 0 then
      pmt.PI_AMOUNT_DUE :=  pmt.PI_AMOUNT_DUE + pmt.EXPECTED_BALANCE_OUT;
      pmt.EXPECTED_BALANCE_OUT := 0;
    end if;

    --
    --add
    if pmt.MATURITY_DATE = l_maturity and pmt.ROWID=last_pmt.ROWID  then
      -- Last transaction therefore make the repayment = Balance Out +
      -- Interest Due.

      pmt.PI_AMOUNT_DUE := nvl(pmt.PI_AMOUNT_DUE,0) + nvl(pmt.EXPECTED_BALANCE_OUT,0);
      pmt.EXPECTED_BALANCE_OUT := 0;
    end if;

    if pmt.BALANCE_OUT_BF < 0 then
      pmt.PI_AMOUNT_DUE := 0;
    end if;
    --
    if g_chk_bal = 'Y' and pmt.ROWID = last_pmt.ROWID  then
      -- Last transaction therefore make the repayment = Balance Out + Interest Due.
      pmt.ACCUM_INTEREST := 0;
      pmt.EXPECTED_BALANCE_OUT := 0;
    end if;
    --
    -- Store balance carried fwd and start date for the next row
    new_exp_bal    := nvl(pmt.EXPECTED_BALANCE_OUT,0);
    new_accum_int  := nvl(pmt.ACCUM_INTEREST,0);
    new_balbf      := nvl(pmt.BALANCE_OUT,0);
    new_start_date := pmt.MATURITY_DATE;
    --
    if nvl(pmt.PI_AMOUNT_RECEIVED,0) <> 0 then
      l_comments := 'RECD SETTLEMENT ON PREV ROLL';
    else
      l_comments := NULL;
    end if;
    --
    l_prin_decr := nvl(l_prin_decr,0);
    pmt.INTEREST_SETTLED := nvl(pmt.INTEREST_SETTLED,0);
    -- Calc HCE amounts
    hce_decr       := round(nvl(l_prin_decr,0) / l_hce_rate,rounding_fac);
    hce_balbf      := round(nvl(pmt.BALANCE_OUT_BF,0) / l_hce_rate,rounding_fac);
    hce_interest   := round(nvl(pmt.INTEREST,0) / l_hce_rate,rounding_fac);
    hce_settled    := round(nvl(pmt.INTEREST_SETTLED,0) / l_hce_rate,rounding_fac);
    hce_accum_int_bf := round(nvl(pmt.ACCUM_INTEREST_BF,0) / l_hce_rate,rounding_fac);
    hce_princ      := nvl(round(nvl(pmt.PRINCIPAL_ADJUST,0) / l_hce_rate,rounding_fac),0);
    hce_balos      := round(nvl(pmt.BALANCE_OUT,0) / l_hce_rate,rounding_fac);
    hce_accum_int  := round(nvl(pmt.ACCUM_INTEREST,0) / l_hce_rate,rounding_fac);
    hce_due        := round(nvl(pmt.PI_AMOUNT_DUE,0) / l_hce_rate,rounding_fac);
    --
    update XTR_ROLLOVER_TRANSACTIONS
    set  START_DATE            = pmt.START_DATE,
         RATE_FIXING_DATE      = pmt.START_DATE,
         BALANCE_OUT_BF        = pmt.BALANCE_OUT_BF,
         BALANCE_OUT_BF_HCE    = hce_balbf,
         ACCUM_INTEREST_BF     = pmt.ACCUM_INTEREST_BF,
         ACCUM_INTEREST_BF_HCE = hce_accum_int_bf,
         PI_AMOUNT_DUE         = pmt.PI_AMOUNT_DUE,
         PI_AMOUNT_RECEIVED    = pmt.PI_AMOUNT_RECEIVED,
         ADJUSTED_BALANCE      = pmt.ADJUSTED_BALANCE,
         BALANCE_OUT           = pmt.BALANCE_OUT,
         BALANCE_OUT_HCE       = hce_balos,
         PRINCIPAL_ADJUST_HCE  = hce_princ,
         PRINCIPAL_ADJUST      = pmt.PRINCIPAL_ADJUST,
         INTEREST              = pmt.INTEREST,
         INTEREST_SETTLED      = pmt.INTEREST_SETTLED,
         INTEREST_HCE          = hce_interest,
         ACCUM_INTEREST        = pmt.ACCUM_INTEREST,
         ACCUM_INTEREST_HCE    = hce_accum_int,
         SETTLE_DATE           = pmt.SETTLE_DATE,
         NO_OF_DAYS            = pmt.NO_OF_DAYS,
         MATURITY_DATE         = pmt.MATURITY_DATE,
         EXPECTED_BALANCE_BF   = nvl(pmt.EXPECTED_BALANCE_BF,0),
         EXPECTED_BALANCE_OUT  = pmt.EXPECTED_BALANCE_OUT,
         ENDORSER_CODE         = l_date_exits
    where ROWID = pmt.ROWID;

    --DDA
    delete from XTR_DEAL_DATE_AMOUNTS_V
    where DEAL_NUMBER = l_deal_no
    and   TRANSACTION_NUMBER = pmt.TRANSACTION_NUMBER;

    --
    -- Insert rows for Principal Adjustments
    --
    if nvl(pmt.PRINCIPAL_ADJUST,0) <> 0 then
      -- Principal Increase has ocurred
      if pmt.PRINCIPAL_ACTION = 'INCRSE' then
        -- Principal Increase has ocurred
        insert into XTR_DEAL_DATE_AMOUNTS_V
              (deal_type,amount_type,date_type,
               deal_number,transaction_number,transaction_date,currency,
               amount,hce_amount,amount_date,transaction_rate,
               cashflow_amount,company_code,account_no,action_code,
               cparty_account_no,deal_subtype,product_type,
               portfolio_code,status_code,cparty_code,dealer_code,
               settle,client_code,serial_reference,
               dual_authorisation_by,
               dual_authorisation_on)
        values ('RTMM',nvl(pmt.PRINCIPAL_AMOUNT_TYPE,'PRINFLW'),
               'COMENCE',l_deal_no,pmt.TRANSACTION_NUMBER,
               l_deal_date,l_ccy ,pmt.PRINCIPAL_ADJUST,hce_princ,
               decode(nvl(g_chk_bal,'N'),'N',pmt.START_DATE,pmt.MATURITY_DATE),pmt.INTEREST_RATE,
               decode(nvl(pmt.PRINCIPAL_AMOUNT_TYPE,'PRINFLW'),'PRINFLW',decode(l_subtype
                 ,'FUND',pmt.PRINCIPAL_ADJUST
                 ,'INVEST',(-1) * pmt.PRINCIPAL_ADJUST),0),
               l_company,l_settle_acct  ,'INCRSE',
               l_cparty_acct ,l_subtype,l_product,
               l_portfolio ,'CURRENT',l_cparty,
               l_dealer,'N',l_client ,substr(l_internal_ticket_no,1,12),
               l_dual_authorisation_by,
               l_dual_authorisation_on);
      end if;
      -- Principal Reduction Row
      if nvl(pmt.PRINCIPAL_ACTION,'@#@') = 'DECRSE' then
        if nvl(pmt.PRINCIPAL_AMOUNT_TYPE,'PRINFLW') <> 'PRINFLW' then
          insert into XTR_DEAL_DATE_AMOUNTS_V
              (deal_type,amount_type,date_type,
               deal_number,transaction_number,transaction_date,currency,
               amount,hce_amount,amount_date,transaction_rate,
               cashflow_amount,company_code,account_no,action_code,
               cparty_account_no,deal_subtype,product_type,
               portfolio_code,status_code,cparty_code,dealer_code,
               settle,client_code,serial_reference,
               dual_authorisation_by,
               dual_authorisation_on)
          values  ('RTMM',nvl(pmt.PRINCIPAL_AMOUNT_TYPE,'PRINFLW'),
               'SETTLE',
	       -- decode(nvl(pmt.PRINCIPAL_AMOUNT_TYPE,'PRINFLW'),'PRINFLW',
               --         decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
               --                   ,0,'FORCAST','SETTLE'),'SETTLE'),

               l_deal_no,pmt.TRANSACTION_NUMBER,
               l_deal_date,l_ccy ,nvl(pmt.PRINCIPAL_ADJUST,0),
               nvl(nvl(hce_princ,pmt.PRINCIPAL_ADJUST),0),
               decode(nvl(g_chk_bal,'N'),'N',pmt.START_DATE,pmt.MATURITY_DATE),pmt.INTEREST_RATE,
               decode(nvl(pmt.PRINCIPAL_AMOUNT_TYPE,'PRINFLW'),'PRINFLW',decode(l_subtype
                 ,'FUND',(-1),1) * nvl(pmt.PRINCIPAL_ADJUST,0),0),
               l_company,l_settle_acct  ,'DECRSE',
               l_cparty_acct ,l_subtype,l_product,
               l_portfolio ,'CURRENT',l_cparty,
               l_dealer,'N',l_client ,substr(l_internal_ticket_no,1,12),
               l_dual_authorisation_by,
               l_dual_authorisation_on);
        end if;
      end if;
    end if;   -- End of Insert rows for Principal Adjustments

    --
    -- Reduction in Principal from a repayment (insert forcast row with 0's if not received)
    --
    insert into XTR_DEAL_DATE_AMOUNTS_V
              (deal_type,amount_type,date_type,
               deal_number,transaction_number,transaction_date,currency,
               amount,hce_amount,amount_date,transaction_rate,
               cashflow_amount,company_code,account_no,action_code,
               cparty_account_no,deal_subtype,product_type,
               portfolio_code,status_code,cparty_code,dealer_code,
               settle,client_code,serial_reference,
               dual_authorisation_by,
               dual_authorisation_on)
    values    ('RTMM','PRINFLW',decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                                  ,0,'FORCAST','SETTLE'),
              /*
              decode(nvl(pmt.PRINCIPAL_AMOUNT_TYPE,'PRINFLW'),'PRINFLW',
			decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                                  ,0,'FORCAST','SETTLE'),'SETTLE'),
              decode(nvl(pmt.PRINCIPAL_ACTION,'@#@'),'DECRSE',
              decode(nvl(pmt.PRINCIPAL_AMOUNT_TYPE,'PRINFLW'),'PRINFLW',
                decode(nvl(pmt.PI_AMOUNT_RECEIVED,NULL),NULL,'FORCAST','SETTLE'),'SETTLE'),
                  decode(pmt.PI_AMOUNT_RECEIVED,NULL,'FORCAST','SETTLE')),
              */
               l_deal_no,pmt.TRANSACTION_NUMBER,
               l_deal_date,l_ccy ,decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                  ,0,0,l_prin_decr),
                decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                  ,0,0,round(l_prin_decr/l_hce_rate,rounding_fac)),
               nvl(pmt.SETTLE_DATE,pmt.MATURITY_DATE),pmt.INTEREST_RATE,
               decode(l_subtype,'FUND',(-1),1) *
                   decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                     ,0,0,l_prin_decr),
               l_company,l_settle_acct  ,'DECRSE',
               l_cparty_acct ,l_subtype,l_product,
               l_portfolio ,'CURRENT',l_cparty,
               l_dealer,'N',l_client ,substr(l_internal_ticket_no,1,12),
                         l_dual_authorisation_by, -- bug 3958736
                         l_dual_authorisation_on);

    if nvl(pmt.BALANCE_OUT,0) <> 0 and pmt.INTEREST_RATE <> 0 then
      --- Rateset Date
      insert into XTR_DEAL_DATE_AMOUNTS_V
              (deal_type,amount_type,date_type,
               deal_number,transaction_number,transaction_date,currency,
               amount,hce_amount,amount_date,transaction_rate,
               cashflow_amount,company_code,account_no,action_code,
               cparty_account_no,deal_subtype,product_type,
               portfolio_code,status_code,cparty_code,dealer_code,
               settle,client_code,
               dual_authorisation_by, -- bug 3958736
               dual_authorisation_on)
      values   ('RTMM','FACEVAL','RATESET',l_deal_no,pmt.TRANSACTION_NUMBER,
               l_deal_date,l_ccy ,nvl(pmt.BALANCE_OUT,0),hce_balos,
               pmt.START_DATE,pmt.INTEREST_RATE,0,l_company,l_settle_acct  ,NULL,
               l_cparty_acct ,l_subtype,l_product,
               l_portfolio ,'CURRENT',l_cparty,l_dealer,'N',l_client,
                         l_dual_authorisation_by, -- bug 3958736
                         l_dual_authorisation_on);
    end if;

    -- Interest Row

    insert into XTR_DEAL_DATE_AMOUNTS_V
               (deal_type,amount_type,date_type,
                deal_number,transaction_number,transaction_date,currency,
                amount,hce_amount,amount_date,transaction_rate,
                cashflow_amount,company_code,account_no,action_code,
                cparty_account_no,deal_subtype,product_type,
                portfolio_code,status_code,cparty_code,dealer_code,
                settle,client_code,serial_reference,
                         dual_authorisation_by, -- bug 3958736
                         dual_authorisation_on)
    values     ('RTMM','INTSET',decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                                  ,0,'FORCAST','SETTLE'),
                l_deal_no,pmt.TRANSACTION_NUMBER,
                l_deal_date,l_ccy ,
                decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                  ,0,pmt.PI_AMOUNT_DUE,pmt.INTEREST_SETTLED),
                decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                  ,0,hce_due,hce_settled),
                nvl(pmt.SETTLE_DATE,pmt.MATURITY_DATE),pmt.INTEREST_RATE,
                decode(l_subtype
                  ,'FUND',(-1),1) * decode(nvl(pmt.PI_AMOUNT_RECEIVED,0)
                                      ,0,nvl(pmt.PI_AMOUNT_DUE,0)
                                      ,nvl(pmt.INTEREST_SETTLED,0)),
                l_company,l_settle_acct  ,NULL,
                l_cparty_acct ,l_subtype,l_product,
                l_portfolio ,'CURRENT',l_cparty,
                l_dealer,'N',l_client ,substr(l_internal_ticket_no,1,12),
                         l_dual_authorisation_by, -- bug 3958736
                         l_dual_authorisation_on);
    --
    if nvl(pmt.PRINCIPAL_ADJUST,0) = 0 then
      delete from XTR_DEAL_DATE_AMOUNTS_V
      where DEAL_NUMBER = l_deal_no
      and TRANSACTION_NUMBER = pmt.TRANSACTION_NUMBER
      and AMOUNT_TYPE = 'PRINFLW'
      and ACTION_CODE = 'INCRSE';-- Why only INCRSE ????
    end if;
    --
    if pmt.NO_OF_DAYS = 0 and pmt.PRINCIPAL_ACTION is NULL and nvl(pmt.INTEREST,0) = 0 then
      -- **** questionable delete
      delete from XTR_DEAL_DATE_AMOUNTS_V
      where DEAL_NUMBER = l_deal_no
      and TRANSACTION_NUMBER = pmt.TRANSACTION_NUMBER
      and DATE_TYPE = 'RATESET';
    end if;
    --
    if nvl(pmt.BALANCE_OUT,0) = 0 and nvl(pmt.ACCUM_INTEREST,0) = 0 and l_nill_date is NULL then
      -- add l_nill_date is NULL
      l_nill_date := pmt.MATURITY_DATE;
    end if;
    --
    fetch DT_ROW INTO pmt;
  END LOOP;

  --
  --
  if l_nill_date is NOT NULL then
    delete from XTR_ROLLOVER_TRANSACTIONS
    where DEAL_NUMBER = l_deal_no
    and START_DATE > l_nill_date
    and SETTLE_DATE is null; --- >=
    --
    delete from XTR_DEAL_DATE_AMOUNTS_V
    where DEAL_NUMBER = l_deal_no
    and amount_date > l_nill_date;
  end if;
  --
  if nvl(l_trans_num,0)=-1 then
    if pmt.balance_out is not null then
      g_expected_balance_bf := to_char(pmt.EXPECTED_BALANCE_OUT);
      g_balance_out_bf   := to_char(pmt.BALANCE_OUT);
      g_accum_interest_bf := to_char(pmt.ACCUM_INTEREST);
      g_principal_adjust := '0';
    else
      g_expected_balance_bf := '0';
      g_balance_out_bf   := '0';
      g_accum_interest_bf :='0';
      g_principal_adjust := to_char(l_face_value_amount);
    end if;
  else
    update XTR_DEAL_DATE_AMOUNTS_V
    set amount=nvl(pmt.BALANCE_OUT,0),
        hce_amount=nvl(hce_balos,0)
    where deal_type='RTMM' and amount_type='BALOUT' and deal_number=l_deal_no;
    if SQL%NOTFOUND then
      --- Add 1 more row to DDA for Balout
      insert into XTR_DEAL_DATE_AMOUNTS_V
              (deal_type,amount_type,date_type,
               deal_number,transaction_number,transaction_date,currency,
               amount,hce_amount,amount_date,transaction_rate,
               cashflow_amount,company_code,account_no,action_code,
               cparty_account_no,deal_subtype,product_type,
               portfolio_code,status_code,cparty_code,dealer_code,
               settle,client_code,limit_code,limit_party,
                         dual_authorisation_by, -- bug 3958736
                         dual_authorisation_on)
      values  ('RTMM','BALOUT','COMENCE',
               l_deal_no,pmt.TRANSACTION_NUMBER,
               l_deal_date,l_ccy ,nvl(pmt.BALANCE_OUT,0),
               nvl(hce_balos,0),l_maturity ,pmt.INTEREST_RATE,0,
               l_company,l_settle_acct  ,NULL,
               l_cparty_acct ,l_subtype,l_product,
               l_portfolio ,'CURRENT',l_cparty,
               l_dealer,'N',l_client ,
               nvl(l_limit_code,'NILL'),l_cparty,
                         l_dual_authorisation_by, -- bug 3958736
                         l_dual_authorisation_on);
    end if;

    if nvl(g_chk_bal,'N')='Y' and nvl(c_writoff_int,0)<>0 then
      -- Add 1 more row to DDA for WRITINT
      insert into XTR_DEAL_DATE_AMOUNTS_V
              (deal_type,amount_type,date_type,
               deal_number,transaction_number,transaction_date,currency,
               amount,hce_amount,amount_date,transaction_rate,
               cashflow_amount,company_code,account_no,action_code,
               cparty_account_no,deal_subtype,product_type,
               portfolio_code,status_code,cparty_code,dealer_code,
               settle,client_code,limit_code,limit_party,
                         dual_authorisation_by, -- bug 3958736
                         dual_authorisation_on
               )
       values ('RTMM','WRTEINT','SETTLE',
               l_deal_no,l_trans_num,
               l_deal_date,l_ccy ,nvl(c_writoff_int,0),
               round(nvl(c_writoff_int,0) / l_hce_rate,rounding_fac),
               c_increase_effective_from,pmt.INTEREST_RATE,0,
               l_company,l_settle_acct  ,NULL,
               l_cparty_acct ,l_subtype,l_product,
               l_portfolio ,'CURRENT',l_cparty,
               l_dealer,'N',l_client ,
               null,l_cparty,
                         l_dual_authorisation_by, -- bug 3958736
                         l_dual_authorisation_on);
    end if;
  end if;

  if DT_ROW%ISOPEN then
    close DT_ROW;
  end if;

END RECALC_DT_DETAILS ;



end XTR_CALC_P;

/
