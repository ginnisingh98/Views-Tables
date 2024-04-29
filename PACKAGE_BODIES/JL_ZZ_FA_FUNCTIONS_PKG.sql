--------------------------------------------------------
--  DDL for Package Body JL_ZZ_FA_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_FA_FUNCTIONS_PKG" AS
/* $Header: jlzzfafb.pls 120.11 2006/09/20 17:13:59 abuissa ship $ */

/* ======================================================================*
 | FND Logging infrastructure                                           |
 * ======================================================================*/
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'JL_ZZ_FA_FUNCTIONS_PKG';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(80) := 'JL.PLSQL.JL_ZZ_FA_FUNCTIONS_PKG.';


TYPE temp_plsql_table is table of JL_AR_FA_EXHIBIT_REPORT%ROWTYPE index by binary_integer;
report_table temp_plsql_table;

/*+=========================================================================+
  |  PUBLIC FUNCTION                                                        |
  |    middle_month                                                         |
  |        p_add_month_number        Month in which the Addition took place.|
  |        p_ret_month_number        Month in which the Retirement took     |
  |                                  place.                                 |
  |        p_include_dpis            Include DPIS month in the periods of   |
  |                                  use calculation.                       |
  |        p_include_ret             Include retirement month in the periods|
  |                                  of use calculation.                    |
  |                                                                         |
  |  NOTES                                                                  |
  |    Middle Month Function:  Assets added or sold in the current FY are   |
  |  adjusted until the half of the period of use.  The half of the period  |
  |  of use is obtained from the Middle Month Tables.                       |
  |                                                                         |
  |    08-Nov-00   S. Vaze      This procedure is now written due to changes|
  |                             in the requirement # 1561112.               |
  |                             The p_add_month_number 0 in addition        |
  |                             signifies Addition in the previous year.    |
  |                             The p_ret_month_number 13 in retirement     |
  |                             signifies Asset is not retired yet.         |
  +=========================================================================+*/
  FUNCTION middle_month (p_add_month_number IN NUMBER
                       , p_ret_month_number IN NUMBER
                       , p_include_dpis     IN VARCHAR2
                       , p_include_ret      IN VARCHAR2) RETURN NUMBER IS

    l_middle_month NUMBER;
    l_mou          NUMBER;
    l_add_month_number   NUMBER;
    l_ret_month_number   NUMBER;

  BEGIN

    IF (p_ret_month_number < p_add_month_number) THEN
       l_middle_month := -1;
       RETURN (l_middle_month);
    END IF;
    IF (p_ret_month_number = p_add_month_number) THEN
       l_middle_month := p_add_month_number;
       RETURN (l_middle_month);
    END IF;

    l_mou := periods_of_use (p_add_month_number
                           , p_ret_month_number
                           , p_include_dpis
                           , p_include_ret);

    l_add_month_number := p_add_month_number;
    l_ret_month_number := p_ret_month_number;
--
--  OPTION  :  Include DPIS month and include retirement month
--  In this option all the previous year additions are treated as if they
--  are done in the first month.
--
    IF p_include_dpis = 'Y' and p_include_ret = 'Y'
    THEN
       IF p_add_month_number = 0
       THEN
          l_add_month_number := 1;
       END IF;

       IF p_add_month_number = 12 and p_ret_month_number = 13
       THEN
          l_middle_month := l_add_month_number;
          RETURN (l_middle_month);
       END IF;

       l_middle_month := trunc(l_mou/2) + l_add_month_number - 1;
    END IF;

--
--  OPTION  :  Include DPIS month and exclude retirement month
--  In this option all the previous year additions are treated as if they
--  are done in the first month.
--
    IF p_include_dpis = 'Y' and p_include_ret = 'N'
    THEN
       IF l_mou = 1
       THEN
          l_middle_month := trunc(l_mou/2) + l_add_month_number;
          RETURN (l_middle_month);
       END IF;

       IF p_add_month_number = 0
       THEN
          l_add_month_number := 1;
       END IF;

       l_middle_month := trunc(l_mou/2) + l_add_month_number - 1;
    END IF;

--
--  OPTION  :  Exclude DPIS month and include retirement month
--
    IF p_include_dpis = 'N' and p_include_ret = 'Y'
    THEN
       l_middle_month := trunc(l_mou/2) + l_add_month_number;
    END IF;

--
--  OPTION  :  Exclude DPIS month and exclude retirement month
--
    IF p_include_dpis = 'N' and p_include_ret = 'N'
    THEN
       l_middle_month := trunc(l_mou/2) + l_add_month_number;
    END IF;

    RETURN (l_middle_month);

  END middle_month;

/*+=========================================================================+
  |  PUBLIC FUNCTION                                                        |
  |    periods_of_use                                                       |
  |        p_add_month_number        Month in which the Addition took place.|
  |        p_ret_month_number        Month in which the Retirement took     |
  |                                  place.                                 |
  |        p_include_dpis            Include DPIS month in the periods of   |
  |                                  use calculation.                       |
  |        p_include_ret             Include retirement month in the periods|
  |                                  of use calculation.                    |
  |                                                                         |
  |  NOTES                                                                  |
  |     Periods of Use Function. It gets the months of use of the asset     |
  |     for the different criterias such as consider Date places in         |
  |     service or prorrate date, and including the month of the retirement |
  |     or not.                                                             |
  |    04-Dec-00   C. Leyva     New function to get the Months of Use       |
  |                             of the asset.                               |
  +=========================================================================+*/
  FUNCTION periods_of_use (p_add_month_number IN NUMBER
                         , p_ret_month_number IN NUMBER
                         , p_include_dpis     IN VARCHAR2
                         , p_include_ret      IN VARCHAR2) RETURN NUMBER IS

    l_mou                NUMBER := null;
    l_add_month_number   NUMBER;
    l_ret_month_number   NUMBER;

  BEGIN

    l_add_month_number := p_add_month_number;
    l_ret_month_number := p_ret_month_number;
--
--  OPTION  :  Include DPIS month and retirement month
--  In this option all the previous year additions are treated as if they
--  are done in the first month.
--  All the unretired assets are treated as if they are retired in the
--  last month.
--
    IF p_include_dpis = 'Y' and p_include_ret = 'Y'
    THEN
       IF p_add_month_number = 0
       THEN
          l_add_month_number := 1;
       END IF;

       IF p_ret_month_number = 13
       THEN
          l_ret_month_number := 12;
       END IF;

       l_mou := l_ret_month_number - l_add_month_number + 1;
    END IF;

--
--  OPTION  :  Include DPIS month and exclude retirement month
--
    IF p_include_dpis = 'Y' and p_include_ret = 'N'
    THEN
       IF p_add_month_number = 0
       THEN
          l_add_month_number := 1;
       END IF;

       l_mou := l_ret_month_number - l_add_month_number;
    END IF;

--
--  OPTION  :  Exclude DPIS month and include retirement month
--
    IF p_include_dpis = 'N' and p_include_ret = 'Y'
    THEN
       IF p_ret_month_number = 13
       THEN
          l_ret_month_number := 12;
       END IF;

       l_mou := l_ret_month_number - l_add_month_number;
    END IF;

--
--  OPTION  :  Exclude DPIS month and exclude retirement month
--
    IF p_include_dpis = 'N' and p_include_ret = 'N'
    THEN
       l_mou := l_ret_month_number - l_add_month_number - 1;
    END IF;

    RETURN (l_mou);
END periods_of_use;


/*+=========================================================================+
  |  PUBLIC FUNCTION                                                        |
  |    asset_cost                                                           |
  |        p_book_type_code IN  Depreciation Book                           |
  |        p_asset_id       IN  Asset                                       |
  |        p_period_counter IN  Period                                      |
  |        p_asset_cost     OUT Asset cost for this particular period and   |
  |                             depreciation book.                          |
  |      Returns                                                            |
  |        Number           0   Normal completion                           |
  |                         1   Abnormal completion                         |
  |                                                                         |
  |  NOTES                                                                  |
  |      Given an asset, a depreciation book and a depreciation period,     |
  |      returns the asset's cost at the end of the period for that         |
  |      depreciation book.                                                 |
  |                                                                         |
  |                                                                         |
  +=========================================================================+*/
  FUNCTION asset_cost (p_book_type_code IN VARCHAR2
                     , p_asset_id       IN NUMBER
                     , p_period_counter IN NUMBER
                     , p_asset_cost     IN OUT NOCOPY NUMBER
                     , p_mrcsobtype     IN VARCHAR2 DEFAULT 'P')
  RETURN NUMBER IS

    normal CONSTANT NUMBER := 0;
    error  CONSTANT NUMBER := 1;
    l_transaction_header_id   NUMBER;
    l_period_counter          NUMBER;

  BEGIN

    l_period_counter := p_period_counter;
    BEGIN
    ------------------------------------------------------------
    -- The latest transaction performed on an asset in a      --
    -- particular period is the one that defines the cost at  --
    -- the end of that period.                                --
    -- Bug 3101070: Due to mrc changes, this function is      --
    -- completely re-written. View jl_zz_fa_books_periods_v   --
    -- has been replaced with the source code of the view.    --
    ------------------------------------------------------------
       SELECT max(th.transaction_header_id) ,
              max(dp.period_counter)
         INTO l_transaction_header_id,
              l_period_counter
         FROM fa_books fb ,
              fa_calendar_periods cp ,
              fa_deprn_periods dp ,
              fa_transaction_headers th ,
              fa_asset_history ah ,
              fa_additions ad ,
              fa_book_controls bc
        WHERE ah.asset_id = ad.asset_id
          AND fb.book_type_code = bc.book_type_code
          AND fb.asset_id = ad.asset_id
          AND fb.transaction_header_id_in = th.transaction_header_id
          AND dp.book_type_code = bc.book_type_code
          AND cp.calendar_type = bc.deprn_calendar
          AND th.asset_id = ad.asset_id
          AND th.book_type_code= dp.book_type_code
          AND th.transaction_header_id >= ah.transaction_header_id_in
          AND th.transaction_header_id < nvl(ah.transaction_header_id_out, th.transaction_header_id + 1)
          AND th.transaction_date_entered between cp.start_date and cp.end_date
          AND th.date_effective between dp.period_open_date and nvl(dp.period_close_date,th.date_effective)
          AND bc.book_type_code = p_book_type_code
          AND ad.asset_id = p_asset_id
          AND dp.period_counter <= p_period_counter;
    END;

    IF p_mrcsobtype = 'R' THEN
       BEGIN
          SELECT fb.cost
            INTO p_asset_cost
            FROM fa_books_mrc_v fb ,
                 fa_calendar_periods cp ,
                 fa_deprn_periods_mrc_v dp ,
                 fa_transaction_headers th ,
                 fa_asset_history ah ,
                 fa_additions ad ,
                 fa_book_controls_mrc_v bc
           WHERE ah.asset_id = ad.asset_id
             AND fb.book_type_code = bc.book_type_code
             AND fb.asset_id = ad.asset_id
             AND fb.transaction_header_id_in = th.transaction_header_id
             AND dp.book_type_code = bc.book_type_code
             AND cp.calendar_type = bc.deprn_calendar
             AND th.asset_id = ad.asset_id
             AND th.book_type_code= dp.book_type_code
             AND th.transaction_header_id >= ah.transaction_header_id_in
             AND th.transaction_header_id < nvl(ah.transaction_header_id_out, th.transaction_header_id + 1)
             AND th.transaction_date_entered between cp.start_date and cp.end_date
             AND th.date_effective between dp.period_open_date and nvl(dp.period_close_date,th.date_effective)
             AND bc.book_type_code = p_book_type_code
             AND ad.asset_id = p_asset_id
             AND dp.period_counter = l_period_counter
             AND th.transaction_header_id = l_transaction_header_id;
       END;
    ELSE
       BEGIN
          SELECT fb.cost
            INTO p_asset_cost
            FROM fa_books fb ,
                 fa_calendar_periods cp ,
                 fa_deprn_periods dp ,
                 fa_transaction_headers th ,
                 fa_asset_history ah ,
                 fa_additions ad ,
                 fa_book_controls bc
           WHERE ah.asset_id = ad.asset_id
             AND fb.book_type_code = bc.book_type_code
             AND fb.asset_id = ad.asset_id
             AND fb.transaction_header_id_in = th.transaction_header_id
             AND dp.book_type_code = bc.book_type_code
             AND cp.calendar_type = bc.deprn_calendar
             AND th.asset_id = ad.asset_id
             AND th.book_type_code= dp.book_type_code
             AND th.transaction_header_id >= ah.transaction_header_id_in
             AND th.transaction_header_id < nvl(ah.transaction_header_id_out, th.transaction_header_id + 1)
             AND th.transaction_date_entered between cp.start_date and cp.end_date
             AND th.date_effective between dp.period_open_date and nvl(dp.period_close_date,th.date_effective)
             AND bc.book_type_code = p_book_type_code
             AND ad.asset_id = p_asset_id
             AND dp.period_counter = l_period_counter
             AND th.transaction_header_id = l_transaction_header_id;
       END;
    END IF;

    RETURN (normal);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN (error);

  END asset_cost;

