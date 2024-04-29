--------------------------------------------------------
--  DDL for Package ASO_BI_QOT_SUMMRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_BI_QOT_SUMMRY_PVT" AUTHID CURRENT_USER AS
/* $Header: asovbiqsmrys.pls 120.0 2005/05/31 01:26:06 appldev noship $ */

-- This  will Return the Top Quotes --

PROCEDURE BY_TOPQUOT_SQL(
                         p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_TBL,
                         x_custom_sql     OUT NOCOPY VARCHAR2,
                         x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
			   );


-- This will return the SQL Query for Current/Previous VALUES,
-- COUNT of the Total/Converted QUOTES for Sales Group.
PROCEDURE BY_SALESGRP_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL


                           );

-- For Approval Rules Summary
PROCEDURE  BY_APPR_RULES(
                         p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_TBL,
                         x_custom_sql     OUT NOCOPY VARCHAR2,
                         x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
			   );

-- For Quote Summary By Approvals
PROCEDURE APPR_BY_SALESGRP_SQL(
                         p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_TBL,
                         x_custom_sql     OUT NOCOPY VARCHAR2,
                         x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
			   );

-- Quote Summary By Product Category
PROCEDURE BY_PRODUCTCAT_SQL(
                         p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_TBL,
                         x_custom_sql     OUT NOCOPY VARCHAR2,
                         x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
			   );

-- Quote Summary By Discount
PROCEDURE BY_DISCOUNT_SQL(
                            p_pmv_parameters IN BIS_PMV_PAGE_PARAMETER_tbl,
                            x_custom_sql     OUT NOCOPY VARCHAR2,
                            x_custom_output  OUT NOCOPY bis_query_attributes_TBL
                           );
END ASO_BI_QOT_SUMMRY_PVT;

 

/
