--------------------------------------------------------
--  DDL for Package Body FA_INS_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_INS_DETAIL_PKG" as
/* $Header: FAXINDDB.pls 120.7.12010000.12 2010/04/23 06:12:19 gigupta ship $ */

--
-- FUNCTION faxindd
--

g_release                  number  := fa_cache_pkg.fazarel_release;

FUNCTION faxindd (X_book_type_code           VARCHAR2,
                  X_asset_id                 NUMBER,
                  X_period_counter           NUMBER := NULL,
                  X_cost                     NUMBER := NULL,
                  X_deprn_reserve            NUMBER := NULL,
                  /* Bug 525654 Modification */
                  X_deprn_adjustment_amount            NUMBER := NULL,
                  X_reval_reserve            NUMBER := NULL,
                  X_ytd                      NUMBER := NULL,
                  X_ytd_reval_dep_exp        NUMBER := NULL,
                  X_bonus_ytd                NUMBER := NULL,
                  X_bonus_deprn_reserve      NUMBER := NULL,
                  X_init_message_flag        VARCHAR2 DEFAULT 'NO',
                  X_bonus_deprn_adj_amount   NUMBER DEFAULT NULL,
                  X_bonus_deprn_amount       NUMBER DEFAULT NULL,
                  X_deprn_amount             NUMBER DEFAULT NULL,
                  X_reval_amortization       NUMBER DEFAULT NULL,
                  X_reval_deprn_expense      NUMBER DEFAULT NULL,
                  X_impairment_amount        NUMBER DEFAULT NULL,
                  X_ytd_impairment           NUMBER DEFAULT NULL,
                  X_impairment_reserve           NUMBER DEFAULT NULL,
                  X_capital_adjustment       NUMBER DEFAULT NULL,   --Bug 6666666
                  X_general_fund             NUMBER DEFAULT NULL,   --Bug 6666666
                  X_b_row                    BOOLEAN DEFAULT TRUE,
                  X_mrc_sob_type_code       VARCHAR2,
                  X_set_of_books_id         NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

         return BOOLEAN is

  h_dpr_dtl   fa_std_types.dpr_dtl_row_struct;
  h_ytd       NUMBER;
  h_deprn_reserve  NUMBER;

  /* Bug 525654 Modification */
  h_deprn_adjustment_amount  NUMBER;
  h_reval_reserve  NUMBER;
  h_ytd_reval_dep_exp  NUMBER;
  h_period_counter     NUMBER;
  h_cost               NUMBER;

  h_bonus_ytd           NUMBER;
  h_bonus_deprn_reserve NUMBER;

  h_msg_name           VARCHAR2(30) := NULL;

  BEGIN

      IF (X_init_message_flag = 'YES') THEN
          FA_SRVR_MSG.INIT_SERVER_MESSAGE;   /* init server msg stack */
          fa_debug_pkg.initialize;           /* init debug msg stack */
      END IF;

      IF (X_book_type_code IS NULL) OR (X_asset_id IS NULL) THEN
          FA_SRVR_MSG.add_message(
                     CALLING_FN => 'FA_INS_DETAIL_PKG.faxindd',
                     NAME       => 'FA_SHARED_ARGUMENTS',  p_log_level_rec => p_log_level_rec);
          return(FALSE);
      END IF;

      h_dpr_dtl.book := X_book_type_code;
      h_dpr_dtl.asset_id := X_asset_id;


      IF (X_cost          IS NULL OR
          X_deprn_reserve IS NULL OR
          X_reval_reserve IS NULL OR
          X_ytd           IS NULL OR
          X_ytd_reval_dep_exp IS NULL OR
          X_period_counter    IS NULL OR
          X_bonus_ytd           IS NULL OR
          X_bonus_deprn_reserve IS NULL) THEN


          if (X_mrc_sob_type_code = 'R') then

             h_msg_name := 'FA_DD_DEP_SUM';

             SELECT ytd_deprn, deprn_reserve,
                    reval_reserve, ytd_reval_deprn_expense,
                    bonus_ytd_deprn, bonus_deprn_reserve,
                    period_counter
             INTO   h_ytd,
                    h_deprn_reserve,
                    h_reval_reserve,
                    h_ytd_reval_dep_exp,
                    h_bonus_ytd,
                    h_bonus_deprn_reserve,
                    h_period_counter
             FROM   fa_mc_deprn_summary
             WHERE  book_type_code = X_book_type_code
             AND    asset_id = X_asset_id
             AND    deprn_source_code = 'BOOKS'
             AND    set_of_books_id = X_set_of_books_id;

             h_msg_name := 'FA_DD_BOOKS';

             SELECT decode(ad.asset_type,
                           'GROUP', 0,
                           bk.cost)
             INTO   h_cost
             FROM   FA_MC_BOOKS bk,
                    FA_ADDITIONS_B ad
             WHERE  ad.asset_id = X_asset_id
             AND    ad.asset_id = bk.asset_id
             AND    bk.book_type_code = X_book_type_code
             and    bk.transaction_header_id_out is null
             AND    set_of_books_id = X_set_of_books_id;

          else

             h_msg_name := 'FA_DD_DEP_SUM';

             SELECT ytd_deprn, deprn_reserve,
                    reval_reserve, ytd_reval_deprn_expense,
                    bonus_ytd_deprn, bonus_deprn_reserve,
                    period_counter
             INTO   h_ytd,
                    h_deprn_reserve,
                    h_reval_reserve,
                    h_ytd_reval_dep_exp,
                    h_bonus_ytd,
                    h_bonus_deprn_reserve,
                    h_period_counter
             FROM   fa_deprn_summary
             WHERE  book_type_code = X_book_type_code
             AND    asset_id = X_asset_id
             AND    deprn_source_code = 'BOOKS';

             h_msg_name := 'FA_DD_BOOKS';

             SELECT decode(ad.asset_type,
                           'GROUP', 0,
                           bk.cost)
             INTO   h_cost
             FROM   FA_BOOKS bk,
                    FA_ADDITIONS_B ad
             WHERE  ad.asset_id = X_asset_id
             AND    ad.asset_id = bk.asset_id
             AND    bk.book_type_code = X_book_type_code
             and    bk.transaction_header_id_out is null;

          end if;  -- end sob_id

          h_msg_name := NULL;
          if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','deprn_summary values:','', p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','ytd_deprn',h_ytd, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','deprn_reserve',h_deprn_reserve, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','reval_reserve',h_reval_reserve, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','ytd_reval_deprn_expense',h_ytd_reval_dep_exp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','period_counter',h_period_counter, p_log_level_rec => p_log_level_rec);
          end if;

       END IF;


        /* Bug 525654 Modification */

       IF X_deprn_adjustment_amount IS NULL THEN

          if (X_mrc_sob_type_code ='R') then

            SELECT sum(nvl(deprn_adjustment_amount,0))
            INTO   h_deprn_adjustment_amount
            FROM   fa_mc_deprn_detail
            WHERE  book_type_code = X_book_type_code
            AND    asset_id = X_asset_id
            AND    deprn_source_code = 'B'
            AND    set_of_books_id = X_set_of_books_id;

          else

            SELECT sum(nvl(deprn_adjustment_amount,0))
            INTO   h_deprn_adjustment_amount
            FROM   fa_deprn_detail
            WHERE  book_type_code = X_book_type_code
            AND    asset_id = X_asset_id
            AND    deprn_source_code = 'B';

          end if;
        END IF;


        IF (X_cost IS NOT NULL) THEN
           h_dpr_dtl.cost := X_cost;
        ELSE
           h_dpr_dtl.cost := h_cost;
        END IF;

        IF (X_ytd IS NOT NULL) THEN
           h_dpr_dtl.ytd := X_ytd;
        ELSE
           h_dpr_dtl.ytd := h_ytd;
        END IF;

        IF (X_deprn_reserve IS NOT NULL) THEN
           h_dpr_dtl.deprn_reserve := X_deprn_reserve;
        ELSE
           h_dpr_dtl.deprn_reserve := h_deprn_reserve;
        END IF;

        /* Bug 525654 Modification */
        IF (X_deprn_adjustment_amount IS NOT NULL) THEN
           h_dpr_dtl.deprn_adjustment_amount := X_deprn_adjustment_amount;
        ELSE
           h_dpr_dtl.deprn_adjustment_amount := h_deprn_adjustment_amount;
        END IF;



        IF (X_reval_reserve IS NOT NULL) THEN
           h_dpr_dtl.reval_reserve := X_reval_reserve;
           h_dpr_dtl.reval_rsv_flag := TRUE;
        ELSE
           IF (h_reval_reserve IS NULL) THEN
              h_dpr_dtl.reval_reserve := 0;
              h_dpr_dtl.reval_rsv_flag := FALSE;
           ELSE
              h_dpr_dtl.reval_reserve := h_reval_reserve;
              h_dpr_dtl.reval_rsv_flag := TRUE;
           END IF;
        END IF;

        IF (X_ytd_reval_dep_exp IS NOT NULL) THEN
           h_dpr_dtl.ytd_reval_dep_exp := X_ytd_reval_dep_exp;
           h_dpr_dtl.ytd_reval_dep_exp_flag := TRUE;
        ELSE
           IF (h_ytd_reval_dep_exp IS NULL) THEN
              h_dpr_dtl.ytd_reval_dep_exp := 0;
              h_dpr_dtl.ytd_reval_dep_exp_flag := FALSE;
           ELSE
              h_dpr_dtl.ytd_reval_dep_exp := h_ytd_reval_dep_exp;
              h_dpr_dtl.ytd_reval_dep_exp_flag := TRUE;
           END IF;
        END IF;
        IF (X_bonus_ytd IS NOT NULL) THEN
           h_dpr_dtl.bonus_ytd := X_bonus_ytd;
        ELSE
           h_dpr_dtl.bonus_ytd := h_bonus_ytd;
        END IF;

        IF (X_bonus_deprn_reserve IS NOT NULL) THEN
           h_dpr_dtl.bonus_deprn_reserve := X_bonus_deprn_reserve;
        ELSE
           h_dpr_dtl.bonus_deprn_reserve := h_bonus_deprn_reserve;
        END IF;

        -- IAS36, add nvl below
        h_dpr_dtl.period_counter      := nvl(h_period_counter, X_period_counter);

        -- IAS36
        h_dpr_dtl.bonus_deprn_adj_amount := X_bonus_deprn_adj_amount;
        h_dpr_dtl.bonus_deprn_amount := nvl(X_bonus_deprn_amount, 0);
        h_dpr_dtl.impairment_amount := X_impairment_amount;
        h_dpr_dtl.ytd_impairment := X_ytd_impairment;
        h_dpr_dtl.impairment_reserve := X_impairment_reserve;
        h_dpr_dtl.deprn_amount := nvl(X_deprn_amount, 0);
        h_dpr_dtl.reval_amortization := nvl(X_reval_amortization, 0);
        h_dpr_dtl.reval_deprn_expense := nvl(X_reval_deprn_expense, 0);

        -- Bug 6666666
        h_dpr_dtl.capital_adjustment := X_capital_adjustment;
        h_dpr_dtl.general_fund := X_general_fund;

        if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','values before call to fadpdtl','', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','cost',h_dpr_dtl.cost, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','ytd_deprn',h_dpr_dtl.ytd, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','deprn_reserve',h_dpr_dtl.deprn_reserve, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','reval_reserve',h_dpr_dtl.reval_reserve, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','ytd_reval_deprn_expense',h_dpr_dtl.ytd_reval_dep_exp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','period_counter',h_dpr_dtl.period_counter, p_log_level_rec => p_log_level_rec);
        end if;

        IF (NOT fadpdtl(X_dpr_dtl     => h_dpr_dtl,
                        X_source_flag => X_b_row, -- TRUE,  Modified for ias36
                        X_mrc_sob_type_code => X_mrc_sob_type_code,
                        X_set_of_books_id => X_set_of_books_id,
                        p_log_level_rec => p_log_level_rec)) THEN
           FA_SRVR_MSG.add_message (
                       CALLING_FN => 'FA_INS_DETAIL_PKG.faxindd',  p_log_level_rec => p_log_level_rec);
           return(FALSE);
        END IF;

        return(TRUE);

   EXCEPTION

      WHEN NO_DATA_FOUND then
          FA_SRVR_MSG.add_message(
                      CALLING_FN => 'FA_INS_DETAIL_PKG.faxindd',
                      NAME       => h_msg_name,  p_log_level_rec => p_log_level_rec);
          return FALSE;

      WHEN OTHERS THEN
          FA_SRVR_MSG.ADD_SQL_ERROR(
                      CALLING_FN => 'FA_INS_DETAIL_PKG.faxindd',  p_log_level_rec => p_log_level_rec);
          return(FALSE);
   END faxindd;