/*+=========================================================================+
  |  PUBLIC FUNCTION                                                        |
  |    asset_desc                                                           |
  |        p_asset_number   IN  Asset                                       |
  |                                                                         |
  |      Returns                                                            |
  |        p_asset_desc         Asset Description                           |
  |                                                                         |
  |  NOTES                                                                  |
  |      Given an asset, returns the asset's description.                   |
  |                                                                         |
  |                                                                         |
  +=========================================================================+*/
  FUNCTION asset_desc (p_asset_number   IN VARCHAR2)
  RETURN VARCHAR2 IS

     p_asset_desc  fa_additions.description%TYPE;

  BEGIN

    BEGIN
    ------------------------------------------------------------
    -- The following sql will return the description of the   --
    -- given asset.                                           --
    ------------------------------------------------------------
      SELECT faa.description
        INTO p_asset_desc
        FROM fa_additions faa
        WHERE faa.asset_number = p_asset_number;
    END;

    RETURN (p_asset_desc);

  EXCEPTION
    WHEN OTHERS THEN
      RETURN (null);

  END asset_desc;

/*+=========================================================================+
  |  PRIVATE PROCEDURE                                                      |
  |    Procedure:                                                           |
  |                                                                         |
  |    Get the revaluation amount for a given asset and a period            |
  |                                                                         |
  +=========================================================================+*/
    PROCEDURE get_adjust_amount    (p_book_type_code   IN VARCHAR2
                                  , p_asset_id         IN NUMBER
                                  , p_period_counter   IN NUMBER
                                  , p_transaction_type IN VARCHAR2
                                  , p_adjustment_type  IN VARCHAR2
                                  , p_adjustment       IN OUT NOCOPY NUMBER
                                  , p_mrcsobtype       IN VARCHAR2) IS
    l_source_type_code VARCHAR2(30);

    BEGIN
      IF p_transaction_type in ('FULL RETIREMENT', 'PARTIAL RETIREMENT', 'REINSTATEMENT') THEN
         l_source_type_code := 'RETIREMENT';
      ELSIF p_transaction_type = 'ADDITION' THEN
         l_source_type_code := 'ADDITION';
      ELSIF p_transaction_type = 'CIP ADDITION' THEN
         l_source_type_code := 'CIP ADDITION';
      ELSIF p_transaction_type = 'ADJUSTMENT' THEN
         IF p_adjustment_type IN ('COST', 'CIP COST') THEN
            l_source_type_code := 'ADJUSTMENT';
         ELSIF p_adjustment_type IN ('EXPENSE') THEN
            l_source_type_code := 'DEPRECIATION';
         END IF;
      ELSIF p_transaction_type = 'CIP ADJUSTMENT' THEN
         l_source_type_code := 'CIP ADJUSTMENT';
      ELSIF p_transaction_type = 'RECLASS' THEN
         l_source_type_code := 'RECLASS';
      ELSIF p_transaction_type = 'CIP RECLASS' THEN
         l_source_type_code := 'CIP RECLASS';
      END IF;

      IF p_mrcsobtype = 'R' THEN
         IF p_transaction_type in ('RECLASS','CIP RECLASS') THEN
            BEGIN
              SELECT   nvl(sum(decode(debit_credit_flag,'DR',adjustment_amount,0)),0)
              INTO     p_adjustment
              FROM     fa_adjustments_mrc_v
              WHERE    book_type_code         = p_book_type_code
                AND    asset_id               = p_asset_id
                AND    period_counter_created = p_period_counter
                AND    source_type_code       = l_source_type_code
                AND    adjustment_type        = p_adjustment_type;
            EXCEPTION
              WHEN OTHERS THEN
                p_adjustment := 0;
            END;
         ELSE
            BEGIN
              SELECT   nvl(sum(decode(debit_credit_flag,'DR',adjustment_amount,-1 * adjustment_amount)),0)
              INTO     p_adjustment
              FROM     fa_adjustments_mrc_v
              WHERE    book_type_code         = p_book_type_code
                AND    asset_id               = p_asset_id
                AND    period_counter_created = p_period_counter
                AND    source_type_code       = l_source_type_code
                AND    adjustment_type        = p_adjustment_type;
            EXCEPTION
              WHEN OTHERS THEN
                p_adjustment := 0;
            END;
         END IF;
      ELSE
         IF p_transaction_type in ('RECLASS','CIP RECLASS') THEN
            BEGIN
              SELECT   nvl(sum(decode(debit_credit_flag,'DR',adjustment_amount,0)),0)
              INTO     p_adjustment
              FROM     fa_adjustments
              WHERE    book_type_code         = p_book_type_code
                AND    asset_id               = p_asset_id
                AND    period_counter_created = p_period_counter
                AND    source_type_code       = l_source_type_code
                AND    adjustment_type        = p_adjustment_type;
            EXCEPTION
              WHEN OTHERS THEN
                p_adjustment := 0;
            END;
         ELSE
            BEGIN
              SELECT   nvl(sum(decode(debit_credit_flag,'DR',adjustment_amount,-1 * adjustment_amount)),0)
              INTO     p_adjustment
              FROM     fa_adjustments
              WHERE    book_type_code         = p_book_type_code
                AND    asset_id               = p_asset_id
                AND    period_counter_created = p_period_counter
                AND    source_type_code       = l_source_type_code
                AND    adjustment_type        = p_adjustment_type;
            EXCEPTION
              WHEN OTHERS THEN
                p_adjustment := 0;
            END;
         END IF;
      END IF;

    END get_adjust_amount;

/*+=========================================================================+
  |  PRIVATE PROCEDURE                                                      |
  |    Procedure:                                                           |
  |                                                                         |
  |    Get the historical info at the begin of the reporting period for a   |
  |    given asset                                                          |
  |                                                                         |
  +=========================================================================+*/
    PROCEDURE get_asset_info_beg_period_mrc ( p_hist_book_type_code IN VARCHAR2
                                              , p_asset_id       IN NUMBER
                                              , p_period_counter_from IN NUMBER
                                              , p_period_counter_to IN NUMBER
                                              , p_historical_cost_begin_period IN OUT NOCOPY NUMBER
                                              , p_accum_depr_begin_period IN OUT NOCOPY NUMBER) IS

    BEGIN
      BEGIN
        SELECT   nvl(bk.cost,0)
        INTO     p_historical_cost_begin_period
        FROM     fa_books_mrc_v bk,
                 fa_deprn_periods_mrc_v dp
        WHERE    bk.book_type_code         = p_hist_book_type_code
          AND    bk.asset_id               = p_asset_id
          AND    bk.book_type_code         = dp.book_type_code
          AND    dp.period_open_date between bk.date_effective and nvl(bk.date_ineffective,dp.period_open_date)
          AND    dp.period_counter         = p_period_counter_from;
      EXCEPTION
        WHEN OTHERS THEN
             p_historical_cost_begin_period := 0;
      END;

      BEGIN
         SELECT NVL(a.deprn_reserve - a.ytd_deprn,0)
         INTO p_accum_depr_begin_period
         FROM fa_deprn_summary_mrc_v a
         WHERE a.book_type_code     = p_hist_book_type_code
           AND a.asset_id           = p_asset_id
           AND a.period_counter between p_period_counter_from AND p_period_counter_to
           AND a.deprn_source_code  = 'BOOKS';
      EXCEPTION
         WHEN OTHERS THEN
              p_accum_depr_begin_period := 0;
      END;

      -- Bug 3128957:
      --
      IF p_accum_depr_begin_period = 0 THEN
         BEGIN
            SELECT NVL(a.deprn_reserve,0)
              INTO p_accum_depr_begin_period
              FROM fa_deprn_summary_mrc_v a
             WHERE a.book_type_code     = p_hist_book_type_code
               AND a.asset_id           = p_asset_id
               AND a.period_counter in (SELECT max(b.period_counter)
                                          FROM fa_deprn_summary_mrc_v b
                                         WHERE b.book_type_code     = p_hist_book_type_code
                                           AND b.asset_id           = p_asset_id
                                           AND b.period_counter    <= p_period_counter_from - 1);
         EXCEPTION
            WHEN OTHERS THEN
               p_accum_depr_begin_period := 0;
         END;
      END IF;

    END get_asset_info_beg_period_mrc;


