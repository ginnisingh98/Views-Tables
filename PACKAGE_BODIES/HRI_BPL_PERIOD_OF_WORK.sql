--------------------------------------------------------
--  DDL for Package Body HRI_BPL_PERIOD_OF_WORK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_PERIOD_OF_WORK" AS
/* $Header: hriblow.pkb 120.3 2005/07/05 01:40:40 anmajumd noship $ */

TYPE g_num_array_t IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_service_months        g_num_array_t;   -- Holds sequence of band min months
g_service_days          g_num_array_t;   -- Holds sequence of band min days

g_service_band_count    NUMBER  := 0;  -- Keeps a count of the number of bands
g_band_number           NUMBER;  -- Primary key for temporary band table
g_period_type           VARCHAR2(30);  -- Fast formula output - DAYS or MONTHS
g_service_ff_update     DATE;   -- Last update date of Fast Formula

g_low_person_id         NUMBER := -1;
g_low_effective_date    DATE;
g_low_months_service    NUMBER;
g_low_latest_hire_date  DATE;

--
-- For storing the row fetched from BIS_BUCKET that stores POW information
--
g_pow_bucket_emp            BIS_BUCKET_CUSTOMIZATIONS%rowtype;
g_pow_bucket_cwk            BIS_BUCKET_CUSTOMIZATIONS%rowtype;
--
-- Number table type with varchar2 indexing.
--
TYPE g_index_by_varchar2_num_tab IS TABLE OF NUMBER INDEX BY VARCHAR2(30);
g_pow_band_cache  g_index_by_varchar2_num_tab;

/******************************************************************************/
/*                PRIVATE Procedures and Functions                            */
/******************************************************************************/

/******************************************************************************/
/*                PUBLIC Procedures and Functions                             */
/******************************************************************************/

/******************************************************************************/
/* Takes values in years, months, weeks and days, and the constant for how    */
/* many days in a months, and returns the equivalent value in months          */
/******************************************************************************/
FUNCTION normalize_band( p_band_years        NUMBER,
                         p_band_months       NUMBER,
                         p_band_weeks        NUMBER,
                         p_band_days         NUMBER,
                         p_days_to_month     NUMBER)
         RETURN NUMBER IS

  l_return_value      NUMBER;  -- Holds value to return

BEGIN

  l_return_value := (((p_band_weeks * 7) + p_band_days) / p_days_to_month)
                   + ((p_band_years * 12) + p_band_months);

  RETURN l_return_value;

END normalize_band;


/******************************************************************************/
/* Retrieves constant converting days to months                               */
/******************************************************************************/
FUNCTION get_days_to_month RETURN NUMBER IS

  l_days_to_month     NUMBER;  -- Holds constant

  CURSOR ratio_cur IS
  SELECT days_to_month
    FROM hri_service_bands
   WHERE days_to_month IS NOT NULL;

BEGIN

  OPEN ratio_cur;
  FETCH ratio_cur INTO l_days_to_month;
  CLOSE ratio_cur;

  RETURN l_days_to_month;

END get_days_to_month;

/******************************************************************************/
/* Retrieves constant converting days to months                               */
/******************************************************************************/
PROCEDURE set_days_to_months( p_days_to_month  NUMBER)
IS

BEGIN

  UPDATE hri_service_bands
     SET days_to_month = p_days_to_month
   WHERE days_to_month IS NOT NULL;

END set_days_to_months;

