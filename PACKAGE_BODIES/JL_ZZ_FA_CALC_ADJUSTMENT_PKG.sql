--------------------------------------------------------
--  DDL for Package Body JL_ZZ_FA_CALC_ADJUSTMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_FA_CALC_ADJUSTMENT_PKG" AS
/* $Header: jlzzfcab.pls 115.4 2002/11/06 00:09:30 cleyvaol ship $ */
----------------------------------------------------------------------------
-- FUNCTION                                                              --
--   Calc_adjustments                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to calculate adjustments in view                   --
--   JL_ZZ_FA_ADJ_SUMMARY_V.                                              --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   p_book_type_code - Book Type Code                                    --
--   p_period_counter - Period Counter                                    --
--   p_asset_id    - Asset ID                                             --
--   P_adjustment_type - Adjustment Type                                  --
--   P_mode -  Mode                                                       --
--                                                                        --
-- HISTORY:                                                               --
--    02/19/99     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

FUNCTION calc_adjustments
          ( p_book_type_code         VARCHAR2,
            p_period_counter            NUMBER,
            p_asset_id                       NUMBER,
            p_adjustment_type          VARCHAR2,
            p_mode                           VARCHAR2
          )
  RETURN NUMBER AS
    x_dr_amount  NUMBER := 0;
    x_cr_amount  NUMBER := 0;

  BEGIN

      SELECT   nvl (sum (decode (aj.debit_credit_flag, 'DR', aj.adjustment_amount, 0)), 0),
                        nvl (sum (decode (aj.debit_credit_flag, 'CR', aj.adjustment_amount, 0)), 0)
      INTO        x_dr_amount,
                        x_cr_amount
      FROM      fa_adjustments   aj
      WHERE   aj.asset_id                           = p_asset_id
            AND   aj.book_type_code             = p_book_type_code
            AND   aj.period_counter_created = p_period_counter
            AND   aj.adjustment_type             = p_adjustment_type
      GROUP BY aj.asset_id,
                       aj.book_type_code,
                       aj.period_counter_created,
                       aj.adjustment_type ;

    IF (p_mode = 'DR') THEN
      RETURN (x_dr_amount);
     ELSIF (p_mode = 'CR') THEN
      RETURN (x_cr_amount);
     ELSIF (p_mode = 'NET') THEN
      RETURN (x_dr_amount - x_cr_amount);
    END IF;

     EXCEPTION
       WHEN others THEN
          RETURN (0);

END calc_adjustments;

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   calc_corp_book_cost                                                  --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to calculate                                       --
--   JL_ZZ_FA_ADJ_SUMMARY_V.                                              --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   p_book_type_code - Distribution Source Book                          --
--   p_period_counter - Period Counter                                    --
--   p_asset_id    - Asset ID                                             --
--   P_mode -                                                             --
--                                                                        --
-- HISTORY:                                                               --
--    12/09/99     Santosh Vaze   Created                                 --
----------------------------------------------------------------------------

FUNCTION calc_corp_book_cost
          ( p_book_type_code         VARCHAR2,
            p_period_counter            NUMBER,
            p_asset_id                       NUMBER,
            p_mode                   VARCHAR2
          )
  RETURN NUMBER AS
    x_cost           NUMBER := 0;

  BEGIN

    IF (p_mode = 'CC') THEN
      SELECT bkc.cost
      INTO   x_cost
      FROM   fa_deprn_periods dpc,
             fa_book_controls bcc,
             fa_books bkc
      WHERE  bcc.book_type_code = p_book_type_code
      AND    dpc.book_type_code = bcc.book_type_code
      AND    dpc.period_counter <= bcc.last_period_counter
      AND    dpc.period_counter = p_period_counter
      AND    bkc.asset_id = p_asset_id
      AND    bkc.book_type_code = dpc.book_type_code
      AND    bkc.date_effective <= nvl (dpc.period_close_date, sysdate)
      AND    nvl (dpc.period_close_date, sysdate) <= nvl (bkc.date_ineffective, sysdate);

      RETURN (x_cost);
    END IF;

    IF (p_mode = 'CO') THEN
      SELECT bkc.cost
      INTO   x_cost
      FROM   fa_deprn_periods dpc,
             fa_book_controls bcc,
             fa_books bkc
      WHERE  bcc.book_type_code = p_book_type_code
      AND    dpc.book_type_code = bcc.book_type_code
      AND    dpc.period_counter = bcc.last_period_counter
      AND    bkc.asset_id = p_asset_id
      AND    bkc.book_type_code = dpc.book_type_code
      AND    bkc.date_effective <= nvl (dpc.period_close_date, sysdate)
      AND    nvl (dpc.period_close_date, sysdate) <= nvl (bkc.date_ineffective, sysdate);

      RETURN (x_cost);
    END IF;

    IF (p_mode = 'OO') THEN
      SELECT bkc.cost
      INTO   x_cost
      FROM   fa_deprn_periods dpc,
             fa_book_controls bcc,
             fa_books bkc
      WHERE  bcc.book_type_code = p_book_type_code
      AND    dpc.book_type_code = bcc.book_type_code
      AND    dpc.period_counter = bcc.last_period_counter + 1
      AND    bkc.asset_id = p_asset_id
      AND    bkc.book_type_code = dpc.book_type_code
      AND    bkc.date_effective <= nvl (dpc.period_close_date, sysdate)
      AND    nvl (dpc.period_close_date, sysdate) <= nvl (bkc.date_ineffective, sysdate);

      RETURN (x_cost);
    END IF;

  EXCEPTION
       WHEN others THEN
          RETURN (0);