/*+=========================================================================+
  |  PRIVATE PROCEDURE                                                      |
  |    Procedure:                                                           |
  |                                                                         |
  |    Get the historical and adjusted cost at the end of the reporting     |
  |    period for a given asset                                             |
  |                                                                         |
  +=========================================================================+*/
    PROCEDURE get_asset_info_end_period_mrc    ( p_hist_book_type_code        IN VARCHAR2
                                           , p_adj_book_type_code         IN VARCHAR2
                                           , p_asset_id                   IN NUMBER
                                           , p_period_counter_from        IN NUMBER
                                           , p_period_counter_to          IN NUMBER
                                           , p_historical_cost_end_period IN OUT NOCOPY NUMBER
                                           , p_adjusted_cost_end_period   IN OUT NOCOPY NUMBER
                                           , p_hist_accum_depr_end_period IN OUT NOCOPY NUMBER
                                           , p_adj_accum_depr_end_period  IN OUT NOCOPY NUMBER
                                           , p_depr_rpt_period            IN OUT NOCOPY NUMBER) IS
    l_depr_rpt_period   number;
    l_api_name           CONSTANT VARCHAR2(30) := 'GET_ASSET_INFO_END_PERIOD_MRC';


    BEGIN
      BEGIN
        SELECT   nvl(bk.cost,0)
        INTO     p_historical_cost_end_period
        FROM     fa_books_mrc_v bk,
                 fa_deprn_periods_mrc_v dp
        WHERE    bk.book_type_code         = p_hist_book_type_code
          AND    bk.asset_id               = p_asset_id
          AND    bk.book_type_code         = dp.book_type_code
          AND    dp.period_close_date between bk.date_effective and nvl(bk.date_ineffective,dp.period_close_date)
          AND    dp.period_counter         = p_period_counter_to;
      EXCEPTION
        WHEN OTHERS THEN
             p_historical_cost_end_period := 0;
      END;

      BEGIN
        SELECT   nvl(bk.cost,0)
        INTO     p_adjusted_cost_end_period
        FROM     fa_books_mrc_v bk,
                 fa_deprn_periods_mrc_v dp
        WHERE    bk.book_type_code         = p_adj_book_type_code
          AND    bk.asset_id               = p_asset_id
          AND    bk.book_type_code         = dp.book_type_code
          AND    dp.period_close_date between bk.date_effective and nvl(bk.date_ineffective,dp.period_close_date)
          AND    dp.period_counter         = p_period_counter_to;
      EXCEPTION
        WHEN OTHERS THEN
             p_adjusted_cost_end_period := 0;
      END;

      -- Bug 3128957:
      --
      BEGIN
         SELECT NVL(a.deprn_reserve,0)
         INTO p_hist_accum_depr_end_period
         FROM fa_deprn_summary_mrc_v a
         WHERE a.book_type_code     = p_hist_book_type_code
           AND a.asset_id           = p_asset_id
           AND a.period_counter in (SELECT max(b.period_counter)
                                      FROM   fa_deprn_summary_mrc_v b
                                      WHERE  b.book_type_code     = p_hist_book_type_code
                                      AND    b.asset_id           = p_asset_id
                                      AND    b.period_counter    <= p_period_counter_to);
      EXCEPTION
         WHEN OTHERS THEN
              p_hist_accum_depr_end_period := 0;
      END;

      BEGIN
         SELECT NVL(a.deprn_reserve,0)
         INTO p_adj_accum_depr_end_period
         FROM fa_deprn_summary_mrc_v a
         WHERE a.book_type_code     = p_adj_book_type_code
           AND a.asset_id           = p_asset_id
           AND a.period_counter in (SELECT max(b.period_counter)
                                      FROM   fa_deprn_summary_mrc_v b
                                      WHERE  b.book_type_code     = p_adj_book_type_code
                                      AND    b.asset_id           = p_asset_id
                                      AND    b.period_counter    <= p_period_counter_to);
      EXCEPTION
         WHEN OTHERS THEN
              p_adj_accum_depr_end_period := 0;
      END;

      -- Bug 3128957: End of changes
      --

      l_depr_rpt_period := 0;
      p_depr_rpt_period := 0;
      BEGIN
         SELECT NVL(a.ytd_deprn,0)
         INTO l_depr_rpt_period
         FROM fa_deprn_summary_mrc_v a
         WHERE a.book_type_code     = p_hist_book_type_code
           AND a.asset_id           = p_asset_id
           AND a.deprn_source_code  = 'BOOKS'
           AND a.period_counter     between  p_period_counter_from and p_period_counter_to;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              l_depr_rpt_period := 0;
         WHEN OTHERS THEN
              l_depr_rpt_period := 0;
      END;

      BEGIN
         SELECT NVL(SUM(NVL(a.deprn_amount,0)),0)
         INTO p_depr_rpt_period
         FROM fa_deprn_summary_mrc_v a
         WHERE a.book_type_code     = p_hist_book_type_code
           AND a.asset_id           = p_asset_id
           AND a.deprn_source_code  = 'DEPRN'
           AND a.period_counter     between  p_period_counter_from and p_period_counter_to;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              p_depr_rpt_period := 0;
         WHEN OTHERS THEN
              p_depr_rpt_period := 0;
      END;
      p_depr_rpt_period := p_depr_rpt_period + l_depr_rpt_period;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'p_depr_rpt_period := '||to_char(p_depr_rpt_period));
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_depr_rpt_period := '||to_char(p_depr_rpt_period));
         FND_FILE.PUT_LINE(FND_FILE.LOG,'p_depr_rpt_period := '||to_char(p_depr_rpt_period));
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_depr_rpt_period := '||to_char(p_depr_rpt_period));
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

  END get_asset_info_end_period_mrc;

/*+=========================================================================+
  |  PRIVATE PROCEDURE                                                      |
  |    Procedure:                                                           |
  |                                                                         |
  |    Get the historical info at the begin of the reporting period for a   |
  |    given asset                                                          |
  |                                                                         |
  +=========================================================================+*/
    PROCEDURE get_asset_info_beg_period  ( p_hist_book_type_code IN VARCHAR2
                                           , p_asset_id       IN NUMBER
                                           , p_period_counter_from IN NUMBER
                                           , p_period_counter_to IN NUMBER
                                           , p_historical_cost_begin_period IN OUT NOCOPY NUMBER
                                           , p_accum_depr_begin_period IN OUT NOCOPY NUMBER) IS

    l_api_name           CONSTANT VARCHAR2(30) := 'GET_ASSET_INFO_BEG_PERIOD';

    BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

      BEGIN
        SELECT   nvl(bk.cost,0)
        INTO     p_historical_cost_begin_period
        FROM     fa_books bk,
                 fa_deprn_periods dp
        WHERE    bk.book_type_code         = p_hist_book_type_code
          AND    bk.asset_id               = p_asset_id
          AND    bk.book_type_code         = dp.book_type_code
          AND    dp.period_open_date between bk.date_effective and nvl(bk.date_ineffective,dp.period_open_date)
          AND    dp.period_counter         = p_period_counter_from;
      EXCEPTION
        WHEN OTHERS THEN
             p_historical_cost_begin_period := 0;
      END;

      BEGIN
         SELECT NVL(a.deprn_reserve - a.ytd_deprn,0)
         INTO p_accum_depr_begin_period
         FROM fa_deprn_summary a
         WHERE a.book_type_code     = p_hist_book_type_code
           AND a.asset_id           = p_asset_id
           AND a.period_counter between p_period_counter_from AND p_period_counter_to
           AND a.deprn_source_code  = 'BOOKS';
       EXCEPTION
         WHEN OTHERS THEN
              p_accum_depr_begin_period := 0;
       END;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'NEW 1: p_accum_depr_beg_period := '||to_char(p_accum_depr_begin_period));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'NEW 1: p_accum_depr_beg_period := '||to_char(p_accum_depr_begin_period));
      END IF;

      -- Bug 3128957:
      --
      IF p_accum_depr_begin_period = 0 THEN
         BEGIN
            SELECT NVL(a.deprn_reserve,0)
              INTO p_accum_depr_begin_period
              FROM fa_deprn_summary a
             WHERE a.book_type_code     = p_hist_book_type_code
               AND a.asset_id           = p_asset_id
               AND a.period_counter in (SELECT max(b.period_counter)
                                          FROM fa_deprn_summary b
                                         WHERE b.book_type_code     = p_hist_book_type_code
                                           AND b.asset_id           = p_asset_id
                                           AND b.period_counter    <= p_period_counter_from - 1);
         EXCEPTION
            WHEN OTHERS THEN
               p_accum_depr_begin_period := 0;
         END;
      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'NEW 1: p_accum_depr_beg_period := '||to_char(p_accum_depr_begin_period));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'NEW 2: p_accum_depr_beg_period := '||to_char(p_accum_depr_begin_period));
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

    END get_asset_info_beg_period;


/*+=========================================================================+
  |  PRIVATE PROCEDURE                                                      |
  |    Procedure:                                                           |
  |                                                                         |
  |    Get the historical and adjusted cost at the end of the reporting     |
  |    period for a given asset                                             |
  |                                                                         |
  +=========================================================================+*/
    PROCEDURE get_asset_info_end_period    ( p_hist_book_type_code        IN VARCHAR2
                                           , p_adj_book_type_code         IN VARCHAR2
                                           , p_asset_id                   IN NUMBER
                                           , p_period_counter_from        IN NUMBER
                                           , p_period_counter_to          IN NUMBER
                                           , p_historical_cost_end_period IN OUT NOCOPY NUMBER
                                           , p_adjusted_cost_end_period   IN OUT NOCOPY NUMBER
                                           , p_hist_accum_depr_end_period IN OUT NOCOPY NUMBER
                                           , p_adj_accum_depr_end_period  IN OUT NOCOPY NUMBER
                                           , p_depr_rpt_period            IN OUT NOCOPY NUMBER) IS
    l_depr_rpt_period   number;
    l_api_name           CONSTANT VARCHAR2(30) := 'GET_ASSET_INFO_END_PERIOD';


    BEGIN
      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

      BEGIN
        SELECT   nvl(bk.cost,0)
        INTO     p_historical_cost_end_period
        FROM     fa_books bk,
                 fa_deprn_periods dp
        WHERE    bk.book_type_code         = p_hist_book_type_code
          AND    bk.asset_id               = p_asset_id
          AND    bk.book_type_code         = dp.book_type_code
          AND    dp.period_close_date between bk.date_effective and nvl(bk.date_ineffective,dp.period_close_date)
          AND    dp.period_counter         = p_period_counter_to;
      EXCEPTION
        WHEN OTHERS THEN
             p_historical_cost_end_period := 0;
      END;

      BEGIN
        SELECT   nvl(bk.cost,0)
        INTO     p_adjusted_cost_end_period
        FROM     fa_books bk,
                 fa_deprn_periods dp
        WHERE    bk.book_type_code         = p_adj_book_type_code
          AND    bk.asset_id               = p_asset_id
          AND    bk.book_type_code         = dp.book_type_code
          AND    dp.period_close_date between bk.date_effective and nvl(bk.date_ineffective,dp.period_close_date)
          AND    dp.period_counter         = p_period_counter_to;
      EXCEPTION
        WHEN OTHERS THEN
             p_adjusted_cost_end_period := 0;
      END;

      -- Bug 3128957:
      --
      BEGIN
         SELECT NVL(a.deprn_reserve,0)
         INTO p_hist_accum_depr_end_period
         FROM fa_deprn_summary a
         WHERE a.book_type_code     = p_hist_book_type_code
           AND a.asset_id           = p_asset_id
           AND a.period_counter in (SELECT max(b.period_counter)
                                      FROM   fa_deprn_summary b
                                      WHERE  b.book_type_code     = p_hist_book_type_code
                                      AND    b.asset_id           = p_asset_id
                                      AND    b.period_counter    <= p_period_counter_to);
      EXCEPTION
         WHEN OTHERS THEN
              p_hist_accum_depr_end_period := 0;
      END;

      BEGIN
         SELECT NVL(a.deprn_reserve,0)
         INTO p_adj_accum_depr_end_period
         FROM fa_deprn_summary a
         WHERE a.book_type_code     = p_adj_book_type_code
           AND a.asset_id           = p_asset_id
           AND a.period_counter in (SELECT max(b.period_counter)
                                      FROM   fa_deprn_summary b
                                      WHERE  b.book_type_code     = p_adj_book_type_code
                                      AND    b.asset_id           = p_asset_id
                                      AND    b.period_counter    <= p_period_counter_to);
      EXCEPTION
         WHEN OTHERS THEN
              p_adj_accum_depr_end_period := 0;
      END;

      -- Bug 3128957: End of changes
      --

      l_depr_rpt_period := 0;
      p_depr_rpt_period := 0;
      BEGIN
         SELECT NVL(a.ytd_deprn,0)
         INTO l_depr_rpt_period
         FROM fa_deprn_summary a
         WHERE a.book_type_code     = p_hist_book_type_code
           AND a.asset_id           = p_asset_id
           AND a.deprn_source_code  = 'BOOKS'
           AND a.period_counter     between  p_period_counter_from and p_period_counter_to;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              l_depr_rpt_period := 0;
         WHEN OTHERS THEN
              l_depr_rpt_period := 0;
      END;

      BEGIN
         SELECT NVL(SUM(NVL(a.deprn_amount,0)),0)
         INTO p_depr_rpt_period
         FROM fa_deprn_summary a
         WHERE a.book_type_code     = p_hist_book_type_code
           AND a.asset_id           = p_asset_id
           AND a.deprn_source_code  = 'DEPRN'
           AND a.period_counter     between  p_period_counter_from and p_period_counter_to;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              p_depr_rpt_period := 0;
         WHEN OTHERS THEN
              p_depr_rpt_period := 0;
      END;
      p_depr_rpt_period := p_depr_rpt_period + l_depr_rpt_period;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'p_depr_rpt_period := '||to_char(p_depr_rpt_period));
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_depr_rpt_period := '||to_char(p_depr_rpt_period));
         FND_FILE.PUT_LINE(FND_FILE.LOG,'p_depr_rpt_period := '||to_char(p_depr_rpt_period));
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_depr_rpt_period := '||to_char(p_depr_rpt_period));
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

  END get_asset_info_end_period;