/******************************************************************************/
/* This procedure inserts a service band into the hri_service_bands table.    */
/* The PK is the minimum year, month, week and day for the service band.      */
/* There will always be a row with all of these zero since this cannot be     */
/* removed by the remove_service_band API) and there will always be (possibly */
/* the same row) a row with null maximum year, month, week and day values     */
/* since inserting a row always works by picking the band that the new        */
/* service length falls into, and splitting it into two                       */
/*                                                                            */
/* If a service length is given that already exists, nothing will happen.     */
/*                                                                            */
/* E.g. if the following bands exist (Years, Months, Weeks, Days):            */
/*                   (0,0,0,0) - (0,3,0,0)                                    */
/*                   (0,3,0,0) - (0,6,0,0)                                    */
/*                   (0,6,0,0) - (0,9,0,0)                                    */
/*                   (0,9,0,0) - (,,,)                                        */
/*                                                                            */
/*  Then insert_service_band(1,0,0,0) would give the new set of bands as:     */
/*                   (0,0,0,0) - (0,3,0,0)                                    */
/*                   (0,3,0,0) - (0,6,0,0)                                    */
/*                   (0,6,0,0) - (0,9,0,0)                                    */
/*                   (0,9,0,0) - (1,0,0,0)                                    */
/*                   (1,0,0,0) - (,,,)                                        */
/******************************************************************************/
PROCEDURE insert_service_band( p_service_min_years    NUMBER,
                               p_service_min_months   NUMBER,
                               p_service_min_weeks    NUMBER,
                               p_service_min_days     NUMBER)
IS

  l_total_min_service_months    NUMBER;    -- Holds the service length in months

  l_band_to_split_min          NUMBER;  -- Service (in months) of band to split
  l_band_to_split_max_years    NUMBER;  -- Max years of band to split
  l_band_to_split_max_months   NUMBER;  -- Max months of band to split
  l_band_to_split_max_weeks    NUMBER;  -- Max weeks of band to split
  l_band_to_split_max_days     NUMBER;  -- Max days of band to split

  l_days_to_month            NUMBER;  -- Constant converting days to months

/* Get details of band to split */
  CURSOR split_cur
  (v_total_min_service_months  NUMBER,
   v_days_to_month             NUMBER) IS
  SELECT normalize_band( band_min_total_years
                       , band_min_total_months
                       , band_min_total_weeks
                       , band_min_total_days
                       , v_days_to_month)     band_months
       , band_max_total_years
       , band_max_total_months
       , band_max_total_weeks
       , band_max_total_days
    FROM hri_service_bands
   WHERE (normalize_band( band_max_total_years
                       , band_max_total_months
                       , band_max_total_weeks
                       , band_max_total_days
                       , v_days_to_month)        > v_total_min_service_months
    OR ( band_max_total_years IS NULL AND band_max_total_months IS NULL
      AND band_max_total_weeks IS NULL AND band_max_total_days IS NULL))
  AND   normalize_band( band_min_total_years
                      , band_min_total_months
                      , band_min_total_weeks
                      , band_min_total_days
                      , v_days_to_month)        < v_total_min_service_months;

BEGIN

/* Retrive constant */
  l_days_to_month := get_days_to_month;

/* Convert input to months */
  l_total_min_service_months := normalize_band( p_service_min_years
                                              , p_service_min_months
                                              , p_service_min_weeks
                                              , p_service_min_days
                                              , l_days_to_month );

/* Find which service band contains input service length */
  OPEN split_cur(l_total_min_service_months, l_days_to_month);
  FETCH split_cur INTO l_band_to_split_min,
                       l_band_to_split_max_years,
                       l_band_to_split_max_months,
                       l_band_to_split_max_weeks,
                       l_band_to_split_max_days;
  IF (split_cur%NOTFOUND OR split_cur%NOTFOUND IS NULL) THEN

  /* Service Band already exists */
    CLOSE split_cur;
  ELSE
    /* Create new service band using maximum of band to split */
    INSERT INTO hri_service_bands
      (band_min_total_years,
       band_min_total_months,
       band_min_total_weeks,
       band_min_total_days,
       band_max_total_years,
       band_max_total_months,
       band_max_total_weeks,
       band_max_total_days)
      VALUES
        ( p_service_min_years,
          p_service_min_months,
          p_service_min_weeks,
          p_service_min_days,
          l_band_to_split_max_years,
          l_band_to_split_max_months,
          l_band_to_split_max_weeks,
          l_band_to_split_max_days );

