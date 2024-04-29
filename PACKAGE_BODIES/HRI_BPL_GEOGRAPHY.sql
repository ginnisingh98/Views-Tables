--------------------------------------------------------
--  DDL for Package Body HRI_BPL_GEOGRAPHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_GEOGRAPHY" AS
/* $Header: hribgeog.pkb 115.1 2003/03/20 16:48:57 jtitmas noship $ */

/* Define global variable for the Region segment */
g_region_segment 	VARCHAR2(20);

/* Indicates whether all regions are cached */
g_all_regions_cached    VARCHAR2(1) := 'N';

/* Define global table for the collection of location and region code */
TYPE g_region_tabtype IS TABLE OF hr_locations_all.attribute1%TYPE
         INDEX BY BINARY_INTEGER;
g_location_region_tab  g_region_tabtype;  -- cache table
g_empty_region_tab     g_region_tabtype;  -- empty table for resetting cache


/******************************************************************************/
/* This function returns the flexfield segment used for storing regions       */
/******************************************************************************/
PROCEDURE cache_region_segment IS

/* Cursor to collect the attribute which stores the region code */
  CURSOR region_segment_csr is
  SELECT bfm.application_column_name
    FROM bis_flex_mappings_v                      bfm
       , bis_dimensions                           bd
   WHERE bfm.dimension_id     = bd.dimension_id
     AND bd.short_name        = 'GEOGRAPHY'
     AND bfm.level_short_name = 'REGION'
     AND bfm.application_id   = 800;

BEGIN

  /* Fetches the attribute which is used to store the region code into */
  /*  the global varable g_region_segment */
  OPEN region_segment_csr;
  FETCH region_segment_csr INTO g_region_segment;
  CLOSE region_segment_csr;

EXCEPTION WHEN OTHERS THEN

  CLOSE region_segment_csr;

END cache_region_segment;


/******************************************************************************/
/* This function caches all region codes for all locations                    */
/******************************************************************************/
PROCEDURE cache_all_regions IS

  TYPE region_csr_type IS REF CURSOR;
  region_cv   region_csr_type;

  csr_sql_stmt     VARCHAR2(200);

  l_region_code    VARCHAR2(80);
  l_location_id    NUMBER;

BEGIN

/* If the initialized segment doesn't exist then don't even go there */
  IF (g_region_segment IS NOT NULL) THEN

  /* Set the dynamic cursor */
    csr_sql_stmt := 'SELECT ' || g_region_segment || ' ' ||
                    ', location_id ' ||
                    'FROM hr_locations_all ' ||
                    'WHERE ' || g_region_segment || ' IS NOT NULL';
  /* Loop through the cursor and populate the cache */
    OPEN region_cv FOR csr_sql_stmt;
      LOOP
        FETCH region_cv INTO l_region_code, l_location_id;
        EXIT WHEN region_cv%NOTFOUND;
        g_location_region_tab(l_location_id) := l_region_code;
      END LOOP;
    CLOSE region_cv;

  END IF;

  g_all_regions_cached := 'Y';

EXCEPTION WHEN OTHERS THEN

  CLOSE region_cv;

END cache_all_regions;

/******************************************************************************/
/* This function returns the specific region code for a location.             */
/* But it kicks off the cache to load all regions in bulk                     */
/******************************************************************************/
FUNCTION get_region_code(p_location_id   IN NUMBER)
     RETURN VARCHAR2 IS

  l_return_code     VARCHAR2(80);

BEGIN

/* If the cache is empty then populate it */
  IF (g_all_regions_cached = 'N') THEN
    cache_all_regions;
  END IF;

/* Return values from cache */
  BEGIN
    l_return_code := g_location_region_tab(p_location_id);
  EXCEPTION WHEN OTHERS THEN
/* Return blank if no region for the location */
    l_return_code := ' ';
  END;

  RETURN l_return_code;

END get_region_code;


/******************************************************************************/
/* Initialization */
/******************/
BEGIN

/* Store flexfield segment used for region in a global variable */
  cache_region_segment;

END hri_bpl_geography;

/
