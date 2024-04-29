--------------------------------------------------------
--  DDL for Package Body HRI_BPL_AGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_AGE" AS
/* $Header: hribage.pkb 115.6 2002/05/10 07:54:59 pkm ship      $ */

/* Set up global type - effectively creates an array */
TYPE g_num_array_t IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_ages       g_num_array_t;   -- Holds sequence of band min ages

/* Values for global reference */
g_age_band_count    NUMBER  := 0;  -- Keeps a count of the number of age bands
g_band_number       NUMBER;  -- Primary key for temporary band tables
g_age_ff_update     DATE;  -- Last update date of age_band Fast Formula

/******************************************************************************/
/*                  PRIVATE Procdures and Functions                           */
/******************************************************************************/


/******************************************************************************/
/*                  PUBLIC Procdures and Functions                            */
/******************************************************************************/


/******************************************************************************/
/* This procedure inserts an age band into the hri_age_bands table. The PK is */
/* the minimum age for the age band. There will always be a row with minimum  */
/* age zero (since this cannot be removed by the delete_age_band API) and     */
/* there will always be (possibly the same row) a row with a null maximum age */
/* since inserting a row always works by picking the age band that the new    */
/* minimum age falls into, and splitting it out on the new minimum age.       */
/*                                                                            */
/* If a minimum age is given that already exists, then nothing will happen.   */
/*                                                                            */
/* E.g. if the following bands exist:                                         */
/*                   0 - 12                                                   */
/*                  12 - 24                                                   */
/*                  24 - 36                                                   */
/*                  36 - <null>                                               */
/*                                                                            */
/*  Then insert_age_band(0,12) would do nothing since 12 does not strictly    */
/*  fall into any of the above bands.                                         */
/*                                                                            */
/*  However, insert_age_band(0,18) [NB - equivalent to insert_age_band(1,6) ] */
/*  would give the new set of bands as:                                       */
/*                   0 - 12                                                   */
/*                  12 - 18  [UPDATEd band]                                   */
/*                  18 - 24  [INSERTed band]                                  */
/*                  24 - 36                                                   */
/*                  36 - <null>                                               */
/*                                                                            */
/* The band_min_total_months is the primary key for the table, and each age   */
/* band is defined as the ages (X) satisfying:                                */
/*       band_min_total_months <= X < band_max_total_months                   */
/*                                                                            */
/******************************************************************************/
PROCEDURE insert_age_band( p_age_min_years    NUMBER,
                           p_age_min_months   NUMBER)
IS

  l_total_min_age_months    NUMBER;  --Holds converted age min in months

  l_age_band_to_split_min   NUMBER;  -- Age minimum of band to split
  l_age_band_to_split_max   NUMBER;  -- Age maxumum of band to split

/* Selects the age band that the new age minimum falls into */
/* Since this is strict it will return no rows if an age minimum is passed in */
/* which corresponds exactly to an age minimum on an existing age band */
  CURSOR split_cur
  (v_total_min_age_months  NUMBER) IS
  SELECT band_min_total_months, band_max_total_months
  FROM hri_age_bands
  WHERE v_total_min_age_months < NVL(band_max_total_months, l_total_min_age_months + 1)
  AND   v_total_min_age_months > NVL(band_min_total_months, l_total_min_age_months - 1)
;

BEGIN

/* Converts parameters to months */
  l_total_min_age_months := p_age_min_months + (12 * p_age_min_years);

  OPEN split_cur(l_total_min_age_months);
  FETCH split_cur INTO l_age_band_to_split_min, l_age_band_to_split_max;
  IF (split_cur%NOTFOUND OR split_cur%NOTFOUND IS NULL) THEN
  /* Age Band already exists */
    CLOSE split_cur;
  ELSE
    /* Create age band with the new age min and the age max of the band it fell into */
    INSERT INTO hri_age_bands
      (band_min_total_months
      ,band_max_total_months)
      VALUES
        (l_total_min_age_months, l_age_band_to_split_max);

    /* Update the age max of the above band to the new age min above */
    UPDATE hri_age_bands
    SET band_max_total_months = l_total_min_age_months
    WHERE band_min_total_months = l_age_band_to_split_min;
  END IF;

END insert_age_band;