/* Update the maximum of band to split with the input */
    UPDATE hri_service_bands
    SET band_max_total_years  = p_service_min_years,
        band_max_total_months = p_service_min_months,
        band_max_total_weeks  = p_service_min_weeks,
        band_max_total_days   = p_service_min_days
    WHERE normalize_band( band_min_total_years,
                          band_min_total_months,
                          band_min_total_weeks,
                          band_min_total_days,
                          l_days_to_month )     = l_band_to_split_min;
  END IF;

END insert_service_band;


/******************************************************************************/
/* Removes a service band, if it exists. The maximum of the band preceding    */
/* the removed band is updated with the maximim of the removed band.          */
/******************************************************************************/
PROCEDURE remove_service_band( p_service_min_years   NUMBER,
                               p_service_min_months  NUMBER,
                               p_service_min_weeks   NUMBER,
                               p_service_min_days    NUMBER)
IS

  l_total_min_service_months    NUMBER;     -- Service length of band to remove

  l_band_to_grow_max_years     NUMBER; -- Max years of band to remove
  l_band_to_grow_max_months    NUMBER; -- Max months of band to remove
  l_band_to_grow_max_weeks     NUMBER; -- Max weeks of band to remove
  l_band_to_grow_max_days      NUMBER; -- Max days of band to remove

/* Get maximum service length of band to remove */
  CURSOR grow_cur IS
  SELECT
   band_max_total_years
  ,band_max_total_months
  ,band_max_total_weeks
  ,band_max_total_days
  FROM hri_service_bands
  WHERE band_min_total_years  = p_service_min_years
  AND   band_min_total_months = p_service_min_months
  AND   band_min_total_weeks  = p_service_min_weeks
  AND   band_min_total_days   = p_service_min_days;

BEGIN

/* Populate variables with maximum service length of band to remove */
  OPEN grow_cur;
  FETCH grow_cur INTO l_band_to_grow_max_years,
                      l_band_to_grow_max_months,
                      l_band_to_grow_max_weeks,
                      l_band_to_grow_max_days;
  IF (grow_cur%NOTFOUND OR grow_cur%NOTFOUND IS NULL) THEN
  /* Age Band doesn't exist */
    CLOSE grow_cur;
  ELSE
  /* Remove the band */
    DELETE FROM hri_service_bands
    WHERE band_min_total_years  = p_service_min_years
    AND   band_min_total_months = p_service_min_months
    AND   band_min_total_weeks  = p_service_min_weeks
    AND   band_min_total_days   = p_service_min_days;

  /* Update the previous band, which can be identified by its maximum */
  /* being the minimum of the band removed */
    UPDATE hri_service_bands
    SET band_max_total_years  = l_band_to_grow_max_years,
        band_max_total_months = l_band_to_grow_max_months,
        band_max_total_weeks  = l_band_to_grow_max_weeks,
        band_max_total_days   = l_band_to_grow_max_days
    WHERE band_max_total_years  = p_service_min_years
    AND   band_max_total_months = p_service_min_months
    AND   band_max_total_weeks  = p_service_min_weeks
    AND   band_max_total_days   = p_service_min_days;
  END IF;

END remove_service_band;

/******************************************************************************/
/* Inserts row into table, or updates it if the row already exists. Called    */
/* from the UPLOAD section of FNDLOAD.                                        */
/******************************************************************************/
PROCEDURE load_row( p_band_min_yrs       IN NUMBER,
                    p_band_min_mths      IN NUMBER,
                    p_band_min_wks       IN NUMBER,
                    p_band_min_days      IN NUMBER,
                    p_band_max_yrs       IN NUMBER,
                    p_band_max_mths      IN NUMBER,
                    p_band_max_wks       IN NUMBER,
                    p_band_max_days      IN NUMBER,
                    p_days_to_month      IN NUMBER,
                    p_owner              IN VARCHAR2 )
IS

  l_row_exists        NUMBER;

