--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_RANK_CTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_RANK_CTR" AS
/* $Header: hrioprkc.pkb 120.0 2005/05/29 07:34 appldev noship $ */

TYPE country_rec_type is RECORD
  (country_code  VARCHAR2(80)
  ,country_name  VARCHAR2(240));

TYPE country_rec_tab_type is TABLE of country_rec_type INDEX BY BINARY_INTEGER;

  g_countries           country_rec_tab_type;

  g_max_no_countries    PLS_INTEGER := 4;

  g_supervisor_id       NUMBER;
  g_effective_date      DATE;

  g_not_used            VARCHAR2(240) := hri_oltp_view_message.get_not_used_msg;

/* Sets the top countries, ordered by headcount as of the given date */
/* Returns the desired number in a PLSQL table */
PROCEDURE set_top_countries
 (p_supervisor_id    IN NUMBER,
  p_effective_date   IN DATE,
  p_no_countries     IN PLS_INTEGER,
  p_country_tab      OUT NOCOPY country_tab_type) IS

-- Cursor to get top countries
  CURSOR c_get_countries IS
  SELECT
   top.country_code
  ,ctr.value             country_name
  ,top.country_rank
  FROM
   hri_dbi_cl_geo_country_v  ctr
  ,(SELECT
     tab.country_code
    ,tab.total_headcount
    ,ROWNUM     country_rank
    FROM
     (SELECT
       hc.geo_country_code      country_code
      ,SUM(hc.total_headcount)  total_headcount
      FROM
       hri_mdp_sup_wrkfc_ctr_mv  hc
      WHERE hc.supervisor_person_id = p_supervisor_id
      AND p_effective_date BETWEEN effective_start_date AND effective_end_date
      GROUP BY
       hc.geo_country_code
      ORDER BY
       SUM(hc.total_headcount) DESC
      ,hc.geo_country_code
     )  tab
    WHERE ROWNUM <= g_max_no_countries
   )  top
  WHERE top.country_code = ctr.id;

BEGIN

  IF (g_supervisor_id = p_supervisor_id AND
      g_effective_date = p_effective_date AND
      p_no_countries <= g_max_no_countries) THEN

  /* Cache hit */
    NULL;

  ELSE

  /* Reset globals */
    g_supervisor_id := p_supervisor_id;
    g_effective_date := p_effective_date;

  /* Adjust maximum if necessary */
    IF (p_no_countries > g_max_no_countries) THEN
      g_max_no_countries := p_no_countries;
    END IF;

  /* Reset all values in table to "Not Used" */
    FOR i IN 1..g_max_no_countries LOOP
      g_countries(i).country_code := g_not_used;
      g_countries(i).country_name := g_not_used;
    END LOOP;

  /* Populate table with top countries */
    FOR ctr_rec IN c_get_countries LOOP
      g_countries(ctr_rec.country_rank).country_code := ctr_rec.country_code;
      g_countries(ctr_rec.country_rank).country_name := ctr_rec.country_name;
    END LOOP;

  END IF;

  FOR i IN 1..p_no_countries LOOP
    p_country_tab(i) := g_countries(i).country_code;
  END LOOP;

END set_top_countries;

-- Function to return country names by rank
FUNCTION get_country_name(p_rank   IN NUMBER)
   RETURN VARCHAR2 IS

BEGIN

  RETURN g_countries(p_rank).country_name;

EXCEPTION WHEN OTHERS THEN

  RETURN g_not_used || ' (' || to_char(p_rank) || ')';

END get_country_name;

END hri_oltp_pmv_rank_ctr;

/
