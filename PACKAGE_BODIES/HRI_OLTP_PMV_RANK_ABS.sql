--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_RANK_ABS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_RANK_ABS" AS
/* $Header: hrioprkac.pkb 120.2 2005/10/13 09:19 cbridge noship $ */

TYPE category_rec_type is RECORD
  (category_code  VARCHAR2(80)
  ,category_name  VARCHAR2(240));

TYPE abs_category_tab_type is TABLE of category_rec_type INDEX BY BINARY_INTEGER;

  g_categories          abs_category_tab_type;

  g_max_no_categories   PLS_INTEGER := 4;

  g_supervisor_id       NUMBER;
  g_effective_from_date      DATE;
  g_effective_to_date      DATE;

  g_not_used            VARCHAR2(240) := hri_oltp_view_message.get_not_used_msg;

/* Sets the top categories, ordered by abs_drtn as of the given date */
/* Returns the desired number in a PLSQL table */
PROCEDURE set_top_categories
 (p_supervisor_id    IN NUMBER,
  p_effective_from_date   IN DATE,
  p_effective_to_date     IN DATE,
  p_no_categories    IN PLS_INTEGER,
  p_category_tab     OUT NOCOPY abs_category_tab) IS

-- Cursor to get top categories
  CURSOR c_get_categories IS
  SELECT
   top.category_code
  ,cat.value             category_name
  ,top.category_rank
  FROM
   hri_cl_absnc_cat_v  cat
  ,(SELECT
     tab.category_code
    ,tab.abs_drtn_days
    ,ROWNUM     category_rank
    FROM
       (SELECT
         SUM(fact.abs_drtn_days)      abs_drtn_days
        ,fact.absence_category_code   category_code
        FROM
           hri_mdp_sup_absnc_cat_mv  fact
        WHERE fact.supervisor_person_id = p_supervisor_id
        AND fact.effective_date BETWEEN p_effective_from_date AND p_effective_to_date
        GROUP BY
          fact.absence_category_code
        ORDER BY
          SUM(fact.abs_drtn_days) DESC
         ,fact.absence_category_code
     )  tab
    WHERE ROWNUM <= g_max_no_categories
   )  top
  WHERE top.category_code = cat.id;

BEGIN

  IF (g_supervisor_id = p_supervisor_id AND
      g_effective_from_date = p_effective_from_date AND
      g_effective_to_date = p_effective_to_date AND
      p_no_categories <= g_max_no_categories) THEN

  /* Cache hit */
    NULL;

  ELSE

  /* Reset globals */
    g_supervisor_id := p_supervisor_id;
    g_effective_from_date := p_effective_from_date;
    g_effective_to_date := p_effective_to_date;

  /* Adjust maximum if necessary */
    IF (p_no_categories > g_max_no_categories) THEN
      g_max_no_categories := p_no_categories;
    END IF;

  /* Reset all values in table to "Not Used" */
    FOR i IN 1..g_max_no_categories LOOP
      g_categories(i).category_code := g_not_used;
      g_categories(i).category_name := g_not_used;
    END LOOP;

  /* Populate table with top countries */
    FOR cat_rec IN c_get_categories LOOP
      g_categories(cat_rec.category_rank).category_code := cat_rec.category_code;
      g_categories(cat_rec.category_rank).category_name := cat_rec.category_name;
    END LOOP;


  END IF;

  FOR i IN 1..p_no_categories LOOP
    p_category_tab(i) := g_categories(i).category_code;
  END LOOP;

END set_top_categories;

-- Function to return category names by rank
FUNCTION get_category_name(p_rank   IN NUMBER)
   RETURN VARCHAR2 IS

BEGIN

  RETURN g_categories(p_rank).category_name;

EXCEPTION WHEN OTHERS THEN

  RETURN g_not_used || ' (' || to_char(p_rank) || ')';

END get_category_name;

-- Function to return category code by rank
FUNCTION get_category_code(p_rank   IN NUMBER)
   RETURN VARCHAR2 IS

BEGIN

  RETURN NVL(g_categories(p_rank).category_code,'NA_EDW');

EXCEPTION WHEN OTHERS THEN

  RETURN g_not_used || ' (' || to_char(p_rank) || ')';

END get_category_code;



END hri_oltp_pmv_rank_abs;

/
