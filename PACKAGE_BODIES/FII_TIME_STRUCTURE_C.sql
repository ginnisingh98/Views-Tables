--------------------------------------------------------
--  DDL for Package Body FII_TIME_STRUCTURE_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_TIME_STRUCTURE_C" AS
/*$Header: FIICMT4B.pls 120.5 2007/03/01 07:14:06 arcdixit ship $*/

g_schema             varchar2(30);
g_debug_flag         VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
g_global_start_date  date := bis_common_parameters.get_GLOBAL_START_DATE;

-- Bug 5624487
g_unassigned_day date := to_date('12/31/4712', 'MM/DD/YYYY');

G_TABLE_NOT_EXIST EXCEPTION;
PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);

---------------------------------------------------
-- PRIVATE PROCEDURE TRUNCATE_TABLE
---------------------------------------------------
procedure truncate_table (p_table_name in varchar2) is
   l_stmt varchar2(400);

begin

   l_stmt := 'truncate table '||g_schema||'.'||p_table_name;
   if g_debug_flag = 'Y' then
      fii_util.put_line(l_stmt);
   end if;
   execute immediate l_stmt;

exception
   WHEN G_TABLE_NOT_EXIST THEN
      null;      -- Oracle 942, table does not exist, no actions
   WHEN OTHERS THEN
      raise;

end truncate_table;

----------------------------------------------------------------
-- PRIVATE FUNCTION NOT_WITHIN
--   This function check that the enterprice start and end date
--   is within the rolling start and end date.  The function will
--   return TRUE if this condition is satisfied.
----------------------------------------------------------------
FUNCTION NOT_WITHIN ( p_x_start date,     -- ent start date
                      p_x_end   date,     -- ent end date
                      p_r_start date,     -- roll start date
                      p_r_end   date      -- roll end date
                    ) RETURN BOOLEAN IS
BEGIN
  RETURN NOT ( p_x_start >= p_r_start and
               p_x_end   <= p_r_end );
END NOT_WITHIN;

---------------------------------------------------
-- PRIVATE FUNCTION INCLUDES_XTD
-- this function determines whether or not a record_type_id
-- value contains any XTD bits
---------------------------------------------------
FUNCTION INCLUDES_XTD
( p_sum     number
, p_rolling number
)
return varchar2 is

   l_bit number := 1;

begin

   loop

      if l_bit >=  p_rolling then
         exit;
      end if;

      if bitand(p_sum,l_bit) = l_bit then
         return 'Y';
      end if;

      l_bit := l_bit *2;

   end loop;

   return 'N';

end INCLUDES_XTD;

-----------------------------------------------------------------------
-- PRIVATE PROCEDURE INSERT_ROW
--   Given the report_date, time_id, period_type_id and record_type_id
--   passed in as parameter, this procedure will insert a row with
--   these values into FII_TIME_STRUCTURES
-----------------------------------------------------------------------
PROCEDURE INSERT_ROW(p_report_date    DATE,
                     p_time_id        NUMBER,
                     p_period_type_id NUMBER,
                     p_record_type_id NUMBER,
                     p_xtd_flag       VARCHAR2 ) IS
BEGIN

  INSERT INTO FII_TIME_STRUCTURES
    ( report_date,
      time_id,
      period_type_id,
      record_type_id,
      xtd_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login )
  VALUES
    ( p_report_date,
      p_time_id,
      p_period_type_id,
      p_record_type_id,
      p_xtd_flag,
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      fnd_global.login_id);

END INSERT_ROW;

---------------------------------------------------
-- PUBLIC PROCEDURE LOAD_TIME_STRUCTURES
---------------------------------------------------
PROCEDURE LOAD_TIME_STRUCTURES IS

   l_status            VARCHAR2(30);
   l_industry          VARCHAR2(30);
   l_max_day           DATE;
   l_current_day       DATE;
   l_roll_year_start   DATE;
   l_roll_year_end     DATE;
   l_roll_qtr_start    DATE;
   l_roll_qtr_end      DATE;
   l_roll_month_start  DATE;
   l_roll_month_end    DATE;
   l_roll_week_start   DATE;
   l_roll_week_end     DATE;
   l_xtd_year_start    DATE;
   l_xtd_year_end      DATE;
   l_xtd_qtr_start     DATE;
   l_xtd_qtr_end       DATE;
   l_xtd_period_start  DATE;
   l_xtd_period_end    DATE;
   l_xtd_week_start    DATE;
   l_xtd_week_end      DATE;
   -- AR DBI Changes: Added for new rolling DSO periods
   l_roll_180_start    DATE;
   l_roll_180_end      DATE;
   l_roll_60_start     DATE;
   l_roll_60_end       DATE;
   l_roll_45_start     DATE;
   l_roll_45_end       DATE;

   ------------------------------------
   -- Pre-defined period_type_id values
   ------------------------------------
   l_nested_day        NUMBER := 1;
   l_nested_week       NUMBER := 16;
   l_nested_ent_period NUMBER := 32;
   l_nested_ent_qtr    NUMBER := 64;
   l_nested_ent_year   NUMBER := 128;

   ------------------------------------
   -- Pre-defined usage types
   ------------------------------------
   l_day               NUMBER := 1;
   l_current_week      NUMBER := 2;
   l_current_month     NUMBER := 4;
   l_current_qtr       NUMBER := 8;
   l_current_year      NUMBER := 16;
   l_xtd_week          NUMBER := 32;
   l_xtd_period        NUMBER := 64;
   l_xtd_qtr           NUMBER := 128;
   l_xtd_year          NUMBER := 256;
   l_itd_year          NUMBER := 512;
   l_rolling_week      NUMBER := 1024;
   l_rolling_month     NUMBER := 2048;
   l_rolling_qtr       NUMBER := 4096;
   l_rolling_year      NUMBER := 8192;
   -- AR DBI Changes: Added for new rolling DSO periods
   l_rolling_45        NUMBER := 16384;
   l_rolling_60        NUMBER := 32768;
   l_rolling_180       NUMBER := 65536;

   ------------------------------------------------------------------------
   -- Variables to capture the use of each time row as an aggregate number
   ------------------------------------------------------------------------
   l_ent_year_id       NUMBER;
   l_year_sum          NUMBER;
   l_ent_qtr_id        NUMBER;
   l_qtr_sum           NUMBER;
   l_ent_period_id     NUMBER;
   l_month_sum         NUMBER;
   l_week_id           NUMBER;
   l_week_sum          NUMBER;
   l_day_id            NUMBER;
   l_day_sum           NUMBER;

   -- Cursor to retrieve all days defined in the calendar
   -- Bug 5624487
   CURSOR calendar_days IS