/*+=========================================================================+
  |  PRIVATE PROCEDURE                                                      |
  |    Procedure:                                                           |
  |                                                                         |
  |    Get the remaining reval coefficient                                  |
  |                                                                         |
  +=========================================================================+*/
    PROCEDURE get_remain_reval_coefficient ( p_adj_book_type_code           IN VARCHAR2
                                           , p_asset_id                     IN NUMBER
                                           , p_date_placed_in_service       IN DATE
                                           , p_period_counter_from          IN NUMBER
                                           , p_period_counter_to            IN NUMBER
                                           , p_remain_reval_coefficient     IN OUT NOCOPY NUMBER) IS
    l_category_id  NUMBER;
    l_price_index  NUMBER;
    l_reval_date   DATE;
    l_index_value_from  NUMBER;
    l_index_value_to    NUMBER;
    BEGIN
      BEGIN
        SELECT ah.category_id
        INTO   l_category_id
        FROM   fa_asset_history ah,
               fa_deprn_periods dp
        WHERE  ah.asset_id = p_asset_id
        AND    dp.book_type_code = p_adj_book_type_code
        AND    dp.period_counter = p_period_counter_from
        AND    dp.period_close_date between ah.date_effective and nvl(ah.date_ineffective, dp.period_close_date);
      EXCEPTION WHEN OTHERS THEN
        l_category_id := 0;
      END;

      BEGIN
        SELECT price_index_id
          INTO l_price_index
          FROM fa_category_book_defaults a, fa_price_indexes b
         WHERE a.book_type_code = p_adj_book_type_code
           AND a.category_id    = l_category_id
           AND p_date_placed_in_service >= a.start_dpis
           AND p_date_placed_in_service <= NVL(a.end_dpis,p_date_placed_in_service)
           AND a.price_index_name = b.price_index_name;
        EXCEPTION WHEN OTHERS THEN
          l_price_index := 0;
      END;

      BEGIN
        SELECT rev.reval_date
          INTO l_reval_date
          FROM fa_mass_revaluations rev,
               fa_deprn_periods dp
         WHERE dp.period_counter    = p_period_counter_from
           AND dp.book_type_code    = p_adj_book_type_code
           AND dp.book_type_code    = rev.book_type_code
           AND dp.calendar_period_open_date <= rev.reval_date
           AND rev.reval_date   <= nvl(dp.calendar_period_close_date, rev.reval_date)
           AND rev.status           = 'COMPLETED';
        EXCEPTION WHEN OTHERS THEN
          l_reval_date  := null;
      END;

      BEGIN
        SELECT price_index_value
          INTO l_index_value_from
          FROM fa_price_index_values
         WHERE price_index_id = l_price_index
           AND l_reval_date BETWEEN from_date AND nvl(to_date,l_reval_date);
        EXCEPTION WHEN OTHERS THEN
          l_index_value_from  := 0;
      END;

      BEGIN
        SELECT max(rev.reval_date)
          INTO l_reval_date
          FROM fa_mass_revaluations rev,
               fa_deprn_periods dp
         WHERE dp.period_counter    between p_period_counter_from and p_period_counter_to
           AND dp.book_type_code    = p_adj_book_type_code
           AND dp.book_type_code    = rev.book_type_code
           AND dp.calendar_period_open_date <= rev.reval_date
           AND rev.reval_date   <= nvl(dp.calendar_period_close_date, rev.reval_date)
           AND rev.status           = 'COMPLETED';
        EXCEPTION WHEN OTHERS THEN
          l_reval_date  := null;
      END;

      BEGIN
        SELECT price_index_value
          INTO l_index_value_to
          FROM fa_price_index_values
         WHERE price_index_id = l_price_index
           AND l_reval_date BETWEEN from_date AND nvl(to_date,l_reval_date);
        EXCEPTION WHEN OTHERS THEN
          l_index_value_to  := 0;
      END;

      IF l_index_value_from = 0 THEN
        p_remain_reval_coefficient := 1;
      ELSE
        p_remain_reval_coefficient := l_index_value_to/l_index_value_from;
      END IF;

    END get_remain_reval_coefficient;

/*+=========================================================================+
  |  PRIVATE PROCEDURE                                                      |
  |    Procedure:                                                           |
  |                                                                         |
  |    Get the cost coefficient                                             |
  |                                                                         |
  +=========================================================================+*/
    PROCEDURE get_cost_coefficient ( p_hist_book_type_code          IN VARCHAR2
                                   , p_adj_book_type_code           IN VARCHAR2
                                   , p_asset_id                     IN NUMBER
                                   , p_period_counter_from          IN NUMBER
                                   , p_period_counter_to            IN NUMBER
                                   , p_historical_cost_begin_period IN OUT NOCOPY NUMBER
                                   , p_accum_depr_begin_period      IN OUT NOCOPY NUMBER
                                   , p_historical_cost_end_period   IN OUT NOCOPY NUMBER
                                   , p_adjusted_cost_end_period     IN OUT NOCOPY NUMBER
                                   , p_hist_accum_depr_end_period   IN OUT NOCOPY NUMBER
                                   , p_adj_accum_depr_end_period    IN OUT NOCOPY NUMBER
                                   , p_depr_rpt_period              IN OUT NOCOPY NUMBER
                                   , p_cost_coefficient             IN OUT NOCOPY NUMBER
                                   , p_depr_coefficient             IN OUT NOCOPY NUMBER
                                   , p_mrcsobtype       IN VARCHAR2) IS

    l_date_placed_in_service DATE;
    l_hist_cost_retirement   NUMBER;
    l_adj_cost_retirement   NUMBER;
    l_period_counter_fully_retired NUMBER;
    l_remain_reval_coefficient     NUMBER;
    l_api_name           CONSTANT VARCHAR2(30) := 'GET_COST_COEFFICIENT';


    BEGIN
       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
       END IF;

       IF p_mrcsobtype = 'R' THEN
          get_asset_info_beg_period_mrc  ( p_hist_book_type_code
                                           , p_asset_id
                                           , p_period_counter_from
                                           , p_period_counter_to
                                           , p_historical_cost_begin_period
                                           , p_accum_depr_begin_period);
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'p_historical_cost_beg_period := '||to_char(p_historical_cost_begin_period));
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_historical_cost_beg_period := '||to_char(p_historical_cost_begin_period));
              FND_FILE.PUT_LINE(FND_FILE.LOG,'p_accum_depr_beg_period := '||to_char(p_accum_depr_begin_period));
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_accum_depr_beg_period := '||to_char(p_accum_depr_begin_period));
          END IF;

          get_asset_info_end_period_mrc    ( p_hist_book_type_code
                                           , p_adj_book_type_code
                                           , p_asset_id
                                           , p_period_counter_from
                                           , p_period_counter_to
                                           , p_historical_cost_end_period
                                           , p_adjusted_cost_end_period
                                           , p_hist_accum_depr_end_period
                                           , p_adj_accum_depr_end_period
                                           , p_depr_rpt_period);
       ELSE
          get_asset_info_beg_period  ( p_hist_book_type_code
                                       , p_asset_id
                                       , p_period_counter_from
                                       , p_period_counter_to
                                       , p_historical_cost_begin_period
                                       , p_accum_depr_begin_period);
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'p_historical_cost_beg_period := '||to_char(p_historical_cost_begin_period));
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_historical_cost_beg_period := '||to_char(p_historical_cost_begin_period));
              FND_FILE.PUT_LINE(FND_FILE.LOG,'p_accum_depr_beg_period := '||to_char(p_accum_depr_begin_period));
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_accum_depr_beg_period := '||to_char(p_accum_depr_begin_period));
          END IF;

          get_asset_info_end_period    ( p_hist_book_type_code
                                       , p_adj_book_type_code
                                       , p_asset_id
                                       , p_period_counter_from
                                       , p_period_counter_to
                                       , p_historical_cost_end_period
                                       , p_adjusted_cost_end_period
                                       , p_hist_accum_depr_end_period
                                       , p_adj_accum_depr_end_period
                                       , p_depr_rpt_period);

       END IF;

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'p_historical_cost_end_period := '||to_char(p_historical_cost_end_period));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_historical_cost_end_period := '||to_char(p_historical_cost_end_period));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'p_adjusted_cost_end_period := '||to_char(p_adjusted_cost_end_period));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_adjusted_cost_end_period := '||to_char(p_adjusted_cost_end_period));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'p_hist_accum_depr_end_period := '||to_char(p_hist_accum_depr_end_period));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_hist_accum_depr_end_period := '||to_char(p_hist_accum_depr_end_period));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'p_adj_accum_depr_end_period := '||to_char(p_adj_accum_depr_end_period));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_adj_accum_depr_end_period := '||to_char(p_adj_accum_depr_end_period));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'p_depr_rpt_period := '||to_char(p_depr_rpt_period));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_depr_rpt_period := '||to_char(p_depr_rpt_period));
       END IF;

       IF p_historical_cost_end_period <> 0 THEN
          p_cost_coefficient := p_adjusted_cost_end_period / p_historical_cost_end_period;
       END IF;

       IF p_historical_cost_end_period = 0 THEN
