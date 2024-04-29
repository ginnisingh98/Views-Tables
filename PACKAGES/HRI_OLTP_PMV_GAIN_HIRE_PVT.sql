--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_GAIN_HIRE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_GAIN_HIRE_PVT" AUTHID CURRENT_USER AS
/* $Header: hriopghp.pkh 120.0 2005/05/29 07:32:51 appldev noship $ */
  --
  PROCEDURE get_sql2(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql          OUT NOCOPY VARCHAR2,
                     x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
  --
END hri_oltp_pmv_gain_hire_pvt;

 

/
