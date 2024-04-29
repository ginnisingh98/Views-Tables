--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_RANK_CTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_RANK_CTR" AUTHID CURRENT_USER AS
/* $Header: hrioprkc.pkh 120.0 2005/05/29 07:34 appldev noship $ */

TYPE country_tab_type is TABLE of VARCHAR2(80) INDEX BY BINARY_INTEGER;

PROCEDURE set_top_countries
 (p_supervisor_id    IN NUMBER,
  p_effective_date   IN DATE,
  p_no_countries     IN PLS_INTEGER,
  p_country_tab      OUT NOCOPY country_tab_type);

FUNCTION get_country_name(p_rank   IN NUMBER)
   RETURN VARCHAR2;

END hri_oltp_pmv_rank_ctr;

 

/