-- *** Why do we need next_ent_period_start_date and next_ent_period_end_date?
-- *** All columns can be found in fii_time_day. Should we change to select all
--     these columns from fii_time_day?
      SELECT
        report_date,
        week_start_date,
        week_end_date,
        ent_period_start_date,
        ent_period_end_date,
        ent_qtr_start_date,
        ent_qtr_end_date,
        ent_year_start_date,
        ent_year_end_date,
        report_date_julian day_id,
        week_id,
        ent_period_id,
        ent_qtr_id,
        ent_year_id
      FROM
        fii_time_day
      where report_date <> g_unassigned_day;
/*      SELECT
        d.report_date,
        d.week_start_date,
        d.week_start_date+6 week_end_date,
        m.start_date ent_period_start_date,
        m.end_date ent_period_end_date,
        q.start_date ent_qtr_start_date,
        q.end_date ent_qtr_end_date,
        y.start_date ent_year_start_date,
        y.end_date ent_year_end_date,
        d.report_date_julian day_id,
        d.week_id,
        m.ent_period_id,
        m.ent_qtr_id,
        m.ent_year_id,
        m.next_start_date next_ent_period_start_date,
        m.next_end_date next_ent_period_end_date
      FROM
        fii_time_day d,
        ( select
            start_date
          , end_date
          , ent_period_id
          , ent_qtr_id
          , ent_year_id
          , lead(start_date,1) over(order by start_date) next_start_date
          , lead(end_date,1) over(order by start_date) next_end_date
          from
            fii_time_ent_period
        ) m,
        fii_time_ent_qtr q,
        fii_time_ent_year y
      WHERE
          d.ent_period_id = m.ent_period_id
      AND m.ent_qtr_id    = q.ent_qtr_id
      AND q.ent_year_id   = y.ent_year_id; */

   -- Bug 5624487
   CURSOR calendar_max_day IS
      SELECT max(report_date) max_report_date
      FROM fii_time_day
      where report_date <> g_unassigned_day;

   l_row_cnt number := 0;

   type l_number_tbl is table of number;
   type l_date_tbl is table of date;

   l_ent_year_id_tbl l_number_tbl;
   l_ent_year_date_tbl l_date_tbl;

BEGIN

   if g_schema is null then
     IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_schema)) THEN
       NULL;
     END IF;
   end if;

   truncate_table('FII_TIME_STRUCTURES');

   -- Find out the max report_date defined in the calendar
   OPEN calendar_max_day;
   FETCH calendar_max_day INTO l_max_day;
   CLOSE calendar_max_day;

   -- load the ent year id and end date plsql tables
   -- used by itd inside the loop
   -- Bug 5624487
   select
     ent_year_id
   , end_date
   bulk collect into
     l_ent_year_id_tbl
   , l_ent_year_date_tbl
   from fii_time_ent_year
   where end_date < g_unassigned_day;

   -- Loop for each day defined in the calendar
   FOR d IN calendar_days LOOP

      -- Confirmed with Keith Reardon that 375 will be safe high bound that we
      -- won't miss a day
      FOR i IN 0..375 LOOP

         l_current_day := d.report_date + i;

         -- Exit the loop if we have processed all days defined in the calendar.
         IF l_current_day > l_max_day THEN
            exit;
         END IF;

         -- Initialize time IDs and aggregate record_type_ids for each time period
         l_ent_year_id   := null;
         l_year_sum      := 0;
         l_ent_qtr_id    := null;
         l_qtr_sum       := 0;
         l_ent_period_id := null;
         l_month_sum     := 0;
         l_week_id       := null;
         l_week_sum      := 0;
         l_day_id        := null;
         l_day_sum       := 0;

         ----------------------------------------------------------------------
         -- Processing rolling year calculations
         ----------------------------------------------------------------------
         IF l_current_day - 364 <= d.report_date THEN

            -- Find out rolling year start and end date
            l_roll_year_start := l_current_day - 364;
            l_roll_year_end   := l_current_day;

            --------------------------------------------------------------
            -- 1. If report_date is at the end of the enterprise year and the
            -- enterprise year is fully within the rolling year then
            -- add the pre-defined rolling year usage to l_year_sum
            --------------------------------------------------------------
            IF d.report_date = d.ent_year_end_date AND
               d.ent_year_start_date >= l_roll_year_start AND
               d.ent_year_end_date <= l_roll_year_end THEN

               l_ent_year_id := d.ent_year_id;
               l_year_sum    := l_year_sum + l_rolling_year;

            --------------------------------------------------------------
            -- 2. If report_date is at the end of enterprise qtr and
            -- the enterprise qtr is fully within the rolling year and
            -- the enterprise year is not fully within rolling year then
            -- add the pre-defined rolling year usage to l_qtr_sum
            --------------------------------------------------------------
            ELSIF d.report_date = d.ent_qtr_end_date AND
               d.ent_qtr_start_date >= l_roll_year_start AND
