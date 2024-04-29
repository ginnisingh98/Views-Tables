--------------------------------------------------------
--  DDL for Package Body HRI_EDW_DIM_SERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_EDW_DIM_SERVICE" AS
/* $Header: hriedlwb.pkb 120.0 2005/05/29 07:08:39 appldev noship $ */

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
  ,band_max_total_years
  ,band_max_total_months
  ,band_max_total_weeks
  ,band_max_total_days
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
  l_last_update_date    DATE := SYSDATE;
  l_last_updated_by     NUMBER := 0;
  l_last_update_login   NUMBER := 0;
  l_created_by          NUMBER := 0;
  l_creation_date       DATE := SYSDATE;

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

END hri_edw_dim_service;

/