END calc_corp_book_cost;

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   calc_corp_deprn_reserve                                              --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to calculate                                       --
--   JL_ZZ_FA_ADJ_SUMMARY_V.                                              --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   p_book_type_code - Distribution Source Book                          --
--   p_period_counter - Period Counter                                    --
--   p_asset_id    - Asset ID                                             --
--   P_mode -                                                             --
--                                                                        --
-- HISTORY:                                                               --
--    12/09/99     Santosh Vaze   Created                                 --
----------------------------------------------------------------------------

FUNCTION calc_corp_deprn_reserve
          ( p_book_type_code         VARCHAR2,
            p_period_counter         NUMBER,
            p_asset_id               NUMBER,
            p_mode                   VARCHAR2
          )
  RETURN NUMBER AS
    x_deprn_reserve  NUMBER := 0;

  BEGIN

    IF (p_mode = 'CC') THEN
      SELECT dsc.deprn_reserve
      INTO   x_deprn_reserve
      FROM   fa_deprn_summary dsc,
             fa_deprn_periods dpc,
             fa_book_controls bcc,
             fa_books bkc
      WHERE  bcc.book_type_code = p_book_type_code
      AND    dpc.book_type_code = bcc.book_type_code
      AND    dpc.period_counter <= bcc.last_period_counter
      AND    dpc.period_counter = p_period_counter
      AND    bkc.asset_id = p_asset_id
      AND    bkc.book_type_code = dpc.book_type_code
      AND    bkc.date_effective <= nvl (dpc.period_close_date, sysdate)
      AND    nvl (dpc.period_close_date, sysdate) <= nvl (bkc.date_ineffective, sysdate)
      AND    dsc.asset_id = p_asset_id
      AND    dsc.book_type_code = dpc.book_type_code
      AND    dsc.period_counter = dpc.period_counter;

      RETURN (x_deprn_reserve);
    END IF;

    IF (p_mode = 'CO') THEN
      SELECT dsc.deprn_reserve
      INTO   x_deprn_reserve
      FROM   fa_deprn_summary dsc,
             fa_deprn_periods dpc,
             fa_book_controls bcc,
             fa_books bkc
      WHERE  bcc.book_type_code = p_book_type_code
      AND    dpc.book_type_code = bcc.book_type_code
      AND    dpc.period_counter = bcc.last_period_counter
      AND    bkc.asset_id = p_asset_id
      AND    bkc.book_type_code = dpc.book_type_code
      AND    bkc.date_effective <= nvl (dpc.period_close_date, sysdate)
      AND    nvl (dpc.period_close_date, sysdate) <= nvl (bkc.date_ineffective, sysdate)
      AND    dsc.asset_id = p_asset_id
      AND    dsc.book_type_code = dpc.book_type_code
      AND    dsc.period_counter = dpc.period_counter;

      RETURN (x_deprn_reserve);
    END IF;

    IF (p_mode = 'OO') THEN
      SELECT dsc.deprn_reserve - jl_zz_fa_calc_adjustment_pkg.calc_adjustments (bcc.book_type_code, dpc.period_counter, p_asset_id, 'RESERVE', 'NET' )
      INTO   x_deprn_reserve
      FROM   fa_deprn_summary dsc,
             fa_deprn_periods dpc,
             fa_book_controls bcc,
             fa_books bkc
      WHERE  bcc.book_type_code = p_book_type_code
      AND    dpc.book_type_code = bcc.book_type_code
      AND    dpc.period_counter = bcc.last_period_counter + 1
      AND    bkc.asset_id = p_asset_id
      AND    bkc.book_type_code = dpc.book_type_code
      AND    bkc.date_effective <= nvl (dpc.period_close_date, sysdate)
      AND    nvl (dpc.period_close_date, sysdate) <= nvl (bkc.date_ineffective, sysdate)
      AND    dsc.asset_id = p_asset_id
      AND    dsc.book_type_code = dpc.book_type_code
      AND    dsc.period_counter = bcc.last_period_counter;

      RETURN (x_deprn_reserve);
    END IF;

  EXCEPTION
       WHEN others THEN
          RETURN (0);