/* Standard WHO columns */
  l_last_update_date    DATE;
  l_last_updated_by     NUMBER;
  l_last_update_login   NUMBER;
  l_created_by          NUMBER;
  l_creation_date       DATE;

  CURSOR row_exists_cur IS
  SELECT 1
  FROM hri_service_bands
  WHERE (band_min_total_years  = p_band_min_yrs
    AND  band_min_total_months = p_band_min_mths
    AND  band_min_total_weeks  = p_band_min_wks
    AND  band_min_total_days   = p_band_min_days)
  OR   (band_min_total_years  IS NULL AND p_band_min_yrs  IS NULL
    AND band_min_total_months IS NULL AND p_band_min_mths IS NULL
    AND band_min_total_weeks  IS NULL AND p_band_min_wks  IS NULL
    AND band_min_total_days   IS NULL AND p_band_min_days IS NULL);

BEGIN
  --
  l_last_update_date    := SYSDATE;
  l_last_updated_by     := 0;
  l_last_update_login   := 0;
  l_created_by          := 0;
  l_creation_date       := SYSDATE;
  --
  OPEN row_exists_cur;
  FETCH row_exists_cur INTO l_row_exists;
    IF (row_exists_cur%NOTFOUND OR row_exists_cur%NOTFOUND IS NULL) THEN
    CLOSE row_exists_cur;
    INSERT INTO  hri_service_bands
      ( band_min_total_years
      , band_min_total_months
      , band_min_total_weeks
      , band_min_total_days
      , band_max_total_years
      , band_max_total_months
      , band_max_total_weeks
      , band_max_total_days
      , days_to_month
      , last_update_date
      , last_update_login
      , last_updated_by
      , created_by
      , creation_date )
      VALUES
        ( p_band_min_yrs
        , p_band_min_mths
        , p_band_min_wks
        , p_band_min_days
        , p_band_max_yrs
        , p_band_max_mths
        , p_band_max_wks
        , p_band_max_days
        , p_days_to_month
        , l_last_update_date
        , l_last_update_login
        , l_last_updated_by
        , l_created_by
        , l_creation_date );
  ELSE
    CLOSE row_exists_cur;
    UPDATE hri_service_bands
    SET
     band_max_total_years  = p_band_max_yrs
    ,band_max_total_months = p_band_max_mths
    ,band_max_total_weeks  = p_band_max_wks
    ,band_max_total_days   = p_band_max_days
    ,days_to_month         = p_days_to_month
    ,last_update_date  = l_last_update_date
    ,last_update_login = l_last_update_login
    ,last_updated_by   = l_last_updated_by
    WHERE (band_min_total_years  = p_band_min_yrs
      AND  band_min_total_months = p_band_min_mths
      AND  band_min_total_weeks  = p_band_min_wks
      AND  band_min_total_days   = p_band_min_days)
    OR   (band_min_total_years  IS NULL AND p_band_min_yrs  IS NULL
      AND band_min_total_months IS NULL AND p_band_min_mths IS NULL
      AND band_min_total_weeks  IS NULL AND p_band_min_wks  IS NULL
      AND band_min_total_days   IS NULL AND p_band_min_days IS NULL);
  END IF;

END load_row;

PROCEDURE cache_period_of_work(p_person_id       IN NUMBER,
                               p_effective_date  IN DATE,
                               p_assignment_type IN VARCHAR2) IS

  CURSOR get_emp_pow_csr IS
  SELECT
   SUM(months_between(least(nvl(actual_termination_date + 1,
                                p_effective_date + 1),
                            p_effective_date + 1),
                      date_start)) total_months
  ,MAX(date_start)                 latest_hire_date
  FROM  per_periods_of_service
  WHERE person_id = p_person_id
  AND date_start <= p_effective_date;

BEGIN

  IF (p_person_id <> g_low_person_id OR
      p_effective_date <> g_low_effective_date) THEN

    IF (p_assignment_type = 'E') THEN

      OPEN get_emp_pow_csr;
      FETCH get_emp_pow_csr INTO g_low_months_service, g_low_latest_hire_date;
      CLOSE get_emp_pow_csr;

      g_low_person_id := p_person_id;
      g_low_effective_date := p_effective_date;

    END IF;

  END IF;

END cache_period_of_work;

