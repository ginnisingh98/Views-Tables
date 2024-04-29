--------------------------------------------------------
--  DDL for Package Body FA_POLISH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_POLISH_PVT" AS
/* $Header: FAVPOLB.pls 120.11.12010000.3 2009/07/19 11:27:37 glchen ship $ */

-- === Overview ============================================================ --
--
-- The Polish Tax Enhancement feature is fairly complicated with a number of
-- business rules that do not follow normal Fixed Assets behaviour.  Therefore,
-- I am going to summarize a few points here.  For a more in-depth look at
-- this feature, refer to the design document or the official published
-- documentation.  For precise formulas such as the formula for calculating
-- the new basis after a negative adjustment, refer to the code.
--
-- Definitions:
-- -------------
-- adjusted_cost: depreciation basis for an asset to derive deprn amount
-- adjusted_recoverable_cost: cost that determines when an asset becomes
--    fully reserved.
--
-- Polish Mechanisms or Rules:
--   ---> : change happens automatically when moving from year 1 to year 2
--   -?-> : switch test is performed to check if method moves to next code
--
--   1: 30 ---> D2 -?-> FR
--   2: 30 ---> FR
--   3: DM ---> D2 -?-> FR
--   4: DM ---> FR
--   5: SD -?-> FR
--
-- Switch Codes:
--   30: adjusted rate = 30% in period asset placed in service
--     : ignore prorate convention
--     : no deprn in rest of first year after first periods
--     : basis = adjusted_cost
--   D2: adjusted rate = flat rate * deprn factor
--     : basis = adjusted_cost - previous year reserve + first year reserve
--   SD: adjusted rate = flat rate * deprn factor
--     : basis = adjusted_cost - previous year reserve
--   DM: adjusted rate = flat rate * alternate deprn factor
--     : basis = adjusted_cost
--   FR: adjusted rate = flat rate
--     : basis = adjusted_cost
--
-- Basic Features:
-- ----------------
-- Polish assets are assets that are assigned to a flat-rate method using
-- one of the five Polish depreciation basis rules in addition to a bonus rule.
-- The bonus rule determines the deprn factor and alternate deprn factor.
--
-- Throughout the asset's life, it moves from one rate, which is determined
-- by the switch code, to another.  Sometimes the switch happens automatically,
-- such as for some mechanisms from year 1 to year 2.  Other times, you need
-- to run a switch test to see if the asset moves to the next method in the
-- chain.  The switch test happens only at the close of the fiscal and
-- determines the rate for all of the periods in that year.  In general, the
-- switch test checks to see which code will generate the greater monthly
-- depreciation in the year and returns that code.  Once an asset has moved
-- to the next part of the chain, it cannot revert back to a previous one.
--
-- In addition to the rate, the switch code also determines the depreciation
-- basis for an asset.  The formulas for the rate and the depreciation basis
-- for each switch code is in the definitions section.
--
-- When you perform a transaction on an asset, it may affect the basis for
-- that asset immediately or not take affect until the next fiscal year
-- depending on the transaction and the switch code the asset currently has.
-- For a negative cost adjustment, the formula to determine the new basis is
-- also predicated on the value of the polish adjustment calculate basis flag
-- which is tied to the method.
--
-- Partial retirement:
--   basis: for formula see Calc_Basis_Partial_Ret procedure
--
-- Negative adjustment w/ polish_adj_calc_basis_flag set to Yes:
--   basis: for formula see Calc_Basis_Neg_Adj_Flag_Yes procedure
--
-- Negative adjustment w/ polish_adj_calc_basis_flag set to No:
--   basis: for formula see Calc_Basis_Neg_Adj_Flag_No
--
-- Positive adjustment
--   basis: if switch is FR, take new adjusted_cost as basis immediately
--        : otherwise, do not take it until next fiscal year, running new
--        : new adjusted_cost through the switch test if necessary.
--
-- In addition, if you do a negative adjustment, the asset can over-depreciate.
-- That is, when a new basis is calculated for the asset, the asset's
-- adjusted_recoverable_cost is also set to this amount so that the asset can
-- depreciate to this new basis amount even if it is greater than the asset's
-- cost.  This brings up an important point with regard to the code.  The
-- Polish asset's adjusted_cost and adjusted_recoverable cost that it uses
-- to determine the depreciation basis are the ones in fa_books.  Instead, I
-- currently use polish_deprn_basis in fa_books_summary for adjusted_cost and
-- polish_adj_rec_cost in fa_books_summary for adjusted_recoverable_cost.
-- The reason for this is that I treat the values in fa_books as the baseline.
-- For example, when the user changes the cost from 20,000 to 12,000, the
-- value of adjusted_cost and adjusted_recoverable_cost are both 12,000 in
-- fa_books.  However, since we need to run negative adjustments through a
-- formula to determine the basis, etc, these numbers will be different from
-- the 12,000.  However, I still want the user to see the 12,000, so if they
-- perform an subsequent transactions on the asset, they are using the 12,000
-- figure and not the new figure calculated by the program.  Therefore, for
-- Polish assets, the depreciation basis and the adjusted_recoverable_cost
-- used to determine when the asset becomes fully reserved are essentially
-- internal figures and not ones that the user sees.  Of course, we could
-- display these figures in fields separately that the user can see such as
-- in the new new book value of the asset.
--
-- This Polish procedure is currently called from the depreciation engine
-- and the adjustment API (when catchup is needed).  For this, we have two
-- modes, DEPRN and ADJUSTMENT.  We have separate code for adjustments
-- because none of the rows have been inserted into the tables when
-- catchup is called.  Therefore, we can't derive from the tables when
-- the adjustment occurred, how much was adjusted, and so forth.  During
-- depreciation, all of this is stored in the tables, so we can drill down
-- and obtain the information we need that way.  For adjustments, we are
-- currently reading some global variables that the adjustment API provides,
-- and this is enough to calculate the appropriate rate and cost.  Note
-- that using global variables is not an ideal solution as they do not work
-- if called from OA Framework since the variables are reset constantly and
-- not when you expect.
--
-- Business Rules:
-- ----------------
-- This is a summary of different business rules that Polish assets need to
-- follow.  Some of them have been mentioned previously.
--
-- * Assets with a switch code of 30, take a flat rate of 30% in the period
--   they are placed in service regardless of prorate convention.  On a
--   related note, please remember if you are using a following month prorate
--   convention for a Polish asset using one of the other rules, if you have
--   the Depreciate When Placed in Service Flag checked for your following
--   month prorate convention in the Setup Prorate Conventions form, the asset
--   will still take depreciation in the period it was added.  For example, if
--   you add such an asset in October 2003 with a following month prorate
--   convention and the Depreciate When Placed In Service flag checked, the
--   asset will take two months depreciation (November and December) for the
--   rest of 2003 because it is a following month convention.  However, it will
--   spread these two months of depreciation across three months since it will
--   begin depreciating in October.  If the Depreciate When Placed In Service
--   flag is not checked, the asset would begin depreciating in November 2003
--   and spread two months of depreciation across two months, November and
--   December as you would expect.
--
-- * You can never move backwards in the switch chain.  For example, after
--   an asset moves to FR, it can never move back to SD, even if you made a
--   cost adjustment to the asset where if you performed the switch test,
--   it would result in SD.  It still must stay FR.
--
-- * The switch test for the next year is determined after the close of the
--   last period in the fiscal year.  Therefore even if you do an adjustment
--   in the first period of the next year before depreciation is charged,
--   the switch test is still performed based upon the values for the last
--   year.  All subsequent rules for that switch code also apply for the first
--   period of that year.  Therefore, if the first period is supposed to be
--   SD, all rules regarding SD apply such as a positive cost adjustment
--   does not affect the basis for SD in the year of adjustment.
--
-- * For a positive cost adjustment, the basis only changes in the current
--   year if the switch is FR.  For any other code, the basis remains the
--   same until the next year when the new cost takes affect.
--
-- * For a negative cost adjustment, the basis changes immediately for any
--   switch value except 30 since all periods after 30 don't depreciate at all.
--
-- * For partial retirement, the basis changes immediately for any switch
--   value except 30.
--
-- * Backdated adjustments across fiscal years do not affect the switch in
--   those years.  Therefore, when you are calculating the catchup in those
--   previous years, the rates stay the same as they were.  In addition, the
--   basis may not change either, depending on whether it is allowed.  For
--   example, if you do a backdated positive adjustment on year, and the
--   previous year were SD, the basis would not change in that previous year
--   either.  The basis would change if it were FR or a negative adjustment
--   instead of a positive one.  Note that since partial retirements cannot
--   cross fiscal years, this is not relevant for this type of transaction.
--
-- * If you have multiple adjustments in the same period, you take the
--   summation of the adjustments to determine the net adjustment for the
--   period and treat this as a single cost change rather than taking the
--   adjustments individually.  For example, if you have a positive
--   adjustments of 100 and a negative adjustment of 25, you treat this as
--   a positive 75 adjustment.
--
-- Possible Improvements:
-- -----------------------
-- One thing mentioned is the use of global variables and the drawbacks.
-- These should be removed ideally.
--
-- One thing that I do not do here that could be improved is the
-- calculate of the switch code.  That is, typically, the switch
-- only need to be calculated at the end of the year, and at times
-- when a transaction occurs.  However, I calculate the switch
-- during every period regardless.  Theoretically, in the middle of a
-- year w/ no transactions, I could take a look at the switch_code in
-- fa_books_summary, and just use that for the current period.  If
-- performance improvements need to be made, that can be one of the
-- first places to look.  One of the reasons that I didn't do this
-- was that I wanted to make the code as generic as possible.  That is,
-- when transactions occur, you do need to do the switch mid-year on
-- occasion.  When backdated adjustments happen, you might need to do
-- this over a range of periods, and here the switch_code in
-- fa_books_summary may not give you the value that you are looking
-- for anymore since that was the switch value at the time of that
-- period, but now that the backdated adjustment has occurred, it's
-- obsolete.  To try to avoid these complexities, I just do the
-- switch all the time even though there are performance drawbacks.
--
-- ============================================================ Overview === --



-- PRIVATE ROUTINE - forward declaration

FUNCTION Calc_Basis_Neg_Adj_Flag_Yes (
                    p_book_type_code         IN            VARCHAR2,
                    p_old_cost               IN            NUMBER,
                    p_old_reserve            IN            NUMBER,
                    p_adjustment_amount      IN            NUMBER,
                    p_set_of_books_id        IN            NUMBER,
                    x_new_deprn_basis           OUT NOCOPY NUMBER,
		    p_log_level_rec          IN
FA_API_TYPES.log_level_rec_type default null)
RETURN BOOLEAN;

FUNCTION Calc_Basis_Neg_Adj_Flag_No (
                    p_book_type_code         IN            VARCHAR2,
                    p_old_cost               IN            NUMBER,
                    p_old_deprn_basis        IN            NUMBER,
                    p_adjustment_amount      IN            NUMBER,
                    p_set_of_books_id        IN            NUMBER,
                    x_new_deprn_basis           OUT NOCOPY NUMBER,
		    p_log_level_rec          IN
FA_API_TYPES.log_level_rec_type default null)
RETURN BOOLEAN;

