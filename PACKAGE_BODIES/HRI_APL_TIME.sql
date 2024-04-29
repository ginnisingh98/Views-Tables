--------------------------------------------------------
--  DDL for Package Body HRI_APL_TIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_APL_TIME" AS
/* $Header: hriatime.pkb 115.3 2002/11/25 10:39:03 jtitmas noship $ */

/******************************************************************************/
/* TIME BANDS SECTION                                                         */
/*                                                                            */
/* The time bands table collects together various different sets of time      */
/* bands. Each set of time bands has a unique identifier "TYPE". For any      */
/* given TYPE there must exist a complete set of time bands in the table. A   */
/* complete set of bands covers the entire range of possible values (0 and    */
/* above). Each band contains values including the minimum but excluding the  */
/* maximum. A band with a NULL maximum value contains all values from the     */
/* minimum up.                                                                */
/******************************************************************************/

/******************************************************************************/
/* Converts a band composite of days, weeks, months and years to the band min */
/* using the grain passed in of days, months or years                         */
/******************************************************************************/
FUNCTION convert_band_to_min(p_grain    IN VARCHAR2,
                             p_years    IN NUMBER,
                             p_months   IN NUMBER,
                             p_weeks    IN NUMBER,
                             p_days     IN NUMBER)
                RETURN NUMBER IS

/* Defines the number of days in a months */
  l_days_in_month          NUMBER := 30.4375;

BEGIN

  IF (p_grain = 'DAY') THEN
    RETURN ROUND( p_days + (7 * p_weeks) +
                 (l_days_in_month * (p_months + (12 * p_years))), 2 );
  ELSIF (p_grain = 'MONTH') THEN
    RETURN ROUND( ((p_days + (7 * p_weeks)) / l_days_in_month) +
                    p_months + (12 * p_years), 2 );
  ELSIF (p_grain = 'YEAR') THEN
    RETURN ROUND( ((p_days + (7 * p_weeks)) / (12 * l_days_in_month)) +
                   (p_months / 12) + p_years, 2 );
  END IF;

  RETURN to_number(null);

END convert_band_to_min;


/******************************************************************************/
/* Inserts a band given its minimum value. This function assumes the band     */
/* type already has a complete set of bands. If there is already a band with  */
/* the given minimum value then no action is taken. Otherwise, the existing   */
/* band which the given minumum value falls into is split into two bands.     */
/******************************************************************************/
PROCEDURE insert_time_band(p_type           IN VARCHAR2,
                           p_band_min_day_comp   IN NUMBER,
                           p_band_min_week_comp  IN NUMBER,
                           p_band_min_month_comp IN NUMBER,
                           p_band_min_year_comp  IN NUMBER) IS

  l_band_min_value      NUMBER;  -- minimum value of band to insert
  l_band_to_split       hri_time_bands%rowtype;  -- band to split

  l_max_value           NUMBER;
  l_max_day             NUMBER;
  l_max_week            NUMBER;
  l_max_month           NUMBER;
  l_max_year            NUMBER;
  l_grain               VARCHAR2(10);

/* Picks out the band to split (the band which the given minimum value */
/* falls into) */
  CURSOR split_cur(v_band_min_value   IN NUMBER) IS
  SELECT *
  FROM hri_time_bands
  WHERE type = p_type
  AND v_band_min_value > band_min_value
  AND (v_band_min_value < band_max_value
    OR band_max_value IS NULL);

BEGIN

/* This section defines the grain - either year, month or day */
  IF (p_type = 'AGE') THEN
    l_grain := 'YEAR';
  ELSIF (p_type = 'LOW') THEN
    l_grain := 'MONTH';
  ELSIF (p_type = 'VACANCY' OR
         p_type = 'APL_STAGE') THEN
    l_grain := 'DAY';
  END IF;

/* Find given minimum value */
  l_band_min_value := convert_band_to_min(p_grain => l_grain,
                                          p_years => p_band_min_year_comp,
                                          p_months => p_band_min_month_comp,
                                          p_weeks => p_band_min_week_comp,
                                          p_days => p_band_min_day_comp);

/* Find the existing band which this minimum value falls into */
  OPEN split_cur(l_band_min_value);
  FETCH split_cur INTO l_band_to_split;
/* If the minimum value doesn't fall into an existing band do nothing */
  IF (split_cur%NOTFOUND OR split_cur%NOTFOUND IS NULL) THEN
    CLOSE split_cur;