-- returns period of time, in years, of the persons period of service
-- taking into account breaks in service for rehires
FUNCTION get_period_of_work_years(p_person_id       IN NUMBER,
                                  p_effective_date  IN DATE,
                                  p_assignment_type IN VARCHAR2)
               RETURN NUMBER IS

BEGIN

  cache_period_of_work(p_person_id => p_person_id,
                       p_effective_date => p_effective_date,
                       p_assignment_type => p_assignment_type);

  RETURN g_low_months_service/12;

END get_period_of_work_years;

-- returns period of time, in months, of the persons period of service
-- taking into account breaks in service for rehires
FUNCTION get_period_of_work_months(p_person_id       IN NUMBER,
                                   p_effective_date  IN DATE,
                                   p_assignment_type IN VARCHAR2)
               RETURN NUMBER IS

BEGIN

  cache_period_of_work(p_person_id => p_person_id,
                       p_effective_date => p_effective_date,
                       p_assignment_type => p_assignment_type);

  RETURN g_low_months_service;

END get_period_of_work_months;

-- returns latest hire date
FUNCTION get_latest_hire_date(p_person_id       IN NUMBER,
                              p_effective_date  IN DATE,
                              p_assignment_type IN VARCHAR2)
               RETURN DATE IS

BEGIN

  cache_period_of_work(p_person_id => p_person_id,
                       p_effective_date => p_effective_date,
                       p_assignment_type => p_assignment_type);

  RETURN g_low_latest_hire_date;

END get_latest_hire_date;
--
-- -----------------------------------------------------------------------------
-- GET_POW_BAND_EMP
-- This function is invoked by the get_pow_band_high_val
-- It reads the definition of the employee period of work bucket returns the high
-- value for the bucket
-- -----------------------------------------------------------------------------
--
FUNCTION get_pow_band_emp(p_band_number       NUMBER)
RETURN NUMBER
IS
  --
  l_band                               NUMBER;
  --
  -- Cursor to fetch the period of work band range information
  -- 4293064 Bucket definition should be picked from the bucket customization table
  --
  CURSOR c_bucket (c_bucket VARCHAR2) IS
  SELECT bb.*
  FROM   bis_bucket_customizations bb,
         bis_bucket b
  WHERE  b.short_name = c_bucket
  AND    b.bucket_id  = bb.bucket_id;
  --
BEGIN
  --
  -- Open the cursor only if the global cache record is not populated
  --
  IF g_pow_bucket_emp.bucket_id is null THEN
    --
    OPEN   c_bucket('HRI_DBI_LOW_BAND_CURRENT');
    FETCH  c_bucket INTO g_pow_bucket_emp;
    CLOSE  c_bucket;
    --
  END IF;
  --
  -- Identify the band within which the normalized rating falls and return the value
  --
  IF p_band_number = 1 THEN
    --
    l_band := g_pow_bucket_emp.range1_high;
    --
  ELSIF p_band_number = 2 THEN
    --
    l_band := g_pow_bucket_emp.range2_high;
    --
  ELSIF p_band_number = 3 THEN
    --
    l_band := g_pow_bucket_emp.range3_high;
    --
  ELSIF p_band_number = 4 THEN
    --
    l_band := g_pow_bucket_emp.range4_high;
    --
  ELSIF p_band_number = 5 THEN
    --
    -- Since this is the highest band, the high value for this band should always be null
    --
    l_band := null;
    --
  ELSE
    --
    l_band := null;
    --
  END IF;
  --
  RETURN l_band;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    IF c_bucket%ISOPEN THEN
      --
      CLOSE c_bucket;
    --
    END IF;
    --
    RAISE;
    --
END get_pow_band_emp;
--
-- -----------------------------------------------------------------------------
-- GET_POW_BAND_EMP
-- This function is invoked by the get_pow_band_high_val
-- It reads the definition of the employee period of work bucket returns the high
-- value for the bucket
-- -----------------------------------------------------------------------------
--
FUNCTION get_pow_band_cwk(p_band_number       NUMBER)
RETURN NUMBER
IS
  --
  l_band                               NUMBER;
  --
  CURSOR c_bucket (c_bucket VARCHAR2) IS
  SELECT bb.*
  FROM   bis_bucket_customizations bb,
         bis_bucket b
  WHERE  b.short_name = c_bucket
  AND    b.bucket_id  = bb.bucket_id;
  --