/* Full retirement case */
/* Find the cost at the last retirement period */
          IF p_mrcsobtype = 'R' THEN
             BEGIN
               SELECT bk.cost,
                      bk.period_counter_fully_retired
               INTO   l_hist_cost_retirement,
                      l_period_counter_fully_retired
               FROM   fa_books_mrc_v bk, fa_transaction_headers th
               WHERE bk.book_type_code = p_hist_book_type_code
               AND   bk.asset_id = p_asset_id
               AND   bk.period_counter_fully_retired = (SELECT max(bk1.period_counter_fully_retired)
                                                         FROM   fa_books bk1
                                                         WHERE bk1.book_type_code = bk.book_type_code
                                                         AND   bk1.asset_id = bk.asset_id
                                                         AND   bk1.period_counter_fully_retired
                                                         between p_period_counter_from and p_period_counter_to)
               AND   bk.book_type_code = th.book_type_code
               AND   bk.asset_id = th.asset_id
               AND   bk.transaction_header_id_out = th.transaction_header_id
               AND   th.transaction_type_code = 'FULL RETIREMENT';
             EXCEPTION WHEN OTHERS THEN
                       l_hist_cost_retirement := 0;
                       l_period_counter_fully_retired := 0;
             END;

             BEGIN
               SELECT bk.cost,
                      bk.date_placed_in_service
               INTO   l_adj_cost_retirement,
                      l_date_placed_in_service
               FROM   fa_books_mrc_v bk, fa_transaction_headers th
               WHERE bk.book_type_code = p_adj_book_type_code
               AND   bk.asset_id = p_asset_id
               AND   bk.period_counter_fully_retired = (SELECT max(bk1.period_counter_fully_retired)
                                                         FROM   fa_books bk1
                                                         WHERE bk1.book_type_code = bk.book_type_code
                                                         AND   bk1.asset_id = bk.asset_id
                                                         AND   bk1.period_counter_fully_retired
                                                         between p_period_counter_from and p_period_counter_to)
               AND   bk.book_type_code = th.book_type_code
               AND   bk.asset_id = th.asset_id
               AND   bk.transaction_header_id_out = th.transaction_header_id
               AND   th.transaction_type_code = 'FULL RETIREMENT';
             EXCEPTION WHEN OTHERS THEN
                       l_adj_cost_retirement := 0;
             END;
          ELSE
             BEGIN
               SELECT bk.cost,
                      bk.period_counter_fully_retired
               INTO   l_hist_cost_retirement,
                      l_period_counter_fully_retired
               FROM   fa_books bk, fa_transaction_headers th
               WHERE bk.book_type_code = p_hist_book_type_code
               AND   bk.asset_id = p_asset_id
               AND   bk.period_counter_fully_retired = (SELECT max(bk1.period_counter_fully_retired)
                                                         FROM   fa_books bk1
                                                         WHERE bk1.book_type_code = bk.book_type_code
                                                         AND   bk1.asset_id = bk.asset_id
                                                         AND   bk1.period_counter_fully_retired
                                                         between p_period_counter_from and p_period_counter_to)
               AND   bk.book_type_code = th.book_type_code
               AND   bk.asset_id = th.asset_id
               AND   bk.transaction_header_id_out = th.transaction_header_id
               AND   th.transaction_type_code = 'FULL RETIREMENT';
             EXCEPTION WHEN OTHERS THEN
                       l_hist_cost_retirement := 0;
                       l_period_counter_fully_retired := 0;
             END;

             BEGIN
               SELECT bk.cost,
                      bk.date_placed_in_service
               INTO   l_adj_cost_retirement,
                      l_date_placed_in_service
               FROM   fa_books bk, fa_transaction_headers th
               WHERE bk.book_type_code = p_adj_book_type_code
               AND   bk.asset_id = p_asset_id
               AND   bk.period_counter_fully_retired = (SELECT max(bk1.period_counter_fully_retired)
                                                         FROM   fa_books bk1
                                                         WHERE bk1.book_type_code = bk.book_type_code
                                                         AND   bk1.asset_id = bk.asset_id
                                                         AND   bk1.period_counter_fully_retired
                                                         between p_period_counter_from and p_period_counter_to)
               AND   bk.book_type_code = th.book_type_code
               AND   bk.asset_id = th.asset_id
               AND   bk.transaction_header_id_out = th.transaction_header_id
               AND   th.transaction_type_code = 'FULL RETIREMENT';
             EXCEPTION WHEN OTHERS THEN
                       l_adj_cost_retirement := 0;
             END;
          END IF;

          IF l_hist_cost_retirement <> 0 THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'l_period_counter_fully_retired := '||to_char(l_period_counter_fully_retired));
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_period_counter_fully_retired := '||to_char(l_period_counter_fully_retired));
             END IF;
             get_remain_reval_coefficient ( p_adj_book_type_code
                                          , p_asset_id
                                          , l_date_placed_in_service
                                          , l_period_counter_fully_retired
                                          , p_period_counter_to
                                          , l_remain_reval_coefficient
                                          );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'l_remain_reval_coefficient := '||to_char(l_remain_reval_coefficient));
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_remain_reval_coefficient := '||to_char(l_remain_reval_coefficient));
             END IF;

             p_cost_coefficient := l_remain_reval_coefficient * l_adj_cost_retirement / l_hist_cost_retirement;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'p_cost_coefficient := '||to_char(p_cost_coefficient));
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_cost_coefficient := '||to_char(p_cost_coefficient));
             END IF;

          ELSE
             p_cost_coefficient := 0;
          END IF;
       END IF;

       IF p_hist_accum_depr_end_period <> 0 THEN
          p_depr_coefficient := p_adj_accum_depr_end_period / p_hist_accum_depr_end_period;
       ELSE
          p_depr_coefficient := p_cost_coefficient;
       END IF;

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'p_cost_coefficient := '||to_char(p_cost_coefficient));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_cost_coefficient := '||to_char(p_cost_coefficient));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'p_depr_coefficient := '||to_char(p_depr_coefficient));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_depr_coefficient := '||to_char(p_depr_coefficient));
       END IF;

       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
       END IF;

  END get_cost_coefficient;

/*+=========================================================================+
  |  PRIVATE PROCEDURE                                                      |
  |    Procedure:                                                           |
  |                                                                         |
  |    Get exhibit group for the category                                   |
  |                                                                         |
  +=========================================================================+*/
    PROCEDURE get_exhibit_group (  p_category_id                IN NUMBER
                                 , p_asset_id                   IN NUMBER
                                 , p_corp_book                  IN VARCHAR2
                                 , p_asset_type                 IN VARCHAR2
                                 , p_exhibit_group_id           IN OUT NOCOPY NUMBER) IS

    l_category_id NUMBER;
    l_api_name           CONSTANT VARCHAR2(30) := 'GET_EXHIBIT_GROUP';

    BEGIN

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    l_category_id     := p_category_id;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'p_asset_id =  '||to_char(p_asset_id));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_asset_id =  '||to_char(p_asset_id));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'p_category_id =  '||to_char(p_category_id));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_category_id =  '||to_char(p_category_id));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'p_asset_type =  '||p_asset_type);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_asset_type =  '||p_asset_type);
    END IF;

    IF p_asset_type = 'CIP' THEN
      BEGIN
        SELECT exb.exhibit_group_id
        INTO   p_exhibit_group_id
        FROM   jl_ar_fa_exhibit_groups exb
        WHERE  exb.cip_group = 'Y';
      EXCEPTION WHEN OTHERS THEN
        p_exhibit_group_id := 0;
      END;
    ELSE
      p_exhibit_group_id := 0;
      BEGIN
        SELECT cat.global_attribute16
        INTO   p_exhibit_group_id
        FROM   fa_category_books cat
        WHERE  cat.book_type_code = p_corp_book
        AND    cat.category_id    = l_category_id;
      EXCEPTION WHEN OTHERS THEN
        p_exhibit_group_id := 0;
      END;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'p_exhibit_group_id =  '||to_char(p_exhibit_group_id));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_exhibit_group_id =  '||to_char(p_exhibit_group_id));
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;

  END get_exhibit_group;

/*+=========================================================================+
  |  PRIVATE PROCEDURE                                                      |
  |    Procedure:                                                           |
  |                                                                         |
  |    Get the old category                                                 |
  |                                                                         |
  +=========================================================================+*/
    PROCEDURE get_old_category ( p_asset_id                     IN NUMBER
                                 , p_transaction_header_id      IN NUMBER
                                 , p_transaction_type_code      IN VARCHAR2
                                 , p_old_category_id            IN OUT NOCOPY NUMBER
                                 , p_position                   IN OUT NOCOPY NUMBER) IS

    row_count               NUMBER;
    l_cip_exhibit_group_id  NUMBER;
    old_cat_not_found       BOOLEAN;
    l_asset_type            VARCHAR2(30);
    l_api_name           CONSTANT VARCHAR2(30) := 'GET_OLD_CATEGORY';


    BEGIN

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    p_old_category_id := 0;
    p_position        := 0;

    BEGIN
      SELECT ah.category_id,
             ah.asset_type
      INTO   p_old_category_id,
             l_asset_type
      FROM   fa_asset_history ah
      WHERE  ah.asset_id = p_asset_id
      AND    ah.transaction_header_id_out = p_transaction_header_id;
    EXCEPTION WHEN OTHERS THEN
      p_old_category_id := 0;
    END;

    IF p_transaction_type_code = 'ADDITION' AND l_asset_type <> 'CIP' THEN
          p_old_category_id := 0;
    END IF;

    BEGIN
      SELECT exb.exhibit_group_id
      INTO   l_cip_exhibit_group_id
      FROM   jl_ar_fa_exhibit_groups exb
      WHERE  exb.cip_group = 'Y';
    EXCEPTION WHEN OTHERS THEN
      l_cip_exhibit_group_id := 0;
    END;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'l_cip_exhibit_group_id   := '||to_char(l_cip_exhibit_group_id));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_cip_exhibit_group_id   := '||to_char(l_cip_exhibit_group_id));
    END IF;

    IF ((l_asset_type = 'CIP') OR (p_old_category_id <> 0)) THEN

       row_count := 1;
       old_cat_not_found := TRUE;
       FOR row_count IN nvl(report_table.first,0) .. nvl(report_table.last,0) LOOP
         IF report_table.exists(row_count) THEN
            IF report_table(row_count).category_id = p_old_category_id THEN
/* This is Capitalization or CIP RECLASS because previous asset_type = CIP*/
               IF l_asset_type = 'CIP' AND report_table(row_count).exhibit_group_id = l_cip_exhibit_group_id THEN
                  p_position := row_count;
                  old_cat_not_found := FALSE;
                  exit;
               END IF;
               IF l_asset_type <> 'CIP' THEN    -- This is RECLASS transaction
                  p_position := row_count;
                  old_cat_not_found := FALSE;
                  exit;
               END IF;
            END IF;
         END IF;
       END LOOP;
       IF old_cat_not_found THEN
          p_position := 0;
       END IF;
       IF p_transaction_type_code = 'ADDITION' AND l_asset_type = 'CIP' THEN
          p_old_category_id := -1;
       END IF;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'p_position =  '||to_char(p_position));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_position =  '||to_char(p_position));
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;

  END get_old_category;

  PROCEDURE insert_db_records IS
  row_count BINARY_INTEGER;
  l_api_name           CONSTANT VARCHAR2(30) := 'INSERT_DB_RECORDS';

  BEGIN

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    row_count := 1;
    FOR row_count IN report_table.first .. report_table.last LOOP
    IF report_table.exists(row_count) THEN

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'exhibit_group_id('||to_char(row_count)||'):= '||to_char(report_table(row_count).exhibit_group_id));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'exhibit_group_id('||to_char(row_count)||'):= '||to_char(report_table(row_count).exhibit_group_id));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'category_id('||to_char(row_count)||'):= '||to_char(report_table(row_count).category_id));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'category_id('||to_char(row_count)||'):= '||to_char(report_table(row_count).category_id));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'asset_id('||to_char(row_count)||'):= '||to_char(report_table(row_count).asset_id));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'asset_id('||to_char(row_count)||'):= '||to_char(report_table(row_count).asset_id));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'report_table(1).begin_cost   := '||to_char(report_table(row_count).begin_cost));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'report_table(1).begin_cost   := '||to_char(report_table(row_count).begin_cost));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'additions('||to_char(row_count)||'):= '||to_char(report_table(row_count).additions));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'additions('||to_char(row_count)||'):= '||to_char(report_table(row_count).additions));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'retirements('||to_char(row_count)||'):= '||to_char(report_table(row_count).retirements));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'retirements('||to_char(row_count)||'):= '||to_char(report_table(row_count).retirements));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'transfers('||to_char(row_count)||'):= '||to_char(report_table(row_count).transfers));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'transfers('||to_char(row_count)||'):= '||to_char(report_table(row_count).transfers));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'end_cost('||to_char(row_count)||'):= '||to_char(report_table(row_count).end_cost));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'end_cost('||to_char(row_count)||'):= '||to_char(report_table(row_count).end_cost));
          FND_FILE.PUT_LINE(FND_FILE.LOG,'report_table(1).begin_accum_depr   := '||to_char(report_table(row_count).begin_accum_depr));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'report_table(1).begin_accum_depr   := '||to_char(report_table(row_count).begin_accum_depr));
       END IF;

       insert into JL_AR_FA_EXHIBIT_REPORT       ( conc_request_id
                                    , exhibit_group_id
                                    , category_id
                                    , asset_id
                                    , begin_cost
                                    , additions
                                    , retirements
                                    , transfers
                                    , end_cost
                                    , begin_accum_depr
                                    , accum_depr_retirements
                                    , accum_depr_transfers
                                    , accum_depr_rpt_period
                                    , deprn_reserve
                                    , creation_date
                                    , created_by
                                    , last_update_date
                                    , last_updated_by
                                    , last_update_login
                                    )
                            values  ( report_table(row_count).conc_request_id
                                    , report_table(row_count).exhibit_group_id
                                    , report_table(row_count).category_id
                                    , report_table(row_count).asset_id
                                    , report_table(row_count).begin_cost
                                    , report_table(row_count).additions
                                    , report_table(row_count).retirements
                                    , report_table(row_count).transfers
                                    , report_table(row_count).end_cost
                                    , report_table(row_count).begin_accum_depr
                                    , report_table(row_count).accum_depr_retirements
                                    , report_table(row_count).accum_depr_transfers
                                    , report_table(row_count).accum_depr_rpt_period
                                    , report_table(row_count).deprn_reserve
                                    , sysdate
                                    , fnd_global.user_id
                                    , sysdate
                                    , fnd_global.user_id
                                    , fnd_global.user_id
                                    );
     END IF;
    END LOOP;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;

  END insert_db_records;