FUNCTION Calc_Basis_Partial_Ret (
                    p_book_type_code         IN            VARCHAR2,
                    p_old_cost               IN            NUMBER,
                    p_old_deprn_basis        IN            NUMBER,
                    p_retirement_amount      IN            NUMBER,
                    p_set_of_books_id        IN            NUMBER,
                    x_new_deprn_basis           OUT NOCOPY NUMBER,
		    p_log_level_rec          IN
FA_API_TYPES.log_level_rec_type default null)
RETURN BOOLEAN;

FUNCTION Calc_Basis_Trxn (
                    p_book_type_code         IN            VARCHAR2,
                    p_transaction_type_code  IN            VARCHAR2,
                    p_pos_neg_adjustment     IN            VARCHAR2,
                    p_polish_adj_calc_basis_flag
                                             IN            VARCHAR2,
                    p_adjusted_cost          IN            NUMBER,
                    p_adjusted_recoverable_cost
                                             IN            NUMBER,
                    p_prev_adj_rec_cost      IN            NUMBER,
                    p_prev_basis             IN            NUMBER,
                    p_prev_reserve           IN            NUMBER,
                    p_adjustment_amount      IN            NUMBER,
                    p_retirement_amount      IN            NUMBER,
                    p_switch_code            IN            VARCHAR2,
                    p_set_of_books_id        IN            NUMBER,
                    x_adjusted_cost             OUT NOCOPY NUMBER,
                    x_adjusted_recoverable_cost OUT NOCOPY NUMBER,
		    p_log_level_rec          IN
FA_API_TYPES.log_level_rec_type default null)
RETURN BOOLEAN;

FUNCTION Calc_Trxn_Values (
                    p_book_type_code         IN            VARCHAR2,
                    p_asset_id               IN            NUMBER,
                    p_transaction_type_code  IN            VARCHAR2,
                    p_transaction_header_id  IN            NUMBER,
                    p_first_period_counter   IN            NUMBER,
                    p_mrc_sob_type_code      IN            VARCHAR2,
                    p_set_of_books_id        IN            NUMBER,
                    p_calling_mode           IN            VARCHAR2,
                    x_adjustment_amount         OUT NOCOPY NUMBER,
                    x_retirement_amount         OUT NOCOPY NUMBER,
                    x_bef_trxn_period_counter   OUT NOCOPY NUMBER,
                    x_pos_neg_adjustment        OUT NOCOPY VARCHAR2,
                    x_prev_basis                OUT NOCOPY NUMBER,
                    x_prev_adj_rec_cost         OUT NOCOPY NUMBER,
                    x_prev_reserve              OUT NOCOPY NUMBER,
		    p_log_level_rec          IN
FA_API_TYPES.log_level_rec_type default null)
RETURN BOOLEAN;

FUNCTION Calc_Rate (
                    p_book_type_code         IN            VARCHAR2,
                    p_asset_id               IN            NUMBER,
                    p_polish_rule            IN            NUMBER,
                    p_year_of_life           IN            NUMBER,
                    p_year_retired           IN            VARCHAR2,
                    p_period_counter         IN            NUMBER,
                    p_first_period_counter   IN            NUMBER,
                    p_open_period_counter    IN            NUMBER,
                    p_period_num             IN            NUMBER,
                    p_periods_per_year       IN            NUMBER,
                    p_adjusted_rate          IN            NUMBER,
                    p_deprn_factor           IN            NUMBER,
                    p_alternate_deprn_factor IN            NUMBER,
                    p_depreciate_flag        IN            VARCHAR2,
                    p_first_year_reserve     IN            NUMBER,
                    p_prev_year_reserve      IN            NUMBER,
                    p_prev_year_adjusted_cost
                                             IN            NUMBER,
                    p_prev_year_adj_rec_cost IN            NUMBER,
                    p_mrc_sob_type_code      IN            VARCHAR2,
                    p_set_of_books_id        IN            NUMBER,
                    x_adjusted_rate             OUT NOCOPY NUMBER,
                    x_depreciate_flag           OUT NOCOPY VARCHAR2,
                    x_switch_code               OUT NOCOPY VARCHAR2,
		    p_log_level_rec          IN
FA_API_TYPES.log_level_rec_type default null)
RETURN BOOLEAN;



-- PUBLIC ROUTINE