BEGIN
  --
  -- Open the cursor only if the global cache record is not populated
  --
  IF g_pow_bucket_cwk.bucket_id is null THEN
    --
    OPEN   c_bucket('HRI_DBI_POW_PLCMNT_BAND');
    FETCH  c_bucket INTO g_pow_bucket_cwk;
    CLOSE  c_bucket;
    --
  END IF;
  --
  -- Identify the band within which the normalized rating falls and return the value
  --
  IF p_band_number = 1 THEN
    --
    l_band := g_pow_bucket_cwk.range1_high;
    --
  ELSIF p_band_number = 2 THEN
    --
    l_band := g_pow_bucket_cwk.range2_high;
    --
  ELSIF p_band_number = 3 THEN
    --
    l_band := g_pow_bucket_cwk.range3_high;
    --
  ELSIF p_band_number = 4 THEN
    --
    l_band := g_pow_bucket_cwk.range4_high;
    --
  ELSIF p_band_number = 5 THEN
    --
    -- Since this is the highest band, the high value for this band should always be null
    --
    l_band := null;
    --
  ELSE
    --
    l_band := null;
    --
  END IF;
  --
  RETURN l_band;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    IF c_bucket%ISOPEN THEN
      --
      CLOSE c_bucket;
    --
    END IF;
    --
    RAISE;
    --
END get_pow_band_cwk;
--
-- -----------------------------------------------------------------------------
-- GET_POW_BAND_HIGH_VAL
-- This procedure is invoked by the asg events fact collection program
-- Based on the assignment type it finds out the high value for the corresponding
-- bucket
-- -----------------------------------------------------------------------------
--
FUNCTION get_pow_band_high_val(p_band_number       NUMBER,
                               p_assignment_type   VARCHAR2)
RETURN NUMBER
IS
  --
  l_band_high_val         NUMBER;
  --
BEGIN
  --
  IF p_assignment_type = 'E' THEN
    --
    l_band_high_val := get_pow_band_emp(p_band_number);
    --
  ELSE
    --
    l_band_high_val := get_pow_band_cwk(p_band_number);
    --
  END IF;
  --
  RETURN l_band_high_val;
  --
END get_pow_band_high_val;
--
-- -----------------------------------------------------------------------------
-- GET_POW_BAND_SK_FK
-- The function returns the pow band surrogate key for use in assignmene events
-- The profram first searched for the details in the cache and when it does not
-- find it queries the table to determine the value.
-- -----------------------------------------------------------------------------
--
FUNCTION get_pow_band_sk_fk(p_band_number       NUMBER,
                            p_assignment_type   VARCHAR2)
RETURN NUMBER IS
  --
  cursor c_pow_band IS
  SELECT pow_band_sk_pk
  FROM   hri_cs_pow_band_ct powb
  WHERE  powb.wkth_wktyp_sk_fk = decode(p_assignment_type,'E','EMP','CWK')
  AND    powb.band_sequence = p_band_number;
  --
  l_pow_band_sk_fk   NUMBER;
  --
BEGIN
  --
  l_pow_band_sk_fk := g_pow_band_cache(p_assignment_type||'###'||p_band_number);
  --
  RETURN l_pow_band_sk_fk;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    OPEN  c_pow_band;
    FETCH c_pow_band into l_pow_band_sk_fk;
    CLOSE c_pow_band;
    --
    g_pow_band_cache(p_assignment_type||'###'||p_band_number) := nvl(l_pow_band_sk_fk,-5);
    --
    RETURN l_pow_band_sk_fk;
    --
END get_pow_band_sk_fk;
--
BEGIN
  --
  g_low_effective_date    := hr_general.start_of_time;
  --
END hri_bpl_period_of_work;

/
