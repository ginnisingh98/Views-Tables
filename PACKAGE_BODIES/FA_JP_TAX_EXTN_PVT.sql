--------------------------------------------------------
--  DDL for Package Body FA_JP_TAX_EXTN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_JP_TAX_EXTN_PVT" 
/* $Header: FAVJPEXTB.pls 120.2.12010000.3 2009/10/06 10:29:44 anujain noship $   */
AS
   g_print_debug                           BOOLEAN := fa_cache_pkg.fa_print_debug;

   TYPE tp_nbv IS RECORD (
      period                               VARCHAR2 (30)
    , nbv_value                            NUMBER
    , asset_id                             NUMBER
    , deprn_value                          NUMBER
    , new_depreciation                     NUMBER
    , acc_deprn                            NUMBER
    , period_cntr                          NUMBER
   );

   TYPE tp_nbv_typ IS TABLE OF tp_nbv
      INDEX BY BINARY_INTEGER;

-- Declaration of global constants
   gn_user_id                              NUMBER := fnd_global.user_id;
   gn_login_id                             NUMBER := fnd_global.login_id;
   gn_deprn                                NUMBER := 0;
   gn_acc_deprn                            NUMBER := 0;
   gn_normal_status               CONSTANT NUMBER := 0;
   gn_warning_status              CONSTANT NUMBER := 1;
   gn_error_status                CONSTANT NUMBER := 2;
   gn_test                                 NUMBER;

   PROCEDURE insert_fa_whatif_itf (
      x_errbuf                   OUT NOCOPY VARCHAR2
    , x_retcode                  OUT NOCOPY NUMBER
    , p_request_id               IN       NUMBER
    , p_checkbox_check           IN       VARCHAR2
    , p_book_type_code           IN       fa_books.book_type_code%TYPE
    , p_number_of_periods        IN       NUMBER
    , p_asset_id                 IN       fa_books.asset_id%TYPE
    , p_period_name              IN       fa_deprn_periods.period_name%TYPE
    , p_first_begin_prd          IN       fa_deprn_periods.period_name%TYPE
    , p_dep_amt                  IN       NUMBER
    , p_dep_amt_annual           IN       NUMBER
    , p_date_placed_in_service   IN       fa_books.date_placed_in_service%TYPE
    , p_life_in_months           IN       fa_books.life_in_months%TYPE
    , p_original_cost            IN       fa_books.original_cost%TYPE
    , p_asset_number             IN       fa_additions_b.asset_number%TYPE
    , p_description              IN       fa_additions.description%TYPE
    , p_tag_number               IN       fa_additions_b.tag_number%TYPE
    , p_serial_number            IN       fa_additions_b.serial_number%TYPE
    , p_location                 IN       fa_locations_kfv.concatenated_segments%TYPE
    , p_expense_account          IN       gl_code_combinations_kfv.concatenated_segments%TYPE
    , p_round_value              IN       NUMBER
    , p_deprn_value              IN       NUMBER
    , p_flag                     IN       VARCHAR2
   )
   IS
      CURSOR lcr_deprn_periods (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_period_name              IN       fa_deprn_periods.period_name%TYPE
      )
      /***********************************************************************
          *
          * CURSOR
          *  lcr_deprn_periods
          *
          * DESCRIPTION
          *  Cursor lcr_deprn_periods is a private cursor of procedure whatif_main.
          *  Cursor will return the end_date
          *
          * PARAMETERS
          * ==========
          * NAME               TYPE     DESCRIPTION
          * -----------------  -------- ------------------------------------------
          * p_book_type_code
          * p_period_name
          *             *
          * None
          *
          * PREREQUISITES
          *  None
          *
          * CALLED BY
          *  load
          *
          ***********************************************************************/
      IS
         SELECT fcp.end_date
         FROM   fa_calendar_periods fcp
              , fa_calendar_types fct
              , fa_book_controls fbc
         WHERE  fbc.book_type_code = p_book_type_code
         AND    fcp.calendar_type = fct.calendar_type
         AND    fcp.calendar_type = fbc.deprn_calendar
         AND    fcp.period_name = p_period_name;

      CURSOR lcr_end_date (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_period_name              IN       fa_deprn_periods.period_name%TYPE
       , p_counter                  IN       NUMBER
      )
      /***********************************************************************
          *
          * CURSOR
          *  lcr_end_date
          *
          * DESCRIPTION
          *  Cursor lcr_end_date is a private cursor of procedure whatif_main.
          *  Cursor will return the end_date
          *
          * PARAMETERS
          * ==========
          * NAME               TYPE     DESCRIPTION
          * -----------------  -------- ------------------------------------------
          * p_book_type_code
          * p_period_name
          *
          *
          * None
          *
          * PREREQUISITES
          *  None
          *
          * CALLED BY
          *  load
          *
          ***********************************************************************/
      IS
         SELECT LAST_DAY (ADD_MONTHS (fcp.end_date, p_counter))
         FROM   fa_calendar_periods fcp
              , fa_calendar_types fct
              , fa_book_controls fbc
         WHERE  fbc.book_type_code = p_book_type_code
         AND    fcp.calendar_type = fct.calendar_type
         AND    fcp.calendar_type = fbc.deprn_calendar
         AND    fcp.period_name = p_period_name;

      CURSOR lcr_distribution (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_asset_id                 IN       fa_books.asset_id%TYPE
      )
      /***********************************************************************
          *
          * CURSOR
          *  lcr_distribution
          *
          * DESCRIPTION
          *  Cursor lcr_distribution is a private cursor of procedure insert_fa_whatif_itf.
          *  Cursor will return distribution records
          *
          * PARAMETERS
          * ==========
          * NAME               TYPE     DESCRIPTION
          * -----------------  -------- ------------------------------------------
          * p_book_type_code
          * p_asset_id
          *
          *
          * None
          *
          * PREREQUISITES
          *  None
          *
          * CALLED BY
          *  insert_fa_whatif_itf
          *
          ***********************************************************************/
      IS
         SELECT fdh.units_assigned
              , papf.full_name
              , papf.employee_number
         FROM   fa_distribution_history fdh
              , per_all_people_f papf
              , fa_book_controls fbc
         WHERE  fbc.book_type_code = p_book_type_code
         AND    fdh.book_type_code = fbc.distribution_source_book
         AND    fdh.asset_id = p_asset_id
         AND    fdh.assigned_to = papf.person_id(+);

      CURSOR lcr_first_periods (
         p_book_type                IN       fa_books.book_type_code%TYPE
       , p_start_period             IN       fa_deprn_periods.period_name%TYPE
       , p_number_of_periods        IN       NUMBER
      )
      /***********************************************************************
      *
      * CURSOR
      *  lcr_first_periods
      *
      * DESCRIPTION
      *  Cursor lcr_first_periods is a private cursor of procedure whatif_main.
      *  Cursor will return the first eligible period for a particular Book Type and Period
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      *  p_book_type_code
      *  p_period_name
      *  p_number_of_periods
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  insert_fa_whatif_itf
      *
      ***********************************************************************/
      IS
         SELECT cp1.period_name
         FROM   fa_calendar_periods cp
              , fa_fiscal_year fy
              , fa_book_controls fb
              , fa_calendar_types fc
              , fa_calendar_periods cp1
         WHERE  cp.period_name = p_start_period
         AND    cp.calendar_type = fb.deprn_calendar
         AND    fb.book_type_code = p_book_type
         AND    cp.calendar_type = fc.calendar_type
         AND    cp.start_date >= fy.start_date
         AND    cp.end_date <= fy.end_date
         AND    fy.fiscal_year_name = fb.fiscal_year_name
         AND    cp1.period_num = 1
         AND    fb.deprn_calendar = cp1.calendar_type
         AND    cp1.start_date >= cp.start_date
         AND    ROWNUM = 1;

      CURSOR lcr_periods (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_end_date                 IN       DATE
      )
      /***********************************************************************
          *
          * CURSOR
          *  lcr_periods
          *
          * DESCRIPTION
          *  Cursor lcr_periods is a private cursor of procedure insert_fa_whatif_itf.
          *  Cursor will return the Peiord
          *
          * PARAMETERS
          * ==========
          * NAME               TYPE     DESCRIPTION
          * -----------------  -------- ------------------------------------------
          * p_book_type_code
          * p_end_date
          *
          *
          * None
          *
          * PREREQUISITES
          *  None
          *
          * CALLED BY
          *  insert_fa_whatif_itf
          *
          ***********************************************************************/
      IS
         SELECT fcp.period_name
         FROM   fa_calendar_periods fcp
              , fa_calendar_types fct
              , fa_book_controls fbc
         WHERE  fbc.book_type_code = p_book_type_code
         AND    fcp.calendar_type = fct.calendar_type
         AND    fcp.calendar_type = fbc.deprn_calendar
         AND    fcp.end_date = p_end_date;

      --
      -- Record type for whatif
      --
      TYPE t_whatif_period_rec IS RECORD (
         period_name                             fa_deprn_periods.period_name%TYPE
      );

      --
      -- Table type for for whatif
      --
      TYPE t_whatif_period_tbl IS TABLE OF t_whatif_period_rec
         INDEX BY BINARY_INTEGER;

      l_start_period_date                     DATE;
      l_first_period_date                     DATE;
      l_date                                  DATE;
      l_start_date                            DATE;
      l_last_date                             DATE;
      l_counter                               NUMBER;
      l_count                                 NUMBER;
      l_counter2                              NUMBER;
      l_deprn_value                           NUMBER;
      l_round_value                           NUMBER;
      l_sql_query                             VARCHAR2 (1000);
      l_sql_counter_query                     VARCHAR2 (1000);
      l_sql_query2                            VARCHAR2 (1000);
      l_first_eligible_period                 VARCHAR2 (15);
      l_start_period_name                     VARCHAR2 (15);
      l_period                                NUMBER;
      l_twelve_count                          NUMBER;
      l_greater_period                        fa_calendar_periods.period_name%TYPE;
      -- As per Bug 712836
      l_whatif_period_tbl                     t_whatif_period_tbl;
      l_whatif_period_tbl2                    t_whatif_period_tbl;
      l_end_date                              fa_calendar_periods.end_date%TYPE;
      h_asset_id                              NUMBER;
      lr_distribution                         lcr_distribution%ROWTYPE;
   BEGIN
      l_whatif_period_tbl2.DELETE;
      l_period                   := NULL;
      l_sql_query                := NULL;
      l_sql_query2               := NULL;
      l_counter2                 := 0;
      l_count                    := 0;
      l_deprn_value              := 0;
      l_round_value              := 0;
      l_twelve_count             := 1;

--**************************************
   -- Derive First Eligible Period Name
--**************************************
      OPEN lcr_first_periods (p_book_type_code
                            , p_first_begin_prd  -- Period When fully reserved
                            , p_number_of_periods
                             );

      FETCH lcr_first_periods
      INTO  l_first_eligible_period;

      CLOSE lcr_first_periods;


--*****************************
    -- Derive First eligible Date
 --*****************************
      OPEN lcr_deprn_periods (p_book_type_code, l_first_eligible_period);

      FETCH lcr_deprn_periods
      INTO  l_date;

      CLOSE lcr_deprn_periods;

--*****************************
    -- Derive Date
 --*****************************
      OPEN lcr_deprn_periods (p_book_type_code, p_period_name);

      FETCH lcr_deprn_periods
      INTO  l_start_period_date;

      CLOSE lcr_deprn_periods;

--*****************************
   -- Derive First Begin Period