-- *** Should we check ent_qtr_end_date instead of ent_period_end_date?
--               d.ent_period_end_date <= l_roll_year_end AND
               d.ent_qtr_end_date <= l_roll_year_end AND
               NOT_WITHIN( d.ent_year_start_date,
                           d.ent_year_end_date,
                           l_roll_year_start,
                           l_roll_year_end ) THEN

               l_ent_qtr_id := d.ent_qtr_id;
               l_qtr_sum    := l_qtr_sum + l_rolling_year;

            --------------------------------------------------------------
            -- 3. If report_date is at the end of enterprise period and
            -- the enterprise period fully within the rolling year and
            -- the enterprise year is not fully within rolling year and
            -- the enterprise qtr is not fully within rolling year then
            -- add the pre-defined rolling year usage to l_month_sum
            --------------------------------------------------------------
            ELSIF d.report_date = d.ent_period_end_date AND
               d.ent_period_start_date >= l_roll_year_start AND
               d.ent_period_end_date <= l_roll_year_end AND
               NOT_WITHIN( d.ent_year_start_date,
                           d.ent_year_end_date,
                           l_roll_year_start,
                           l_roll_year_end ) AND
               NOT_WITHIN( d.ent_qtr_start_date,
                           d.ent_qtr_end_date,
                           l_roll_year_start,
                           l_roll_year_end ) THEN

               l_ent_period_id := d.ent_period_id;
               l_month_sum     := l_month_sum + l_rolling_year;

            --------------------------------------------------------------
            -- 4. If report_date is at the end of a week and
            -- the week is fully within rolling year and
            -- the week is fully within enterprise period and
            -- the enterprise year is not fully within rolling year and
            -- the enterprise qtr is not fully within rolling year and
            -- the enterprise period is not fully within rolling year then
            -- add the pre-defined rolling year usage to l_week_sum
            --------------------------------------------------------------
            ELSIF d.report_date = d.week_end_date AND
               d.week_start_date >= l_roll_year_start AND
               d.week_end_date <= l_roll_year_end AND
               d.week_start_date >= d.ent_period_start_date AND
               d.week_end_date <= d.ent_period_end_date AND
               NOT_WITHIN( d.ent_year_start_date,
                           d.ent_year_end_date,
                           l_roll_year_start,
                           l_roll_year_end ) AND
               NOT_WITHIN( d.ent_qtr_start_date,
                           d.ent_qtr_end_date,
                           l_roll_year_start,
                           l_roll_year_end ) AND
               NOT_WITHIN( d.ent_period_start_date,
                           d.ent_period_end_date,
                           l_roll_year_start,
                           l_roll_year_end ) THEN

               l_week_id  := d.week_id;
               l_week_sum := l_week_sum + l_rolling_year;

            --------------------------------------------------------------
            -- 5. If the enterprise year is not fully within rolling year and
            -- the enterprise qtr is not fully within rolling year and
            -- the enterprise period is not fully within rolling year and
            -- (the week is not fully within the rolling year or
            -- the week is not fully within the enterprise period) then
            -- add the pre-defined rolling year usage to l_day_sum
            --------------------------------------------------------------
            ELSIF NOT_WITHIN( d.ent_year_start_date,
                              d.ent_year_end_date,
                              l_roll_year_start,
                              l_roll_year_end ) AND
               NOT_WITHIN( d.ent_qtr_start_date,
                           d.ent_qtr_end_date,
                           l_roll_year_start,
                           l_roll_year_end ) AND
               NOT_WITHIN( d.ent_period_start_date,
                           d.ent_period_end_date,
                           l_roll_year_start,
                           l_roll_year_end ) AND
               (NOT_WITHIN( d.week_start_date,
                            d.week_end_date,
                            l_roll_year_start,
                            l_roll_year_end ) OR
                NOT_WITHIN( d.week_start_date,
                            d.week_end_date,
                            d.ent_period_start_date,
                            d.ent_period_end_date )) THEN

               l_day_id := d.day_id;
               l_day_sum := l_day_sum + l_rolling_year;

            END IF;

         END IF;

         -- AR DBI Changes: Added codes to process Rolling 180-day DSO period
         ----------------------------------------------------------------------
         -- Processing rolling 180-day calcuations
         ----------------------------------------------------------------------
         IF l_current_day - 179 <= d.report_date THEN

            -- Find out rolling 180-day start and end date
            l_roll_180_start := l_current_day - 179;
            l_roll_180_end   := l_current_day;

            --------------------------------------------------------------
            -- 1.IF report_date is at the end of the enterprise qtr
            -- AND the enterprise qtr is fully within the rolling 180-day
            -- THEN add the pre-defined rolling 180-day usage to l_qtr_sum
            --------------------------------------------------------------
            IF (d.report_date = d.ent_qtr_end_date AND
               d.ent_qtr_start_date >= l_roll_180_start AND
               d.ent_qtr_end_date <= l_roll_180_end) THEN

               l_ent_qtr_id := d.ent_qtr_id;
               l_qtr_sum    := l_qtr_sum + l_rolling_180;

            -----------------------------------------------------------------
            -- 2.IF report_date is at the end of enterprise period
            -- AND the enterprise period is fully within the rolling 180-day
            -- AND the enterprise qtr is not fully within the rolling 180-day
            -- THEN add the pre-defined rolling 180-day usage to l_month_sum
            -----------------------------------------------------------------
            ELSIF d.report_date = d.ent_period_end_date AND
               d.ent_period_start_date >= l_roll_180_start AND
               d.ent_period_end_date <= l_roll_180_end AND
               NOT_WITHIN( d.ent_qtr_start_date,
                           d.ent_qtr_end_date,
                           l_roll_180_start,
                           l_roll_180_end ) THEN

               l_ent_period_id := d.ent_period_id;
               l_month_sum     := l_month_sum + l_rolling_180;

            --------------------------------------------------------------------
            -- 3.IF report_date is at the end of a week
            -- AND the week is fully within the rolling 180-day
            -- AND the week is fully within enterprise period
            -- AND the enterprise qtr is not fully within the rolling 180-day
            -- AND the enterprise period is not fully within the rolling 180-day
            -- THEN add the pre-defined rolling 180-day usage to l_week_sum
            --------------------------------------------------------------------
            ELSIF d.report_date = d.week_end_date AND
               d.week_start_date >= l_roll_180_start AND
               d.week_end_date <= l_roll_180_end AND
               d.week_start_date >= d.ent_period_start_date AND
               d.week_end_date <= d.ent_period_end_date AND
               NOT_WITHIN( d.ent_qtr_start_date,
                           d.ent_qtr_end_date,
                           l_roll_180_start,
                           l_roll_180_end ) AND
               NOT_WITHIN( d.ent_period_start_date,
                           d.ent_period_end_date,
                           l_roll_180_start,
                           l_roll_180_end ) THEN

               l_week_id := d.week_id;
               l_week_sum := l_week_sum + l_rolling_180;

            --------------------------------------------------------------------
            -- 4.IF enterprise qtr is not fully within the rolling 180-day
            -- AND the enterprise period is not fully within the rolling 180-day
            -- AND (   the week is not fully within the rolling 180-day
            --      OR the week is not fully within the enterprise period)
            -- THEN add the pre-defined rolling 180-day usage to l_day_sum
            --------------------------------------------------------------------
            ELSIF NOT_WITHIN( d.ent_qtr_start_date,
                              d.ent_qtr_end_date,
                              l_roll_180_start,
                              l_roll_180_end ) AND
               NOT_WITHIN( d.ent_period_start_date,
                           d.ent_period_end_date,
                           l_roll_180_start,
                           l_roll_180_end ) AND
              (NOT_WITHIN( d.week_start_date,
                           d.week_end_date,
                           l_roll_180_start,
                           l_roll_180_end ) OR
               NOT_WITHIN( d.week_start_date,
                           d.week_end_date,
                           d.ent_period_start_date,
                           d.ent_period_end_date )) THEN

               l_day_id  := d.day_id;
               l_day_sum := l_day_sum + l_rolling_180;

            END IF;

         END IF;

         ----------------------------------------------------------------------
         -- Processing rolling quarter calculations
         ----------------------------------------------------------------------
         IF l_current_day - 89 <= d.report_date THEN

            -- Find out rolling quarter start and end date
            l_roll_qtr_start := l_current_day - 89;
            l_roll_qtr_end := l_current_day;

            -----------------------------------------------------------
            -- 1. If report_date is at the end of the enterprise qtr and
            -- the enterprise qtr is fully within the rolling qtr then
            -- add the pre-defined rolling quarter usage to l_qtr_sum
            -----------------------------------------------------------
            IF (d.report_date = d.ent_qtr_end_date AND
               d.ent_qtr_start_date >= l_roll_qtr_start AND
               d.ent_qtr_end_date <= l_roll_qtr_end) THEN

               l_ent_qtr_id := d.ent_qtr_id;
               l_qtr_sum    := l_qtr_sum + l_rolling_qtr;

            -----------------------------------------------------------
            -- 2. If report_date is at the end of enterprise period and
            -- the enterprise period is fully within the rolling qtr and
            -- the enterprise qtr is not fully within the rolling qtr then
            -- add the pre-defined rolling quarter usage to l_month_sum
            -----------------------------------------------------------
            ELSIF d.report_date = d.ent_period_end_date AND
               d.ent_period_start_date >= l_roll_qtr_start AND
               d.ent_period_end_date <= l_roll_qtr_end AND
               NOT_WITHIN( d.ent_qtr_start_date,
                           d.ent_qtr_end_date,
                           l_roll_qtr_start,
                           l_roll_qtr_end ) THEN

               l_ent_period_id := d.ent_period_id;
               l_month_sum     := l_month_sum + l_rolling_qtr;

            -----------------------------------------------------------
            -- 3. If report_date is at the end of a week and
            -- the week is fully within the rolling qtr and
            -- the week is fully within enterprise period and
            -- the enterprise qtr is not fully within the rolling qtr and
            -- the enterprise period is not fully within the rolling qtr then
            -- add the pre-defined rolling quarter usage to l_week_sum
            -----------------------------------------------------------
            ELSIF d.report_date = d.week_end_date AND
               d.week_start_date >= l_roll_qtr_start AND
               d.week_end_date <= l_roll_qtr_end AND
               d.week_start_date >= d.ent_period_start_date AND
               d.week_end_date <= d.ent_period_end_date AND
               NOT_WITHIN( d.ent_qtr_start_date,
                           d.ent_qtr_end_date,
                           l_roll_qtr_start,
                           l_roll_qtr_end ) AND
               NOT_WITHIN( d.ent_period_start_date,
                           d.ent_period_end_date,
                           l_roll_qtr_start,
                           l_roll_qtr_end ) THEN

               l_week_id := d.week_id;
               l_week_sum := l_week_sum + l_rolling_qtr;

            -----------------------------------------------------------
            -- 4. If enterprise qtr is not fully within the rolling qtr and
            -- the enterprise period is not fully within the rolling qtr and
            -- (the week is not fully within the rolling qtr or
            -- the week is not fully within the enterprise period) then
            -- add the pre-defined rolling quarter usage to l_day_sum
            -----------------------------------------------------------
            ELSIF NOT_WITHIN( d.ent_qtr_start_date,
                              d.ent_qtr_end_date,
                              l_roll_qtr_start,
                              l_roll_qtr_end ) AND
               NOT_WITHIN( d.ent_period_start_date,
                           d.ent_period_end_date,
                           l_roll_qtr_start,
                           l_roll_qtr_end ) AND
              (NOT_WITHIN( d.week_start_date,
                           d.week_end_date,
                           l_roll_qtr_start,
                           l_roll_qtr_end ) OR
               NOT_WITHIN( d.week_start_date,
                           d.week_end_date,
                           d.ent_period_start_date,
                           d.ent_period_end_date )) THEN

               l_day_id  := d.day_id;
               l_day_sum := l_day_sum + l_rolling_qtr;

            END IF;

         END IF;

         -- AR DBI Changes: Added codes to process Rolling 60-day DSO period
         ----------------------------------------------------------------------
         -- Processing rolling 60-day calculations
         ----------------------------------------------------------------------
         IF l_current_day - 59 <= d.report_date THEN

            -- Find out rolling 60-day start and end date
            l_roll_60_start := l_current_day - 59;
            l_roll_60_end   := l_current_day;

            ---------------------------------------------------------------
            -- 1.IF report_date is at the end of the enterprise period
            -- AND the enterprise period is fully with the rolling 60-day
            -- THEN add the pre-defined rolling 60-day usage to l_month_sum
            ---------------------------------------------------------------
            IF (d.report_date = d.ent_period_end_date AND
                d.ent_period_start_date >= l_roll_60_start AND
                d.ent_period_end_date <= l_roll_60_end )THEN

               l_ent_period_id := d.ent_period_id;
               l_month_sum := l_month_sum + l_rolling_60;

            -------------------------------------------------------------------
            -- 2.IF report_date is the end of a week
            -- AND the week is fully within the rolling 60-day
            -- AND the week is fully within enterprise period
            -- AND the enterprise period is not fully within the rolling 60-day
            -- THEN add the pre-defined rolling 60-day usage to l_week_sum
            -------------------------------------------------------------------
            ELSIF d.report_date = d.week_end_date AND
               d.week_start_date >= l_roll_60_start AND
               d.week_end_date <= l_roll_60_end AND
               d.week_start_date >= d.ent_period_start_date AND
               d.week_end_date <= d.ent_period_end_date AND
               NOT_WITHIN( d.ent_period_start_date,
                           d.ent_period_end_date,
                           l_roll_60_start,
                           l_roll_60_end )
			   THEN

               l_week_id  := d.week_id;
               l_week_sum := l_week_sum + l_rolling_60;

            --------------------------------------------------------------------
            -- 3.IF the enterprise period is not fully within the rolling 60-day
            -- AND (   the week is not fully within the rolling 60-day
            --      OR the week is not fully within the enterprise period)
            -- THEN add the pre-defined rolling 60-day usage to l_day_sum
            --------------------------------------------------------------------
            ELSIF NOT_WITHIN( d.ent_period_start_date,
                              d.ent_period_end_date,
                              l_roll_60_start,
                              l_roll_60_end ) AND
              (NOT_WITHIN( d.week_start_date,
                           d.week_end_date,
                           l_roll_60_start,
                           l_roll_60_end) OR
               NOT_WITHIN( d.week_start_date,
                           d.week_end_date,
                           d.ent_period_start_date,
                           d.ent_period_end_date )) THEN

               l_day_id  := d.day_id;
               l_day_sum := l_day_sum + l_rolling_60;

            END IF;

         END IF;

         -- AR DBI Changes: Added codes to process Rolling 45-day DSO period
         ----------------------------------------------------------------------
         -- Processing rolling 45-day calculations
         ----------------------------------------------------------------------
         IF l_current_day - 44 <= d.report_date THEN

            -- Find out rolling 45-day start and end date
            l_roll_45_start := l_current_day - 44;
            l_roll_45_end   := l_current_day;

            ---------------------------------------------------------------
            -- 1.IF report_date is at the end of the enterprise period
            -- AND the enterprise period is fully with the rolling 60-day
            -- THEN add the pre-defined rolling 45-day usage to l_month_sum
            ---------------------------------------------------------------
            IF (d.report_date = d.ent_period_end_date AND
                d.ent_period_start_date >= l_roll_45_start AND
                d.ent_period_end_date <= l_roll_45_end )THEN

               l_ent_period_id := d.ent_period_id;
               l_month_sum := l_month_sum + l_rolling_45;

            -------------------------------------------------------------------
            -- 2.IF report_date is the end of a week
            -- AND the week is fully within the rolling 45-day
            -- AND the week is fully within enterprise period
            -- AND the enterprise period is not fully within the rolling 45-day
            -- THEN add the pre-defined rolling 45-day usage to l_week_sum
            -------------------------------------------------------------------
            ELSIF d.report_date = d.week_end_date AND
               d.week_start_date >= l_roll_45_start AND
               d.week_end_date <= l_roll_45_end AND
               d.week_start_date >= d.ent_period_start_date AND
               d.week_end_date <= d.ent_period_end_date AND
               NOT_WITHIN( d.ent_period_start_date,
                           d.ent_period_end_date,
                           l_roll_45_start,
                           l_roll_45_end )
			   THEN

               l_week_id  := d.week_id;
               l_week_sum := l_week_sum + l_rolling_45;

            --------------------------------------------------------------------
            -- 3.IF the enterprise period is not fully within the rolling 45-day
            -- AND (   the week is not fully within the rolling 45-day
            --      OR the week is not fully within the enterprise period)
            -- THEN add the pre-defined rolling 45-day usage to l_day_sum
            --------------------------------------------------------------------
            ELSIF NOT_WITHIN( d.ent_period_start_date,
                              d.ent_period_end_date,
                              l_roll_45_start,
                              l_roll_45_end ) AND
              (NOT_WITHIN( d.week_start_date,
                           d.week_end_date,
                           l_roll_45_start,
                           l_roll_45_end) OR
               NOT_WITHIN( d.week_start_date,
                           d.week_end_date,
                           d.ent_period_start_date,
                           d.ent_period_end_date )) THEN

               l_day_id  := d.day_id;
               l_day_sum := l_day_sum + l_rolling_45;

            END IF;

         END IF;

         ----------------------------------------------------------------------
         -- Processing rolling month calculations
         ----------------------------------------------------------------------
         IF l_current_day - 29 <= d.report_date THEN

            -- Find out rolling month start and end date
            l_roll_month_start := l_current_day - 29;
            l_roll_month_end   := l_current_day;

            -----------------------------------------------------------
            -- 1. If report_date is at the end of the enterprise period and
            -- the enterprise period is fully with the rolling month then
            -- add the pre-defined rolling month usage to l_month_sum
            -----------------------------------------------------------
            IF d.report_date = d.ent_period_end_date AND
               d.ent_period_start_date >= l_roll_month_start AND
               d.ent_period_end_date <= l_roll_month_end /*AND
-- *** Why do we need to check the enterprise period is not fully within the
--     rolling month?
               NOT_WITHIN( d.ent_period_start_date,
                           d.ent_period_end_date,
                           l_roll_month_start,
                           l_roll_month_end) */THEN

               l_ent_period_id := d.ent_period_id;
               l_month_sum := l_month_sum + l_rolling_month;

            -----------------------------------------------------------
            -- 2. If report_date is the end of a week and
            -- the week is fully within the rolling month and
            -- the enterprise period is not fully within the rolling month then
            -- add the pre-defined rolling month usage to l_week_sum
            -----------------------------------------------------------
            ELSIF d.report_date = d.week_end_date AND
               d.week_start_date >= l_roll_month_start AND
               d.week_end_date <= l_roll_month_end AND
