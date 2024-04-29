--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_ABS_CAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_ABS_CAT" 
/* $Header: hriopabsct.pkh 120.0 2005/09/22 07:29 cbridge noship $ */
AUTHID CURRENT_USER AS

PROCEDURE get_sql_abscat_t4
  (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
   x_custom_sql         OUT NOCOPY VARCHAR2,
   x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_SQL_TN(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT NOCOPY VARCHAR2
                   ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END HRI_OLTP_PMV_ABS_CAT ;

 

/
