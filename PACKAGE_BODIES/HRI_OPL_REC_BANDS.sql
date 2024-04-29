--------------------------------------------------------
--  DDL for Package Body HRI_OPL_REC_BANDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_REC_BANDS" AS
/* $Header: hriprbnd.pkb 115.2 2002/11/19 11:35:05 jtitmas noship $ */

TYPE g_band_rec IS RECORD(g_min_value       NUMBER,
                          g_max_value       NUMBER,
                          g_band_name       VARCHAR2(30));

TYPE g_bands_tabtype IS TABLE OF g_band_rec INDEX BY BINARY_INTEGER;


g_apl_bands_tab     g_bands_tabtype;
g_vac_bands_tab     g_bands_tabtype;

/* Bug 2669294 - Incremented band min value for the displayed name if it */
/* is non-zero */
CURSOR g_apl_time_bands_csr IS
SELECT
 band_min_value  min_val
,band_max_value  max_val
,to_char(DECODE(band_min_value, 0, 0, band_min_value + 1)) ||
 DECODE(band_max_value, to_number(null), ' +', ' - ' || to_char(band_max_value))
                 band_name
,band_sequence   seq_no
FROM hri_time_bands
WHERE type = 'APL_STAGE';

/* Bug 2669294 - Incremented band min value for the displayed name if it */
/* is non-zero */
CURSOR g_vac_time_bands_csr IS
SELECT
 band_min_value  min_val
,band_max_value  max_val
,to_char(DECODE(band_min_value, 0, 0, band_min_value + 1)) ||
 DECODE(band_max_value, to_number(null), ' +', ' - ' || to_char(band_max_value))
                 band_name
,band_sequence   seq_no
FROM hri_time_bands
WHERE type = 'VACANCY';

/******************************************************************************/
/* Returns an indicator for whether the supplied value is within the          */
/* specified applicant time band                                              */
/******************************************************************************/
FUNCTION is_in_apl_band(p_value          IN NUMBER,
                        p_band_sequence  IN NUMBER)
             RETURN NUMBER IS

BEGIN

/* Bug 2673387 - Fixed condition */
  IF ((g_apl_bands_tab(p_band_sequence).g_min_value < p_value OR
       g_apl_bands_tab(p_band_sequence).g_min_value = 0) AND
      (p_value <= g_apl_bands_tab(p_band_sequence).g_max_value OR
       g_apl_bands_tab(p_band_sequence).g_max_value IS NULL)) THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;

EXCEPTION
  WHEN OTHERS THEN

  RETURN to_number(null);

END is_in_apl_band;

/******************************************************************************/
/* Returns an indicator for whether the supplied value is within the          */
/* specified vacancy time band                                                */
/******************************************************************************/
FUNCTION is_in_vac_band(p_value          IN NUMBER,
                        p_band_sequence  IN NUMBER)
             RETURN NUMBER IS

BEGIN

/* Bug 2673387 - Fixed condition */
  IF ((g_vac_bands_tab(p_band_sequence).g_min_value < p_value OR
       g_vac_bands_tab(p_band_sequence).g_min_value = 0) AND
      (p_value <= g_vac_bands_tab(p_band_sequence).g_max_value OR
       g_vac_bands_tab(p_band_sequence).g_max_value IS NULL)) THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;

EXCEPTION
  WHEN OTHERS THEN

  RETURN to_number(null);

END is_in_vac_band;

/******************************************************************************/
/* Function returning a specific band name from the global table              */
/******************************************************************************/
FUNCTION get_apl_time_band_name(p_band_sequence    IN NUMBER)
                 RETURN VARCHAR2 IS

BEGIN

  RETURN g_apl_bands_tab(p_band_sequence).g_band_name;

EXCEPTION WHEN OTHERS THEN

  RETURN to_char(p_band_sequence);

END get_apl_time_band_name;

/******************************************************************************/
/* Function returning a specific band name from the global table              */
/******************************************************************************/
FUNCTION get_vac_time_band_name(p_band_sequence    IN NUMBER)
                 RETURN VARCHAR2 IS

BEGIN

  RETURN g_vac_bands_tab(p_band_sequence).g_band_name;

EXCEPTION WHEN OTHERS THEN

  RETURN to_char(p_band_sequence);

END get_vac_time_band_name;

/******************************************************************************/
/* INITIALIZATION SECTION                                                     */
/******************************************************************************/
BEGIN

  FOR g_apl_rec IN g_apl_time_bands_csr LOOP
    g_apl_bands_tab(g_apl_rec.seq_no).g_min_value := g_apl_rec.min_val;
    g_apl_bands_tab(g_apl_rec.seq_no).g_max_value := g_apl_rec.max_val;
    g_apl_bands_tab(g_apl_rec.seq_no).g_band_name := g_apl_rec.band_name;
  END LOOP;

  FOR g_vac_rec IN g_vac_time_bands_csr LOOP
    g_vac_bands_tab(g_vac_rec.seq_no).g_min_value := g_vac_rec.min_val;
    g_vac_bands_tab(g_vac_rec.seq_no).g_max_value := g_vac_rec.max_val;
    g_vac_bands_tab(g_vac_rec.seq_no).g_band_name := g_vac_rec.band_name;
  END LOOP;

END hri_opl_rec_bands;

/
