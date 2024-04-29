--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_DTL_SALARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_DTL_SALARY" 
/* $Header: hriopsdt.pkh 120.1 2005/07/01 01:40:51 jtitmas noship $ */
AUTHID CURRENT_USER AS

PROCEDURE get_salary_detail2
  (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
   x_custom_sql         OUT NOCOPY VARCHAR2,
   x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_hr_detail
  (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
   x_custom_sql         OUT NOCOPY VARCHAR2,
   x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END HRI_OLTP_PMV_DTL_SALARY ;

 

/