--
-- FUNCTION fadpdtl
--
FUNCTION fadpdtl(X_dpr_dtl     FA_STD_TYPES.DPR_DTL_ROW_STRUCT,
                 X_source_flag BOOLEAN,
                 X_mrc_sob_type_code       VARCHAR2,
                 X_set_of_books_id  NUMBER,
                 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
                 return   BOOLEAN IS

    h_book_type_code       VARCHAR2(30);
    h_asset_id             NUMBER;
    h_period_counter       NUMBER;
    h_dist_book            VARCHAR2(30);
    h_source_code          VARCHAR2(1);

    h_dist_id              NUMBER;
    h_units_assigned       NUMBER;
    h_sysdate              DATE;
    h_rec_count            NUMBER := 0;
    h_dist_count           NUMBER := 0;
    h_total_units          NUMBER := 0;
    h_pc_counter           NUMBER := 0;

    h_sum_cost               NUMBER := 0;
    h_sum_ytd                NUMBER := 0;
    h_sum_deprn_reserve      NUMBER := 0;

    /* Bug 525654 Modification */

    h_part_deprn_adjustment_amount      NUMBER := 0;
    h_sum_reval_reserve      NUMBER := 0;
    h_sum_ytd_reval_dep_exp  NUMBER := 0;
    h_sum_bonus_ytd          NUMBER := 0;
    h_sum_bonus_deprn_reserve NUMBER := 0;

    h_part_cost              NUMBER := 0;
    h_part_ytd               NUMBER := 0;
    h_part_deprn_reserve     NUMBER := 0;
    h_part_reval_reserve     NUMBER := 0;
    h_part_ytd_reval_dep_exp NUMBER := 0;
    h_part_bonus_ytd              NUMBER := 0;
    h_part_bonus_deprn_reserve    NUMBER := 0;

    -- IAS36
    h_part_bonus_deprn_amount     NUMBER := 0;
    h_part_bonus_deprn_adj_amount NUMBER := 0;
    h_part_impairment_amount      NUMBER := 0;
    h_part_ytd_impairment         NUMBER := 0;
    h_part_impairment_reserve         NUMBER := 0;
    h_part_deprn_amount           NUMBER := 0;
    h_part_reval_amortization     NUMBER := 0;
    h_part_reval_deprn_expense    NUMBER := 0;
    h_sum_bonus_amount            NUMBER := 0;
    h_sum_bonus_deprn_adj_amount  NUMBER := 0;
    h_sum_impairment_amount       NUMBER := 0;
    h_sum_ytd_impairment          NUMBER := 0;
    h_sum_impairment_reserve          NUMBER := 0;
    h_sum_deprn_amount            NUMBER := 0;
    h_sum_reval_amortization      NUMBER := 0;
    h_sum_reval_deprn_expense     NUMBER := 0;

    --Bug 6666666
    h_part_capital_adjustment     NUMBER := 0;
    h_part_general_fund           NUMBER := 0;
    h_sum_capital_adjustment      NUMBER := 0;
    h_sum_general_fund            NUMBER := 0;

	 --Added for 9128700
	 h_add_date DATE := NULL;

    h_full_ytd               NUMBER := 0; -- Bug 5984105

    h_msg_name               VARCHAR2(30) := NULL;
    ERROR_FOUND              EXCEPTION;

    h_count                       NUMBER := 0; --Bug 9142501
    h_cost_to_clear               NUMBER := 0; --Bug 9142501

    CURSOR C1_11 IS
       SELECT   distribution_id, units_assigned
       FROM     fa_distribution_history
       WHERE    book_type_code = h_dist_book AND
                asset_id = h_asset_id AND
                date_ineffective IS NULL
       ORDER BY distribution_id;

    --Changed for 9128700

    CURSOR C1 IS
       SELECT   distribution_id, units_assigned
       FROM     fa_distribution_history
       WHERE    book_type_code = h_dist_book
       AND      asset_id = h_asset_id
	    AND      h_add_date BETWEEN
	             date_effective AND NVL(date_ineffective,SYSDATE)
       ORDER BY distribution_id;


    -- Bug 5984105 Fetch transfered out current period distribuitons
    /*Bug#8421266- Modified cursor to fetch all the distributions transferred out in current fiscal year */
    CURSOR C2 IS
        SELECT  dh.distribution_id,
                dh.units_assigned,
                dp.period_counter
        FROM    fa_distribution_history dh, fa_deprn_periods dp, fa_transaction_headers th
        WHERE   dh.asset_id = X_dpr_dtl.asset_id
        AND     dh.book_type_code = fa_cache_pkg.fazcbc_record.distribution_source_book
        AND     dp.book_type_code = X_dpr_dtl.book
        AND     NVL(dh.date_ineffective, sysdate) >=  dp.period_open_date
        and     dh.transaction_header_id_out IS not NULL
        and     th.book_type_code = dh.book_type_code
        and     th.asset_id = dh.asset_id
        and     th.date_Effective between dp.period_open_date and NVL(dp.period_close_date,sysdate)
        and     th.transaction_type_code in ('TRANSFER','UNIT ADJUSTMENT','RECLASS','REINSTATEMENT')
        --Bug# 7291015 - Added Unit Adjustment,Bug# 6701439 - Added Reclass
        /*Bug#7836587 - Added REINSTATEMENT */
        and     dh.transaction_header_id_out = th.transaction_header_id
        and     dp.fiscal_year =
                (select fiscal_year
                 from   fa_deprn_periods dp2
                 where  dp2.period_close_date is NULL
                 and    book_type_code = X_dpr_dtl.book)
        ORDER BY dh.distribution_id;

    CURSOR C_MC_COST_TO_CLEAR IS --Bug 9142501
    SELECT SUM(NVL(adjustment_amount,0))
      FROM FA_MC_ADJUSTMENTS adj,
           FA_TRANSACTION_HEADERS th
     WHERE adj.book_type_code(+) = h_book_type_code
       AND adj.asset_id(+) = h_asset_id
       AND adj.adjustment_type(+) = decode (th.transaction_type_code, 'CIP ADDITION', 'CIP COST', 'ADDITION', 'COST')
       AND adj.distribution_id(+) = h_dist_id
       AND th.book_type_code = h_book_type_code
       AND th.asset_id = h_asset_id
       AND th.transaction_type_code in ('CIP ADDITION','ADDITION')
       AND th.transaction_header_id = adj.transaction_header_id(+)
     GROUP BY th.transaction_header_id
     ORDER BY th.transaction_header_id;

 	 CURSOR C_COST_TO_CLEAR IS --Bug 9142501
    SELECT SUM(NVL(adjustment_amount,0))
      FROM FA_ADJUSTMENTS adj,
           FA_TRANSACTION_HEADERS th
     WHERE adj.book_type_code(+) = h_book_type_code
       AND adj.asset_id(+) = h_asset_id
       AND adj.adjustment_type(+) = decode (th.transaction_type_code, 'CIP ADDITION', 'CIP COST', 'ADDITION', 'COST')
       AND adj.distribution_id(+) = h_dist_id
       AND th.book_type_code = h_book_type_code
       AND th.asset_id = h_asset_id
       AND th.transaction_type_code in ('CIP ADDITION','ADDITION')
       AND th.transaction_header_id = adj.transaction_header_id(+)
     GROUP BY th.transaction_header_id
     ORDER BY th.transaction_header_id;

  BEGIN

    -- need to insure this is only called from faxindd and no other location!!!!

    h_book_type_code := X_dpr_dtl.book;
    h_asset_id := X_dpr_dtl.asset_id;
    h_period_counter := X_dpr_dtl.period_counter;

    h_msg_name := 'FA_SHARED_DATA_ERR_BC';

    -- bug# 2140468 - use cache
    h_dist_book := fa_cache_pkg.fazcbc_record.distribution_source_book;

    h_msg_name := 'FA_SHARED_DATA_ERR_DH';

    /*Bug 9142501 - Start:In POA Cost adjustment should not reflect in B row of fa_deprn_detail.
 	       ADDITION_COST_TO_CLEAR should contain old value only, which is addition time value. */
 	 IF X_mrc_sob_type_code = 'R' THEN
       SELECT COUNT(*)
         INTO h_count
         FROM FA_MC_DEPRN_DETAIL
        WHERE book_type_code = h_book_type_code AND
              asset_id = h_asset_id AND
              period_counter = h_period_counter;
 	 ELSE
       SELECT COUNT(*)
         INTO h_count
         FROM FA_DEPRN_DETAIL
        WHERE book_type_code = h_book_type_code AND
              asset_id = h_asset_id AND
              period_counter = h_period_counter;
 	 END IF;
 	 /*Bug 9142501 - End*/

    if (G_release = 11 or X_source_flag = FALSE) then
       SELECT nvl(SUM(dh.units_assigned),0), COUNT(*)
       INTO   h_total_units, h_dist_count
       FROM   fa_distribution_history dh
       WHERE  dh.book_type_code = h_dist_book AND
              dh.asset_id = h_asset_id AND
              dh.date_ineffective IS NULL;
    else
       -- Bug 8237945 ... Since this is called only in Period of Addition, and in
    -- Period of addition we always have to take Distributions at the time of
    -- additions into consideration . Commented dh.date_ineffective is null
    -- condition
    -- Bug 8281792 ... We need to pass h_dist_book for book_type_code, since we can
    -- have a situation where we are using Tax Book and fa_distribution_history does
    -- not contain units. Also rewritten the query using EXISTS cluase

	 --Modified for 9128700

    BEGIN

       SELECT MIN(date_effective)
         INTO h_add_date
         FROM fa_transaction_headers
        WHERE book_type_code = h_book_type_code
          AND asset_id = h_asset_id
          AND transaction_type_code LIKE '%ADDITION%';

    EXCEPTION
    WHEN OTHERS THEN
	   if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','Getting date added',SQLERRM, p_log_level_rec => p_log_level_rec);
      end if;

		RAISE  ERROR_FOUND;
    END;


    SELECT nvl(SUM(dh.units_assigned),0), COUNT(*)
      INTO h_total_units, h_dist_count
      FROM fa_distribution_history dh
     WHERE dh.book_type_code = h_dist_book
       AND dh.asset_id = h_asset_id
       AND h_add_date BETWEEN
	        date_effective AND NVL(date_ineffective,SYSDATE);

    --End of modification for 9128700

    end if;

    IF (h_total_units = 0) THEN
        FA_SRVR_MSG.add_message(
                    CALLING_FN => 'FA_INS_DETAIL_PKG.fadpdtl',
                    NAME       => 'FA_SHARED_DATA_ERR_DH',  p_log_level_rec => p_log_level_rec);
        return (FALSE);
    END IF;

    h_msg_name := NULL;

    if X_mrc_sob_type_code = 'R' then
       DELETE FROM fa_mc_deprn_detail
       WHERE  book_type_code = h_book_type_code AND
              asset_id = h_asset_id AND
              period_counter = h_period_counter AND
              set_of_books_id = X_set_of_books_id;
    else
       DELETE FROM fa_deprn_detail
       WHERE  book_type_code = h_book_type_code AND
              asset_id = h_asset_id AND
              period_counter = h_period_counter;
    end if;  -- end mrc


    IF (SQL%NOTFOUND) THEN
       null;
    END IF;


    IF (X_source_flag) THEN   -- insert B row
       h_source_code := 'B';
       h_sysdate := sysdate;
    ELSE
       h_source_code := 'D';  -- insert D row
       h_sysdate := sysdate;
    END IF;

    -- Bug 5984105 -- Start
    --   Insert rows into fa_deprn_detail for the
    --   transfered out distributions
    h_full_ytd := X_dpr_dtl.ytd;

    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','At Start Total Ytd',h_full_ytd, p_log_level_rec => p_log_level_rec);
    end if;
    if (X_dpr_dtl.impairment_amount is not null and
        X_dpr_dtl.impairment_amount <> 0 ) then
       open c2;
       loop
          h_units_assigned := 0;
          h_dist_id := 0;

          FETCH C2 INTO h_dist_id,
                        h_units_assigned,
			h_pc_counter;
          EXIT WHEN C2%NOTFOUND;
          BEGIN

          /*Bug#8421266 - Modified query to fetch ytd_deprn of transferred out distribution.*/
          if (X_mrc_sob_type_code = 'R') then
             SELECT ytd_deprn
             INTO   h_part_ytd
             FROM   fa_mc_deprn_detail
             WHERE  book_type_code = h_book_type_code
             and    asset_id = h_asset_id
             and    distribution_id = h_dist_id
             and    period_counter = (select max(period_counter)
                                     from   fa_mc_deprn_detail fdd2
                                     where  fdd2.asset_id = h_asset_id
                                     and    fdd2.distribution_id = h_dist_id
                                     and    fdd2.set_of_books_id = X_set_of_books_id
                                     and    fdd2.book_type_code = h_book_type_code)
             and    set_of_books_id = X_set_of_books_id;
          else
             SELECT ytd_deprn
             INTO   h_part_ytd
             FROM   fa_deprn_detail
             WHERE  book_type_code = h_book_type_code
             and    asset_id = h_asset_id
             and    distribution_id = h_dist_id
             and    period_counter = (select max(period_counter)
                                     from   fa_deprn_detail fdd2
                                     where  fdd2.asset_id = h_asset_id
                                     and    fdd2.book_type_code = h_book_type_code
                                     and    fdd2.distribution_id = h_dist_id);
          end if;
          EXCEPTION
             WHEN OTHERS THEN
                h_part_ytd := 0;
          END;

          h_full_ytd := h_full_ytd - h_part_ytd;

          if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add('FA_INS_DETAIL_PKG.fadpdtl','values after C2 fetch','', p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','dist_id',h_dist_id, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','units_assigned',h_units_assigned, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','h_part_ytd',h_part_ytd, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','Total Ytd',h_full_ytd, p_log_level_rec => p_log_level_rec);
          end if;

          /*Bug#8421266 - Insert row in deprn table only when transferred out in current period.*/
          if h_pc_counter = h_period_counter then
	     if (X_mrc_sob_type_code = 'R') then

                INSERT INTO fa_mc_deprn_detail
                                  (SET_OF_BOOKS_ID,
                                   BOOK_TYPE_CODE,
                                   ASSET_ID,
                                   DISTRIBUTION_ID,
                                   PERIOD_COUNTER,
                                   DEPRN_RUN_DATE,
                                   DEPRN_AMOUNT,
                                   YTD_DEPRN,
                                   ADDITION_COST_TO_CLEAR,
                                   DEPRN_RESERVE,
                                   /* Bug 525654 Modification */
                                   DEPRN_ADJUSTMENT_AMOUNT,
                                   REVAL_RESERVE,
                                   YTD_REVAL_DEPRN_EXPENSE,
                                   COST,
                                   DEPRN_SOURCE_CODE,
                                   BONUS_DEPRN_AMOUNT,
                                   BONUS_YTD_DEPRN,
                                   BONUS_DEPRN_RESERVE,
                                   BONUS_DEPRN_ADJUSTMENT_AMOUNT,
                                   IMPAIRMENT_AMOUNT,
                                   YTD_IMPAIRMENT,
                                   impairment_reserve,
                                   REVAL_AMORTIZATION,
                                   REVAL_DEPRN_EXPENSE)
                        VALUES (X_set_of_books_id,
                                h_book_type_code,
                                h_asset_id,
                                h_dist_id,
                                h_period_counter,
                                h_sysdate,
                                0,
                                h_part_ytd, ---ytd_deprn
                                0,  ---cost_to_clear( doubt for POA)
                                0,
                                0,
                                0,
                                0,
                                0,
                                h_source_code,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0);

             else
                INSERT INTO fa_deprn_detail(
                                   BOOK_TYPE_CODE,
                                   ASSET_ID,
                                   DISTRIBUTION_ID,
                                   PERIOD_COUNTER,
                                   DEPRN_RUN_DATE,
                                   DEPRN_AMOUNT,
                                   YTD_DEPRN,
                                   ADDITION_COST_TO_CLEAR,
                                   DEPRN_RESERVE,
                                   /* Bug 525654 Modification */
                                   DEPRN_ADJUSTMENT_AMOUNT,
                                   REVAL_RESERVE,
                                   YTD_REVAL_DEPRN_EXPENSE,
                                   COST,
                                   DEPRN_SOURCE_CODE,
                                   BONUS_DEPRN_AMOUNT,
                                   BONUS_YTD_DEPRN,
                                   BONUS_DEPRN_RESERVE,
                                   BONUS_DEPRN_ADJUSTMENT_AMOUNT,
                                   IMPAIRMENT_AMOUNT,
                                   YTD_IMPAIRMENT,
                                   impairment_reserve,
                                   REVAL_AMORTIZATION,
                                   REVAL_DEPRN_EXPENSE)
                        VALUES (h_book_type_code,
                                h_asset_id,
                                h_dist_id,
                                h_period_counter,
                                h_sysdate,
                                0,
                                h_part_ytd, ---ytd_deprn
                                0,  ---cost_to_clear( doubt for POA)
                                0,
                                0,
                                0,
                                0,
                                0,
                                h_source_code,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0);
             end if;
          end if;
       end loop;
    end if;

    -- Bug 5984105 -- End

    if (G_release = 11 OR X_source_flag = FALSE ) then /* Bug# 8731454 - Need to use C1_11 only for impairment */
       OPEN C1_11;
    else
       OPEN C1;
    end if;

    LOOP
       h_units_assigned := 0;
       h_dist_id := 0;

       if (G_release = 11 OR X_source_flag = FALSE ) then -- Bug# 8731454
          FETCH C1_11 INTO h_dist_id, h_units_assigned;
          EXIT WHEN C1_11%NOTFOUND;
       else
          FETCH C1 INTO h_dist_id, h_units_assigned;
          EXIT WHEN C1%NOTFOUND;
       end if;

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.fadpdtl','values after the fetch','', p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','dist_id',h_dist_id, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','units_assigned',h_units_assigned, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','total_units',h_total_units, p_log_level_rec => p_log_level_rec);
       end if;

       /*Bug 9142501 - Start:In POA Cost adjustment should not reflect in B row of fa_deprn_detail.
                       ADDITION_COST_TO_CLEAR should contain old value only, which is addition time value. */
       fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','Brahma2 before Loop','BRAHMA',p_log_level_rec => p_log_level_rec);
       IF h_count > 0 THEN
          IF X_mrc_sob_type_code = 'R' THEN
             OPEN C_MC_COST_TO_CLEAR;
             FETCH C_MC_COST_TO_CLEAR INTO h_cost_to_clear;
             CLOSE C_MC_COST_TO_CLEAR;
          ELSE
             OPEN C_COST_TO_CLEAR;
             FETCH C_COST_TO_CLEAR INTO h_cost_to_clear;
             CLOSE C_COST_TO_CLEAR;
          END IF;
       END IF;
       /*Bug 9142501 - End*/

       h_rec_count := h_rec_count + 1;

       h_part_cost := (X_dpr_dtl.cost * h_units_assigned) / h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_cost,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       h_part_ytd := (h_full_ytd * h_units_assigned) / h_total_units; -- Bug 5984105

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_ytd,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;


