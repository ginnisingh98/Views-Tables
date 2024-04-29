--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_ABS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_ABS_PVT" AUTHID CURRENT_USER AS
/* $Header: hriopabspvt.pkh 120.0 2005/09/22 07:29 cbridge noship $ */

  PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT NOCOPY VARCHAR2
                   ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END HRI_OLTP_PMV_ABS_PVT;

 

/
