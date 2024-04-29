--------------------------------------------------------
--  DDL for Package Body HRI_OPL_DBI_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_DBI_CALENDAR" AS
/* $Header: hriodcal.pkb 120.2 2005/08/31 00:46:57 jtitmas noship $ */

TYPE mtdt_period_rec_type IS RECORD
  (days           PLS_INTEGER,
   type           VARCHAR2(30),
   trend_points   PLS_INTEGER);

TYPE g_mdtd_period_tab_type IS TABLE OF mtdt_period_rec_type
                  INDEX BY BINARY_INTEGER;

TYPE g_varchar_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;

/* PL/SQL table storing metadata about periods */
g_mtdt_prds_tab             g_mdtd_period_tab_type;

/* PL/SQL table for bulk inserting into the workforce fact calendar */
g_wrkfc_type                g_varchar_tab_type;
g_wrkfc_comp_type           g_varchar_tab_type;
g_wrkfc_start_date          g_date_tab_type;
g_wrkfc_end_date            g_date_tab_type;
g_wrkfc_comp_start_date     g_date_tab_type;
g_wrkfc_comp_end_date       g_date_tab_type;
g_wrkfc_snapshot_date       g_date_tab_type;
g_wrkfc_row_count           PLS_INTEGER;

/* PL/SQL table for bulk inserting into the workforce change fact calendar */
g_wcnt_chg_type             g_varchar_tab_type;
g_wcnt_chg_comp_type        g_varchar_tab_type;
g_wcnt_chg_start_date       g_date_tab_type;
g_wcnt_chg_end_date         g_date_tab_type;
g_wcnt_chg_comp_start_date  g_date_tab_type;
g_wcnt_chg_comp_end_date    g_date_tab_type;
g_wcnt_chg_snapshot_date    g_date_tab_type;
g_wcnt_chg_row_count        PLS_INTEGER;

/* Profiles */
-- How many days in advance to provide snapshots
g_future_days               PLS_INTEGER;
-- Whether DATE snapshots are also required at the start of periods
g_snapshot_period_start     BOOLEAN;
-- Whether snapshots are turned on
g_collect_snapshots         BOOLEAN;

/* Current date */
g_sysdate                   DATE := TRUNC(SYSDATE);


/******************************************************************************/
/* Full Refresh                                                               */
/* ============                                                               */
/* The main logic for the full refresh works as follows:                      */
/*                                                                            */
/* For the current system date, loop through the different time periods:      */
/*   Year                                                                     */
/*   Quarter                                                                  */
/*   Month                                                                    */
/*   Week                                                                     */
/*                                                                            */
/* For each time period, store the snapshots required to support reporting    */
/* for that period:                                                           */
/*                                                                            */
/*   Period Snapshots                                                         */
/*   ----------------                                                         */
/*   For the periods snapshot calendar the following snapshots are stored     */
/*   in the pl/sql table ready for bulk insert. These are repeated for each   */
/*   time period:                                                             */
/*     Current period snapshot                                                */
/*     Previous year snapshot                                                 */
/*     Previous period snapshots (up to maximum trend periods)                */
/*                                                                            */
/*   For the trend periods, collecting the period start dates is equivalent   */
/*   to increasing the number of previous period end dates collected by 1.    */
/*                                                                            */
/******************************************************************************/


/******************************************************************************/
/* Defines properties of each period:                                         */
/*    - period length in days                                                 */
/*    - period name (time period type)                                        */
/*    - maximum number of trend points for the period                         */
/******************************************************************************/
PROCEDURE set_metadata IS

BEGIN

  g_mtdt_prds_tab(1).days := 365;
  g_mtdt_prds_tab(1).type := 'FII_ROLLING_YEAR';
  g_mtdt_prds_tab(1).trend_points := 4;
  g_mtdt_prds_tab(2).days :=  90;
  g_mtdt_prds_tab(2).type := 'FII_ROLLING_QTR';
  g_mtdt_prds_tab(2).trend_points := 8;
  g_mtdt_prds_tab(3).days :=  30;
  g_mtdt_prds_tab(3).type := 'FII_ROLLING_MONTH';
  g_mtdt_prds_tab(3).trend_points := 12;
  g_mtdt_prds_tab(4).days :=   7;
  g_mtdt_prds_tab(4).type := 'FII_ROLLING_WEEK';
  g_mtdt_prds_tab(4).trend_points := 13;

/* Set the number of future days to collect */
/* Bug 4454369, Changed g_future_days to 6. This cannot be more than 6 */

  g_future_days := 6;

END set_metadata;

/******************************************************************************/
/* Gets values from relevant profile options                                  */
/******************************************************************************/
PROCEDURE get_profile_values IS

BEGIN

/* Check whether snapshots are enabled */
  IF (fnd_profile.value('HRI_DBI_PER_SNRMGR_SNPSHTS') = 'Y') THEN
    g_collect_snapshots := TRUE;
  ELSE
    g_collect_snapshots := FALSE;
  END IF;