PROCEDURE Calc_Polish_Rate_Cost (
                    p_Book_Type_Code         IN            VARCHAR2,
                    p_Asset_Id               IN            NUMBER,
                    p_Polish_Rule            IN            NUMBER,
                    p_Deprn_Factor           IN            NUMBER,
                    p_Alternate_Deprn_Factor IN            NUMBER,
                    p_Polish_Adj_Calc_Basis_Flag
                                             IN            VARCHAR2,
                    p_Rate                   IN            NUMBER,
                    p_Depreciate_Flag        IN            VARCHAR2,
                    p_Adjusted_Cost          IN            NUMBER,
                    p_Recoverable_Cost       IN            NUMBER,
                    p_Adjusted_Recoverable_Cost
                                             IN            NUMBER,
                    p_Fiscal_Year            IN            NUMBER,
                    p_Period_Num             IN            NUMBER,
                    p_Periods_Per_Year       IN            NUMBER,
                    p_Year_Retired           IN            VARCHAR2,
                    p_MRC_Sob_Type_Code      IN            VARCHAR2,
                    p_set_of_books_id        IN            NUMBER,
                    x_Rate                      OUT NOCOPY NUMBER,
                    x_Depreciate_Flag           OUT NOCOPY VARCHAR2,
                    x_Adjusted_Cost             OUT NOCOPY NUMBER,
                    x_Adjusted_Recoverable_Cost
                                                OUT NOCOPY NUMBER,
                    x_Success                   OUT NOCOPY INTEGER,
                    p_Calling_Fn             IN            VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
IS

   l_period_counter              number(15);
   l_first_period_counter        number(15);
   l_first_fiscal_year           number(4);
   l_year_of_life                number(15);
   l_old_adjusted_cost           number;
   l_adjusted_cost               number;
   l_adjusted_recoverable_cost   number;
   l_adjusted_rate               number;
   l_depreciate_flag             varchar2(3);
   l_switch_code                 varchar2(2);

   l_adjusted_cost_old           number;
   l_adj_rec_cost_old            number;

   l_transaction_type_code       varchar2(20);
   l_transaction_header_id       number(15);

   l_adjustment_amount           number;
   l_retirement_amount           number;
   l_bef_trxn_period_counter     number(15);
   l_pos_neg_adjustment          varchar2(3);
   l_prev_adj_rec_cost           number;
   l_prev_basis                  number;
   l_prev_reserve                number;

   l_first_year_period_counter   number(15);
   l_prev_year_period_counter    number(15);
   l_first_year_reserve          number;
   l_prev_year_reserve           number;
   l_prev_year_adjusted_cost     number;
   l_prev_year_adj_rec_cost      number;
   l_min_period_counter          number;

   l_previous_year_adjustment    boolean;
   l_previous_year_retirement    boolean;

   l_open_period_counter         number(15);
   l_bs_row                      number(15);

   polish_err                    exception;

BEGIN

   -- === Initializations ================================================== --

   l_transaction_type_code := 'NONE';
   l_previous_year_adjustment := FALSE;
   l_previous_year_retirement := FALSE;

   l_first_year_reserve := 0;
   l_prev_year_reserve := 0;

   -- Fix for Bug #3649102.  Need to initialize this in case we're in 1st yr
   l_prev_year_adj_rec_cost := p_Adjusted_Recoverable_Cost;

   if (p_Calling_Fn = 'fadpdp.faxgpolr') then
      -- We are calling this from the deprn engine.  Set the mode.
      FA_POLISH_PVT.calling_mode := 'DEPRN';
   elsif (p_Calling_Fn = 'faproj.faxgpolr') then
      FA_POLISH_PVT.calling_mode := 'PROJECT';
   elsif (p_Calling_Fn = 'fa_cde_pkg.whatif.faxgpolr') then
      FA_POLISH_PVT.calling_mode := 'WHATIF';
   end if;

   -- Derive current period_counter.  Note that this may be different from
   -- the current open period if we are looping through backdated periods.
   l_period_counter := (p_Fiscal_Year * p_Periods_Per_Year) + p_Period_Num;

   -- Determine the year_of_life.  For a Polish asset, the first year is
   -- always the year of the dpis regardless of the prorate convention.
   begin

      if (p_MRC_SOB_Type_Code = 'R') then

         select fy.fiscal_year
         into   l_first_fiscal_year
         from   fa_fiscal_year fy,
                fa_mc_book_controls mbc,
                fa_book_controls bc,
                fa_mc_books bks
         where  bc.book_type_code = p_Book_Type_Code
         and    mbc.book_type_code = p_Book_Type_Code
         and    bc.fiscal_year_name = fy.fiscal_year_name
         and    mbc.set_of_books_id = p_set_of_books_id
         and    bks.book_type_code = p_Book_Type_Code
         and    bks.asset_id = p_Asset_Id
         and    bks.transaction_header_id_out is null
         and    bks.set_of_books_id = p_set_of_books_id
         and    bks.date_placed_in_service between
                fy.start_date and fy.end_date;

         select dp.period_counter
         into   l_first_period_counter
         from   fa_mc_deprn_periods dp,
                fa_mc_books bks
         where  dp.book_type_code = p_Book_Type_Code
         and    dp.set_of_books_id = p_set_of_books_id
         and    bks.book_type_code = p_Book_Type_Code
         and    bks.asset_id = p_Asset_Id
         and    bks.transaction_header_id_out is null
         and    bks.set_of_books_id = p_set_of_books_id
         and    bks.date_placed_in_service between
                dp.calendar_period_open_date and dp.calendar_period_close_date;

         select period_counter
         into   l_open_period_counter
         from   fa_mc_deprn_periods
         where  book_type_code = p_Book_Type_Code
         and    period_close_date is null
         and    set_of_books_id = p_set_of_books_id;

      else

         select fy.fiscal_year
         into   l_first_fiscal_year
         from   fa_fiscal_year fy,
                fa_book_controls bc,
                fa_books bks
         where  bc.book_type_code = p_Book_Type_Code
         and    bc.fiscal_year_name = fy.fiscal_year_name
         and    bks.book_type_code = p_Book_Type_Code
         and    bks.asset_id = p_Asset_Id
         and    bks.transaction_header_id_out is null
         and    bks.date_placed_in_service between
                fy.start_date and fy.end_date;

         select dp.period_counter
         into   l_first_period_counter
         from   fa_deprn_periods dp,
                fa_books bks
         where  dp.book_type_code = p_Book_Type_Code
         and    bks.book_type_code = p_Book_Type_Code
         and    bks.asset_id = p_Asset_Id
         and    bks.transaction_header_id_out is null
         and    bks.date_placed_in_service between
                dp.calendar_period_open_date and dp.calendar_period_close_date;

         select period_counter
         into   l_open_period_counter
         from   fa_deprn_periods
         where  book_type_code = p_Book_Type_Code
         and    period_close_date is null;

      end if;
   exception
      when others then
         -- We're going to assume that if there are errors, the asset is
         -- too old for the calendar, so we'll just set the first year to 0
         l_first_fiscal_year := 0;
         l_first_period_counter := 0;
   end;

   l_year_of_life := p_Fiscal_Year - l_first_fiscal_year + 1;

   -- For an adjustment, the p_Adjusted_Cost passed in is not necessarily the
   -- new cost.  We will need to derive this amount.
   if (FA_POLISH_PVT.calling_mode = 'ADJUSTMENT') then

      if (p_MRC_SOB_Type_Code = 'R') then

         select adjusted_cost
         into   l_old_adjusted_cost
         from   fa_mc_books
         where  book_type_code = p_Book_Type_Code
         and    asset_id = p_Asset_Id
         and    transaction_header_id_out is null
         and    set_of_books_id = p_set_of_books_id;

      else

         select adjusted_cost
         into   l_old_adjusted_cost
         from   fa_books
         where  book_type_code = p_Book_Type_Code
         and    asset_id = p_Asset_Id
         and    transaction_header_id_out is null;
      end if;

      l_adjusted_cost := FA_POLISH_PVT.adjustment_amount + l_old_adjusted_cost;
   else
      l_adjusted_cost := p_Adjusted_Cost;
   end if;

   -- Save parameters into local variables if we may be modifying them
   l_adjusted_recoverable_cost := p_Adjusted_Recoverable_Cost;
   l_adjusted_rate := p_Rate;
   l_depreciate_flag := p_Depreciate_Flag;

   -- ============================================== End Initializations === --
   --                                                                        --
   -- === Initial Checks =================================================== --

   -- If before first period of life, then just return
   if (l_period_counter < l_first_period_counter) then
      x_Rate := 0;
      x_Depreciate_Flag := l_depreciate_flag;
      x_Adjusted_Cost := l_adjusted_cost;
      x_Adjusted_Recoverable_Cost := l_adjusted_recoverable_cost;
      X_Success := 1;
      return;
   end if;

   -- If we are not calling this from a recognized program, then error.
   if (FA_POLISH_PVT.calling_mode not in ('DEPRN', 'ADJUSTMENT',
                                          'PROJECT', 'WHATIF')) then

      fa_srvr_msg.add_message(
         calling_fn => 'fa_polish_pvt.calc_polish_rate_cost',
         name       => '***FA_POLISH_INVALID_MODE***',
         p_log_level_rec => p_log_level_rec);
      raise polish_err;
   end if;

   -- =============================================== End Initial Checks === --
   --                                                                        --
   -- === Check Transactions =============================================== --

   if (FA_POLISH_PVT.calling_mode = 'ADJUSTMENT') then
      -- If we are currently doing an adjustment, no rows for the adjustment
      -- will be been added yet, so there will not exist rows for the
      -- adjustment in fa_transaction_headers or fa_adjustments.
      l_transaction_type_code := 'ADJUSTMENT';

   else

      -- Check to see if any transactions have been performed on this asset,
      -- specifically, adjustments and partial retirements, which would affect
      -- the rate and deprn basis.  We want to get the most recent transaction.

      -- Fix for Bug #3629991.  Added transaction_header_id to select b/c
      -- we may have multiple transactions to select from fa_adjustments
      -- later.
      begin
         select transaction_type_code,
                transaction_header_id
         into   l_transaction_type_code,
                l_transaction_header_id
         from   fa_transaction_headers
         where  book_type_code = p_Book_Type_Code
         and    asset_id = p_Asset_ID
         and    transaction_type_code in ('ADJUSTMENT', 'PARTIAL RETIREMENT')
         and    transaction_header_id =
         (
          select max(transaction_header_id)
          from   fa_transaction_headers
          where  book_type_code = p_Book_Type_Code
          and    asset_id = p_Asset_ID
          and    transaction_type_code in ('ADJUSTMENT', 'PARTIAL RETIREMENT')
         );

      exception
         when no_data_found then
            -- No adjustments or partial retirements found
            l_transaction_type_code := 'NONE';
      end;
   end if;

   -- =========================================== End Check Transactions === --
   --                                                                        --
   -- === Calculate Transaction Values ===================================== --
   -- If there are transactions that were done, let's calculate some
   -- intermediate values since nearly every scenario will require them.

   if (l_transaction_type_code <> 'NONE') then

      if (not FA_POLISH_PVT.Calc_Trxn_Values (
                    p_book_type_code          => p_book_type_code,
                    p_asset_id                => p_asset_id,
                    p_transaction_type_code   => l_transaction_type_code,
                    p_transaction_header_id   => l_transaction_header_id,
                    p_first_period_counter    => l_first_period_counter,
                    p_mrc_sob_type_code       => p_mrc_sob_type_code,
                    p_set_of_books_id         => p_set_of_books_id,
                    p_calling_mode            => fa_polish_pvt.calling_mode,
                    x_adjustment_amount       => l_adjustment_amount,
                    x_retirement_amount       => l_retirement_amount,
                    x_bef_trxn_period_counter => l_bef_trxn_period_counter,
                    x_pos_neg_adjustment      => l_pos_neg_adjustment,
                    x_prev_basis              => l_prev_basis,
                    x_prev_adj_rec_cost       => l_prev_adj_rec_cost,
                    x_prev_reserve            => l_prev_reserve
      , p_log_level_rec => p_log_level_rec)) then
	   raise polish_err;
      end if;
   end if;

   -- ================================= End Calculate Transaction Values === --
   --                                                                        --
   -- === Calculate Transaction Switch Values ============================== --

   -- After the first year, we need to calculate some new values because a
   -- transaction in the middle of a year can cause a switch test to be
   -- re-done, especially if it is a backdated adjustment.  Therefore the
   -- new deprn basis may be derived differently based on these values.

   if ((l_year_of_life > 1) and (p_Year_Retired = 'N')) then

      -- The previous year last period counter is period_ctr - per
      l_prev_year_period_counter := l_period_counter - p_Period_Num;

      -- The first year last period counter is (begin_fy + 1) * 12)
      l_first_year_period_counter := (l_first_fiscal_year + 1) * 12;

      if (p_MRC_SOB_Type_Code = 'R') then
        Begin /* Bug 6450906  Added Exception handling*/
		select  deprn_reserve
		into    l_first_year_reserve
		from    fa_mc_deprn_summary
		where   book_type_code  = p_Book_Type_Code
		and     asset_id = p_Asset_Id
		and     period_counter = l_first_year_period_counter
                and     set_of_books_id = p_set_of_books_id;
	Exception
		when no_data_found then
			l_first_year_reserve := 0;
	End;

	Begin /* Bug 6450906  Added Exception handling*/
		select  deprn_reserve
		into    l_prev_year_reserve
		from    fa_mc_deprn_summary
		where   book_type_code  = p_Book_Type_Code
		and     asset_id = p_Asset_Id
		and     period_counter = l_prev_year_period_counter
                and     set_of_books_id = p_set_of_books_id;
	Exception
		when no_data_found then
			l_prev_year_reserve := 0;
	End;
         -- Fix for Bug #5550557.  Need to catch if books summary row
         -- does not exist.
         begin

            select  polish_deprn_basis,
                    polish_adj_rec_cost
            into    l_prev_year_adjusted_cost,
                    l_prev_year_adj_rec_cost
            from    fa_mc_books_summary
            where   book_type_code  = p_Book_Type_Code
            and     asset_id = p_Asset_Id
            and     period_counter = l_prev_year_period_counter
            and     set_of_books_id = p_set_of_books_id;

            -- Fix for Bug #5907258.  If these values are null, can cause
            -- data corruption.  Needs to be fixed first.
            if (l_prev_year_adjusted_cost is null) or
               (l_prev_year_adj_rec_cost is null) then

               fa_srvr_msg.add_message(
                  calling_fn => 'fa_polish_pvt.calc_polish_rate_cost',
                  name       => '***FA_POLISH_NULL_COST***',
         p_log_level_rec => p_log_level_rec);
                    raise polish_err;
            end if;
         exception

            when no_data_found then

               select min(period_counter)
               into   l_min_period_counter
               from   fa_mc_deprn_periods
               where  book_type_code = p_Book_Type_Code
               and     set_of_books_id = p_set_of_books_id;

               if (l_prev_year_period_counter >= l_min_period_counter) then

                  begin

                     select bks.adjusted_cost,
                            bks.adjusted_recoverable_cost
                     into   l_prev_year_adjusted_cost,
                            l_prev_year_adj_rec_cost
                     from   fa_mc_books bks
                     where  bks.book_type_code = p_Book_Type_Code
                     and    bks.asset_id = p_Asset_Id
                     and    bks.set_of_books_id = p_set_of_books_id
                     and    bks.rowid =
                     (
                      select max(bks1.rowid)
                      from   fa_mc_books bks1,
                             fa_mc_deprn_periods dp
                      where  bks1.book_type_code = p_Book_Type_Code
                      and    bks1.asset_id = p_Asset_Id
                      and    bks1.book_type_code = dp.book_type_code
                      and    bks1.set_of_books_id = p_set_of_books_id
                      and    dp.period_counter = l_prev_year_period_counter
                      and    dp.set_of_books_id = p_set_of_books_id
                      and    bks1.date_effective <=
                             nvl(dp.period_close_date, sysdate)
                     );
                  exception
                     when others then
                        l_prev_year_adjusted_cost := l_Adjusted_Cost;
                        l_prev_year_adj_rec_cost := l_Adjusted_Recoverable_Cost;
                  end;
               else
                  begin

                     select bks.adjusted_cost,
                            bks.adjusted_recoverable_cost
                     into   l_prev_year_adjusted_cost,
                            l_prev_year_adj_rec_cost
                     from   fa_mc_books bks
                     where  bks.book_type_code = p_Book_Type_Code
                     and    bks.asset_id = p_Asset_Id
                     and    bks.set_of_books_id = p_set_of_books_id
                     and    bks.rowid =
                     (
                      select min(bks1.rowid)
                      from   fa_mc_books bks1
                      where  bks1.book_type_code = p_Book_Type_Code
                      and    bks1.asset_id = p_Asset_Id
                      and    bks1.set_of_books_id = p_set_of_books_id
                     );
                  exception
                     when others then
                        l_prev_year_adjusted_cost := l_Adjusted_Cost;
                        l_prev_year_adj_rec_cost := l_Adjusted_Recoverable_Cost;
                  end;
               end if;
         end;

      else
         Begin /* Bug 6450906  Added Exception handling*/
		select  deprn_reserve
		into    l_first_year_reserve
		from    fa_deprn_summary
		where   book_type_code  = p_Book_Type_Code
		and     asset_id = p_Asset_Id
		and     period_counter = l_first_year_period_counter;
	Exception
		when no_data_found then
		l_first_year_reserve := 0;
	End;

	Begin   /* Bug 6450906  Added Exception handling*/
		select  deprn_reserve
		into    l_prev_year_reserve
		from    fa_deprn_summary
		where   book_type_code  = p_Book_Type_Code
		and     asset_id = p_Asset_Id
		and     period_counter = l_prev_year_period_counter;
	Exception
		when no_data_found then
		l_prev_year_reserve := 0;
	End;

         -- Fix for Bug #5550557.  Need to catch if books summary row
         -- does not exist.
         begin

            select  polish_deprn_basis,
                    polish_adj_rec_cost
            into    l_prev_year_adjusted_cost,
                    l_prev_year_adj_rec_cost
            from    fa_books_summary
            where   book_type_code  = p_Book_Type_Code
            and     asset_id = p_Asset_Id
            and     period_counter = l_prev_year_period_counter;

            -- Fix for Bug #5907258.  If these values are null, can cause
            -- data corruption.  Needs to be fixed first.
            if (l_prev_year_adjusted_cost is null) or
               (l_prev_year_adj_rec_cost is null) then

               fa_srvr_msg.add_message(
                  calling_fn => 'fa_polish_pvt.calc_polish_rate_cost',
                  name       => '***FA_POLISH_NULL_COST***',
         p_log_level_rec => p_log_level_rec);
                 raise polish_err;
            end if;

         exception

            when no_data_found then

               select min(period_counter)
               into   l_min_period_counter
               from   fa_deprn_periods
               where  book_type_code = p_Book_Type_Code;

               if (l_prev_year_period_counter >= l_min_period_counter) then

                  begin

                     select bks.adjusted_cost,
                            bks.adjusted_recoverable_cost
                     into   l_prev_year_adjusted_cost,
                            l_prev_year_adj_rec_cost
                     from   fa_books bks
                     where  bks.book_type_code = p_Book_Type_Code
                     and    bks.asset_id = p_Asset_Id
                     and    bks.rowid =
                     (
                      select max(bks1.rowid)
                      from   fa_books bks1,
                             fa_deprn_periods dp
                      where  bks1.book_type_code = p_Book_Type_Code
                      and    bks1.asset_id = p_Asset_Id
                      and    bks1.book_type_code = dp.book_type_code
                      and    dp.period_counter = l_prev_year_period_counter
                      and    bks1.date_effective <=
                             nvl(dp.period_close_date, sysdate)
                     );
                  exception
                     when others then
                        l_prev_year_adjusted_cost := l_Adjusted_Cost;
                        l_prev_year_adj_rec_cost := l_Adjusted_Recoverable_Cost;
                  end;
               else
                  begin

                     select bks.adjusted_cost,
                            bks.adjusted_recoverable_cost
                     into   l_prev_year_adjusted_cost,
                            l_prev_year_adj_rec_cost
                     from   fa_books bks
                     where  bks.book_type_code = p_Book_Type_Code
                     and    bks.asset_id = p_Asset_Id
                     and    bks.rowid =
                     (
                      select min(bks1.rowid)
                      from   fa_books bks1
                      where  bks1.book_type_code = p_Book_Type_Code
                      and    bks1.asset_id = p_Asset_Id
                     );
                  exception
                     when others then
				l_prev_year_adjusted_cost := l_Adjusted_Cost;
				l_prev_year_adj_rec_cost := l_Adjusted_Recoverable_Cost;
                  end;
               end if;
         end;
      end if;

      if (l_transaction_type_code  = 'ADJUSTMENT') then

         -- Check to see if the ADJUSTMENT occurred in a past fiscal year
         -- from this current period.  If it did, we will need to do the
         -- switch test again even though we may be in the middle of the
         -- year.  If the transaction occurred in the same fiscal year, we
         -- may change the basis, but we would still stay with the same
         -- switch rate since we're not doing the re-test again.
         -- If the current period counter - period adjustment occurred >=
         -- period num then the adjustment occurred in a previous year.
         if (l_period_counter - (l_bef_trxn_period_counter + 1) >=
             p_Period_Num) then

            -- Adjustment occurred in previous year
            l_previous_year_adjustment := TRUE;

            -- Fix for Bug #5710413.  Need to use correct adjusted cost
            -- for the previous year.
            if (p_MRC_SOB_Type_Code = 'R') then

               select adjusted_cost
               into   l_prev_year_adjusted_cost
               from   fa_mc_books
               where  asset_id = p_asset_id
               and    book_type_code = p_book_type_code
               and    transaction_header_id_out is null
               and    set_of_books_id = p_set_of_books_id;

            else
               select adjusted_cost
               into   l_prev_year_adjusted_cost
               from   fa_books
               where  asset_id = p_asset_id
               and    book_type_code = p_book_type_code
               and    transaction_header_id_out is null;
            end if;

         else
            -- Adjustment occurred in current year
            -- ??? Do we need logic for if adjustment in a future year?
            l_previous_year_adjustment := FALSE;
         end if;

      elsif (l_transaction_type_code  = 'PARTIAL RETIREMENT') then
         -- Same logic as above.  Partial retirements cannot cross fiscal
         -- years.  However, in the year after the retirement, we still
         -- need to subtract the previous reserve  when doing the switch test.
         if (l_period_counter - (l_bef_trxn_period_counter + 1) >=
             p_Period_Num) then

            -- Retirement occurred in previous year
            l_previous_year_retirement := TRUE;
         else

            -- Retirement occurred in current year
            -- ??? Do we need logic for if retirement in a future year?
            l_previous_year_retirement := FALSE;
         end if;
      end if;
   end if;

   -- ========================== End Calculate Transaction Switch Values === --
   --                                                                        --
   -- === Derive Rate ====================================================== --

   -- Calculate the rate and switch code for this period.

   if (not FA_POLISH_PVT.Calc_Rate (
                    p_book_type_code         => p_book_type_code,
                    p_asset_id               => p_asset_id,
                    p_polish_rule            => p_polish_rule,
                    p_year_of_life           => l_year_of_life,
                    p_year_retired           => p_year_retired,
                    p_period_counter         => l_period_counter,
                    p_first_period_counter   => l_first_period_counter,
                    p_open_period_counter    => l_open_period_counter,
                    p_period_num             => p_period_num,
                    p_periods_per_year       => p_periods_per_year,
                    p_adjusted_rate          => p_rate,
                    p_deprn_factor           => p_deprn_factor,
                    p_alternate_deprn_factor => p_alternate_deprn_factor,
                    p_depreciate_flag        => p_depreciate_flag,
                    p_first_year_reserve     => l_first_year_reserve,
                    p_prev_year_reserve      => l_prev_year_reserve,
                    p_prev_year_adjusted_cost
                                             => l_prev_year_adjusted_cost,
                    p_prev_year_adj_rec_cost => l_prev_year_adj_rec_cost,
                    p_mrc_sob_type_code      => p_mrc_sob_type_code,
                    p_set_of_books_id        => p_set_of_books_id,
                    x_adjusted_rate          => l_adjusted_rate,
                    x_depreciate_flag        => l_depreciate_flag,
                    x_switch_code            => l_switch_code
   , p_log_level_rec => p_log_level_rec)) then
        raise polish_err;
   end if;

   -- ================================ End Derive Rate ===================== --
   --                                                                        --
   -- === Calculate New Basis ============================================== --

   if ((l_transaction_type_code = 'NONE') or
       ((l_transaction_type_code = 'ADJUSTMENT') and
        (l_previous_year_adjustment)) or
       ((l_transaction_type_code = 'ADJUSTMENT') and (l_pos_neg_adjustment is null)) or	 /* Brahma 6989831. This perticular statement is added for non cost adjustments like Dereciation checkbox unselected and selected again */
       ((l_transaction_type_code = 'PARTIAL RETIREMENT') and
        (l_previous_year_retirement))) then

      -- Determine the basis depending on the switch
      if (l_switch_code in ('30', 'DM')) then

         -- Set the basis to be the fully reservable cost
         l_adjusted_cost := nvl(l_adjusted_recoverable_cost, 0);

      elsif (l_switch_code = 'D2') then

         -- Set the basis to be cost - previous year rsv + 1st year rsv
         l_adjusted_cost := nvl(l_prev_year_adj_rec_cost,
                                l_adjusted_recoverable_cost) -
                            nvl(l_prev_year_reserve,0) +
                            nvl(l_first_year_reserve,0);
         l_adjusted_recoverable_cost := nvl(l_prev_year_adj_rec_cost,
                                            l_adjusted_recoverable_cost);

      elsif (l_switch_code = 'SD') then

         -- Set the basis to be the cost - previous year rsv
         l_adjusted_cost := nvl(l_prev_year_adj_rec_cost,
                                 l_adjusted_recoverable_cost) -
                            nvl(l_prev_year_reserve,0);
         l_adjusted_recoverable_cost := nvl(l_prev_year_adj_rec_cost,
                                            l_adjusted_recoverable_cost);

      elsif (l_switch_code = 'FR') then

         -- Set the basis to be the fully reservable cost
         l_adjusted_cost := nvl(l_prev_year_adj_rec_cost,
                                l_adjusted_recoverable_cost);
         l_adjusted_recoverable_cost := nvl(l_prev_year_adj_rec_cost,
                                            l_adjusted_recoverable_cost);

      end if;

  else
      -- Need to copy into separate variables since can't have same
      -- as IN and OUT parameters when using NOCOPY
      l_adjusted_cost_old := l_adjusted_cost;
      l_adj_rec_cost_old := l_adjusted_recoverable_cost;

      -- Calculate the new basis depending on the transaction
   if (l_transaction_type_code = 'ADJUSTMENT') then

      if not (Calc_Basis_Trxn (
         p_book_type_code             => p_Book_Type_Code,
         p_transaction_type_code      => l_transaction_type_code,
         p_pos_neg_adjustment         => l_pos_neg_adjustment,
         p_polish_adj_calc_basis_flag => p_polish_adj_calc_basis_flag,
         p_adjusted_cost              => l_adjusted_cost_old,
         p_adjusted_recoverable_cost  => l_adj_rec_cost_old,
         p_prev_adj_rec_cost          => l_prev_adj_rec_cost,
         p_prev_reserve               => l_prev_reserve,
         p_prev_basis                 => l_prev_basis,
         p_adjustment_amount          => l_adjustment_amount,
         p_retirement_amount          => l_retirement_amount,
         p_switch_code                => l_switch_code,
         p_set_of_books_id            => p_set_of_books_id,
         x_adjusted_cost              => l_adjusted_cost,
         x_adjusted_recoverable_cost  => l_adjusted_recoverable_cost,
         p_log_level_rec              => p_log_level_rec
      )) then
         raise polish_err;
      end if;
   end if;
