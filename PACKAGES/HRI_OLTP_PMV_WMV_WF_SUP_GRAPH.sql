--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_WF_SUP_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_WF_SUP_GRAPH" AUTHID CURRENT_USER AS
/* $Header: hriopwfsg.pkh 120.0 2005/06/24 07:33:29 appldev noship $ */


PROCEDURE GET_SQL2(
       p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql  OUT NOCOPY VARCHAR2,
       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   ) ;

END;

 

/
