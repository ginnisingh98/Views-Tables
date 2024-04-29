--------------------------------------------------------
--  DDL for Package Body HRI_EDW_DIM_AGE_BAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_EDW_DIM_AGE_BAND" AS
/* $Header: hriedagb.pkb 120.0 2005/05/29 07:07:58 appldev noship $ */

/******************************************************************************/
/* This is a dummy procedure which calls the procedure insert_age_band from   */
/* the Business Process Layer.                                                */
/*                                                                            */
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

BEGIN

  hri_bpl_age.insert_age_band
      ( p_age_min_years    => p_age_min_years
      , p_age_min_months   => p_age_min_months);

END insert_age_band;

/******************************************************************************/
/* This is a dummy procedure which calls the procedure remove_age_band from   */
/* the Business Process Layer.                                                */
/*                                                                            */
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

BEGIN
  hri_bpl_age.remove_age_band
    ( p_age_min_years   => p_age_min_years,
      p_age_min_months  => p_age_min_months);

END remove_age_band;

/******************************************************************************/
/* Inserts a row into the table. If the row already exists then the row is    */
/* updated. Called from UPLOAD part of FNDLOAD.                               */
/******************************************************************************/
PROCEDURE load_row( p_band_min     IN NUMBER,
                    p_band_max     IN NUMBER,
                    p_owner        IN VARCHAR2 )
 IS
BEGIN

 hri_bpl_age.load_row
    ( p_band_min     => p_band_min,
      p_band_max     => p_band_max,
      p_owner        => p_owner );

END load_row;

END hri_edw_dim_age_band;

/
