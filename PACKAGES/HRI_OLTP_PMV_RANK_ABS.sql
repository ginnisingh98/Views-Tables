--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_RANK_ABS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_RANK_ABS" AUTHID CURRENT_USER AS
/* $Header: hrioprkac.pkh 120.1 2005/10/13 09:18 cbridge noship $ */

TYPE abs_category_tab is TABLE of VARCHAR2(80) INDEX BY BINARY_INTEGER;

PROCEDURE set_top_categories
 (p_supervisor_id    IN NUMBER,
  p_effective_from_date   IN DATE,
  p_effective_to_date   IN DATE,
  p_no_categories    IN PLS_INTEGER,
  p_category_tab     OUT NOCOPY abs_category_tab);

FUNCTION get_category_name(p_rank   IN NUMBER)
   RETURN VARCHAR2;

-- used for drill across dimension id for column 1 .. 4
FUNCTION get_category_code(p_rank   IN NUMBER)
   RETURN VARCHAR2;

END hri_oltp_pmv_rank_abs;

 

/