end if;

   -- ================================================== End Audit Trail === --
   --                                                                        --
   -- === Set OUT Parameters =============================================== --

   x_Adjusted_Cost := l_adjusted_cost;
   x_Adjusted_Recoverable_Cost := l_adjusted_recoverable_cost;
   x_Depreciate_Flag := l_depreciate_flag;
   x_Rate := l_adjusted_rate;

   -- =========================================== End Set OUT Parameters === --
   X_Success := 1;


EXCEPTION
   WHEN polish_err THEN

      if (sqlcode <> 0) then
        fa_rx_conc_mesg_pkg.log(sqlerrm);
      end if;

      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_polish_pvt.Calc_Polish_Rate_Cost',  p_log_level_rec => p_log_level_rec);
      x_Rate := 0;
      X_Success := 0;

   WHEN OTHERS THEN

      if (sqlcode <> 0) then
        fa_rx_conc_mesg_pkg.log(sqlerrm);
      end if;

      fa_srvr_msg.add_sql_error (
          calling_fn => 'fa_polish_pvt.Calc_Polish_Rate_Cost',  p_log_level_rec => p_log_level_rec);
      x_Rate := 0;
      X_Success := 0;

END Calc_Polish_Rate_Cost;

FUNCTION Calc_Basis_Neg_Adj_Flag_Yes (
                    p_book_type_code         IN            VARCHAR2,
                    p_old_cost               IN            NUMBER,
                    p_old_reserve            IN            NUMBER,
                    p_adjustment_amount      IN            NUMBER,
                    p_set_of_books_id        IN            NUMBER,
                    x_new_deprn_basis           OUT NOCOPY NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

   l_adjustment_reserve number;
   l_adjustment_nbv     number;

   l_dummy_bool         boolean;

BEGIN

   l_adjustment_reserve := p_old_reserve * p_adjustment_amount / p_old_cost;

   l_adjustment_nbv := p_adjustment_amount - l_adjustment_reserve;

   x_new_deprn_basis := p_old_cost - l_adjustment_nbv;

   l_dummy_bool := fa_utils_pkg.faxrnd (x_new_deprn_basis, p_Book_Type_Code, p_set_of_books_id, p_log_level_rec => p_log_level_rec);

   return (TRUE);

EXCEPTION
   WHEN OTHERS THEN

      if (sqlcode <> 0) then
        fa_rx_conc_mesg_pkg.log(sqlerrm);
      end if;

      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_polish_pvt.Calc_Basis_Neg_Adj_Flag_Yes',  p_log_level_rec => p_log_level_rec);
      return (FALSE);
END Calc_Basis_Neg_Adj_Flag_Yes;

FUNCTION Calc_Basis_Neg_Adj_Flag_No (
                    p_book_type_code         IN            VARCHAR2,
                    p_old_cost               IN            NUMBER,
                    p_old_deprn_basis        IN            NUMBER,
                    p_adjustment_amount      IN            NUMBER,
                    p_set_of_books_id        IN            NUMBER,
                    x_new_deprn_basis           OUT NOCOPY NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

   l_dummy_bool       boolean;

BEGIN

   x_new_deprn_basis := p_old_deprn_basis -
                        (p_old_deprn_basis * p_adjustment_amount /
                         p_old_cost);

   l_dummy_bool := fa_utils_pkg.faxrnd (x_new_deprn_basis, p_Book_Type_Code, p_set_of_books_id, p_log_level_rec => p_log_level_rec);

   return (TRUE);

EXCEPTION
   WHEN OTHERS THEN

      if (sqlcode <> 0) then
        fa_rx_conc_mesg_pkg.log(sqlerrm);
      end if;

      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_polish_pvt.Calc_Basis_Neg_Adj_Flag_No',  p_log_level_rec => p_log_level_rec);
      return (FALSE);

END Calc_Basis_Neg_Adj_Flag_No;

FUNCTION Calc_Basis_Partial_Ret (
                    p_book_type_code         IN            VARCHAR2,
                    p_old_cost               IN            NUMBER,
                    p_old_deprn_basis        IN            NUMBER,
                    p_retirement_amount      IN            NUMBER,
                    p_set_of_books_id        IN            NUMBER,
                    x_new_deprn_basis           OUT NOCOPY NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

   l_dummy_bool       boolean;

BEGIN

   x_new_deprn_basis := p_old_deprn_basis -
                        (p_old_deprn_basis * p_retirement_amount /
                         p_old_cost);

   l_dummy_bool := fa_utils_pkg.faxrnd (x_new_deprn_basis, p_Book_Type_Code, p_set_of_books_id, p_log_level_rec => p_log_level_rec);

   return (TRUE);

EXCEPTION
   WHEN OTHERS THEN

      if (sqlcode <> 0) then
        fa_rx_conc_mesg_pkg.log(sqlerrm);
      end if;

      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_polish_pvt.Calc_Basis_Partial_Ret',  p_log_level_rec => p_log_level_rec);
      return (FALSE);

END Calc_Basis_Partial_Ret;

FUNCTION Calc_Basis_Trxn (
                    p_book_type_code         IN            VARCHAR2,
                    p_transaction_type_code  IN            VARCHAR2,
                    p_pos_neg_adjustment     IN            VARCHAR2,
                    p_polish_adj_calc_basis_flag
                                             IN            VARCHAR2,
                    p_adjusted_cost          IN            NUMBER,
                    p_adjusted_recoverable_cost
                                             IN            NUMBER,
                    p_prev_adj_rec_cost      IN            NUMBER,
                    p_prev_basis             IN            NUMBER,
                    p_prev_reserve           IN            NUMBER,
                    p_adjustment_amount      IN            NUMBER,
                    p_retirement_amount      IN            NUMBER,
                    p_switch_code            IN            VARCHAR2,
                    p_set_of_books_id        IN            NUMBER,
                    x_adjusted_cost             OUT NOCOPY NUMBER,
                    x_adjusted_recoverable_cost OUT NOCOPY NUMBER,
                    p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

   basis_err      exception;
Begin

   if ((p_transaction_type_code = 'ADJUSTMENT') and
       (p_pos_neg_adjustment = 'NEG')) then

      -- Calculate new basis
      if (p_Polish_Adj_Calc_Basis_Flag = 'Y') then
         if not (Calc_Basis_Neg_Adj_Flag_Yes (
            p_book_type_code    => p_book_type_code,
            p_old_cost          => p_prev_adj_rec_cost,
            p_old_reserve       => p_prev_reserve,
            p_adjustment_amount => p_adjustment_amount,
            p_set_of_books_id   => p_set_of_books_id,
            x_new_deprn_basis   => x_adjusted_cost,
            p_log_level_rec     => p_log_level_rec
         )) then
            raise basis_err;
         end if;

         -- For a negative adjustment with the polish_adj_calc_basis_flag
         -- checked, we over-depreciate the asset, setting the cost at
         -- which it becomes fully reserved, i.e., the
         -- adjusted_recoverable_cost to the new basis.
         x_adjusted_recoverable_cost := x_adjusted_cost;

      else
         if not (Calc_Basis_Neg_Adj_Flag_No (
            p_book_type_code    => p_book_type_code,
            p_old_cost          => p_prev_adj_rec_cost,
            p_old_deprn_basis   => p_prev_basis,
            p_adjustment_amount => p_adjustment_amount,
            p_set_of_books_id   => p_set_of_books_id,
            x_new_deprn_basis   => x_adjusted_cost,
            p_log_level_rec     => p_log_level_rec
         )) then
            raise basis_err;
         end if;

         -- These values don't change from the defaults
         x_adjusted_recoverable_cost := p_Adjusted_Recoverable_Cost;
      end if;

   elsif ((p_transaction_type_code = 'ADJUSTMENT') and
          (p_pos_neg_adjustment = 'POS')) then

      -- For a positive adjustment, the new basis is just the new
      -- cost if the switch is currently FR.  However, for anything else,
      -- the basis stays the same as it was before the adjustment.
      if (p_switch_code = 'FR') then
         x_adjusted_cost := p_adjusted_cost;
         x_adjusted_recoverable_cost := p_adjusted_cost;

      else
         -- Need to go w/ the value before the adjustment occurred.
         x_adjusted_cost := p_prev_basis;

         -- We will change the fully reservable cost to reflect the new cost
         -- however.
         x_adjusted_recoverable_cost := p_adjusted_recoverable_cost;
      end if;
   elsif (p_transaction_type_code = 'PARTIAL RETIREMENT') then

      if not (Calc_Basis_Partial_Ret (
         p_book_type_code    => p_book_type_code,
         p_old_cost          => p_prev_adj_rec_cost,
         p_old_deprn_basis   => p_prev_basis,
         p_retirement_amount => p_retirement_amount,
         p_set_of_books_id   => p_set_of_books_id,
         x_new_deprn_basis   => x_adjusted_cost,
         p_log_level_rec     => p_log_level_rec
      )) then
         raise basis_err;
      end if;

      -- These values don't change from the defaults
      x_adjusted_recoverable_cost := p_Adjusted_Recoverable_Cost;
   end if;

   return (TRUE);

EXCEPTION
   WHEN basis_err THEN

      if (sqlcode <> 0) then
        fa_rx_conc_mesg_pkg.log(sqlerrm);
      end if;

      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_polish_pvt.Calc_Basis_Trxn',  p_log_level_rec => p_log_level_rec);
      return (FALSE);

   WHEN OTHERS THEN

      if (sqlcode <> 0) then
        fa_rx_conc_mesg_pkg.log(sqlerrm);
      end if;

      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_polish_pvt.Calc_Basis_Trxn',  p_log_level_rec => p_log_level_rec);
      return (FALSE);
END Calc_Basis_Trxn;

FUNCTION Calc_Trxn_Values (
                    p_book_type_code         IN            VARCHAR2,
                    p_asset_id               IN            NUMBER,
                    p_transaction_type_code  IN            VARCHAR2,
                    p_transaction_header_id  IN            NUMBER,
                    p_first_period_counter   IN            NUMBER,
                    p_mrc_sob_type_code      IN            VARCHAR2,
                    p_set_of_books_id        IN            NUMBER,
                    p_calling_mode           IN            VARCHAR2,
                    x_adjustment_amount         OUT NOCOPY NUMBER,
                    x_retirement_amount         OUT NOCOPY NUMBER,
                    x_bef_trxn_period_counter   OUT NOCOPY NUMBER,
                    x_pos_neg_adjustment        OUT NOCOPY VARCHAR2,
                    x_prev_basis                OUT NOCOPY NUMBER,
                    x_prev_adj_rec_cost         OUT NOCOPY NUMBER,
                    x_prev_reserve              OUT NOCOPY NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

   l_amortization_start_date     date;
   l_debit_credit_flag           varchar2(2);
   l_min_period_counter          number;

   polish_err                    exception;

BEGIN

   -- ??? Probably need to still account for multiple adjustments or
   -- partial retirements in a single period.  If we get the max id, we'd
   -- be missing some transactions.  Maybe need to do a sum or something.
   if (p_transaction_type_code = 'ADJUSTMENT') then

      if (p_calling_mode = 'ADJUSTMENT') then

         l_amortization_start_date := FA_POLISH_PVT.amortization_start_date;

         if (p_mrc_sob_type_code = 'R') then

            select period_counter - 1
            into   x_bef_trxn_period_counter
            from   fa_mc_deprn_periods
            where  book_type_code = p_Book_Type_Code
            and    set_of_books_id = p_set_of_books_id
            and    l_amortization_start_date between
                   calendar_period_open_date and calendar_period_close_date;
         else
            select period_counter - 1
            into   x_bef_trxn_period_counter
            from   fa_deprn_periods
            where  book_type_code = p_Book_Type_Code
            and    l_amortization_start_date between
                   calendar_period_open_date and calendar_period_close_date;
         end if;

         -- Can't go before the first period of the asset's life
         if (x_bef_trxn_period_counter < p_first_period_counter) then
            x_bef_trxn_period_counter := p_first_period_counter;
         end if;

         x_adjustment_amount := FA_POLISH_PVT.adjustment_amount;

         if (x_adjustment_amount > 0) then
            -- Positive adjustment
            x_pos_neg_adjustment := 'POS';
         else
            x_pos_neg_adjustment := 'NEG';

            -- Always need to have this positive.
            x_adjustment_amount := x_adjustment_amount * -1;
         end if;

      else  /* Brahma 6989831. If the transaction is not cost based then the following query returns no rows. so handle that exception */

	 if (p_MRC_SOB_Type_Code = 'R') then
            -- Determine if it's a positive or negative adj, amount and period
            -- immediately before the period of adjustment
	   Begin
              select adjustment_amount,
                     debit_credit_flag
               into  x_adjustment_amount,
                     l_debit_credit_flag
               from  fa_mc_adjustments
               where book_type_code  = p_Book_Type_Code
               and   asset_id = p_Asset_Id
               and   transaction_header_id = p_transaction_header_id
               and   set_of_books_id = p_set_of_books_id
               and   source_type_code = 'ADJUSTMENT'
               and   adjustment_type = 'COST';
  	   Exception
	       when no_data_found then
		  x_adjustment_amount := 0;
   		  l_debit_credit_flag := null;
           End;
         else
	    Begin
               select adjustment_amount,
                      debit_credit_flag
               into  x_adjustment_amount,
                     l_debit_credit_flag
               from  fa_adjustments
               where book_type_code  = p_Book_Type_Code
               and   asset_id = p_Asset_Id
               and   transaction_header_id = p_transaction_header_id
               and   source_type_code = 'ADJUSTMENT'
               and   adjustment_type = 'COST';
	    Exception
	       when no_data_found then
		 x_adjustment_amount := 0;
		 l_debit_credit_flag := null;
	    End;
         end if;

         if ((l_debit_credit_flag = 'CR') and (x_adjustment_amount >= 0)) then

            -- Negative adjustment
            x_pos_neg_adjustment := 'NEG';

         elsif ((l_debit_credit_flag = 'DR') and (x_adjustment_amount < 0)) then
            -- Negative adjustment
            x_pos_neg_adjustment := 'NEG';

            -- Flip the adjustment amount
            x_adjustment_amount := x_adjustment_amount * -1;

         elsif ((l_debit_credit_flag = 'CR') and (x_adjustment_amount < 0)) then
            -- Positive adjustment
            x_pos_neg_adjustment := 'POS';

         elsif ((l_debit_credit_flag = 'DR') and (x_adjustment_amount >= 0)) then

            -- Positive adjustment
            x_pos_neg_adjustment := 'POS';

            -- Flip the adjustment amount
            x_adjustment_amount := x_adjustment_amount * -1;
         end if;
      end if; /* End of  if (p_calling_mode = 'ADJUSTMENT') then */

      if (p_calling_mode = 'DEPRN') then

         if (x_pos_neg_adjustment = 'POS') then

            if (p_MRC_SOB_Type_Code = 'R') then

               select dp.period_counter - 1
               into   x_bef_trxn_period_counter
               from   fa_mc_deprn_periods dp,
                      fa_transaction_headers th
               where  th.transaction_header_id = p_transaction_header_id
               and    dp.book_type_code = p_Book_Type_Code
               and    dp.set_of_books_id = p_set_of_books_id
               and    th.date_effective between
                      dp.period_open_date and
                      nvl(dp.period_close_date, sysdate);
            else

               select dp.period_counter - 1
               into   x_bef_trxn_period_counter
               from   fa_deprn_periods dp,
                      fa_transaction_headers th
               where  th.transaction_header_id = p_transaction_header_id
               and    dp.book_type_code = p_Book_Type_Code
               and    th.date_effective between
                      dp.period_open_date and
                      nvl(dp.period_close_date, sysdate);
            end if;

            -- Can't go before the first period of the asset's life
            if (x_bef_trxn_period_counter < p_first_period_counter) then
               x_bef_trxn_period_counter := p_first_period_counter;
            end if;

         elsif (x_pos_neg_adjustment = 'NEG') then

            if (p_MRC_SOB_Type_Code = 'R') then

               select dp.period_counter - 1
               into   x_bef_trxn_period_counter
               from   fa_mc_deprn_periods dp,
                      fa_transaction_headers th
               where  th.transaction_header_id = p_transaction_header_id
               and    dp.book_type_code = p_Book_Type_Code
               and    dp.set_of_books_id = p_set_of_books_id
               and    th.transaction_date_entered between
                      dp.calendar_period_open_date and
                      dp.calendar_period_close_date;
            else

               select dp.period_counter - 1
               into   x_bef_trxn_period_counter
               from   fa_deprn_periods dp,
                      fa_transaction_headers th
               where  th.transaction_header_id = p_transaction_header_id
               and    dp.book_type_code = p_Book_Type_Code
               and    th.transaction_date_entered between
                      dp.calendar_period_open_date and
                      dp.calendar_period_close_date;
            end if;

            -- Can't go before the first period of the asset's life
            if (x_bef_trxn_period_counter < p_first_period_counter) then
               x_bef_trxn_period_counter := p_first_period_counter;
            end if;
         end if;
      end if; /* End if of if (p_calling_mode = 'DEPRN') then */

      -- Determine the cost and the reserve in the period before the adj
      if (p_MRC_SOB_Type_Code = 'R') then

         -- Fix for Bug #5550557.  Need to catch if books summary row
         -- does not exist.
         begin
            select polish_deprn_basis,
                   polish_adj_rec_cost
            into   x_prev_basis,
                   x_prev_adj_rec_cost
            from   fa_mc_books_summary
            where  book_type_code = p_Book_Type_Code
            and    asset_id = p_Asset_Id
            and    period_counter = x_bef_trxn_period_counter
            and    set_of_books_id = p_set_of_books_id;

            -- Fix for Bug #5907258.  If these values are null, can cause
            -- data corruption.  Needs to be fixed first.
            if (x_prev_basis is null) or
               (x_prev_adj_rec_cost is null) then

               fa_srvr_msg.add_message(
                  calling_fn => 'fa_polish_pvt.calc_trxn_values',
                  name       => '***FA_POLISH_NULL_COST***',
         p_log_level_rec => p_log_level_rec);

               raise polish_err;
            end if;

         exception

            when no_data_found then

               select min(period_counter)
               into   l_min_period_counter
               from   fa_mc_deprn_periods
               where  book_type_code = p_Book_Type_Code
               and    set_of_books_id = p_set_of_books_id;

               if (x_bef_trxn_period_counter >= l_min_period_counter) then

                  begin

                     select bks.adjusted_cost,
                            bks.adjusted_recoverable_cost
                     into   x_prev_basis,
                            x_prev_adj_rec_cost
                     from   fa_mc_books bks
                     where  bks.book_type_code = p_Book_Type_Code
                     and    bks.asset_id = p_Asset_Id
                     and    bks.set_of_books_id = p_set_of_books_id
                     and    bks.rowid =
                     (
                      select max(bks1.rowid)
                      from   fa_mc_books bks1,
                             fa_mc_deprn_periods dp
                      where  bks1.book_type_code = p_Book_Type_Code
                      and    bks1.asset_id = p_Asset_Id
                      and    bks1.book_type_code = dp.book_type_code
                      and    bks1.set_of_books_id = p_set_of_books_id
                      and    dp.period_counter = x_bef_trxn_period_counter
                      and    dp.set_of_books_id = p_set_of_books_id
                      and    bks1.date_effective <=
                             nvl(dp.period_close_date, sysdate)
                     );
                  end;
               elsif (x_bef_trxn_period_counter < l_min_period_counter) then /* Brahma 6989831. when x_bef_trxn_period_counter is null then else part was getting executed. but it should not that case so added lessthan condition */
                  begin

                     select bks.adjusted_cost,
                            bks.adjusted_recoverable_cost
                     into   x_prev_basis,
                            x_prev_adj_rec_cost
                     from   fa_mc_books bks
                     where  bks.book_type_code = p_Book_Type_Code
                     and    bks.asset_id = p_Asset_Id
                     and    bks.set_of_books_id = p_set_of_books_id
                     and    bks.rowid =
                     (
                      select min(bks1.rowid)
                      from   fa_mc_books bks1
                      where  bks1.book_type_code = p_Book_Type_Code
                      and    bks1.asset_id = p_Asset_Id
                      and    bks.set_of_books_id = p_set_of_books_id
                     );
                  end;
               end if;
         end;

	 Begin /* Brahma 6989831. when x_bef_trxn_period_counter is null the following query returns no rows. so adding exception handling */
         select deprn_reserve
         into   x_prev_reserve
         from   fa_mc_deprn_summary
         where  book_type_code = p_Book_Type_Code
         and    asset_id = p_Asset_Id
         and    period_counter = x_bef_trxn_period_counter
         and    set_of_books_id = p_set_of_books_id;

	 Exception
		 when no_data_found then
			x_prev_reserve := 0;
	 End;
      else


         -- Fix for Bug #5550557.  Need to catch if books summary row
         -- does not exist.
         begin

            select polish_deprn_basis,
                   polish_adj_rec_cost
            into   x_prev_basis,
                   x_prev_adj_rec_cost
            from   fa_books_summary
            where  book_type_code = p_Book_Type_Code
            and    asset_id = p_Asset_Id
            and    period_counter = x_bef_trxn_period_counter;

            -- Fix for Bug #5907258.  If these values are null, can cause
            -- data corruption.  Needs to be fixed first.
            if (x_prev_basis is null) or
               (x_prev_adj_rec_cost is null) then

               fa_srvr_msg.add_message(
                  calling_fn => 'fa_polish_pvt.calc_trxn_values',
                  name       => '***FA_POLISH_NULL_COST***',
         p_log_level_rec => p_log_level_rec);

               raise polish_err;
            end if;

         exception

            when no_data_found then

               select min(period_counter)
               into   l_min_period_counter
               from   fa_deprn_periods
               where  book_type_code = p_Book_Type_Code;

               if (x_bef_trxn_period_counter >= l_min_period_counter) then

                  begin

                     select bks.adjusted_cost,
                            bks.adjusted_recoverable_cost
                     into   x_prev_basis,
                            x_prev_adj_rec_cost
                     from   fa_books bks
                     where  bks.book_type_code = p_Book_Type_Code
                     and    bks.asset_id = p_Asset_Id
                     and    bks.rowid =
                     (
                      select max(bks1.rowid)
                      from   fa_books bks1,
                             fa_deprn_periods dp
                      where  bks1.book_type_code = p_Book_Type_Code
                      and    bks1.asset_id = p_Asset_Id
                      and    bks1.book_type_code = dp.book_type_code
                      and    dp.period_counter = x_bef_trxn_period_counter
                      and    bks1.date_effective <=
                             nvl(dp.period_close_date, sysdate)
                     );
                  end;
               elsif (x_bef_trxn_period_counter < l_min_period_counter) then /* Brahma 6989831. when x_bef_trxn_period_counter is null then else part was getting executed. but it should not that case so added lessthan condition */
                  begin

                     select bks.adjusted_cost,
                            bks.adjusted_recoverable_cost
                     into   x_prev_basis,
                            x_prev_adj_rec_cost
                     from   fa_books bks
                     where  bks.book_type_code = p_Book_Type_Code
                     and    bks.asset_id = p_Asset_Id
                     and    bks.rowid =
                     (
                      select min(bks1.rowid)
                      from   fa_books bks1
                      where  bks1.book_type_code = p_Book_Type_Code
                      and    bks1.asset_id = p_Asset_Id
                     );
                  end;
               end if;
         end;

	 Begin /* Brahma 6989831. when x_bef_trxn_period_counter is null the following query returns no rows. so adding exception handling  */
		select deprn_reserve
	         into   x_prev_reserve
		 from   fa_deprn_summary
	         where  book_type_code = p_Book_Type_Code
	         and    asset_id = p_Asset_Id
	         and    period_counter = x_bef_trxn_period_counter;
	 Exception
		 when no_data_found then
			x_prev_reserve := 0;
	 End;
      end if;

      -- Fix for Bug #3629784.  If you have an asset with a following month
      -- prorate convention, the basis will be 0 in the first period of its
      -- life since you don't want to depreciate until the next period.
      -- However, if you do an adjustment that is effective in the second
      -- period, the previous basis will get a value of 0, which you don't
      -- want.  You need the actual cost here since you do want to
      -- depreciate in the 2nd period.
      if (x_bef_trxn_period_counter = p_first_period_counter) then
         x_prev_basis := x_prev_adj_rec_cost;
      end if;
   elsif (p_transaction_type_code = 'PARTIAL RETIREMENT') then

      -- Get the retirement values
      if (p_MRC_SOB_Type_Code = 'R') then

         select adjustment_amount,
                debit_credit_flag
         into   x_retirement_amount,
                l_debit_credit_flag
         from   fa_mc_adjustments
         where  book_type_code = p_Book_Type_Code
         and    asset_id = p_Asset_Id
         and    transaction_header_id = p_transaction_header_id
         and    source_type_code = 'RETIREMENT'
         and    adjustment_type = 'COST'
         and    set_of_books_id = p_set_of_books_id;

         select dp.period_counter - 1
         into   x_bef_trxn_period_counter
         from   fa_mc_deprn_periods dp,
                fa_transaction_headers th
         where  th.transaction_header_id = p_transaction_header_id
         and    dp.book_type_code = p_Book_Type_Code
         and    dp.set_of_books_id = p_set_of_books_id
         and    th.transaction_date_entered between
                dp.calendar_period_open_date and
                dp.calendar_period_close_date;

      else

         select adjustment_amount,
                debit_credit_flag
         into   x_retirement_amount,
                l_debit_credit_flag
         from   fa_adjustments
         where  book_type_code = p_Book_Type_Code
         and    asset_id = p_Asset_Id
         and    transaction_header_id = p_transaction_header_id
         and    source_type_code = 'RETIREMENT'
         and    adjustment_type = 'COST';

         select dp.period_counter - 1
         into   x_bef_trxn_period_counter
         from   fa_deprn_periods dp,
                fa_transaction_headers th
         where  th.transaction_header_id = p_transaction_header_id
         and    dp.book_type_code = p_Book_Type_Code
         and    th.transaction_date_entered between
                dp.calendar_period_open_date and
                dp.calendar_period_close_date;
      end if;

      -- Can't go before the first period of the asset's life
      if (x_bef_trxn_period_counter < p_first_period_counter) then
         x_bef_trxn_period_counter := p_first_period_counter;
      end if;

      if (l_debit_credit_flag = 'DR') then
         -- Flip adjustment_amount
         x_retirement_amount := x_retirement_amount * -1;
      end if;

      -- Determine the cost in the period before the retirement
      if (p_MRC_SOB_Type_Code = 'R') then

         -- Fix for Bug #5550557.  Need to catch if books summary row
         -- does not exist.
         begin

            select polish_deprn_basis,
                   polish_adj_rec_cost
            into   x_prev_basis,
                   x_prev_adj_rec_cost
            from   fa_mc_books_summary
            where  book_type_code = p_Book_Type_Code
            and    asset_id = p_Asset_Id
            and    period_counter = x_bef_trxn_period_counter
            and    set_of_books_id = p_set_of_books_id;

            -- Fix for Bug #5907258.  If these values are null, can cause
            -- data corruption.  Needs to be fixed first.
            if (x_prev_basis is null) or
               (x_prev_adj_rec_cost is null) then

               fa_srvr_msg.add_message(
                  calling_fn => 'fa_polish_pvt.calc_trxn_values',
                  name       => '***FA_POLISH_NULL_COST***',
         p_log_level_rec => p_log_level_rec);

               raise polish_err;
            end if;

         exception

            when no_data_found then

               select min(period_counter)
               into   l_min_period_counter
               from   fa_mc_deprn_periods
               where  book_type_code = p_Book_Type_Code
               and    set_of_books_id = p_set_of_books_id;

               if (x_bef_trxn_period_counter >= l_min_period_counter) then

                  begin

                     select bks.adjusted_cost,
                            bks.adjusted_recoverable_cost
                     into   x_prev_basis,
                            x_prev_adj_rec_cost
                     from   fa_mc_books bks
                     where  bks.book_type_code = p_Book_Type_Code
                     and    bks.asset_id = p_Asset_Id
                     and    bks.set_of_books_id = p_set_of_books_id
                     and    bks.rowid =
                     (
                      select max(bks1.rowid)
                      from   fa_mc_books bks1,
                             fa_mc_deprn_periods dp
                      where  bks1.book_type_code = p_Book_Type_Code
                      and    bks1.asset_id = p_Asset_Id
                      and    bks1.set_of_books_id = p_set_of_books_id
                      and    bks1.book_type_code = dp.book_type_code
                      and    dp.period_counter = x_bef_trxn_period_counter
                      and    dp.set_of_books_id = p_set_of_books_id
                      and    bks1.date_effective <=
                             nvl(dp.period_close_date, sysdate)
                     );
                  end;
               else
                  begin

                     select bks.adjusted_cost,
                            bks.adjusted_recoverable_cost
                     into   x_prev_basis,
                            x_prev_adj_rec_cost
                     from   fa_mc_books bks
                     where  bks.book_type_code = p_Book_Type_Code
                     and    bks.asset_id = p_Asset_Id
                     and    bks.set_of_books_id = p_set_of_books_id
                     and    bks.rowid =
                     (
                      select min(bks1.rowid)
                      from   fa_mc_books bks1
                      where  bks1.book_type_code = p_Book_Type_Code
                      and    bks1.asset_id = p_Asset_Id
                      and    bks1.set_of_books_id = p_set_of_books_id
                     );
                  end;
               end if;
         end;

      else

         -- Fix for Bug #5550557.  Need to catch if books summary row
         -- does not exist.
         begin

            select polish_deprn_basis,
                   polish_adj_rec_cost
            into   x_prev_basis,
                   x_prev_adj_rec_cost
            from   fa_books_summary
            where  book_type_code = p_Book_Type_Code
            and    asset_id = p_Asset_Id
            and    period_counter = x_bef_trxn_period_counter;

            -- Fix for Bug #5907258.  If these values are null, can cause
            -- data corruption.  Needs to be fixed first.
            if (x_prev_basis is null) or
               (x_prev_adj_rec_cost is null) then

               fa_srvr_msg.add_message(
                  calling_fn => 'fa_polish_pvt.calc_trxn_values',
                  name       => '***FA_POLISH_NULL_COST***',
         p_log_level_rec => p_log_level_rec);

               raise polish_err;
            end if;

         exception

            when no_data_found then

               select min(period_counter)
               into   l_min_period_counter
               from   fa_deprn_periods
               where  book_type_code = p_Book_Type_Code;

               if (x_bef_trxn_period_counter >= l_min_period_counter) then

                  begin

                     select bks.adjusted_cost,
                            bks.adjusted_recoverable_cost
                     into   x_prev_basis,
                            x_prev_adj_rec_cost
                     from   fa_books bks
                     where  bks.book_type_code = p_Book_Type_Code
                     and    bks.asset_id = p_Asset_Id
                     and    bks.rowid =
                     (
                      select max(bks1.rowid)
                      from   fa_books bks1,
                             fa_deprn_periods dp
                      where  bks1.book_type_code = p_Book_Type_Code
                      and    bks1.asset_id = p_Asset_Id
                      and    bks1.book_type_code = dp.book_type_code
                      and    dp.period_counter = x_bef_trxn_period_counter
                      and    bks1.date_effective <=
                             nvl(dp.period_close_date, sysdate)
                     );
                  end;
               else
                  begin

                     select bks.adjusted_cost,
                            bks.adjusted_recoverable_cost
                     into   x_prev_basis,
                            x_prev_adj_rec_cost
                     from   fa_books bks
                     where  bks.book_type_code = p_Book_Type_Code
                     and    bks.asset_id = p_Asset_Id
                     and    bks.rowid =
                     (
                      select min(bks1.rowid)
                      from   fa_books bks1
                      where  bks1.book_type_code = p_Book_Type_Code
                      and    bks1.asset_id = p_Asset_Id
                     );
                  end;
               end if;
         end;
     end if;

      -- Fix for Bug #3629784.  If you have an asset with a following month
      -- prorate convention, the basis will be 0 in the first period of its
      -- life since you don't want to depreciate until the next period.
      -- However, if you do a retirement that is effective in the second
      -- period, the previous basis will get a value of 0, which you don't
      -- want.  You need the actual cost here since you do want to
      -- depreciate in the 2nd period.
      if (x_bef_trxn_period_counter = p_first_period_counter) then
         x_prev_basis := x_prev_adj_rec_cost;
      end if;
   end if;

   return (TRUE);

EXCEPTION

   WHEN polish_err THEN

      if (sqlcode <> 0) then
        fa_rx_conc_mesg_pkg.log(sqlerrm);
      end if;

      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_polish_pvt.Calc_Basis_Trxn',  p_log_level_rec => p_log_level_rec);
      return (FALSE);

   WHEN OTHERS THEN

      if (sqlcode <> 0) then
        fa_rx_conc_mesg_pkg.log(sqlerrm);
      end if;

      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_polish_pvt.Calc_Basis_Trxn',  p_log_level_rec => p_log_level_rec);
      return (FALSE);
END Calc_Trxn_Values;

FUNCTION Calc_Rate (
                    p_book_type_code         IN            VARCHAR2,
                    p_asset_id               IN            NUMBER,
                    p_polish_rule            IN            NUMBER,
                    p_year_of_life           IN            NUMBER,
                    p_year_retired           IN            VARCHAR2,
                    p_period_counter         IN            NUMBER,
                    p_first_period_counter   IN            NUMBER,
                    p_open_period_counter    IN            NUMBER,
                    p_period_num             IN            NUMBER,
                    p_periods_per_year       IN            NUMBER,
                    p_adjusted_rate          IN            NUMBER,
                    p_deprn_factor           IN            NUMBER,
                    p_alternate_deprn_factor IN            NUMBER,
                    p_depreciate_flag        IN            VARCHAR2,
                    p_first_year_reserve     IN            NUMBER,
                    p_prev_year_reserve      IN            NUMBER,
                    p_prev_year_adjusted_cost
                                             IN            NUMBER,
                    p_prev_year_adj_rec_cost IN            NUMBER,
                    p_mrc_sob_type_code      IN            VARCHAR2,
                    p_set_of_books_id        IN            NUMBER,
                    x_adjusted_rate             OUT NOCOPY NUMBER,
                    x_depreciate_flag           OUT NOCOPY VARCHAR2,
                    x_switch_code               OUT NOCOPY VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

   FA_POLISH_30_RULE             constant number := .3;

   l_prev_switch_code            varchar2(2);
   l_new_basis                   number;
   l_switch_value                number;

   calc_rate_err                 exception;

BEGIN

   -- Default values
   x_adjusted_rate := p_adjusted_rate;
   x_depreciate_flag := p_depreciate_flag;
   x_switch_code := 'XX';

   -- In an asset's first year of life, it has a specific rate and switch
   -- code.  In addition, we do not do the switch test in the first year.
   if ((p_year_of_life = 1) and (p_Year_Retired = 'N')) then

      if (p_Polish_Rule in (FA_STD_TYPES.FAD_DBR_POLISH_1,
                            FA_STD_TYPES.FAD_DBR_POLISH_2)) then

         x_switch_code := '30';

      elsif (p_Polish_Rule in (FA_STD_TYPES.FAD_DBR_POLISH_3,
                               FA_STD_TYPES.FAD_DBR_POLISH_4)) then

         x_switch_code := 'DM';

      elsif (p_Polish_Rule = FA_STD_TYPES.FAD_DBR_POLISH_5) then

         x_switch_code := 'SD';

      else
         -- Not one of the 5 Polish Mechanisms.

         fa_srvr_msg.add_message(
            calling_fn => 'fa_polish_pvt.calc_rate',
            name       => '***FA_POLISH_INVALID_MECH***',
         p_log_level_rec => p_log_level_rec);

         raise calc_rate_err;
      end if;
   end if;

   -- After the first year, some mechanisms automatically move to a new switch
   if ((p_year_of_life > 1) and (p_Year_Retired = 'N')) then
      if (p_Polish_Rule in (FA_STD_TYPES.FAD_DBR_POLISH_1,
                            FA_STD_TYPES.FAD_DBR_POLISH_3)) then
         if (p_Year_Of_Life = 2) then

            -- For 2nd year, rate is adj_rate * deprn_factor
            -- No switch test is done in the second year
            x_switch_code := 'D2';
            x_adjusted_rate := p_adjusted_rate * p_Deprn_Factor;

         else
            -- After year 2, we will always need to do the switch test.
            -- We're going to use XX to signify that we'll figure out the
            -- switch and new basis later.
            x_switch_code := 'XX';

         end if;
      elsif (p_Polish_Rule in (FA_STD_TYPES.FAD_DBR_POLISH_2,
                               FA_STD_TYPES.FAD_DBR_POLISH_4)) then
          -- After the first year, rate is adj_rate
          -- No switch test is done
          x_switch_code := 'FR';
          x_adjusted_rate := p_adjusted_rate;

      elsif (p_Polish_Rule = FA_STD_TYPES.FAD_DBR_POLISH_5) then
         -- For Mech 5, we do the switch test immediately after year 1.
         -- We're going to use XX to signify that we'll figure out the
         -- switch and new basis later.
         x_switch_code := 'XX';

      end if;
   end if;

   -- Check if old period
   if ((x_switch_code = 'XX') and
       (p_period_counter < p_open_period_counter)) then

      -- We never modify a switch_code once we set it, so if we are doing a
      -- backdated transaction or something else where we're looking at old
      -- periods, just take the switch_code that was there originally.  The
      -- nvl is to handle perhaps a method change where the asset wasn't
      -- always a Polish one.
      if (p_mrc_sob_type_code = 'R') then

         begin

            select nvl(switch_code, 'XX')
            into   x_switch_code
            from   fa_mc_books_summary
            where  book_type_code = p_book_type_code
            and    asset_id = p_asset_id
            and    period_counter = p_period_counter
            and     set_of_books_id = p_set_of_books_id;
         exception
             when no_data_found then
                null;
         end;
      else

         begin
            select nvl(switch_code, 'XX')
            into   x_switch_code
            from   fa_books_summary
            where  book_type_code = p_book_type_code
            and    asset_id = p_asset_id
            and    period_counter = p_period_counter;
         exception
             when no_data_found then
                null;
         end;
      end if;
   end if;

   -- Check previous switch code rules
   if (x_switch_code = 'XX') then
      if (p_mrc_sob_type_code = 'R') then

         begin
            select nvl(switch_code, 'XX')
            into   l_prev_switch_code
            from   fa_mc_books_summary
            where  book_type_code = p_book_type_code
            and    asset_id = p_asset_id
            and    period_counter = p_period_counter - 1
            and    set_of_books_id = p_set_of_books_id;
         exception
             when no_data_found then
                l_prev_switch_code := 'XX';
         end;
      else

         begin
            select nvl(switch_code, 'XX')
            into   l_prev_switch_code
            from   fa_books_summary
            where  book_type_code = p_book_type_code
            and    asset_id = p_asset_id
            and    period_counter = p_period_counter - 1;
         exception
             when no_data_found then
                l_prev_switch_code := 'XX';
         end;
      end if;

      -- You never change the switch with a fiscal year, so after the first
      -- period.
      if (p_period_num > 1) then
         x_switch_code := l_prev_switch_code;

      -- You can never move backwards in the switch chain, so once the switch
      -- is at FR, it stays there.
      elsif (p_period_num = 1) then
         if (l_prev_switch_code = 'FR') then
            x_switch_code := 'FR';
         end if;
      end if;
   end if;

   -- Do the switch test if necessary.  The switch test is always based on
   -- old data, and specifically, what happened after the last period of the
   -- previous fiscal year close.  Even if a transaction occurred in the
   -- current period, even the first period, it does not affect the switch
   -- code.  Transactions such as this would only affect the basis.  It would
   -- not affect the switch until the nexte year.  Even backdated transactions
   -- have no effect since you cannot change the switch code within the
   -- fiscal year.  Once the year end for a fiscal year has closed, the
   -- switch code for the next year is set.
   --
   -- Here is how the switch test is derived.
   --
   -- The switch formula is as follows:
   -- (basis for D2) * (rate for D2) / pers_per_year <=
   -- (basis for FR) * (rate for FR) / pers_per_year.
   --
   --  This derives into: (when cancelling common variables)
   --
   -- (adjusted_cost for D2) * (adj_rate * deprn_factor) <=
   -- (adjusted_cost) * (adj_rate)
   --
   --  Further deriving into:
   --
   --  (adjusted_cost - prev_yr_rsv + first_yr_rsv) * deprn_factor
   --   <= (adjusted_cost)
   --
   --  This simiplied switch rule is common to Polish mechanisms
   --  1 and 3.  For mechanism 5, we just want the nbv and don't
   --  want to add back the first year reserve for the formula is:
   --
   --  (adjusted_cost - prev_yr_rsv) * deprn_factor <= (adjusted_cost)
   --
   if (x_switch_code = 'XX') then
      if (p_Polish_Rule in (FA_STD_TYPES.FAD_DBR_POLISH_1,
                            FA_STD_TYPES.FAD_DBR_POLISH_3)) then

         -- Switch between D2 and FR

         l_new_basis := p_prev_year_adjusted_cost - p_prev_year_reserve +
                        p_first_year_reserve;

         l_switch_value := l_new_basis * p_deprn_factor;

         -- Now do switch test
         if (l_switch_value > p_prev_year_adjusted_cost) then

            -- Stay with current D2
            x_switch_code := 'D2';
         else
            -- Switch to FR
            x_switch_code := 'FR';
         end if;

      elsif (p_Polish_Rule = FA_STD_TYPES.FAD_DBR_POLISH_5) then

         -- Switch between SD and FR

         l_new_basis := p_prev_year_adj_rec_cost - p_prev_year_reserve;

         l_switch_value := l_new_basis * p_deprn_factor;

         -- Now do switch test
         if (l_switch_value > p_prev_year_adj_rec_cost) then

            -- Stay with current SD
            x_switch_code := 'SD';

          else
            -- Switch to FR
            x_switch_code := 'FR';

         end if;
      end if;
   end if;

   -- Set the rate based on the switch code derived.
   if (x_switch_code = '30') then

      if (p_period_counter = p_first_period_counter) then

         -- We're multiplying the rate by the periods in the year because
         -- for the first year, we want to take the entire year's worth of
         -- depreciation in a single period when the switch is 30.  For the
         -- rest of the year, we'll turn the depreciate flag off.
         x_adjusted_rate := FA_POLISH_30_RULE * p_Periods_Per_Year;

         -- Note that an adjustment does not affect the rate or basis
         -- here since an adjustment in the period of addition creates
         -- an ADDITION/ADDITION VOID row rather than an ADJUSTMENT row
         -- Similarly, you can't retirement an asset in the period of add
         -- ???  How about an asset with a FOL MONTH convention and an
         -- ??? ADJUSTMENT that occurs in the period after addition?
         -- After discussion w/ Som, we decided to use our judgment and
         -- take the new cost after the adjustment as the new basis
         -- since depreciation had not been taken yet.  For example, if
         -- user added an asset w/ cost 10K in March w/ FOL MON convention,
         -- and in April, adjusted the cost to 20K, we would use 20K as the
         -- the basis in April when we apply the 30% rule.

      else
         -- When switch is 30, don't depreciate the asset in the first year
         -- after the first period
         x_adjusted_rate := 0;
         x_depreciate_flag := 'NO';

         -- Note that transactions such as adjustments do not affect
         -- the rate here.
      end if;
   elsif (x_switch_code = 'DM') then
      -- When switch is DM, rate is adj_rate * alt_deprn_factor
      x_adjusted_rate := p_adjusted_rate * p_Alternate_Deprn_Factor;

   elsif (x_switch_code in ('D2','SD')) then
      -- When switch is D2 or SD, rate is adj_rate * deprn_factor
      x_adjusted_rate := p_adjusted_rate * p_Deprn_Factor;
   elsif (x_switch_code = 'FR') then
      -- When switch is FR, rate is adj_rate
      x_adjusted_rate := p_adjusted_rate;
   else
      -- Unknown switch_code.
      fa_srvr_msg.add_message(
         calling_fn => 'fa_polish_pvt.calc_rate',
         name       => '***FA_POLISH_INVALID_SWITCH_CODE***',
         p_log_level_rec => p_log_level_rec);

      raise calc_rate_err;
   end if;

   return (TRUE);

EXCEPTION
   WHEN calc_rate_err THEN

      if (sqlcode <> 0) then
        fa_rx_conc_mesg_pkg.log(sqlerrm);
      end if;

      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_polish_pvt.Calc_Rate',  p_log_level_rec => p_log_level_rec);
      return (FALSE);
   WHEN OTHERS THEN

      if (sqlcode <> 0) then
        fa_rx_conc_mesg_pkg.log(sqlerrm);
      end if;

      fa_srvr_msg.add_sql_error (
         calling_fn => 'fa_polish_pvt.Calc_Rate',  p_log_level_rec => p_log_level_rec);
      return (FALSE);
END Calc_Rate;

END FA_POLISH_PVT;

/