/*+=========================================================================+
  |  PUBLIC PROCEDURE                                                       |
  |    populate_FA_Exhibit_Data                                             |
  |        p_book_type_code       IN  Depreciation Book                     |
  |        p_conc_request_id      IN  Concurrent Request Id                 |
  |        p_period_counter_from  IN  Earliest Period on the report         |
  |        p_period_counter_to    IN  Latest Period on the report           |
  |                                                                         |
  |  NOTES                                                                  |
  |      G                                                                  |
  |                                                                         |
  |                                                                         |
  +=========================================================================+*/
  PROCEDURE populate_FA_Exhibit_Data (p_tax_book      IN VARCHAR2,
                                      p_corp_book     IN VARCHAR2,
                                      p_conc_request_id     IN  NUMBER,
                                      p_period_counter_from IN  NUMBER,
                                      p_period_counter_to   IN  NUMBER,
                                      p_mrcsobtype    IN VARCHAR2 DEFAULT 'P') IS

    l_api_name           CONSTANT VARCHAR2(30) := 'FA_EXHIBIT_DATA';

    l_ignore_retirement              VARCHAR2(1);
    l_ignore_reinstatement           VARCHAR2(1);
    l_exhibit_group_id               number;
    l_current_category_id            number;
    l_old_category_id                number;
    l_category_id                    number;
    l_asset_id                       number;
    l_period_counter                 number;
    l_historical_cost_begin_period   number;
    l_historical_cost_end_period     number;
    l_adjusted_cost_end_period       number;
    l_accum_depr_begin_period        number;
    l_hist_accum_depr_end_period     number;
    l_adj_accum_depr_end_period      number;
    l_depr_rpt_period                number;
    l_cost_coefficient               number;
    l_depr_coefficient               number;
    l_reval_cost                     number;
    l_adjustment                     number;
    i                                number;
    j                                number;
    l_date_placed_in_service         DATE;
    l_remain_reval_coefficient       NUMBER;

    -- Bug 4956193. Variables added to add logic to support multiple Adjustments in same period.

    l_book_type_code_old             fa_transaction_headers.book_type_code%type;
    l_asset_id_old                   fa_transaction_headers.asset_id%type;
    l_period_counter_old             fa_deprn_periods.period_counter%type;
    l_transaction_type_code_old      fa_transaction_headers.transaction_type_code%type;
    l_adj_already_calculated_flag    varchar2(1);

   -- Create ref cursors for bug 3101070
  Type report_row IS RECORD
  (
    asset_id                 fa_transaction_headers.asset_id%type,
    category_id              fa_asset_history.category_id%type,
    period_counter           fa_deprn_periods.period_counter%type,
    book_type_code           fa_transaction_headers.book_type_code%type,
    transaction_type_code    fa_transaction_headers.transaction_type_code%type,
    transaction_header_id    fa_transaction_headers.transaction_header_id%type,
    asset_type               fa_asset_history.asset_type%type,
    units                    fa_asset_history.units%type
  );

  TYPE report_ref_cur is REF CURSOR;
  fetch_txns_for_rpt_period       report_ref_cur;
  asset_txns_rec                  report_row;

    ------------------------------------------------------------
    -- Cursor: fetch_txns_for_rpt_period                      --
    --                                                        --
    -- Fetch all the asset transactions happened in the       --
    -- reporting period.                                      --
    --                                                        --
    ------------------------------------------------------------

  BEGIN

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    l_exhibit_group_id := 0;
    l_category_id      := 0;
    l_asset_id         := 0;
    l_period_counter   := 0;

    -- Bug 4956193. Variables added to add logic to support multiple Adjustments in same period.
    l_book_type_code_old             := null;
    l_asset_id_old                   := null;
    l_period_counter_old             := null;
    l_transaction_type_code_old      := null;
    l_adj_already_calculated_flag    := 'N';


    delete from JL_AR_FA_EXHIBIT_REPORT;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Start');
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Start');
       FND_FILE.PUT_LINE(FND_FILE.LOG,'p_tax_book =  '||p_tax_book);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_tax_book =  '||p_tax_book);
    END IF;

    IF p_mrcsobtype = 'R' THEN
      OPEN fetch_txns_for_rpt_period FOR
      SELECT   th.asset_id,
               ah.category_id,
               dp.period_counter,
               th.book_type_code,
               th.transaction_type_code,
               th.transaction_header_id,
               ah.asset_type,
               nvl (ah.units,0)
      FROM     fa_transaction_headers  th,
               fa_deprn_periods_mrc_v  dp,
               fa_asset_history        ah
      WHERE    dp.book_type_code    = p_corp_book
        AND    dp.period_counter    between p_period_counter_from and p_period_counter_to
        AND    th.book_type_code    = dp.book_type_code
        AND    dp.period_open_date <= th.date_effective
        AND    th.date_effective   <= dp.period_close_date
        AND    th.transaction_type_code IN ('TRANSFER OUT',
                                            'RECLASS',
                                            'CIP RECLASS',
--                                            'TRANSFER',
--                                            'CIP TRANSFER',
                                            'UNIT ADJUSTMENT',
                                            'ADDITION',
                                            'CIP ADDITION',
                                            'ADJUSTMENT',
                                            'CIP ADJUSTMENT',
                                            'FULL RETIREMENT',
                                            'PARTIAL RETIREMENT',
                                            'REINSTATEMENT',
--                                            'TRANSFER IN',
                                            'ADDITION/VOID'
                                           )
        AND    ah.asset_id = th.asset_id
        AND    ah.date_effective <= th.date_effective
        AND    th.date_effective <  nvl (ah.date_ineffective, th.date_effective + 1)
      UNION
      SELECT   ah.asset_id,
               ah.category_id,
               dp.period_counter - 1,
               dp.book_type_code,
               null,
               -1,
               ah.asset_type,
               nvl (ah.units,0)
      FROM     fa_books                bk,
               fa_deprn_periods_mrc_v  dp,
               fa_asset_history        ah
      WHERE    dp.book_type_code           = p_corp_book
        AND    bk.book_type_code           = dp.book_type_code
        AND    bk.asset_id                 = ah.asset_id
        AND    dp.period_counter           = p_period_counter_from
        AND    dp.period_open_date between ah.date_effective AND nvl(ah.date_ineffective,dp.period_open_date)
        AND    dp.period_open_date between bk.date_effective AND nvl(bk.date_ineffective,dp.period_open_date)
      ORDER BY 1,3,5;
    ELSE
      OPEN fetch_txns_for_rpt_period FOR
      SELECT   th.asset_id,
               ah.category_id,
               dp.period_counter,
               th.book_type_code,
               th.transaction_type_code,
               th.transaction_header_id,
               ah.asset_type,
               nvl (ah.units,0)
      FROM     fa_transaction_headers  th,
               fa_deprn_periods        dp,
               fa_asset_history        ah
      WHERE    dp.book_type_code    = p_corp_book
        AND    dp.period_counter    between p_period_counter_from and p_period_counter_to
        AND    th.book_type_code    = dp.book_type_code
        AND    dp.period_open_date <= th.date_effective
        AND    th.date_effective   <= dp.period_close_date
        AND    th.transaction_type_code IN ('TRANSFER OUT',
                                            'RECLASS',
                                            'CIP RECLASS',
--                                            'TRANSFER',
--                                            'CIP TRANSFER',
                                            'UNIT ADJUSTMENT',
                                            'ADDITION',
                                            'CIP ADDITION',
                                            'ADJUSTMENT',
                                            'CIP ADJUSTMENT',
                                            'FULL RETIREMENT',
                                            'PARTIAL RETIREMENT',
                                            'REINSTATEMENT',
--                                            'TRANSFER IN',
                                            'ADDITION/VOID'
                                           )
        AND    ah.asset_id = th.asset_id
        AND    ah.date_effective <= th.date_effective
        AND    th.date_effective <  nvl (ah.date_ineffective, th.date_effective + 1)
      UNION
      SELECT   ah.asset_id,
               ah.category_id,
               dp.period_counter - 1,
               dp.book_type_code,
               null,
               -1,
               ah.asset_type,
               nvl (ah.units,0)
      FROM     fa_books                bk,
               fa_deprn_periods        dp,
               fa_asset_history        ah
      WHERE    dp.book_type_code           = p_corp_book
        AND    bk.book_type_code           = dp.book_type_code
        AND    bk.asset_id                 = ah.asset_id
        AND    dp.period_counter           = p_period_counter_from
        AND    dp.period_open_date between ah.date_effective AND nvl(ah.date_ineffective,dp.period_open_date)
        AND    dp.period_open_date between bk.date_effective AND nvl(bk.date_ineffective,dp.period_open_date)
      ORDER BY 1,3,5;
    END IF;

    LOOP
       FETCH fetch_txns_for_rpt_period INTO asset_txns_rec;
       EXIT WHEN fetch_txns_for_rpt_period%NOTFOUND
              OR fetch_txns_for_rpt_period%NOTFOUND IS NULL;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'**Next Record****');
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, '**Next Record****');
       FND_FILE.PUT_LINE(FND_FILE.LOG,'asset_txns_rec.category_id := '||to_char(asset_txns_rec.category_id));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'asset_txns_rec.category_id := '||to_char(asset_txns_rec.category_id));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'asset_txns_rec.asset_id := '||to_char(asset_txns_rec.asset_id));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'asset_txns_rec.asset_id := '||to_char(asset_txns_rec.asset_id));
       FND_FILE.PUT_LINE(FND_FILE.LOG,'asset_txns_rec.transaction_type_code := '||asset_txns_rec.transaction_type_code);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'asset_txns_rec.transaction_type_code := '||asset_txns_rec.transaction_type_code);
       FND_FILE.PUT_LINE(FND_FILE.LOG,'asset_txns_rec.period_counter := '||to_char(asset_txns_rec.period_counter));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'asset_txns_rec.period_counter := '||to_char(asset_txns_rec.period_counter));
    END IF;

       IF ((asset_txns_rec.asset_id <> l_asset_id) OR (l_category_id <> asset_txns_rec.category_id)) THEN
          IF (asset_txns_rec.asset_id <> l_asset_id) THEN
             IF l_asset_id <> 0 THEN
                insert_db_records;
                report_table.delete;
             END IF;
             get_cost_coefficient ( p_corp_book
                                  , p_tax_book
                                  , asset_txns_rec.asset_id
                                  , p_period_counter_from
                                  , p_period_counter_to
                                  , l_historical_cost_begin_period
                                  , l_accum_depr_begin_period
                                  , l_historical_cost_end_period
                                  , l_adjusted_cost_end_period
                                  , l_hist_accum_depr_end_period
                                  , l_adj_accum_depr_end_period
                                  , l_depr_rpt_period
                                  , l_cost_coefficient
                                  , l_depr_coefficient
                                  , p_mrcsobtype
                                  );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_historical_cost_beg_period := '||to_char(l_historical_cost_begin_period));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_historical_cost_beg_period := '||to_char(l_historical_cost_begin_period));
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_accum_depr_beg_period := '||to_char(l_accum_depr_begin_period));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_accum_depr_beg_period := '||to_char(l_accum_depr_begin_period));
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_historical_cost_end_period := '||to_char(l_historical_cost_end_period));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_historical_cost_end_period := '||to_char(l_historical_cost_end_period));
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_adjusted_cost_end_period := '||to_char(l_adjusted_cost_end_period));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_adjusted_cost_end_period := '||to_char(l_adjusted_cost_end_period));
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_hist_accum_depr_end_period := '||to_char(l_hist_accum_depr_end_period));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_hist_accum_depr_end_period := '||to_char(l_hist_accum_depr_end_period));
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_adj_accum_depr_end_period := '||to_char(l_adj_accum_depr_end_period));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_adj_accum_depr_end_period := '||to_char(l_adj_accum_depr_end_period));
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_depr_rpt_period := '||to_char(l_depr_rpt_period));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_depr_rpt_period := '||to_char(l_depr_rpt_period));
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_cost_coefficient := '||to_char(l_cost_coefficient));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_cost_coefficient := '||to_char(l_cost_coefficient));
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_depr_coefficient := '||to_char(l_depr_coefficient));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_depr_coefficient := '||to_char(l_depr_coefficient));
             END IF;

             l_asset_id := asset_txns_rec.asset_id;
             i := 1;

