--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_TRN_SUMMRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_TRN_SUMMRY" AUTHID CURRENT_USER AS
/* $Header: hrioptsm.pkh 120.0 2005/05/29 07:36 appldev noship $ */

/******************************************************************************/
/* Turnover Pivot
/******************************************************************************/

PROCEDURE get_sql_pvt(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql         OUT NOCOPY VARCHAR2,
                      x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END;

 

/