-- *** We need to check its enterprise period is not fully within the rolling
--     month
               NOT_WITHIN( d.ent_period_start_date,
                           d.ent_period_end_date,
                           l_roll_month_start,
                           l_roll_month_end) THEN

               l_week_id  := d.week_id;
               l_week_sum := l_week_sum + l_rolling_month;

            -----------------------------------------------------------
            -- 3. If the enterprise period is not fully within the rolling month
            -- and the week is not fully within the rolling month then
            -- add the pre-defined rolling month usage to l_day_sum
            -----------------------------------------------------------
            ELSIF NOT_WITHIN( d.ent_period_start_date,
                              d.ent_period_end_date,
                              l_roll_month_start,
                              l_roll_month_end) AND
               NOT_WITHIN( d.week_start_date,
                           d.week_end_date,
                           l_roll_month_start,
                           l_roll_month_end) THEN

               l_day_id  := d.day_id;
               l_day_sum := l_day_sum + l_rolling_month;

            END IF;

         END IF;

         ----------------------------------------------------------------------
         -- Processing rolling week calculations
         ----------------------------------------------------------------------
         IF l_current_day-6 <= d.report_date THEN

            -- Find out rolling week start and end date
            l_roll_week_start := l_current_day-6;
            l_roll_week_end   := l_current_day;

            -----------------------------------------------------------
            -- 1. If report_date is the end of week and
            -- the week is fully within the rolling week then
            -- add the pre-defined rolling week usage to l_week_sum
            -----------------------------------------------------------
            IF d.report_date = d.week_end_date AND
               d.week_start_date >= l_roll_week_start AND
               d.week_end_date <= l_roll_week_end THEN

               l_week_id  := d.week_id;
               l_week_sum := l_week_sum + l_rolling_week;

            -----------------------------------------------------------
            -- 2. If the week is not fully with the rolling week then
            -- add the pre-defined rolling week usage to l_day_sum
            -----------------------------------------------------------
            ELSIF NOT_WITHIN( d.week_start_date,
                              d.week_end_date,
                              l_roll_week_start,
                              l_roll_week_end ) THEN

               l_day_id  := d.day_id;
               l_day_sum := l_day_sum + l_rolling_week;

            END IF;

         END IF;

         ----------------------------------------------------------------------
         -- Processing days
         ----------------------------------------------------------------------
         IF l_current_day = d.report_date THEN

            l_day_id  := d.day_id;
            l_day_sum := l_day_sum + l_day;

         END IF;

         ----------------------------------------------------------------------
         -- Processing XTD year calculations
         ----------------------------------------------------------------------
         IF l_current_day <= d.ent_year_end_date THEN

            -- Find out xtd year start and end date
            l_xtd_year_start := d.ent_year_start_date;
            l_xtd_year_end := l_current_day;

            -----------------------------------------------------------
            -- 1. if report_date is the end of enterprise year then
            -- add the pre-defined YTD calculation usage to l_year_sum
            -----------------------------------------------------------
            IF d.report_date = d.ent_year_end_date THEN

               l_ent_year_id := d.ent_year_id;
               l_year_sum := l_year_sum + l_xtd_year;
               l_year_sum := l_year_sum + l_itd_year;
               l_year_sum := l_year_sum + l_current_year;

            -----------------------------------------------------------
            -- 2. If report_date is the end of enterprise qtr and
            -- report_date is not the end of enterprise year and
            -- xtd year end < the end of the enterprise year then
            -- add the pre-defined YTD calculation usage to l_qtr_sum
            -----------------------------------------------------------
            ELSIF d.report_date = d.ent_qtr_end_date AND
               d.report_date <> d.ent_year_end_date AND
               l_xtd_year_end < d.ent_year_end_date THEN

               l_ent_qtr_id := d.ent_qtr_id;
               l_qtr_sum    := l_qtr_sum + l_xtd_year;
               l_qtr_sum    := l_qtr_sum + l_itd_year;

            -----------------------------------------------------------
            -- 3. If report_date is the end of enterprise period and
            -- report_date is not the end of enterprise year and
            -- report_date is not the end of enterprise qtr and
            -- xtd year end < the end of the enterprise year and
            -- xtd year end < the end of the enterprise qtr then
            -- add the pre-defined YTD calculation usage to l_month_sum
            -----------------------------------------------------------
            ELSIF d.report_date = d.ent_period_end_date AND
               d.report_date <> d.ent_year_end_date AND
               d.report_date <> d.ent_qtr_end_date AND
               l_xtd_year_end < d.ent_year_end_date AND
               l_xtd_year_end < d.ent_qtr_end_date THEN

               l_ent_period_id := d.ent_period_id;
               l_month_sum     := l_month_sum + l_xtd_year;
               l_month_sum     := l_month_sum + l_itd_year;

            -----------------------------------------------------------
            -- 4. If report_date is the end of a week and
            -- report_date is not the end of enterprise year and
            -- report_date is not the end of enterprise qtr and
            -- report_date is not the end of enterprise period and
            -- xtd year end < the end of the enterprise year and
            -- xtd year end < the end of the enterprise qtr and
            -- xtd year end < the end of the enterprise period and
            -- week is within the enterprise period and
            -- week is within the xtd year end then
            -- add the pre-defined YTD calculation usage to l_week_sum
            -----------------------------------------------------------
            ELSIF d.report_date = d.week_end_date AND
               d.report_date <> d.ent_year_end_date AND
               d.report_date <> d.ent_qtr_end_date AND
               d.report_date <> d.ent_period_end_date AND
               l_xtd_year_end < d.ent_year_end_date AND
               l_xtd_year_end < d.ent_qtr_end_date AND
               l_xtd_year_end < d.ent_period_end_date AND
               d.week_start_date >= d.ent_period_start_date AND
               d.week_end_date <= d.ent_period_end_date AND
               d.week_start_date >= l_xtd_year_start AND
               d.week_end_date <= l_xtd_year_end THEN

               l_week_id := d.week_id;
               l_week_sum := l_week_sum + l_xtd_year;
               l_week_sum := l_week_sum + l_itd_year;

            -----------------------------------------------------------
            -- 5. If report_date is not the end of enterprise year and
            -- report_date is not the end of enterprise qtr and
            -- report_date is not the end of enterprise period and
            -- enterprise period is not within xtd year and
            -- (week is not within xtd year or
            --  week is not within enterprise period) then
            -- add the pre-defined YTD calculation usage to l_day_sum
            -----------------------------------------------------------
            ELSIF d.report_date <> d.ent_year_end_date AND
               d.report_date <> d.ent_qtr_end_date AND
               d.report_date <> d.ent_period_end_date AND
               NOT_WITHIN( d.ent_period_start_date,
                           d.ent_period_end_date,
                           l_xtd_year_start,
                           l_xtd_year_end ) AND
               (NOT_WITHIN( d.week_start_date,
                            d.week_end_date,
                            l_xtd_year_start,
                            l_xtd_year_end ) OR
                NOT_WITHIN( d.week_start_date,
                            d.week_end_date,
                            d.ent_period_start_date,
                            d.ent_period_end_date )) THEN

               l_day_id  := d.day_id;
               l_day_sum := l_day_sum + l_xtd_year;
               l_day_sum := l_day_sum + l_itd_year;

            END IF;

         END IF;

         ----------------------------------------------------------------------
         -- Processing XTD quarter calculations
         ----------------------------------------------------------------------
         IF l_current_day <= d.ent_qtr_end_date THEN

            -- Find out xtd quarter start and end date
            l_xtd_qtr_start := d.ent_qtr_start_date;
            l_xtd_qtr_end   := l_current_day;

            -----------------------------------------------------------
            -- 1. If report_date is the end of enterprise qtr then
            -- add the pre-defined QTD calculation usage to l_qtr_sum
            -----------------------------------------------------------
            IF d.report_date = d.ent_qtr_end_date THEN

               l_ent_qtr_id := d.ent_qtr_id;
               l_qtr_sum    := l_qtr_sum + l_xtd_qtr;
               l_qtr_sum    := l_qtr_sum + l_current_qtr;

            -----------------------------------------------------------
            -- 2. If report_date is the end of enterprise period and
            -- report_date is not the end of enterprise qtr and
            -- xtd qtr < end of enterprise qtr then
            -- add the pre-defined QTD calculation usage to l_month_sum
            -----------------------------------------------------------
            ELSIF d.report_date = d.ent_period_end_date AND
               d.report_date <> d.ent_qtr_end_date AND
               l_xtd_qtr_end < d.ent_qtr_end_date THEN

               l_ent_period_id := d.ent_period_id;
               l_month_sum     := l_month_sum + l_xtd_qtr;

            -----------------------------------------------------------
            -- 3. If report_date is the end of a week and
            -- report_date is not the end of enterprise qtr and
            -- report_date is not the end of enterprise period and
            -- xtd qtr end < the end of the enterprise qtr and
            -- xtd qtr end < the end of the enterprise period and
            -- week is within the enterprise period and
            -- week is within the xtd qtr then
            -- add the pre-defined QTD calculation usage to l_week_sum
            -----------------------------------------------------------
            ELSIF d.report_date = d.week_end_date AND
               d.report_date <> d.ent_qtr_end_date AND
               d.report_date <> d.ent_period_end_date AND
               l_xtd_qtr_end < d.ent_qtr_end_date AND
               l_xtd_qtr_end < d.ent_period_end_date AND
               d.week_start_date >= d.ent_period_start_date AND
               d.week_end_date <= d.ent_period_end_date AND
               d.week_start_date >= l_xtd_qtr_start AND
               d.week_end_date <=  l_xtd_qtr_end THEN

               l_week_id  := d.week_id;
               l_week_sum := l_week_sum + l_xtd_qtr;

            -----------------------------------------------------------
            -- 4. If report_date is not the end of enterprise qtr and
            -- report_date is not the end of enterprise period and
            -- enterprise period is not within xtd qtr and
            -- (week is not within xtd qtr or
            --  week is not within enterprise period) then
            -- add the pre-defined QTD calculation usage to l_day_sum
            -----------------------------------------------------------
            ELSIF d.report_date <> d.ent_qtr_end_date AND
               d.report_date <> d.ent_period_end_date AND
               NOT_WITHIN( d.ent_period_start_date,
                           d.ent_period_end_date,
                           l_xtd_qtr_start,
                           l_xtd_qtr_end ) AND
               (NOT_WITHIN( d.week_start_date,
                            d.week_end_date,
                            l_xtd_qtr_start,
                            l_xtd_qtr_end ) OR
                NOT_WITHIN( d.week_start_date,
                            d.week_end_date,
                            d.ent_period_start_date,
                            d.ent_period_end_date )) THEN

               l_day_id  := d.day_id;
               l_day_sum := l_day_sum + l_xtd_qtr;

            END IF;

         END IF;

         ----------------------------------------------------------------------
         -- Processing XTD month calculations
         ----------------------------------------------------------------------
         IF l_current_day <= d.ent_period_end_date THEN

            -- Find out xtd period start and end date
            l_xtd_period_start := d.ent_period_start_date;
            l_xtd_period_end   := l_current_day;

            -----------------------------------------------------------
            -- 1. If report_date is the end of enterprise period then
            -- add the pre-defined PTD calculation usage to l_month_sum
            -----------------------------------------------------------
            IF d.report_date = d.ent_period_end_date THEN

               l_ent_period_id := d.ent_period_id;
               l_month_sum     := l_month_sum + l_xtd_period;
               l_month_sum     := l_month_sum + l_current_month;

            -----------------------------------------------------------
            -- 2. If report_date is the end of a week and
            -- report_date is not the end of enterprise period and
            -- xtd period end < the end of the enterprise period and
            -- week is within the xtd period and then
            -- add the pre-defined PTD calculation usage to l_week_sum
            -----------------------------------------------------------
            ELSIF d.report_date = d.week_end_date AND
               d.report_date <> d.ent_period_end_date AND
               l_xtd_period_end < d.ent_period_end_date AND
               d.week_start_date >= l_xtd_period_start AND
               d.week_end_date <= l_xtd_period_end THEN

               l_week_id  := d.week_id;
               l_week_sum := l_week_sum + l_xtd_period;

            -----------------------------------------------------------
            -- 3. If report_date is not the end of enterprise period and
            -- xtd period end < the end of the period and
            -- (week is not within xtd period or
            --  week is not within enterprise period) then
            -- add the pre-defined PTD calculation usage to l_day_sum
            -----------------------------------------------------------
            ELSIF d.report_date <> d.ent_period_end_date AND
               l_xtd_period_end < d.ent_period_end_date AND
               (NOT_WITHIN( d.week_start_date,
                            d.week_end_date,
                            l_xtd_period_start,
                            l_xtd_period_end ) OR
                NOT_WITHIN( d.week_start_date,
                            d.week_end_date,
                            d.ent_period_start_date,
                            d.ent_period_end_date )) THEN

               l_day_id  := d.day_id;
               l_day_sum := l_day_sum + l_xtd_period;

            END IF;

         END IF;

         ----------------------------------------------------------------------
         -- Processing XTD week calculations
         ----------------------------------------------------------------------
         IF l_current_day <= d.week_end_date THEN

            -- Find out xtd week start and end date
            l_xtd_week_start := d.week_start_date;
            l_xtd_week_end   := l_current_day;

            -----------------------------------------------------------
            -- 1. If report_date is the end of a week then
            -- add the pre-defined WTD calculation usage to l_week_sum
            -----------------------------------------------------------
            IF d.report_date = d.week_end_date THEN

               l_week_id  := d.week_id;
               l_week_sum := l_week_sum + l_xtd_week;
               l_week_sum := l_week_sum + l_current_week;

            -----------------------------------------------------------
            -- 2. If report_date is not the end of the week and
            -- the current day is not the end of the week then
            -- add the pre-defined WTD calculation usage to l_day_sum
            -----------------------------------------------------------
            ELSIF d.report_date <> d.week_end_date AND
               l_current_day <> d.week_end_date THEN

               l_day_id  := d.day_id;
               l_day_sum := l_day_sum + l_xtd_week;

            END IF;

         END IF;

         ----------------------------------------------------------------------
         -- Inserting rows into FII_TIME_STRUCTURES for Rolling and XTD calendar
         ----------------------------------------------------------------------
         IF l_ent_year_id IS NOT NULL THEN
            insert_row(l_current_day, l_ent_year_id, l_nested_ent_year,
                       l_year_sum, INCLUDES_XTD(l_year_sum,l_rolling_week));
            l_row_cnt :=  l_row_cnt+1;
         END IF;

         IF l_ent_qtr_id IS NOT NULL THEN
            insert_row(l_current_day, l_ent_qtr_id, l_nested_ent_qtr,
                       l_qtr_sum, INCLUDES_XTD(l_qtr_sum,l_rolling_week));
            l_row_cnt :=  l_row_cnt+1;
         END IF;

         IF l_ent_period_id IS NOT NULL THEN
            insert_row(l_current_day, l_ent_period_id, l_nested_ent_period,
                       l_month_sum, INCLUDES_XTD(l_month_sum,l_rolling_week));
            l_row_cnt :=  l_row_cnt+1;
         END IF;

         IF l_week_id IS NOT NULL THEN
            insert_row(l_current_day, l_week_id, l_nested_week,
                      l_week_sum, INCLUDES_XTD(l_week_sum,l_rolling_week));
            l_row_cnt :=  l_row_cnt+1;
         END IF;

         IF l_day_id IS NOT NULL THEN
            insert_row(l_current_day, l_day_id, l_nested_day,
                      l_day_sum, INCLUDES_XTD(l_day_sum,l_rolling_week));
            l_row_cnt :=  l_row_cnt+1;
         END IF;

      END LOOP;

      -- Initialize time IDs and aggregate record_type_ids for each time period
      l_ent_year_id   := null;
      l_year_sum      := 0;
      l_ent_qtr_id    := null;
      l_qtr_sum       := 0;
      l_ent_period_id := null;
      l_month_sum     := 0;
      l_week_id       := null;
      l_week_sum      := 0;
      l_day_id        := null;
      l_day_sum       := 0;

      ----------------------------------------------------------------------
      -- Processing Current year calculations
      ----------------------------------------------------------------------
      IF d.report_date BETWEEN d.ent_year_start_date
                           AND d.ent_year_end_date and
         d.report_date <> d.ent_year_end_date THEN

         l_ent_year_id := d.ent_year_id;
         l_year_sum := l_year_sum + l_current_year;

      END IF;

      ----------------------------------------------------------------------
      -- Processing Current quarter calculations
      ----------------------------------------------------------------------
      IF d.report_date BETWEEN d.ent_qtr_start_date
                           AND d.ent_qtr_end_date and
         d.report_date <> d.ent_qtr_end_date THEN

         l_ent_qtr_id := d.ent_qtr_id;
         l_qtr_sum    := l_qtr_sum + l_current_qtr;

      END IF;

      ----------------------------------------------------------------------
      -- Processing Current month calculations
      ----------------------------------------------------------------------
      IF d.report_date BETWEEN d.ent_period_start_date
                           AND d.ent_period_end_date and
         d.report_date <> d.ent_period_end_date THEN

         l_ent_period_id := d.ent_period_id;
         l_month_sum     := l_month_sum + l_current_month;

      END IF;

      ----------------------------------------------------------------------
      -- Processing Current week calculations
      ----------------------------------------------------------------------
      IF d.report_date BETWEEN d.week_start_date
                           AND d.week_end_date and
         d.report_date <> d.week_end_date THEN

         l_week_id := d.week_id;
         l_week_sum := l_week_sum + l_current_week;

      END IF;

      ----------------------------------------------------------------------
      -- Inserting rows into FII_TIME_STRUCTURES for Current periods
      ----------------------------------------------------------------------
      IF l_ent_year_id IS NOT NULL THEN
         insert_row(d.report_date, l_ent_year_id, l_nested_ent_year, l_year_sum, 'Y');
         l_row_cnt :=  l_row_cnt+1;
      END IF;

      IF l_ent_qtr_id IS NOT NULL THEN
         insert_row(d.report_date, l_ent_qtr_id, l_nested_ent_qtr, l_qtr_sum, 'Y');
         l_row_cnt :=  l_row_cnt+1;
      END IF;

      IF l_ent_period_id IS NOT NULL THEN
         insert_row(d.report_date, l_ent_period_id, l_nested_ent_period,
                    l_month_sum, 'Y');
         l_row_cnt :=  l_row_cnt+1;
      END IF;

      IF l_week_id IS NOT NULL THEN
         insert_row(d.report_date, l_week_id, l_nested_week, l_week_sum, 'Y');
         l_row_cnt :=  l_row_cnt+1;
      END IF;

      IF l_day_id IS NOT NULL THEN
         insert_row(d.report_date, l_day_id, l_nested_day, l_day_sum, 'Y');
         l_row_cnt :=  l_row_cnt+1;
      END IF;

      ----------------------------------------------------------------------
      -- Processing Inception-To-Date
      ----------------------------------------------------------------------
      FOR y in 1..l_ent_year_id_tbl.count LOOP

         l_ent_year_id   := null;
         l_year_sum := 0;

         IF (l_ent_year_date_tbl(y) >= g_global_start_date AND
             l_ent_year_date_tbl(y) < d.report_date) THEN

            insert_row(d.report_date, l_ent_year_id_tbl(y), l_nested_ent_year,
                       l_itd_year, 'Y');
            l_row_cnt :=  l_row_cnt+1;

         END IF;

      END LOOP;

      COMMIT;

   END LOOP;

   IF g_debug_flag = 'Y' THEN
      fii_util.put_line(TO_CHAR(l_row_cnt)||' records has been populated to the Reporting Structure table for XTD and Rolling Periods');
   END IF;

   fnd_stats.gather_table_stats(ownname => g_schema
                               , tabname => 'FII_TIME_STRUCTURES'
                               );

   if g_debug_flag = 'Y' then
      fii_util.put_line('Gathered statistics for Reporting Structure table for XTD and Rolling Periods');
    end if;

END LOAD_TIME_STRUCTURES;

END FII_TIME_STRUCTURE_C;

/