/* Check whether extra snapshots are required to support the turnover */
/* calculation method */
  IF (fnd_profile.value('HR_TRNVR_CALC_MTHD') = 'WMV_STARTENDAVG') THEN
    g_snapshot_period_start := TRUE;
  ELSE
    g_snapshot_period_start := FALSE;
  END IF;

END get_profile_values;


/******************************************************************************/
/* Bulk insert snapshots for the workforce fact                               */
/******************************************************************************/
PROCEDURE bulk_insert_wrkfc IS

BEGIN

  FORALL i IN 1..g_wrkfc_row_count
    INSERT INTO hri_cal_snpsht_wrkfc
      (period_type,
       comparison_type,
       effective_date,
       curr_start_date,
       curr_end_date,
       comp_start_date,
       comp_end_date,
       snapshot_date)
      VALUES
       (g_wrkfc_type(i),
        g_wrkfc_comp_type(i),
        g_wrkfc_end_date(i),
        g_wrkfc_start_date(i),
        g_wrkfc_end_date(i),
        g_wrkfc_comp_start_date(i),
        g_wrkfc_comp_end_date(i),
        g_wrkfc_snapshot_date(i));

END bulk_insert_wrkfc;

/******************************************************************************/
/* Bulk insert snapshots for the workforce changes fact                       */
/******************************************************************************/
PROCEDURE bulk_insert_wcnt_chg IS

BEGIN

  FORALL i IN 1..g_wcnt_chg_row_count
    INSERT INTO hri_cal_snpsht_wcnt_chg
      (period_type,
       comparison_type,
       effective_start_date,
       effective_end_date,
       snapshot_date)
      VALUES
       (g_wcnt_chg_type(i),
        g_wcnt_chg_comp_type(i),
        g_wcnt_chg_start_date(i),
        g_wcnt_chg_end_date(i),
        g_wcnt_chg_snapshot_date(i));

END bulk_insert_wcnt_chg;

/******************************************************************************/
/* Insert a single period into the workforce fact calendar                    */
/******************************************************************************/
PROCEDURE insert_wrkfc_period(p_curr_start_date  IN DATE,
                              p_curr_end_date    IN DATE,
                              p_comp_start_date  IN DATE,
                              p_comp_end_date    IN DATE,
                              p_period_type      IN VARCHAR2,
                              p_comparison_type  IN VARCHAR2,
                              p_snapshot_date    IN DATE) IS

BEGIN

  g_wrkfc_row_count := g_wrkfc_row_count + 1;
  g_wrkfc_type(g_wrkfc_row_count) := p_period_type;
  g_wrkfc_comp_type(g_wrkfc_row_count) := p_comparison_type;
  g_wrkfc_start_date(g_wrkfc_row_count) := p_curr_start_date;
  g_wrkfc_end_date(g_wrkfc_row_count) := p_curr_end_date;
  g_wrkfc_comp_start_date(g_wrkfc_row_count) := p_comp_start_date;
  g_wrkfc_comp_end_date(g_wrkfc_row_count) := p_comp_end_date;
  g_wrkfc_snapshot_date(g_wrkfc_row_count) := p_snapshot_date;

END insert_wrkfc_period;

/******************************************************************************/
/* Insert a single period into the workforce change fact calendar             */
/******************************************************************************/
PROCEDURE insert_wcnt_chg_period(p_start_date       IN DATE,
                                 p_end_date         IN DATE,
                                 p_period_type      IN VARCHAR2,
                                 p_comparison_type  IN VARCHAR2,
                                 p_snapshot_date    IN DATE) IS

BEGIN

  g_wcnt_chg_row_count := g_wcnt_chg_row_count + 1;
  g_wcnt_chg_type(g_wcnt_chg_row_count) := p_period_type;
  g_wcnt_chg_comp_type(g_wcnt_chg_row_count) := p_comparison_type;
  g_wcnt_chg_start_date(g_wcnt_chg_row_count) := p_start_date;
  g_wcnt_chg_end_date(g_wcnt_chg_row_count) := p_end_date;
  g_wcnt_chg_snapshot_date(g_wcnt_chg_row_count) := p_snapshot_date;

END insert_wcnt_chg_period;

/******************************************************************************/
/* Loads the snapshot dates and periods into pl/sql tables to support         */
/* reporting on the given effective date                                      */
/******************************************************************************/
PROCEDURE load_snapshots_for_date(p_effective_date  IN DATE) IS

  l_days_in_year     PLS_INTEGER;
  l_offset           PLS_INTEGER;
  l_comparison_type  VARCHAR2(30);

BEGIN

-- If start date snapshots are required add extra period to the trend snapshots
  IF g_snapshot_period_start THEN
    l_offset := 0;
  ELSE
    l_offset := 1;
  END IF;

-- Days in year
  l_days_in_year := p_effective_date - ADD_MONTHS(p_effective_date, -12);

