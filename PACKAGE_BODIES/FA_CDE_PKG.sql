--------------------------------------------------------
--  DDL for Package Body FA_CDE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CDE_PKG" AS
/* $Header: FACDEB.pls 120.90.12010000.17 2010/04/28 08:30:04 dvjoshi ship $ */

   ROUND_WITH_RESTRICTIONS CONSTANT INTEGER:= 0;
   ROUND_ALWAYS CONSTANT INTEGER:= 1;

   g_tested_use_annual_round BOOLEAN:= FALSE;
   g_use_annual_round        INTEGER:= ROUND_WITH_RESTRICTIONS;
   primary_cost              NUMBER;
   g_pre_period_name         fa_calendar_periods.period_name%TYPE;
   g_pre_period_ctr          fa_calendar_periods.period_num%TYPE;
   g_pre_fyctr               fa_fiscal_year.fiscal_year%TYPE;


FUNCTION faxgpr (
        X_dpr_ptr                       fa_std_types.dpr_struct,
        X_period                        fa_std_types.fa_cp_struct,
        X_projecting_flag               BOOLEAN,
        X_prodn           IN OUT NOCOPY NUMBER,
        p_log_level_rec   IN            FA_API_TYPES.log_level_rec_type default null)
RETURN BOOLEAN IS

   h_dist_book VARCHAR2(30);

   CURSOR PROD IS
        SELECT  ROWID,
                used_flag used,
                production *
                (LEAST (TO_DATE (X_period.end_jdate, 'J'), end_date) -
                GREATEST (TO_DATE (X_period.start_jdate, 'J'), start_date) + 1)
                / (end_date - start_date + 1) prod
        FROM    FA_PERIODIC_PRODUCTION
        WHERE   asset_id = X_dpr_ptr.asset_id
        AND     book_type_code = h_dist_book
        AND     start_date <= TO_DATE (X_period.end_jdate, 'J')
        AND     end_date >= TO_DATE (X_period.start_jdate, 'J')
        FOR UPDATE OF used_flag NOWAIT;

BEGIN <<FAXGPR>>

   -- Get fa_book_controls.distribution_source_book since
   -- production is only stored in the corporate book.

   -- fazcbc cache should have already been called don't call again -bmr

   h_dist_book := fa_cache_pkg.fazcbc_record.distribution_source_book;
   X_prodn := 0;

   FOR h IN PROD LOOP
      X_prodn := X_prodn + h.prod;

      IF NOT X_projecting_flag AND  h.used <> 'YES'  THEN
         UPDATE  FA_PERIODIC_PRODUCTION
         SET     Used_Flag = 'YES'
         WHERE   ROWID = h.ROWID;

         IF SQL%NOTFOUND THEN
            fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxgpr',
                                    name            => 'FA_DEPRN_FETCH_PROD',
                                    p_log_level_rec => p_log_level_rec);
            RAISE NO_DATA_FOUND;
         END IF;
      END IF;

   END LOOP;

   RETURN (TRUE);

EXCEPTION
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_cde_pkg.faxgpr', p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
END FAXGPR;

FUNCTION faxgtr (
        X_method_id                    NUMBER,
        X_year_of_life                 NUMBER,
        X_prorate_period               NUMBER,
        X_rate              OUT NOCOPY NUMBER,
        p_log_level_rec  IN            FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

BEGIN <<FAZGTR>>

   SELECT  rate
   INTO    X_rate
   FROM    fa_rates
   WHERE   method_id = X_method_id
   AND     YEAR = X_year_of_life
   AND     period_placed_in_service = X_prorate_period;

   RETURN (TRUE);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      X_rate := 0;
      RETURN (TRUE);
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_cde_pkg.faxgtr', p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
END FAXGTR;

-- syoung: Take out remaining life calculation
-- this can be called from Pro*C during deprn or when mass change is run
PROCEDURE faxgfr (X_Book_Type_Code         IN            VARCHAR2,
                  X_Asset_Id               IN            NUMBER,
                  X_Short_Fiscal_Year_Flag IN            VARCHAR2,
                  X_Conversion_Date        IN            DATE := NULL,
                  X_Prorate_Date           IN            DATE := NULL,
                  X_Orig_Deprn_Start_Date  IN            DATE := NULL,
                  C_Prorate_Date           IN            VARCHAR2 := NULL,
                  C_Conversion_Date        IN            VARCHAR2 := NULL,
                  C_Orig_Deprn_Start_Date  IN            VARCHAR2 := NULL,
                  X_Method_Code            IN            VARCHAR2,
                  X_Life_In_Months         IN            INTEGER,
                  X_Fiscal_Year            IN            NUMBER,
                  X_Current_Period         IN            NUMBER,
                  X_calling_interface      IN            VARCHAR2 DEFAULT NULL,
                  X_new_cost               IN            NUMBER DEFAULT NULL,
                  X_adjusted_cost          IN            NUMBER DEFAULT NULL,
                  X_Rate                      OUT NOCOPY NUMBER,
                  X_Method_Type               OUT NOCOPY NUMBER,
                  X_Success                   OUT NOCOPY INTEGER,
                  p_log_level_rec          IN            FA_API_TYPES.log_level_rec_type default null) IS

   h_method_id             NUMBER;
   h_formula               VARCHAR2(4000);
   h_formula_parsed        VARCHAR2(4000);
   h_cursor                NUMBER;
   h_return_code           NUMBER;
   h_count1                NUMBER;
   h_count2                NUMBER;
   h_prod_method           NUMBER := 0;
   h_rem_life1             NUMBER;
   h_rem_life2             NUMBER;
   h_conversion_date       DATE := X_Conversion_Date;
   h_prorate_date          DATE := X_Prorate_Date;
   h_orig_deprn_start_date DATE := X_Orig_Deprn_Start_Date;
   h_deprn_basis_rule      VARCHAR2(4);
   cache_exception         EXCEPTION;
   rem_life_exception      EXCEPTION;
   rate_null_exception     EXCEPTION;
   rate_neg_exception      EXCEPTION;
   l_original_Rate         NUMBER;
   l_Revised_Rate          NUMBER;
   l_Guaranteed_Rate       NUMBER;
   l_is_revised_rate       NUMBER;
   h_msg_count             NUMBER := 0;
   h_msg_data              VARCHAR2(512);

BEGIN <<FAXGFR>>

   -- Fix for Bug #2629724.  Call the fazccmt cache to improve perf.
   IF (NOT fa_cache_pkg.fazccmt(X_Method        => X_Method_Code,
                                X_Life          => X_Life_In_Months,
                                p_log_level_rec => p_log_level_rec)) THEN
      RAISE cache_exception;
   END IF;

   h_method_id := fa_cache_pkg.fazccmt_record.method_id;
   h_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;
   h_formula_parsed := fa_cache_pkg.fazcfor_record.formula_parsed;

   h_count1 := INSTR (h_formula_parsed, 'REMAINING_LIFE1');
   h_count2 := INSTR (h_formula_parsed, 'REMAINING_LIFE2');
   h_prod_method := INSTR (fa_cache_pkg.fazcfor_record.formula_actual, 'CAPACITY');

   X_Method_Type := 0;

   -- Bug:5930979:Japan Tax Reform Project (Start)
   IF fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag = 'YES' THEN

      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.ADD('FAXGFR','+++ in', fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, p_log_level_rec);
         fa_debug_pkg.ADD('FAXGFR','+++ X_new_cost', X_new_cost, p_log_level_rec);
         fa_debug_pkg.ADD('FAXGFR','+++ X_adjusted_cost', X_adjusted_cost, p_log_level_rec);
      END IF;

      IF X_calling_interface IN ('FAXCDE')  AND (X_new_cost IS NOT NULL  AND X_adjusted_cost IS NOT NULL) THEN
         h_formula_parsed := REPLACE(h_formula_parsed, 'ADJUSTED_COST', TO_CHAR(X_adjusted_cost));
         h_formula_parsed := REPLACE(h_formula_parsed, 'COST', TO_CHAR(X_new_cost));

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('FAXGFR','+++ faxcde Cost', X_new_cost, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD('FAXGFR','+++ faxcde NBV', X_adjusted_cost, p_log_level_rec => p_log_level_rec);
         END IF; -- debug
      END IF; -- calling interface
   END IF; -- guarantee_rate method
   -- Bug:5930979:Japan Tax Reform Project (End)

   IF (h_count1 > 0 OR h_count2 > 0) THEN

      IF (h_conversion_date IS NULL) THEN
         IF (C_Conversion_Date = 'DD/MM/YYYY') THEN
            h_conversion_date := NULL;
         ELSE
            h_conversion_date := TO_DATE(C_Conversion_Date, 'DD/MM/YYYY');
         END IF;
      END IF;

      IF (h_prorate_date IS NULL) THEN
         h_prorate_date := TO_DATE(C_Prorate_Date, 'DD/MM/YYYY');
      END IF;

      IF (h_orig_deprn_start_date IS NULL) THEN
         IF (C_Orig_Deprn_Start_Date = 'DD/MM/YYYY') THEN
            h_orig_deprn_start_date := NULL;
         ELSE
            h_orig_deprn_start_date := TO_DATE(C_Orig_Deprn_Start_Date, 'DD/MM/YYYY');
         END IF;
      END IF;

      IF (NOT faxgrl(
                X_Asset_Id               => X_Asset_Id,
                X_Book_Type_Code         => X_Book_Type_Code,
                X_Short_Fiscal_Year_Flag => X_Short_Fiscal_Year_Flag,
                X_Prorate_Date           => h_prorate_date,
                X_Conversion_Date        => h_conversion_Date,
                X_Orig_Deprn_Start_Date  => h_orig_deprn_start_date,
                X_Fiscal_Year            => X_Fiscal_Year,
                X_Life_In_Months         => X_Life_In_Months,
                X_Method_Code            => X_Method_Code,
                X_Current_Period         => X_Current_Period,
                X_rem_life1              => h_rem_life1,
                X_rem_life2              => h_rem_life2,
                p_log_level_rec          => p_log_level_rec)) THEN
         RAISE rem_life_exception;
      END IF;

      h_formula_parsed := REPLACE(h_formula_parsed, 'REMAINING_LIFE1', TO_CHAR(h_rem_life1));
      h_formula_parsed := REPLACE(h_formula_parsed, 'REMAINING_LIFE2', TO_CHAR(h_rem_life2));

   END IF;

   -- fix for 4685808
   h_formula_parsed := REPLACE(h_formula_parsed, 'LIFE_IN_MONTHS', TO_CHAR(X_Life_In_Months));

   -- Fix for Bug #2939771.  Use bind variables.
   h_formula := 'SELECT ' || h_formula_parsed ||
                ' rate FROM fa_books fabk, fa_deprn_periods fadp ' ||
                ' WHERE (fabk.asset_id = :v1) ' ||
                ' AND (fabk.book_type_code = :v2' ||
                ' ) AND (fabk.book_type_code = fadp.book_type_code) ' ||
                ' AND (fabk.date_ineffective is null) ' ||
                ' AND (fadp.period_close_date is null)';

   IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.ADD('FAXGFR','+++ stmt:', h_formula, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD('FAXGFR','+++ stmt:', h_formula_parsed, p_log_level_rec => p_log_level_rec);
   END IF;

   -- Open the cursor for processing.
   h_cursor := dbms_sql.open_cursor;

   -- Parse the query.
   dbms_sql.parse(h_cursor,h_formula,1);

   -- Bind X_asset_id to the placeholder.
   dbms_sql.bind_variable (h_cursor, ':v1', X_Asset_ID);
   dbms_sql.bind_variable (h_cursor, ':v2', X_Book_Type_Code);

   -- Define the output variable, rate.
   dbms_sql.define_column (h_cursor, 1, X_Rate);

   -- Execute the statement.  We don't care about the
   -- return value, but we do need to declare a variable
   -- for it.
   h_return_code := dbms_sql.EXECUTE(h_cursor);

   -- This is the fetch loop.
   LOOP
      IF dbms_sql.fetch_rows (h_cursor) = 0 THEN
         EXIT;
      END IF;

      dbms_sql.column_value (h_cursor, 1, X_rate);
   END LOOP;

   -- Close the cursor.
   dbms_sql.close_cursor (h_cursor);

   ---Added by Satish Byreddy For Method Code JP-250DB XX
   IF X_rate is NULL THEN

      h_formula := 'SELECT ' || h_formula_parsed || ' rate FROM dual';

      -- Open the cursor for processing.
      h_cursor := dbms_sql.open_cursor;

      -- Parse the query.
      dbms_sql.parse(h_cursor,h_formula,1);

      -- Bind X_asset_id to the placeholder.

      -- Define the output variable, rate.
      dbms_sql.define_column (h_cursor, 1, X_Rate);

      -- Execute the statement.  We don't care about the
      -- return value, but we do need to declare a variable
      -- for it.
      h_return_code := dbms_sql.EXECUTE(h_cursor);

      -- This is the fetch loop.
      LOOP
         IF dbms_sql.fetch_rows (h_cursor) = 0 THEN
            EXIT;
         END IF;

         dbms_sql.column_value (h_cursor, 1, X_rate);
      END LOOP;

      -- Close the cursor.
      dbms_sql.close_cursor (h_cursor);
   END IF;
   ---End OF Addition by Satish Byreddy For Method Code JP-250DB XX

   -- Fix for Bug #2421998.  For a formula that uses remaining life, we
   -- need to take this into account so that the depreciation is allocated
   -- correctly in the last year of its life.  For example, if there are
   -- only 3 months left in the life, the rate per month should be
   -- four times what is calculated since the asset needs to be fully
   -- reserved at the end of the third month.  We only want to do this
   -- with assets that use remaining life 1 in the formula method  and
   -- not remaining life 2 and the deprn basis rule is COST.  For NBV
   -- methods, we just use 1 / (h_rem_life1 / 12) as the rate.
   IF ((h_rem_life1 > 0) AND (h_rem_life1 < 12) AND
       (NVL(X_Short_Fiscal_Year_Flag, 'NO') <> 'YES') AND
       (h_count1 > 0) AND (h_count2 = 0)) THEN

      IF (h_deprn_basis_rule = 'COST') THEN
              X_Rate := X_Rate * (12 / h_rem_life1);
      ELSIF (h_deprn_basis_rule = 'NBV') THEN
              X_Rate := GREATEST (X_Rate, 1 / (h_rem_life1 / 12));
      END IF;
   END IF;

   -- Bug:5930979:Japan Tax Reform Project (Start)
   IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.ADD('FAXGFR','+++ guarantee_flag', fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, p_log_level_rec);
      fa_debug_pkg.ADD('FAXGFR','+++ X_calling_interface', X_calling_interface, p_log_level_rec);
      fa_debug_pkg.ADD('FAXGFR','+++ guarantee_flag', fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, p_log_level_rec);
      fa_debug_pkg.ADD('FAXGFR','+++ X_calling_interface', X_calling_interface, p_log_level_rec);
      fa_debug_pkg.ADD('FAXGFR','+++ X_rate', X_rate, p_log_level_rec);
   END IF;

   IF fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag = 'YES' THEN
      IF X_calling_interface IS NULL THEN
         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('FAXGFR','+++ Fetching current rate from fa_books', 'YES', p_log_level_rec => p_log_level_rec);
         END IF; -- _debug

         SELECT rate_in_use
         INTO X_Rate
         FROM ( SELECT rate_in_use,
                       rank() over(order by transaction_header_id_in desc) rank
                  FROM fa_books
                 WHERE book_type_code = X_Book_Type_Code
                   AND asset_id = X_Asset_Id
                   AND deprn_method_code = X_Method_Code
              )
         WHERE rank = 1;

      END IF;  -- X_calling_interface is null

   END IF; -- guarantee rate flag
   -- Bug:5930979:Japan Tax Reform Project (End)

   IF (X_Rate IS NULL) THEN
      RAISE rate_null_exception;
   END IF;

   IF (X_Rate < 0) THEN
      RAISE rate_neg_exception;
   END IF;

   X_Success := 1;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxgfr',
                              name            => 'FA_FORMULA_RATE_NO_DATA_FOUND',
                              token1          => 'ASSET_ID',
                              value1          => TO_CHAR(X_Asset_Id),
                              p_log_level_rec => p_log_level_rec);
      X_rate := 0;
      X_Success := -2;
   WHEN ZERO_DIVIDE THEN
      fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxgfr',
                              name            => 'FA_FORMULA_RATE_ZERO_DIVIDE',
                              token1          => 'ASSET_ID',
                              value1          => TO_CHAR(X_Asset_Id),
                              p_log_level_rec => p_log_level_rec);
      X_rate := 0;
      X_Success := 1;
   WHEN cache_exception THEN
      fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxgfr',
                              name            => 'FA_SHARED_INVALID_METHOD_RATE',
                              p_log_level_rec => p_log_level_rec);
      X_rate := 0;
      X_Success := -7;
   WHEN rate_null_exception THEN
      fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxgfr',
                              name            => 'FA_FORMULA_RATE_NULL',
                              token1          => 'ASSET_ID',
                              value1          => TO_CHAR(X_Asset_Id),
                              p_log_level_rec => p_log_level_rec);
      X_rate := 0;
      X_Success := -4;
   WHEN rem_life_exception THEN
      fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxgfr',
                              name            => 'FA_FORMULA_RATE_LIFE',
                              token1          => 'ASSET_ID',
                              value1          => TO_CHAR(X_Asset_Id),
                              p_log_level_rec => p_log_level_rec);
      X_rate := 0;
      X_Success := -5;
   WHEN rate_neg_exception THEN
      fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxgfr',
                              name            => 'FA_FORMULA_RATE_NEGATIVE',
                              token1          => 'ASSET_ID',
                              value1          => TO_CHAR(ROUND(X_Rate, 5)),
                              p_log_level_rec => p_log_level_rec);
      X_rate := 0;
      X_Success := 1;
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn      => 'fa_cde_pkg.faxgfr',
                                p_log_level_rec => p_log_level_rec);
      X_rate := 0;
      X_Success := 0;
END FAXGFR;

FUNCTION faxgrl(X_Asset_Id               IN            NUMBER,
                X_Book_Type_Code         IN            VARCHAR2,
                X_Short_Fiscal_Year_Flag IN            VARCHAR2,
                X_Prorate_Date           IN            DATE,
                X_Conversion_Date        IN            DATE,
                X_Orig_Deprn_Start_Date  IN            DATE,
                X_Fiscal_Year            IN            NUMBER,
                X_Life_In_Months         IN            NUMBER,
                X_Method_Code            IN            VARCHAR2,
                X_Current_Period         IN            NUMBER,
                X_rem_life1                 OUT NOCOPY NUMBER,
                X_rem_life2                 OUT NOCOPY NUMBER,
                p_log_level_rec          IN            FA_API_TYPES.log_level_rec_type)
                        RETURN BOOLEAN IS

   X_curr_fy_start_date        DATE;
   X_curr_fy_end_date          DATE;
   X_Success                   VARCHAR2(3);
   X_Rate_Source_Rule          VARCHAR2(10) := 'FORMULA';
   h_curr_fy                   NUMBER;
   h_short_fiscal_year_flag    VARCHAR2(3);
   h_conversion_year           NUMBER;
   h_dpis                      DATE;
   -- added h_deprn_start_date for fix to Bug 1095275
   h_deprn_start_date          DATE;

BEGIN
   SELECT  fy.start_date,
           fy.end_date,
           bc2.current_fiscal_year,
           bk.date_placed_in_service,
           bk.deprn_start_date
   INTO    X_curr_fy_start_date,
           X_curr_fy_end_date,
           h_curr_fy,
           h_dpis,
           h_deprn_start_date
   FROM    fa_books bk,
           fa_fiscal_year fy,
           fa_book_controls bc,
           fa_book_controls bc2
   WHERE   bc.book_type_code = X_Book_Type_Code
   AND     fy.fiscal_year_name = bc.fiscal_year_name
   AND     fy.fiscal_year = X_Fiscal_Year
   AND     bc2.book_type_code = X_Book_Type_Code
   AND     bk.book_type_code = X_Book_Type_Code
   AND     bk.asset_id = X_Asset_Id
   AND     bk.date_ineffective IS NULL;

   IF (X_Short_Fiscal_Year_Flag = 'YES' AND
      h_curr_fy <> X_Fiscal_Year) THEN
      h_short_fiscal_year_flag := 'NO';
   ELSIF (X_Short_Fiscal_Year_Flag = 'NO' AND
          X_Conversion_Date IS NOT NULL) THEN
      SELECT COUNT(*)
      INTO   h_conversion_year
      FROM   fa_fiscal_year fy,
             fa_book_controls bc
      WHERE  bc.book_type_code = X_Book_Type_Code
      AND    bc.fiscal_year_name = fy.fiscal_year_name
      AND    X_Conversion_Date BETWEEN fy.start_date AND
                                           fy.end_date;
      IF (h_conversion_year > 0) THEN
         h_short_fiscal_year_flag := 'YES';
      END IF;
   ELSE
      h_short_fiscal_year_flag := X_Short_Fiscal_Year_Flag;
   END IF;

   -- pass h_deprn_start_date instead of prorate date for
   -- calculating remaing life. Fix for Bug 1095275

   FA_SHORT_TAX_YEARS_PKG.Calculate_Short_Tax_Vals(
                                X_Asset_Id,
                                X_Book_Type_Code,
                                h_short_fiscal_year_flag,
                                h_dpis,
                                h_deprn_start_date,
                                X_prorate_date,
                                X_Conversion_Date,
                                X_Orig_Deprn_Start_Date,
                                X_Curr_Fy_Start_Date,
                                X_Curr_Fy_End_Date,
                                NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL,
                                X_Life_In_Months,
                                X_Rate_Source_Rule,
                                X_Fiscal_Year,
                                X_Method_Code,
                                X_Current_Period,
                                X_rem_life1,
                                X_rem_life2,
                                X_Success,
                                p_log_level_rec => p_log_level_rec);
   IF (X_success = 'YES') THEN
      RETURN (TRUE);
   ELSE
      RETURN (FALSE);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END faxgrl;

FUNCTION faxcfyf (X_dpr              IN OUT NOCOPY fa_std_types.dpr_struct,
                  X_d_pers_per_yr                  NUMBER,
                  X_rate_source_rule               VARCHAR2,
                  X_y_begin                        NUMBER,
                  X_y_dead                         NUMBER,
                  X_y_ret                          NUMBER,
                  X_dp_begin                       NUMBER,
                  X_dpp_begin                      NUMBER,
                  X_dp_d_ptr         IN OUT NOCOPY NUMBER,
                  X_dp_r_ptr                       NUMBER,
                  X_dpp_r_ptr                      NUMBER,
                  X_pp_begin                       NUMBER,
                  X_pp_dead                        NUMBER,
                  X_pp_ret                         NUMBER,
                  X_by_factor        IN OUT NOCOPY NUMBER,
                  X_bp_frac          IN OUT NOCOPY NUMBER,
                  X_dp_frac          IN OUT NOCOPY NUMBER,
                  X_rp_frac          IN OUT NOCOPY NUMBER,
                  X_by_frac          IN OUT NOCOPY NUMBER,
                  X_dy_frac          IN OUT NOCOPY NUMBER,
                  X_ry_frac          IN OUT NOCOPY NUMBER,
                  X_prd_flag                       varchar2,
                  p_log_level_rec    IN            FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS
   h_by_dfrac              NUMBER;
   h_dy_dfrac              NUMBER;
   h_p_period_fracs        fa_std_types.table_fa_cp_struct;
   h_d_period_fracs        fa_std_types.table_fa_cp_struct;
   h_ctr                   NUMBER;
   h_b_temp                NUMBER;
   h_d_temp                NUMBER;
   h_r_temp                NUMBER;
   h_cur_fy                NUMBER;

BEGIN  <<FAXCFYF>>

   -- If different (or new) book, get book information
   IF last_book = X_dpr.book THEN
      NULL;
   ELSE
      -- fazcbc cache should have already been called, dont'd call it again
      last_book := X_dpr.book;
      last_pro_cal := fa_cache_pkg.fazcbc_record.PRORATE_CALENDAR;
      last_divide_evenly_flag := SUBSTR (fa_cache_pkg.fazcbc_record.DEPRN_ALLOCATION_CODE,1,1) = 'E';

      IF NOT fa_cache_pkg.fazcct (last_pro_cal, p_log_level_rec => p_log_level_rec) THEN
         fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcfyf', p_log_level_rec => p_log_level_rec);
         RETURN (FALSE);
      END IF;

      p_pers_per_yr := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;

      IF NOT fa_cache_pkg.fazcct (X_dpr.calendar_type, p_log_level_rec => p_log_level_rec) THEN
         fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcfyf', p_log_level_rec => p_log_level_rec);
         RETURN (FALSE);
      END IF;
   END IF;

   IF last_divide_evenly_flag THEN

      X_by_frac := (p_pers_per_yr + 1 - X_pp_begin) / p_pers_per_yr;

      -- Fix for Bug# 4304260, 4621761
      IF (p_pers_per_yr >= X_d_pers_per_yr) THEN
         h_by_dfrac := (p_pers_per_yr + 1 - X_dpp_begin) / p_pers_per_yr;
      ELSE
         -- Bug# 5085669
         h_by_dfrac := (X_d_pers_per_yr + 1 - X_dp_begin) / X_d_pers_per_yr;
      END IF;

      h_b_temp  := (X_d_pers_per_yr - X_dp_begin) / X_d_pers_per_yr;
   ELSE
      IF NOT fa_cache_pkg.fazcff(last_pro_cal,
                                 X_dpr.book,
                                 X_y_begin,
                                 h_p_period_fracs,
                                 p_log_level_rec) THEN
         fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcfyf', p_log_level_rec => p_log_level_rec);
         RETURN (FALSE);
      END IF;

      IF NOT fa_cache_pkg.fazcff(X_dpr.calendar_type,
                                 X_dpr.book,
                                 X_y_begin,
                                 h_d_period_fracs,
                                 p_log_level_rec) THEN
         fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcfyf', p_log_level_rec => p_log_level_rec);
         RETURN (FALSE);
      END IF;

      X_by_frac := 0;
      FOR i IN  X_pp_begin..p_pers_per_yr LOOP
         X_by_frac := X_by_frac + h_p_period_fracs(i-1).frac;
      END LOOP;

      h_by_dfrac := 0;
      FOR i IN X_dpp_begin..p_pers_per_yr LOOP
         h_by_dfrac := h_by_dfrac + h_p_period_fracs(i-1).frac;
      END LOOP;

      h_b_temp := 0;
      FOR i IN  X_dp_begin+1..X_d_pers_per_yr LOOP
         h_b_temp := h_b_temp + h_d_period_fracs(i-1).frac;
      END LOOP;
   END IF;

   X_bp_frac := h_by_dfrac - h_b_temp;

   IF X_rate_source_rule = 'TABLE' THEN
      IF h_by_dfrac <= 0 THEN
         fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcfyf',
                                 name => 'FA_DEPRN_ILLEGAL_VALUE',
                                 token1 => 'VARIABLE',
                                 value1 => 'BY_DFRAC',
                                 token2 => 'VALUE',
                                 value2 => h_by_dfrac,
                                 TRANSLATE => FALSE,
                                 p_log_level_rec => p_log_level_rec);
         RETURN (FALSE);
      END IF;

      X_by_factor := 1/h_by_dfrac;

   ELSIF X_rate_source_rule = 'FLAT' THEN
      IF h_by_dfrac <= 0 THEN
         fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcfyf',
                                 name => 'FA_DEPRN_ILLEGAL_VALUE',
                                 token1 => 'VARIABLE',
                                 value1 => 'BY_DFRAC',
                                 token2 => 'VALUE',
                                 value2 => h_by_dfrac,
                                 TRANSLATE => FALSE,
                                 p_log_level_rec => p_log_level_rec);
         RETURN (FALSE);
      END IF;

      X_by_factor := X_by_frac / h_by_dfrac;

   ELSIF X_rate_source_rule  IN ('PRODUCTION','CALCULATED', 'FORMULA') THEN
      X_by_factor := 1;
   ELSE
      fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcfyf.switch', p_log_level_rec => p_log_level_rec);
      RETURN(FALSE);
   END IF;

   IF X_y_ret <> 0 THEN
      h_cur_fy := fa_cache_pkg.fazcbc_record.CURRENT_FISCAL_YEAR;

      IF last_divide_evenly_flag THEN
         --Bug8620551
         --Added the conditon to check for daily prorate and first period.
         if p_pers_per_yr = 365 and X_prd_flag = 'Y' then
            X_ry_frac :=(X_pp_ret - X_pp_begin) / p_pers_per_yr;
            h_r_temp := 0;
         else
            X_ry_frac :=(X_pp_ret - 1) / p_pers_per_yr;
            h_r_temp := (X_dp_r_ptr - 1) / X_d_pers_per_yr;
         end if;

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcfyf(1.5.1)','p_pers_per_yr', p_pers_per_yr, p_log_level_rec);
            fa_debug_pkg.ADD('faxcfyf(1.5.1)','X_d_pers_per_yr', X_d_pers_per_yr, p_log_level_rec);
            fa_debug_pkg.ADD('faxcfyf(1.5.1)','X_ry_frac', X_ry_frac, p_log_level_rec);
            fa_debug_pkg.ADD('faxcfyf(1.5.1)','h_r_temp', h_r_temp, p_log_level_rec);
         END IF;
      ELSE
         IF NOT fa_cache_pkg.fazcff(last_pro_cal,
                                    X_dpr.book,
                                    X_y_ret,
                                    h_p_period_fracs,
                                    p_log_level_rec) THEN
            fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcfyf', p_log_level_rec => p_log_level_rec);
            RETURN (FALSE);
         END IF;

         -- Bug#4953366: if  not fa_cache_pkg.fazcff (X_dpr.calendar_type, X_dpr.book, X_y_ret,
         IF NOT fa_cache_pkg.fazcff(X_dpr.calendar_type,
                                    X_dpr.book,
                                    h_cur_fy,
                                    h_d_period_fracs,
                                    p_log_level_rec) THEN
            fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcfyf', p_log_level_rec => p_log_level_rec);
            RETURN (FALSE);
         END IF;

         --Bug# 8620551 - Added the conditon to check for daily prorate and first period.
         if p_pers_per_yr = 365 and X_prd_flag = 'Y' then
            X_ry_frac := 0;
            for i in  X_pp_begin ..  X_pp_ret-1 loop
               X_ry_frac := X_ry_frac + h_p_period_fracs(i-1).frac;
            end loop;
            h_r_temp := 0;
         else
            --
            -- Note condition 'i < X_pp_ret'; this is because no
            -- depreciation should be taken in the prorate
            -- period retired
            --
            X_ry_frac := 0;
            FOR i IN  1 ..  X_pp_ret-1 LOOP
               X_ry_frac := X_ry_frac + h_p_period_fracs(i-1).frac;
            END LOOP;

            -- Note condition 'i < *X_dp_r_ptr'; see above
            h_r_temp := 0;
            FOR i IN 1 .. X_dp_r_ptr-1 LOOP
               h_r_temp := h_r_temp + h_d_period_fracs(i-1).frac;
            END LOOP;
         end if;

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcfyf(1.5.2)','X_pp_ret', X_pp_ret, p_log_level_rec);
            fa_debug_pkg.ADD('faxcfyf(1.5.2)','X_ry_frac', X_ry_frac, p_log_level_rec);
            fa_debug_pkg.ADD('faxcfyf(1.5.2)','X_dp_r_ptr', X_dp_r_ptr, p_log_level_rec);
            fa_debug_pkg.ADD('faxcfyf(1.5.2)','h_r_temp', h_r_temp, p_log_level_rec);
         END IF;
      END IF;

      X_rp_frac := (X_y_ret - h_cur_fy)+ (X_ry_frac - h_r_temp);

      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.ADD('faxcfyf(2)','X_y_ret', X_y_ret, p_log_level_rec);
         fa_debug_pkg.ADD('faxcfyf(2)','h_cur_fy', h_cur_fy, p_log_level_rec);
         fa_debug_pkg.ADD('faxcfyf(2)','X_ry_frac', X_ry_frac, p_log_level_rec);
         fa_debug_pkg.ADD('faxcfyf(2)','h_r_temp', h_r_temp, p_log_level_rec);
         fa_debug_pkg.ADD('faxcfyf(2)','X_rp_frac', X_rp_frac, p_log_level_rec);
         fa_debug_pkg.ADD('faxcfyf(2)','X_y_begin', X_y_begin, p_log_level_rec);
      END IF;

      IF X_y_ret = X_y_begin THEN
         IF X_by_frac <= 0 THEN
            fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxcfyf',
                                    name            => 'FA_DEPRN_ILLEGAL_VALUE',
                                    token1          => 'VARIABLE',
                                    value1          => 'BY_FRAC',
                                    token2          => 'VALUE',
                                    value2          => X_by_frac,
                                    TRANSLATE       => FALSE,
                                    p_log_level_rec => p_log_level_rec);
            RETURN (FALSE);
         END IF;

         X_rp_frac := (h_by_dfrac/X_by_frac) * (X_ry_frac+X_by_frac-1) -
                             (X_bp_frac+h_r_temp+h_b_temp-1);

         IF X_dp_r_ptr = X_dp_begin THEN
            X_bp_frac := X_rp_frac;
         END IF;
      END IF;

      IF X_ry_frac < 0 THEN
         X_ry_frac := 0;
         X_rp_frac := 0;
      END IF;

   ELSE
      X_ry_frac := 1;
      X_rp_frac := 0;
   END IF;

   IF X_y_dead <> 0 THEN
      IF last_divide_evenly_flag THEN
         X_dy_frac := X_pp_dead / p_pers_per_yr;
         h_dy_dfrac := X_dy_frac;

         IF p_pers_per_yr = X_d_pers_per_yr THEN
               X_dp_d_ptr := X_pp_dead;
         ELSE
               X_dp_d_ptr := CEIL ( ROUND ( X_dy_frac * X_d_pers_per_yr,fa_std_types.FA_ROUND_DECIMAL));
         END IF;

         h_d_temp := (X_dp_d_ptr - 1) / X_d_pers_per_yr;
      ELSE
         IF NOT fa_cache_pkg.fazcff(last_pro_cal,
                                    X_dpr.book,
                                    X_y_dead,
                                    h_p_period_fracs,
                                    p_log_level_rec) THEN
            fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcfyf', p_log_level_rec => p_log_level_rec);
            RETURN (FALSE);
         END IF;

         IF NOT fa_cache_pkg.fazcff(X_dpr.calendar_type,
                                    X_dpr.book,
                                    X_y_dead,
                                    h_d_period_fracs,
                                    p_log_level_rec) THEN
            fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcfyf', p_log_level_rec => p_log_level_rec);
            RETURN (FALSE);
         END IF;

         -- Fixed loop ctr usage here - changed i to i-1
         X_dy_frac := 0;
         FOR i IN 1.. X_pp_dead LOOP
            X_dy_frac := X_dy_frac + h_p_period_fracs(i-1).frac;
         END LOOP;

         h_dy_dfrac := X_dy_frac;
         h_d_temp := 0;
         FOR i IN 1..X_d_pers_per_yr LOOP
            h_ctr := i;
            IF ROUND (h_d_temp+h_d_period_fracs(i-1).frac, fa_std_types.FA_ROUND_DECIMAL) >=
                    ROUND ( X_dy_frac,fa_std_types.FA_ROUND_DECIMAL) THEN
               EXIT;
            END IF;
            h_d_temp := h_d_temp + h_d_period_fracs(i-1).frac;
         END LOOP;

         X_dp_d_ptr := h_ctr;
      END IF;  -- last_divide_evenly_flag THEN

      X_dp_frac := X_dy_frac + h_d_temp;

      IF X_y_dead = X_y_ret THEN
         IF X_dy_frac > X_ry_frac THEN
            X_dy_frac := X_ry_frac;

            IF X_dp_d_ptr = X_dp_r_ptr THEN
               X_dp_frac := X_rp_frac;
            ELSE
               X_dp_frac := 0;
            END IF;
         END IF;
      END IF;

   ELSE
      X_dy_frac := 1;
      h_dy_dfrac := 1;
      X_dp_d_ptr := X_d_pers_per_yr;
      X_dp_frac := 0;
   END IF;

   RETURN (TRUE);