END calc_corp_deprn_reserve;

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   calc_corp_ytd_deprn                                                  --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to calculate                                       --
--   JL_ZZ_FA_ADJ_SUMMARY_V.                                              --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   p_book_type_code - Distribution Source Book                          --
--   p_period_counter - Period Counter                                    --
--   p_asset_id    - Asset ID                                             --
--   P_mode -                                                             --
--                                                                        --
-- HISTORY:                                                               --
--    12/09/99     Santosh Vaze   Created                                 --
----------------------------------------------------------------------------

FUNCTION calc_corp_ytd_deprn
          ( p_book_type_code         VARCHAR2,
            p_period_counter         NUMBER,
            p_asset_id               NUMBER,
            p_mode                   VARCHAR2
          )
  RETURN NUMBER AS
    x_ytd_deprn      NUMBER := 0;

  BEGIN

    IF (p_mode = 'CC') THEN
      SELECT dsc.ytd_deprn
      INTO   x_ytd_deprn
      FROM   fa_deprn_summary dsc,
             fa_deprn_periods dpc,
             fa_book_controls bcc,
             fa_books bkc
      WHERE  bcc.book_type_code = p_book_type_code
      AND    dpc.book_type_code = bcc.book_type_code
      AND    dpc.period_counter <= bcc.last_period_counter
      AND    dpc.period_counter = p_period_counter
      AND    bkc.asset_id = p_asset_id
      AND    bkc.book_type_code = dpc.book_type_code
      AND    bkc.date_effective <= nvl (dpc.period_close_date, sysdate)
      AND    nvl (dpc.period_close_date, sysdate) <= nvl (bkc.date_ineffective, sysdate)
      AND    dsc.asset_id = p_asset_id
      AND    dsc.book_type_code = dpc.book_type_code
      AND    dsc.period_counter = dpc.period_counter;

      RETURN (x_ytd_deprn);
    END IF;

    IF (p_mode = 'CO') THEN
      SELECT dsc.ytd_deprn
      INTO   x_ytd_deprn
      FROM   fa_deprn_summary dsc,
             fa_deprn_periods dpc,
             fa_book_controls bcc,
             fa_books bkc
      WHERE  bcc.book_type_code = p_book_type_code
      AND    dpc.book_type_code = bcc.book_type_code
      AND    dpc.period_counter = bcc.last_period_counter
      AND    bkc.asset_id = p_asset_id
      AND    bkc.book_type_code = dpc.book_type_code
      AND    bkc.date_effective <= nvl (dpc.period_close_date, sysdate)
      AND    nvl (dpc.period_close_date, sysdate) <= nvl (bkc.date_ineffective, sysdate)
      AND    dsc.asset_id = p_asset_id
      AND    dsc.book_type_code = dpc.book_type_code
      AND    dsc.period_counter = dpc.period_counter;

      RETURN (x_ytd_deprn);
    END IF;

    IF (p_mode = 'OO') THEN
      SELECT dsc.ytd_deprn + jl_zz_fa_calc_adjustment_pkg.calc_adjustments (bcc.book_type_code, dpc.period_counter, p_asset_id, 'EXPENSE', 'NET' )
      INTO   x_ytd_deprn
      FROM   fa_deprn_summary dsc,
             fa_deprn_periods dpc,
             fa_book_controls bcc,
             fa_books bkc
      WHERE  bcc.book_type_code = p_book_type_code
      AND    dpc.book_type_code = bcc.book_type_code
      AND    dpc.period_counter = bcc.last_period_counter + 1
      AND    bkc.asset_id = p_asset_id
      AND    bkc.book_type_code = dpc.book_type_code
      AND    bkc.date_effective <= nvl (dpc.period_close_date, sysdate)
      AND    nvl (dpc.period_close_date, sysdate) <= nvl (bkc.date_ineffective, sysdate)
      AND    dsc.asset_id = p_asset_id
      AND    dsc.book_type_code = dpc.book_type_code
      AND    dsc.period_counter = bcc.last_period_counter;

      RETURN (x_ytd_deprn);
    END IF;


  EXCEPTION
       WHEN others THEN
          RETURN (0);

END calc_corp_ytd_deprn;

END jl_zz_fa_calc_adjustment_pkg;

/