/* Bug 525654 Modification */
        h_part_deprn_adjustment_amount := ( X_dpr_dtl.deprn_adjustment_amount * h_units_assigned) / h_total_units;

       h_part_deprn_reserve := (X_dpr_dtl.deprn_reserve * h_units_assigned) /
                                h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_deprn_reserve,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       IF (X_dpr_dtl.reval_rsv_flag) THEN
          h_part_reval_reserve := (X_dpr_dtl.reval_reserve * h_units_assigned) /
                                   h_total_units;

          IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_reval_reserve,
                                      X_book            => h_book_type_code,
                                      X_set_of_books_id => X_set_of_books_id,
                                      p_log_level_rec   => p_log_level_rec)) THEN
              raise ERROR_FOUND;
          END IF;
       ELSE
          h_part_reval_reserve := NULL;
       END IF;


       IF (X_dpr_dtl.ytd_reval_dep_exp_flag) THEN
          h_part_ytd_reval_dep_exp := (X_dpr_dtl.ytd_reval_dep_exp * h_units_assigned) /
                                       h_total_units;

          IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_ytd_reval_dep_exp,
                                      X_book            => h_book_type_code,
                                      X_set_of_books_id => X_set_of_books_id,
                                      p_log_level_rec   => p_log_level_rec)) THEN
              raise ERROR_FOUND;
          END IF;
       ELSE
          h_part_ytd_reval_dep_exp := NULL;
       END IF;

       h_part_bonus_ytd := (X_dpr_dtl.bonus_ytd * h_units_assigned) /
                                h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_bonus_ytd,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       h_part_bonus_deprn_reserve := (X_dpr_dtl.bonus_deprn_reserve * h_units_assigned) /
                                h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount         => h_part_bonus_deprn_reserve,
                                  X_book            => h_book_type_code,
                                  X_set_of_books_id => X_set_of_books_id,
                                  p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       -- IAS36
       -- bonus, bonus adj, imp, ytd imp, and ltd imp
       h_part_bonus_deprn_amount := (X_dpr_dtl.bonus_deprn_amount * h_units_assigned) /
                                          h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_bonus_deprn_amount,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       h_part_bonus_deprn_adj_amount := (X_dpr_dtl.bonus_deprn_adj_amount * h_units_assigned) /
                                             h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_bonus_deprn_adj_amount,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       h_part_impairment_amount := (X_dpr_dtl.impairment_amount * h_units_assigned) /
                                          h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_impairment_amount,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       h_part_ytd_impairment := (X_dpr_dtl.ytd_impairment * h_units_assigned) /
                                          h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_ytd_impairment,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       h_part_impairment_reserve := (X_dpr_dtl.impairment_reserve * h_units_assigned) /
                                          h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_impairment_reserve,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       h_part_deprn_amount := (X_dpr_dtl.deprn_amount *  h_units_assigned) /
                                          h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_deprn_amount,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       h_part_reval_amortization := (X_dpr_dtl.reval_amortization * h_units_assigned) /
                                          h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_reval_amortization,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       h_part_reval_deprn_expense := (X_dpr_dtl.reval_deprn_expense * h_units_assigned) /
                                          h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_reval_deprn_expense,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       -- Bug 6666666

       h_part_capital_adjustment := (X_dpr_dtl.capital_adjustment * h_units_assigned) /
                                          h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_capital_adjustment,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       h_part_general_fund := (X_dpr_dtl.general_fund * h_units_assigned) /
                                          h_total_units;

       IF (NOT FA_UTILS_PKG.faxrnd(X_amount          => h_part_general_fund,
                                   X_book            => h_book_type_code,
                                   X_set_of_books_id => X_set_of_books_id,
                                   p_log_level_rec   => p_log_level_rec)) THEN
            raise ERROR_FOUND;
       END IF;

       h_sum_cost := h_sum_cost + h_part_cost;
       h_sum_ytd :=  h_sum_ytd + h_part_ytd;
       h_sum_deprn_reserve := h_sum_deprn_reserve + h_part_deprn_reserve;
       h_sum_bonus_ytd :=  h_sum_bonus_ytd + h_part_bonus_ytd;
       h_sum_bonus_deprn_reserve := h_sum_bonus_deprn_reserve + h_part_bonus_deprn_reserve;
       -- IAS36
       h_sum_bonus_amount := h_sum_bonus_amount + h_part_bonus_deprn_amount;
       h_sum_bonus_deprn_adj_amount := h_sum_bonus_deprn_adj_amount + h_part_bonus_deprn_adj_amount;
       h_sum_impairment_amount := h_sum_impairment_amount + h_part_impairment_amount;
       h_sum_ytd_impairment := h_sum_ytd_impairment + h_part_ytd_impairment;
       h_sum_impairment_reserve := h_sum_impairment_reserve + h_part_impairment_reserve;
       h_sum_deprn_amount := h_sum_deprn_amount + h_part_deprn_amount;
       h_sum_reval_amortization := h_sum_reval_amortization + h_part_reval_amortization;
       h_sum_reval_deprn_expense := h_sum_reval_deprn_expense + h_part_reval_deprn_expense;

       --Bug 6666666
       h_sum_capital_adjustment := h_sum_capital_adjustment + h_part_capital_adjustment;
       h_sum_general_fund := h_sum_general_fund + h_part_general_fund;

       if (X_dpr_dtl.reval_rsv_flag) then
         h_sum_reval_reserve := h_sum_reval_reserve + h_part_reval_reserve;
       end if;
       if (X_dpr_dtl.ytd_reval_dep_exp_flag) then
         h_sum_ytd_reval_dep_exp := h_sum_ytd_reval_dep_exp +
                                    h_part_ytd_reval_dep_exp;
       end if;


       IF (h_rec_count = h_dist_count) THEN
          h_part_cost := h_part_cost + (X_dpr_dtl.cost - h_sum_cost);
          h_part_ytd  := h_part_ytd + (h_full_ytd - h_sum_ytd); -- Bug 5984105
          h_part_deprn_reserve := h_part_deprn_reserve +
                                 (X_dpr_dtl.deprn_reserve - h_sum_deprn_reserve);
          h_part_bonus_ytd  := h_part_bonus_ytd + (X_dpr_dtl.bonus_ytd - h_sum_bonus_ytd);
          h_part_bonus_deprn_reserve := h_part_bonus_deprn_reserve +
                                 (X_dpr_dtl.bonus_deprn_reserve - h_sum_bonus_deprn_reserve);

          if (X_dpr_dtl.reval_rsv_flag) then
             h_part_reval_reserve := h_part_reval_reserve +
                                 (X_dpr_dtl.reval_reserve - h_sum_reval_reserve);
          end if;
          if (X_dpr_dtl.ytd_reval_dep_exp_flag) then
              h_part_ytd_reval_dep_exp := h_part_ytd_reval_dep_exp +
                           (X_dpr_dtl.ytd_reval_dep_exp - h_sum_ytd_reval_dep_exp);
          end if;

          -- IAS36
          h_part_bonus_deprn_amount := h_part_bonus_deprn_amount + (X_dpr_dtl.bonus_deprn_amount - h_sum_bonus_amount);
          h_part_bonus_deprn_adj_amount := h_part_bonus_deprn_adj_amount + (X_dpr_dtl.bonus_deprn_adj_amount -
                                                                            h_sum_bonus_deprn_adj_amount);
          h_part_impairment_amount := h_part_impairment_amount + (X_dpr_dtl.impairment_amount - h_sum_impairment_amount);
          h_part_ytd_impairment := h_part_ytd_impairment + (X_dpr_dtl.ytd_impairment - h_sum_ytd_impairment);
          h_part_impairment_reserve := h_part_impairment_reserve + (X_dpr_dtl.impairment_reserve - h_sum_impairment_reserve);
          h_part_deprn_amount := h_part_deprn_amount + (X_dpr_dtl.deprn_amount - h_sum_deprn_amount);
          h_part_reval_amortization := h_part_reval_amortization + (X_dpr_dtl.reval_amortization - h_sum_reval_amortization);
          h_part_reval_deprn_expense := h_part_reval_deprn_expense + (X_dpr_dtl.reval_deprn_expense - h_sum_reval_deprn_expense);

          -- Bug 6666666
          h_part_capital_adjustment := h_part_capital_adjustment + (X_dpr_dtl.capital_adjustment - h_sum_capital_adjustment);
          h_part_general_fund := h_part_general_fund + (X_dpr_dtl.general_fund - h_sum_general_fund);

       END IF;

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.fadpdtl','values before the insert to deprn_detail','', p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','book',h_book_type_code, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','asset_id',h_asset_id, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','dist_id',h_dist_id, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','source_code',h_source_code, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.fadpdtl','period_counter',h_period_counter, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','ytd_deprn',h_part_ytd, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','deprn_reserve',h_part_deprn_reserve, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','reval_reserve',h_part_reval_reserve, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('FA_INS_DETAIL_PKG.faxindd','ytd_reval_deprn_expense',h_part_ytd_reval_dep_exp, p_log_level_rec => p_log_level_rec);
       end if;

       if (G_release = 11) then
          h_cost_to_clear := h_part_cost;
       end if;

       if (X_mrc_sob_type_code = 'R') then
       INSERT INTO fa_mc_deprn_detail
                                  (SET_OF_BOOKS_ID,
                                   BOOK_TYPE_CODE,
                                   ASSET_ID,
                                   DISTRIBUTION_ID,
                                   PERIOD_COUNTER,
                                   DEPRN_RUN_DATE,
                                   DEPRN_AMOUNT,
                                   YTD_DEPRN,
                                   ADDITION_COST_TO_CLEAR,
                                   DEPRN_RESERVE,
                                   /* Bug 525654 Modification */
                                   DEPRN_ADJUSTMENT_AMOUNT,
                                   REVAL_RESERVE,
                                   YTD_REVAL_DEPRN_EXPENSE,
                                   COST,
                                   DEPRN_SOURCE_CODE,
                                   BONUS_DEPRN_AMOUNT,
                                   BONUS_YTD_DEPRN,
                                   BONUS_DEPRN_RESERVE,
                                   BONUS_DEPRN_ADJUSTMENT_AMOUNT,
                                   IMPAIRMENT_AMOUNT,
                                   YTD_IMPAIRMENT,
                                   impairment_reserve,
                                   REVAL_AMORTIZATION,
                                   REVAL_DEPRN_EXPENSE,
                                   CAPITAL_ADJUSTMENT,
                                   GENERAL_FUND)
                  VALUES (X_set_of_books_id,
                          h_book_type_code,
                          h_asset_id,
                          h_dist_id,
                          h_period_counter,
                          h_sysdate,
                          h_part_deprn_amount,
                          h_part_ytd,
                          decode(h_source_code, 'B', decode(h_count,0,h_part_cost,h_cost_to_clear),0), --Bug 9142501
                          h_part_deprn_reserve,
                          /* Bug 525654 Modification */
                          h_part_deprn_adjustment_amount,
                          h_part_reval_reserve,
                          h_part_ytd_reval_dep_exp,
                          decode(h_source_code, 'D',h_part_cost,0),
                          h_source_code,
                          h_part_bonus_deprn_amount,
                          h_part_bonus_ytd,
                          h_part_bonus_deprn_reserve,
                          h_part_bonus_deprn_adj_amount,
                          h_part_impairment_amount,
                          h_part_ytd_impairment,
                          h_part_impairment_reserve,
                          h_part_reval_amortization,
                          h_part_reval_deprn_expense,
                          h_part_capital_adjustment,
                          h_part_general_fund);

       else

       INSERT INTO fa_deprn_detail(BOOK_TYPE_CODE,
                                   ASSET_ID,
                                   DISTRIBUTION_ID,
                                   PERIOD_COUNTER,
                                   DEPRN_RUN_DATE,
                                   DEPRN_AMOUNT,
                                   YTD_DEPRN,
                                   ADDITION_COST_TO_CLEAR,
                                   DEPRN_RESERVE,
                                   /* Bug 525654 Modification */
                                   DEPRN_ADJUSTMENT_AMOUNT,
                                   REVAL_RESERVE,
                                   YTD_REVAL_DEPRN_EXPENSE,
                                   COST,
                                   DEPRN_SOURCE_CODE,
                                   BONUS_DEPRN_AMOUNT,
                                   BONUS_YTD_DEPRN,
                                   BONUS_DEPRN_RESERVE,
                                   BONUS_DEPRN_ADJUSTMENT_AMOUNT,
                                   IMPAIRMENT_AMOUNT,
                                   YTD_IMPAIRMENT,
                                   impairment_reserve,
                                   REVAL_AMORTIZATION,
                                   REVAL_DEPRN_EXPENSE,
                                   CAPITAL_ADJUSTMENT,
                                   GENERAL_FUND)
                  VALUES (h_book_type_code,
                          h_asset_id,
                          h_dist_id,
                          h_period_counter,
                          h_sysdate,
                          h_part_deprn_amount,
                          h_part_ytd,
                          decode(h_source_code, 'B', decode(h_count,0,h_part_cost,h_cost_to_clear),0), --Bug 9142501
                          h_part_deprn_reserve,
                          /* Bug 525654 Modification */
                          h_part_deprn_adjustment_amount,
                          h_part_reval_reserve,
                          h_part_ytd_reval_dep_exp,
                          decode(h_source_code, 'D',h_part_cost,0),
                          h_source_code,
                          h_part_bonus_deprn_amount,
                          h_part_bonus_ytd,
                          h_part_bonus_deprn_reserve,
                          h_part_bonus_deprn_adj_amount,
                          h_part_impairment_amount,
                          h_part_ytd_impairment,
                          h_part_impairment_reserve,
                          h_part_reval_amortization,
                          h_part_reval_deprn_expense,
                          h_part_capital_adjustment,
                          h_part_general_fund);

        end if;  -- end mrc

      END LOOP;

      if (G_release = 11 OR X_source_flag = FALSE ) then -- Bug# 8731454
         CLOSE C1_11;
      else
         CLOSE C1;
      end if;

      return (TRUE);

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
          FA_SRVR_MSG.add_message(
                    CALLING_FN => 'FA_INS_DETAIL_PKG.fadpdtl',
                    NAME       => h_msg_name,  p_log_level_rec => p_log_level_rec);
        return (FALSE);

       WHEN ERROR_FOUND THEN
          FA_SRVR_MSG.add_message(
                       CALLING_FN  => 'FA_INS_DETAIL_PKG.fadpdtl',  p_log_level_rec => p_log_level_rec);

          if (G_release = 11 OR X_source_flag = FALSE) then -- Bug# 8731454
             close C1_11;
          else
             close C1;
          end if;

          return (FALSE);

       WHEN OTHERS THEN
          FA_SRVR_MSG.ADD_SQL_ERROR(
                        CALLING_FN => 'FA_INS_DETAIL.fadpdtl', p_log_level_rec => p_log_level_rec);

          if (G_release = 11 OR X_source_flag = FALSE) then -- Bug# 8731454
             close C1_11;
          else
             close C1;
          end if;

          return(FALSE);
  END fadpdtl;

END FA_INS_DETAIL_PKG;

/