EXCEPTION
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error (calling_fn => 'fa_cde_pkg.faxcfyf', p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
END FAXCFYF;

/*
** Table to map new variable names to old variable names.

Old name        New name                Comment
--------        ------------            --------------------------------------
r_y_dead        fy_fully_rsv            fiscal year which asset becomes
                                        fully reserved

c_r_y_dead      fy_fully_rsv_1          Value of r_y_dead passing into
                                        faxcfyf() to calculate fraction of
                                        last year of asset's life

r_dp_dead       deprn_perd_fully_rsv    depreciation period which asset
                                        becomes fully reserved

r_pp_dead       prate_perd_fully_rsv    prorate period which asset becomes
                                        fully reserved

dpr_flag        dpr_cur_fy_flag         depreciation in current fiscal year

calc_flag       calc_rate_src_flag      deprn method uses calculate rate
                                        source rule

formula_flag    formula_rate_src_flag   deprn method uses formula rate
                                        source rule

prod_flag       prod_rate_src_flag      deprn method uses production rate
                                        source rule

table_flag      table_rate_src_flag     deprn method uses table rate source
                                        rule

flat_flag       flat_rate_src_flag      deprn method uses flat rate source rule

cost_flag       cost_deprn_basis_flag   deprn method uses cost for
                                        depreciation basis rule

nbv_flag        nbv_deprn_basis_flag    deprn method uses nbv
                                        depreciation  basis rule

fy              fy_ctr                  fiscal year counter

per             perd_ctr                period counter

ctr             dpr_arr_ctr             dpr_arr array counter

initial_rsv     initial_rsv             reserve at beginning of calculation

initial_ltd_prod initial_ltd_prod       life-to-date production at beginning of
                                        calculation

c_amt           deprn_ceiling_amt       depreciation expense ceilings amount
                                        from FA_CEILINGS to limit the annual
                                        depreciation expense

r_amt           deprn_method_amt        depreciation expense calculated by
                                        using depreciation method

c_min           use_deprn_ceil_amt      depreciation ceiling amount is less than
                                        depreciation amount calculated using
                                        depreciation method

r_min           use_deprn_prate_amt     depreciation amount calculated using
                                        depreciation method is less than
                                        using depreciation ceiling amount

temp_r_amt      temp_prate_amt          temporary amount calculated

rate
ann_deprn_rate          annsal depreciation rate

N/A             method_type             type of formula-based method (prod or life)

y_first         first_fy_flag           fiscal year is first
                                        year of asset's life

y_mid           mid_fy_flag             fiscal year is in middle of asset's
                                        life

y_last          last_fy_flag            fiscal year is last year of asset's
                                        life

y_retired       ret_fy_flag             fiscal year is year in which asset is
                                        retired

y_after         after_eol_fy_flag       fiscal year is after last year of
                                        asset's life

p_st            deprn_start_perd        first period in fiscal year to return
                                        depreciation expense

p_end           deprn_end_perd          last period in fiscal year to return
                                        depreciation expense

fy_nz_begin     actual_deprn_start_perd first period in fiscal year that has
                                        non-zero depreciation

fy_nz_end       actual_deprn_end_perd   last period in fiscal year that has
                                        non-zero depreciation

fy_amt          ann_fy_deprn            annualized depreciation amount for
                                        fiscal year

use_frac        deprn_frac_of_yr        fraction of year value used

p_deprn_exp     perd_deprn_exp          this period's depreciation amount

p_prod          perd_prod               this period's production

y_deprn_exp     year_deprn_exp          this year's Depreciation amount

y_reval_exp     year_reval_exp          this year's depreciation expense due
                                        to revaluation

y_reval_amo     year_reval_amo          this year's revaluation amortization

y_prod          year_prod               this year's production

deprn_exp_sum   deprn_exp_sum           sum of depreciation calculated

reval_exp_sum   reval_exp_sum           sum of depreciation due to revaluation

reval_amo_sum   reval_amo_sum           sum of revaluation amortization

prod_sum        prod_sum                sum of production

cur_adj_cost    cur_adj_cost            current adjusted cost

cur_deprn_rsv   cur_deprn_rsv           current depreciation reserve

cur_reval_rsv   cur_reval_rsv           current revaluation reserve

cur_reval_amo_basis                     current revaluation amortization basis

cur_ltd_prod    cur_ltd_prod            current life-to-date production

rab_rc_ratio    rab_rc_ratio            ratio of revaluation amortization basis
                                        to recoverable cost

bp_frac         first_perd_frac fraction of annual depreciation to be
                                        allocated to first period of life

by_frac         first_year_frac         fraction of annual depreciation to be
                                        allocated to first year

by_factor       adj_first_yr_frac       actual fraction of annual depreciation to be
                                        allocated to first year of asset's life based
                                        on depreciation method
dp_frac         last_perd_frac          fraction of annual depreciation to be
                                        allocated to last period of life

dy_frac         last_year_frac          fraction of annual depreciation to be
                                        allocated to last year of life

rp_frac         ret_perd_frac           fraction of annual depreciation to be
                                        allocated to retirement period

ry_frac         ret_year_frac           fraction of annual depreciation to be
                                        allocated to retirement year

period_fracs    perds_fracs_arr         array to store period fractions of
                                        fiscal year

nbv_fabs        nbv_absval              nbv absolute value

rec_cost_fabs   rec_cost_absval         recoverable cost absolute value

adj_rec_cost_fabs   adj_rec_cost_absval     adjusted recoverable cost absolut
                                            value

rsv_fabs         rsv_absval             depreciation reserve absolute value


temp_afnum

fy_name         fy_name                 fiscal year name

method_id       method_id               depreciation method id

depr_last_year_flag   depr_last_year_flag  depreciate_lastyear_flag in
                                            fa_methods

rate_cal        prorate_calendar        prorate calendar

d_pers_per_yr   perds_per_yr_dcal       number of periods per year in
                                        depreciation calendar

p_pers_per_yr   perds_per_yr_pcal       number of periods per year in prorrate
                                        calendar

tmp_ub2

use_deprn_start_jdate  actual_deprn_start_jdate

                                           For stl method, actual depreciation
                                           start date equals to asset's porate
                                           date else equals to asset's
                                           deprn_start_date

dp_begin        deprn_period_dcal_begin    depreciation starting accounting
                                           period in deprn calendar which the
                                           actual_deprn_start_jdate falls into

dpp_begin       deprn_period_pcal_begin    depreciation starting prorate period
                                           in prorate calendar which the
                                           actual_deprn_start_jdate falls into

pp_begin        prorate_period_pcal_begin  depreciation starting prorate period
                                           in prorate calendar which
                                           prorate_date falls into

dp_ret          ret_period_dcal            retirement period in deprn calendar
                                           which retirement date falls into

dpp_ret         ret_period_pcal            retirement period in prorate
                                           calendar which retirement date
                                           falls into

pp_ret          ret_prorate_period_pcal    retirement prorate period in
                                           prorate calendar which retirement
                                           prorate date falls into

dy_begin        deprn_year_dcal_begin      depreciation starting year in
                                           depreciation calendar which the
                                           actual_deprn_start_jdate falls into

dpy_begin       deprn_year_pcal_begin      depreciation starting year in
                                           prorate calendar which the
                                           actual_deprn_start_jdate falls into

y_begin         prorate_year_pcal_begin    depreciation starting year in
                                           prorate calendar which
                                           prorate date falls into

y_ret           ret_year_pcal              retirement year in prorate calendar
                                           which retirement prorate date
                                           falls into

nbv_frac_thresh    nbv_frac_thresh         nbv_fraction_threshhold in
                                           fa_book_controls

nbv_amt_thresh     nbv_amt_thresh          nbv_amount_threshhold in
                                           fa_book_controls

projecting_flag    deprn_projecting_flag


amo_reval_rsv_flag amo_reval_rsv_flag      amortize_reval_reserve_flag in
                                           fa_book_controls

raf                rate_adj_factor         rate_adjustment_factor in fa_books

cur_fy             cur_fy                  current fiscal year

deprn_limit_flag   use_deprn_limit_flag    use depreciation limit flag

adj_rec_cost       adj_rec_cost            adjusted recoverable cost

new_deprn_exp      last_period_deprn_exp   depreciation expense for the last
                                           period of asset's life

ann_deprn_amt      actual_annual_deprn_amt  actual annual depreciation amount

ytd_deprn_sum      ytd_deprn_sum           sum of all year-to-date depreciation
                                           based on number of requested periods
                                           to depreciate in a fiscal year

pfy_exp_sum        prior_fy_exp_sum        sum of depreciation expense for
                                           prior fiscal years of all requested
                                           periods

exclude_salvage_value_flag
                   excl_sal_val_flag       exclude_salvage_value_flag in
                                           fa_methods

**
*/

FUNCTION faxcde (dpr_in          IN OUT NOCOPY fa_std_types.dpr_struct,
                 dpr_arr         IN OUT NOCOPY fa_std_types.dpr_arr_type,
                 dpr_out         IN OUT NOCOPY fa_std_types.dpr_out_struct,
                 fmode                         NUMBER,
                 p_ind                         BINARY_INTEGER DEFAULT 0,
                 p_log_level_rec IN            FA_API_TYPES.log_level_rec_type default null)
RETURN BOOLEAN IS

   l_calling_fn                  VARCHAR2(20) := 'faxcde';

   dpr                           fa_std_types.dpr_struct;
   dpr_sub                       fa_std_types.dpr_struct;
   fy_fully_rsv                  NUMBER(5);
   fy_fully_rsv_1                NUMBER;
   deprn_perd_fully_rsv          NUMBER;
   prate_perd_fully_rsv          NUMBER;
   dpr_cur_fy_flag               BOOLEAN;
   calc_rate_src_flag            BOOLEAN;
   formula_rate_src_flag         BOOLEAN;
   prod_rate_src_flag            BOOLEAN;
   table_rate_src_flag           BOOLEAN;
   flat_rate_src_flag            BOOLEAN;
   cost_deprn_basis_flag         BOOLEAN;
   nbv_deprn_basis_flag          BOOLEAN;
   fy_ctr                        NUMBER;
   perd_ctr                      NUMBER;
   dpr_arr_ctr                   NUMBER;
   initial_rsv                   NUMBER;
   initial_ltd_prod              NUMBER;
   use_deprn_ceil_amt            BOOLEAN;
   use_deprn_prate_amt           BOOLEAN;
   deprn_ceiling_amt             NUMBER;
   temp_prate_amt                NUMBER;
   temp_bonus_prate_amt          NUMBER;
   deprn_method_amt              NUMBER;
   bonus_deprn_method_amt        NUMBER;
   deprn_method_amt2             NUMBER;  -- bug 8408871
   bonus_deprn_method_amt2       NUMBER;  -- bug 8408871
   ann_deprn_rate                NUMBER;
   method_type                   NUMBER := 0;
   first_fy_flag                 BOOLEAN;
   mid_fy_flag                   BOOLEAN;
   last_fy_flag                  BOOLEAN;
   ret_fy_flag                   BOOLEAN;
   after_eol_fy_flag             BOOLEAN;
   deprn_start_perd              NUMBER;
   deprn_end_perd                NUMBER;
   actual_deprn_start_perd       NUMBER;
   actual_deprn_end_perd         NUMBER;
   ann_fy_deprn                  NUMBER;
   bonus_ann_fy_deprn            NUMBER;
   deprn_frac_of_yr              NUMBER;
   perd_deprn_exp                NUMBER;
   perd_bonus_deprn_amount       NUMBER;
   perd_prod                     NUMBER;
   year_deprn_exp                NUMBER;
   year_reval_exp                NUMBER;
   year_reval_amo                NUMBER;
   year_prod                     NUMBER;
   year_bonus_deprn_amount       NUMBER;
   deprn_exp_sum                 NUMBER;
   reval_exp_sum                 NUMBER;
   bonus_deprn_exp_sum           NUMBER;
   reval_amo_sum                 NUMBER;
   prod_sum                      NUMBER;
   cur_adj_cost                  NUMBER;
   cur_deprn_rsv                 NUMBER;
   cur_reval_rsv                 NUMBER;
   cur_reval_amo_basis           NUMBER;
   cur_ltd_prod                  NUMBER;
   cur_bonus_deprn_rsv           NUMBER;
   rab_rc_ratio                  NUMBER;
   first_perd_frac               NUMBER;
   first_year_frac               NUMBER;
   adj_first_yr_frac             NUMBER;
   last_perd_frac                NUMBER;
   last_year_frac                NUMBER;
   ret_perd_frac                 NUMBER;
   ret_year_frac                 NUMBER;
   period_fracs_single           fa_std_types.fa_cp_struct;
   perds_fracs_arr               fa_std_types.table_fa_cp_struct;
   nbv_absval                    NUMBER;
   rec_cost_absval               NUMBER;
   adj_rec_cost_absval           NUMBER;
   rsv_absval                    NUMBER;
   temp_afnum                    NUMBER;
   fy_name                       VARCHAR2(45);
   temp                          VARCHAR2(45);
   method_id                     NUMBER;
   depr_last_year_flag           BOOLEAN;
   rate_source_rule              VARCHAR2(40);
   deprn_basis_rule              VARCHAR2(14);
   prorate_calendar              VARCHAR2(48);
   perds_per_yr_dcal             NUMBER;
   perds_per_yr_pcal             NUMBER;
   tmp_ub2                       NUMBER;
   actual_deprn_start_jdate      NUMBER;
   deprn_period_dcal_begin       NUMBER;
   deprn_period_pcal_begin       NUMBER;
   ret_period_dcal               NUMBER;
   ret_period_pcal               NUMBER;
   ret_year_pcal                 NUMBER;
   ret_prorate_period_pcal       NUMBER;
   deprn_year_dcal_begin         NUMBER;
   deprn_year_pcal_begin         NUMBER;
   prorate_year_pcal_begin       NUMBER;
   prorate_period_pcal_begin     NUMBER;
   nbv_frac_thresh               NUMBER;
   nbv_amt_thresh                NUMBER;
   deprn_projecting_flag         BOOLEAN;
   amo_reval_rsv_flag            BOOLEAN;
   rate_adj_factor               NUMBER;
   cur_fy                        NUMBER;
   use_deprn_limit_flag          BOOLEAN;
   adj_rec_cost                  NUMBER;
   last_period_deprn_exp         NUMBER;
   actual_annual_deprn_amt       NUMBER;
   actual_annual_bonus_deprn_amt NUMBER;
   ytd_deprn_sum                 NUMBER;
   ytd_bonus_deprn_sum           NUMBER;
   prior_fy_exp_sum              NUMBER;
   prior_fy_bonus_exp_sum        NUMBER;
   excl_sal_val_flag             BOOLEAN;
   ann_rounding_mode             INTEGER;
   h_dummy                       NUMBER;
   h_dummy_dpr                   fa_std_types.dpr_arr_type;
   h_dummy_bool                  BOOLEAN;
   success                       INTEGER;
   ceiling_diff_amt              NUMBER;
   deprn_override_flag           VARCHAR2(1);
   override_depr_amt             NUMBER;
   override_bonus_amt            NUMBER;
   l_ytd_deprn                   NUMBER;
   l_bonus_ytd_deprn             NUMBER;
   l_polish_rule                 NUMBER;
   return_code                   NUMBER;
   whatif_override_enable        VARCHAR2(40); -- Changed variable name from value
                                               -- to whatif_override_enable for bug7698338

   fy_ret                        NUMBER; -- Fix for Bug 1418257
   temp_round_amt                NUMBER; -- For bug 7539379
   temp_round_amt1               NUMBER; -- For bug 7539379
   dpis_fy                       NUMBER; -- For bug 7539379
   dpis_perd_num                 NUMBER; -- For bug 7539379
   book_fy                       NUMBER; -- For bug 7539379

   -- For Track Member Assets
   p_subtract_ytd_flag           VARCHAR2(1);
   p_deprn_amount                NUMBER;
   p_bonus_amount                NUMBER;
   x_new_perd_exp                NUMBER;
   x_new_perd_bonus_deprn_amount NUMBER;
   x_life_complete_flag          BOOLEAN;
   x_fully_reserved_flag         BOOLEAN;
   h_mode                        VARCHAR2(15);

   -- For depreciable basis rule
   h_eofy_flag                   VARCHAR2(1);
   cur_eofy_reserve              NUMBER;

   l_rate                        NUMBER;
   polish_adj_calc_basis_flag    VARCHAR2(1);

   -- Temporary deprn rsv bonus deprn rsv for call_deprn_basis
   cdb_deprn_rsv                 NUMBER;
   cdb_bonus_deprn_rsv           NUMBER;

   l_period_counter              NUMBER(15); -- For Super Group

   l_ind                         BINARY_INTEGER; -- For FA_BOOKS_SUMMARY
   l_accum_rsv_adj               NUMBER;  -- Store reserve adjustment_amount.
                                          -- It will be accumulated if faxcde is called for
                                          -- multiple periods
   l_rsv_adj                     NUMBER;  -- Store reserve adjustment amount from fa_amort_pvt
                                          -- that exclude the amount of period faxcde is called
                                          -- so that it can be used when validating fully reserve or not.

   l_temp_adj_cost              NUMBER; --Bug 5657699

   l_old_adj_rec_cost           NUMBER; --Bug 8231467
   l_adj_deprn_rsv              NUMBER; --Bug 8231467

   l_adjusted_rsv_absval        NUMBER; -- Bug 5893429
   h_adjusted_cost              NUMBER; -- Japan Tax Reforms Project
   l_calling_interface          VARCHAR2(30);  -- Bug:5930979:Japan Tax Reform Project
   l_adjusted_cost              NUMBER;        -- Bug 7129262 : Nbv calculation of revised assets.
   l_request_short_name         VARCHAR2(100); --- BUG # 7277598: store the Concurrent Program Short Name
   l_number_of_periods          NUMBER;        --- BUG # 7277598: store the number of periods remaining after the switch.
   l_count                      NUMBER := 0;   --- BUG # 7277598: store the Temporary Count.
   l_nbv_at_switch              NUMBER;        --- BUG # 7277598: store the nbv_at_switch from Database.
   dpr_run_flag                 BOOLEAN;       --- BUG # 7304706: store the TRUE/FALSE value if the Deprn is run for a particular Asset
   h_deprn_run                  varchar2(1);   --- BUG # 7304706: store the Y/N value if the Deprn is run for a particular Asset

   l_over_depreciate_option     number;        --Bug 8487934

   --Bug8620551
   --Added new cursor and variable to check for retirement in period of addition
   prd_flag varchar2(1);

   cursor c_prd_flag is
   select 'Y'
   from   fa_calendar_periods fcp1,
          fa_calendar_periods  fcp2,
          fa_book_controls fbc
   where  to_date (dpr_in.prorate_jdate,'J') BETWEEN fcp1.start_date AND fcp1.end_date
   and    fbc.book_type_code = dpr_in.book
   and    fcp1.calendar_type = fbc.deprn_calendar
   and    to_date (decode( dpr_in.jdate_retired,0,null,dpr_in.jdate_retired),'J') BETWEEN fcp2.start_date AND fcp2.end_date
   and    fcp2.calendar_type=fcp1.calendar_type
   and    fcp1.period_name=fcp2.period_name;

BEGIN <<FAXCDE>>

   --code fix for bug no. 3909805.Used default value for
   -- year_depnr_exp in expressions if it is having null value.

   dpr_out.full_rsv_flag := FALSE;
   dpr_out.life_comp_flag := FALSE;
   dpr_run_flag := FALSE;
   --
   -- Debug
   --
   IF (p_log_level_rec.statement_level) THEN
     h_dummy_bool := fa_cde_pkg.faprds(dpr_in, p_log_level_rec => p_log_level_rec);
   END IF;

   deprn_exp_sum := 0;
   bonus_deprn_exp_sum := 0;
   reval_exp_sum := 0;
   reval_amo_sum := 0;
   prod_sum := 0;
   year_deprn_exp := 0;
   year_bonus_deprn_amount :=0;
   year_reval_exp := 0;
   year_reval_amo := 0;
   year_prod := 0;
   rab_rc_ratio := 0;
   actual_annual_deprn_amt := 0;
   actual_annual_bonus_deprn_amt := 0;
   ytd_deprn_sum := 0;
   ytd_bonus_deprn_sum := 0;
   prior_fy_exp_sum := 0;
   prior_fy_bonus_exp_sum := 0;

   dpr_out.new_deprn_rsv := 0;
   dpr_out.new_bonus_deprn_rsv := 0;
   dpr_out.new_adj_cost := 0;
   dpr_out.new_reval_rsv := 0;
   dpr_out.new_reval_amo_basis := 0;
   dpr_out.new_adj_capacity := 0;
   dpr_out.new_ltd_prod := 0;
   dpr_out.ann_adj_exp := 0;
   dpr_out.ann_adj_reval_exp := 0;
   dpr_out.ann_adj_reval_amo := 0;
   dpr_out.bonus_rate_used := 0;
   dpr_out.new_prior_fy_exp := 0;
   dpr_out.new_prior_fy_bonus_exp := 0;

   -- Populate initial ytd_deprn
   dpr_out.new_ytd_deprn := dpr_in.ytd_deprn;

   dpr_out.new_impairment_rsv := dpr_in.impairment_rsv;
   dpr_out.new_capital_adjustment := dpr_in.capital_adjustment;  -- Bug 6666666
   dpr_out.new_general_fund := dpr_in.general_fund;              -- Bug 6666666

   IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.ADD('faxcde','dpr_out.new_impairment_rsv',dpr_out.new_impairment_rsv, p_log_level_rec);
   END IF;

   deprn_ceiling_amt := 0;
   first_perd_frac := 0;
   first_year_frac := 0;
   adj_first_yr_frac := 0;
   last_perd_frac := 0;
   last_year_frac := 0;
   ret_perd_frac := 0;
   ret_year_frac := 0;

   IF NOT fa_cache_pkg.fazccmt(dpr_in.method_code,
                               dpr_in.life,
                               p_log_level_rec => p_log_level_rec) THEN
      fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
   END IF;

   method_id           := fa_cache_pkg.fazccmt_record.method_id;
   rate_source_rule    := fa_cache_pkg.fazccmt_record.rate_source_rule;
   deprn_basis_rule    := fa_cache_pkg.fazccmt_record.deprn_basis_rule;
   polish_adj_calc_basis_flag := fa_cache_pkg.fazccmt_record.polish_adj_calc_basis_flag;
   p_subtract_ytd_flag := fa_cache_pkg.fazcdrd_record.subtract_ytd_flag;

   IF fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag = 'YES' THEN
      excl_sal_val_flag := TRUE;
   ELSE
      excl_sal_val_flag := FALSE;
   END IF;

   IF fa_cache_pkg.fazccmt_record.depreciate_lastyear_flag = 'YES' THEN
      depr_last_year_flag := TRUE;
   ELSE
      depr_last_year_flag := FALSE;
   END IF;

   IF (fa_cache_pkg.fazccmt_record.deprn_basis_rule_id IS NOT NULL) THEN
      l_polish_rule := fa_cache_pkg.fazcdbr_record.polish_rule;
   END IF;

   -- One of these will be true
   calc_rate_src_flag := (rate_source_rule = 'CALCULATED');
   prod_rate_src_flag := (rate_source_rule = 'PRODUCTION');
   table_rate_src_flag := (rate_source_rule ='TABLE');
   flat_rate_src_flag := (rate_source_rule = 'FLAT');
   formula_rate_src_flag := (rate_source_rule = 'FORMULA');

   -- Initialize indicator
   l_ind := p_ind;

   IF NOT (calc_rate_src_flag OR
           prod_rate_src_flag OR
           table_rate_src_flag OR
           flat_rate_src_flag OR
           formula_rate_src_flag) THEN

      fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxcde',
                              name            => 'FA_SHARED_NO_RATE_SOURCE_RULE',
                              TRANSLATE       => FALSE,
                              p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
   END IF;

   -- One of these will be true
   cost_deprn_basis_flag := (deprn_basis_rule = 'COST');
   nbv_deprn_basis_flag := (deprn_basis_rule = 'NBV');

   IF NOT (cost_deprn_basis_flag OR nbv_deprn_basis_flag) THEN

      fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde',
                              name       => 'FA_SHARED_NO_DEPRN_BASIS_RULE',
                              TRANSLATE  => FALSE,
                              p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
   END IF;

   IF nbv_deprn_basis_flag AND
      NOT (flat_rate_src_flag OR
           table_rate_src_flag OR
           formula_rate_src_flag OR                              -- ENERGY
           prod_rate_src_flag) THEN                              -- ENERGY

      fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxcde',
                              name            => 'FA_SHARED_NBV_NOT_FLAT',
                              TRANSLATE       => FALSE,
                              p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
   END IF;

   --
   -- set use_deprn_limit_flag if asset's recoverable cost is not
   -- equal to adjusted recoverable cost and deprn_source_rule is
   -- not CALCULATED or FLAT or FORMULA
   --
   IF (calc_rate_src_flag OR
       flat_rate_src_flag OR
       formula_rate_src_flag) AND
      (dpr_in.rec_cost <> dpr_in.adj_rec_cost) THEN

      use_deprn_limit_flag := TRUE;
      adj_rec_cost := dpr_in.adj_rec_cost;
   ELSE
      use_deprn_limit_flag := FALSE;
      adj_rec_cost := dpr_in.rec_cost;
   END IF;

   deprn_projecting_flag := (fmode = fa_std_types.FA_DPR_PROJECT);

   --
   -- Get the following information from the FA_BOOK_CONTROLS cache
   -- 1. Rate Calendar
   -- 2. NBV Fraction Threshold
   -- 3. NBV Amount Threshold
   -- 4. Amortize Reval Reserve Flag
   -- 5. Fiscal Year Name
   -- 6. Current Fiscal Year
   --
   -- fazcbc cache should have already been called don't call again
   --  BUG# 4027981 - use the mrc enabled cache  for nbv_amount_threshold

   prorate_calendar := fa_cache_pkg.fazcbc_record.PRORATE_CALENDAR;
   nbv_frac_thresh := NVL(fa_cache_pkg.fazcbc_record.NBV_FRACTION_THRESHOLD,
                          fa_std_types.FA_DEF_NBV_FRAC);
   nbv_amt_thresh := NVL(fa_cache_pkg.fazcbcs_record.NBV_AMOUNT_THRESHOLD,
                         fa_std_types.FA_DEF_NBV_AMT);
   amo_reval_rsv_flag := (fa_cache_pkg.fazcbc_record.AMORTIZE_REVAL_RESERVE_FLAG = 'YES');
   fy_name := fa_cache_pkg.fazcbc_record.FISCAL_YEAR_NAME;
   cur_fy := fa_cache_pkg.fazcbc_record.CURRENT_FISCAL_YEAR;

   --
   -- Get the number of periods per year in the depreciation calendar
   --
   IF NOT fa_cache_pkg.fazcct(dpr_in.calendar_type, p_log_level_rec => p_log_level_rec) THEN
      fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
   END IF;

   perds_per_yr_dcal := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;

   --
   -- Get the number of periods per year in the rate calendar
   --
   IF NOT fa_cache_pkg.fazcct(prorate_calendar, p_log_level_rec => p_log_level_rec) THEN
      fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
   END IF;

   perds_per_yr_pcal := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;

   --
   -- Determine the actual Deprn Start Date to use: this is the
   -- dpr_in.deprn_start_date, unless the method is STL (calc_rate_src_flag)
   -- Fix for Bug 903791. For formula_rate_src_flag we will use the
   -- deprn_start_date as determined by Depreciate When Placed in Service
   -- flag in Prorate Convention.

   IF calc_rate_src_flag THEN
      actual_deprn_start_jdate :=  dpr_in.prorate_jdate ;
   ELSE
      actual_deprn_start_jdate :=  dpr_in.deprn_start_jdate;
   END IF;

   --
   -- Get the depreciation start period, and the corresponding
   -- fiscal year. We use h_dummy to hold the returned start
   -- date, which we don't need.
   --
   IF NOT fa_cache_pkg.fazccp(dpr_in.calendar_type,
                              fy_name,
                              actual_deprn_start_jdate,
                              deprn_period_dcal_begin,
                              deprn_year_dcal_begin,
                              h_dummy,
                              p_log_level_rec => p_log_level_rec) THEN
      fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
   END IF;

   --
   -- Get the depreciation start prorate period, and the corresponding
   -- fiscal year
   --
   IF NOT fa_cache_pkg.fazccp(prorate_calendar
                            , fy_name
                            , actual_deprn_start_jdate
                            , deprn_period_pcal_begin
                            , deprn_year_pcal_begin
                            , h_dummy
                            , p_log_level_rec => p_log_level_rec) THEN
      fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
   END IF;

   --
   -- Get the prorate period, and the corresponding fiscal year
   --
   IF NOT fa_cache_pkg.fazccp(prorate_calendar
                            , fy_name
                            , dpr_in.prorate_jdate
                            , prorate_period_pcal_begin
                            , prorate_year_pcal_begin
                            , h_dummy
                            , p_log_level_rec => p_log_level_rec) THEN
      fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
   END IF;

   IF deprn_year_dcal_begin < prorate_year_pcal_begin THEN
      deprn_year_dcal_begin := prorate_year_pcal_begin;
      deprn_period_dcal_begin :=  1;
   END IF;

   IF deprn_year_pcal_begin < prorate_year_pcal_begin THEN
      deprn_year_pcal_begin := prorate_year_pcal_begin;
      deprn_period_pcal_begin :=  1;
   END IF;

   IF dpr_in.y_begin = 0 THEN
      dpr_in.y_begin := prorate_year_pcal_begin;

      IF deprn_year_dcal_begin = prorate_year_pcal_begin THEN
         dpr_in.p_cl_begin := deprn_period_dcal_begin;
      ELSE
         dpr_in.p_cl_begin := 1;
      END IF;
   END IF;

   IF dpr_in.jdate_retired <> 0 AND
      dpr_in.ret_prorate_jdate <> 0 THEN
      IF NOT fa_cache_pkg.fazccp(dpr_in.calendar_type
                               , fy_name
                               , dpr_in.jdate_retired
                               , ret_period_dcal
                               , ret_year_pcal
                               , h_dummy
                               , p_log_level_rec => p_log_level_rec) THEN
         fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
         RETURN (FALSE);
      END IF;

      -- assign y_ret to fy_ret as it gets overwritten in next call
      -- to fazccp. Fix for 1418257
      fy_ret := ret_year_pcal;

      IF NOT fa_cache_pkg.fazccp(prorate_calendar
                               , fy_name
                               , dpr_in.jdate_retired
                               , ret_period_pcal
                               , ret_year_pcal
                               , h_dummy
                               , p_log_level_rec => p_log_level_rec) THEN
         fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
         RETURN (FALSE);
      END IF;

      IF NOT fa_cache_pkg.fazccp(prorate_calendar
                               , fy_name
                               , dpr_in.ret_prorate_jdate
                               , ret_prorate_period_pcal
                               , ret_year_pcal
                               , h_dummy
                               , p_log_level_rec => p_log_level_rec) THEN
         fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
         RETURN (FALSE);
      END IF;
   ELSE
      ret_period_dcal := 0;
      ret_prorate_period_pcal := 0;
      ret_year_pcal := 0;
      fy_ret := 0;
   END IF; -- dpr_in.jdate_retired <> 0 and

   --
   -- If Current reserve is not known, calculate what it
   -- should be by calling this routine starting at the
   -- beginning of the asset's life
   --
   -- bonus? When is rsv_known_flag false?
   --        FAWDPRB.pls, FAEXADJB.pls, FATXRSVB.pls, FAAMRT1B.pls checked
   --     and all return true.
   --        Included dpr.depn_rsv and dpr_out.new_bonus_deprn_rsv anyway.
   IF NOT dpr_in.rsv_known_flag THEN
      dpr := dpr_in;
      dpr.deprn_rsv := 0;
      dpr.bonus_deprn_rsv := 0;
      dpr.ltd_prod := 0;
      initial_rsv := 0;
      initial_ltd_prod := 0;
      dpr.rsv_known_flag := TRUE;
      dpr.y_begin := prorate_year_pcal_begin;

      IF dpr_in.p_cl_begin = 1 THEN
         dpr.y_end :=  dpr_in.y_begin - 1;
      ELSE
         dpr.y_end := dpr_in.y_begin;
      END IF;

      dpr.p_cl_begin := 1;
      dpr.p_cl_end := MOD(dpr_in.p_cl_begin - 2 + perds_per_yr_dcal,
                          perds_per_yr_dcal) + 1;

      IF NOT fa_cde_pkg.faxcde(dpr
                             , h_dummy_dpr
                             , dpr_out
                             , fmode
                             , p_log_level_rec => p_log_level_rec) THEN
         fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
         RETURN (FALSE);
      END IF;

      dpr_in.rsv_known_flag := TRUE;
      dpr_in.deprn_rsv := dpr_out.new_deprn_rsv;
      dpr_in.bonus_deprn_rsv := dpr_out.new_bonus_deprn_rsv;
      dpr_in.adj_cost := dpr_out.new_adj_cost;
      dpr_in.ltd_prod := dpr_out.new_ltd_prod;
      dpr_in.prior_fy_exp := dpr_out.new_prior_fy_exp;
      dpr_in.prior_fy_bonus_exp := dpr_out.new_prior_fy_bonus_exp;

      --
      -- Debug
      --
      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.ADD('faxcde','new deprn_rsv',dpr_in.deprn_rsv, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD('faxcde','new adj_cost',dpr_in.adj_cost, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD('faxcde','new ltd_prod',dpr_in.ltd_prod, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD('faxcde','new prior_fy_exp',dpr_in.prior_fy_exp, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD('faxcde','new prior_fy_bonus_exp',dpr_in.prior_fy_bonus_exp, p_log_level_rec => p_log_level_rec);
      END IF;
   END IF; -- not dpr_in.rsv_known_flag

   dpr := dpr_in;

   cur_deprn_rsv := dpr.deprn_rsv;
   cur_reval_rsv := dpr.reval_rsv;
   cur_ltd_prod := dpr.ltd_prod;
   cur_adj_cost := dpr.adj_cost;
   cur_reval_amo_basis := dpr.reval_amo_basis;
   -- bonus. dpr.bonus_deprn_rsv should be known at this point

   cur_bonus_deprn_rsv := dpr.bonus_deprn_rsv;

   cur_eofy_reserve := dpr.eofy_reserve;

   IF (nbv_deprn_basis_flag AND excl_sal_val_flag) THEN
      cur_adj_cost := cur_adj_cost + dpr.salvage_value;
   END IF;

   --
   -- Debug
   --
   IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.ADD('faxcde','cur_deprn_rsv',cur_deprn_rsv, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD('faxcde','cur_reval_rsv',cur_reval_rsv, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD('faxcde','cur_adj_cost',cur_adj_cost, p_log_level_rec => p_log_level_rec);
   END IF;

   --
   -- If Flat-Rate or Production depreciation, do not use
   -- the asset's life
   --
   IF flat_rate_src_flag OR prod_rate_src_flag THEN
      prate_perd_fully_rsv :=  1;
      fy_fully_rsv :=  0;
   ELSE
      prate_perd_fully_rsv := 1 + MOD (prorate_period_pcal_begin - 2 +
                                          CEIL(dpr.life * perds_per_yr_pcal / 12.0),
                                       perds_per_yr_pcal);
      fy_fully_rsv :=  prorate_year_pcal_begin + FLOOR((dpr.life - 1) / 12.0);

      IF prate_perd_fully_rsv < prorate_period_pcal_begin THEN
         fy_fully_rsv := fy_fully_rsv + 1;
      END IF;
   END IF;

   dpr_arr_ctr := 0;

   IF  fy_fully_rsv <= dpr.y_end THEN
      fy_fully_rsv_1 :=  fy_fully_rsv ;
   ELSE
      fy_fully_rsv_1 :=   0;
   END IF;
   --Bug8620551: Added check for retirement in period of addition
   open c_prd_flag;
   fetch c_prd_flag into prd_flag;

   if c_prd_flag%NOTFOUND then
      prd_flag := 'N';
   end if;

   close c_prd_flag;

   IF NOT fa_cde_pkg.faxcfyf(dpr
                           , perds_per_yr_dcal
                           , rate_source_rule
                           , prorate_year_pcal_begin
                           , fy_fully_rsv_1
                           , ret_year_pcal
                           , deprn_period_dcal_begin
                           , deprn_period_pcal_begin
                           , deprn_perd_fully_rsv
                           , ret_period_dcal
                           , ret_period_pcal
                           , prorate_period_pcal_begin
                           , prate_perd_fully_rsv
                           , ret_prorate_period_pcal
                           , adj_first_yr_frac
                           , first_perd_frac
                           , last_perd_frac
                           , ret_perd_frac
                           , first_year_frac
                           , last_year_frac
                           , ret_year_frac
                           , prd_flag
                           , p_log_level_rec => p_log_level_rec) THEN

      fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcde',  p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
   END IF;

   ann_rounding_mode:= fadgpoar();

   IF (prod_rate_src_flag AND ann_rounding_mode = ROUND_ALWAYS) THEN
      ann_rounding_mode:= ROUND_WITH_RESTRICTIONS;
   END IF;

   --
   -- Override depreciation functionality
   --
   IF NVL(dpr_in.deprn_override_flag, fa_std_types.FA_NO_OVERRIDE) <>
                                       fa_std_types.FA_OVERRIDE_RECURSIVE THEN
      dpr_out.deprn_override_flag:= fa_std_types.FA_NO_OVERRIDE;
   END IF;

    -- Added the Below code to take care of the Bug# 7277598
    -- Below Query will fetch the program short name from the Conc Request Summary.
   IF fnd_global.conc_request_id is not null AND fnd_global.conc_request_id  <> -1 then
      BEGIN
         select program_short_name
         into  l_request_short_name
         from  FND_CONC_REQ_SUMMARY_V
         where request_id = fnd_global.conc_request_id;
      EXCEPTION
         when others then
           l_request_short_name := NULL;
      END;
   END IF;

    --- The following code is added to check  whether NBV_AT_SWITCH column of fa_books has value or Not.
    IF l_request_short_name = 'FAWDPR' then
       BEGIN
          SELECT nbv_at_switch
          INTO   l_nbv_at_switch
          FROM   fa_books
          WHERE  asset_id = dpr.asset_id
          AND    book_type_code = dpr.book
          AND    transaction_header_id_out is null;
       EXCEPTION
          WHEN OTHERS THEN
             l_nbv_at_switch := NULL;
       END;
       --- BUG# 7290365 : If clause added becuase the program  is erroring out ora-01476 for Method JP-250DB 2
       IF fa_cache_pkg.fazcfor_record.revised_Rate = 0 THEN
          l_number_of_periods := perds_per_yr_dcal;
       ELSIF fa_cache_pkg.fazcfor_record.revised_Rate > 0 THEN
          l_number_of_periods := CEIL(perds_per_yr_dcal/fa_cache_pkg.fazcfor_record.revised_Rate);   --- Calculate the Approximate Number of Periods, when Switch happens.
       END IF;
       --  End of  BUG# 7290365.
       -- BUG# 7304706 : the query below will get the details about whether deprn is run for a particular asset.
       -- If deprn is already run for the Asset, follow the standard procedure of calculating the Deprn.
       BEGIN
          SELECT 'Y'
          INTO   h_deprn_run
          FROM   fa_deprn_summary
          WHERE  book_type_code = dpr.book
          AND    asset_id = dpr.asset_id
          AND    deprn_source_code = 'DEPRN'
          AND    period_counter = ((dpr_in.y_begin*perds_per_yr_dcal+dpr_in.p_cl_begin)-1);
       EXCEPTION
          WHEN OTHERS THEN
             h_deprn_run := NULL;
             dpr_run_flag := FALSE;
       END;


       IF h_deprn_run = 'Y' then
          dpr_run_flag := TRUE;
       END IF;
        -- BUG# 7304706 : End Of Addition
    END IF;
    -- End of Addition  Bug# 7277598


   -- Loop over all requested Fiscal Years --
   --
   -- YEAR LOOP
   --
   FOR fyctr IN dpr.y_begin..dpr.y_end LOOP

      fy_ctr := fyctr;
      year_deprn_exp :=0;
      year_reval_exp :=0;
      year_reval_amo :=0;
      year_bonus_deprn_amount :=0;
      year_prod :=0 ;
      actual_annual_deprn_amt := 0;
      actual_annual_bonus_deprn_amt := 0;

      IF NOT fa_cache_pkg.fazcff(dpr.calendar_type
                               , dpr.book
                               , fyctr
                               , perds_fracs_arr
                               , p_log_level_rec => p_log_level_rec) THEN
         fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
         RETURN (FALSE);
      END IF;

      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.ADD('faxcde','cur_deprn_rsv1',cur_deprn_rsv, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD('faxcde','cur_reval_rsv1',cur_reval_rsv, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD('faxcde','cur_adj_cost1',cur_adj_cost, p_log_level_rec => p_log_level_rec);
      END IF;

      first_fy_flag := FALSE;
      mid_fy_flag := FALSE;
      last_fy_flag := FALSE;
      after_eol_fy_flag := FALSE;
      ret_fy_flag := FALSE;

      IF fyctr < prorate_year_pcal_begin THEN
         dpr_cur_fy_flag := FALSE;
      ELSIF fyctr = prorate_year_pcal_begin THEN
         first_fy_flag := TRUE;
         dpr_cur_fy_flag := TRUE;
      ELSIF (fyctr > prorate_year_pcal_begin) AND (fy_fully_rsv = 0 OR (fyctr < fy_fully_rsv) OR
         flat_rate_src_flag OR prod_rate_src_flag) THEN
         mid_fy_flag := TRUE;
         dpr_cur_fy_flag := TRUE;

      ELSIF fyctr = fy_fully_rsv THEN
         last_fy_flag := TRUE;
         dpr_cur_fy_flag := TRUE;
      ELSIF fyctr > fy_fully_rsv THEN
         after_eol_fy_flag := TRUE;
         --
         -- Continually depreciate an asset after its life is
         -- completed but it is not fully reserved yet.
         -- This handles the cases where an asset becomes
         -- fully reserved before reaching end of year loop.
         -- (e.g. prior period addition case)
         --
         dpr_cur_fy_flag := NOT dpr_out.full_rsv_flag;
      END IF;

      IF fyctr = fy_ret THEN
         ret_fy_flag := TRUE;
         dpr_cur_fy_flag := dpr_cur_fy_flag AND depr_last_year_flag;
      END IF;

      IF ret_year_pcal <> 0 AND fyctr > fy_ret THEN
         dpr_cur_fy_flag := FALSE;
      END IF;

      IF fyctr = dpr.y_begin THEN
         deprn_start_perd := dpr.p_cl_begin;
         IF dpr.y_begin = dpr.y_end THEN
            deprn_end_perd := dpr.p_cl_end;
         ELSE
            deprn_end_perd := perds_per_yr_dcal;
         END IF;
      ELSIF fyctr = dpr.y_end THEN
         deprn_start_perd := 1;
         deprn_end_perd := dpr.p_cl_end;
      ELSE
         deprn_start_perd := 1;
         deprn_end_perd := perds_per_yr_dcal;
      END IF;

      -- bonus: put fa_cache_pkg.fazcbf here, and erase all calls later!
      --
      -- Get rate from FA_BONUS_RATES table
      --
      IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
         --
         -- Get rate from FA_BONUS_RATES table
         --

         IF NOT fa_cache_pkg.fazcbr(dpr.bonus_rule
                                  , (fyctr - prorate_year_pcal_begin + 1)
                                  , dpr_out.bonus_rate_used
                                  , dpr_out.deprn_factor_used
                                  , dpr_out.alternate_deprn_factor_used
                                  , p_log_level_rec) THEN
            fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
            RETURN (FALSE);
         END IF;

      ELSE
         dpr_out.bonus_rate_used := 0;
         dpr_out.deprn_factor_used := 0;
         dpr_out.alternate_deprn_factor_used := 0;
      END IF; -- nvl(dpr.bonus_rule, 'NONE') <> 'NONE'

      -- Moved period loop for period update method
      --
      -- PERIOD LOOP
      --
      FOR perd_ctr IN deprn_start_perd .. deprn_end_perd LOOP

         --
         -- Replace depreciation rate, adj_rec_cost if super group is assigned
         -- to this asset.
         --
         IF (dpr.super_group_id IS NOT NULL) THEN

            l_period_counter := fyctr * fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR + perd_ctr;

            IF NOT fa_cache_pkg.fazcsgr(x_super_group_id  => dpr.super_group_id
                                      , x_book_type_code  => dpr.book
                                      , x_period_counter  => l_period_counter, p_log_level_rec => p_log_level_rec) THEN
               RETURN (FALSE);
            END IF;

            dpr.adj_rate := NVL(fa_cache_pkg.fazcsgr_record.adjusted_rate, dpr.adj_rate);
            adj_rec_cost := NVL(dpr.cost * fa_cache_pkg.fazcsgr_record.percent_salvage_value, adj_rec_cost);
            fa_round_pkg.fa_floor(adj_rec_cost, dpr.book,p_log_level_rec);

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde', 'Super Group new adj cost', adj_rec_cost, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'Super Group new adj rate', dpr.adj_rate, p_log_level_rec);
            END IF;

         END IF;

         --
         -- Calculate annual depreciation rate
         --
         IF dpr_cur_fy_flag AND (calc_rate_src_flag) THEN
            -- Calculate the rate for Straight-Line Depreciation --

            IF (dpr.life < 1) THEN
               fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxcde'
                                     , name            => 'FA_DEPRN_ILLEGAL_VALUE'
                                     , token1          => 'VARIABLE'
                                     , value1          => 'Life'
                                     , token2          => 'VALUE'
                                     , value2          => dpr.life
                                     , TRANSLATE       => FALSE
                                     , p_log_level_rec => p_log_level_rec);
               RETURN (FALSE);
            END IF;

            ann_deprn_rate := 12 / dpr.life;

         ELSIF dpr_cur_fy_flag AND prod_rate_src_flag THEN
            --
            -- Temporarily use 100% as rate; get actual rate
            -- for period later
            --
            ann_deprn_rate := 1;
            -- bonus: not including bonus rate for production.
            dpr_out.bonus_rate_used := 0;

         ELSIF (dpr_cur_fy_flag AND
                table_rate_src_flag AND
                NOT after_eol_fy_flag) THEN
            -- Get rate from FA_RATES table --

            IF NOT faxgtr(method_id
                        , fyctr - prorate_year_pcal_begin + 1
                        , prorate_period_pcal_begin
                        , ann_deprn_rate
                        , p_log_level_rec) THEN
               fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
               RETURN (FALSE);
            END IF;

         ELSIF (dpr_cur_fy_flag AND formula_rate_src_flag) THEN
            -- Get rate from FA_FORMULAS table --
            -- bonus: including bonus_rate for formula
            -- therefore not clearing bonus_rate, compare with production method.

            -- Bug:5930979:Japan Tax Reform Project (End)
            IF NVL(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, 'NO') = 'YES' THEN
               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde', '+++ JAPAN ', 'in guarantee rate', p_log_level_rec => p_log_level_rec);
               END IF;

               IF dpr_in.jdate_retired <> 0 AND  -- retirement
                  dpr_in.ret_prorate_jdate <> 0 THEN
                  l_calling_interface := NULL;
               ELSIF dpr_in.transaction_type_code = 'REINSTATEMENT' THEN -- Bug:6349882
                  l_calling_interface := NULL;
               ELSE
                  l_calling_interface := 'FAXCDE';
               END IF;
            END IF;
            -- Bug:5930979:Japan Tax Reform Project (End)

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde', 'dpr.cost', dpr.cost, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'dpr.cost - NVL(cur_eofy_reserve,0)', dpr.cost - NVL(cur_eofy_reserve,0), p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'fa_cache_pkg.fazcfor_record.guarantee_rate', fa_cache_pkg.fazcfor_record.guarantee_rate, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'cur_deprn_rsv', cur_deprn_rsv, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'fa_cache_pkg.fazcfor_record.original_Rate', fa_cache_pkg.fazcfor_record.original_Rate, p_log_level_rec);
            END IF;

             -- Bug:7193797 : Wrong Adjusted Cost is passed, when Switch happens in What-if Program.
             -- The following code change will also work for Bug 7129262
            IF (NVL(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, 'NO') = 'YES') THEN  --- Checking for Methods JP-250DB XX
                  l_adjusted_cost := cur_adj_cost ;
            ELSE
                  l_adjusted_cost := dpr.cost - NVL(cur_eofy_reserve,0);
            END IF;
            --- Bug:7129262 : END

            faxgfr( X_Book_Type_Code         => dpr.book,
                    X_Asset_Id               => dpr.asset_id,
                    X_Short_Fiscal_Year_Flag => dpr.short_fiscal_year_flag,
                    X_Conversion_Date        => dpr.conversion_date,
                    X_Prorate_Date           => dpr.prorate_date,
                    X_Orig_Deprn_Start_Date  => dpr.orig_deprn_start_date,
                    C_Prorate_Date           => NULL,
                    C_Conversion_Date        => NULL,
                    C_Orig_Deprn_Start_Date  => NULL,
                    X_Method_Code            => dpr.method_code,
                    X_Life_In_Months         => dpr.life,
                    X_Fiscal_Year            => fyctr,
                    X_Current_Period         => perd_ctr,
                    -- Bug:5930979:Japan Tax Reform Project
                    X_calling_interface      => l_calling_interface,
                    X_new_cost               => dpr.cost,
                    X_adjusted_cost          => l_adjusted_cost , --- Bug:7129262 --dpr.cost - NVL(cur_eofy_reserve,0),
                    X_Rate                   => ann_deprn_rate,
                    X_Method_Type            => method_type,
                    X_Success                => success,
                    p_log_level_rec          => p_log_level_rec);

            IF (method_type = 1) THEN
               rate_source_rule := 'PRODUCTION';
               prod_rate_src_flag := (rate_source_rule = 'PRODUCTION');
               formula_rate_src_flag := (rate_source_rule = 'FORMULA');
            END IF;

            IF (success <= 0) THEN
               fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
               RETURN (FALSE);
            END IF;

         ELSIF (dpr_cur_fy_flag AND flat_rate_src_flag) THEN

            -- Bug 3187975.  If Polish method, use special rate logic
            IF (l_polish_rule IN (FA_STD_TYPES.FAD_DBR_POLISH_1,
                                  FA_STD_TYPES.FAD_DBR_POLISH_2,
                                  FA_STD_TYPES.FAD_DBR_POLISH_3,
                                  FA_STD_TYPES.FAD_DBR_POLISH_4,
                                  FA_STD_TYPES.FAD_DBR_POLISH_5)) THEN

               l_rate := dpr.adj_rate;

               fa_cde_pkg.faxgpolr (
                                X_Book_Type_Code             => dpr.book,
                                X_Asset_Id                   => dpr.asset_id,
                                X_Polish_Rule                => l_polish_rule,
                                X_Deprn_Factor               => dpr_out.deprn_factor_used,
                                X_Alternate_Deprn_Factor     => dpr_out.alternate_deprn_factor_used,
                                X_Polish_Adj_Calc_Basis_Flag => polish_adj_calc_basis_flag,
                                X_Recoverable_Cost           => dpr_in.rec_cost,
                                X_Fiscal_Year                => fyctr,
                                X_Current_Period             => perd_ctr,
                                X_Periods_Per_Year           => perds_per_yr_dcal,
                                X_Year_Retired               => ret_fy_flag,
                                X_Projecting_Flag            => deprn_projecting_flag,
                                X_MRC_SOB_Type_Code          => dpr.mrc_sob_type_code,
                                X_set_of_books_id            => dpr.set_of_books_id,
                                X_Rate                       => l_rate,
                                X_Depreciate_Flag            => dpr_cur_fy_flag,
                                X_Current_Adjusted_Cost      => cur_adj_cost,
                                X_Adjusted_Recoverable_Cost  => adj_rec_cost,
                                X_Success                    => success,
                                X_Calling_Fn                 => 'fa_cde_pkg.faxcde',
                                p_log_level_rec              => p_log_level_rec);
               ann_deprn_rate := l_rate;
            ELSE
               -- bonus: changed this so we keep deprn_exp and
               -- bonus_deprn_amount separated until later.
               -- ann_deprn_rate := dpr.adj_rate + dpr_out.bonus_rate_used;

               ann_deprn_rate := dpr.adj_rate;
            END IF;
         ELSIF dpr_cur_fy_flag THEN -- bonus: elsif for unknown rate_source_rule
            --
            -- Rate-based amount is total recoverable cost, all
            -- taken in current period (=> *perds_per_yr_dcal)
            -- No deprn limit for table_rate_src_flag
            --
            ann_deprn_rate := 1;
            temp_prate_amt := dpr.rec_cost * perds_per_yr_dcal;

            -- Bonus Deprn - YYOON 7/7/2000
            --    In this case which is assumed to be
            --    a recoverable cost based method,
            --    the bonus deprn amount is only calculated
            --    as temp_prate_amt multiplied by bonus_rate */

            IF NVL(dpr_out.bonus_rate_used,0) <> 0 THEN
               temp_bonus_prate_amt := temp_prate_amt * dpr_out.bonus_rate_used;
            ELSE
               temp_bonus_prate_amt := 0;
            END IF;
            -- End of Bonus Deprn Change */

         ELSE
            --
            -- dpr_cur_fy_flag is FALSE
            --
            ann_deprn_rate := 0;
            dpr_out.bonus_rate_used := 0;
            temp_prate_amt := 0;
            temp_bonus_prate_amt := 0;
         END IF;

         -- Note: temp_prate_amt and temp_bonus_prate_amt have no value
         --      if rate_source_rule is provided.
         -- bonus: using same fraction for bonus rate as for regular deprn rate.
         --     dpr_out.bonus_rate_used := dpr_out.bonus_rate_used * ann_deprn_rate;

         --
         -- Debug
         --

         -- Added the Below code to take care of the Bug# 7277598
         -- Below code calculates the  Prorata Depreciable amount , if the asset is added with JP-250DB XX and NBV_AT_SWITCH in the middle of FY
         IF l_request_short_name = 'FAWDPR' then
            -- Removed and l_nbv_at_switch is not null clause as from the Below IF condition , as this should work for all scenarios.
            IF (NVL(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, 'NO') = 'YES')  THEN   --- Checking for Methods JP-250DB XX
               IF ann_deprn_rate = fa_cache_pkg.fazcfor_record.revised_Rate  then
                  l_count := l_count + 1;
               END IF;
            END IF;
         END IF;
         -- End of Addition BUG# 7277598

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcde','fadpdp(2): ann_deprn_rate',ann_deprn_rate);
         END IF;

         IF ann_deprn_rate >= 0 THEN
            --
            -- Check that RAF is between 0 and 1
            --
            IF dpr.rate_adj_factor NOT BETWEEN 0 AND 1 THEN
               fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde',
                                       name => 'FA_DEPRN_ILLEGAL_VALUE',
                                       token1 => 'VARIABLE',
                                       value1 => 'Rate_Adjustment_Factor',
                                       token2 => 'VALUE',
                                       value2 => dpr.rate_adj_factor,
                                       TRANSLATE => FALSE,
                                       p_log_level_rec => p_log_level_rec);
               RETURN (FALSE);
            END IF;

            IF dpr.rate_adj_factor = 0 THEN
               --
               -- If RAF = 0, then use a very small RAF
               -- so we don't divide by zero
               --
               rate_adj_factor := fa_std_types.FA_DPR_SMALL_RAF;
            ELSE
               rate_adj_factor := dpr.rate_adj_factor;
            END IF;
            --code fix for bug no.3909805. dpr.formula_factor can have null value.
            temp_prate_amt := (cur_adj_cost / rate_adj_factor) * ann_deprn_rate * NVL(dpr.formula_factor,1);

            -- Added the Below code to take care of the Bug# 7277598
            -- Below code calculates the  Prorata Depreciable amount , if the asset is added with JP-250DB XX and NBV_AT_SWITCH in the Middle of the FY

            IF l_request_short_name = 'FAWDPR' then
               -- Removed and "l_nbv_at_switch is not null" clause and "first_fy_flag = TRUE  AND" clause from the Below IF condition , as this should work for all scenarios.
               IF (NVL(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, 'NO') = 'YES')  THEN  --- Checking for Methods JP-250DB XX
                  IF NOT(dpr_run_flag) AND deprn_start_perd <> 1 AND deprn_start_perd <> perds_per_yr_dcal THEN
                     -- BUG# 7304706 : NOT(dpr_run_flag) clause is added

                     /*Bug 7539379 starts */
                     dpis_perd_num := 0;
                     dpis_fy := 0;
                     book_fy := 0;
                     temp_round_amt := 0  ;
                     temp_round_amt1 := 0;


                     /* Below query will fetch the Fiscal year and Period number of DPIS */
                     SELECT fy.fiscal_year,cl.period_num
                     INTO   dpis_fy,dpis_perd_num
                     FROM   FA_BOOKS bk,
                            FA_CALENDAR_PERIODS CL,
                            FA_BOOK_CONTROLS BC,
                            FA_FISCAL_YEAR fy
                     WHERE  bk.asset_id = dpr.asset_id
                     AND    bk.book_type_code = dpr.book
                     AND    bk.date_ineffective is null
                     AND    BC.book_type_code = dpr.book
                     AND    BC.date_ineffective is null
                     AND    BC.deprn_calendar = CL.Calendar_type
                     AND    bk.date_placed_in_service BETWEEN CL.start_date AND CL.END_DATE
                     AND    fy.fiscal_year_name = bc.fiscal_year_name
                     AND    bk.date_placed_in_service BETWEEN fy.start_date AND fy.END_DATE;

                     /*Below query will fetch the current fiscal year of book*/
                     SELECT fiscal_year
                     INTO book_fy
                     FROM fa_deprn_periods pd
                     WHERE pd.book_type_code = dpr.book
                     AND period_close_date is null;

                     IF (dpis_fy <> book_fy) then
                        dpis_perd_num := 1;
                     END IF;

                     temp_prate_amt := (cur_adj_cost / rate_adj_factor) * ann_deprn_rate * NVL(dpr.formula_factor,1)
                                     * (perds_per_yr_dcal - deprn_start_perd + 1)/perds_per_yr_dcal;
                     temp_round_amt := trunc((cur_adj_cost / rate_adj_factor) * ann_deprn_rate * NVL(dpr.formula_factor,1)
                                     * (perds_per_yr_dcal - (dpis_perd_num - 1))/perds_per_yr_dcal);
                     temp_round_amt1 := round((trunc((cur_adj_cost / rate_adj_factor) * ann_deprn_rate *
                                                NVL(dpr.formula_factor,1)))/perds_per_yr_dcal)*(perds_per_yr_dcal - dpis_perd_num);


                     /*Bug 7539379 ENDS */

                     perds_fracs_arr(perd_ctr-1).frac := (perds_per_yr_dcal/(perds_per_yr_dcal - deprn_start_perd + 1))*(1/perds_per_yr_dcal);
                  END IF; -- NOT(dpr_run_flag)
               END IF;  -- (NVL(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, 'NO') = 'YES')
            END IF;  -- l_request_short_name = 'FAWDPR'

            -- End of Addition BUG# 7277598

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde','fadpdp(3A): temp_prate_amt',temp_prate_amt, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','fadpdp(3A): cur_adj_cost',cur_adj_cost, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','fadpdp(3A): rate_adj_factor',rate_adj_factor, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','fadpdp(3A): ann_deprn_rate',ann_deprn_rate, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','fadpdp(3A): dpr.formula_factor',dpr.formula_factor, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','fadpdp(3A): temp_round_amt',temp_round_amt, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','fadpdp(3A): temp_round_amt1',temp_round_amt1, p_log_level_rec);
            END IF;

            --
            -- Bonus Deprn - YYOON
            --  Calcuate annual bonus deprn expense for current year
            --  NOTE:
            --  1. The bonus deprn calculation should NOT be adjusted
            --     by the rate adjustment factor.(Please refer to HLD page 24)
            --  2. The depreciable basis for the bonus deprn calculation should be
            --     the recoverable cost or NBV depending on the asset's method.
            --     (Please refer to HLD Example 1 and 3)
            --  3. The bonus deprn calculation for assets with a cost-based method
            --     should NOT be based on the adjusted_cost which gets reset to NBV
            --     as of the period of amortized adjustment
            --     but should be based on the recoverable cost.
            --     (Please refer to HLD Example 6)
            --  4. The adjusted_cost is calculated based only on the standard
            --     accumulated depreciation (total less bonus) as of the period of
            --     amortized adjustment. (This should be taken care of in forms level)
            --     (Please refer to HLD Example 6)
            --  5. On 7/20/2000, a new logic to reset adjusted_cost of assets
            --     with NBV-based methods to Cost minus Regular Reserve
            --     at the end of each fiscal year. (bug# 1351870)
            --  6. On 09/10/2000, backed out changes done for 1351870.
            --
            IF NVL(dpr_out.bonus_rate_used,0) <> 0 THEN
               temp_bonus_prate_amt := cur_adj_cost * dpr_out.bonus_rate_used ;
            ELSE
               temp_bonus_prate_amt := 0;
            END IF;
            -- End of Bonus Deprn Change

         END IF; -- ann_deprn_rate >= 0

         --
         -- Debug
         --
         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcde','fadpdp(3): temp_prate_amt',temp_prate_amt, p_log_level_rec);
         END IF;

         -- syoung: changed 0 to '0'.  If ceil_name(varchar2) is not null, and
         -- if that is compared with 0, then would cause a value_error.
         IF dpr_cur_fy_flag AND NVL(dpr.ceil_name,'0') <> '0'  THEN
            --
            -- Get Ceiling Information from FA_CEILING_TYPES
            -- and FA_CEILINGS
            --
            IF NOT fa_cache_pkg.fazccl(dpr.ceil_name,
                                       dpr.jdate_in_service,
                                       fyctr - prorate_year_pcal_begin + 1,
                                       deprn_ceiling_amt,
                                       p_log_level_rec) THEN
               fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde', p_log_level_rec => p_log_level_rec);
               RETURN (FALSE);
            END  IF;

         END IF;

         IF dpr.ceil_name IS NOT NULL AND (temp_prate_amt = 0 OR
             deprn_ceiling_amt < temp_prate_amt + temp_bonus_prate_amt) THEN
            use_deprn_ceil_amt := TRUE;
            use_deprn_prate_amt := FALSE;
         ELSE
            use_deprn_ceil_amt := FALSE;
            use_deprn_prate_amt := TRUE;
         END IF;

         -- Default initializations --
         actual_deprn_start_perd := 1;
         actual_deprn_end_perd := perds_per_yr_dcal;

         --
         -- if asset is in the first year or last year of life then
         -- re-calculate annual deprn expense based on the fraction
         -- of year asset is held
         --
         IF (first_fy_flag) THEN
            actual_deprn_start_perd := deprn_period_dcal_begin;
            -- 'Annualize' the Rate amount and Ceiling amount
            deprn_method_amt := temp_prate_amt * adj_first_yr_frac;

            --
            -- bug 2182029. added condition, now not multipl. with fraction for table mthd.
            --
            IF (NOT table_rate_src_flag) THEN
               bonus_deprn_method_amt := temp_bonus_prate_amt * adj_first_yr_frac;
            ELSE
               bonus_deprn_method_amt := temp_bonus_prate_amt;
            END IF;
            -- end 2182029

            IF (dpr.ceil_name IS NOT NULL) THEN
               deprn_ceiling_amt := deprn_ceiling_amt * adj_first_yr_frac;
            END IF;

            IF (dpr.ceil_name IS NOT NULL AND (
               deprn_method_amt = 0 OR deprn_ceiling_amt < (deprn_method_amt + bonus_deprn_method_amt))) THEN
               use_deprn_ceil_amt := TRUE;
               use_deprn_prate_amt := FALSE;
            ELSE
               use_deprn_prate_amt := TRUE;
               use_deprn_ceil_amt := FALSE;
            END IF;

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde','ann_fy_deprn1111',ann_fy_deprn, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','actual_annual_deprn_amt1111',actual_annual_deprn_amt, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','perd_ctr1111',perd_ctr, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','ret_period_dcal1111',ret_period_dcal, p_log_level_rec);
            END IF;

            IF use_deprn_prate_amt THEN
               ann_fy_deprn := deprn_method_amt;
               bonus_ann_fy_deprn := bonus_deprn_method_amt;
            ELSE  -- use_deprn_ceil_amt

               IF deprn_method_amt >= deprn_ceiling_amt THEN
                  ann_fy_deprn := deprn_ceiling_amt;
                  bonus_ann_fy_deprn := 0;
               ELSE
                  ann_fy_deprn := deprn_method_amt;

                  IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                     bonus_ann_fy_deprn := deprn_ceiling_amt - deprn_method_amt;
                  ELSE
                     bonus_ann_fy_deprn := 0;
                  END IF;

               END IF;

            END IF; -- use_deprn_prate_amt then

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde','ann_fy_deprn2222',ann_fy_deprn, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','actual_annual_deprn_amt22221111',actual_annual_deprn_amt, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','perd_ctr2222',perd_ctr, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','ret_period_dca2222',ret_period_dcal, p_log_level_rec);
            END IF;

            actual_annual_deprn_amt := ann_fy_deprn;
            actual_annual_bonus_deprn_amt := bonus_ann_fy_deprn;

            -- bonus: ann_fy_deprn and deprn_method_amt still not containing
            --        bonus_ann_fy_deprn or bonus_deprn_method_amt.
            -- first_year_frac holds fraction of the year, i.e. a decimal value.
            -- adj_first_yr_frac is the inverse

            IF (table_rate_src_flag) THEN
               actual_annual_deprn_amt := actual_annual_deprn_amt/adj_first_yr_frac;

               IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                  actual_annual_bonus_deprn_amt := bonus_ann_fy_deprn/adj_first_yr_frac;
               END IF;

            ELSE
               actual_annual_deprn_amt :=
               actual_annual_deprn_amt * (first_year_frac/adj_first_yr_frac);

               IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                  -- bonus
                  actual_annual_bonus_deprn_amt :=
                  bonus_ann_fy_deprn * (first_year_frac/adj_first_yr_frac);
               END IF;
            END IF; --(table_rate_src_flag)

         ELSIF mid_fy_flag THEN

            deprn_method_amt := temp_prate_amt;
            bonus_deprn_method_amt := temp_bonus_prate_amt;

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde','ann_fy_deprn3333',ann_fy_deprn, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','actual_annual_deprn_amt333331',actual_annual_deprn_amt, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','perd_ctr3333',perd_ctr, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','ret_period_dca33333',ret_period_dcal, p_log_level_rec);
            END IF;

            IF use_deprn_prate_amt THEN
               ann_fy_deprn := deprn_method_amt;
               bonus_ann_fy_deprn := bonus_deprn_method_amt;
               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde','ann_fy_deprn3333AAAAA',ann_fy_deprn, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','actual_annual_deprn_amt333331',actual_annual_deprn_amt, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','deprn_method_amt',deprn_method_amt, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','ret_period_dca33333',ret_period_dcal, p_log_level_rec);
               END IF;
            ELSE  -- use_deprn_ceil_amt

               IF deprn_method_amt >= deprn_ceiling_amt THEN
                  ann_fy_deprn := deprn_ceiling_amt;
                  bonus_ann_fy_deprn := 0;
                  IF (p_log_level_rec.statement_level) THEN
                     fa_debug_pkg.ADD('faxcde','ann_fy_deprn3333BBBBBBB',ann_fy_deprn, p_log_level_rec);
                     fa_debug_pkg.ADD('faxcde','deprn_method_amt',deprn_method_amt, p_log_level_rec);
                     fa_debug_pkg.ADD('faxcde','deprn_ceiling_amt',deprn_ceiling_amt, p_log_level_rec);
                     fa_debug_pkg.ADD('faxcde','ret_period_dca33333',ret_period_dcal, p_log_level_rec);
                  END IF;
               ELSE
                  ann_fy_deprn := deprn_method_amt;
                  -- bonus: prorate to bonus..

                  IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                     bonus_ann_fy_deprn := deprn_ceiling_amt - deprn_method_amt;
                  ELSE
                     bonus_ann_fy_deprn := 0;
                  END IF;

                  IF (p_log_level_rec.statement_level) THEN
                     fa_debug_pkg.ADD('faxcde','ann_fy_deprn3333CCCCCCCCC',ann_fy_deprn, p_log_level_rec);
                     fa_debug_pkg.ADD('faxcde','deprn_method_amt',deprn_method_amt, p_log_level_rec);
                     fa_debug_pkg.ADD('faxcde','deprn_ceiling_amt',deprn_ceiling_amt, p_log_level_rec);
                     fa_debug_pkg.ADD('faxcde','ret_period_dca33333',ret_period_dcal, p_log_level_rec);
                  END IF;

               END IF; -- deprn_method_amt >= deprn_ceiling_amt

            END IF; --use_deprn_prate_amt

            actual_annual_deprn_amt := ann_fy_deprn;
            actual_annual_bonus_deprn_amt := bonus_ann_fy_deprn;

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde','ann_fy_deprn4444',ann_fy_deprn, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','actual_annual_deprn_amt44441',actual_annual_deprn_amt, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','perd_ctr4444',perd_ctr, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','ret_period_dca4444',ret_period_dcal, p_log_level_rec);
            END IF;

         ELSIF last_fy_flag THEN
            deprn_method_amt := temp_prate_amt;
            bonus_deprn_method_amt := temp_bonus_prate_amt;

            IF (p_log_level_rec.statement_level) THEN
              fa_debug_pkg.ADD('faxcde','fadpdp(3.5): deprn_method_amt',deprn_method_amt, p_log_level_rec);
            END IF;
             -- Bug 8408871: Start
            IF dpr.ceil_name IS NOT NULL AND (ann_fy_deprn = 0 OR
                 deprn_ceiling_amt < ann_fy_deprn) THEN
                use_deprn_ceil_amt := TRUE;
                use_deprn_prate_amt := FALSE;
            ELSE
                use_deprn_ceil_amt := FALSE;
                use_deprn_prate_amt := TRUE;
            END IF;
             -- Bug 8408871: End
            IF (use_deprn_ceil_amt) THEN
               actual_deprn_end_perd := deprn_perd_fully_rsv;

               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde','ann_fy_deprn5555',ann_fy_deprn, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','deprn_ceiling_amt555555',deprn_ceiling_amt, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','deprn_method_amt555555',deprn_method_amt, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','actual_annual_deprn_amt5555',actual_annual_deprn_amt, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','perd_ctr5555',perd_ctr, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','actual_deprn_end_perd5555',actual_deprn_end_perd, p_log_level_rec);
               END IF;

               IF deprn_method_amt >= deprn_ceiling_amt THEN
                  ann_fy_deprn := deprn_ceiling_amt;
                  bonus_ann_fy_deprn := 0;
               ELSE
                  ann_fy_deprn := deprn_method_amt;

                  -- bonus: prorate to bonus..
                  IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                     bonus_ann_fy_deprn := deprn_ceiling_amt - deprn_method_amt;
                  ELSE
                     bonus_ann_fy_deprn := 0;
                  END IF;
               END IF; -- deprn_method_amt >= deprn_ceiling_amt

            ELSE

               IF (p_log_level_rec.statement_level) THEN
                 fa_debug_pkg.ADD('faxcde','fadpdp(3.6): last_year_frac',last_year_frac);
               END IF;

               IF (table_rate_src_flag) THEN
                  IF ( last_year_frac <= 0) THEN
                     deprn_method_amt := 0;
                     bonus_deprn_method_amt := 0;
                  ELSE
                     -- Bug#4745217: To avoid doubled catchup when retiring assets with Half Yr convention in last FY
                     IF ret_fy_flag THEN
                        deprn_method_amt := temp_prate_amt;
                        bonus_deprn_method_amt := temp_bonus_prate_amt;
                     ELSE
                        -- Bug 8408871: Start
                        deprn_method_amt2 :=temp_prate_amt / last_year_frac;

                        IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                           bonus_deprn_method_amt2 := temp_bonus_prate_amt / last_year_frac;
                        END IF;


                        if dpr.ceil_name IS NOT NULL then
                           deprn_method_amt := least ( deprn_method_amt2, deprn_method_amt,
                                                       ann_fy_deprn);
                           bonus_deprn_method_amt := least ( bonus_deprn_method_amt2,
                                                          bonus_deprn_method_amt, bonus_ann_fy_deprn);
                        else
                           deprn_method_amt := deprn_method_amt2;
                           bonus_deprn_method_amt := bonus_deprn_method_amt2;
                        end if;
                        -- Bug 8408871: End
                     END IF;
                  END IF;
               END IF; -- (table_rate_src_flag)

               -- For assets without depreciation limit,
               -- we stop depreciating in the last period of
               -- life, if asset has depreciation limit then
               -- it may continue to depreciate even past the
               -- last year of life. This only applies to assets
               -- without depreciation ceiling.

               IF NOT use_deprn_limit_flag THEN
                  actual_deprn_end_perd := deprn_perd_fully_rsv;
                  IF (p_log_level_rec.statement_level) THEN
                     fa_debug_pkg.ADD('faxcde','perd_ctr66666',perd_ctr, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.ADD('faxcde','actual_deprn_end_perd11111111',actual_deprn_end_perd, p_log_level_rec => p_log_level_rec);
                  END IF;
               END IF;

               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde','ann_fy_deprn66666',ann_fy_deprn, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','deprn_ceiling_amt66666',deprn_ceiling_amt, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','deprn_method_amt66666',deprn_method_amt, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','actual_annual_deprn_amt66666',actual_annual_deprn_amt, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','perd_ctr66666',perd_ctr, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','actual_deprn_end_perd666666666666',actual_deprn_end_perd, p_log_level_rec);
               END IF;

               ann_fy_deprn := deprn_method_amt;
               bonus_ann_fy_deprn := bonus_deprn_method_amt;

            END IF; -- (use_deprn_ceil_amt) then

            actual_annual_deprn_amt := ann_fy_deprn;
            actual_annual_bonus_deprn_amt := bonus_ann_fy_deprn;

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde','ann_fy_deprn77777',ann_fy_deprn, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','deprn_ceiling_amt77777',deprn_ceiling_amt, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','deprn_method_amt7777',deprn_method_amt, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','actual_annual_deprn_amt677777',actual_annual_deprn_amt, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','perd_ctr7777',perd_ctr, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','ret_period_dca67777',ret_period_dcal, p_log_level_rec);
            END IF;
         ELSIF (after_eol_fy_flag) THEN

            -- if asset does not has deprn limit then fully
            -- reserve the asset in the current period
            -- otherwise set annual deprn amount to
            -- temp_prate_amt as if asset is in the middle year
            -- of life
            -- bonus here?
            IF NOT use_deprn_limit_flag THEN

               IF NOT use_deprn_ceil_amt THEN
                  -- Fully reserve the asset in the
                  -- current period
                  use_deprn_ceil_amt := TRUE;
                  use_deprn_prate_amt := FALSE;
                  deprn_ceiling_amt := dpr.rec_cost * perds_per_yr_dcal;
               END IF;

               ann_fy_deprn := deprn_ceiling_amt;
               bonus_ann_fy_deprn := 0;
               IF dpr_in.method_code = 'JP-STL-EXTND' THEN
                  ann_fy_deprn := temp_prate_amt;
               END IF;

               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde','ann_fy_deprn8888888',ann_fy_deprn, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','deprn_ceiling_amt88888',deprn_ceiling_amt, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','deprn_method_amt88888',deprn_method_amt, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','actual_annual_deprn_amt88888',actual_annual_deprn_amt, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','perd_ctr8888',perd_ctr, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','ret_period_dca888',ret_period_dcal, p_log_level_rec);
               END IF;
           ELSE
               -- we assume that asset can only has deprn
               -- limit or deprn ceiling
               ann_fy_deprn := temp_prate_amt;
               bonus_ann_fy_deprn := temp_bonus_prate_amt;
            END IF; -- not use_deprn_limit_flag then

            actual_annual_deprn_amt := ann_fy_deprn;
            actual_annual_bonus_deprn_amt := bonus_ann_fy_deprn;

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde','ann_fy_deprn99999',ann_fy_deprn, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','deprn_ceiling_amt99999',deprn_ceiling_amt, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','deprn_method_amt9999',deprn_method_amt, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','actual_annual_deprn_amt9999',actual_annual_deprn_amt, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','perd_ctr9999',perd_ctr, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde','ret_period_dca9999',ret_period_dcal, p_log_level_rec);
            END IF;
         ELSE
            actual_deprn_end_perd := 0;
            ann_fy_deprn := 0;
            actual_annual_deprn_amt := 0;
            bonus_ann_fy_deprn := 0;
            actual_annual_bonus_deprn_amt := 0;
         END IF; -- (first_fy_flag) then

         IF dpr_in.method_code = 'JP-STL-EXTND' THEN
            ann_fy_deprn := temp_prate_amt;
            actual_deprn_end_perd := perds_per_yr_dcal;
         END IF;


         --
         -- Bug 3270280
         --         if ret_fy_flag then
         -- Bug3961991
         -- Added condition dpr_in.deprn_override_flag <>  fa_std_types.FA_OVERRIDE_RECURSIVE
         -- so that following condition will not be true during recursive call.
         IF ((ret_fy_flag) AND (NOT depr_last_year_flag) OR (ret_fy_flag AND first_fy_flag)) AND
            dpr_in.deprn_override_flag <>  fa_std_types.FA_OVERRIDE_RECURSIVE THEN

            deprn_start_perd := ret_period_dcal;
            deprn_end_perd := ret_period_dcal;

            actual_deprn_start_perd := ret_period_dcal;
            actual_deprn_end_perd := ret_period_dcal;

            --bug fix 3695153 starts
            IF(ret_period_dcal < ret_prorate_period_pcal) AND (first_fy_flag)THEN
                actual_deprn_start_perd := perd_ctr;
                actual_deprn_end_perd := perd_ctr;
            END IF;
            --bug fix 3695153 ends
         END IF;

         -- bonus: sum bonus amount into ann_fy_deprn now.
         IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
            ann_fy_deprn := ann_fy_deprn + bonus_ann_fy_deprn;
            -- latest bonus addition:
            actual_annual_deprn_amt := actual_annual_deprn_amt + actual_annual_bonus_deprn_amt;
         END IF;

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcde','ann_fy_deprnxxxxxxxxxx',ann_fy_deprn, p_log_level_rec);
            fa_debug_pkg.ADD('faxcde','deprn_ceiling_amxxxxxxx',deprn_ceiling_amt, p_log_level_rec);
            fa_debug_pkg.ADD('faxcde','deprn_method_amtxxxxxxxx',deprn_method_amt, p_log_level_rec);
            fa_debug_pkg.ADD('faxcde','perd_ctrxxxxxxxxx',perd_ctr, p_log_level_rec);
            fa_debug_pkg.ADD('faxcde','actual_deprn_start_perd',actual_deprn_start_perd, p_log_level_rec);
            fa_debug_pkg.ADD('faxcde','actual_deprn_end_perd',actual_deprn_end_perd, p_log_level_rec);
         END IF;

         -- currency formatting.Modified for bug6988823.
         h_dummy_bool := fa_utils_pkg.faxtru (ann_fy_deprn, dpr.book, dpr.set_of_books_id, p_log_level_rec);
         h_dummy_bool := fa_utils_pkg.faxrnd (actual_annual_deprn_amt, dpr.book,dpr.set_of_books_id, p_log_level_rec);

         IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
            h_dummy_bool := fa_utils_pkg.faxtru (bonus_ann_fy_deprn, dpr.book, dpr.set_of_books_id, p_log_level_rec);
            h_dummy_bool := fa_utils_pkg.faxtru (actual_annual_bonus_deprn_amt, dpr.book, dpr.set_of_books_id, p_log_level_rec);
         END IF;

         --
         -- Debug
         --
         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcde','fadpdp(4): ann_fy_deprn',ann_fy_deprn, p_log_level_rec);
            fa_debug_pkg.ADD('faxcde','actual_annual_deprn_amt',actual_annual_deprn_amt, p_log_level_rec);
            fa_debug_pkg.ADD('faxcde','perd_ctr',perd_ctr, p_log_level_rec);
            fa_debug_pkg.ADD('faxcde','ret_period_dcal',ret_period_dcal, p_log_level_rec);
         END IF;

         IF dpr_in.method_code = 'JP-STL-EXTND' THEN
            actual_deprn_end_perd := perds_per_yr_dcal;
         END IF;
         --
         -- deprn_start_perd is the first period in this fiscal year
         -- for which we want to return a value.
         -- deprn_end_perd is the last period in this fiscal year
         -- for which we want to return a value.
         --
         -- bonus: sum bonus amount into ann_fy_deprn now.
         --     if nvl(dpr.bonus_rule, 'NONE') <> 'NONE' then
         --       ann_fy_deprn := ann_fy_deprn + bonus_ann_fy_deprn;
         -- latest bonus addition:
         --       actual_annual_deprn_amt := actual_annual_deprn_amt + actual_annual_bonus_deprn_amt;
         --     end if;

         -- *************************************************************
         -- Commented out and moved period loop for period update method
         -- This is the point where for loop for each period located
         --     for perd_ctr in deprn_start_perd .. deprn_end_perd loop
         -- ************************************************************
         deprn_override_flag:= fa_std_types.FA_NO_OVERRIDE;

         --
         -- actual_deprn_start_perd is the first period in this fy
         -- for which the depreciation can be non-zero.
         -- actual_deprn_end_perd is the last period in this fy for
         -- which the depreciation can be non-zero.
         --
         IF ((perd_ctr >= actual_deprn_start_perd) AND
             (perd_ctr <= actual_deprn_end_perd)) THEN

            IF first_fy_flag AND
               (perd_ctr = actual_deprn_start_perd) AND
               (NOT ret_fy_flag) THEN

               deprn_frac_of_yr := first_perd_frac;


               -- Added the Below code to take care of the Bug# 7277598
               -- Below code calculates the  Prorata Depreciable amount , if the asset is added with JP-250DB XX
               --  and NBV_AT_SWITCH in the Middle of the FY
               IF l_request_short_name = 'FAWDPR' then
                  -- Removed and "l_nbv_at_switch is not null" clause and "first_fy_flag = TRUE  AND" clause
                  -- from the Below IF condition , as this should work for all scenarios.
                  IF (NVL(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, 'NO') = 'YES')  THEN  --- Checking for Methods JP-250DB XX
                     IF NOT(dpr_run_flag) AND deprn_start_perd <> 1 AND deprn_start_perd <> perds_per_yr_dcal THEN             -- BUG# 7304706 : NOT(dpr_run_flag) clause is added
                        deprn_frac_of_yr := (perds_per_yr_dcal/(perds_per_yr_dcal - deprn_start_perd + 1))*(1/perds_per_yr_dcal);
                     END IF;
                  END IF;
               END IF;
               -- End of Addition BUG# 7277598

               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde','fadpdp(4.5.1): deprn_frac_of_yr',deprn_frac_of_yr, p_log_level_rec);
               END IF;
               --bug fix 3233833 starts
               -- code fix for bug4213110: enter the following condition only if the no of pds in deprn and prorate calendar are same.
               -- bug fix 5487875 (added and condition (perd_ctr <> ret_period_dcal) at the end of elsif)
            ELSIF ret_fy_flag  AND
                        (ret_period_dcal < ret_prorate_period_pcal) AND (perds_per_yr_pcal = perds_per_yr_dcal) AND
                           (perd_ctr <> ret_period_dcal) THEN
               deprn_frac_of_yr :=  (ret_prorate_period_pcal - perd_ctr)/perds_per_yr_dcal;
               --bug fix 3233833 ends

               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde','fadpdp(4.5.2): ret_period_dcal',ret_period_dcal, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','fadpdp(4.5.2): ret_prorate_period_pcal',ret_prorate_period_pcal, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','fadpdp(4.5.2): perds_per_yr_pcal',perds_per_yr_pcal, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','fadpdp(4.5.2): perds_per_yr_dcal',perds_per_yr_dcal, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde','fadpdp(4.5.2): perd_ctr',perd_ctr);
               END IF;
               --Bug7133501 Added for cases where prorate falls in next year
            ELSIF ret_fy_flag  AND
                  (ret_period_dcal > ret_prorate_period_pcal) AND
                  (fy_ret < ret_year_pcal) AND
                  (perds_per_yr_pcal = perds_per_yr_dcal) AND
                  (perd_ctr <> ret_period_dcal) THEN
               deprn_frac_of_yr :=  (perds_per_yr_dcal - perd_ctr + ret_prorate_period_pcal)/perds_per_yr_dcal;

               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde','fadpdp(4.5.3): deprn_frac_of_yr',deprn_frac_of_yr);
               END IF;
            ELSIF ret_fy_flag AND
                  (perd_ctr = ret_period_dcal) THEN
               deprn_frac_of_yr := ret_perd_frac;

               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde','fadpdp(4.5.4): deprn_frac_of_yr',deprn_frac_of_yr);
               END IF;
            ELSIF use_deprn_prate_amt AND
                  (fyctr = fy_fully_rsv) AND
                  (perd_ctr = deprn_perd_fully_rsv) AND
                  NOT use_deprn_limit_flag THEN
               deprn_frac_of_yr := last_perd_frac;
               IF dpr_in.method_code = 'JP-STL-EXTND' THEN
                  deprn_frac_of_yr := perds_fracs_arr(perd_ctr-1).frac;
               END IF;

               IF (p_log_level_rec.statement_level) THEN
                 fa_debug_pkg.ADD('faxcde','fadpdp(4.5.5): deprn_frac_of_yr',deprn_frac_of_yr);
               END IF;
            ELSE
               --
               -- always get fraction from cache for
               -- assets using flat rate or having
               -- deprn limit
               --
               deprn_frac_of_yr := perds_fracs_arr(perd_ctr-1).frac;

               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde','fadpdp(4.5.6): perd_ctr',perd_ctr);
                  fa_debug_pkg.ADD('faxcde','fadpdp(4.5.6): deprn_frac_of_yr',deprn_frac_of_yr);
               END IF;
            END IF; -- first_fy_flag and

            -- bonus: perd_deprn_exp including perd_bonus_deprn_amount, since ann_fy_deprn
            --    kept the total amount.
            perd_deprn_exp := ann_fy_deprn * deprn_frac_of_yr;
            -- start: bug 8408871
            if (NVL(year_deprn_exp,0) + perd_deprn_exp > ann_fy_deprn) AND
                (dpr.ceil_name IS NOT NULL)
            then
                perd_deprn_exp   := ann_fy_deprn - NVL(year_deprn_exp,0);
            end if;
            -- end: bug 8408871

            -- bonus? investigate.
            IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
               perd_bonus_deprn_amount := bonus_ann_fy_deprn * deprn_frac_of_yr;
            -- start: bug 8408871
               if (NVL(year_bonus_deprn_amount,0) + perd_bonus_deprn_amount > bonus_ann_fy_deprn) AND
                    (dpr.ceil_name IS NOT NULL)
               then
                    perd_bonus_deprn_amount   := bonus_ann_fy_deprn - NVL(year_bonus_deprn_amount,0);
               end if;
            -- end: bug 8408871
            END IF;
            --
            -- In case of subtract ytd falg is true, multiply number of
            -- period past in this fiscal year to periodic depreciation
            -- and subtract passed ytd deprn amount to find periodic exp.
            --
            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD(l_calling_fn, 'p_subtract_ytd_flag', p_subtract_ytd_flag, p_log_level_rec);
            END IF;

            IF (NVL(p_subtract_ytd_flag,'N') = 'Y') THEN

               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD(l_calling_fn||' OPA', 'cache: use_eofy_reserve_flag',
                                   fa_cache_pkg.fazcdrd_record.use_eofy_reserve_flag, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.ADD(l_calling_fn||' OPA', 'cache: allow_reduction_rate_flag',
                                   fa_cache_pkg.fazcdrd_record.allow_reduction_rate_flag, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.ADD(l_calling_fn||' OPA', 'cache: rate_source_rule',
                                   fa_cache_pkg.fazccmt_record.rate_source_rule, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.ADD(l_calling_fn||' OPA', 'cache: deprn_basis_rule',
                                   fa_cache_pkg.fazccmt_record.deprn_basis_rule, p_log_level_rec => p_log_level_rec);
               END IF;

               --
               -- Change for OPA
               --
               IF (fa_cache_pkg.fazcdrd_record.use_eofy_reserve_flag = 'Y' AND
                   fa_cache_pkg.fazcdrd_record.allow_reduction_rate_flag = 'N' AND
                   fa_cache_pkg.fazccmt_record.rate_source_rule = 'FLAT' AND
                   fa_cache_pkg.fazccmt_record.deprn_basis_rule = 'COST') THEN
                  --
                  -- Find ytd using (reserve - eofy reserve)
                  -- find remaining period in fy using (num per in fy - period num + 1)
                  -- formula to find peridic exp is
                  -- ((adj_cost * rate) - ytd) / remaining period in fy
                  --
                  IF (p_log_level_rec.statement_level) THEN
                     fa_debug_pkg.ADD(l_calling_fn||' OPA', 'ann_fy_deprn', ann_fy_deprn, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.ADD(l_calling_fn||' OPA', 'ann_deprn_rate', ann_deprn_rate, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.ADD(l_calling_fn||' OPA', 'cur_deprn_rsv', cur_deprn_rsv, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.ADD(l_calling_fn||' OPA', 'cur_eofy_reserve', cur_eofy_reserve, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.ADD(l_calling_fn||' OPA', 'perds_per_yr_dcal', perds_per_yr_dcal, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.ADD(l_calling_fn||' OPA', 'perd_ctr', perd_ctr, p_log_level_rec => p_log_level_rec);
                  END IF;

                  perd_deprn_exp := (cur_adj_cost * ann_deprn_rate -
                                     (NVL(cur_deprn_rsv,0)+ NVL(year_deprn_exp,0) - cur_eofy_reserve))/
                                    (perds_per_yr_dcal - perd_ctr + 1);
                  IF (p_log_level_rec.statement_level) THEN
                     fa_debug_pkg.ADD(l_calling_fn||' OPA', 'perd_deprn_exp', perd_deprn_exp, p_log_level_rec => p_log_level_rec);
                  END IF;

               ELSE

                  IF (p_log_level_rec.statement_level) THEN
                     fa_debug_pkg.ADD('HH DEBUG', 'perd_deprn_exp(before)',perd_deprn_exp);
                     fa_debug_pkg.ADD('HH DEBUG', 'perd_ctr',perd_ctr, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.ADD('HH DEBUG', 'dpr_in.ytd_deprn',dpr_in.ytd_deprn, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.ADD('HH DEBUG', 'year_deprn_exp',year_deprn_exp, p_log_level_rec => p_log_level_rec);
                  END IF;

                  IF (fyctr = dpr.y_begin) THEN
                     perd_deprn_exp := perd_deprn_exp * perd_ctr - dpr_in.ytd_deprn;

                     IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                        perd_bonus_deprn_amount := perd_bonus_deprn_amount * perd_ctr - dpr.bonus_ytd_deprn;
                     END IF;

                  ELSE
                     perd_deprn_exp := perd_deprn_exp * perd_ctr - NVL(year_deprn_exp,0);

                     IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                        perd_bonus_deprn_amount :=
                             perd_bonus_deprn_amount * perd_ctr - year_bonus_deprn_amount;
                     END IF;

                  END IF; -- (fyctr = dpr.y_begin)
               END IF; -- Change for OPA

            END IF; -- (nvl(p_subtract_ytd_flag,'N') = 'Y')

            dpr_out.ann_adj_exp := ann_fy_deprn;
            --
            -- Debug
            --
            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde', 'fadpdp(4.0): ann_fy_deprn',ann_fy_deprn);
               fa_debug_pkg.ADD('faxcde', 'deprn_frac_of_yr',deprn_frac_of_yr, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'perd_deprn_exp',perd_deprn_exp, p_log_level_rec => p_log_level_rec);
            END IF;

            --
            --  if the profile option:FA_DEPRN_OVERRIDE_ENABLED = 'Y' and
            --  this is not for what-if analysis, call FAODDA funtion to
            --  upload the override depreciation data
            --
            override_depr_amt:= NULL;
            override_bonus_amt:= NULL;

            /* As mentioned above we should not override deprn value for what-if-analysis
               So, added check for What-If analysis bug 7645269*/

            -- Bug 8211842: Added nvl
            IF (fa_cache_pkg.fa_deprn_override_enabled) AND (nvl(l_request_short_name,'X') <> 'FAWDPR')  THEN
               whatif_override_enable := 'Y';
            ELSE
               whatif_override_enable := 'N';
            END IF;

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde', 'FA_DEPRN_OVERRIDE_ENABLED', whatif_override_enable, p_log_level_rec => p_log_level_rec);
            END IF;

            IF whatif_override_enable = 'Y' AND
               NVL(dpr_in.deprn_override_flag, fa_std_types.FA_NO_OVERRIDE) <> fa_std_types.FA_OVERRIDE_RECURSIVE THEN
               l_bonus_ytd_deprn := 0;

               IF fyctr = dpr.y_begin THEN
                  l_ytd_deprn := dpr_in.ytd_deprn;

                  IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                     l_bonus_ytd_deprn := dpr.bonus_ytd_deprn;
                  END IF;
               ELSE
                  l_ytd_deprn := NVL(year_deprn_exp,0);

                  IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                     l_bonus_ytd_deprn := year_bonus_deprn_amount;
                  END IF;
               END IF;

               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde', 'fadpdp: dpr_in.deprn_override_flag',dpr_in.deprn_override_flag, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'fadpdp: dpr_in.override_period_counter',dpr_in.override_period_counter, p_log_level_rec => p_log_level_rec);
               END IF;

               /*Bug# - 8487934 */
               if (dpr.over_depreciate_option = fa_std_types.FA_OVER_DEPR_YES) then
                  l_over_depreciate_option := 2;
               elsif (dpr.over_depreciate_option = fa_std_types.FA_OVER_DEPR_NO) then
                  l_over_depreciate_option := 1;
               else
                  l_over_depreciate_option := 0;
               end if;

               IF NOT FAODDA(dpr.book
                           , dpr.used_by_adjustment
                           , dpr.asset_id
                           , dpr.bonus_rule
                           , fyctr
                           , perd_ctr
                           , prod_rate_src_flag
                           , deprn_projecting_flag
                           , l_ytd_deprn
                           , l_bonus_ytd_deprn
                           , override_depr_amt
                           , override_bonus_amt
                           , deprn_override_flag
                           , return_code
                           , dpr.mrc_sob_type_code
                           , dpr.set_of_books_id
                           , dpr.rec_cost
                           , dpr.salvage_value
                           , dpr.update_override_status
                           , l_over_depreciate_option
                           , dpr.asset_type
                           , dpr.deprn_rsv
                           , dpr.rec_cost
                           , dpr.override_period_counter
                           , p_log_level_rec) THEN

                  fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faooda',  p_log_level_rec => p_log_level_rec);
                  dpr_out.deprn_override_flag:= fa_std_types.FA_NO_OVERRIDE;
                  RETURN(FALSE);

               END IF;

               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde', 'fadpdp: deprn_override_flag',deprn_override_flag, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'fadpdp: faodda:return_code',return_code, p_log_level_rec => p_log_level_rec);
               END IF;

               -- Bug#7953789 - start
               if return_code = 2 then
                  fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faooda', p_log_level_rec => p_log_level_rec);
                  dpr_out.deprn_override_flag:= fa_std_types.FA_NO_OVERRIDE;
               end if;
               -- Bug#7953789 end

            END IF; -- value = 'Y' and

            --
            -- re-calculate perd_deprn_exp to use substraction method
            -- if current period is the last period of fiscal year
            -- and deprn_rounding_flag is NULL or ADD
            -- perd_deprn_exp = actual_annual_deprn_amt -
            --  ((dpr.ytd_deprn + ytd_deprn_sum) -
            --  (dpr.prior_fy_exp +prior_fy_exp_sum ))
            --
            -- we can not use substraction method for projection
            -- since dpr.ytd_deprn has incorrect value if the
            -- projection staring period is later than the current
            -- period. it's a temp fix. To fix tis problem, we
            -- need to return the value of ytd_deprn in dpr_out
            -- then copy it to dpr.ytd_deprn when calling the
            -- faxcde at the second time

            --
            -- This is set appropriately in what-if so take what is passed
            -- to faxcde. or apply this only for the first year.
            --if deprn_projecting_flag then
            --   dpr.deprn_rounding_flag:= fa_std_types.FA_DPR_ROUND_RES;
            --end if;

            -- Bug #2686687
            -- Annual rounding should be performed if current period is
            -- the last period of fiscal year; AND
            --    when there was no override; OR
            --    when overridden only bonus depreciation amount

            IF (perd_ctr=perds_per_yr_dcal AND
                (deprn_override_flag = fa_std_types.FA_NO_OVERRIDE OR
                 deprn_override_flag = fa_std_types.FA_OVERRIDE_BONUS) AND
                NVL(fa_cache_pkg.fazcdrd_record.period_update_flag,'N') ='N' AND
                NVL(fa_cache_pkg.fazcdrd_record.subtract_ytd_flag,'N') ='N') THEN

               IF (dpr.deprn_rounding_flag = fa_std_types.FA_DPR_ROUND_ADD OR
                   dpr.deprn_rounding_flag IS NULL) THEN
                  --
                  --  Go into following logic if this is group (except sumup) or calculating member
                  --
                  IF (NVL(dpr.asset_type, 'CAPITALIZED') = 'GROUP' AND
                      NVL(dpr.member_rollup_flag, 'N') <> 'Y') OR
                     (NVL(dpr.asset_type, 'CAPITALIZED') <> 'GROUP' AND
                      NVL(dpr.tracking_method, 'NULL') = 'CALCULATE') THEN

                     perd_deprn_exp := actual_annual_deprn_amt -
                                       (NVL(cur_deprn_rsv,0)+ NVL(year_deprn_exp,0) - cur_eofy_reserve);

                     IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                        perd_bonus_deprn_amount := perd_deprn_exp *
                                                   (dpr_out.bonus_rate_used /
                                                    (ann_deprn_rate + dpr_out.bonus_rate_used));
                     END IF;

                  ELSE
                     -- Bonus
                     -- Should actual_annual_deprn_amt be added with actual_annual_bonus_deprn_amt?
                     -- Yes, included. See before the loop.
                     -- Original equation only works for first year in fy loop.
                     --

                     IF (p_log_level_rec.statement_level) THEN
                        fa_debug_pkg.ADD('faxcde', 'fyctr', fyctr, p_log_level_rec);
                        fa_debug_pkg.ADD('faxcde', 'dpr.y_begin', dpr.y_begin, p_log_level_rec);
                        fa_debug_pkg.ADD('faxcde', 'dpr.ytd_deprn', dpr.ytd_deprn, p_log_level_rec);
                        fa_debug_pkg.ADD('faxcde', 'ytd_deprn_sum', ytd_deprn_sum, p_log_level_rec);
                        fa_debug_pkg.ADD('faxcde', 'actual_annual_deprn_amt', actual_annual_deprn_amt, p_log_level_rec);
                        fa_debug_pkg.ADD('faxcde', 'dpr.prior_fy_exp', dpr.prior_fy_exp, p_log_level_rec);
                        fa_debug_pkg.ADD('faxcde', 'prior_fy_exp_sum', prior_fy_exp_sum, p_log_level_rec);
                        fa_debug_pkg.ADD('faxcde', 'year_deprn_exp', year_deprn_exp, p_log_level_rec);
                     END IF;

                     -- Bug5152481: Added "(dpr_in.p_cl_begin <> 1)" to the following
                     --             if statement.
                     IF (fyctr = dpr.y_begin) AND (dpr_in.p_cl_begin <> 1) THEN
                        perd_deprn_exp := (actual_annual_deprn_amt -
                                           ((dpr.ytd_deprn + ytd_deprn_sum) -
                                            (dpr.prior_fy_exp + prior_fy_exp_sum)));
                     ELSE
                        perd_deprn_exp := actual_annual_deprn_amt - NVL(year_deprn_exp,0);
                     END IF;

                     -- bonus? Investigate the statement below! This case is for last
                     --period in fiscal year.
                     -- Now added prior_fy_bonus_exp_sum.
                     IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                        -- Bug 5057908: Added nvl
                        perd_bonus_deprn_amount := (actual_annual_bonus_deprn_amt -
                                                    ((dpr.bonus_ytd_deprn + ytd_bonus_deprn_sum) -
                                                     (NVL(dpr.prior_fy_bonus_exp,0) + prior_fy_bonus_exp_sum)));
                     END IF;
                  END IF; -- (nvl(dpr.asset_type, 'CAPITALIZED') = 'GROUP' and ..

               ELSIF (dpr.deprn_rounding_flag = fa_std_types.FA_DPR_ROUND_ADJ OR
                      dpr.deprn_rounding_flag = fa_std_types.FA_DPR_ROUND_RET OR
                      dpr.deprn_rounding_flag = fa_std_types.FA_DPR_ROUND_REV OR
                      dpr.deprn_rounding_flag = fa_std_types.FA_DPR_ROUND_TFR OR
                      dpr.deprn_rounding_flag = fa_std_types.FA_DPR_ROUND_RES OR
                      dpr.deprn_rounding_flag = fa_std_types.FA_DPR_ROUND_OVE) THEN

                  IF ann_rounding_mode=ROUND_ALWAYS THEN
                     dpr_sub:= dpr_in;
                     dpr_sub.bonus_deprn_rsv:= 0;
                     dpr_sub.deprn_rsv:= 0;
                     dpr_sub.ltd_prod:= 0;
                     dpr_sub.ytd_deprn:= 0;

                     dpr_sub.y_begin:= fyctr;
                     dpr_sub.y_end:= fyctr;
                     dpr_sub.p_cl_begin:= 1;
                     dpr_sub.p_cl_end:= perds_per_yr_dcal - 1;

                     dpr_sub.deprn_override_flag:= fa_std_types.FA_OVERRIDE_RECURSIVE;

                     -- Bug3493721:
                     --   Rounding should always be done during recursive call
                     --
                     dpr_sub.deprn_rounding_flag := NULL;

                     IF (nbv_deprn_basis_flag AND excl_sal_val_flag) THEN
                        dpr_sub.adj_cost := cur_adj_cost - dpr.salvage_value;
                     ELSE
                        dpr_sub.adj_cost := cur_adj_cost;
                     END IF;

                     --Bug # 7561254
                     IF ( (dpr_out.full_rsv_flag) AND
                          (l_request_short_name = 'FAWDPR') AND
                          (dpr_in.method_code = 'JP-STL-EXTND'))  then
                        perd_deprn_exp := 0;
                     Else
                        IF NOT fa_cde_pkg.faxcde(dpr_sub,
                                                 h_dummy_dpr,
                                                 dpr_out,
                                                 fmode,
                                                 p_log_level_rec => p_log_level_rec) THEN
                           fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde',  p_log_level_rec => p_log_level_rec);
                           RETURN (FALSE);
                        END IF;
                        perd_deprn_exp := actual_annual_deprn_amt - dpr_out.deprn_exp;
                     END IF;

                     fa_debug_pkg.ADD('faxcde', 'fadpdp(4.1): IN :actual_annual_deprn_amt ', nbv_absval||','||actual_annual_deprn_amt||','||dpr_out.deprn_exp||','||ann_fy_deprn, p_log_level_rec);

                     -- Added the Below code to take care of the Bug# 7277598
                     -- Below code calculates the  Prorata Depreciable amount , if the asset is added with JP-250DB XX and NBV_AT_SWITCH in the Mid of the FY

                     IF l_request_short_name = 'FAWDPR' then
                        -- Removed and "l_nbv_at_switch is not null" clause and "first_fy_flag = TRUE  AND" clause from the Below IF condition , as this should work for all scenarios.
                        IF (NVL(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, 'NO') = 'YES')  THEN  --- Checking for Methods JP-250DB XX
                           IF   NOT(dpr_run_flag) AND deprn_start_perd <> 1 AND deprn_start_perd <> perds_per_yr_dcal THEN      -- BUG# 7304706 : NOT(dpr_run_flag) clause is added
                              /*Bug 7539379 changed below calculation for last period deprn amount */
                              --perd_deprn_exp := ann_fy_deprn - ytd_deprn_sum;
                              perd_deprn_exp := temp_round_amt - temp_round_amt1;
                           END IF;
                        END IF;
                     END IF;

                     -- End of Addition BUG# 7277598

                  END IF; -- ann_rounding_mode=ROUND_ALWAYS then

               ELSE
                  fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxcde',
                                          name            => 'FA_DEPRN_ILLEGAL_VALUE',
                                          token1          => 'VARIABLE',
                                          value1          => 'Deprn_Rounding_Flag',
                                          token2          => 'VALUE',
                                          value2          => dpr.deprn_rounding_flag,
                                          TRANSLATE       => FALSE,
                                          p_log_level_rec => p_log_level_rec);
                  RETURN (FALSE);
               END IF; -- (dpr.deprn_rounding_flag = fa_std_types.FA_DPR_ROUND_ADD or

               --
               -- Debug
               --
               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde', 'fadpdp(4.1): IN :perd_deprn_exp ', perd_deprn_exp);
                  fa_debug_pkg.ADD('faxcde', 'actual_annual_deprn_amt',actual_annual_deprn_amt, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'dpr.ytd_deprn',dpr.ytd_deprn, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'ytd_deprn_sum',ytd_deprn_sum, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'dpr.prior_fy_exp', dpr.prior_fy_exp, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'dpr.prior_fy_bonus_exp', dpr.prior_fy_exp, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'prior_fy_exp_sum',prior_fy_exp_sum, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'fadpdp(4.1) OUT :perd_deprn_exp ', perd_deprn_exp);
               END IF;
            END IF; -- (perd_ctr=perds_per_yr_dcal and

            IF (prod_rate_src_flag) THEN
               period_fracs_single.frac := perds_fracs_arr(perd_ctr-1).frac;
               period_fracs_single.start_jdate :=
               perds_fracs_arr(perd_ctr-1).start_jdate;
               period_fracs_single.end_jdate :=
               perds_fracs_arr(perd_ctr-1).end_jdate;

               IF NOT fa_cde_pkg.faxgpr(dpr,
                                        period_fracs_single,
                                        deprn_projecting_flag,
                                        perd_prod,
                                        p_log_level_rec) THEN
                  fa_srvr_msg.add_message ( calling_fn => 'fa_cde_pkg.faxcde',  p_log_level_rec => p_log_level_rec);
                  RETURN (FALSE);
               END IF;

               IF dpr.rate_adj_factor <= 0 THEN
                  fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxcde',
                                          name            => 'FA_DEPRN_ILLEGAL_VALUE',
                                          token1          => 'VARIABLE',
                                          value1          => 'Rate_Adjustment_Factor',
                                          token2          => 'VALUE',
                                          value2          => dpr.rate_adj_factor,
                                          TRANSLATE       => FALSE,
                                          p_log_level_rec => p_log_level_rec);
                  RETURN (FALSE);
               END IF;

               IF dpr.capacity <= 0  THEN
                  fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde',
                                          name => 'FA_DEPRN_ILLEGAL_VALUE',
                                          token1 => 'VARIABLE',
                                          value1 => 'Capacity',
                                          token2 => 'VALUE',
                                          value2 => dpr.capacity,
                                          TRANSLATE => FALSE,  p_log_level_rec => p_log_level_rec);
                  RETURN (FALSE);
               END IF;

               IF dpr.adj_capacity < 0 THEN
                  fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde',
                                          name => 'FA_DEPRN_ILLEGAL_VALUE',
                                          token1 => 'VARIABLE',
                                          value1 => 'Adjusted_Capacity',
                                          token2 => 'VALUE',
                                          value2 => dpr.adj_capacity,
                                          TRANSLATE => FALSE,  p_log_level_rec => p_log_level_rec);
                  RETURN (FALSE);
               END IF;

               --
               -- Debug
               --
               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde', 'fadpdp(5): cur_adj_cost', cur_adj_cost);
                  fa_debug_pkg.ADD('faxcde', 'dpr.rate_adj_factor', dpr.rate_adj_factor, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'perd_prod', perd_prod, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'dpr.adj_capacity', dpr.adj_capacity, p_log_level_rec => p_log_level_rec);
               END IF;

               if dpr.adj_capacity = 0 then
                  perd_deprn_exp := 0;
               else
                  perd_deprn_exp := (cur_adj_cost / dpr.rate_adj_factor) *
                                    (perd_prod / dpr.adj_capacity);
               end if;

               -- Main tain adj_capacity
               IF (NVL(fa_cache_pkg.fazcdrd_record.period_update_flag,'N') ='Y') THEN -- ENERGY
                  dpr.adj_capacity := dpr.adj_capacity - perd_prod;                   -- ENERGY
               END IF;                                                                -- ENERGY

               -- bonus: Not tracking for production.
               perd_bonus_deprn_amount := 0;
               dpr_out.ann_adj_exp := 0;

               --
               -- Debug
               --
               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde', 'fadpdp(6): perd_deprn_exp', perd_deprn_exp);
               END IF;
            ELSE
               perd_prod := 0;
            END IF; -- (prod_rate_src_flag) then

            IF (deprn_projecting_flag OR
               ann_rounding_mode=ROUND_ALWAYS) THEN
               --
               -- Round perd_deprn_exp ONLY if Projecting
               --

               IF NOT fa_utils_pkg.faxrnd(perd_deprn_exp, dpr.book, dpr.set_of_books_id, p_log_level_rec => p_log_level_rec) THEN
                  fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde',  p_log_level_rec => p_log_level_rec);
                  RETURN (FALSE);
               END IF;

               -- bonus: Assignment to perd_bonus_deprn_amount earlier should be checked.
               IF NOT fa_utils_pkg.faxrnd(perd_bonus_deprn_amount, dpr.book, dpr.set_of_books_id, p_log_level_rec => p_log_level_rec) THEN
                  fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde',  p_log_level_rec => p_log_level_rec);
                  RETURN (FALSE);
               END IF;

            END IF; -- (deprn_projecting_flag or

            -- perform override depreciation for each uploaded data from the interface table
            IF (deprn_override_flag <> fa_std_types.FA_NO_OVERRIDE) THEN

               --Bug 5657699
               SELECT adjusted_cost
               INTO l_temp_adj_cost
               FROM fa_books
               WHERE book_type_code = dpr.book
               AND asset_id = dpr.asset_id
               AND transaction_header_id_out IS NULL;

               IF (l_temp_adj_cost <> dpr_in.adj_cost or l_temp_adj_cost <> 0) THEN -- Bug 5657699
                                                                                    -- Bug 8579500
                  --
                  -- Debug
                  --
                  IF (p_log_level_rec.statement_level) THEN
                     fa_debug_pkg.ADD('faxcde', 'perd_deprn_exp(default)', perd_deprn_exp);

                     IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                        fa_debug_pkg.ADD('faxcde', 'perd_bonus_deprn_amount(default)', perd_bonus_deprn_amount);
                     END IF;
                  END IF;

                  IF deprn_override_flag = fa_std_types.FA_OVERRIDE_BONUS OR
                     deprn_override_flag = fa_std_types.FA_OVERRIDE_DPR_BONUS THEN
                     perd_deprn_exp:= perd_deprn_exp - NVL(perd_bonus_deprn_amount, 0);
                     perd_bonus_deprn_amount:= NVL(override_bonus_amt,0);
                  END IF;

                  IF deprn_override_flag = fa_std_types.FA_OVERRIDE_DPR OR
                     deprn_override_flag = fa_std_types.FA_OVERRIDE_DPR_BONUS THEN

                     IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                        perd_deprn_exp:= override_depr_amt + NVL(perd_bonus_deprn_amount,0);
                     ELSE
                        perd_deprn_exp:= override_depr_amt;
                     END IF;
                  ELSE
                     perd_deprn_exp:= perd_deprn_exp + perd_bonus_deprn_amount;
                  END IF;

                  --
                  -- Debug
                  --
                  IF (p_log_level_rec.statement_level) THEN
                     fa_debug_pkg.ADD('faxcde', 'perd_deprn_exp(new)', perd_deprn_exp);

                     IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                        fa_debug_pkg.ADD('faxcde', 'perd_bonus_deprn_amount(new)', perd_bonus_deprn_amount);
                     END IF;
                  END IF;

               -- Bug 5657699: Added following else part
               ELSE
                  perd_deprn_exp := 0;
                  perd_bonus_deprn_amount := 0;

               END IF; -- Bug 5657699

            END IF; -- (deprn_override_flag <> fa_std_types.FA_NO_OVERRIDE) then
            -- End of override depreciation logic

            --
            -- If the remaining depreciation is small (absolutely OR
            -- relatively), then fully depreciate the asset
            --
            -- Calculate the absolute value of the asset's new NBV
            -- Use adj_rec_cost as base instead of dpr.rec_cost
            --
            nbv_absval := ABS(adj_rec_cost -
                              (cur_deprn_rsv + NVL(year_deprn_exp,0) + perd_deprn_exp));

            -- bonus? Shouldn't really have to bother about bonus nbv, as long as regular deprn figures
            --    contain bonus figures. skipping.

            --
            -- Debug
            --
            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde', 'fadpdp(7): adj_rec_cost', adj_rec_cost);
               fa_debug_pkg.ADD('faxcde', 'cur_deprn_rsv', cur_deprn_rsv, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'year_deprn_exp', year_deprn_exp, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'perd_deprn_exp', perd_deprn_exp, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'nbv_absval', nbv_absval, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'nbv_frac_thresh', nbv_frac_thresh, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'nbv_amt_thresh', nbv_amt_thresh, p_log_level_rec => p_log_level_rec);
            END IF;


            --
            -- Get the absolute value of the asset's Adjusted
            -- Recoverable Cost, do not use Recoverable Cost
            --
            adj_rec_cost_absval := ABS (adj_rec_cost);

            --
            -- Check the NBV against the constant value, and then
            -- against the fraction of the Adjusted Recoverable Cost
            --
            IF deprn_override_flag = fa_std_types.FA_NO_OVERRIDE THEN
               IF (nbv_absval < nbv_amt_thresh) OR
                  (nbv_absval <  nbv_frac_thresh * adj_rec_cost_absval)  THEN
                  last_period_deprn_exp := adj_rec_cost - (cur_deprn_rsv + NVL(year_deprn_exp,0));

                  --
                  -- recalculate annual deprn amount if asset will became
                  -- fully reserved in the last period of fiscal year
                  --
                  IF (nbv_deprn_basis_flag AND (deprn_end_perd = perds_per_yr_dcal)) THEN
                     IF perd_deprn_exp < last_period_deprn_exp THEN

                        --
                        -- use ann_fy_deprn to avoid rounding twice
                        -- on annual depreciation amount
                        --
                        actual_annual_deprn_amt := ann_fy_deprn + (last_period_deprn_exp - perd_deprn_exp);

                        -- bonus: how prorate to bonus?
                        --     maybe don't need assign any value to bonus. See hld regardin last period deprn.
                        --     maybe we need actual_annual_bonus_deprn_amt variable in addition to bonus_ann_fy_deprn.
                        --     We probably don't need to assign actual_annual_bonus_deprn_amt ? Investigate.
                        --     actual_annual_bonus_deprn_amt := 0;
                        h_dummy_bool := fa_utils_pkg.faxtru(actual_annual_deprn_amt, dpr.book, dpr.set_of_books_id, p_log_level_rec => p_log_level_rec);

                     END IF;

                  END IF; -- (nbv_deprn_basis_flag and (deprn_end_perd = perds_per_yr_dcal)) then

               END IF; -- (nbv_absval < nbv_amt_thresh) or

            END IF; -- deprn_override_flag = fa_std_types.FA_NO_OVERRIDE then

         ELSE
            perd_deprn_exp := 0;
            perd_bonus_deprn_amount := 0;
            perd_prod := 0;
         END IF; -- if ((perd_ctr >= actual_deprn_start_perd) and

         --
         -- if excl_sal_val_flag='YES' then add salvage_value
         -- back to rec_cost_absval, and if it is less than rsv_absval then
         -- mark this asset as life complete
         --
         IF (nbv_deprn_basis_flag AND excl_sal_val_flag) THEN
            rec_cost_absval := ABS(dpr.rec_cost + dpr.salvage_value);
         ELSE
            rec_cost_absval := ABS(dpr.rec_cost);
         END IF;

         rec_cost_absval := ABS(dpr.rec_cost);
         adj_rec_cost_absval := ABS(adj_rec_cost);

         -- Bug4037112:
         -- Need to prepare local variables include reserve adjustment amounts
         -- If the period has reset_adjusted_cost_flag, then current reserve
         -- has already include the adjustment and for other period, it needs
         -- accumulated reserve adjsutment amount to verify whether the asset
         -- is fully reserved or not.
         --
         IF ((l_ind <> 0) AND
             (fa_amort_pvt.t_reset_adjusted_cost_flag(l_ind) = 'Y')) THEN
            l_accum_rsv_adj := 0;
            l_rsv_adj := 0;
         ELSIF ((l_ind <> 0) AND
                (fa_amort_pvt.t_reset_adjusted_cost_flag(l_ind) = 'N')) THEN
            l_accum_rsv_adj := NVL(l_accum_rsv_adj, 0) +
                               fa_amort_pvt.t_reserve_adjustment_amount(l_ind);
            l_rsv_adj := l_accum_rsv_adj;
         ELSE
            l_rsv_adj := 0;
         END IF;

         --
         -- If this is called for maintaining  FA_BOOKS_SUMAMRY table,
         -- consider reserve_adjustment_amount when calculating absolute
         -- value of reserve
         --
         IF (l_ind <> 0) AND
            (fa_amort_pvt.t_reset_adjusted_cost_flag(l_ind) = 'N') THEN

            rsv_absval := ABS (cur_deprn_rsv + year_deprn_exp +
                               perd_deprn_exp + l_rsv_adj);
         ELSE
            rsv_absval := ABS (cur_deprn_rsv + year_deprn_exp +perd_deprn_exp);
         END IF;

         -- bonus?
         --
         -- if asset's depreciation reserve  is greater than it's
         -- recoverable cost, set life completed flag
         --
         IF (rec_cost_absval <= rsv_absval) THEN
            dpr_out.life_comp_flag := TRUE;
         ELSE
            -- Reserve is now less than rec cost.  Unset fully reserved flag
            -- and life complete flag.
            -- This is to restart calculating expense again
            dpr_out.full_rsv_flag := FALSE;
            dpr_out.life_comp_flag :=FALSE;
         END IF;

         -- Fix for Bug #2833307.  Add the following logic for over
         -- depreciate option:
         --
         -- FA_OVER_DEPR_NULL : No change in deprn logic
         -- FA_OVER_DEPR_NO   : No change in deprn logic
         -- FA_OVER_DEPR_YES  : If reserve is already exceeds
         --                     adj_rec_cost, do nothing and mark the
         --                     asset fully reserved.  If not, calculate
         --                     periodic depreciation.  If it results in
         --                     rsv exceeding adj_rec_cost, do nothing
         --                     but mark the asset as fully reserved.
         -- FA_OVER_DEPR_DEPRN: Asset will never stop depreciation
         --                     unless all member asset has been fully
         --                     retired, or depreciate flag is unchecked.
         --
         -- NOTE: All life base methods will not value other than
         --       FA_OVER_DEPR_NULL or FA_OVER_DEPR_NO.
         IF (dpr.over_depreciate_option = fa_std_types.FA_OVER_DEPR_YES) THEN

            -- BUg3315683:
            -- Group could have situation whether rsv_absval is greater than adj_rec_cost_absval
            -- but still not fully reserved because rsv is -ve and adj_rec_cost is +ve.
            --if (adj_rec_cost_absval < rsv_absval) then
            IF ((adj_rec_cost > 0) AND
                (adj_rec_cost < (cur_deprn_rsv + NVL(year_deprn_exp,0) +perd_deprn_exp+l_rsv_adj))) OR
               ((adj_rec_cost < 0)  AND (adj_rec_cost_absval < rsv_absval)) THEN

               -- Bug4037112: Need to add accumulated reserve adjustment in order to identify
               -- whether the group asset is fully reserved or not because cur_deprn_rsv does not
               -- include the amount.
               IF (l_ind <> 0) THEN
                  IF((adj_rec_cost > 0) AND
                            (adj_rec_cost < (cur_deprn_rsv +
                                             NVL(year_deprn_exp,0) +
                                             perd_deprn_exp+l_rsv_adj))) OR
                           ((adj_rec_cost < 0)  AND (adj_rec_cost_absval < rsv_absval)) THEN

                     dpr_out.full_rsv_flag := TRUE;

                     IF NOT dpr_out.life_comp_flag THEN
                               dpr_out.life_comp_flag := TRUE;
                     END IF;

                  ELSE
                     -- Reserve is now less than rec cost.  Unset fully reserved flag
                     -- and life complete flag.
                     -- This is to restart calculating expense again
                     dpr_out.full_rsv_flag := FALSE;
                     dpr_out.life_comp_flag :=FALSE;
                  END IF;
               ELSE
                  dpr_out.full_rsv_flag := TRUE;

                  IF NOT dpr_out.life_comp_flag THEN
                     dpr_out.life_comp_flag := TRUE;
                  END IF;
               END IF;

            ELSE

               -- Reserve is now less than rec cost.  Unset fully reserved flag
               -- and life complete flag.
               -- This is to restart calculating expense again
               dpr_out.full_rsv_flag := FALSE;
               dpr_out.life_comp_flag :=FALSE;

            END IF;

         ELSIF (dpr.over_depreciate_option = fa_std_types.FA_OVER_DEPR_DEPRN) THEN
            -- continue depreciating
            NULL;
         ELSE

            -- Bug fix 5893429
            IF dpr.cost_frac IS NOT NULL THEN
               l_adjusted_rsv_absval := ((rsv_absval - NVL(perd_deprn_exp,0) - NVL(year_deprn_exp,0))
                                        * (1 - dpr.cost_frac))
                                        + NVL(perd_deprn_exp,0) + NVL(year_deprn_exp,0);

               IF NOT fa_utils_pkg.faxrnd(l_adjusted_rsv_absval, dpr.book, dpr.set_of_books_id, p_log_level_rec) THEN
                  fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde',  p_log_level_rec => p_log_level_rec);
                  RETURN (FALSE);
               END IF;

               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde', 'dpr.cost_frac', dpr.cost_frac, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'rsv_absval', rsv_absval, p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'before rounding: l_adjusted_rsv_absval', l_adjusted_rsv_absval, p_log_level_rec);
               END IF;

            ELSE
               l_adjusted_rsv_absval := rsv_absval;
            END IF;

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde', 'l_adjusted_rsv_absval', l_adjusted_rsv_absval, p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'adj_rec_cost_absval', adj_rec_cost_absval, p_log_level_rec);
            END IF;
            -- End bug fix 5893429
            --
            -- if asset's deprn reserve is greater than adjusted revoverable
            -- cost, set fully reserve flag.
            -- For assets which do not have deprn limit, recoverable cost is
            -- always equal to adjusted recoverable cost
            --
            IF adj_rec_cost_absval <= l_adjusted_rsv_absval THEN      -- Bug fix 5893429 (replaced rsv_absval with l_adjusted_rsv_absval)

               IF (deprn_override_flag <> fa_std_types.FA_NO_OVERRIDE) AND
                  (adj_rec_cost_absval < rsv_absval) AND
                  NOT (deprn_projecting_flag) THEN

                  fa_srvr_msg.add_message(calling_fn => 'fa_cde_pkg.faxcde',
                                          name => 'FA_OVER_DEPRN_LIMIT',
                                          TRANSLATE=> FALSE,  p_log_level_rec => p_log_level_rec);
                  dpr_out.deprn_override_flag:= fa_std_types.FA_NO_OVERRIDE;
                  RETURN(FALSE);
               END IF;

               dpr_out.full_rsv_flag := TRUE;

               --
               -- Always set life complete once asset is fully reserved.
               -- This handles the case where the adjusted recoverable
               -- cost is less than recoverable cost
               --
               IF NOT dpr_out.life_comp_flag THEN
                  dpr_out.life_comp_flag := TRUE;
               END IF;
            ELSE
               -- Reserve is now less than rec cost.  Unset fully reserved flag
               -- and life complete flag.
               -- This is to restart calculating expense again
               dpr_out.full_rsv_flag := FALSE;
               dpr_out.life_comp_flag :=FALSE;
            END IF; -- adj_rec_cost_absval <= rsv_absval then

         END IF; -- (dpr.over_depreciate_option = fa_std_types.FA_OVER_DEPR_YES) then

         --
         -- If the Depreciate_Flag is 'NO', then don't depreciate
         --
         IF NOT dpr_cur_fy_flag THEN

            IF deprn_override_flag <> fa_std_types.FA_NO_OVERRIDE THEN

               fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faxcde',
                                       name            => 'FA_NO_DEPRECIATION',
                                       TRANSLATE       => FALSE,
                                       p_log_level_rec => p_log_level_rec);
               dpr_out.deprn_override_flag:= fa_std_types.FA_NO_OVERRIDE;
               RETURN(FALSE);
            ELSE
               perd_deprn_exp := 0;
               perd_bonus_deprn_amount := 0;
            END IF;

         END IF; -- not dpr_cur_fy_flag then

         --
         -- For projection/what-if
         -- Set fully reserved flag if asset hits the end of life
         --
         IF (deprn_projecting_flag) AND
            (fyctr = fy_fully_rsv) AND
            (perd_ctr = actual_deprn_end_perd) THEN
            dpr_out.full_rsv_flag := TRUE;
         END IF;

         -- Added the Below code to take care of the Bug# 7277598
         -- Below code calculates the  Prorata Depreciable amount , if the asset is added with JP-250DB XX and NBV_AT_SWITCH in the Middle of FY
         IF l_request_short_name = 'FAWDPR' then
            IF (NVL(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, 'NO') = 'YES')  THEN  --- Checking for Methods JP-250DB XX
              IF l_count = l_number_of_periods then
                 dpr_out.full_rsv_flag := TRUE;
                 dpr_out.life_comp_flag := TRUE;
              END IF;
            END IF;
         END IF;
         -- End of Addition BUG# 7277598

         IF dpr_out.full_rsv_flag THEN

            IF deprn_override_flag = fa_std_types.FA_NO_OVERRIDE THEN

               IF (dpr.over_depreciate_option = fa_std_types.FA_OVER_DEPR_YES) THEN

                  IF (SIGN(adj_rec_cost) < 0 AND
                      (adj_rec_cost > (cur_deprn_rsv + NVL(year_deprn_exp,0)+ l_rsv_adj))) OR
                     (SIGN(cur_deprn_rsv + NVL(year_deprn_exp,0)+ l_rsv_adj) > 0 AND
                      (adj_rec_cost < (cur_deprn_rsv + NVL(year_deprn_exp,0)+ l_rsv_adj))) THEN
                     perd_deprn_exp := 0;
                  ELSE
                     perd_deprn_exp := adj_rec_cost - (cur_deprn_rsv + NVL(year_deprn_exp,0)+ l_rsv_adj);
                  END IF;

               ELSIF (dpr.over_depreciate_option = fa_std_types.FA_OVER_DEPR_DEPRN) THEN
                  NULL;
               ELSE
                  IF (SIGN(adj_rec_cost) < 0 AND
                      (adj_rec_cost > (cur_deprn_rsv + NVL(year_deprn_exp,0)+ l_rsv_adj))) OR
                     (SIGN(cur_deprn_rsv + NVL(year_deprn_exp,0)+ l_rsv_adj) > 0 AND
                      (adj_rec_cost < (cur_deprn_rsv + NVL(year_deprn_exp,0)+ l_rsv_adj))) THEN

                     -- Bug 8231467. The adj_rec_cost is new amount. Bur cur_deprn_rsv is still based on
                     --  old adj_rec_cost. So we need to find out adj_deprn_rsv which is the reserve based
                     --  on new adj_rec_cost. Let asset Cost:12000, STL:1 Year. Cur Period: Jan-01.
                     --  By Oct-01, The reserve is 10000. The asset is fully reserved in Dec. Asset partialy
                     --  retired(2000) with Oct-01 date. Now adj_rec_cost = 10000 and cur_deprn_rsv = 10000
                     --  at this point of code. Exp_Oct = 833, Exp_Nov = 833. Year_expense = 1666. If you
                     --  calculate with existing formula it gives (10000-(10000+1666)+0) = -1666. This should
                     --  not be Exp_Dec. Rather than subtracting cur_deprn_rsv, we need to subtract the
                     --  relative reserve based on cur_adj_rec_cost.

                     Begin
                        SELECT fab1.adjusted_recoverable_cost
                        INTO   l_old_adj_rec_cost
                        FROM   fa_books fab1,fa_books fab2
                        WHERE  fab1.transaction_header_id_out = fab2.transaction_header_id_in
                        AND    fab1.asset_id = fab2.asset_id
                        AND    fab1.book_type_code = fab2.book_type_code
                        AND    fab2.asset_id = dpr.asset_id
                        AND    fab2.book_type_code = dpr.book --Bug 8475228
                        AND    fab2.transaction_header_id_out IS NULL;
                     Exception
                        When no_data_found Then
                           null;
                     End;

                     --Fix for bug 9360599
                     IF (l_old_adj_rec_cost <> 0) THEN
                         l_adj_deprn_rsv := (cur_deprn_rsv/l_old_adj_rec_cost) * adj_rec_cost;
                         perd_deprn_exp := adj_rec_cost - (l_adj_deprn_rsv + NVL(year_deprn_exp,0)+ l_rsv_adj);
							ELSE
							    l_adj_deprn_rsv := 0;
                         perd_deprn_exp := 0;
							END IF;
							--End of fix for bug 9360599

							--perd_deprn_exp := 0;
                  ELSE
                      perd_deprn_exp := adj_rec_cost - (cur_deprn_rsv + NVL(year_deprn_exp,0)+ l_rsv_adj);
                  END IF;

               END IF;

               -- bonus?
               -- According to hld, no bonus deprn amount should be charged in last period of life.
               -- Effects should be tested.
               perd_bonus_deprn_amount := 0;

            END IF; -- deprn_override_flag = fa_std_types.FA_NO_OVERRIDE then

            IF prod_rate_src_flag THEN
               --
               -- Reset to FALSE for Production-Based assets, because
               -- they never become marked as fully-reserved
               --
               dpr_out.full_rsv_flag := FALSE;
            END IF;

         END IF; -- dpr_out.full_rsv_flag then

         -- Added for Track Member Assets:
         --
         -- Round amount calculated
         --
         h_dummy_bool := fa_utils_pkg.faxrnd (perd_deprn_exp, dpr.book, dpr.set_of_books_id, p_log_level_rec => p_log_level_rec);
         -- bonus
         IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
            h_dummy_bool := fa_utils_pkg.faxrnd (perd_bonus_deprn_amount, dpr.book, dpr.set_of_books_id, p_log_level_rec => p_log_level_rec);
         END IF;

         IF NVL(dpr.tracking_method,'OTHER') = 'ALLOCATE' AND
            NVL(dpr_in.deprn_override_flag, fa_std_types.FA_NO_OVERRIDE)
                                       <> fa_std_types.FA_OVERRIDE_RECURSIVE THEN

            -- Check if subtract ytd flag is enabled or not
            IF NVL(p_subtract_ytd_flag,'N') = 'Y' THEN

               IF (fyctr = dpr.y_begin) THEN
                  p_deprn_amount := dpr_in.ytd_deprn + perd_deprn_exp;

                  IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                     p_bonus_amount := dpr.bonus_ytd_deprn + perd_bonus_deprn_amount;
                  END IF;

               ELSE
                  p_deprn_amount := NVL(year_deprn_exp,0) + perd_deprn_exp;

                  IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                     p_bonus_amount := year_bonus_deprn_amount + perd_bonus_deprn_amount;
                  END IF;

               END IF;

            ELSE
               p_deprn_amount := perd_deprn_exp;

               IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
                  p_bonus_amount := perd_bonus_deprn_amount;
               END IF;

            END IF; -- nvl(p_subtract_ytd_flag,'N') = 'Y' then

            -- Set Mode following used_by_adjustment flag
            IF dpr.used_by_adjustment = TRUE THEN
               h_mode := 'ADJUSTMENT';
            ELSE
               h_mode := NULL;
            END IF;

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde', 'fadpdp(8*********): perd_deprn_exp', perd_deprn_exp);
               fa_debug_pkg.ADD('faxcde', 'perd_bonus_deprn_amount', perd_bonus_deprn_amount, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'year_deprn_exp', year_deprn_exp, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'adj_rec_cost', adj_rec_cost, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'perd_prod', perd_prod, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD('faxcde', 'year_prod', year_prod, p_log_level_rec => p_log_level_rec);
            END IF;

            -- Call FATRKM to call track member function
            IF NOT FATRKM (p_dpr => dpr,
                           p_perd_deprn_exp => p_deprn_amount,
                           p_perd_bonus_deprn_amount => p_bonus_amount,
                           p_perd_ctr => perd_ctr,
                           p_fyctr => fyctr,
                           p_loop_end_year => dpr.y_end,
                           p_loop_end_period => dpr.p_cl_end,
                           p_exclude_salvage_value_flag => excl_sal_val_flag,
                           p_deprn_basis_rule => deprn_basis_rule,
                           p_deprn_override_flag => deprn_override_flag,
                           p_subtract_ytd_flag => p_subtract_ytd_flag,
                           p_life_complete_flag => dpr_out.life_comp_flag,
                           p_fully_reserved_flag => dpr_out.full_rsv_flag,
                           p_year_deprn_exp => year_deprn_exp,
                           p_recoverable_cost => dpr.rec_cost,
                           p_adj_rec_cost => adj_rec_cost,
                           p_current_deprn_reserve => cur_deprn_rsv,
                           p_nbv_threshold => nbv_frac_thresh,
                           p_nbv_thresh_amount => nbv_amt_thresh,
                           p_rec_cost_abs_value => rec_cost_absval,
                           p_mode => h_mode,
                           x_new_perd_exp => x_new_perd_exp,
                           x_new_perd_bonus_deprn_amount => x_new_perd_bonus_deprn_amount,
                           x_life_complete_flag => x_life_complete_flag,
                           x_fully_reserved_flag => x_fully_reserved_flag,
                           p_log_level_rec       => p_log_level_rec) THEN
               RETURN(FALSE);
            ELSE
               perd_deprn_exp := x_new_perd_exp;
               perd_bonus_deprn_amount := x_new_perd_bonus_deprn_amount;
               dpr_out.life_comp_flag := x_life_complete_flag;
               dpr_out.full_rsv_flag := x_fully_reserved_flag;
               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.ADD('faxcde', 'fadpdp(9*********): perd_deprn_exp', perd_deprn_exp);
                  fa_debug_pkg.ADD('faxcde', 'perd_bonus_deprn_amount', perd_bonus_deprn_amount, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'year_deprn_exp', year_deprn_exp, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'adj_rec_cost', adj_rec_cost, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'dpr_out.life_comp_flag', dpr_out.life_comp_flag, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.ADD('faxcde', 'dpr_out.full_rsv_flag', dpr_out.full_rsv_flag, p_log_level_rec => p_log_level_rec);
               END IF;
            END IF; -- not FATRKM (p_dpr => dpr,

         END IF; -- Tracking_Method = 'ALLOCATE'?

         year_deprn_exp := NVL(year_deprn_exp,0) + perd_deprn_exp;
         ytd_deprn_sum := ytd_deprn_sum + perd_deprn_exp;
         year_prod := year_prod + perd_prod ;

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcde', 'fadpdp(8888*********): perd_deprn_exp', perd_deprn_exp);
            fa_debug_pkg.ADD('faxcde', 'perd_bonus_deprn_amount', perd_bonus_deprn_amount, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD('faxcde', 'year_deprn_exp', year_deprn_exp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD('faxcde', 'adj_rec_cost', adj_rec_cost, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD('faxcde', 'perd_prod', perd_prod, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD('faxcde', 'year_prod', year_prod, p_log_level_rec => p_log_level_rec);
         END IF;
         -- bonus: investigate how perd_bonus_deprn_amount can be calculated earlier
         IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
            year_bonus_deprn_amount := year_bonus_deprn_amount + perd_bonus_deprn_amount;
            ytd_bonus_deprn_sum := ytd_bonus_deprn_sum + perd_bonus_deprn_amount;
         END IF;

         --
         -- Debug
         --
         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcde', 'fadpdp(8): perd_deprn_exp', perd_deprn_exp);
            fa_debug_pkg.ADD('faxcde', 'perd_bonus_deprn_amount', perd_bonus_deprn_amount, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD('faxcde', 'year_deprn_exp', year_deprn_exp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD('faxcde', 'adj_rec_cost', adj_rec_cost, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD('faxcde', 'perd_prod', perd_prod, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD('faxcde', 'year_prod', year_prod, p_log_level_rec => p_log_level_rec);
         END IF;

         -- bonus: perd_bonus_deprn_amount will now go into dpr_arr struct.
         --       bonus_value added to dpr_arr.
         dpr_arr(dpr_arr_ctr).value := perd_deprn_exp;
         dpr_arr(dpr_arr_ctr).bonus_value := perd_bonus_deprn_amount;
         dpr_arr(dpr_arr_ctr).period_num := perd_ctr;
         dpr_arr(dpr_arr_ctr).fiscal_year := fyctr;

         -- Manual Override
         IF deprn_override_flag <> fa_std_types.FA_NO_OVERRIDE AND NOT (deprn_projecting_flag) THEN
            dpr_out.deprn_override_flag:= deprn_override_flag;
         END IF;
         -- End of Manual Override

         ----------------------------------------------
         -- Call Depreciable Basis Rule
         -- for depreciation
         ----------------------------------------------
         IF perd_ctr = perds_per_yr_dcal THEN
            h_eofy_flag :='Y';
         ELSE
            h_eofy_flag :='N';
         END IF;

         -- Set deprn reserve for depreciable basis rule function
         cdb_deprn_rsv := NVL(cur_deprn_rsv,0)+ NVL(year_deprn_exp,0);
         cdb_bonus_deprn_rsv := NVL(cur_bonus_deprn_rsv,0) +
                                NVL(year_bonus_deprn_amount,0);

         --
         -- if excl_sal_val_flag='YES' then
         -- reduce salvage_value from adjusted cost
         --
         IF (nbv_deprn_basis_flag AND excl_sal_val_flag) THEN
            cur_adj_cost := cur_adj_cost - dpr.salvage_value;
         END IF;

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcde','deprn_period_dcal_begin' , deprn_period_dcal_begin, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD('faxcde','perd_ctr' , perd_ctr, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD('faxcde','cdb_deprn_rsv111111111' , cdb_deprn_rsv, p_log_level_rec => p_log_level_rec);
         END IF;

         -- call deprn basis rule logic.
         -- if perd_deprn_exp <> 0 then

         IF (fyctr = deprn_year_dcal_begin AND perd_ctr >= deprn_period_dcal_begin) OR
            fyctr > deprn_year_dcal_begin THEN

            -- BUG# 3769466
            -- avoid deprn basis call when not needed

            --Bug#8230037 - Addition condition on deprn_basis_rule_id to check for non zero value.
            --            - as cache is returning zero if deprn_basis_rule_id is null
            IF (nbv_deprn_basis_flag OR
                (fa_cache_pkg.fazccmt_record.deprn_basis_rule_id IS NOT NULL AND
                 fa_cache_pkg.fazccmt_record.deprn_basis_rule_id <> 0 AND
                 NOT (rate_source_rule = 'CALCULATED' AND
                      cost_deprn_basis_flag AND
                      NVL(fa_cache_pkg.fazcdrd_record.period_update_flag,'N') ='N' AND
                      NVL(p_subtract_ytd_flag,'N') = 'N' AND
                      NVL(fa_cache_pkg.fazcdrd_record.use_eofy_reserve_flag, 'N') = 'N'))) THEN

               -- Japan Tax Reform Project
               IF NVL(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag, 'NO') = 'YES' THEN

                  IF (p_log_level_rec.statement_level) THEN
                     fa_debug_pkg.ADD('faxcde', '+++ JAPAN ', 'in guarantee rate call deprn basis', p_log_level_rec => p_log_level_rec);
                  END IF;

                  h_adjusted_cost := NVL(cur_adj_cost,0);

               ELSE
                  h_adjusted_cost := NULL;
               END IF;
               -- Japan Tax Reform Project End

               IF (NOT FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS (
                         p_event_type             => 'AFTER_DEPRN',
                         p_dpr                    => dpr,
                         p_fiscal_year            => fyctr,
                         p_period_num             => perd_ctr,
                         p_period_counter         => fyctr*perds_per_yr_dcal+perd_ctr,
                         p_adjusted_cost          => h_adjusted_cost,   -- Japan Tax Reforms Project
                         p_current_total_rsv      => cdb_deprn_rsv,
                         p_current_rsv            => cdb_deprn_rsv
                                                       - NVL(cdb_bonus_deprn_rsv,0),
                         p_current_total_ytd      => ytd_deprn_sum,
                         p_eofy_reserve           => cur_eofy_reserve,
                         p_used_by_adjustment     => h_mode,
                         p_eofy_flag              => h_eofy_flag,
                         px_new_adjusted_cost     => cur_adj_cost,
                         px_new_raf               => dpr.rate_adj_factor,
                         px_new_formula_factor    => dpr.formula_factor,
                         x_annual_deprn_rounding_flag => dpr.deprn_rounding_flag,
                         p_log_level_rec       => p_log_level_rec)) THEN
                    fa_srvr_msg.add_message (calling_fn => 'fa_cde_pkg.faxcde',  p_log_level_rec => p_log_level_rec);
                  RETURN (FALSE);
               END IF;
            ELSE
               IF (p_log_level_rec.statement_level) THEN
                  fa_debug_pkg.add ('faxcde', 'skipping', 'deprn basis call', p_log_level_rec);
               END IF;
            END IF;
         END IF; -- (fyctr = deprn_year_dcal_begin and

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcde','l_dpr_in.deprn_rounding_flag(after CALL_DEPRN_BASIS)',
                             dpr.deprn_rounding_flag, p_log_level_rec);
         END IF;

         --
         -- if excl_sal_val_flag='YES' then
         -- add salvage_value back to adjusted cost
         --
         IF (nbv_deprn_basis_flag AND excl_sal_val_flag) THEN
            cur_adj_cost := cur_adj_cost + dpr.salvage_value;
         END IF;

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcde','l_dpr_in.deprn_rounding_flag(after CALL_DEPRN_BASIS)',
                             cur_adj_cost, p_log_level_rec);
            fa_debug_pkg.ADD('faxcde','l_dpr_in.deprn_rounding_flag(after CALL_DEPRN_BASIS)',
                             dpr.salvage_value, p_log_level_rec);
         END IF;

         dpr_arr_ctr := dpr_arr_ctr + 1;

         IF (l_ind <> 0) THEN
            --
            -- Maintain Books Summary Table
            --
            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD('faxcde','Maintain Books Summary Table',
                                TO_CHAR(l_ind)||':'||TO_CHAR(fa_amort_pvt.t_deprn_amount.COUNT));
            END IF;

            IF (l_ind <= fa_amort_pvt.t_deprn_amount.COUNT) THEN

               IF (nbv_deprn_basis_flag AND excl_sal_val_flag) THEN
                  fa_amort_pvt.t_adjusted_cost(l_ind + 1) := cur_adj_cost - dpr.salvage_value;
               ELSE
                  fa_amort_pvt.t_adjusted_cost(l_ind + 1) := cur_adj_cost;
               END IF;

               fa_amort_pvt.t_adjusted_capacity(l_ind + 1) := dpr.adj_capacity; --Bug7487450

               fa_amort_pvt.t_formula_factor(l_ind + 1) := dpr.formula_factor;
               fa_amort_pvt.t_deprn_amount(l_ind) :=
                                               perd_deprn_exp +
                                               fa_amort_pvt.t_expense_adjustment_amount(l_ind);
               fa_amort_pvt.t_bonus_deprn_amount(l_ind) := perd_bonus_deprn_amount;
               fa_amort_pvt.t_production(l_ind) := nvl(perd_prod, 0); --Bug7487450

               IF (l_ind = 1) THEN
                  fa_amort_pvt.t_deprn_reserve(l_ind) :=
                                       fa_amort_pvt.t_deprn_amount(l_ind) +
                                       fa_amort_pvt.t_reserve_adjustment_amount(l_ind);
                  fa_amort_pvt.t_bonus_deprn_reserve(l_ind) := perd_bonus_deprn_amount;
                  fa_amort_pvt.t_impairment_reserve(l_ind) :=
                                       fa_amort_pvt.t_impairment_amount(l_ind);
                  fa_amort_pvt.t_ltd_production(l_ind) := fa_amort_pvt.t_production(l_ind); --Bug7487450
               ELSE
                  fa_amort_pvt.t_deprn_reserve(l_ind) :=
                                       fa_amort_pvt.t_deprn_reserve(l_ind - 1) +
                                       fa_amort_pvt.t_deprn_amount(l_ind) +
                                       fa_amort_pvt.t_reserve_adjustment_amount(l_ind);
                  fa_amort_pvt.t_bonus_deprn_reserve(l_ind) :=
                             fa_amort_pvt.t_bonus_deprn_reserve(l_ind- 1) +
                             perd_bonus_deprn_amount;
                  fa_amort_pvt.t_impairment_reserve(l_ind) :=
                                       fa_amort_pvt.t_impairment_reserve(l_ind - 1) +
                                       fa_amort_pvt.t_impairment_amount(l_ind);
                  fa_amort_pvt.t_ltd_production(l_ind) := fa_amort_pvt.t_ltd_production(l_ind - 1 ) +
                                                          fa_amort_pvt.t_production(l_ind); --Bug7487450
               END IF;

               IF dpr.bonus_rule IS NULL THEN
                  fa_amort_pvt.t_bonus_rate(l_ind) := NULL;
               ELSE
                  fa_amort_pvt.t_bonus_rate(l_ind) := dpr_out.bonus_rate_used;
               END IF;

               IF (fa_amort_pvt.t_period_num(l_ind) = 1) THEN
                  fa_amort_pvt.t_ytd_deprn(l_ind) := fa_amort_pvt.t_deprn_amount(l_ind);
                  fa_amort_pvt.t_bonus_ytd_deprn(l_ind) := perd_bonus_deprn_amount;
                  fa_amort_pvt.t_ytd_impairment(l_ind) :=
                                                 fa_amort_pvt.t_impairment_amount(l_ind);
                  fa_amort_pvt.t_ytd_production(l_ind) := fa_amort_pvt.t_production(l_ind); --Bug7487450

                  IF (l_ind = 1) THEN
                     fa_amort_pvt.t_eofy_reserve(l_ind) := 0;
                     fa_amort_pvt.t_eofy_adj_cost(l_ind) := 0;
                     fa_amort_pvt.t_eofy_formula_factor(l_ind) := 1;
                  ELSE
                     fa_amort_pvt.t_eofy_reserve(l_ind) :=
                                              fa_amort_pvt.t_deprn_reserve(l_ind - 1);
                     fa_amort_pvt.t_eofy_adj_cost(l_ind) :=
                                              fa_amort_pvt.t_adjusted_cost(l_ind - 1);
                     fa_amort_pvt.t_eofy_formula_factor(l_ind) :=
                                              fa_amort_pvt.t_formula_factor(l_ind - 1);
                  END IF;

               ELSE

                  IF (l_ind = 1) THEN
                     fa_amort_pvt.t_ytd_deprn(l_ind) := fa_amort_pvt.t_deprn_amount(l_ind);
                     fa_amort_pvt.t_bonus_ytd_deprn(l_ind) := perd_bonus_deprn_amount;
                     fa_amort_pvt.t_eofy_reserve(l_ind) := 0;
                     fa_amort_pvt.t_eofy_adj_cost(l_ind) := 0;
                     fa_amort_pvt.t_eofy_formula_factor(l_ind) := 1;
                     fa_amort_pvt.t_ytd_impairment(l_ind) :=
                                                 fa_amort_pvt.t_impairment_amount(l_ind);
                     fa_amort_pvt.t_ytd_production(l_ind) := fa_amort_pvt.t_production(l_ind); --Bug7487450
                  ELSE
                     fa_amort_pvt.t_ytd_deprn(l_ind) :=
                                    fa_amort_pvt.t_ytd_deprn(l_ind - 1) +
                                    fa_amort_pvt.t_deprn_amount(l_ind);
                     fa_amort_pvt.t_bonus_ytd_deprn(l_ind) :=
                                    fa_amort_pvt.t_bonus_ytd_deprn(l_ind - 1) +
                                    perd_bonus_deprn_amount;
                     fa_amort_pvt.t_eofy_reserve(l_ind) :=
                                    fa_amort_pvt.t_eofy_reserve(l_ind - 1);
                     fa_amort_pvt.t_eofy_adj_cost(l_ind) :=
                                    fa_amort_pvt.t_eofy_adj_cost(l_ind - 1);
                     fa_amort_pvt.t_eofy_formula_factor(l_ind) :=
                                    fa_amort_pvt.t_eofy_formula_factor(l_ind - 1);
                     fa_amort_pvt.t_ytd_impairment(l_ind) :=
                                    fa_amort_pvt.t_ytd_impairment(l_ind - 1) +
                                    fa_amort_pvt.t_impairment_amount(l_ind);
                     fa_amort_pvt.t_ytd_production(l_ind) :=
                                    fa_amort_pvt.t_ytd_production(l_ind - 1) +
                                    fa_amort_pvt.t_production(l_ind); --Bug7487450
                  END IF;

               END IF; -- (fa_amort_pvt.t_period_num(l_ind) = 1) then

               IF (l_ind = 1) THEN
                  fa_amort_pvt.t_eop_adj_cost(l_ind) := 0;
               ELSE
                  fa_amort_pvt.t_eop_adj_cost(l_ind) :=
                                    fa_amort_pvt.t_adjusted_cost(l_ind - 1);
               END IF;

               fa_amort_pvt.t_eop_formula_factor(l_ind) :=
                                 fa_amort_pvt.t_formula_factor(l_ind);

               dpr_out.new_impairment_rsv := fa_amort_pvt.t_impairment_reserve(l_ind);

               IF (p_log_level_rec.statement_level) THEN
                         fa_debug_pkg.ADD('faxcde','period_counter', fa_amort_pvt.t_period_counter(l_ind));
                         fa_debug_pkg.ADD('faxcde','deprn_amount', fa_amort_pvt.t_deprn_amount(l_ind));
                         fa_debug_pkg.ADD('faxcde','ytd_deprn', fa_amort_pvt.t_ytd_deprn(l_ind));
                         fa_debug_pkg.ADD('faxcde','deprn_reserve', fa_amort_pvt.t_deprn_reserve(l_ind));
                         fa_debug_pkg.ADD('faxcde','bonus_deprn_amount', fa_amort_pvt.t_bonus_deprn_amount(l_ind));
                         fa_debug_pkg.ADD('faxcde','bonus_ytd_deprn', fa_amort_pvt.t_bonus_ytd_deprn(l_ind));
                         fa_debug_pkg.ADD('faxcde','bonus_deprn_reserve', fa_amort_pvt.t_bonus_deprn_reserve(l_ind));
                         fa_debug_pkg.ADD('faxcde','eofy_reserve', fa_amort_pvt.t_eofy_reserve(l_ind));
                         fa_debug_pkg.ADD('faxcde','eofy_adj_cost', fa_amort_pvt.t_eofy_adj_cost(l_ind));
                         fa_debug_pkg.ADD('faxcde','eofy_formula_factor', fa_amort_pvt.t_eofy_formula_factor(l_ind));
                         fa_debug_pkg.ADD('faxcde','eop_adj_cost', fa_amort_pvt.t_eop_adj_cost(l_ind));
                         fa_debug_pkg.ADD('faxcde','eop_formula_factor', fa_amort_pvt.t_eop_formula_factor(l_ind));
                         fa_debug_pkg.ADD('faxcde','imp_rsv', fa_amort_pvt.t_impairment_reserve(l_ind));
                         fa_debug_pkg.ADD('faxcde','adjusted_capacity', fa_amort_pvt.t_adjusted_capacity(l_ind));
                         fa_debug_pkg.ADD('faxcde','production', fa_amort_pvt.t_production(l_ind));
                         fa_debug_pkg.ADD('faxcde','ytd_production', fa_amort_pvt.t_ytd_production(l_ind));
                         fa_debug_pkg.ADD('faxcde','ltd_production', fa_amort_pvt.t_ltd_production(l_ind));
               END IF;


               --
               -- Revaluation related amounts needs to be corrected
               -- fa_amort_pvt.t_reval_amortization(l_ind) :=
               -- fa_amort_pvt.t_ytd_reval_deprn_expense(l_ind) :=
               -- fa_amort_pvt.t_reval_reserve(l_ind) :=
               -- fa_amort_pvt.t_remaining_life1(l_ind) :=
               -- fa_amort_pvt.t_remaining_life2(l_ind) :=

               l_ind := l_ind + 1;
            END IF; -- (l_ind <= fa_amort_pvt.t_deprn_amount.COUNT) then

         END IF; -- (l_ind <> 0))

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD(l_calling_fn, 'p_ind', p_ind, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD(l_calling_fn, 'dpr_out.full_rsv_flag', dpr_out.full_rsv_flag, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD(l_calling_fn, 'adj_rec_cost', adj_rec_cost, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD(l_calling_fn, 'cur_deprn_rsv', cur_deprn_rsv, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD(l_calling_fn, 'year_deprn_exp', year_deprn_exp, p_log_level_rec => p_log_level_rec);
         END IF;

         --
         -- Stop and exit period loop if
         -- 1. This is not group related trx
         -- 2. method is NBV base
         -- 3. reserve will be equal to limit
         -- 4. reserve before deprn is more than the limit
         -- 5. This is not projection.
         --
         IF (p_ind = 0) AND
            (nbv_deprn_basis_flag) AND
            (dpr_out.full_rsv_flag) AND
            (adj_rec_cost = (cur_deprn_rsv + NVL(year_deprn_exp,0))) AND
            ((adj_rec_cost > 0 AND adj_rec_cost <= cur_deprn_rsv) OR
             (adj_rec_cost < 0 AND adj_rec_cost >= cur_deprn_rsv)) AND
            (NOT(deprn_projecting_flag)) THEN

            IF (p_log_level_rec.statement_level) THEN
               fa_debug_pkg.ADD(l_calling_fn, 'Exiting PERIOD LOOP', '.', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD(l_calling_fn, 'Fully reserved during recalculation',
                             TO_CHAR(adj_rec_cost)||':'||TO_CHAR(cur_deprn_rsv + year_deprn_exp));
            END IF;

            EXIT;

         END IF; -- (p_ind = 0) and

      END LOOP;  -- End of period loop

      --
      -- Round amount calculated
      h_dummy_bool := fa_utils_pkg.faxrnd (year_deprn_exp, dpr.book, dpr.set_of_books_id, p_log_level_rec => p_log_level_rec);

      -- bonus
      IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
         h_dummy_bool := fa_utils_pkg.faxrnd (year_bonus_deprn_amount, dpr.book, dpr.set_of_books_id, p_log_level_rec => p_log_level_rec);
      END IF;

      IF  cur_adj_cost = 0 THEN
         rab_rc_ratio := 0;
      ELSE
         rab_rc_ratio := cur_reval_amo_basis / cur_adj_cost;
      END IF;

      year_reval_exp := NVL(year_deprn_exp,0) * rab_rc_ratio;
      h_dummy_bool := fa_utils_pkg.faxrnd (year_reval_exp, dpr.book, dpr.set_of_books_id, p_log_level_rec => p_log_level_rec);

      IF (amo_reval_rsv_flag) THEN
         year_reval_amo := year_reval_exp;
      ELSE
         year_reval_amo := 0;
      END IF;
      deprn_exp_sum := deprn_exp_sum + NVL(year_deprn_exp,0);
      cur_deprn_rsv := cur_deprn_rsv + NVL(year_deprn_exp,0);

      -- bonus
      IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
         bonus_deprn_exp_sum := bonus_deprn_exp_sum + year_bonus_deprn_amount;
         cur_bonus_deprn_rsv := cur_bonus_deprn_rsv + year_bonus_deprn_amount;
      END IF;

      reval_exp_sum := reval_exp_sum + year_reval_exp;
      reval_amo_sum := reval_amo_sum + year_reval_amo;
      cur_reval_rsv := cur_reval_rsv - year_reval_amo;
      prod_sum      := prod_sum + year_prod;
      cur_ltd_prod  := cur_ltd_prod + year_prod;

      --
      -- Debug
      --
      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.ADD('faxcde', 'fadpdp(9): deprn_exp_sum', deprn_exp_sum, p_log_level_rec);
         fa_debug_pkg.ADD('faxcde', 'cur_deprn_rsv', cur_deprn_rsv, p_log_level_rec);
         fa_debug_pkg.ADD('faxcde', 'reval_exp_sum', reval_exp_sum, p_log_level_rec);
         fa_debug_pkg.ADD('faxcde', 'reval_amo_sum', reval_amo_sum, p_log_level_rec);
         fa_debug_pkg.ADD('faxcde', 'cur_reval_rsv', cur_reval_rsv, p_log_level_rec);
         fa_debug_pkg.ADD('faxcde', 'prod_sum', prod_sum, p_log_level_rec);
         fa_debug_pkg.ADD('faxcde', 'cur_ltd_prod', cur_ltd_prod, p_log_level_rec);
         fa_debug_pkg.ADD('faxcde', 'year_deprn_exp', year_deprn_exp, p_log_level_rec);
         fa_debug_pkg.ADD('faxcde', 'ytd_deprn_sum', ytd_deprn_sum, p_log_level_rec);
      END IF;

      IF (deprn_end_perd = perds_per_yr_dcal) THEN

         -- bonus? We need to investigate how to treat prior_bonus_fy_exp_sum
         --
         -- prior_fy_exp_sum needs to include dpr.ytd_deprn to make sure
         -- subtraction method to work correctly for subsequent years
         --
         IF (fyctr = dpr.y_begin) THEN
            prior_fy_exp_sum := prior_fy_exp_sum + NVL(year_deprn_exp,0) + dpr.ytd_deprn;
            prior_fy_bonus_exp_sum := prior_fy_bonus_exp_sum + year_bonus_deprn_amount + dpr.bonus_ytd_deprn;
         ELSE
            prior_fy_exp_sum := prior_fy_exp_sum + NVL(year_deprn_exp,0);
            prior_fy_bonus_exp_sum := prior_fy_bonus_exp_sum + year_bonus_deprn_amount;
         END IF;

      END IF; -- (deprn_end_perd = perds_per_yr_dcal) then

      --
      -- If necessary, recompute the current adjusted cost based on
      -- the new depreciation reserve
      -- Also, recompute the current revaluation amortization basis
      -- to be the new revaluation reserve
      --
      IF nbv_deprn_basis_flag AND  deprn_end_perd = perds_per_yr_dcal THEN
         --
         -- Instead of using adj_rec_cost, still use rec_cost to
         -- calculate asset's nbv after normal life completed
         --
         cur_reval_amo_basis := cur_reval_rsv;

         --
         -- Debug
         --
         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcde', 'cur_reval_amo_basis', cur_reval_amo_basis, p_log_level_rec => p_log_level_rec);
         END IF;

      END IF; -- nbv_deprn_basis_flag and  deprn_end_perd = perds_per_yr_dcal then

      --
      -- Populate YTD deprn as of end of calculation.
      --
      IF (fyctr = dpr.y_begin) THEN
         dpr_out.new_ytd_deprn := dpr_out.new_ytd_deprn + NVL(year_deprn_exp,0);
      ELSE
         dpr_out.new_ytd_deprn := NVL(year_deprn_exp,0);
      END IF;

      --
      -- For second year during catchup, rounding flag should be set
      -- to null.
      dpr.deprn_rounding_flag := NULL;

      -- Set eofy amount
      IF deprn_end_perd = perds_per_yr_dcal THEN
         cur_eofy_reserve := cur_deprn_rsv;
      END IF;

      --
      -- Stop and exit period loop if
      -- 1. This is not group related trx
      -- 2. method is NBV base
      -- 3. reserve is equal to limit
      -- 4. reserve before deprn is more than the limit
      -- 5. This is not projection.
      --
      IF (p_ind = 0) AND
         (nbv_deprn_basis_flag) AND
         (dpr_out.full_rsv_flag) AND
         (adj_rec_cost = (cur_deprn_rsv)) AND
         ((adj_rec_cost > 0 AND adj_rec_cost <= cur_deprn_rsv - NVL(year_deprn_exp,0))  OR
          (adj_rec_cost < 0 AND adj_rec_cost >= cur_deprn_rsv - NVL(year_deprn_exp,0)))  AND
         (NOT(deprn_projecting_flag)) THEN
         fa_debug_pkg.ADD(l_calling_fn, 'EXITING YEAR LOOP', '.', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD(l_calling_fn, 'Fully reserved during recalculation',
                          TO_CHAR(adj_rec_cost)||':'||TO_CHAR(cur_deprn_rsv + year_deprn_exp));
         cur_adj_cost := 0;
         EXIT;
      END IF;

   END LOOP; -- End fiscal year loop --

   --
   -- We increment fy by 1 to emulate the C lang for loop behavior
   -- where the loop counter is incremented before the loop condition
   -- is tested. PL/SQL doesnt.
   --
   fy_ctr := fy_ctr + 1;

   -- bug 894937 and 1330860
   -- '+' changed to '-'
   IF (nbv_deprn_basis_flag AND excl_sal_val_flag) THEN
      cur_adj_cost := cur_adj_cost - dpr.salvage_value;
   END IF;

   --
   -- Bug4037112: Need to return reserve that includes
   --             Reserve adjustments amount which can only
   --             find in fa_amort_pvt pl/sql table.
   --
   IF (l_ind<>0) AND
      (l_ind <= fa_amort_pvt.t_deprn_amount.COUNT) THEN
      dpr_out.new_deprn_rsv := fa_amort_pvt.t_deprn_reserve(l_ind-1)+
                               fa_amort_pvt.t_reserve_adjustment_amount(l_ind) +
                               fa_amort_pvt.t_expense_adjustment_amount(l_ind);
   ELSE
      dpr_out.new_deprn_rsv := cur_deprn_rsv;
   END IF;

   IF NVL(dpr.bonus_rule, 'NONE') <> 'NONE' THEN
      dpr_out.new_bonus_deprn_rsv := cur_bonus_deprn_rsv;
   ELSE
      dpr_out.new_bonus_deprn_rsv := 0;
   END IF;

   dpr_out.new_adj_cost := cur_adj_cost;
   dpr_out.new_reval_rsv := cur_reval_rsv;
   dpr_out.new_reval_amo_basis := cur_reval_amo_basis;
   dpr_out.new_ltd_prod := cur_ltd_prod;
   dpr_out.deprn_exp := deprn_exp_sum;
   -- bonus? necessary? if so we need to add to dpr_out_struct.
   -- dpr_out.bonus_deprn_amount := bonus_deprn_exp_sum;
   dpr_out.bonus_deprn_exp := bonus_deprn_exp_sum; -- YYOON
   dpr_out.reval_exp := reval_exp_sum;
   dpr_out.reval_amo := reval_amo_sum;
   dpr_out.prod := prod_sum;
   dpr_out.ann_adj_reval_exp := dpr_out.ann_adj_exp * rab_rc_ratio;
   h_dummy_bool := fa_utils_pkg.faxrnd(dpr_out.ann_adj_reval_exp, dpr.book, dpr.set_of_books_id, p_log_level_rec);
   dpr_out.new_eofy_reserve := cur_eofy_reserve;

   IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.ADD('faxcde', 'dpr_out.deprn_override_flag',dpr_out.deprn_override_flag, p_log_level_rec);
   END IF;

   IF (amo_reval_rsv_flag) THEN
      dpr_out.ann_adj_reval_amo := dpr_out.ann_adj_reval_exp;
   ELSE
      dpr_out.ann_adj_reval_amo := 0;
   END IF;

   -- old bonus code, where is -1 evaluated.
   -- Maybe: if prod_rate_src_flag or nvl(dpr.bonus_rule, 'NONE') = 'NONE' then
   IF NVL(dpr.bonus_rule, 'NONE') = 'NONE' THEN
      dpr_out.bonus_rate_used := -1;
   END IF;

   -- if the period is the last period of current the fiscal year, or
   -- the year is greater than current fiscal year then reset deprn
   -- expense of all prior fiscal years to 0, otherwise increase
   -- prior_fy_exp by sum of deprn expense for all prior fiscal years
   -- of requested periods
   --
   IF (fy_ctr - 1 <= cur_fy) THEN

      IF (deprn_end_perd = perds_per_yr_dcal AND fy_ctr = cur_fy) THEN
         dpr_out.new_prior_fy_exp := 0;
         dpr_out.new_prior_fy_bonus_exp := 0;
      ELSE
         dpr_out.new_prior_fy_exp := prior_fy_exp_sum + dpr.prior_fy_exp;
         dpr_out.new_prior_fy_bonus_exp := prior_fy_bonus_exp_sum + dpr.prior_fy_bonus_exp;
      END IF;

   ELSE
      dpr_out.new_prior_fy_exp := 0;
      dpr_out.new_prior_fy_bonus_exp := 0;
   END IF;

   --
   -- Debug
   --
   IF (p_log_level_rec.statement_level) THEN
      h_dummy_bool := fa_cde_pkg.faprdos(dpr_out, p_log_level_rec => p_log_level_rec);
   END IF;

   RETURN (TRUE);

EXCEPTION
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error (calling_fn => 'fa_cde_pkg.faxcde',  p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);

END FAXCDE;

FUNCTION faprds
        (
        X_dpr IN fa_std_types.dpr_struct
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS
BEGIN <<FAPRDS>>

   fa_debug_pkg.ADD('faxcde','Contents of dpr_struct for asset_id',X_dpr.asset_id, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','asset_num',X_dpr.asset_num, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','book',X_dpr.book, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','calendar_type',X_dpr.calendar_type, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','ceil_name',X_dpr.ceil_name, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','bonus_rule',X_dpr.bonus_rule, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','method_code',X_dpr.method_code, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','adj_cost',X_dpr.adj_cost, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','rec_cost',X_dpr.rec_cost, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','reval_amo_basis',X_dpr.reval_amo_basis, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','deprn_rsv',X_dpr.deprn_rsv, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','reval_rsv',X_dpr.reval_rsv, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','adj_rate',X_dpr.adj_rate, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','rate_adj_factor',X_dpr.rate_adj_factor, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','capacity',X_dpr.capacity, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','adj_capacity',X_dpr.adj_capacity, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','ltd_prod',X_dpr.ltd_prod, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','adj_rec_cost',X_dpr.adj_rec_cost, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','salvage_value',X_dpr.salvage_value, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','prior_fy_exp',X_dpr.prior_fy_exp, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','ytd_deprn',X_dpr.ytd_deprn, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','asset_id',X_dpr.asset_id, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','jdate_in_service',X_dpr.jdate_in_service, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','prorate_jdate',X_dpr.prorate_jdate, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','deprn_start_jdate',X_dpr.deprn_start_jdate, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','jdate_retired',X_dpr.jdate_retired, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','ret_prorate_jdate',X_dpr.ret_prorate_jdate, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','life',X_dpr.life, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','COST111111',X_dpr.cost, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','prorate_year_pcal_begin',X_dpr.y_begin, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','y_end',X_dpr.y_end, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','p_cl_begin',X_dpr.p_cl_begin, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','p_cl_end',X_dpr.p_cl_end, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','pc_life_end',X_dpr.pc_life_end, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','mrc_sob_type_code',X_dpr.mrc_sob_type_code, p_log_level_rec =>
   p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','set_of_books_id',X_dpr.set_of_books_id, p_log_level_rec =>
   p_log_level_rec);


   IF (X_dpr.rsv_known_flag) THEN
      fa_debug_pkg.ADD('faxcde','rsv_known_flag','TRUE', p_log_level_rec => p_log_level_rec);
   ELSE
      fa_debug_pkg.ADD('faxcde','rsv_known_flag','FALSE', p_log_level_rec => p_log_level_rec);
   END IF;

   fa_debug_pkg.ADD('faxcde','deprn_rounding_flag',X_dpr.deprn_rounding_flag, p_log_level_rec => p_log_level_rec);

   RETURN (TRUE);

EXCEPTION
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error (calling_fn => 'fa_cde_pkg.faprds',  p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);

END FAPRDS;

FUNCTION faprdos (X_dpr           IN fa_std_types.dpr_out_struct,
                  p_log_level_rec IN FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

BEGIN <<FAPRDOS>>

   fa_debug_pkg.ADD('faxcde','new_deprn_rsv',X_dpr.new_deprn_rsv, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','new_ytd_deprn',X_dpr.new_ytd_deprn, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','new_adj_cost',X_dpr.new_adj_cost, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','new_reval_rsv',X_dpr.new_reval_rsv, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','new_reval_amo_basis',X_dpr.new_reval_amo_basis, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','new_adj_capacity',X_dpr.new_adj_capacity, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','new_ltd_prod',X_dpr.new_ltd_prod, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','deprn_exp',X_dpr.deprn_exp, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','reval_exp',X_dpr.reval_exp, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','reval_amo',X_dpr.reval_amo, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','prod',X_dpr.prod, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','ann_adj_exp',X_dpr.ann_adj_exp, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','ann_adj_reval_exp',X_dpr.ann_adj_reval_exp, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','ann_adj_reval_amo',X_dpr.ann_adj_reval_amo, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.ADD('faxcde','bonus_rate_used',X_dpr.bonus_rate_used, p_log_level_rec => p_log_level_rec);

   IF (X_dpr.full_rsv_flag) THEN
      fa_debug_pkg.ADD('faxcde','full_rsv_flag','TRUE', p_log_level_rec => p_log_level_rec);
   ELSE
      fa_debug_pkg.ADD('faxcde','full_rsv_flag','FALSE', p_log_level_rec => p_log_level_rec);
   END IF;

   IF (X_dpr.life_comp_flag) THEN
      fa_debug_pkg.ADD('faxcde','life_comp_flag','TRUE', p_log_level_rec => p_log_level_rec);
   ELSE
      fa_debug_pkg.ADD('faxcde','life_comp_flag','FALSE', p_log_level_rec => p_log_level_rec);
   END IF;

   fa_debug_pkg.ADD('faxcde','new_prior_fy_exp',X_dpr.new_prior_fy_exp, p_log_level_rec => p_log_level_rec);

   RETURN (TRUE);

EXCEPTION
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error (calling_fn => 'fa_cde_pkg.faprdos',  p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
END FAPRDOS;

FUNCTION fadgpoar RETURN INTEGER IS

  -- value VARCHAR2(40);

BEGIN <<FADGPOAR>>

  IF (NOT g_tested_use_annual_round) THEN
     -- fnd_profile.get('FA_ANNUAL_ROUND', value);
     IF fa_cache_pkg.fa_annual_round = 'ALWAYS' THEN
        g_use_annual_round := ROUND_ALWAYS;
     ELSE
        g_use_annual_round := ROUND_WITH_RESTRICTIONS;
     END IF;

     g_tested_use_annual_round := TRUE;
  END IF;

  RETURN g_use_annual_round;

EXCEPTION
   WHEN OTHERS THEN
      RETURN (g_use_annual_round);
END FADGPOAR;


FUNCTION faodda(book                      IN            VARCHAR2,
                used_by_adjustment        IN            BOOLEAN,
                asset_id                  IN            NUMBER,
                bonus_rule                IN            VARCHAR2,
                fyctr                     IN            NUMBER,
                perd_ctr                  IN            NUMBER,
                prod_rate_src_flag        IN            BOOLEAN,
                deprn_projecting_flag     IN            BOOLEAN,
                p_ytd_deprn               IN            NUMBER,
                p_bonus_ytd_deprn         IN            NUMBER,
                override_depr_amt            OUT NOCOPY NUMBER,
                override_bonus_amt           OUT NOCOPY NUMBER,
                deprn_override_flag          OUT NOCOPY VARCHAR2,
                return_code                  OUT NOCOPY NUMBER,
                p_mrc_sob_type_code       IN            VARCHAR2,
                p_set_of_books_id         IN            NUMBER,
                p_recoverable_cost        IN            NUMBER,
                p_salvage_value           IN            NUMBER,
                p_update_override_status  IN            BOOLEAN,
                p_over_depreciate_option  IN            NUMBER   DEFAULT NULL, --Bug 8487934
                p_asset_type              IN            VARCHAR2 DEFAULT NULL, --Bug 8487934
                p_deprn_rsv               IN            NUMBER   DEFAULT NULL, --Bug 8487934
                p_cur_adj_cost            IN            NUMBER   DEFAULT NULL, --Bug 8487934
                p_override_period_counter IN            NUMBER   DEFAULT NULL,-- Bug 8211842
                p_log_level_rec           IN            FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   h_calendar_type        VARCHAR2(15);
   h_fy_name              VARCHAR2(30);
   subtract_ytd_flag      VARCHAR2(1);
   h_num_per_fy           NUMBER(5);
   h_set_of_books_id      NUMBER;
   h_prim_set_of_books_id NUMBER;
   h_reporting_flag       VARCHAR2(1);
   h_asset_id             NUMBER(15);
   h_deprn_override_id    NUMBER(15);
   h_success              BOOLEAN;
   deprn_summary          fa_std_types.fa_deprn_row_struct;
   perd_name              VARCHAR2(15);
   report_cost            NUMBER;
   l_exchange_rate        NUMBER;
   l_avg_rate             NUMBER;
   l_period_counter       NUMBER; -- Bug 8211842
   l_posted_deprn         BOOLEAN := FALSE; -- Bug 8211842
   l_calling_fn           VARCHAR2(40) := 'fa_cde_pkg.faodda';

   faodda_err             EXCEPTION;
   faodda_err2            EXCEPTION; /*Bug#7953789 */

BEGIN <<FAODDA>>

   return_code:= 11;

   IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.ADD('faodda', 'book_type_code', book, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'asset_id', asset_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'used_by_adjustment', used_by_adjustment, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'p_update_override_status', p_update_override_status, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'p_mrc_sob_type_code', p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec);

   END IF;


   -- Modified for MRC
   -- couldn't get set_of_books_id correctly,
   -- so added p_mrc_sob_type_code to paramter
   IF p_mrc_sob_type_code = 'R' THEN
      h_set_of_books_id := p_set_of_books_id;
      h_reporting_flag := p_mrc_sob_type_code;
   ELSE
      h_set_of_books_id := p_set_of_books_id;
      h_reporting_flag := p_mrc_sob_type_code;
   END IF;

   IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.ADD('faodda', 'set_of_books_id', h_set_of_books_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'reporting_flag', h_reporting_flag, p_log_level_rec => p_log_level_rec);
   END IF;

   return_code:=12;

   -- select the corresponding period_counter for the current period: fyctr, perd_ctr
   -- Get calendar Info: type, fy_name and num_per_fiscal_year
   h_calendar_type:= fa_cache_pkg.fazcbc_record.deprn_calendar;
   h_fy_name:= fa_cache_pkg.fazcbc_record.fiscal_year_name;
   h_num_per_fy:= fa_cache_pkg.fazcct_record.number_per_fiscal_year;

   return_code:= 13;


   -- FIGURE OUT THE PERIOD_NAME for the current fyctr and perd_ctr
   IF perd_ctr <> NVL(g_pre_period_ctr, 0) OR fyctr <> NVL(g_pre_fyctr,0) THEN

      -- Bug 8211842: Fetch period counter also
      SELECT cp.period_name,
             fy.fiscal_year * h_num_per_fy + cp.period_num
      INTO   perd_name,
             l_period_counter
      FROM fa_calendar_periods cp, fa_fiscal_year fy
      WHERE cp.calendar_type = h_calendar_type AND
            cp.period_num = perd_ctr AND
            cp.start_date >= fy.start_date AND
            cp.end_date <= fy.end_date AND
            fy.fiscal_year_name = h_fy_name AND
            fy.fiscal_year = fyctr;

      g_pre_period_name:= perd_name;
      g_pre_period_ctr:= perd_ctr;
      g_pre_fyctr:= fyctr;
   ELSE
      perd_name := g_pre_period_name;
   END IF;

   h_asset_id:= asset_id;

   IF (p_log_level_rec.statement_level) THEN
     fa_debug_pkg.ADD('faodda', 'period_name', perd_name, p_log_level_rec => p_log_level_rec);
   END IF;


   -- Bug 8211842: If p_override_period_counter is populated,
   -- Look for posted depreciation overrides for periods before
   -- p_override_period_counter
   if (p_override_period_counter is not null) and
      (l_period_counter < p_override_period_counter) then

      SELECT deprn_amount, bonus_deprn_amount, subtract_ytd_flag, deprn_override_id
      INTO   override_depr_amt, override_bonus_amt, subtract_ytd_flag, h_deprn_override_id
      FROM   FA_DEPRN_OVERRIDE
      WHERE  book_type_code = book
      AND    asset_id = h_asset_id
      AND    period_name = perd_name
      AND    used_by = 'DEPRECIATION'
      AND    status = 'POSTED';

      l_posted_deprn := TRUE;

   elsif used_by_adjustment = TRUE THEN
      SELECT deprn_amount
           , bonus_deprn_amount
           , subtract_ytd_flag
           , deprn_override_id
      INTO   override_depr_amt
           , override_bonus_amt
           , subtract_ytd_flag
           , h_deprn_override_id
      FROM   FA_DEPRN_OVERRIDE
      WHERE  book_type_code = book
      AND    asset_id = h_asset_id
      AND    period_name = perd_name
      AND    used_by = 'ADJUSTMENT'
      AND    status = 'POST';
   ELSE
      SELECT deprn_amount
           , bonus_deprn_amount
           , subtract_ytd_flag
           , deprn_override_id
      INTO   override_depr_amt
           , override_bonus_amt
           , subtract_ytd_flag
           , h_deprn_override_id
      FROM   FA_DEPRN_OVERRIDE
      WHERE  book_type_code = book
      AND    asset_id = h_asset_id
      AND    period_name = perd_name
      AND    used_by = 'DEPRECIATION'
      AND    status = 'POST';
   END IF;


   IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.ADD('faodda', 'primary override_depr_amt', override_depr_amt, p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'primary override_bonus_amt', override_bonus_amt, p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'deprn_projecting_flag', deprn_projecting_flag, p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'p_ytd_deprn', p_ytd_deprn, p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'p_bonus_ytd_deprn', p_bonus_ytd_deprn, p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'p_recoverable_cost', p_recoverable_cost, p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'p_salvage_value', p_salvage_value, p_log_level_rec);
   END IF;

   -- Bug#-8527619 - start
   if (p_over_depreciate_option = 1 or p_over_depreciate_option = 0) and
      used_by_adjustment = FALSE and
      nvl(p_cur_adj_cost,0) = 0 and
      nvl(override_depr_amt,0) <> 0  then --fully reserved

      override_depr_amt :=null;
      return_code:= 2;
      raise faodda_err2;

   end if;
   --Bug#-8527619 - end

   -- Data Validation for manual override feature
   IF (NVL(bonus_rule,'NONE') = 'NONE' AND override_bonus_amt IS NOT NULL) THEN
      -- need to raise an error even for projection because projection needs to output the bonus account on the report.
      fa_srvr_msg.add_message(calling_fn      => 'fa_cde_pkg.faodda',
                              name            => 'FA_NO_BONUS_RULE',
                              TRANSLATE       => FALSE,
                              p_log_level_rec => p_log_level_rec);
      return_code:= 3;
      RAISE faodda_err;
   END IF;

   IF used_by_adjustment = TRUE THEN

      IF (h_reporting_flag <> 'R') THEN
         primary_cost:= p_recoverable_cost + p_salvage_value;
      ELSE
         report_cost:= p_recoverable_cost + p_salvage_value;
      END IF;

      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.ADD('faodda', 'primary_cost', primary_cost, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD('faodda', 'report_cost', report_cost, p_log_level_rec => p_log_level_rec);
      END IF;

      -- ratio = Reporting Books Cost / Primary books Cost for adjustment.
      --         the above calculation can be used once the depreciaion
      --         program was built in one-step.
      --       = use latest average rate for depreciation until one-step depreciation is built.

      l_avg_rate:= report_cost / primary_cost;

      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.ADD('faodda', 'l_avg_rate', l_avg_rate, p_log_level_rec => p_log_level_rec);
      END IF;

   ELSE  -- Depreciation Run
      IF (h_reporting_flag = 'R') THEN
         SELECT bk.cost
         INTO   report_cost
         FROM   fa_mc_books bk
         WHERE  bk.book_type_code = book
         AND    bk.asset_id = h_asset_id
         AND    bk.transaction_header_id_out IS NULL
         AND    bk.set_of_books_id = p_set_of_books_id;

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faodda', 'report_cost', report_cost, p_log_level_rec => p_log_level_rec);
         END IF;

         SELECT bk.cost
         INTO   primary_cost
         FROM   fa_books  bk
         WHERE  bk.book_type_code = book
         AND    bk.asset_id = h_asset_id
         AND    bk.transaction_header_id_out IS NULL;

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faxcde', 'faodda:primary_cost', primary_cost, p_log_level_rec => p_log_level_rec);
         END IF;

         l_avg_rate:= report_cost / primary_cost;

         IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.ADD('faodda', 'l_avg_rate', l_avg_rate, p_log_level_rec => p_log_level_rec);
         END IF;
      END IF;
   END IF;

   IF override_depr_amt IS NOT NULL THEN

      deprn_override_flag:= fa_std_types.FA_OVERRIDE_DPR;
      deprn_override_flag:= fa_std_types.FA_OVERRIDE_DPR;

      IF (h_reporting_flag = 'R') THEN
          override_depr_amt:= override_depr_amt * l_avg_rate;
      END IF;

      IF override_bonus_amt IS NOT NULL AND NOT(prod_rate_src_flag) THEN

         deprn_override_flag:= fa_std_types.FA_OVERRIDE_DPR_BONUS;

         IF (h_reporting_flag = 'R') THEN
           override_bonus_amt:= override_bonus_amt * l_avg_rate;
         END IF;

      END IF;

   ELSIF override_bonus_amt IS NOT NULL AND NOT(prod_rate_src_flag) THEN

      deprn_override_flag:= fa_std_types.FA_OVERRIDE_BONUS;

      IF (h_reporting_flag = 'R') THEN
         override_bonus_amt:= override_bonus_amt * l_avg_rate;
      END IF;

   ELSE
      deprn_override_flag:= fa_std_types.FA_NO_OVERRIDE;
   END IF;

   IF deprn_override_flag <> fa_std_types.FA_NO_OVERRIDE AND
      NOT (deprn_projecting_flag) AND
      h_reporting_flag = 'P' THEN

      -- Bug 8211842: Update the status only if it is not
      -- posted depreciation overrrides
      if not l_posted_deprn then

         fa_std_types.deprn_override_trigger_enabled:= FALSE;

         IF used_by_adjustment = FALSE THEN
            UPDATE fa_deprn_override
            SET    status = 'POSTED'
            WHERE  deprn_override_id = h_deprn_override_id;

         ELSIF p_update_override_status THEN
            UPDATE fa_deprn_override
            SET    status = 'SELECTED'
            WHERE  deprn_override_id = h_deprn_override_id;

         END IF;

         fa_std_types.deprn_override_trigger_enabled:= TRUE;

      end if;

   END IF;

   return_code:= 4;

   --  When user provided YTD amount
   IF NVL(subtract_ytd_flag,'N') = 'Y' THEN
      override_depr_amt := override_depr_amt - (p_ytd_deprn - p_bonus_ytd_deprn);
      override_bonus_amt := override_bonus_amt - p_bonus_ytd_deprn;
   END IF;

   IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.ADD('faodda', 'override_depr_amt', override_depr_amt, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'override_bonus_amt', override_bonus_amt, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD('faodda', 'deprn_override_flag', deprn_override_flag, p_log_level_rec => p_log_level_rec);
   END IF;

  RETURN(TRUE);

EXCEPTION
   --Bug#7953789 - start
   WHEN faodda_err2 THEN
      return(TRUE);
   --Bug#7953789  - end

   WHEN faodda_err THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      RETURN(FALSE);

   WHEN NO_DATA_FOUND THEN
      deprn_override_flag:= fa_std_types.FA_NO_OVERRIDE;
      return_code:= 5;
      RETURN(TRUE);

   WHEN OTHERS THEN
      deprn_override_flag:= fa_std_types.FA_NO_OVERRIDE;
      return_code:= 6;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      RETURN(TRUE);

END FAODDA;

------------------------------------------------------------------
-- Function:
--           FATRKM
--
-- Description:
--           Main entry to call Tracking feature
--           This function will call TRACK_MEMBER function
--
------------------------------------------------------------------
FUNCTION fatrkm(p_dpr                     IN fa_std_types.dpr_struct,
                p_perd_deprn_exp          IN NUMBER,
                p_perd_bonus_deprn_amount IN NUMBER,
                p_perd_ctr                IN NUMBER,
                p_fyctr                   IN NUMBER,
                p_loop_end_year           IN NUMBER,
                p_loop_end_period         IN NUMBER,
                p_exclude_salvage_value_flag IN BOOLEAN,
                p_deprn_basis_rule        IN VARCHAR2,
                p_deprn_override_flag     IN OUT NOCOPY VARCHAR2,
                p_subtract_ytd_flag       IN VARCHAR2,
                p_life_complete_flag      IN BOOLEAN,
                p_fully_reserved_flag     IN BOOLEAN,
                p_year_deprn_exp          IN NUMBER,
                p_recoverable_cost        IN NUMBER,
                p_adj_rec_cost            IN NUMBER,
                p_current_deprn_reserve   IN NUMBER,
                p_nbv_threshold           IN NUMBER,
                p_nbv_thresh_amount       IN NUMBER,
                p_rec_cost_abs_value      IN NUMBER,
                p_mode                    IN VARCHAR2 DEFAULT NULL,
                x_new_perd_exp            OUT NOCOPY NUMBER,
                x_new_perd_bonus_deprn_amount OUT NOCOPY NUMBER,
                x_life_complete_flag      OUT NOCOPY BOOLEAN,
                x_fully_reserved_flag     OUT NOCOPY BOOLEAN,
                p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn          VARCHAR2(50) := 'fa_cde_pkg.fatrkm';
   --* Variables to call TRACK ASSETS
   h_book_type_code      VARCHAR2(30);
   h_group_asset_id      NUMBER(15);
   h_deprn_bonus_rule    VARCHAR2(15);
   h_exclude_salvage_value_flag VARCHAR2(1);
   h_tracking_method     VARCHAR2(15);
   h_alloc_fully_ret_flag VARCHAR2(1);
   h_alloc_fully_rsv_flag VARCHAR2(1);
   h_excess_alloc_option VARCHAR2(15);
   h_depreciation_option VARCHAR2(15);
   h_member_rollup_flag  VARCHAR2(1);
   h_group_override      VARCHAR2(1);

   h_new_deprn_amount    NUMBER;
   h_new_bonus_amount    NUMBER;

   h_life_complete_flag  VARCHAR2(1);
   h_fully_reserved_flag VARCHAR2(1);

   x_ret_code            NUMBER;

BEGIN <<FATRKM>>

   IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.ADD(l_calling_fn, 'fatrkm', 'Just Started', p_log_level_rec => p_log_level_rec);
   END IF;

   -- Set Data into variables to call TRACK_ASSETS

   h_book_type_code := p_dpr.book;
   h_group_asset_id := p_dpr.asset_id;
   h_deprn_bonus_rule := p_dpr.bonus_rule;

   IF (p_exclude_salvage_value_flag) THEN
     h_exclude_salvage_value_flag := 'Y';
   ELSE
     h_exclude_salvage_value_flag := 'N';
   END IF;

   h_tracking_method := p_dpr.tracking_method;
   h_alloc_fully_ret_flag := p_dpr.allocate_to_fully_ret_flag;
   h_alloc_fully_rsv_flag := p_dpr.allocate_to_fully_rsv_flag;
   h_excess_alloc_option := p_dpr.excess_allocation_option;
   h_depreciation_option := p_dpr.depreciation_option;
   h_member_rollup_flag := p_dpr.member_rollup_flag;

   IF p_deprn_override_flag <> fa_std_types.FA_NO_OVERRIDE THEN
     h_group_override := 'Y';
   ELSE
     h_group_override := 'N';
   END IF;

   IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.ADD(l_calling_fn, 'book_type_code ', h_book_type_code, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'group_asset_id ', h_group_asset_id, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'period_counter ', p_perd_ctr, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'fiscal_year ', p_fyctr, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'loop_end_year ', p_loop_end_year, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'loop_end_periods ', p_loop_end_period, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'exclude_salvage_value_flag ', h_exclude_salvage_value_flag, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'group_bonus_rule ', h_deprn_bonus_rule, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'group_deprn_amount ', p_perd_deprn_exp, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'group_bonus_amount ', p_perd_bonus_deprn_amount, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'tracking_method ', h_tracking_method, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'allocate_to_fully_ret_flag ', h_alloc_fully_ret_flag, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'allocate_to_fully_rsv_flag ', h_alloc_fully_rsv_flag, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'excess_allocation_option ', h_excess_alloc_option, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'depreciation_option ', h_depreciation_option, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'member_rollup_flag ', h_member_rollup_flag, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'group_override_flag ', h_group_override, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'subtract_ytd_flag ', p_subtract_ytd_flag, p_log_level_rec);
      fa_debug_pkg.ADD(l_calling_fn, 'mode ', p_mode, p_log_level_rec);
   END IF;

   x_ret_code :=  FA_TRACK_MEMBER_PVT.TRACK_ASSETS(
                                        P_book_type_code             => h_book_type_code,
                                        P_group_asset_id             => h_group_asset_id,
                                        P_period_counter             => p_perd_ctr,
                                        P_fiscal_year                => p_fyctr,
                                        P_loop_end_year              => p_loop_end_year,
                                        P_loop_end_period            => p_loop_end_period,
                                        P_group_deprn_basis          => p_deprn_basis_rule,
                                        P_group_exclude_salvage      => h_exclude_salvage_value_flag,
                                        P_group_bonus_rule           => h_deprn_bonus_rule,
                                        P_group_deprn_amount         => p_perd_deprn_exp,
                                        P_group_bonus_amount         => p_perd_bonus_deprn_amount,
                                        P_tracking_method            => h_tracking_method,
                                        P_allocate_to_fully_ret_flag => h_alloc_fully_ret_flag,
                                        P_allocate_to_fully_rsv_flag => h_alloc_fully_rsv_flag,
                                        P_excess_allocation_option   => h_excess_alloc_option,
                                        P_depreciation_option        => h_depreciation_option,
                                        P_member_rollup_flag         => h_member_rollup_flag,
                                        P_subtraction_flag           => p_subtract_ytd_flag,
                                        P_group_level_override       => h_group_override,
                                        P_mode                       => p_mode,
                                        P_mrc_sob_type_code          => p_dpr.mrc_sob_type_code,
                                        P_set_of_books_id            => p_dpr.set_of_books_id,
                                        X_new_deprn_amount           => h_new_deprn_amount,
                                        X_new_bonus_amount           => h_new_bonus_amount,
                                        p_log_level_rec              => p_log_level_rec);
   IF x_ret_code <> 0 THEN
      fa_srvr_msg.add_message (calling_fn => l_calling_fn,  p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);
   ELSE
      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.ADD(l_calling_fn, 'new_deprn_amount ', h_new_deprn_amount, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD(l_calling_fn, 'new_bonus_amount ', h_new_bonus_amount, p_log_level_rec => p_log_level_rec);
      END IF;

      p_deprn_override_flag := h_group_override;

      IF h_new_deprn_amount IS NULL THEN
         x_new_perd_exp := 0;
      END IF;

      IF h_new_bonus_amount IS NULL THEN
         x_new_perd_bonus_deprn_amount := 0;
      END IF;

      IF h_new_deprn_amount <= p_perd_deprn_exp THEN
         x_new_perd_exp := h_new_deprn_amount;
         x_new_perd_bonus_deprn_amount := h_new_bonus_amount;

         IF h_new_deprn_amount = p_perd_deprn_exp THEN
            x_life_complete_flag := p_life_complete_flag;
            x_fully_reserved_flag := p_fully_reserved_flag;
         ELSE
            x_life_complete_flag := FALSE;
            x_fully_reserved_flag := FALSE;
         END IF;
      ELSIF (p_life_complete_flag AND p_fully_reserved_flag) THEN

         -- Fix for Bug #6417506.  Need to comment the return false and
         -- pass back the values for life complete and fully rsvd flags.
         --return(FALSE);
         x_life_complete_flag := p_life_complete_flag;
         x_fully_reserved_flag := p_fully_reserved_flag;

      ELSE
         x_ret_code := 0;

         x_ret_code := FA_TRACK_MEMBER_PVT.CHECK_GROUP_AMOUNTS(
                                                   P_book_type_code        => h_book_type_code,
                                                   P_group_asset_id        => h_group_asset_id,
                                                   P_period_counter        => p_perd_ctr,
                                                   P_perd_deprn_exp        => h_new_deprn_amount,
                                                   P_year_deprn_exp        => p_year_deprn_exp,
                                                   P_recoverable_cost      => p_recoverable_cost,
                                                   P_adj_rec_cost          => p_adj_rec_cost,
                                                   P_current_deprn_reserve => p_current_deprn_reserve,
                                                   P_nbv_threshold         => p_nbv_threshold,
                                                   P_nbv_thresh_amount     => P_nbv_thresh_amount,
                                                   P_rec_cost_abs_value    => P_rec_cost_abs_value,
                                                   X_life_complete_flag    => h_life_complete_flag,
                                                   X_fully_reserved_flag   => h_fully_reserved_flag,
                                                   p_log_level_rec         => p_log_level_rec);
         IF x_ret_code <> 0 THEN
            fa_srvr_msg.add_message (calling_fn => l_calling_fn,  p_log_level_rec => p_log_level_rec);
            RETURN (FALSE);
         ELSE
            IF NVL(h_life_complete_flag,'N') = 'Y' THEN
               x_life_complete_flag := TRUE;
            ELSE
               x_life_complete_flag := FALSE;
            END IF;

            IF NVL(h_fully_reserved_flag,'N') = 'Y' THEN
               x_fully_reserved_flag := TRUE;
            ELSE
               x_fully_reserved_flag := FALSE;
            END IF;
            x_new_perd_exp := h_new_deprn_amount;
            x_new_perd_bonus_deprn_amount := h_new_bonus_amount;
         END IF;

      END IF;

   END IF;

   RETURN(TRUE);

EXCEPTION
   WHEN OTHERS THEN
      fa_srvr_msg.add_message (calling_fn => l_calling_fn,  p_log_level_rec => p_log_level_rec);
      RETURN(TRUE);

END FATRKM;

PROCEDURE faxgpolr (X_Book_Type_Code             IN            VARCHAR2,
                    X_Asset_Id                   IN            NUMBER,
                    X_Polish_Rule                IN            NUMBER,
                    X_Deprn_Factor               IN            NUMBER,
                    X_Alternate_Deprn_Factor     IN            NUMBER,
                    X_Polish_Adj_Calc_Basis_Flag IN            VARCHAR2,
                    X_Recoverable_Cost           IN            NUMBER,
                    X_Fiscal_Year                IN            NUMBER,
                    X_Current_Period             IN            NUMBER,
                    X_Periods_Per_Year           IN            NUMBER,
                    X_Year_Retired               IN            BOOLEAN,
                    X_Projecting_Flag            IN            BOOLEAN,
                    X_MRC_Sob_Type_Code          IN            VARCHAR2,
                    X_set_of_books_id            IN            NUMBER,
                    X_Rate                       IN OUT NOCOPY NUMBER,
                    X_Depreciate_Flag            IN OUT NOCOPY BOOLEAN,
                    X_Current_Adjusted_Cost      IN OUT NOCOPY NUMBER,
                    X_Adjusted_Recoverable_Cost  IN OUT NOCOPY NUMBER,
                    X_Success                       OUT NOCOPY INTEGER,
                    X_Calling_Fn                 IN            VARCHAR2,
                    p_log_level_rec              IN            FA_API_TYPES.log_level_rec_type)

IS

   l_calling_fn                    VARCHAR2(80);
   l_year_retired                  VARCHAR2(1);
   l_old_rate                      NUMBER;
   l_old_depreciate_flag           VARCHAR2(3);
   l_old_adjusted_cost             NUMBER;
   l_old_adjusted_rec_cost         NUMBER;
   l_new_rate                      NUMBER;
   l_new_depreciate_flag           VARCHAR2(3);
   l_new_adjusted_cost             NUMBER;
   l_new_adjusted_rec_cost         NUMBER;
   l_success                       NUMBER;

   faxgpolr_err                    EXCEPTION;

BEGIN

   l_old_rate := X_Rate;
   l_old_adjusted_cost := X_Current_Adjusted_Cost;
   l_old_adjusted_rec_cost := X_Adjusted_Recoverable_Cost;

   IF (X_Depreciate_Flag) THEN
      l_old_depreciate_flag := 'YES';
   ELSE
      l_old_depreciate_flag := 'NO';
   END IF;

   IF (X_Year_Retired) THEN
      l_year_retired := 'Y';
   ELSE
      l_year_retired := 'N';
   END IF;

   IF (X_Projecting_Flag) THEN
      l_calling_fn := 'fa_cde_pkg.whatif.faxgpolr';
   ELSE
      l_calling_fn := 'fa_cde_pkg.faxgpolr';
   END IF;

   FA_POLISH_PVT.Calc_Polish_Rate_Cost (
      p_Book_Type_Code             => X_Book_Type_Code,
      p_Asset_Id                   => X_Asset_Id,
      p_Polish_Rule                => X_Polish_Rule,
      p_Deprn_Factor               => X_Deprn_Factor,
      p_Alternate_Deprn_Factor     => X_Alternate_Deprn_Factor,
      p_Polish_Adj_Calc_Basis_Flag => NVL(X_Polish_Adj_Calc_Basis_Flag, 'N'),
      p_Rate                       => l_old_rate,
      p_Depreciate_Flag            => l_old_depreciate_flag,
      p_Adjusted_Cost              => l_old_adjusted_cost,
      p_Recoverable_Cost           => X_Recoverable_Cost,
      p_Adjusted_Recoverable_Cost  => l_old_adjusted_rec_cost,
      p_Fiscal_Year                => X_Fiscal_Year,
      p_Period_Num                 => X_Current_Period,
      p_Periods_Per_Year           => X_Periods_Per_Year,
      p_Year_Retired               => l_year_retired,
      p_MRC_Sob_Type_Code          => X_MRC_Sob_Type_Code,
      p_set_of_books_id            => X_set_of_books_id,
      x_Rate                       => l_new_rate,
      x_Depreciate_Flag            => l_new_depreciate_flag,
      x_Adjusted_Cost              => l_new_adjusted_cost,
      x_Adjusted_Recoverable_Cost  => l_new_adjusted_rec_cost,
      x_Success                    => l_success,
      p_Calling_Fn                 => l_calling_fn,
      p_log_level_rec              => p_log_level_rec);

   IF (l_success <> 1) THEN
      RAISE faxgpolr_err;
   END IF;

   X_Rate := l_new_rate;
   X_Current_Adjusted_Cost := l_new_adjusted_cost;
   x_Adjusted_Recoverable_cost := l_new_adjusted_rec_cost;

   IF (l_new_depreciate_flag = 'YES') THEN
      X_Depreciate_Flag := TRUE;
   ELSE
      X_Depreciate_Flag := FALSE;
   END IF;

   X_Success := 1;

EXCEPTION
   WHEN faxgpolr_err THEN
      fa_srvr_msg.add_sql_error (calling_fn => 'fa_cde_pkg.faxgpolr',  p_log_level_rec => p_log_level_rec);
      X_rate := 0;
      X_Success := 0;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error (calling_fn => 'fa_cde_pkg.faxgpolr',  p_log_level_rec => p_log_level_rec);
      X_rate := 0;
      X_Success := 0;

END faxgpolr;

END FA_CDE_PKG;

/