/* Otherwise split the existing band */
  ELSE
  /* Increment the band sequence for higher bands */
    UPDATE hri_time_bands
    SET band_sequence = band_sequence + 1
    WHERE band_sequence > l_band_to_split.band_sequence
    AND type = p_type;

  /* Insert a new band with the new minimum and the existing maximum */
    INSERT INTO hri_time_bands
      (type
      ,band_min_value
      ,band_max_value
      ,band_sequence
      ,band_min_day_comp
      ,band_min_week_comp
      ,band_min_month_comp
      ,band_min_year_comp
      ,band_max_day_comp
      ,band_max_week_comp
      ,band_max_month_comp
      ,band_max_year_comp)
      VALUES
        (p_type
        ,l_band_min_value
        ,l_band_to_split.band_max_value
        ,l_band_to_split.band_sequence + 1
        ,NVL(p_band_min_day_comp,0)
        ,NVL(p_band_min_week_comp,0)
        ,NVL(p_band_min_month_comp,0)
        ,NVL(p_band_min_year_comp,0)
        ,l_band_to_split.band_max_day_comp
        ,l_band_to_split.band_max_week_comp
        ,l_band_to_split.band_max_month_comp
        ,l_band_to_split.band_max_year_comp);

  /* Update the band with the existing minimum to end at the new minimum */
    UPDATE hri_time_bands
    SET band_max_value      = l_band_min_value,
        band_max_year_comp  = p_band_min_year_comp,
        band_max_month_comp = p_band_min_month_comp,
        band_max_week_comp  = p_band_min_week_comp,
        band_max_day_comp   = p_band_min_day_comp
    WHERE band_min_value = l_band_to_split.band_min_value
    AND type = p_type;

  END IF;

END insert_time_band;


/******************************************************************************/
/* Removes a band given its minimum value. This function assumes the band     */
/* type already has a complete set of bands. If the band to delete is found   */
/* then it is removed and the previous band extended to cover the same values */
/* otherwise no action is taken.                                              */
/******************************************************************************/
PROCEDURE remove_time_band(p_type           IN VARCHAR2,
                           p_band_min_day_comp   IN NUMBER,
                           p_band_min_week_comp  IN NUMBER,
                           p_band_min_month_comp IN NUMBER,
                           p_band_min_year_comp  IN NUMBER) IS

  l_band_min_value      NUMBER;  -- minimum value of band to remove
  l_band_to_delete      hri_time_bands%rowtype;    -- band to remove
  l_band_to_grow        hri_time_bands%rowtype;    -- band to remove

/* Selects information from band to be deleted */
  CURSOR delete_cur IS
  SELECT *
  FROM hri_time_bands
  WHERE type = p_type
  AND band_min_day_comp   = p_band_min_day_comp
  AND band_min_week_comp  = p_band_min_week_comp
  AND band_min_month_comp = p_band_min_month_comp
  AND band_min_year_comp  = p_band_min_year_comp;

/* Selects information from band to be extended */
  CURSOR grow_cur IS
  SELECT *
  FROM hri_time_bands
  WHERE type = p_type
  AND band_max_day_comp   = p_band_min_day_comp
  AND band_max_week_comp  = p_band_min_week_comp
  AND band_max_month_comp = p_band_min_month_comp
  AND band_max_year_comp  = p_band_min_year_comp;

BEGIN

/* The band starting at 0 cannot be deleted as it is the first one */
  IF (NVL(p_band_min_day_comp,  0) +
      NVL(p_band_min_week_comp, 0) +
      NVL(p_band_min_month_comp,0) +
      NVL(p_band_min_year_comp, 0) > 0) THEN

  /* Get the information about the band to be deleted */
    OPEN delete_cur;
    FETCH delete_cur INTO l_band_to_delete;
    CLOSE delete_cur;

  /* Get the information about the band immediately preceeding it */
    OPEN grow_cur;
    FETCH grow_cur INTO l_band_to_grow;
    CLOSE grow_cur;

  /* Check the bands are consecutive */
    IF (l_band_to_delete.band_min_value = l_band_to_grow.band_max_value) THEN

    /* Delete the given band */
      DELETE FROM hri_time_bands
      WHERE band_min_value = l_band_to_delete.band_min_value
      AND type = p_type;

    /* Decrement the sequence number of higher bands */
      UPDATE hri_time_bands
      SET band_sequence = band_sequence - 1
      WHERE band_sequence > l_band_to_delete.band_sequence
      AND type = p_type;

    /* Set the maximum value of the band preceeding the deleted band */
    /* to the maximum value of the deleted band */
      UPDATE hri_time_bands
         SET band_max_value      = l_band_to_delete.band_max_value,
             band_max_year_comp  = l_band_to_delete.band_max_year_comp,
             band_max_month_comp = l_band_to_delete.band_max_month_comp,
             band_max_week_comp  = l_band_to_delete.band_max_week_comp,
             band_max_day_comp   = l_band_to_delete.band_max_day_comp
       WHERE band_max_value = l_band_to_grow.band_max_value
       AND type = p_type;

    END IF;

  END IF;

