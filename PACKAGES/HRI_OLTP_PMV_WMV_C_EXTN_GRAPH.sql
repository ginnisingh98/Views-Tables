--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_C_EXTN_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_C_EXTN_GRAPH" AUTHID CURRENT_USER AS
/* $Header: hriopcetg.pkh 120.0 2005/06/24 07:32:33 appldev noship $ */


PROCEDURE GET_SQL(
       p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql  OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   ) ;

END;

 

/