/* If the first transaction hit in this loop is RECLASS or CAPITALIZATION(ADDITION) then we need to create additional record for old category */

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'asset_txns_rec.transaction_type_code := ' || asset_txns_rec.transaction_type_code );
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'asset_txns_rec.transaction_type_code := ' || asset_txns_rec.transaction_type_code );
             END IF;

             IF asset_txns_rec.transaction_type_code in ('RECLASS','CIP RECLASS','ADDITION') THEN
                get_old_category ( asset_txns_rec.asset_id
                                   , asset_txns_rec.transaction_header_id
                                   , asset_txns_rec.transaction_type_code
                                   , l_old_category_id
                                   , j);
                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'p_tax_book =  '||p_tax_book);
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'p_tax_book =  '||p_tax_book);
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'l_old_category_id =  '||to_char(l_old_category_id));
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_old_category_id =  '||to_char(l_old_category_id));
                END IF;

/* If old category returned is -1, then Transaction in consideration is Capitalization. */
                IF l_old_category_id = -1 THEN
                   get_exhibit_group ( asset_txns_rec.category_id
                                       , asset_txns_rec.asset_id
                                       , p_corp_book
                                       , 'CIP'
                                       , l_exhibit_group_id);
                   report_table(i).conc_request_id        := p_conc_request_id;
                   report_table(i).exhibit_group_id       := l_exhibit_group_id;
                   report_table(i).category_id            := asset_txns_rec.category_id;
                   report_table(i).asset_id               := l_asset_id;
                   report_table(i).additions              := 0;
                   report_table(i).retirements            := 0;
                   report_table(i).transfers              := 0;
                   report_table(i).accum_depr_retirements := 0;
                   report_table(i).accum_depr_transfers   := 0;
                   report_table(i).end_cost               := 0;
                   report_table(i).accum_depr_rpt_period  := 0;
                   report_table(i).deprn_reserve          := 0;
                ELSIF l_old_category_id > 0 THEN
                   get_exhibit_group ( l_old_category_id
                                       , asset_txns_rec.asset_id
                                       , p_corp_book
                                       , asset_txns_rec.asset_type
                                       , l_exhibit_group_id);
                   report_table(i).conc_request_id        := p_conc_request_id;
                   report_table(i).exhibit_group_id       := l_exhibit_group_id;
                   report_table(i).category_id            := l_old_category_id;
                   report_table(i).asset_id               := l_asset_id;
                   report_table(i).additions              := 0;
                   report_table(i).retirements            := 0;
                   report_table(i).transfers              := 0;
                   report_table(i).accum_depr_retirements := 0;
                   report_table(i).accum_depr_transfers   := 0;
                   report_table(i).end_cost               := 0;
                   report_table(i).accum_depr_rpt_period  := 0;
                   report_table(i).deprn_reserve          := 0;
                ELSE
                   l_category_id := asset_txns_rec.category_id;
                   get_exhibit_group ( l_category_id
                                       , asset_txns_rec.asset_id
                                       , p_corp_book
                                       , asset_txns_rec.asset_type
                                       , l_exhibit_group_id);
                END IF;
             ELSE
                l_category_id := asset_txns_rec.category_id;
                get_exhibit_group ( l_category_id
                                    , asset_txns_rec.asset_id
                                    , p_corp_book
                                    , asset_txns_rec.asset_type
                                    , l_exhibit_group_id);
             END IF;

             report_table(i).begin_cost          := l_cost_coefficient * l_historical_cost_begin_period;
             report_table(i).begin_accum_depr       := l_depr_coefficient * l_accum_depr_begin_period;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'report_table(1).begin_cost   := '||to_char(report_table(i).begin_cost));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'report_table(1).begin_cost   := '||to_char(report_table(i).begin_cost));
                FND_FILE.PUT_LINE(FND_FILE.LOG,'report_table(1).begin_accum_depr   := '||to_char(report_table(i).begin_accum_depr));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'report_table(1).begin_accum_depr   := '||to_char(report_table(i).begin_accum_depr));
             END IF;

          END IF;
          IF (asset_txns_rec.category_id <> l_category_id) THEN
             IF l_category_id <> 0 THEN
                i := i + 1;
                report_table(i).begin_cost          := 0;
                report_table(i).begin_accum_depr    := 0;
                l_category_id := asset_txns_rec.category_id;
                get_exhibit_group ( l_category_id
                                    , asset_txns_rec.asset_id
                                    , p_corp_book
                                    , asset_txns_rec.asset_type
                                    , l_exhibit_group_id);
             END IF;
          END IF;

/* Find the category at the end of the last reporting period */
          BEGIN
             SELECT ah.category_id
             INTO   l_current_category_id
             FROM   fa_asset_history ah,
                    fa_deprn_periods dp
             WHERE  ah.asset_id = asset_txns_rec.asset_id
             AND    dp.book_type_code         = p_corp_book
             AND    dp.period_close_date between ah.date_effective and nvl(ah.date_ineffective,dp.period_close_date)
             AND    dp.period_counter         = p_period_counter_to;
          EXCEPTION WHEN OTHERS THEN
             l_current_category_id := 0;
          END;
          IF l_category_id = l_current_category_id THEN
             report_table(i).end_cost               := l_adjusted_cost_end_period;
             report_table(i).accum_depr_rpt_period  := l_depr_coefficient * l_depr_rpt_period;
             report_table(i).deprn_reserve          := l_adj_accum_depr_end_period;
          ELSE
             report_table(i).end_cost               := 0;
             report_table(i).accum_depr_rpt_period  := 0;
             report_table(i).deprn_reserve          := 0;
          END IF;
          report_table(i).conc_request_id        := p_conc_request_id;
          report_table(i).exhibit_group_id       := l_exhibit_group_id;
          report_table(i).category_id            := asset_txns_rec.category_id;
          report_table(i).asset_id               := asset_txns_rec.asset_id;
          report_table(i).additions              := 0;
          report_table(i).retirements            := 0;
          report_table(i).transfers              := 0;
          report_table(i).accum_depr_retirements := 0;
          report_table(i).accum_depr_transfers   := 0;
       END IF;

       IF asset_txns_rec.transaction_type_code in ('ADDITION', 'CIP ADDITION') THEN
          IF asset_txns_rec.transaction_type_code in ('ADDITION') THEN
/* Check if this ADDITION transaction has happened due to Capitalization */
             get_old_category ( asset_txns_rec.asset_id
                                , asset_txns_rec.transaction_header_id
                                , asset_txns_rec.transaction_type_code
                                , l_old_category_id
                                , j);

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_old_category_id              := ' || to_char(l_old_category_id));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_old_category_id              := ' || to_char(l_old_category_id));
             END IF;

             IF l_old_category_id <> -1 THEN

                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'Regular Addition');
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Regular Addition');
                END IF;

                get_adjust_amount (asset_txns_rec.book_type_code
                                   , asset_txns_rec.asset_id
                                   , asset_txns_rec.period_counter
                                   , asset_txns_rec.transaction_type_code
                                   , 'COST'
                                   , l_adjustment
                                   , p_mrcsobtype
                                     );

                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'l_adjustment              := ' || to_char(l_adjustment));
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_adjustment              := ' || to_char(l_adjustment));
                END IF;

                report_table(i).additions              := report_table(i).additions + l_cost_coefficient * l_adjustment;

                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'additions   := ' || to_char(report_table(i).additions));
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'additions   := ' || to_char(report_table(i).additions));
                END IF;

             END IF;
          ELSIF asset_txns_rec.transaction_type_code in ('CIP ADDITION') THEN
                get_adjust_amount (asset_txns_rec.book_type_code
                                   , asset_txns_rec.asset_id
                                   , asset_txns_rec.period_counter
                                   , asset_txns_rec.transaction_type_code
                                   , 'CIP COST'
                                   , l_adjustment
                                   , p_mrcsobtype
                                     );

                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'l_adjustment              := ' || to_char(l_adjustment));
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_adjustment              := ' || to_char(l_adjustment));
                END IF;

                report_table(i).additions              := report_table(i).additions + l_cost_coefficient * l_adjustment;

                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'additions   := ' || to_char(report_table(i).additions));
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'additions   := ' || to_char(report_table(i).additions));
                END IF;
          END IF;
       END IF;

       IF asset_txns_rec.transaction_type_code in ('FULL RETIREMENT','PARTIAL RETIREMENT') THEN

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_FILE.PUT_LINE(FND_FILE.LOG,'In FULL/PARTIAL RETIREMENT');
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'In FULL/PARTIAL RETIREMENT');
          END IF;

/* Ignore the re-instated retirements */
          l_ignore_retirement := 'N';
          BEGIN
            SELECT 'Y'
            INTO   l_ignore_retirement
            FROM   fa_retirements ret
            WHERE  ret.book_type_code            = asset_txns_rec.book_type_code
            AND    ret.asset_id                  = asset_txns_rec.asset_id
            AND    ret.transaction_header_id_in  = asset_txns_rec.transaction_header_id
            AND    ret.status                    = 'DELETED'
            AND    EXISTS (SELECT   th.transaction_header_id
                           FROM     fa_transaction_headers  th,
                                    fa_deprn_periods        dp
                           WHERE    dp.book_type_code    = asset_txns_rec.book_type_code
                             AND    dp.period_counter    between p_period_counter_from and p_period_counter_to
                             AND    th.book_type_code    = dp.book_type_code
                             AND    dp.period_open_date <= th.date_effective
                             AND    th.date_effective   <= dp.period_close_date
                             AND    th.transaction_header_id  = ret.transaction_header_id_out);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_ignore_retirement := 'N';
            WHEN OTHERS THEN
              l_ignore_retirement := 'N';
          END;
          IF l_ignore_retirement = 'N' THEN
             get_adjust_amount (asset_txns_rec.book_type_code
                              , asset_txns_rec.asset_id
                              , asset_txns_rec.period_counter
                              , asset_txns_rec.transaction_type_code
                              , 'COST'
                              , l_adjustment
                              , p_mrcsobtype
                               );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_adjustment := ' || to_char(l_adjustment));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_adjustment := ' || to_char(l_adjustment));
             END IF;

             report_table(i).retirements := report_table(i).retirements + l_cost_coefficient * l_adjustment;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'retirements := ' || to_char(report_table(i).retirements));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'retirements := ' || to_char(report_table(i).retirements));
             END IF;

             get_adjust_amount (asset_txns_rec.book_type_code
                              , asset_txns_rec.asset_id
                              , asset_txns_rec.period_counter
                              , asset_txns_rec.transaction_type_code
                              , 'RESERVE'
                              , l_adjustment
                              , p_mrcsobtype
                               );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_adjustment := ' || to_char(l_adjustment));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_adjustment := ' || to_char(l_adjustment));
             END IF;

             report_table(i).accum_depr_retirements := report_table(i).accum_depr_retirements - l_depr_coefficient * l_adjustment;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'accum_depr_retirements := ' || to_char(report_table(i).accum_depr_retirements));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'accum_depr_retirements := ' || to_char(report_table(i).accum_depr_retirements));
             END IF;

          END IF;
       END IF;

       IF asset_txns_rec.transaction_type_code in ('REINSTATEMENT') THEN