/******************************************************************************/
/* This procedure removes an age band from the hri_age_bands table. The PK is */
/* the minimum age for the age band. There will always be a row with minimum  */
/* age zero (since this cannot be removed by the this procedure and there     */
/* will always be (possibly the same row) a row with a null maximum age since */
/* inserting a row always works by picking the age band that the new minimum  */
/* age falls into, and splitting it out on the new minimum age.               */
/*                                                                            */
/* If a minimum age is given that does not exists, then nothing will happen.  */
/*                                                                            */
/* E.g. if the following bands exist:                                         */
/*                   0 - 12                                                   */
/*                  12 - 24                                                   */
/*                  24 - 36                                                   */
/*                  36 - <null>                                               */
/*                                                                            */
/*  Then remove_age_band(0,18) would do nothing since 18 does not match the   */
/*  minimum age of any of the above bands.                                    */
/*                                                                            */
/*  However, remove_age_band(0,12) would give the new set of bands as:        */
/*                   0 - 24  [UPDATEd band with maximum age of DELETEd band]  */
/*                  24 - 36                                                   */
/*                  36 - <null>                                               */
/* If the top band is removed, the previous band maximum age will be updated  */
/* with the null value.                                                       */
/******************************************************************************/
PROCEDURE remove_age_band( p_age_min_years   NUMBER,
                           p_age_min_months  NUMBER)
IS

  l_total_min_age_months    NUMBER;  -- Minimum age in months of band to remove

  l_total_max_age_months    NUMBER;  -- Maximum age in months of band to remove

  CURSOR grow_cur
  (v_remove_band_min   NUMBER) IS
  SELECT band_max_total_months
  FROM hri_age_bands
  WHERE band_min_total_months = v_remove_band_min;

BEGIN

  l_total_min_age_months := p_age_min_months + (12 * p_age_min_years);

  IF (l_total_min_age_months > 0) THEN
    OPEN grow_cur(l_total_min_age_months);
    FETCH grow_cur INTO l_total_max_age_months;
    IF (grow_cur%NOTFOUND OR grow_cur%NOTFOUND IS NULL) THEN
    /* Age Band doesn't exist */
      CLOSE grow_cur;
    ELSE
      DELETE FROM hri_age_bands
      WHERE band_min_total_months = l_total_min_age_months;

      UPDATE hri_age_bands
      SET band_max_total_months = l_total_max_age_months
      WHERE band_max_total_months = l_total_min_age_months;
    END IF;
  END IF;

END remove_age_band;

/*******************************************************************************/
/* Inserts a row into the table. If the row already exists then the row is    */
/* updated. Called from UPLOAD part of FNDLOAD.                               */
/******************************************************************************/
PROCEDURE load_row( p_band_min     IN NUMBER,
                    p_band_max     IN NUMBER,
                    p_owner        IN VARCHAR2 )
IS

  l_row_exists          NUMBER;  -- Whether a row already exists in table

/* Standard WHO columns */
  l_last_update_date    DATE := SYSDATE;
  l_last_updated_by     NUMBER := 0;
  l_last_update_login   NUMBER := 0;
  l_created_by          NUMBER := 0;
  l_creation_date       DATE := SYSDATE;

  CURSOR row_exists_cur IS
  SELECT 1
  FROM hri_age_bands
  WHERE band_min_total_months = p_band_min;

BEGIN

  IF (p_owner = 'SEED') THEN
    l_created_by := 1;
    l_last_updated_by := 1;
  END IF;

  OPEN row_exists_cur;
  FETCH row_exists_cur INTO l_row_exists;
  IF (row_exists_cur%NOTFOUND OR row_exists_cur%NOTFOUND IS NULL) THEN
    CLOSE row_exists_cur;
    INSERT INTO hri_age_bands
      ( band_min_total_months
      , band_max_total_months
      , last_update_date
      , last_update_login
      , last_updated_by
      , created_by
      , creation_date )
      VALUES
        ( p_band_min
        , p_band_max
        , l_last_update_date
        , l_last_update_login
        , l_last_updated_by
        , l_created_by
        , l_creation_date );
  ELSE
    CLOSE row_exists_cur;
    UPDATE hri_age_bands
    SET
     band_max_total_months = p_band_max
    ,last_update_date  = l_last_update_date
    ,last_update_login = l_last_update_login
    ,last_updated_by   = l_last_updated_by
    WHERE band_min_total_months = p_band_min;
  END IF;

END load_row;

END hri_bpl_age;

/
