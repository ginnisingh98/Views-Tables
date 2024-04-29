--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_PER_MGR_LOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_PER_MGR_LOV" AUTHID CURRENT_USER AS
/* $Header: hriopmgrlov.pkh 120.1 2005/10/19 10:16 jrstewar noship $ */

   PROCEDURE GET_SQL(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql       OUT NOCOPY VARCHAR2,
                     x_custom_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

   PROCEDURE GET_SQL_LEAF(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql       OUT NOCOPY VARCHAR2,
                     x_custom_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END HRI_OLTP_PMV_PER_MGR_LOV;

 

/