/* Ignore the re-instatement if retirement is also considered in the reporting time frame */
          l_ignore_reinstatement := 'N';
          BEGIN
            SELECT 'Y'
            INTO   l_ignore_reinstatement
            FROM   fa_retirements ret
            WHERE  ret.book_type_code             = asset_txns_rec.book_type_code
            AND    ret.asset_id                   = asset_txns_rec.asset_id
            AND    ret.transaction_header_id_out  = asset_txns_rec.transaction_header_id
            AND    ret.status                     = 'DELETED'
            AND    EXISTS (SELECT   th.transaction_header_id
                           FROM     fa_transaction_headers  th,
                                    fa_deprn_periods        dp
                           WHERE    dp.book_type_code    = asset_txns_rec.book_type_code
                             AND    dp.period_counter    between p_period_counter_from and p_period_counter_to
                             AND    th.book_type_code    = dp.book_type_code
                             AND    dp.period_open_date <= th.date_effective
                             AND    th.date_effective   <= dp.period_close_date
                             AND    th.transaction_header_id  = ret.transaction_header_id_in);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_ignore_reinstatement := 'N';
            WHEN OTHERS THEN
              l_ignore_reinstatement := 'N';
          END;
          IF l_ignore_reinstatement = 'N' THEN
             get_adjust_amount (asset_txns_rec.book_type_code
                              , asset_txns_rec.asset_id
                              , asset_txns_rec.period_counter
                              , asset_txns_rec.transaction_type_code
                              , 'COST'
                              , l_adjustment
                              , p_mrcsobtype
                               );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_adjustment := ' || to_char(l_adjustment));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_adjustment := ' || to_char(l_adjustment));
             END IF;

             report_table(i).retirements := report_table(i).retirements - l_cost_coefficient * l_adjustment;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'retirements := ' || to_char(report_table(i).retirements));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'retirements := ' || to_char(report_table(i).retirements));
             END IF;

             get_adjust_amount (asset_txns_rec.book_type_code
                              , asset_txns_rec.asset_id
                              , asset_txns_rec.period_counter
                              , asset_txns_rec.transaction_type_code
                              , 'RESERVE'
                              , l_adjustment
                              , p_mrcsobtype
                               );

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_adjustment := ' || to_char(l_adjustment));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_adjustment := ' || to_char(l_adjustment));
             END IF;

             report_table(i).accum_depr_retirements := report_table(i).accum_depr_retirements + l_depr_coefficient * l_adjustment;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'accum_depr_retirements := ' || to_char(report_table(i).accum_depr_retirements));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'accum_depr_retirements := ' || to_char(report_table(i).accum_depr_retirements));
             END IF;

          END IF;
       END IF;

       IF ((asset_txns_rec.transaction_type_code in ('RECLASS','CIP RECLASS')) OR
           (asset_txns_rec.transaction_type_code = 'ADDITION' AND l_old_category_id = -1))  THEN

          IF  (asset_txns_rec.transaction_type_code = 'ADDITION' AND l_old_category_id = -1)  THEN

                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'Capitalization of the asset');
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Capitalization of the asset');
                END IF;

                i := i + 1;

                get_exhibit_group ( asset_txns_rec.category_id
                                    , asset_txns_rec.asset_id
                                    , p_corp_book
                                    , asset_txns_rec.asset_type
                                    , l_exhibit_group_id);

                report_table(i).conc_request_id        := p_conc_request_id;
                report_table(i).exhibit_group_id       := l_exhibit_group_id;
                report_table(i).category_id            := asset_txns_rec.category_id;
                report_table(i).asset_id               := asset_txns_rec.asset_id;
                report_table(i).begin_cost             := 0;
                report_table(i).additions              := 0;
                report_table(i).retirements            := 0;
                report_table(i).transfers              := 0;
                report_table(i).begin_accum_depr       := 0;
                report_table(i).accum_depr_retirements := 0;
                report_table(i).accum_depr_transfers   := 0;
/* Since the asset is capitalized, we need to move the end cost to 'CAPITALIZED' row
   and set the end cost of CIP row for the asset to zero */
                report_table(i).end_cost            := report_table(j).end_cost;
                report_table(i).accum_depr_rpt_period  := report_table(j).accum_depr_rpt_period;
                report_table(i).deprn_reserve          := report_table(j).deprn_reserve;

                report_table(j).end_cost            := 0;
                report_table(j).accum_depr_rpt_period  := 0;
                report_table(j).deprn_reserve          := 0;
         ELSE
                get_old_category ( asset_txns_rec.asset_id
                                  , asset_txns_rec.transaction_header_id
                                  , asset_txns_rec.transaction_type_code
                                  , l_old_category_id
                                  , j);
         END IF;
         get_adjust_amount (asset_txns_rec.book_type_code
                           , asset_txns_rec.asset_id
                           , asset_txns_rec.period_counter
                           , asset_txns_rec.transaction_type_code
                           , 'COST'
                           , l_adjustment
                           , p_mrcsobtype
                           );

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'l_adjustment := ' || to_char(l_adjustment));
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_adjustment := ' || to_char(l_adjustment));
            FND_FILE.PUT_LINE(FND_FILE.LOG,'j := ' || to_char(j));
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'j := ' || to_char(j));
            FND_FILE.PUT_LINE(FND_FILE.LOG,'i := ' || to_char(i));
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'i := ' || to_char(i));
         END IF;

         report_table(i).transfers := report_table(i).transfers + l_cost_coefficient * l_adjustment;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'transfers To := ' || to_char(report_table(i).transfers));
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'transfers To := ' || to_char(report_table(i).transfers));
         END IF;

         report_table(j).transfers := report_table(j).transfers - l_cost_coefficient * l_adjustment;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'transfers From := ' || to_char(report_table(j).transfers));
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'transfers From := ' || to_char(report_table(j).transfers));
         END IF;

         IF report_table(i).begin_accum_depr > 0 THEN
            get_adjust_amount (asset_txns_rec.book_type_code
                               , asset_txns_rec.asset_id
                               , asset_txns_rec.period_counter
                               , asset_txns_rec.transaction_type_code
                               , 'RESERVE'
                               , l_adjustment
                               , p_mrcsobtype
                               );

            report_table(i).accum_depr_transfers := report_table(i).accum_depr_transfers + (l_depr_coefficient * l_adjustment);

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'accum_depr_transfers := ' || to_char(report_table(i).accum_depr_transfers));
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'accum_depr_transfers := ' || to_char(report_table(i).accum_depr_transfers));
            END IF;

            report_table(j).accum_depr_transfers := report_table(j).accum_depr_transfers - (l_depr_coefficient * l_adjustment);
         END IF;
         IF  (asset_txns_rec.transaction_type_code = 'ADDITION' AND l_old_category_id = -1)  THEN

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Capitalization of the asset ends');
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Capitalization of the asset ends');
             END IF;

         END IF;
       END IF;

       IF asset_txns_rec.transaction_type_code in ('ADJUSTMENT', 'CIP ADJUSTMENT') THEN
          -----------------------------------------------------------------------------------------------------------
          -- BUG 4856193. Logic has been added to avoid looping throguh all the rows in FA_TRANSACTION_HEADERS for
          --              multiple Adjustments. An asset can have multiple adjustments for the same period and book.
          --              The function get_adjust_amount already returns the summary of all the adjustments for a
          --              given period. So no need to summarize again for each adjustment row.
          -----------------------------------------------------------------------------------------------------------

          IF asset_txns_rec.book_type_code        = l_book_type_code_old        AND
             asset_txns_rec.asset_id              = l_asset_id_old              AND
             asset_txns_rec.period_counter        = l_period_counter_old        AND
             asset_txns_rec.transaction_type_code = l_transaction_type_code_old
            THEN
              l_adj_already_calculated_flag := 'Y';
            ELSE
              l_adj_already_calculated_flag := 'N';
              l_book_type_code_old        := asset_txns_rec.book_type_code;
              l_asset_id_old              := asset_txns_rec.asset_id;
              l_period_counter_old        := asset_txns_rec.period_counter;
              l_transaction_type_code_old := asset_txns_rec.transaction_type_code;
          END IF;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_FILE.PUT_LINE(FND_FILE.LOG,'Bug 4956193: Adjustment calculated flag:'||l_adj_already_calculated_flag);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Bug 4956193: Adjustment calculated flag:'||l_adj_already_calculated_flag);
          END IF;

          -----------------------------------------------------------------------------
          -- Bug 4856193. Only if Adjustment has not been calculated yet, calculate it.
          -----------------------------------------------------------------------------
          IF l_adj_already_calculated_flag = 'N' THEN
            IF asset_txns_rec.transaction_type_code in ('ADJUSTMENT') THEN
              get_adjust_amount (  asset_txns_rec.book_type_code
                                 , asset_txns_rec.asset_id
                                 , asset_txns_rec.period_counter
                                 , asset_txns_rec.transaction_type_code
                                 , 'COST'
                                 , l_adjustment
                                 , p_mrcsobtype
                                   );
            ELSIF asset_txns_rec.transaction_type_code in ('CIP ADJUSTMENT') THEN
              get_adjust_amount (  asset_txns_rec.book_type_code
                                 , asset_txns_rec.asset_id
                                 , asset_txns_rec.period_counter
                                 , asset_txns_rec.transaction_type_code
                                 , 'CIP COST'
                                 , l_adjustment
                                 , p_mrcsobtype
                                   );
            END IF;

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'l_adjustment              := ' || to_char(l_adjustment));
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_adjustment              := ' || to_char(l_adjustment));
            END IF;

            IF l_adjustment > 0 THEN
               report_table(i).additions              := report_table(i).additions + l_cost_coefficient * l_adjustment;

               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Addition adjustments   := ' || to_char(report_table(i).additions));
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Addition adjustments   := ' || to_char(report_table(i).additions));
               END IF;

            ELSE
               report_table(i).retirements            := report_table(i).retirements - l_cost_coefficient * l_adjustment;

               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'Retirement adjustments   := ' || to_char(report_table(i).retirements));
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Retirement adjustments   := ' || to_char(report_table(i).retirements));
               END IF;

            END IF;

            get_adjust_amount (asset_txns_rec.book_type_code
                                , asset_txns_rec.asset_id
                                , asset_txns_rec.period_counter
                                , asset_txns_rec.transaction_type_code
                                , 'EXPENSE'
                                , l_adjustment
                                , p_mrcsobtype
                                 );

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'l_adjustment              := ' || to_char(l_adjustment));
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'l_adjustment              := ' || to_char(l_adjustment));
            END IF;

            IF l_adjustment < 0 THEN
               report_table(i).accum_depr_retirements := report_table(i).accum_depr_retirements + (l_depr_coefficient * l_adjustment);

               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'accum_depr_retirements := ' || to_char(report_table(i).accum_depr_retirements));
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'accum_depr_retirements := ' || to_char(report_table(i).accum_depr_retirements));
               END IF;

            END IF;
          END IF;
        END IF;

    END LOOP;
    insert_db_records;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;

  END Populate_FA_Exhibit_Data;

END jl_zz_fa_functions_pkg;

/
