--------------------------------------------------------
--  DDL for Package FII_PSI_MON_CUMUL_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PSI_MON_CUMUL_TREND_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIPSIMCTS.pls 120.1 2005/10/30 05:06:03 appldev noship $ */

-- the GET_MON_CUMUL_TREND procedure is called by Monthly Cumulative Trend report.
PROCEDURE GET_MON_CUMUL_TREND (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         p_mon_trend_sql out NOCOPY VARCHAR2,
                         p_mon_trend_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END  FII_PSI_MON_CUMUL_TREND_PKG;

 

/