EXCEPTION WHEN OTHERS THEN

  RETURN;

END remove_time_band;


/******************************************************************************/
/* Overloaded version of remove time band to remove all bands for a type      */
/******************************************************************************/
PROCEDURE remove_time_band(p_type           IN VARCHAR2) IS

  CURSOR remove_all_rows IS
  SELECT
   band_min_day_comp
  ,band_min_week_comp
  ,band_min_month_comp
  ,band_min_year_comp
  FROM hri_time_bands
  WHERE type = p_type
  AND band_min_value > 0;

BEGIN

  FOR row_to_remove IN remove_all_rows LOOP

    remove_time_band
       (p_type => p_type,
        p_band_min_day_comp => row_to_remove.band_min_day_comp,
        p_band_min_week_comp => row_to_remove.band_min_week_comp,
        p_band_min_month_comp => row_to_remove.band_min_month_comp,
        p_band_min_year_comp => row_to_remove.band_min_year_comp);

  END LOOP;

END remove_time_band;

/******************************************************************************/
/* Inserts a row into the table. If the row already exists then the row is    */
/* updated. Called from UPLOAD part of FNDLOAD.                               */
/******************************************************************************/
PROCEDURE load_time_band_row(p_type                 IN VARCHAR2,
                             p_band_min             IN NUMBER,
                             p_band_max             IN NUMBER,
                             p_band_sequence        IN NUMBER,
                             p_band_min_day_comp    IN NUMBER,
                             p_band_min_week_comp   IN NUMBER,
                             p_band_min_month_comp  IN NUMBER,
                             p_band_min_year_comp   IN NUMBER,
                             p_band_max_day_comp    IN NUMBER,
                             p_band_max_week_comp   IN NUMBER,
                             p_band_max_month_comp  IN NUMBER,
                             p_band_max_year_comp   IN NUMBER,
                             p_owner                IN VARCHAR2)
IS

  l_rows_customized     NUMBER;  -- How many rows have been customized

/* Standard WHO columns */
  l_last_update_date    DATE := SYSDATE;
  l_last_updated_by     NUMBER := 0;
  l_last_update_login   NUMBER := 0;
  l_created_by          NUMBER := 0;
  l_creation_date       DATE := SYSDATE;

/* Selects the number of bands for the given type that have been customized */
  CURSOR customized_bands_csr IS
  SELECT count(*)
  FROM hri_time_bands
  WHERE type = p_type
  AND fnd_load_util.owner_name(last_updated_by) <> 'ORACLE';

BEGIN

  l_created_by := fnd_load_util.owner_id(p_name => p_owner);
  l_last_updated_by := fnd_load_util.owner_id(p_name => p_owner);

/* Find whether the given type has been customized */
  OPEN customized_bands_csr;
  FETCH customized_bands_csr INTO l_rows_customized;
  CLOSE customized_bands_csr;

/* If the banding type has not been customized, process the seeded type */
  IF (l_rows_customized = 0) THEN

  /* Delete all overlapping bands */
    DELETE FROM hri_time_bands
    WHERE type = p_type
    AND ((p_band_min <= band_min_value AND
          (band_min_value < p_band_max OR p_band_max IS NULL))
      OR (band_min_value <= p_band_min AND
          (p_band_min < band_max_value OR band_max_value IS NULL))
      OR band_sequence = p_band_sequence);

  /* Insert seeded band */
    INSERT INTO hri_time_bands
      ( type
      , band_min_value
      , band_max_value
      , band_sequence
      , band_min_day_comp
      , band_min_week_comp
      , band_min_month_comp
      , band_min_year_comp
      , band_max_day_comp
      , band_max_week_comp
      , band_max_month_comp
      , band_max_year_comp
      , last_update_date
      , last_update_login
      , last_updated_by
      , created_by
      , creation_date )
      VALUES
        ( p_type
        , p_band_min
        , p_band_max
        , p_band_sequence
        , p_band_min_day_comp
        , p_band_min_week_comp
        , p_band_min_month_comp
        , p_band_min_year_comp
        , p_band_max_day_comp
        , p_band_max_week_comp
        , p_band_max_month_comp
        , p_band_max_year_comp
        , l_last_update_date
        , l_last_update_login
        , l_last_updated_by
        , l_created_by
        , l_creation_date );

  END IF;

EXCEPTION
  WHEN OTHERS THEN

  CLOSE customized_bands_csr;
  RAISE;

END load_time_band_row;

END hri_apl_time;

/
