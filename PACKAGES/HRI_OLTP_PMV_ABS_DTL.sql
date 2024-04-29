--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_ABS_DTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_ABS_DTL" 
/* $Header: hriopabsdt.pkh 120.0.12000000.1 2007/01/15 22:09:54 appldev noship $ */
AUTHID CURRENT_USER AS

PROCEDURE get_abs_detail
  (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
   x_custom_sql         OUT NOCOPY VARCHAR2,
   x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END HRI_OLTP_PMV_ABS_DTL ;

 

/