--*****************************
      OPEN lcr_deprn_periods (p_book_type_code, p_first_begin_prd);

      FETCH lcr_deprn_periods
      INTO  l_first_period_date;

      CLOSE lcr_deprn_periods;

      --Fetch the Counter for duration Start Period to First Eligible period
      --Starts As per Bug No. 7289893

      l_sql_counter_query :=
         'SELECT months_between(''' || l_first_period_date
         || ''',''' || l_start_period_date
         || ''') counter
                    FROM DUAL';

      EXECUTE IMMEDIATE l_sql_counter_query
      INTO              l_count;

      EXECUTE IMMEDIATE l_sql_counter_query
      INTO              l_count;

--*****************************
   -- Derive the end date
--*****************************
      l_counter2                 := p_number_of_periods - l_count;

-- As per Bug 7128376
      IF l_first_period_date > l_start_period_date
      THEN
         -- l_greater_period := p_period_name;
         l_greater_period           := p_first_begin_prd;
      -- As per Bug No .7183390 (For Tax Books)
      -- As per Bug 7128376
      OPEN lcr_end_date
                   (p_book_type_code
                  , l_greater_period -- p_first_begin_prd -- As per Bug 712836
                  , l_counter2
                   );

      FETCH lcr_end_date
      INTO  l_end_date;

      CLOSE lcr_end_date;
      ELSIF l_first_period_date <= l_start_period_date
      THEN
         -- l_greater_period := p_first_begin_prd;
         l_greater_period           := p_period_name;
      -- As per Bug 7128376
      OPEN lcr_end_date
                   (p_book_type_code
                  , l_greater_period -- p_first_begin_prd -- As per Bug 712836
                  , p_number_of_periods
                   );

      FETCH lcr_end_date
      INTO  l_end_date;

      CLOSE lcr_end_date;
      -- As per Bug No .7183390 (For Tax Books)
      END IF;


      l_deprn_value              := p_deprn_value;

      --Starts As per Bug No. 7289893

      l_last_date := l_first_period_date;

      -- END  As per Bug No. 7289893

      SELECT DECODE (SIGN (l_first_period_date - l_start_period_date)
                   , -1, l_start_period_date
                   , l_first_period_date
                    )
      INTO   l_last_date
      FROM   DUAL;

      SELECT DECODE (SIGN (l_first_period_date - l_start_period_date)
                   , -1, l_first_period_date
                   , l_start_period_date
                    )
      INTO   l_start_date
      FROM   DUAL;

      IF p_flag = 'Y'
      THEN
         l_last_date                := l_date;
      END IF;
         --l_last_date                := l_date;


      IF     p_period_name <> p_first_begin_prd
         AND p_flag = 'N'
      THEN
         l_sql_query                :=
            'SELECT FCP.period_name
                        FROM   fa_calendar_periods FCP
                         , fa_calendar_types   FCT
                         , fa_book_controls    FBC
                        WHERE  FBC.book_type_code = '''
            || p_book_type_code
            || '''
                        AND    FCP.calendar_type   = FCT.calendar_type
                    AND    FCP.calendar_type   = FBC.deprn_calendar
                AND    FCP.end_date BETWEEN '''
            || l_start_date || ''' AND ''' || l_last_date || '''';

         EXECUTE IMMEDIATE l_sql_query
         BULK COLLECT INTO l_whatif_period_tbl;

         IF l_whatif_period_tbl.COUNT = 0
         THEN
            fnd_message.set_name ('OFA', 'FA_NO_DATA_FOUND_ERROR');
            x_errbuf                   := fnd_message.get;
            x_retcode                  := gn_error_status;
         END IF;

         IF p_checkbox_check = 'N'
         THEN
            OPEN lcr_distribution (p_book_type_code, p_asset_id);

            LOOP
               FETCH lcr_distribution
               INTO  lr_distribution;

               EXIT WHEN lcr_distribution%NOTFOUND;

               -- For loop to insert 0 in the periods between the start and first eligible period.
               FOR i IN 1 .. l_count
               LOOP
                  INSERT INTO fa_whatif_itf
                              (request_id
                             , book_type_code
                             , asset_id
                             , period_name
                             , depreciation
                             , new_depreciation
                             , current_method
                             , current_cost
                             , current_life
                             , units
                             , employee_name
                             , employee_number
                             , created_by
                             , creation_date
                             , last_update_date
                             , last_updated_by
                             , last_update_login
                             , date_placed_in_service
                             , asset_number
                             , description
                             , tag_number
                             , serial_number
                             , LOCATION
                             , expense_acct
                              )
                  VALUES      (p_request_id
                             , p_book_type_code
                             , p_asset_id
                             , l_whatif_period_tbl (i).period_name
                             , 0
                             , 0
                             , 'STL'
                             , p_original_cost
                             , p_life_in_months
                             , lr_distribution.units_assigned
                             , lr_distribution.full_name
                             , lr_distribution.employee_number
                             , gn_user_id
                             , SYSDATE
                             , SYSDATE
                             , gn_user_id
                             , gn_login_id
                             , p_date_placed_in_service
                             , p_asset_number
                             , p_description
                             , p_tag_number
                             , p_serial_number
                             , p_location
                             , p_expense_account
                              );

                  l_deprn_value              := l_deprn_value + 0;

                  UPDATE fa_whatif_itf
                  SET accumulated_deprn = l_deprn_value
                  WHERE  period_name = l_whatif_period_tbl (i).period_name
                  AND    book_type_code = p_book_type_code
                  AND    request_id = p_request_id;
               END LOOP;               -- FOR i IN 1..p_number_of_periods LOOP
            END LOOP;              --   OPEN lcr_distribution(p_book_type_code
         ELSE                               -- IF p_checkbox_check IS 'N' THEN
            FOR i IN 1 .. l_count
            LOOP
               l_deprn_value              := l_deprn_value + 0;

               UPDATE fa_whatif_itf
               SET depreciation = 0
                 , new_depreciation = 0
                 , units = lr_distribution.units_assigned
                 , employee_name = lr_distribution.full_name
                 , employee_number = lr_distribution.employee_number
                 , accumulated_deprn = l_deprn_value           --p_deprn_value
               WHERE  period_name = l_whatif_period_tbl (i).period_name
               AND    book_type_code = p_book_type_code
               AND    request_id = p_request_id
               AND    asset_id = p_asset_id;
/*

IF i = 61 THEN
          l_round_value := p_round_value*60;

         UPDATE fa_whatif_itf
           SET    depreciation      = p_round_value*5
                  , new_depreciation  = p_round_value*5
                  , units             = lr_distribution.units_assigned
        , employee_name     = lr_distribution.full_name
              , employee_number   = lr_distribution.employee_number
              , accumulated_deprn = l_deprn_value - l_round_value
           WHERE  period_name       = l_whatif_period_tbl2(i).period_name
           AND    book_type_code    = p_book_type_code
           AND    request_id        = p_request_id;
END IF;
 */
            END LOOP;
         END IF;                            -- IF p_checkbox_check IS 'N' THEN
      END IF;                   -- IF  p_period_name <> p_first_begin_prd THEN

      l_sql_query2               :=
         'SELECT FCP.period_name
                        FROM   fa_calendar_periods FCP
                         , fa_calendar_types   FCT
                         , fa_book_controls    FBC
                        WHERE  FBC.book_type_code = '''
         || p_book_type_code
         || '''
                        AND    FCP.calendar_type   = FCT.calendar_type
                    AND    FCP.calendar_type   = FBC.deprn_calendar
                AND    FCP.end_date BETWEEN '''
         || l_date || ''' AND ''' || l_end_date || '''';
                                                         --l_first_period_date

      EXECUTE IMMEDIATE l_sql_query2
      BULK COLLECT INTO l_whatif_period_tbl2;

      IF l_start_period_date <= l_first_period_date THEN
       l_count := 0;
      ELSE
        select round(months_between(l_start_period_date, l_first_period_date),0)
        INTO l_count
        FROM DUAL;
      END IF;

      IF l_whatif_period_tbl2.COUNT = 0
      THEN
         fnd_message.set_name ('OFA', 'FA_NO_DATA_FOUND_ERROR');
         x_errbuf                   := fnd_message.get;
         x_retcode                  := gn_error_status;
      END IF;

-- Get period NAme
      OPEN lcr_periods (p_book_type_code, l_last_date);

      FETCH lcr_periods
      INTO  l_start_period_name;

      CLOSE lcr_periods;

      l_period                   :=
                              chk_period (p_first_begin_prd, p_book_type_code);

      IF p_checkbox_check = 'N'
      THEN
         OPEN lcr_distribution (p_book_type_code, p_asset_id);

         LOOP
            FETCH lcr_distribution
            INTO  lr_distribution;

            EXIT WHEN lcr_distribution%NOTFOUND;

-- For loop to insert 0 in the periods between the first eligible period till the period counter ends
            FOR i IN 1 .. l_counter2
            LOOP
               INSERT INTO fa_whatif_itf
                           (request_id
                          , book_type_code
                          , asset_id
                          , period_name
                          , depreciation
                          , new_depreciation
                          , current_method
                          , current_cost
                          , current_life
                          , units
                          , employee_name
                          , employee_number
                          , created_by
                          , creation_date
                          , last_update_date
                          , last_updated_by
                          , last_update_login
                          , date_placed_in_service
                          , asset_number
                          , description
                          , tag_number
                          , serial_number
                          , LOCATION
                          , expense_acct
                           )
               VALUES      (p_request_id
                          , p_book_type_code
                          , p_asset_id
                          , l_whatif_period_tbl2 (i).period_name
                          , p_dep_amt
                          , p_dep_amt
                          , 'STL'
                          , p_original_cost
                          , p_life_in_months
                          , lr_distribution.units_assigned
                          , lr_distribution.full_name
                          , lr_distribution.employee_number
                          , gn_user_id
                          , SYSDATE
                          , SYSDATE
                          , gn_user_id
                          , gn_login_id
                          , p_date_placed_in_service
                          , p_asset_number
                          , p_description
                          , p_tag_number
                          , p_serial_number
                          , p_location
                          , p_expense_account
                           );

               l_deprn_value              := l_deprn_value + p_dep_amt;

               UPDATE fa_whatif_itf
               SET accumulated_deprn = l_deprn_value
               WHERE  period_name = l_whatif_period_tbl2 (i).period_name
               AND    book_type_code = p_book_type_code
               AND    request_id = p_request_id;
            END LOOP;                  -- FOR i IN 1..p_number_of_periods LOOP
         END LOOP;                    --OPEN lcr_distribution(p_book_type_code
      ELSE        --IF p_checkbox_check IS 'N' THEN  -- p_checkbox_check = 'Y'
         FOR i IN 1+l_count .. (l_counter2+l_count)
         LOOP
            IF i > (61+l_count)
            THEN                        --(l_count + i) has been changed to i
               UPDATE fa_whatif_itf
               SET depreciation = 0
                 , new_depreciation = 0
                 , units = lr_distribution.units_assigned
                 , employee_name = lr_distribution.full_name
                 , employee_number = lr_distribution.employee_number
                 , accumulated_deprn = l_deprn_value
               WHERE  period_name = l_whatif_period_tbl2 (i-l_count).period_name
               AND    book_type_code = p_book_type_code
               AND    request_id = p_request_id
               AND    asset_id = p_asset_id;
            ELSIF     i = (61 + l_count)
                  AND l_period <> 12 * l_twelve_count
            THEN                         --(l_count + i) has been changed to i
               -- l_round_value := p_round_value*60;
               UPDATE fa_whatif_itf
               SET depreciation = p_round_value * 5          --l_round_value*5
                 , new_depreciation = p_round_value * 5
                 , units = lr_distribution.units_assigned
                 , employee_name = lr_distribution.full_name
                 , employee_number = lr_distribution.employee_number
                 , accumulated_deprn = l_deprn_value - l_round_value
               WHERE  period_name = l_whatif_period_tbl2 (i-l_count).period_name
               AND    book_type_code = p_book_type_code
               AND    request_id = p_request_id
               AND    asset_id = p_asset_id;
            ELSIF     i <= (60+l_count)
                  AND l_period <> 12 * l_twelve_count
            THEN                       ----(l_count + i) has been changed to i
               UPDATE fa_whatif_itf
               SET depreciation = p_dep_amt
                 , new_depreciation = p_dep_amt
                 , units = lr_distribution.units_assigned
                 , employee_name = lr_distribution.full_name
                 , employee_number = lr_distribution.employee_number
                 , accumulated_deprn = l_deprn_value
               WHERE  period_name = l_whatif_period_tbl2 (i-l_count).period_name
               AND    book_type_code = p_book_type_code
               AND    request_id = p_request_id
               AND    asset_id = p_asset_id;
            ELSIF l_period = 12 * l_twelve_count
            THEN
               UPDATE fa_whatif_itf
               SET depreciation = (FLOOR (p_dep_amt_annual) - p_dep_amt * 11)
                 , new_depreciation =
                                   (FLOOR (p_dep_amt_annual) - p_dep_amt * 11
                                   )
                 , units = lr_distribution.units_assigned
                 , employee_name = lr_distribution.full_name
                 , employee_number = lr_distribution.employee_number
                 , accumulated_deprn = l_deprn_value - l_round_value
               WHERE  period_name = l_whatif_period_tbl2 (i-l_count).period_name
               AND    book_type_code = p_book_type_code
               AND    request_id = p_request_id
               AND    asset_id = p_asset_id;

               l_twelve_count             := l_twelve_count + 1;
            ELSE
               NULL;
            END IF;

            l_period                   := l_period + 1;
         END LOOP;
      END IF;                                --IF p_checkbox_check IS 'N' THEN

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END insert_fa_whatif_itf;

   PROCEDURE whatif_main (
      x_errbuf                   OUT NOCOPY VARCHAR2
    , x_retcode                  OUT NOCOPY NUMBER
    , p_request_id               IN       NUMBER
    , p_book_type_code           IN       fa_books.book_type_code%TYPE
    , p_first_begin_period       IN       VARCHAR2
    , p_number_of_periods        IN       NUMBER
    , p_start_period             IN       VARCHAR2
    , p_checkbox_check           IN       VARCHAR2
    , p_full_rsrv_checkbox       IN       VARCHAR2
    , p_asset_id                 IN       NUMBER
   )
   IS
      CURSOR lcr_profile_option (
         p_option_name              IN       VARCHAR2
      )
      /***********************************************************************
      *
      * CURSOR
      *  lcr_receipts_details
      *
      * DESCRIPTION
      *  Cursor lcr_receipts_details is a private cursor of procedure whatif_main.
      *  Cursor will return the Profile option associated with the profile option name
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      * p_option_name
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  whatif_main
      *
      ***********************************************************************/
      IS
         SELECT user_profile_option_name
         FROM   fnd_profile_options_vl
         WHERE  profile_option_name = p_option_name;

      CURSOR lcr_books (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_asset_id                 IN       fa_books.asset_id%TYPE
      )
      /***********************************************************************
      *
      * CURSOR
        lcr_books
      *
      * DESCRIPTION
      *  Cursor lcr_books is a private cursor of procedure whatif_main.
      *  Cursor will return only the  Book Details which are Active for a particular Book Type
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      * p_book_type_code
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  whatif_main
      *
      ***********************************************************************/
      IS

      --BUG#  7331249 The Below Query has been changed as, this query is not returning data ,
      --when Period_counter_fully_reserved is not in FA_deprn_periods table.
         SELECT fb.book_type_code
              , cp.period_name
              , fy.fiscal_year
              , fb.asset_id
              , fb.last_update_date
              , fb.last_updated_by
              , fb.last_update_login
              , fb.original_cost
              , fb.life_in_months
              , fb.date_placed_in_service
              , fb.period_counter_fully_reserved
              , fa.asset_number
              , fa.description
              , fa.tag_number
              , fa.serial_number
              , flk.concatenated_segments LOCATION
              , gcck.concatenated_segments expense_account
              , (fb.allowed_deprn_limit_amount - 1) / 5
                - FLOOR ((fb.allowed_deprn_limit_amount - 1) / 5) round_value
              --  , CEIL(((FB.cost - FB.salvage_value)*FB.basic_rate)/12) Deprn_Value
         ,      ROUND ((fb.allowed_deprn_limit_amount - 1) / 60) deprn_value
              , (fb.allowed_deprn_limit_amount - 1) / 5 annual_deprn_value
         FROM   fa_books fb
              , fa_book_controls fbc
               ,fa_calendar_periods cp
              , fa_fiscal_year fy
              , fa_calendar_types fct
              , fa_additions fa
              , fa_distribution_history fdh
              , fa_locations_kfv flk
              , gl_code_combinations_kfv gcck
         WHERE  fa.asset_id = fb.asset_id
         AND    fb.asset_id = p_asset_id
         AND    fdh.asset_id = fa.asset_id
         --    AND   FDH.book_type_code               = FB.book_type_code -- As per Bug No .7183390 (For Tax Books)
         AND    fbc.book_type_code = fb.book_type_code
         -- As per Bug No .7183390 (For Tax Books)
         AND    fbc.distribution_source_book = fdh.book_type_code
         -- As per Bug No .7183390 (For Tax Books)
         AND    fdh.location_id = flk.location_id
         AND    gcck.code_combination_id = fdh.code_combination_id
         AND    fb.book_type_code = p_book_type_code
         AND    cp.calendar_type = fbc.deprn_calendar
         AND    fy.fiscal_year_name = fbc.fiscal_year_name
         AND    cp.calendar_type = fct.calendar_type
         AND    cp.start_date >= fy.start_date
                and cp.end_date  <= fy.end_date
         AND    fb.period_counter_fully_reserved = (fy.fiscal_year * fct.number_per_fiscal_year + cp.period_num)
         AND    fb.date_ineffective IS NULL
         AND    fb.transaction_header_id_out IS NULL
         AND    fdh.transaction_header_id_out IS NULL
         -- As per Bug No .7183390 (For Tax Books)
         AND    fb.period_counter_fully_reserved IS NOT NULL
         AND    fb.deprn_method_code <> 'JP-STL-EXTND'
         AND    fb.allowed_deprn_limit_amount > 1;

      CURSOR lcr_deprn_periods (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_period_name              IN       fa_deprn_periods.period_name%TYPE
      )
      /***********************************************************************
      *
      * CURSOR
      *  lcr_deprn_periods
      *
      * DESCRIPTION
      *  Cursor lcr_deprn_periods is a private cursor of procedure whatif_main.
      *  Cursor will return the period for a particular Book Type and Period
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      *  p_book_type_code
      *  p_period_name
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  whatif_main
      *
      ***********************************************************************/
      IS
         SELECT fdp.period_counter
         FROM   fa_deprn_periods fdp
         WHERE  fdp.book_type_code = p_book_type_code
         AND    fdp.period_name = p_period_name;

      CURSOR lcr_first_periods (
         p_book_type                IN       fa_books.book_type_code%TYPE
       , p_start_period             IN       fa_deprn_periods.period_name%TYPE
       , p_number_of_periods        IN       NUMBER
      )
      /***********************************************************************
      *
      * CURSOR
      *  lcr_first_periods
      *
      * DESCRIPTION
      *  Cursor lcr_first_periods is a private cursor of procedure whatif_main.
      *  Cursor will return the first eligible period for a particular Book Type and Period
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      *  p_book_type_code
      *  p_period_name
      *  p_number_of_periods
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  whatif_main
      *
      ***********************************************************************/
      IS
         --As per Bug No. 7289893 . The SQL statement was failing if p_number_of_periods = 1

         SELECT cp1.period_name
         FROM   fa_calendar_periods cp
              , fa_fiscal_year fy
              , fa_book_controls fb
              , fa_calendar_types fc
              , fa_calendar_periods cp1
         WHERE  cp.period_name = p_start_period
         AND    cp.calendar_type = fb.deprn_calendar
         AND    fb.book_type_code = p_book_type
         AND    cp.calendar_type = fc.calendar_type
         AND    cp.start_date >= fy.start_date
         AND    cp.end_date <= fy.end_date
         AND    fy.fiscal_year_name = fb.fiscal_year_name
         AND    cp1.period_num = 1
         AND    fb.deprn_calendar = cp1.calendar_type
         AND    cp1.start_date > cp.start_date
         AND    ROWNUM = 1;

      CURSOR lcr_deprn_amount (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_asset_id                 IN       fa_books.asset_id%TYPE
       , p_period_counter           IN       NUMBER
      )
      /***********************************************************************
      *
      * CURSOR
      *  lcr_deprn_amount
      *
      * DESCRIPTION
      *  Cursor lcr_deprn_amount is a private cursor of procedure whatif_main.
      *  Cursor will return the Depreciation Amount for a particular Book Type and Period
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      *  p_book_type_code
      *  p_period_name
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  whatif_main
      *
      ***********************************************************************/
      IS
         SELECT CEIL ((fb.COST - fds.deprn_reserve) / 60)
         FROM   fa_books fb
              , fa_deprn_summary fds
         WHERE  fds.book_type_code = fb.book_type_code
         AND    fb.asset_id = fds.asset_id
         AND    fds.period_counter = p_period_counter
         AND    fb.asset_id = p_asset_id
         AND    fb.book_type_code = p_book_type_code
         AND    fb.transaction_header_id_out IS NULL;

      -- condition modified from date_ineffective
      CURSOR lcr_end_date (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_period_name              IN       fa_deprn_periods.period_name%TYPE
       , p_counter                  IN       NUMBER
      )
      /***********************************************************************
          *
          * CURSOR
          *  lcr_end_date
          *
          * DESCRIPTION
          *  Cursor lcr_end_date is a private cursor of procedure whatif_main.
          *  Cursor will return the end_date
          *
          * PARAMETERS
          * ==========
          * NAME               TYPE     DESCRIPTION
          * -----------------  -------- ------------------------------------------
          * p_book_type_code
          * p_period_name
          *
          *
          * None
          *
          * PREREQUISITES
          *  None
          *
          * CALLED BY
          *  whatif_main
          *
          ***********************************************************************/
      IS
         SELECT LAST_DAY (ADD_MONTHS (fcp.end_date, p_counter))
         FROM   fa_calendar_periods fcp
              , fa_calendar_types fct
              , fa_book_controls fbc
         WHERE  fbc.book_type_code = p_book_type_code
         AND    fcp.calendar_type = fct.calendar_type
         AND    fcp.calendar_type = fbc.deprn_calendar
         AND    fcp.period_name = p_period_name;

      CURSOR lcr_periods (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_end_date                 IN       DATE
      )
      /***********************************************************************
          *
          * CURSOR
          *  lcr_periods
          *
          * DESCRIPTION
          *  Cursor lcr_deprn_periods is a private cursor of procedure whatif_main.
          *  Cursor will return the Peiord
          *
          * PARAMETERS
          * ==========
          * NAME               TYPE     DESCRIPTION
          * -----------------  -------- ------------------------------------------
          * p_book_type_code
          * p_end_date
          *
          *
          * None
          *
          * PREREQUISITES
          *  None
          *
          * CALLED BY
          *  whatif_main
          *
          ***********************************************************************/
      IS
         SELECT fcp.period_name
         FROM   fa_calendar_periods fcp
              , fa_calendar_types fct
              , fa_book_controls fbc
         WHERE  fbc.book_type_code = p_book_type_code
         AND    fcp.calendar_type = fct.calendar_type
         AND    fcp.calendar_type = fbc.deprn_calendar
         AND    fcp.end_date = p_end_date;

      l_req_id                                fa_whatif_itf.request_id%TYPE;
      l_sob                                   fa_book_controls.set_of_books_id%TYPE;
      l_fully_reserved_flag                   VARCHAR2 (1);
      lc_return                               BOOLEAN;
      l_profile_tax_reform                    VARCHAR2 (100);
      ln_setof_bk_id                          NUMBER;
      lc_errmsg                               VARCHAR2 (4000);
      ln_retcode                              NUMBER;
      l_end_date                              DATE;
      ln_acc_deprn                            NUMBER;
      ln_first_elg_period                     NUMBER;
      ln_first_beg_period                     NUMBER;
      l_period                                fa_deprn_periods.period_name%TYPE;
      l_profile_option                        fnd_profile_options_vl.user_profile_option_name%TYPE;
      l_period_counter                        fa_deprn_periods.period_counter%TYPE;
      l_period_full_counter                   fa_deprn_periods.period_counter%TYPE;
      l_period_apr07_counter                  fa_deprn_periods.period_counter%TYPE;
      l_period_name                           fa_deprn_periods.period_name%TYPE;
      l_first_eligible_period                 fa_deprn_periods.period_name%TYPE
                                                                       := NULL;
      l_deprn_amount                          NUMBER;
      lr_books                                lcr_books%ROWTYPE;
      ex_user_exception                       EXCEPTION;
      p_debug_flag                            VARCHAR2 (1) DEFAULT 'N';
   BEGIN
--*****Check Profile Option*****************
-- Get the Profile Option
      l_profile_tax_reform       :=
                                   fnd_profile.VALUE ('FA_JAPAN_TAX_REFORMS');

--Accumulated Depreciation
      BEGIN
      /* bug 8991192
         SELECT deprn_reserve
         INTO   ln_acc_deprn
         FROM   (SELECT   ROWNUM a
                        , deprn_reserve
                 FROM     fa_deprn_summary
                 WHERE    book_type_code = p_book_type_code
                 AND      asset_id = p_asset_id
                 ORDER BY deprn_reserve DESC)
         WHERE  ROWNUM = 1;
       */
         SELECT max(nvl(deprn_reserve,0))
         INTO   ln_acc_deprn
         FROM   fa_deprn_summary
         WHERE  book_type_code = p_book_type_code
         AND    asset_id = p_asset_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            x_retcode                  := gn_error_status;
            x_errbuf                   := lc_errmsg;
      END;

--*****************************
   -- Derive Period Counter
--*****************************
      OPEN lcr_deprn_periods (p_book_type_code, p_first_begin_period);

      FETCH lcr_deprn_periods
      INTO  l_period_counter;

      CLOSE lcr_deprn_periods;

-- *****Check whether the asset is Fully Reserved*****
      IF l_profile_tax_reform = 'Y'
      THEN                                                            --Step 1
         IF p_checkbox_check IN (('YES'), ('Y'))
         THEN                                                       -- Step 2
            l_period_full_counter      := NULL;

            OPEN lcr_books (p_book_type_code, p_asset_id);

            LOOP
               FETCH lcr_books
               INTO  lr_books;

               EXIT WHEN lcr_books%NOTFOUND;

--**************************************
   -- Derive First Eligible Period Name
--**************************************
               OPEN lcr_first_periods
                           (p_book_type_code
                          , lr_books.period_name -- Period When fully reserved
                          , p_number_of_periods
                           );

               FETCH lcr_first_periods
               INTO  l_first_eligible_period;

               CLOSE lcr_first_periods;


--*****************************
   -- Derive Depreciation Amount
--*****************************
               OPEN lcr_deprn_amount (p_book_type_code
                                    , lr_books.asset_id
                                    , lr_books.period_counter_fully_reserved
                                     );

               FETCH lcr_deprn_amount
               INTO  l_deprn_amount;

               CLOSE lcr_deprn_amount;


               ln_first_elg_period        :=
                       ret_counter (p_book_type_code, l_first_eligible_period);
               ln_first_beg_period        :=
                          ret_counter (p_book_type_code, p_first_begin_period);

               --Step 3 Validation for Date Placed in Service
               IF lr_books.date_placed_in_service <
                                          TO_DATE ('01-04-2007', 'DD-MM-RRRR')
               THEN
                  IF p_first_begin_period IS NOT NULL
                  THEN
                     -- STEP 5 VALIDATION using the concept for Period Counter
                      --  IF (TO_DATE(l_first_eligible_period,'MM-RRRR') > TO_DATE(p_first_begin_period,'MM-RRRR') ) THEN
                     IF ln_first_elg_period > ln_first_beg_period
                     THEN
                        --Step 8 Insert data into FA_WHATIF_ITF
                        insert_fa_whatif_itf
                           (x_errbuf                      => lc_errmsg
                          , x_retcode                     => ln_retcode
                          , p_request_id                  => p_request_id
                          , p_checkbox_check              => p_full_rsrv_checkbox
                          , p_book_type_code              => p_book_type_code
                          , p_number_of_periods           => p_number_of_periods
                          , p_asset_id                    => lr_books.asset_id
                          , p_period_name                 => p_start_period
                          , p_first_begin_prd             => l_first_eligible_period
                                                        --lr_books.period_name
                          --  ,p_dep_amt                => l_deprn_amount
                        ,   p_dep_amt                     => lr_books.deprn_value
                          , p_dep_amt_annual              => lr_books.annual_deprn_value
                          , p_date_placed_in_service      => lr_books.date_placed_in_service
                          , p_life_in_months              => lr_books.life_in_months
                          , p_original_cost               => lr_books.original_cost
                          , p_asset_number                => lr_books.asset_number
                          , p_description                 => lr_books.description
                          , p_tag_number                  => lr_books.tag_number
                          , p_serial_number               => lr_books.serial_number
                          , p_location                    => lr_books.LOCATION
                          , p_expense_account             => lr_books.expense_account
                          , p_round_value                 => lr_books.round_value
                          , p_deprn_value                 => ln_acc_deprn
                          --ln_acc_deprnlr_books.Deprn_Value
                        ,   p_flag                        => 'N'
                           );

                        IF ln_retcode <> 1
                        THEN
                           RAISE ex_user_exception;
                        END IF;
                     ELSE
                        --Calculating extended depreciation starting from the first period provided in the form
                        --Step 8 Insert data into FA_WHATIF_ITF
                        insert_fa_whatif_itf
                           (x_errbuf                      => lc_errmsg
                          , x_retcode                     => ln_retcode
                          , p_request_id                  => p_request_id
                          , p_checkbox_check              => p_full_rsrv_checkbox
                          , p_book_type_code              => p_book_type_code
                          , p_number_of_periods           => p_number_of_periods
                          , p_asset_id                    => lr_books.asset_id
                          , p_period_name                 => p_start_period
                          --lr_books.period_name
                        ,   p_first_begin_prd             => p_first_begin_period
                          --   ,p_dep_amt                => l_deprn_amount
                        ,   p_dep_amt                     => lr_books.deprn_value
                          , p_dep_amt_annual              => lr_books.annual_deprn_value
                          , p_date_placed_in_service      => lr_books.date_placed_in_service
                          , p_life_in_months              => lr_books.life_in_months
                          , p_original_cost               => lr_books.original_cost
                          , p_asset_number                => lr_books.asset_number
                          , p_description                 => lr_books.description
                          , p_tag_number                  => lr_books.tag_number
                          , p_serial_number               => lr_books.serial_number
                          , p_location                    => lr_books.LOCATION
                          , p_expense_account             => lr_books.expense_account
                          , p_round_value                 => lr_books.round_value
                          , p_deprn_value                 => ln_acc_deprn
                          --lr_books.Deprn_Value
                        ,   p_flag                        => 'N'
                           );

                        IF ln_retcode <> 1
                        THEN
                           RAISE ex_user_exception;
                        END IF;
                     END IF;
                           --IF (p_first_begin_period > p_end_asset_date) THEN
                  --Step 6 calculate depreciation projections based on  Period When Fully Reserved
                  ELSE             -- IF p_first_begin_period IS NOT NULL THEN
                     --Step 8 Insert data into FA_WHATIF_ITF

                     insert_fa_whatif_itf
                        (x_errbuf                      => lc_errmsg
                       , x_retcode                     => ln_retcode
                       , p_request_id                  => p_request_id
                       , p_checkbox_check              => p_full_rsrv_checkbox
                       , p_book_type_code              => p_book_type_code
                       , p_number_of_periods           => p_number_of_periods
                       , p_asset_id                    => lr_books.asset_id
                       , p_period_name                 => p_start_period
                       , p_first_begin_prd             => l_first_eligible_period
                                                        --lr_books.period_name
                       --   ,p_dep_amt                => l_deprn_amount
                     ,   p_dep_amt                     => lr_books.deprn_value
                       , p_dep_amt_annual              => lr_books.annual_deprn_value
                       , p_date_placed_in_service      => lr_books.date_placed_in_service
                       , p_life_in_months              => lr_books.life_in_months
                       , p_original_cost               => lr_books.original_cost
                       , p_asset_number                => lr_books.asset_number
                       , p_description                 => lr_books.description
                       , p_tag_number                  => lr_books.tag_number
                       , p_serial_number               => lr_books.serial_number
                       , p_location                    => lr_books.LOCATION
                       , p_expense_account             => lr_books.expense_account
                       , p_round_value                 => lr_books.round_value
                       , p_deprn_value                 => ln_acc_deprn
                       --lr_books.Deprn_Value
                     ,   p_flag                        => 'N'
                        );

                     IF ln_retcode <> 1
                     THEN
                        RAISE ex_user_exception;
                     END IF;
                  END IF;          -- IF p_first_begin_period IS NOT NULL THEN
               ELSE
                  fnd_message.set_name ('OFA', 'FA_SERVICE_DATE_INVALID');
                  lc_errmsg                  := fnd_message.get;
                  RAISE ex_user_exception;
               END IF;
--fnd_date.canonical_to_date(lr_books.date_placed_in_service) < fnd_date.canonical_to_date('01-APR-2007')
            END LOOP;
         END IF;                --IF p_checkbox_check IN (('YES'),('Y'))) THEN
      END IF;                             --IF l_profile_tax_reform = 'Y' THEN
   EXCEPTION
      WHEN ex_user_exception
      THEN
         x_retcode                  := gn_error_status;
         x_errbuf                   := lc_errmsg;
         fnd_file.put_line (fnd_file.output, x_errbuf);
         fnd_file.put_line (fnd_file.LOG, x_errbuf);
      WHEN OTHERS
      THEN
         x_retcode                  := gn_error_status;
         x_errbuf                   := lc_errmsg;
         ROLLBACK;
   END whatif_main;

   PROCEDURE extd_deprn_main (
      x_errbuf                   OUT NOCOPY VARCHAR2
    , x_retcode                  OUT NOCOPY NUMBER
    , p_request_id               IN       NUMBER
    , p_book_type_code           IN       fa_books.book_type_code%TYPE
    , p_first_begin_period       IN       VARCHAR2
    , p_number_of_periods        IN       NUMBER
    , p_start_period             IN       VARCHAR2
    , p_checkbox_check           IN       VARCHAR2
    , p_full_rsrv_checkbox       IN       VARCHAR2
    , p_asset_id                 IN       NUMBER
   )
   IS
      CURSOR lcr_profile_option (
         p_option_name              IN       VARCHAR2
      )
      /***********************************************************************
      *
      * CURSOR
      *  lcr_receipts_details
      *
      * DESCRIPTION
      *  Cursor lcr_receipts_details is a private cursor of procedure whatif_main.
      *  Cursor will return the Profile option associated with the profile option name
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      * p_option_name
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  extd_deprn_main
      *
      ***********************************************************************/
      IS
         SELECT user_profile_option_name
         FROM   fnd_profile_options_vl
         WHERE  profile_option_name = p_option_name;

      CURSOR lcr_books (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_asset_id                 IN       fa_books.asset_id%TYPE
      )
      /***********************************************************************
      *
      * CURSOR
        lcr_books
      *
      * DESCRIPTION
      *  Cursor lcr_books is a private cursor of procedure whatif_main.
      *  Cursor will return only the  Book Details which are Active for a particular Book Type
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      * p_book_type_code
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  extd_deprn_main
      *
      ***********************************************************************/
      IS
         SELECT fb.book_type_code
              , fb.COST                                              -- change
              , fb.basic_rate                                        -- change
              , fb.asset_id
              , fb.last_update_date
              , fb.last_updated_by
              , fb.last_update_login
              , fb.original_cost
              , fb.life_in_months
              , fb.date_placed_in_service
              , fb.period_counter_fully_reserved
              , fa.asset_number
              , fa.description
              , fa.tag_number
              , fa.serial_number
              , flk.concatenated_segments LOCATION
              , gcck.concatenated_segments expense_account
              --    ,(CEIL(((FB.cost - FB.salvage_value)*FB.basic_rate)/12)-((FB.cost - FB.salvage_value)*FB.basic_rate)/12) Round_Value
                  --   , CEIL(((FB.cost - FB.salvage_value)*FB.basic_rate)/12) Acc_Deprn_Value
                 --    ,CEIL((FB.allowed_deprn_limit_amount -1)/60) Deprn_value
         ,      (fb.allowed_deprn_limit_amount - 1) / 5
                - FLOOR ((fb.allowed_deprn_limit_amount - 1) / 5) round_value
              , ROUND ((fb.allowed_deprn_limit_amount - 1) / 60) deprn_value
              , (fb.allowed_deprn_limit_amount - 1) / 5 annual_deprn_value
              , fb.adjusted_cost
              , fb.allowed_deprn_limit_amount
         FROM   fa_books fb
              , fa_book_controls fbc -- As per Bug No .7183390 (For Tax Books)
              , fa_additions fa
              , fa_distribution_history fdh
              , fa_locations_kfv flk
              , gl_code_combinations_kfv gcck
         WHERE  fa.asset_id = fb.asset_id
         AND    fb.asset_id = p_asset_id
         AND    fdh.asset_id = fa.asset_id
         --    AND   FDH.book_type_code               = FB.book_type_code -- As per Bug No .7183390 (For Tax Books)
         AND    fbc.book_type_code = fb.book_type_code
         -- As per Bug No .7183390 (For Tax Books)
         AND    fbc.distribution_source_book = fdh.book_type_code
         -- As per Bug No .7183390 (For Tax Books)
         AND    fdh.location_id = flk.location_id
         AND    gcck.code_combination_id = fdh.code_combination_id
         AND    fb.book_type_code = p_book_type_code
         AND    fb.date_ineffective IS NULL
         AND    fb.transaction_header_id_out IS NULL
         AND    fb.period_counter_fully_reserved IS NULL
         AND    fdh.transaction_header_id_out IS NULL
         -- As per Bug No .7183390 (For Tax Books)
         AND    fb.deprn_method_code <> 'JP-STL-EXTND'
         AND    fb.allowed_deprn_limit_amount > 1;

      CURSOR lcr_deprn_periods (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_period_name              IN       fa_deprn_periods.period_name%TYPE
      )
      /***********************************************************************
      *
      * CURSOR
      *  lcr_deprn_periods
      *
      * DESCRIPTION
      *  Cursor lcr_deprn_periods is a private cursor of procedure whatif_main.
      *  Cursor will return the period for a particular Book Type and Period
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      *  p_book_type_code
      *  p_period_name
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  extd_deprn_main
      *
      ***********************************************************************/
      IS
         SELECT fdp.period_counter
         FROM   fa_deprn_periods fdp
         WHERE  fdp.book_type_code = p_book_type_code
         AND    fdp.period_name = p_period_name;

      CURSOR lcr_first_periods (
         p_book_type                IN       fa_books.book_type_code%TYPE
       , p_start_period             IN       fa_deprn_periods.period_name%TYPE
       , p_number_of_periods        IN       NUMBER
      )
      /***********************************************************************
      *
      * CURSOR
      *  lcr_first_periods
      *
      * DESCRIPTION
      *  Cursor lcr_first_periods is a private cursor of procedure whatif_main.
      *  Cursor will return the first eligible period for a particular Book Type and Period
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      *  p_book_type_code
      *  p_period_name
      *  p_number_of_periods
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  extd_deprn_main
      *
      ***********************************************************************/
      IS
         SELECT cp1.period_name
         FROM   fa_calendar_periods cp
              , fa_fiscal_year fy
              , fa_book_controls fb
              , fa_calendar_types fc
              , fa_calendar_periods cp1
         WHERE  cp.period_name = p_start_period
         AND    cp.calendar_type = fb.deprn_calendar
         AND    fb.book_type_code = p_book_type
         AND    cp.calendar_type = fc.calendar_type
         AND    cp.start_date >= fy.start_date
         AND    cp.end_date <= fy.end_date
         AND    fy.fiscal_year_name = fb.fiscal_year_name
         AND    cp1.period_num = 1
         AND    fb.deprn_calendar = cp1.calendar_type
         AND    cp1.start_date >= cp.start_date     -- BUG# 7264516: Added = condition
         AND    ROWNUM = 1;

      CURSOR lcr_deprn_amount (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_asset_id                 IN       fa_books.asset_id%TYPE
       , p_period_counter           IN       NUMBER
      )
      /***********************************************************************
      *
      * CURSOR
      *  lcr_deprn_amount
      *
      * DESCRIPTION
      *  Cursor lcr_deprn_amount is a private cursor of procedure whatif_main.
      *  Cursor will return the Depreciation Amount for a particular Book Type and Period
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      *  p_book_type_code
      *  p_period_name
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  extd_deprn_main
      *
      ***********************************************************************/
      IS
         SELECT CEIL ((fb.COST - fds.deprn_reserve) / 60)
         -- need to change for variable
         FROM   fa_books fb
              , fa_deprn_summary fds
         WHERE  fds.book_type_code = fb.book_type_code
         AND    fb.asset_id = fds.asset_id
         AND    fds.period_counter = p_period_counter
         AND    fb.asset_id = p_asset_id
         AND    fb.book_type_code = p_book_type_code
         AND    fb.transaction_header_id_out IS NULL;

      -- condition modified from date_ineffective
      CURSOR lcr_end_date_check (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_period_name              IN       fa_deprn_periods.period_name%TYPE
       , p_counter                  IN       NUMBER
      )
      /***********************************************************************
          *
          * CURSOR
          *  lcr_end_date_check
          *
          * DESCRIPTION
          *  Cursor lcr_end_date_check is a private cursor of procedure whatif_main.
          *  Cursor will return the end_date
          *
          * PARAMETERS
          * ==========
          * NAME               TYPE     DESCRIPTION
          * -----------------  -------- ------------------------------------------
          * p_book_type_code
          * p_period_name
          * p_counter
          *
          *
          * None
          *
          * PREREQUISITES
          *  None
          *
          * CALLED BY
          *  extd_deprn_main
          *
          ***********************************************************************/
      IS
         SELECT LAST_DAY (ADD_MONTHS (fcp.end_date, p_counter))
         FROM   fa_calendar_periods fcp
              , fa_calendar_types fct
              , fa_book_controls fbc
         WHERE  fbc.book_type_code = p_book_type_code
         AND    fcp.calendar_type = fct.calendar_type
         AND    fcp.calendar_type = fbc.deprn_calendar
         AND    fcp.period_name = p_period_name;

      CURSOR lcr_end_date_validate (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_end_date                 IN       fa_calendar_periods.end_date%TYPE
       , p_counter                  IN       NUMBER
      )
      /***********************************************************************
          *
          * CURSOR
          *  lcr_end_date_check
          *
          * DESCRIPTION
          *  Cursor lcr_end_date_check is a private cursor of procedure whatif_main.
          *  Cursor will return the end_date
          *
          * PARAMETERS
          * ==========
          * NAME               TYPE     DESCRIPTION
          * -----------------  -------- ------------------------------------------
          * p_book_type_code
          * p_end_date
          * p_counter
          *
          *
          * None
          *
          * PREREQUISITES
          *  None
          *
          * CALLED BY
          *  extd_deprn_main
          *
          ***********************************************************************/
      IS
         SELECT LAST_DAY (ADD_MONTHS (fcp.end_date, p_counter))
         FROM   fa_calendar_periods fcp
              , fa_calendar_types fct
              , fa_book_controls fbc
         WHERE  fbc.book_type_code = p_book_type_code
         AND    fcp.calendar_type = fct.calendar_type
         AND    fcp.calendar_type = fbc.deprn_calendar
         AND    p_end_date BETWEEN fcp.start_date AND fcp.end_date;

      CURSOR lcr_periods (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_end_date                 IN       DATE
      )
      /***********************************************************************
          *
          * CURSOR
          *  lcr_periods
          *
          * DESCRIPTION
          *  Cursor lcr_deprn_periods is a private cursor of procedure whatif_main.
          *  Cursor will return the Peiord
          *
          * PARAMETERS
          * ==========
          * NAME               TYPE     DESCRIPTION
          * -----------------  -------- ------------------------------------------
          * p_book_type_code
          * p_end_date
          *
          *
          * None
          *
          * PREREQUISITES
          *  None
          *
          * CALLED BY
          *  extd_deprn_main
          *
          ***********************************************************************/
      IS
         SELECT fcp.period_name
         FROM   fa_calendar_periods fcp
              , fa_calendar_types fct
              , fa_book_controls fbc
         WHERE  fbc.book_type_code = p_book_type_code
         AND    fcp.calendar_type = fct.calendar_type
         AND    fcp.calendar_type = fbc.deprn_calendar
         AND    fcp.end_date = p_end_date;

      CURSOR lcr_extd_deprns (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_period_name              IN       fa_deprn_periods.period_name%TYPE
      )
      /***********************************************************************
          *
          * CURSOR
          *  lcr_extd_deprns
          *
          * DESCRIPTION
          *  Cursor lcr_deprn_periods is a private cursor of procedure whatif_main.
          *  Cursor will return the end_date
          *
          * PARAMETERS
          * ==========
          * NAME               TYPE     DESCRIPTION
          * -----------------  -------- ------------------------------------------
          * p_book_type_code
          * p_period_name
          *             *
          * None
          *
          * PREREQUISITES
          *  None
          *
          * CALLED BY
          *  load
          *
          ***********************************************************************/
      IS
         SELECT fcp.end_date
         FROM   fa_calendar_periods fcp
              , fa_calendar_types fct
              , fa_book_controls fbc
         WHERE  fbc.book_type_code = p_book_type_code
         AND    fcp.calendar_type = fct.calendar_type
         AND    fcp.calendar_type = fbc.deprn_calendar
         AND    fcp.period_name = p_period_name;

      CURSOR lcr_dern_method (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_asset_id                 IN       fa_books.asset_id%TYPE
      )
      /***********************************************************************
      *
      * CURSOR
        lcr_dern_method
      *
      * DESCRIPTION
      *  Cursor lcr_dern_method is a private cursor of procedure whatif_main.
      *  Cursor will return the deprn method code which are Active for a particular Book Type
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      * p_book_type_code
      * p_asset_id
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  extd_deprn_main
      *
      ***********************************************************************/
      IS
         SELECT fb.deprn_method_code
         FROM   fa_books fb
         WHERE  fb.book_type_code = p_book_type_code
         AND    fb.asset_id = p_asset_id
         AND    fb.date_ineffective IS NULL
         AND    fb.transaction_header_id_out IS NULL
         AND    fb.deprn_method_code LIKE '%STL%';

      l_req_id                                fa_whatif_itf.request_id%TYPE;
      l_sob                                   fa_book_controls.set_of_books_id%TYPE;
      l_fully_reserved_flag                   VARCHAR2 (1);
      lc_return                               BOOLEAN;
      l_profile_tax_reform                    VARCHAR2 (100);
      ln_setof_bk_id                          NUMBER;
      lc_errmsg                               VARCHAR2 (4000);
      ln_retcode                              NUMBER;
      l_end_date                              DATE;
      l_end_date_validate                     DATE;
      l_end_date_check                        DATE;
      l_extd_period_name                      VARCHAR2 (10);
      l_extended_date                         DATE;
      l_period                                fa_deprn_periods.period_name%TYPE;
      l_profile_option                        fnd_profile_options_vl.user_profile_option_name%TYPE;
      l_period_counter                        fa_deprn_periods.period_counter%TYPE;
      l_period_full_counter                   fa_deprn_periods.period_counter%TYPE;
      l_period_apr07_counter                  fa_deprn_periods.period_counter%TYPE;
      l_period_name                           fa_deprn_periods.period_name%TYPE;
      l_first_eligible_period                 fa_deprn_periods.period_name%TYPE;
      l_deprn_amount                          NUMBER;
      l_per                                   NUMBER;
      l_count                                 NUMBER := 1;
      ln_acc_deprn                            NUMBER;
      ln_acc_deprn1                           NUMBER;
      lc_period                               VARCHAR2 (10);
      l_date_extn_end                         DATE;
      l_exit                                  NUMBER := 0;
      ln_first_elg_period                     NUMBER;
      ln_first_beg_period                     NUMBER;
      ln_int_deprn                            fa_deprn_summary.deprn_reserve%TYPE;
      l_deprn_method                          fa_books.deprn_method_code%TYPE;
      l_amt                                   NUMBER;
      l_temp                                  NUMBER;
      lr_books                                lcr_books%ROWTYPE;
      ex_user_exception                       EXCEPTION;
      p_debug_flag                            VARCHAR2 (1) DEFAULT 'N';
      ln_start_period_count                   NUMBER;
      ln_period_count                         NUMBER;
   BEGIN
      l_date_extn_end            := NULL;
      ln_acc_deprn               := NULL;
      l_extended_date            := NULL;
      gn_acc_deprn               := 0;
      --*****Check Profile Option*****************

      -- Get the Profile Option
      l_profile_tax_reform       :=
                                   fnd_profile.VALUE ('FA_JAPAN_TAX_REFORMS');

      SELECT period_name
      INTO   lc_period
      FROM   fa_deprn_periods
      WHERE  book_type_code = p_book_type_code
      AND    period_close_date IS NULL;

--As per the Bug 7210341
      ln_period_count        :=
                       ret_counter (p_book_type_code, lc_period);
      ln_start_period_count  :=
                       ret_counter (p_book_type_code, p_start_period);

      l_temp := ln_period_count - ln_start_period_count;

--As per the Bug 7210341
    /*  SELECT MONTHS_BETWEEN (TO_DATE (lc_period, 'MM-RRRR')
                           , TO_DATE (p_start_period, 'MM-RRRR'))
      INTO   l_temp
      FROM   DUAL;
    */
      IF l_temp > 0
      THEN
         l_temp                     := p_number_of_periods - l_temp;
         lc_period                  := lc_period;
      ELSE
         l_temp                     := p_number_of_periods;
         lc_period                  := p_start_period;
      END IF;

--*****************************
   -- Derive Period Counter
--*****************************
      OPEN lcr_extd_deprns (p_book_type_code, lc_period);

      FETCH lcr_extd_deprns
      INTO  l_date_extn_end;

      CLOSE lcr_extd_deprns;

--*****************************
   -- Derive Method Code
--*****************************
      OPEN lcr_dern_method (p_book_type_code, p_asset_id);

      FETCH lcr_dern_method
      INTO  l_deprn_method;

      CLOSE lcr_dern_method;

      OPEN lcr_books (p_book_type_code, p_asset_id);

      LOOP
         FETCH lcr_books
         INTO  lr_books;

         EXIT WHEN lcr_books%NOTFOUND;

         OPEN lcr_end_date_check (p_book_type_code
                                , lc_period
                                , p_number_of_periods
                                 );

         FETCH lcr_end_date_check
         INTO  l_end_date_check;

         CLOSE lcr_end_date_check;

         BEGIN
            SELECT deprn_reserve
            INTO   ln_acc_deprn1               --ln_acc_deprn (Bug No.6968798)
            FROM   (SELECT   ROWNUM a
                           , deprn_reserve
                    FROM     fa_deprn_summary
                    WHERE    book_type_code = p_book_type_code
                    AND      asset_id = lr_books.asset_id
                    ORDER BY deprn_reserve DESC)
            WHERE  ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               x_retcode                  := gn_error_status;
               x_errbuf                   := lc_errmsg;
         END;

         gn_acc_deprn               := gn_acc_deprn + ln_acc_deprn1;
         l_per                      :=
                                      chk_period (lc_period, p_book_type_code);

         IF l_exit = 0
         THEN
            FOR i IN 1 .. l_temp
            LOOP
               IF l_deprn_method IS NOT NULL
               THEN                                      -- ( For STL Method)
                  IF gn_acc_deprn <=
                        (lr_books.COST - lr_books.allowed_deprn_limit_amount
                        )
                  THEN
                     ln_acc_deprn := (lr_books.adjusted_cost * lr_books.basic_rate)/12; -- Bug#8628718
                    -- ln_acc_deprn               :=
                    --               (lr_books.COST * lr_books.basic_rate
                    --               ) / 12;
                     gn_acc_deprn               := gn_acc_deprn + ln_acc_deprn;
                  ELSIF gn_acc_deprn >
                          (lr_books.COST - lr_books.allowed_deprn_limit_amount
                          )
                  THEN
                     BEGIN
                        SELECT ADD_MONTHS (l_date_extn_end, i-1)
                        -- SELECT ADD_MONTHS(l_date_extn_end,i-1) (For Bug : 6971130)
                        INTO   l_extended_date
                        FROM   DUAL;

                        IF l_extended_date IS NOT NULL
                        THEN
                           l_exit                     := l_exit + 1;
                           EXIT;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           x_retcode                  := gn_error_status;
                           x_errbuf                   := lc_errmsg;
                     END;
                  END IF;  --IF gn_acc_deprn <> lr_books.recoverable_cost THEN
               ELSE     -- IF l_deprn_method IS NOT NULL THEN ( For DB Method)
                  IF gn_acc_deprn <=
                        (lr_books.COST - lr_books.allowed_deprn_limit_amount
                        )
                  THEN
                     IF l_per = (12 * l_count + 1)
                     THEN
                        ln_int_deprn               :=
                           ((lr_books.COST - gn_acc_deprn)
                            * lr_books.basic_rate
                           )
                           / 12;
                        l_count                    := l_count + 1;

                        IF ln_int_deprn IS NULL
                        THEN
                           --  ln_acc_deprn := (lr_books.adjusted_cost * lr_books.basic_rate)/12;-- (Bug No.6968798)
                           ln_acc_deprn               :=
                              ((lr_books.COST - ln_acc_deprn1)
                               * lr_books.basic_rate
                              )
                              / 12;
                        ELSE
                           ln_acc_deprn               := ln_int_deprn;
                        END IF;

                        gn_acc_deprn               :=
                                                   gn_acc_deprn + ln_acc_deprn;
                     ELSIF l_per <> (12 * l_count + 1)
                     THEN
                        IF ln_int_deprn IS NULL
                        THEN
                           --  ln_acc_deprn := (lr_books.adjusted_cost * lr_books.basic_rate)/12;-- (Bug No.6968798)
                           ln_acc_deprn               :=
                              ((lr_books.COST - ln_acc_deprn1)
                               * lr_books.basic_rate
                              )
                              / 12;
                        ELSIF ln_int_deprn IS NOT NULL
                        THEN
                           ln_acc_deprn               := ln_int_deprn;
                        END IF;

                        gn_acc_deprn               :=
                                                   gn_acc_deprn + ln_acc_deprn;
                     END IF;                            --IF l_per = 12   THEN
                  ELSIF gn_acc_deprn >
                          (lr_books.COST - lr_books.allowed_deprn_limit_amount
                          )
                  THEN
                     BEGIN
                        SELECT ADD_MONTHS (l_date_extn_end, i-1)
                        --SELECT ADD_MONTHS(l_date_extn_end,i-1) (For Bug : 6971130)
                        INTO   l_extended_date
                        FROM   DUAL;

                        IF l_extended_date IS NOT NULL
                        THEN
                           l_exit                     := l_exit + 1;
                           EXIT;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           x_retcode                  := gn_error_status;
                           x_errbuf                   := lc_errmsg;
                     END;
                  END IF;  --IF gn_acc_deprn <> lr_books.recoverable_cost THEN

                  l_per                      := l_per + 1;
               END IF;                   -- IF l_deprn_method IS NOT NULL THEN
            END LOOP;

            IF l_extended_date IS NOT NULL
            THEN
               EXIT;
            END IF;
         END IF;                                          --IF l_exit = 0 THEN
      END LOOP;

--*****************************
   -- Derive Period end date
--*****************************
      OPEN lcr_deprn_periods (p_book_type_code, p_first_begin_period);

      FETCH lcr_deprn_periods
      INTO  l_period_counter;

      CLOSE lcr_deprn_periods;

      IF lcr_books%ISOPEN
      THEN
         CLOSE lcr_books;
      END IF;

      -- *****Check whether the asset is Fully Reserved*****
      IF l_profile_tax_reform = 'Y'
      THEN                                                            --Step 1
         IF p_checkbox_check IN (('YES'), ('Y'))
         THEN                                                       -- Step 2
            l_period_full_counter      := NULL;

            OPEN lcr_books (p_book_type_code, p_asset_id);

            LOOP
               FETCH lcr_books
               INTO  lr_books;

               EXIT WHEN lcr_books%NOTFOUND;

--*****************************
   -- Derive Depreciation Amount
--*****************************
               OPEN lcr_deprn_amount (p_book_type_code
                                    , lr_books.asset_id
                                    , lr_books.period_counter_fully_reserved
                                     );

               FETCH lcr_deprn_amount
               INTO  l_deprn_amount;

               CLOSE lcr_deprn_amount;

               -- Step 4: Derive End Date for the period when the Extended depreciation is scheduled to start
               OPEN lcr_end_date_validate (p_book_type_code
                                         , l_extended_date
                                         , 1              -- Bug#8626718:Passing pc next to fully reserved pc.
                                          );

               FETCH lcr_end_date_validate
               INTO  l_end_date_validate;

               CLOSE lcr_end_date_validate;

               -- Step 4: Derive End Date for the period when p_number_of_periods parameter ends starting from start period
               OPEN lcr_end_date_check (p_book_type_code
                                      , lc_period
                                      , p_number_of_periods
                                       );

               FETCH lcr_end_date_check
               INTO  l_end_date_check;

               CLOSE lcr_end_date_check;

               OPEN lcr_periods (p_book_type_code, l_end_date_validate);

               FETCH lcr_periods
               INTO  l_extd_period_name;

               CLOSE lcr_periods;

--**************************************p
   -- Derive First Eligible Period Name
--**************************************
               OPEN lcr_first_periods (p_book_type_code
                                     , l_extd_period_name
                                     --p_start_period -- Period When fully reserved
                   ,                   p_number_of_periods
                                      );

               FETCH lcr_first_periods
               INTO  l_first_eligible_period;

               CLOSE lcr_first_periods;

               ln_first_elg_period        :=
                       ret_counter (p_book_type_code, l_first_eligible_period);
               ln_first_beg_period        :=
                          ret_counter (p_book_type_code, p_first_begin_period);

               --Step 3 Validation for Date Placed in Service
               IF lr_books.date_placed_in_service <
                                          TO_DATE ('01-04-2007', 'DD-MM-RRRR')
               THEN
                  IF l_end_date_check > l_end_date_validate
                  THEN                                              -- Step 4
                     IF p_first_begin_period IS NOT NULL
                     THEN
                        -- STEP 5 VALIDATION using the concept for Period Counter
                            --IF (TO_DATE(l_first_eligible_period,'MM-RRRR') > TO_DATE(p_first_begin_period,'MM-RRRR') ) THEN
                        IF ln_first_elg_period > ln_first_beg_period
                        THEN
                           --Step 8 Insert data into FA_WHATIF_ITF
                           insert_fa_whatif_itf
                              (x_errbuf                      => lc_errmsg
                             , x_retcode                     => ln_retcode
                             , p_request_id                  => p_request_id
                             , p_checkbox_check              => p_full_rsrv_checkbox
                             , p_book_type_code              => p_book_type_code
                             , p_number_of_periods           => p_number_of_periods
                             , p_asset_id                    => lr_books.asset_id
                             , p_period_name                 => lc_period
                             , p_first_begin_prd             => l_first_eligible_period
                             --lr_books.period_name
                           ,   p_dep_amt                     => lr_books.deprn_value
                             --l_deprn_amount
                           ,   p_dep_amt_annual              => lr_books.annual_deprn_value
                             , p_date_placed_in_service      => lr_books.date_placed_in_service
                             , p_life_in_months              => lr_books.life_in_months
                             , p_original_cost               => lr_books.original_cost
                             , p_asset_number                => lr_books.asset_number
                             , p_description                 => lr_books.description
                             , p_tag_number                  => lr_books.tag_number
                             , p_serial_number               => lr_books.serial_number
                             , p_location                    => lr_books.LOCATION
                             , p_expense_account             => lr_books.expense_account
                             , p_round_value                 => lr_books.round_value
                             , p_deprn_value                 => ln_acc_deprn
                             --lr_books.Acc_Deprn_Value
                           ,   p_flag                        => 'Y'
                              );

                           IF ln_retcode <> 1
                           THEN
                              RAISE ex_user_exception;
                           END IF;
                        ELSE
                           --Calculating extended depreciation starting from the first period provided in the form
                           --Step 8 Insert data into FA_WHATIF_ITF
                           insert_fa_whatif_itf
                              (x_errbuf                      => lc_errmsg
                             , x_retcode                     => ln_retcode
                             , p_request_id                  => p_request_id
                             , p_checkbox_check              => p_full_rsrv_checkbox
                             , p_book_type_code              => p_book_type_code
                             , p_number_of_periods           => p_number_of_periods
                             , p_asset_id                    => lr_books.asset_id
                             , p_period_name                 => lc_period
                             --lr_books.period_name
                           ,   p_first_begin_prd             => p_first_begin_period
                             , p_dep_amt                     => lr_books.deprn_value
                             --l_deprn_amount
                           ,   p_dep_amt_annual              => lr_books.annual_deprn_value
                             , p_date_placed_in_service      => lr_books.date_placed_in_service
                             , p_life_in_months              => lr_books.life_in_months
                             , p_original_cost               => lr_books.original_cost
                             , p_asset_number                => lr_books.asset_number
                             , p_description                 => lr_books.description
                             , p_tag_number                  => lr_books.tag_number
                             , p_serial_number               => lr_books.serial_number
                             , p_location                    => lr_books.LOCATION
                             , p_expense_account             => lr_books.expense_account
                             , p_round_value                 => lr_books.round_value
                             , p_deprn_value                 => ln_acc_deprn
                             --lr_books.Acc_Deprn_Value
                           ,   p_flag                        => 'Y'
                              );

                           IF ln_retcode <> 1
                           THEN
                              RAISE ex_user_exception;
                           END IF;
                        END IF;
                           --IF (p_first_begin_period > p_end_asset_date) THEN
                     --Step 6 calculate depreciation projections based on  Period When Fully Reserved
                     ELSE          -- IF p_first_begin_period IS NOT NULL THEN
                        --Step 8 Insert data into FA_WHATIF_ITF
                        insert_fa_whatif_itf
                           (x_errbuf                      => lc_errmsg
                          , x_retcode                     => ln_retcode
                          , p_request_id                  => p_request_id
                          , p_checkbox_check              => p_full_rsrv_checkbox
                          , p_book_type_code              => p_book_type_code
                          , p_number_of_periods           => p_number_of_periods
                          , p_asset_id                    => lr_books.asset_id
                          , p_period_name                 => lc_period
                          --p_start_period
                        ,   p_first_begin_prd             => l_first_eligible_period
                          --lr_books.period_name
                        ,   p_dep_amt                     => lr_books.deprn_value
                          --l_deprn_amount
                        ,   p_dep_amt_annual              => lr_books.annual_deprn_value
                          , p_date_placed_in_service      => lr_books.date_placed_in_service
                          , p_life_in_months              => lr_books.life_in_months
                          , p_original_cost               => lr_books.original_cost
                          , p_asset_number                => lr_books.asset_number
                          , p_description                 => lr_books.description
                          , p_tag_number                  => lr_books.tag_number
                          , p_serial_number               => lr_books.serial_number
                          , p_location                    => lr_books.LOCATION
                          , p_expense_account             => lr_books.expense_account
                          , p_round_value                 => lr_books.round_value
                          , p_deprn_value                 => ln_acc_deprn
                          --lr_books.Acc_Deprn_Value
                        ,   p_flag                        => 'Y'
                           );

                        IF ln_retcode <> 1
                        THEN
                           RAISE ex_user_exception;
                        END IF;
                     END IF;       -- IF p_first_begin_period IS NOT NULL THEN
                  END IF;        --IF l_end_date_check > l_end_date_check THEN
               END IF;
            --IF lr_books.date_placed_in_service < TO_DATE('01-04-2007','DD-MM-RRRR')
            END LOOP;
         END IF;                --IF p_checkbox_check IN (('YES'),('Y'))) THEN
      END IF;                             --IF l_profile_tax_reform = 'Y' THEN
   EXCEPTION
      WHEN ex_user_exception
      THEN
         x_retcode                  := gn_error_status;
         x_errbuf                   := lc_errmsg;
         fnd_file.put_line (fnd_file.output, x_errbuf);
         fnd_file.put_line (fnd_file.LOG, x_errbuf);
      WHEN OTHERS
      THEN
         x_retcode                  := gn_error_status;
         x_errbuf                   := lc_errmsg;
         ROLLBACK;
   END extd_deprn_main;

   PROCEDURE deprn_main (
      x_errbuf                   OUT NOCOPY VARCHAR2
    , x_retcode                  OUT NOCOPY NUMBER
    , p_request_id               IN       NUMBER
    , p_book_type_code           IN       fa_books.book_type_code%TYPE
    , p_first_begin_period       IN       VARCHAR2
    , p_number_of_periods        IN       NUMBER
    , p_start_period             IN       VARCHAR2
    , p_checkbox_check           IN       VARCHAR2
    , p_full_rsrv_checkbox       IN       VARCHAR2
    , p_asset_id                 IN       NUMBER
   )
   IS
      CURSOR lcr_books (
         p_book_type_code           IN       fa_books.book_type_code%TYPE
       , p_asset_id                 IN       fa_books.asset_id%TYPE
      )
      /***********************************************************************
      *
      * CURSOR
        lcr_books
      *
      * DESCRIPTION
      *  Cursor lcr_books is a private cursor of procedure whatif_main.
      *  Cursor will return only the  Book Details which are Active for a particular Book Type
      *
      * PARAMETERS
      * ==========
      * NAME               TYPE     DESCRIPTION
      * -----------------  -------- ------------------------------------------
      * p_book_type_code
      *
      *
      * None
      *
      * PREREQUISITES
      *  None
      *
      * CALLED BY
      *  deprn_main
      *
      ***********************************************************************/
      IS
         SELECT fb.period_counter_fully_reserved
              , fb.asset_id
         FROM   fa_books fb
         WHERE  fb.book_type_code = p_book_type_code
         AND    fb.date_ineffective IS NULL
         AND    fb.transaction_header_id_out IS NULL
         AND    fb.asset_id = p_asset_id
         AND    fb.deprn_method_code <> 'JP-STL-EXTND'
         AND    fb.allowed_deprn_limit_amount > 1;

      lr_books                                lcr_books%ROWTYPE;
      lc_errmsg                               VARCHAR2 (4000);
      ln_retcode                              NUMBER;
      ex_user_exception                       EXCEPTION;
   BEGIN
      OPEN lcr_books (p_book_type_code, p_asset_id);

      LOOP
         FETCH lcr_books
         INTO  lr_books;

         EXIT WHEN lcr_books%NOTFOUND;

         IF lr_books.period_counter_fully_reserved IS NOT NULL
         THEN
            whatif_main (x_errbuf                      => lc_errmsg
                       , x_retcode                     => ln_retcode
                       , p_request_id                  => p_request_id
                       , p_book_type_code              => p_book_type_code
                       , p_first_begin_period          => p_first_begin_period
                       , p_number_of_periods           => p_number_of_periods
                       , p_start_period                => p_start_period
                       , p_checkbox_check              => p_checkbox_check
                       , p_full_rsrv_checkbox          => p_full_rsrv_checkbox
                       , p_asset_id                    => lr_books.asset_id
                        );

            IF ln_retcode <> 1
            THEN
               RAISE ex_user_exception;
            END IF;
         ELSE
            extd_deprn_main (x_errbuf                      => lc_errmsg
                           , x_retcode                     => ln_retcode
                           , p_request_id                  => p_request_id
                           , p_book_type_code              => p_book_type_code
                           , p_first_begin_period          => p_first_begin_period
                           , p_number_of_periods           => p_number_of_periods
                           , p_start_period                => p_start_period
                           , p_checkbox_check              => p_checkbox_check
                           , p_full_rsrv_checkbox          => p_full_rsrv_checkbox
                           , p_asset_id                    => lr_books.asset_id
                            );

            IF ln_retcode <> 1
            THEN
               RAISE ex_user_exception;
            END IF;
         END IF; -- IF lr_books.period_counter_fully_reserved IS NOT NULL THEN
      END LOOP;
   EXCEPTION
      WHEN ex_user_exception
      THEN
         x_retcode                  := gn_error_status;
         x_errbuf                   := lc_errmsg;
         fnd_file.put_line (fnd_file.output, x_errbuf);
         fnd_file.put_line (fnd_file.LOG, x_errbuf);
   END deprn_main;

   PROCEDURE calc_jp250db (
      x_request_id                        NUMBER
    , x_asset_id                          NUMBER
    , x_book                              VARCHAR2
    , x_method                            VARCHAR2
    , x_cost                              NUMBER
    , x_cur_cost                          NUMBER
    , x_life                              NUMBER
    , x_rate_in_use                       NUMBER
    , x_deprn_lmt                         NUMBER
    , x_start_prd                         VARCHAR2
    , x_dtin_serv                         VARCHAR2
    , x_num_per                           NUMBER
   )
   IS
      CURSOR lcu_assets (
         x_reuest_id                         NUMBER
       , x_book                              VARCHAR2
       , x_asset_id                          NUMBER
       , x_dep                               NUMBER
      )
      IS
         SELECT   request_id
                , book_type_code
                , asset_id
                , asset_number
                , description
                , tag_number
                , serial_number
                , period_name
                , fiscal_year
                , expense_acct
                , LOCATION
                , units
                , employee_name
                , employee_number
                , asset_key
                , current_cost
                , current_prorate_conv
                , current_method
                , current_life
                , current_basic_rate
                , current_adjusted_rate
                , current_salvage_value
                , depreciation
                , new_depreciation
                , created_by
                , creation_date
                , last_update_date
                , last_updated_by
                , last_update_login
                , date_placed_in_service
                , CATEGORY
                , accumulated_deprn
                , bonus_depreciation
                , new_bonus_depreciation
                , current_bonus_rule
                , period_num
                , currency_code
         FROM     fa_whatif_itf
         WHERE    request_id = x_request_id
         AND      book_type_code = x_book
         AND      asset_id = x_asset_id
         AND      EXISTS (
                     SELECT fiscal_year
                     FROM   fa_whatif_itf
                     WHERE  request_id = x_request_id
                     AND    book_type_code = x_book
                     AND    asset_id = x_asset_id)
         ORDER BY fiscal_year ASC;

      CURSOR lcu_periods (
         x_book_type                         VARCHAR2
       , x_start_period                      VARCHAR2
       , x_num_periods                       NUMBER
      )
      IS
         SELECT cp1.period_name period_name
              , fa_jp_tax_extn_pvt.ret_counter (x_book_type, cp1.period_name)
                                                                      counter
              , cp1.period_num
              , bc.fiscal_year_name
         FROM   fa_calendar_periods cp
              , fa_book_controls bc
              , fa_deprn_periods dp
              , fa_calendar_periods cp1
              , (SELECT MAX (cp.start_date) max_start_date
                 FROM   fa_calendar_periods cp
                      , fa_calendar_periods cp1
                      , fa_book_controls bc
                      , fa_deprn_periods dp
                 WHERE  dp.book_type_code = x_book_type
                 AND    dp.period_close_date IS NULL
                 AND    dp.calendar_period_open_date <= cp.start_date
                 AND    cp.calendar_type = bc.deprn_calendar
                 AND    bc.book_type_code = x_book_type
                 AND    bc.deprn_calendar = cp1.calendar_type
                 AND    cp.start_date >= cp1.start_date
                 AND    cp1.period_name = x_start_period
                 AND    ROWNUM <= x_num_periods) x
         WHERE  dp.book_type_code = x_book_type
         AND    dp.period_close_date IS NULL
         AND    dp.calendar_period_open_date <= cp.start_date
         AND    cp.calendar_type = bc.deprn_calendar
         AND    bc.book_type_code = x_book_type
         AND    bc.deprn_calendar = cp1.calendar_type
         AND    cp1.start_date >= cp.start_date
         AND    cp.period_name = x_start_period
         AND    cp1.start_date <= x.max_start_date;

      CURSOR lcu_backdt_ast (
         x_book_type                         VARCHAR2
      )
      IS
         SELECT th.asset_id
         FROM   fa_calendar_periods cp
              , fa_deprn_periods dp
              , fa_transaction_headers th
              , fa_book_controls bc
         WHERE  dp.book_type_code = bc.book_type_code
         AND    cp.calendar_type = bc.deprn_calendar
         AND    th.book_type_code = dp.book_type_code
         AND    th.transaction_date_entered BETWEEN cp.start_date AND cp.end_date
         AND    th.date_effective BETWEEN dp.period_open_date
                                      AND NVL (dp.period_close_date
                                             , th.date_effective)
         AND    bc.book_type_code = x_book_type
         AND    cp.period_name <> dp.period_name
         AND    th.transaction_type_code = 'ADDITION';

      lt_nbv_typ                              tp_nbv_typ;
      l_nop                                   NUMBER;
      h_nop                                   NUMBER;
      h_cntr1                                 BINARY_INTEGER := 1;
      h_cntr2                                 BINARY_INTEGER := 1;
      h_per                                   NUMBER;
      h_orig_rate                             NUMBER;
      h_rev_rate                              NUMBER;
      h_guarant_rate                          NUMBER;
      ln_nbv                                  NUMBER;
      ln_nbv1                                 NUMBER;
      ln_temp3                                NUMBER;
      lc_period                               VARCHAR2 (30);
      h_period                                VARCHAR2 (30);
      l_dep                                   NUMBER;
      g_dep                                   NUMBER;
      ln_acc_deprn                            NUMBER := 0;
      ln_int_deprn                            NUMBER := 0;
      gn_acc_deprn                            NUMBER := 0;
      l_gnacc_deprn                           NUMBER := 0;    -- added to chk life end depreciation #7174535
      l_temp                                  NUMBER;
      gn_deprn                                NUMBER;
      h_rate                                  NUMBER;
      h_cost                                  NUMBER;
      ln_temp1                                NUMBER;
      l_ct                                    NUMBER;
      h_rate_in_use                           NUMBER;
      l_cnt                                   NUMBER := 1;
      l_cnt1                                  NUMBER := 1;
      l_tmp                                   NUMBER := 1;
      l_tmp4                                  NUMBER := 1;
      ln_dep_dumy                             NUMBER := 0;
      l_cnt2                                  NUMBER := 0;
      l_dtin_serv                             VARCHAR2 (15);
      l_dtcntr                                NUMBER;
      l_strt_cntr                             NUMBER;
      l_opn_cntr                              NUMBER;
      h_period_cnt                            NUMBER;
      l_end_percnt                            NUMBER;
      ln_stcnt                                NUMBER;
      y_dep                                   NUMBER;
      l_per_dum                               NUMBER;
      l_count_dum                             NUMBER := 0;
      h_cache                                 BOOLEAN;
      l_bdast_flg                             NUMBER := 0;
   BEGIN
      IF     x_book IS NOT NULL
         AND fnd_profile.VALUE ('FA_JAPAN_TAX_REFORMS') = 'Y'
      THEN
         h_cache                    :=
                                      fa_cache_pkg.fazccmt (x_method, x_life);
         lt_whatitf.DELETE;
         lt_nbv_typ.DELETE;
         h_rate_in_use              := x_rate_in_use;
         h_orig_rate                :=
                                    fa_cache_pkg.fazcfor_record.original_rate;
         h_rev_rate                 :=
                                     fa_cache_pkg.fazcfor_record.revised_rate;
         h_guarant_rate             :=
                                   fa_cache_pkg.fazcfor_record.guarantee_rate;

         BEGIN
            SELECT number_per_fiscal_year
            INTO   h_nop
            FROM   fa_calendar_types fc
                 , fa_book_controls fb
            WHERE  fc.calendar_type = fb.deprn_calendar
            AND    fb.book_type_code = x_book;
         END;

         h_cost                     :=
                                  ROUND ((x_cost * h_guarant_rate) / h_nop, 0);

         -- load all periods into temp plsql table
         FOR lc_asset IN lcu_assets (x_request_id
                                   , x_book
                                   , x_asset_id
                                   , h_cost
                                    )
         LOOP
            EXIT WHEN lcu_assets%NOTFOUND;
            lt_whatitf (h_cntr2).request_id := lc_asset.request_id;
            lt_whatitf (h_cntr2).book_type_code := lc_asset.book_type_code;
            lt_whatitf (h_cntr2).asset_id := lc_asset.asset_id;
            lt_whatitf (h_cntr2).asset_number := lc_asset.asset_number;
            lt_whatitf (h_cntr2).period_name := lc_asset.period_name;
            lt_whatitf (h_cntr2).period_counter :=
                                   ret_counter (x_book, lc_asset.period_name);
            lt_whatitf (h_cntr2).fiscal_year := lc_asset.fiscal_year;
            lt_whatitf (h_cntr2).units := lc_asset.units;
            lt_whatitf (h_cntr2).current_method := lc_asset.current_method;
            lt_whatitf (h_cntr2).current_life := lc_asset.current_life;
            lt_whatitf (h_cntr2).depreciation := lc_asset.depreciation;
            lt_whatitf (h_cntr2).new_depreciation :=
                                                    lc_asset.new_depreciation;
            lt_whatitf (h_cntr2).date_placed_in_service :=
                                              lc_asset.date_placed_in_service;
            lt_whatitf (h_cntr2).accumulated_deprn :=
                                                   lc_asset.accumulated_deprn;
            lt_whatitf (h_cntr2).period_num := lc_asset.period_num;
            h_cntr2                    := h_cntr2 + 1;
         END LOOP;

         BEGIN
            SELECT period_name
            INTO   lc_period
            FROM   fa_deprn_periods
            WHERE  book_type_code = x_book
            AND    period_close_date IS NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               lc_period                  := NULL;
         END;

         BEGIN
            SELECT fc.period_name
            INTO   l_dtin_serv
            FROM   fa_calendar_periods fc
                 , fa_book_controls fb
            WHERE  fc.calendar_type = fb.deprn_calendar
            AND    fb.book_type_code = x_book
            AND    TRUNC (TO_DATE (x_dtin_serv, 'dd/mm/rrrr'))
                      BETWEEN fc.start_date
                          AND fc.end_date;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_dtin_serv                := NULL;
         END;

         l_dtcntr                   := ret_counter (x_book, l_dtin_serv);
         l_strt_cntr                := ret_counter (x_book, x_start_prd);
         l_opn_cntr                 := ret_counter (x_book, lc_period);

         -- calc nop for accdeprn
         IF    l_strt_cntr = l_dtcntr
            OR l_strt_cntr = l_opn_cntr
            OR l_dtcntr = l_opn_cntr
         THEN
            l_nop                      := x_num_per;
            h_period                   := x_start_prd;
-- modified for #7174543
            FOR lc_backdt_ast IN lcu_backdt_ast (x_book)
            LOOP
               IF lc_backdt_ast.asset_id = x_asset_id
               THEN
                  BEGIN
                     SELECT COUNT (1)
                        INTO ln_temp1
                      FROM fa_deprn_summary
                      WHERE asset_id = x_asset_id
                        AND deprn_source_code = 'DEPRN';
                  END;
                  IF ln_temp1 = 0
                  THEN
                     l_bdast_flg := 1;
                  END IF;
                END IF;
            END LOOP;
         ELSE
            l_temp                     := ABS (l_opn_cntr - l_strt_cntr);

            IF l_temp > 0
            THEN
               l_nop                      := x_num_per - l_temp;
               h_period                   := lc_period;
            ELSIF l_temp < 0
            THEN
               l_nop                      := ABS (l_temp) + x_num_per;
               h_period                   := lc_period;
            END IF;

            FOR lc_backdt_ast IN lcu_backdt_ast (x_book)
            LOOP
               IF lc_backdt_ast.asset_id = x_asset_id
               THEN
                  BEGIN
                     SELECT COUNT (1)
                     INTO   ln_temp1
                     FROM   fa_deprn_summary
                     WHERE  asset_id = x_asset_id
                     AND    deprn_source_code = 'DEPRN';
                  END;

                  IF ln_temp1 = 0
                  THEN
                     l_temp := ABS (l_opn_cntr - l_strt_cntr);
                     l_nop := x_num_per + l_temp;
                     h_period := lc_period;
                     l_bdast_flg := 1;           -- modified for #7174543
                  END IF;
               END IF;
            END LOOP;
         END IF;

         BEGIN
            SELECT deprn_reserve
            INTO   ln_int_deprn
            FROM   (SELECT   ROWNUM a
                           , deprn_reserve
                    FROM     fa_deprn_summary
                    WHERE    book_type_code = x_book
                    AND      asset_id = x_asset_id
                    ORDER BY deprn_reserve DESC)
            WHERE  ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               ln_int_deprn               := 0;
         END;

         gn_acc_deprn               := gn_acc_deprn + ln_int_deprn;
         l_gnacc_deprn              := l_gnacc_deprn + ln_int_deprn;  -- added to chk life end depreciation #7174535

         IF ((x_cur_cost * h_guarant_rate) <
                                     (x_cur_cost - gn_acc_deprn) * h_orig_rate
            )
         THEN
            h_rate                     := h_orig_rate;
         ELSE
            h_rate                     := h_rev_rate;
            h_rate_in_use              := h_rev_rate;
         END IF;

         BEGIN
            SELECT DECODE (adjusted_cost
                         , COST, 1
                         , 0
                          )
            INTO   l_tmp
            FROM   fa_books
            WHERE  book_type_code = x_book
            AND    date_ineffective IS NULL
            AND    period_counter_fully_reserved IS NULL
            AND    asset_id = x_asset_id;
         END;

         FOR lc_periods IN lcu_periods (x_book
                                      , h_period
                                      , l_nop
                                       )
         LOOP                                                   -- each period
-- findout the rate to calculate deprn
            h_per                      := chk_period (lc_periods.period_name, x_book);

            IF h_per = 1
            THEN
               IF ((x_cur_cost * h_guarant_rate) <
                                     (x_cur_cost - gn_acc_deprn
                                     ) * h_orig_rate
                  )
               THEN
                  h_rate                     := h_orig_rate;
               ELSE
                  h_rate                     := h_rev_rate;
                  h_rate_in_use              := h_rev_rate;
               END IF;

               BEGIN
                  SELECT deprn_amount
                       , ROUND (deprn_reserve, 0)
                  INTO   l_dep
                       , g_dep
                  FROM   fa_deprn_summary fds
                       , fa_deprn_periods fdp
                  WHERE  fds.period_counter = fdp.period_counter
                  AND    fds.book_type_code = fdp.book_type_code
                  AND    fds.asset_id = x_asset_id
                  AND    fdp.book_type_code = x_book
                  AND    fdp.period_name =
                            (SELECT cp.period_name
                             FROM   fa_calendar_periods cp
                                  , fa_fiscal_year fy
                                  , fa_book_controls fb
                             WHERE  cp.calendar_type = fb.deprn_calendar
                             AND    fb.book_type_code = x_book
                             AND    fb.fiscal_year_name = fy.fiscal_year_name
                             AND    cp.period_num = 1
                             AND    fy.fiscal_year =
                                       (SELECT fy.fiscal_year
                                        FROM   fa_calendar_periods cp
                                             , fa_fiscal_year fy
                                             , fa_book_controls fb
                                        WHERE  cp.period_name = lc_period
                                        AND    cp.calendar_type =
                                                             fb.deprn_calendar
                                        AND    fb.book_type_code = x_book
                                        AND    fb.fiscal_year_name =
                                                           fy.fiscal_year_name
                                        AND    cp.start_date
                                                  BETWEEN fy.start_date
                                                      AND fy.end_date)
                             AND    cp.start_date BETWEEN fy.start_date
                                                      AND fy.end_date);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     l_dep                      := ln_dep_dumy;
                     g_dep                      := 0;
               END;

-- commented for  #7161938 and 7161740
               /* IF h_rate = h_rev_rate
               THEN
                  IF l_cnt2 = 0
                    AND l_tmp <> 1
                  THEN
                     gn_acc_deprn := gn_acc_deprn + NVL(l_ct,0);
                     l_cnt2 := l_cnt2 + 1;
                  END IF;
               END IF; */
               IF l_tmp = 1
               THEN
                  IF h_rate <> h_rev_rate
                  THEN
                     gn_acc_deprn               := gn_acc_deprn + ln_acc_deprn;
                     l_gnacc_deprn              := l_gnacc_deprn + ln_acc_deprn;   -- added to chk life end depreciation #7174535
                  END IF;

                  ln_nbv                     := x_cur_cost - gn_acc_deprn;
                  ln_acc_deprn := TRUNC (ln_nbv * h_rate, 0);           -- round changed to trunc  7174535
               ELSIF l_tmp = 0
               THEN
                  IF l_cnt1 = 1
                  THEN
                     IF chk_period (x_start_prd, x_book) = 1
                     THEN
                        IF     g_dep > 0
                           AND l_dep > 0
                        THEN
                           gn_acc_deprn               := g_dep - l_dep;
                           l_gnacc_deprn              := g_dep - l_dep;     -- added to chk life end depreciation #7174535
                        END IF;

                        ln_nbv                     := x_cost;
                     ELSE
                        IF h_rate <> h_rev_rate
                        THEN
                           gn_acc_deprn               := gn_acc_deprn + (ln_dep_dumy * h_nop);
                           l_gnacc_deprn              := l_gnacc_deprn + (ln_dep_dumy * h_nop);   -- added to chk life end depreciation #7174535
                           ln_nbv                     := x_cur_cost - gn_acc_deprn;
                        ELSE
                           ln_nbv                     := ln_nbv1;
                        END IF;
                     END IF;

                     ln_acc_deprn := TRUNC (ln_nbv * h_rate, 0);                -- round changed to trunc  7174535
                     l_cnt1                     := l_cnt1 + 1;
                  ELSE
                     gn_acc_deprn               := gn_acc_deprn + ln_acc_deprn;
                     l_gnacc_deprn              := l_gnacc_deprn + ln_acc_deprn;   -- added to chk life end depreciation #7174535
                     ln_nbv                     := x_cur_cost - gn_acc_deprn;
                     ln_acc_deprn               := TRUNC (ln_nbv * h_rate, 0);  -- round changed to trunc  7174535
                  END IF;
               END IF;

               IF h_orig_rate = h_rate_in_use
               THEN
                  lt_nbv_typ (h_cntr1).period := lc_periods.period_name;
                  lt_nbv_typ (h_cntr1).period_cntr := lc_periods.counter;
                  lt_nbv_typ (h_cntr1).nbv_value := ln_nbv;
                  lt_nbv_typ (h_cntr1).asset_id := x_asset_id;
                  lt_nbv_typ (h_cntr1).deprn_value :=
                     ROUND (TRUNC ((lt_nbv_typ (h_cntr1).nbv_value * h_rate
                                   )
                                 , 0)
                            * (1 / h_nop)
                          , 0);
                  lt_nbv_typ (h_cntr1).new_depreciation :=
                     ROUND (TRUNC ((lt_nbv_typ (h_cntr1).nbv_value * h_rate))
                            * (1 / h_nop)
                          , 0);
                  gn_deprn                   := gn_deprn + lt_nbv_typ (h_cntr1).deprn_value;
               ELSE
                  -- STL method
                  h_rate                      := h_rev_rate;
                  lt_nbv_typ (h_cntr1).period := lc_periods.period_name;
                  lt_nbv_typ (h_cntr1).period_cntr := lc_periods.counter;
                  lt_nbv_typ (h_cntr1).asset_id := x_asset_id;
                  lt_nbv_typ (h_cntr1).deprn_value :=
                              ROUND (TRUNC (ln_nbv * h_rate) * (1 / h_nop), 0);
                  lt_nbv_typ (h_cntr1).new_depreciation :=
                              ROUND (TRUNC (ln_nbv * h_rate) * (1 / h_nop), 0);
                  gn_deprn                   := gn_deprn + lt_nbv_typ (h_cntr1).deprn_value;
               END IF;

               IF h_rate <> h_rev_rate
               THEN
                  gn_acc_deprn               := gn_acc_deprn + ln_acc_deprn;
               END IF;
               l_gnacc_deprn              := l_gnacc_deprn + ln_acc_deprn;         -- added to chk life end depreciation #7174535
               h_cntr1                    := h_cntr1 + 1;
            ELSIF h_per = h_nop
            THEN
               IF     gn_acc_deprn = 0
                  AND (chk_period (x_start_prd, x_book) <> 1)
                  AND l_tmp4 = 1
               THEN
-- modified against 7174535
                  IF y_dep <> 0 THEN
                     gn_acc_deprn               := x_cost * h_rate;
                     l_gnacc_deprn              := x_cost * h_rate;          -- added to chk life end depreciation #7174535
                  ELSE
                     h_per                      := chk_period (x_start_prd, x_book);
                     gn_acc_deprn               := gn_acc_deprn + (nvl(ln_dep_dumy,0) * (h_nop - (h_per-1)));
                     l_gnacc_deprn              := l_gnacc_deprn + (nvl(ln_dep_dumy,0) * (h_nop - (h_per-1)));  -- added to chk life end depreciation #7174535
                  END IF;

                  IF ln_nbv1 IS NULL
                  THEN
                     ln_nbv1                 := x_cur_cost - gn_acc_deprn;
                  END IF;
                  l_tmp4                     := l_tmp4 + 1;
               END IF;
-- added to calculate year end period depreciation #7174535
               IF l_count_dum = 0
               THEN
                  BEGIN
                     SELECT period_num
                     INTO   l_per_dum
                     FROM   fa_deprn_summary fds
                          , fa_deprn_periods fdp
                     WHERE  fdp.book_type_code = fds.book_type_code
                     AND    fdp.period_counter = fds.period_counter
                     AND    fds.book_type_code = x_book
                     AND    fds.asset_id = x_asset_id
                     AND    fds.deprn_source_code = 'BOOKS';
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_per_dum                  := 1;
                  END;
                  l_count_dum                := l_count_dum + 1;
               ELSE
                  l_per_dum                  := 1;
               END IF;

               IF    l_per_dum = 1
                  OR l_per_dum = h_nop
               THEN
                  ln_temp3                   :=
                     ROUND (TRUNC (ln_nbv1 * h_rate) * (1 / h_nop), 0)
                     * (h_per - 1);
               ELSE
                  ln_temp3                   := TRUNC ((ln_nbv1 * h_rate)
                            * ((h_nop - l_per_dum + 1) / h_nop));
               END IF;

--   fa_round_pkg.fa_round (ln_temp3, x_book);
               gn_deprn                    := gn_deprn + ln_temp3;
               lt_nbv_typ (h_cntr1).period := lc_periods.period_name;
               lt_nbv_typ (h_cntr1).period_cntr := lc_periods.counter;
               lt_nbv_typ (h_cntr1).nbv_value := x_cur_cost - gn_acc_deprn;
               lt_nbv_typ (h_cntr1).asset_id  := x_asset_id;
-- added for year end rounding #7171947
               IF    l_per_dum = 1
                  OR l_per_dum = h_nop
               THEN
                  lt_nbv_typ (h_cntr1).deprn_value :=
                                     TRUNC ((ln_nbv1 * h_rate), 0) - ln_temp3;
                  lt_nbv_typ (h_cntr1).new_depreciation :=
                                     TRUNC ((ln_nbv1 * h_rate), 0) - ln_temp3;
               ELSE
                  lt_nbv_typ (h_cntr1).deprn_value :=
                     ln_temp3
                     - ROUND (TRUNC (ln_nbv1 * h_rate) * (1 / h_nop), 0)
                       * (h_nop - l_per_dum);
                  lt_nbv_typ (h_cntr1).new_depreciation :=
                     ln_temp3
                     - ROUND (TRUNC (ln_nbv1 * h_rate) * (1 / h_nop), 0)
                       * (h_nop - l_per_dum);
               END IF;

-- added against #7136958
               l_end_percnt               := l_dtcntr + (x_life - 1);

-- modified for #7174543
               IF l_bdast_flg <> 1
               THEN
                  IF lt_nbv_typ (h_cntr1).period_cntr = l_end_percnt
                    AND l_gnacc_deprn <> (x_cur_cost - x_deprn_lmt)
                  THEN
                     gn_acc_deprn := gn_acc_deprn - x_deprn_lmt;
                     lt_nbv_typ (h_cntr1).deprn_value :=
                               lt_nbv_typ (h_cntr1).deprn_value - x_deprn_lmt;
                     lt_nbv_typ (h_cntr1).new_depreciation :=
                          lt_nbv_typ (h_cntr1).new_depreciation - x_deprn_lmt;
                  END IF;
               END IF;

               gn_deprn                   :=
                                   gn_deprn + lt_nbv_typ (h_cntr1).deprn_value;
               l_ct                       := ln_acc_deprn;
               gn_deprn                   := 0;
               ln_acc_deprn               := 0;
               h_cntr1                    := h_cntr1 + 1;
            ELSE
               IF ln_nbv > 0
               THEN
                  ln_nbv1                    := ln_nbv;
               ELSE
                  h_per                      := chk_period (l_dtin_serv, x_book);

                  IF h_per = 1
                  THEN
                     BEGIN
                        SELECT deprn_amount
                             , ROUND (deprn_reserve, 0)
                        INTO   l_dep
                             , g_dep
                        FROM   fa_deprn_summary fds
                             , fa_deprn_periods fdp
                        WHERE  fds.period_counter = fdp.period_counter
                        AND    fds.book_type_code = fdp.book_type_code
                        AND    fds.asset_id = x_asset_id
                        AND    fdp.book_type_code = x_book
                        AND    fdp.period_name =
                                  (SELECT cp.period_name
                                   FROM   fa_calendar_periods cp
                                        , fa_fiscal_year fy
                                        , fa_book_controls fb
                                   WHERE  cp.calendar_type = fb.deprn_calendar
                                   AND    fb.book_type_code = x_book
                                   AND    fb.fiscal_year_name =
                                                           fy.fiscal_year_name
                                   AND    cp.period_num = 1
                                   AND    fy.fiscal_year =
                                             (SELECT fy.fiscal_year
                                              FROM   fa_calendar_periods cp
                                                   , fa_fiscal_year fy
                                                   , fa_book_controls fb
                                              WHERE  cp.period_name =
                                                                     lc_period
                                              AND    cp.calendar_type =
                                                             fb.deprn_calendar
                                              AND    fb.book_type_code =
                                                                        x_book
                                              AND    fb.fiscal_year_name =
                                                           fy.fiscal_year_name
                                              AND    cp.start_date
                                                        BETWEEN fy.start_date
                                                            AND fy.end_date)
                                   AND    cp.start_date BETWEEN fy.start_date
                                                            AND fy.end_date);
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           l_dep                      := 0;
                           g_dep                      := 0;
                     END;

                     IF l_tmp = 0
                     THEN
                        gn_acc_deprn               := x_cur_cost - x_cost;
                        l_gnacc_deprn              := x_cur_cost - x_cost;       -- added to chk life end depreciation #7174535
                     ELSE
                        BEGIN
                           SELECT fdp.period_counter
                           INTO   ln_stcnt
                           FROM   fa_deprn_periods fdp
                           WHERE  fdp.period_name =
                                     (SELECT cp.period_name
                                      FROM   fa_calendar_periods cp
                                           , fa_fiscal_year fy
                                           , fa_book_controls fb
                                      WHERE  cp.calendar_type =
                                                             fb.deprn_calendar
                                      AND    fb.book_type_code = x_book
                                      AND    fb.fiscal_year_name =
                                                           fy.fiscal_year_name
                                      AND    cp.period_num = 1
                                      AND    fy.fiscal_year =
                                                (SELECT fy.fiscal_year
                                                 FROM   fa_calendar_periods cp
                                                      , fa_fiscal_year fy
                                                      , fa_book_controls fb
                                                 WHERE  cp.period_name =
                                                                     lc_period
                                                 AND    cp.calendar_type =
                                                             fb.deprn_calendar
                                                 AND    fb.book_type_code =
                                                                        x_book
                                                 AND    fb.fiscal_year_name =
                                                           fy.fiscal_year_name
                                                 AND    cp.start_date
                                                           BETWEEN fy.start_date
                                                               AND fy.end_date)
                                      AND    cp.start_date BETWEEN fy.start_date
                                                               AND fy.end_date)
                           AND    fdp.book_type_code = x_book;
                        END;

-- added against #7133749
                        BEGIN
                           SELECT deprn_amount
                                , ytd_deprn
                                , deprn_reserve
                           INTO   l_dep
                                , y_dep
                                , g_dep
                           FROM   fa_deprn_summary fds
                                , fa_deprn_periods fdp
                           WHERE  fds.period_counter = fdp.period_counter
                           AND    fds.book_type_code = fdp.book_type_code
                           AND    fds.asset_id = x_asset_id
                           AND    fdp.book_type_code = x_book
                           AND    fdp.period_counter = l_opn_cntr - 1;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              l_dep                      := 0;
                              g_dep                      := 0;
                              y_dep                      := 0;
                        END;
-- modified against 7174535
--Manual entry assets
                        gn_acc_deprn               := g_dep - y_dep;
                        l_gnacc_deprn              := g_dep - y_dep;       -- added to chk life end depreciation #7174535
--    gn_acc_deprn := g_dep - (l_dep * ABS(l_opn_cntr - ln_stcnt));        #7171957
                     END IF;

-- commented against #7133749
                    -- IF h_rate <> h_rev_rate
                    -- THEN
                     ln_nbv1                    := x_cur_cost - gn_acc_deprn;
                     gn_acc_deprn               := gn_acc_deprn + ln_acc_deprn;
                     l_gnacc_deprn              := l_gnacc_deprn + ln_acc_deprn;    -- added to chk life end depreciation #7174535
                  -- END IF;
                  ELSE
                     IF ((x_cur_cost * h_guarant_rate) <
                                     (x_cur_cost - gn_acc_deprn
                                     ) * h_orig_rate
                        )
                     THEN
                        h_rate                     := h_orig_rate;
                     ELSE
                        h_rate                     := h_rev_rate;
                        h_rate_in_use              := h_rev_rate;
                     END IF;

                     BEGIN
                        SELECT deprn_amount
                             , deprn_reserve
                        INTO   l_dep
                             , g_dep
                        FROM   fa_deprn_summary fds
                             , fa_deprn_periods fdp
                        WHERE  fds.period_counter = fdp.period_counter
                        AND    fds.book_type_code = fdp.book_type_code
                        AND    fds.asset_id = x_asset_id
                        AND    fdp.book_type_code = x_book
                        AND    fdp.period_name =
                                  (SELECT cp.period_name
                                   FROM   fa_calendar_periods cp
                                        , fa_fiscal_year fy
                                        , fa_book_controls fb
                                   WHERE  cp.calendar_type = fb.deprn_calendar
                                   AND    fb.book_type_code = x_book
                                   AND    fb.fiscal_year_name =
                                                           fy.fiscal_year_name
                                   AND    cp.period_num = 1
                                   AND    fy.fiscal_year =
                                             (SELECT fy.fiscal_year
                                              FROM   fa_calendar_periods cp
                                                   , fa_fiscal_year fy
                                                   , fa_book_controls fb
                                              WHERE  cp.period_name =
                                                                     lc_period
                                              AND    cp.calendar_type =
                                                             fb.deprn_calendar
                                              AND    fb.book_type_code =
                                                                        x_book
                                              AND    fb.fiscal_year_name =
                                                           fy.fiscal_year_name
                                              AND    cp.start_date
                                                        BETWEEN fy.start_date
                                                            AND fy.end_date)
                                   AND    cp.start_date BETWEEN fy.start_date
                                                            AND fy.end_date);
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           l_dep                      := 0;
                           g_dep                      := 0;
                     END;

                     BEGIN
                        SELECT DECODE (adjusted_cost
                                     , COST, 1
                                     , 0
                                      )
                        INTO   l_tmp
                        FROM   fa_books
                        WHERE  book_type_code = x_book
                        AND    date_ineffective IS NULL
                        AND    period_counter_fully_reserved IS NULL
                        AND    asset_id = x_asset_id;
                     END;

                     IF l_tmp = 0
                     THEN
                        IF l_dep <> 0
                        THEN
                           gn_acc_deprn               := g_dep - l_dep;
                           l_gnacc_deprn              := g_dep - l_dep;    -- added to chk life end depreciation #7174535
                        ELSE
                           gn_acc_deprn               := x_cur_cost - x_cost;
                           l_gnacc_deprn              := x_cur_cost - x_cost;    -- added to chk life end depreciation #7174535
                        END IF;

                        ln_nbv1                    := x_cost;

                     ELSIF l_tmp = 1
                     THEN
                        IF h_rate <> h_rev_rate
                        THEN
                           gn_acc_deprn               := ln_acc_deprn;
                           l_gnacc_deprn              := ln_acc_deprn;        -- added to chk life end depreciation #7174535
                           ln_nbv1                    := x_cur_cost - gn_acc_deprn;
                        END IF;

                        ln_temp3                   :=
                           ROUND (TRUNC (ln_nbv1 * h_rate) * (1 / h_nop), 0)
                           * (h_nop - h_per + 1);
                     -- fa_round_pkg.fa_round(ln_temp3,X_book);
                     END IF;
                  END IF;
               END IF;

               IF h_orig_rate = h_rate_in_use
               THEN
                  lt_nbv_typ (h_cntr1).period := lc_periods.period_name;
                  lt_nbv_typ (h_cntr1).period_cntr := lc_periods.counter;
                  lt_nbv_typ (h_cntr1).nbv_value := ln_nbv1;
                  lt_nbv_typ (h_cntr1).asset_id := x_asset_id;
                  lt_nbv_typ (h_cntr1).deprn_value :=
                             ROUND (TRUNC (ln_nbv1 * h_rate) * (1 / h_nop)
                                  , 0);
                  lt_nbv_typ (h_cntr1).new_depreciation :=
                             ROUND (TRUNC (ln_nbv1 * h_rate) * (1 / h_nop)
                                  , 0);
                  gn_deprn                   :=
                                  gn_deprn + lt_nbv_typ (h_cntr1).deprn_value;
                  ln_dep_dumy                :=
                                             (ln_nbv1 * h_rate)
                                             * (1 / h_nop);
               ELSE
                  -- STL method
                  h_rate                     := h_rev_rate;
                  lt_nbv_typ (h_cntr1).period := lc_periods.period_name;
                  lt_nbv_typ (h_cntr1).period_cntr := lc_periods.counter;
                  lt_nbv_typ (h_cntr1).asset_id := x_asset_id;
                  lt_nbv_typ (h_cntr1).deprn_value :=
                             ROUND (TRUNC (ln_nbv1 * h_rate) * (1 / h_nop)
                                  , 0);
                  lt_nbv_typ (h_cntr1).new_depreciation :=
                             ROUND (TRUNC (ln_nbv1 * h_rate) * (1 / h_nop)
                                  , 0);
                  gn_deprn                   :=
                                  gn_deprn + lt_nbv_typ (h_cntr1).deprn_value;
                  ln_dep_dumy                :=
                                             lt_nbv_typ (h_cntr1).deprn_value;
               END IF;

               h_cntr1                    := h_cntr1 + 1;
            END IF;
         END LOOP;

         h_period                   := l_strt_cntr;

         FOR k IN 1 .. lt_nbv_typ.COUNT
         LOOP
            IF lt_nbv_typ (k).period_cntr = l_strt_cntr
            THEN
               lt_nbv_typ (k).acc_deprn   := lt_nbv_typ (k).deprn_value;
               h_period_cnt               := l_strt_cntr + 1;
               ln_temp1                   := lt_nbv_typ (k).acc_deprn;
            ELSIF lt_nbv_typ (k).period_cntr = h_period_cnt
            THEN
               lt_nbv_typ (k).acc_deprn   :=
                                        ln_temp1 + lt_nbv_typ (k).deprn_value;
               h_period_cnt               := h_period_cnt + 1;
               ln_temp1                   := lt_nbv_typ (k).acc_deprn;
            END IF;
         --fa_round_pkg.fa_round (lt_nbv_typ (k).acc_deprn, x_book);
         END LOOP;

         l_end_percnt               := l_dtcntr + (x_life - 1);
         h_period_cnt               := l_end_percnt + 1;

         FOR j IN 1 .. lt_nbv_typ.COUNT
         LOOP
            IF lt_nbv_typ (j).asset_id = x_asset_id
            THEN
               FOR k IN 1 .. lt_whatitf.COUNT
               LOOP
                  IF     lt_whatitf (k).period_counter =
                                                   lt_nbv_typ (j).period_cntr
                     AND lt_whatitf (k).asset_id = lt_nbv_typ (j).asset_id
                  THEN
                     IF lt_whatitf (k).period_counter = l_end_percnt
                     THEN
-- Modified for #7174543
                         IF l_bdast_flg <> 1
                         THEN
                            lt_whatitf (k).depreciation := lt_nbv_typ (j).deprn_value;
                            lt_whatitf (k).new_depreciation  := lt_nbv_typ (j).new_depreciation;
                            lt_whatitf (k).accumulated_deprn := lt_nbv_typ (j).acc_deprn;
                         ELSIF l_bdast_flg = 1
                         THEN
                            lt_whatitf (k).depreciation := lt_nbv_typ (j).deprn_value;
                            lt_whatitf (k).new_depreciation := lt_nbv_typ (j).new_depreciation;
                            lt_whatitf (k).accumulated_deprn := lt_nbv_typ (j).acc_deprn;
                            l_end_percnt := l_opn_cntr + (x_life - 1);
                            h_period_cnt := l_end_percnt + 1;
                         END IF;

                     -- EXIT;
                     ELSIF lt_whatitf (k).period_counter = h_period_cnt
                     THEN
                        lt_whatitf (k).depreciation := 0;
                        lt_whatitf (k).new_depreciation := 0;
                        lt_whatitf (k).accumulated_deprn := 0;
                        h_period_cnt               := h_period_cnt + 1;
                        EXIT;
                     ELSE
                        IF lt_nbv_typ (j).deprn_value <= 1
                        THEN
                           lt_whatitf (k).depreciation := 0;
                           lt_whatitf (k).new_depreciation := 0;
                        ELSE
                           lt_whatitf (k).depreciation :=
                                                   lt_nbv_typ (j).deprn_value;
                           lt_whatitf (k).new_depreciation :=
                                              lt_nbv_typ (j).new_depreciation;
                           lt_whatitf (k).accumulated_deprn :=
                                                     lt_nbv_typ (j).acc_deprn;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;

-- added  against #7136958
-- modified #7161938 and 7161740
         l_cnt1                     := 1;

         FOR j IN 1 .. lt_nbv_typ.COUNT
         LOOP
            FOR k IN 1 .. lt_whatitf.COUNT
            LOOP
               IF     lt_nbv_typ (j).asset_id = x_asset_id
                  AND (   lt_nbv_typ (j).acc_deprn >= x_cost
                       OR lt_nbv_typ (j).acc_deprn >= x_cur_cost
                      )
                  AND lt_whatitf (k).period_counter =
                                                    lt_nbv_typ (j).period_cntr
                  AND lt_whatitf (k).asset_id = lt_nbv_typ (j).asset_id
               THEN
                  IF     l_cnt1 = 1
                     AND lt_whatitf (k).accumulated_deprn = x_cost
                  THEN
                     lt_whatitf (k).depreciation :=
                                    lt_whatitf (k).depreciation - x_deprn_lmt;
                     lt_whatitf (k).new_depreciation :=
                                lt_whatitf (k).new_depreciation - x_deprn_lmt;
                     l_cnt1                     := l_cnt1 + 1;
                  ELSE
                     lt_whatitf (k).depreciation := 0;
                     lt_whatitf (k).new_depreciation := 0;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;

         l_cnt1                     := 1;

         FOR j IN 1 .. lt_whatitf.COUNT
         LOOP
            BEGIN
               --fa_round_pkg.fa_round (lt_whatitf (j).depreciation, x_book);
               --fa_round_pkg.fa_round (lt_whatitf (j).new_depreciation,   x_book);
               --fa_round_pkg.fa_round (lt_whatitf (j).accumulated_deprn,x_book);
               UPDATE fa_whatif_itf
               SET depreciation = lt_whatitf (j).depreciation
                 , new_depreciation = lt_whatitf (j).new_depreciation
                 , accumulated_deprn = lt_whatitf (j).accumulated_deprn
               WHERE  period_name = lt_whatitf (j).period_name
               AND    asset_id = x_asset_id
               AND    book_type_code = x_book
               AND    request_id = lt_whatitf (j).request_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END LOOP;

         COMMIT;
      END IF;
   END calc_jp250db;

   FUNCTION chk_period (
      x_period                            VARCHAR2
    , x_book_type                         VARCHAR2
   )
      RETURN NUMBER
   IS
      h_periodnum                             NUMBER;
   BEGIN
      SELECT period_num
      INTO   h_periodnum
      FROM   fa_calendar_periods fc
           , fa_book_controls fb
      WHERE  fc.calendar_type = fb.deprn_calendar
      AND    fb.book_type_code = x_book_type
      AND    period_name = x_period;

      RETURN h_periodnum;
   EXCEPTION
      WHEN OTHERS
      THEN
         h_periodnum                := NULL;
         RETURN h_periodnum;
   END chk_period;

   FUNCTION ret_counter (
      x_book_typ                          VARCHAR2
    , x_periodname                        VARCHAR2
   )
      RETURN VARCHAR2
   IS
      l_dtcntr1                               NUMBER;
   BEGIN
      SELECT (ffy.fiscal_year * fct.number_per_fiscal_year + fc.period_num)
                                                               period_counter
      INTO   l_dtcntr1
      FROM   fa_calendar_periods fc
           , fa_book_controls fb
           , fa_fiscal_year ffy
           , fa_calendar_types fct
      WHERE  fc.calendar_type = fb.deprn_calendar
      AND    fb.book_type_code = x_book_typ
      AND    ffy.fiscal_year_name = fb.fiscal_year_name
      AND    ffy.fiscal_year_name = fct.fiscal_year_name
      AND    fc.calendar_type = fct.calendar_type
      AND    fct.calendar_type = fb.deprn_calendar
      AND    fc.start_date >= ffy.start_date
      AND    fc.end_date <= ffy.end_date
      AND    fc.period_name = x_periodname;

      RETURN l_dtcntr1;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_dtcntr1                  := NULL;
         RETURN l_dtcntr1;
   END;
END fa_jp_tax_extn_pvt;

/
