--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_SAL_KPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_SAL_KPI" 
/* $Header: hriopski.pkh 120.0 2005/05/29 07:35:48 appldev noship $ */
AUTHID CURRENT_USER AS
FUNCTION GET_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL) returN varchar2 ;

END HRI_OLTP_PMV_SAL_KPI ;

 

/