-- Loop through Period Types
  FOR i IN g_mtdt_prds_tab.FIRST..g_mtdt_prds_tab.LAST LOOP

  -- Add workforce change period for Previous Year
    insert_wcnt_chg_period
     (p_start_date => p_effective_date - l_days_in_year
                      - g_mtdt_prds_tab(i).days + 1,
      p_end_date => p_effective_date - l_days_in_year,
      p_period_type => g_mtdt_prds_tab(i).type,
      p_comparison_type => 'YEARLY',
      p_snapshot_date => p_effective_date);

  -- Add workforce period with previous year
    insert_wrkfc_period
     (p_curr_start_date => p_effective_date - g_mtdt_prds_tab(i).days + 1,
      p_curr_end_date => p_effective_date,
      p_comp_start_date => p_effective_date - l_days_in_year
                      - g_mtdt_prds_tab(i).days + 1,
      p_comp_end_date => p_effective_date - l_days_in_year,
      p_period_type => g_mtdt_prds_tab(i).type,
      p_comparison_type => 'YEARLY',
      p_snapshot_date => p_effective_date);

    -- Trend periods
      FOR j IN 0..(g_mtdt_prds_tab(i).trend_points + l_offset) LOOP

      -- Set comparison type
        IF (j = 0) THEN
          l_comparison_type := 'CURRENT';
        ELSIF (j = 1) THEN
          l_comparison_type := 'SEQUENTIAL';
        ELSE
          l_comparison_type := 'TREND';
        END IF;

      -- Insert trend period for workforce changes calendar
        insert_wcnt_chg_period
         (p_start_date => p_effective_date - (j * g_mtdt_prds_tab(i).days)
                          - g_mtdt_prds_tab(i).days + 1,
          p_end_date => p_effective_date - (j * g_mtdt_prds_tab(i).days),
          p_period_type => g_mtdt_prds_tab(i).type,
          p_comparison_type => l_comparison_type,
          p_snapshot_date => p_effective_date);

      -- Insert trend period for workforce calendar
      -- (less periods need adding because the each snapshot contains the previous
      --  calculations required)
        IF (j > 0) THEN
          insert_wrkfc_period
           (p_curr_start_date => p_effective_date - ((j - 1) * g_mtdt_prds_tab(i).days)
                                 - g_mtdt_prds_tab(i).days + 1,
            p_curr_end_date => p_effective_date - ((j - 1) * g_mtdt_prds_tab(i).days),
            p_comp_start_date => p_effective_date - (j * g_mtdt_prds_tab(i).days)
                                 - g_mtdt_prds_tab(i).days + 1,
            p_comp_end_date => p_effective_date - (j * g_mtdt_prds_tab(i).days),
            p_period_type => g_mtdt_prds_tab(i).type,
            p_comparison_type => l_comparison_type,
            p_snapshot_date => p_effective_date);
        END IF;

      END LOOP;  -- j (Trend periods)

  END LOOP;  -- i (Time periods)

END load_snapshots_for_date;

/******************************************************************************/
/* Loads the snapshot dates and periods into pl/sql tables                    */
/******************************************************************************/
PROCEDURE load_snapshots IS

BEGIN

-- Loop through future dates to support snapshots
  FOR i IN 0..g_future_days LOOP

  -- Load pl/sql tables with snapshots required to support
  -- reporting on the given date
    load_snapshots_for_date
     (p_effective_date => g_sysdate + i);

  END LOOP;

END load_snapshots;

/* Deletes rows from calendar tables */
PROCEDURE truncate_calendar_tables IS

  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(30);

BEGIN

/* Truncate tables */
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    EXECUTE IMMEDIATE
     ('TRUNCATE TABLE ' || l_schema || '.HRI_CAL_SNPSHT_WRKFC');
    EXECUTE IMMEDIATE
     ('TRUNCATE TABLE ' || l_schema || '.HRI_CAL_SNPSHT_WCNT_CHG');
  END IF;

END truncate_calendar_tables;

/* Full refresh calendar tables */
PROCEDURE load_calendars IS

BEGIN

/* Get values of relevant profile options */
  get_profile_values;

/* Empty tables */
  truncate_calendar_tables;

/* If snapshots are enabled then load the calendar tables */
  IF g_collect_snapshots THEN

  /* Initialize globals storing numbers of rows inserted */
    g_wcnt_chg_row_count := 0;
    g_wrkfc_row_count := 0;

  /* Load up period metadata */
    set_metadata;

  /* Main processing - populates a list of dates to snapshot and loads   */
  /* the periods to snapshot into the PL/SQL table ready for bulk insert */
    load_snapshots;

  /* Move the data from PL/SQL tables into the database tables */
    bulk_insert_wrkfc;
    bulk_insert_wcnt_chg;

  /* Commit */
    commit;

  END IF;

END load_calendars;

/* Full refresh calendar tables - main entry point */
PROCEDURE load_calendars(errbuf   OUT NOCOPY VARCHAR2,
                         retcode  OUT NOCOPY VARCHAR2) IS

BEGIN

  load_calendars;

END load_calendars;

/* Incrementally update calendar tables */
PROCEDURE update_calendars IS

BEGIN

  null;

END update_calendars;

/* Incrementally update calendar tables - main entry point */
PROCEDURE update_calendars(errbuf   OUT NOCOPY VARCHAR2,
                           retcode  OUT NOCOPY VARCHAR2) IS

BEGIN

  update_calendars;

END update_calendars;

END hri_opl_dbi_calendar;

/
