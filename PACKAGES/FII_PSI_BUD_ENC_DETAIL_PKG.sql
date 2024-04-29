--------------------------------------------------------
--  DDL for Package FII_PSI_BUD_ENC_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_PSI_BUD_ENC_DETAIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIPSIBEDTLS.pls 120.1 2005/10/30 05:06:13 appldev noship $ */

-- the get_bud_trend_dtl procedure is called by Budget Trend by Account Detail
-- It is a wrapper for get_bud_enc_trend_dtl.
PROCEDURE get_bud_trend_dtl (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                             p_exp_trend_dtl_sql out NOCOPY VARCHAR2,
                             p_exp_trend_dtl_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- the get_enc_trend_dtl procedure is called by Encumbrance Trend by Account Detail
-- It is a wrapper for get_rev_exp_trend_dtl.
PROCEDURE get_enc_trend_dtl (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                             p_rev_trend_dtl_sql out NOCOPY VARCHAR2,
                             p_rev_trend_dtl_output out NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- This is the main function which constructs the PMV sql.
FUNCTION get_bud_enc_trend_dtl ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                                 p_fin_cat            IN VARCHAR2,
                                 p_trend_type         IN VARCHAR2) RETURN VARCHAR2;



END FII_PSI_BUD_ENC_DETAIL_PKG;


 

/
