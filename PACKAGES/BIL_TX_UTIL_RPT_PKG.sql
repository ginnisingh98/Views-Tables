--------------------------------------------------------
--  DDL for Package BIL_TX_UTIL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_TX_UTIL_RPT_PKG" AUTHID CURRENT_USER AS
/* $Header: biltxuts.pls 120.9.12010000.2 2010/02/16 05:14:55 annsrini ship $ */



PROCEDURE GET_PAGE_PARAMS (p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL,
                           p_region_id               IN     VARCHAR2,
                           x_period_type             OUT NOCOPY VARCHAR2,
                           x_to_currency             OUT NOCOPY VARCHAR2,
                           x_to_period_name          OUT NOCOPY VARCHAR2,
                           x_sg_id                   OUT NOCOPY VARCHAR2,
                           x_resource_id             OUT NOCOPY VARCHAR2,
                           x_frcst_owner             OUT NOCOPY VARCHAR2,
                           x_prodcat_id              OUT NOCOPY VARCHAR2,
                           x_item_id                 OUT NOCOPY VARCHAR2,
                           x_parameter_valid         OUT NOCOPY BOOLEAN,
                           x_viewby                  OUT NOCOPY VARCHAR2,
                           x_order                   OUT NOCOPY VARCHAR2, -- Column on which data is sorted
                           x_rptby                   OUT NOCOPY VARCHAR2,
                           x_sls_chnl                OUT NOCOPY VARCHAR2,
                           x_sls_stge                OUT NOCOPY VARCHAR2,
                           x_opp_status              OUT NOCOPY VARCHAR2,
                           x_source                  OUT NOCOPY VARCHAR2,
                           x_sls_methodology         OUT NOCOPY VARCHAR2,
                           x_win_probability         OUT NOCOPY VARCHAR2,
                           x_win_probability_opr     OUT NOCOPY VARCHAR2,
                           x_close_reason            OUT NOCOPY VARCHAR2,
                           x_competitor              OUT NOCOPY VARCHAR2,
                           x_opty_number             OUT NOCOPY VARCHAR2,
                           x_total_opp_amount        OUT NOCOPY VARCHAR2,
                           x_total_opp_amt_opr       OUT NOCOPY VARCHAR2,
                           x_opty_name               OUT NOCOPY VARCHAR2,
                           x_customer                OUT NOCOPY VARCHAR2,
                           x_partner                 OUT NOCOPY VARCHAR2,
                           x_from_date               OUT NOCOPY DATE,
                           x_to_date                 OUT NOCOPY DATE);

PROCEDURE GET_DETAIL_PAGE_PARAMS
                          (p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL,
                           p_region_id               IN     VARCHAR2,
                           x_parameter_valid         OUT NOCOPY BOOLEAN,
                           x_viewby                  OUT NOCOPY VARCHAR2,
                           x_lead_id                 OUT NOCOPY VARCHAR2,
                           x_cust_id                 OUT NOCOPY VARCHAR2,
                           x_credit_type_id          OUT NOCOPY VARCHAR2 ) ;

/*
-- Removed , not used in ASN reports. Caused SQL Repository Shared Memory issues.
PROCEDURE GET_DEFAULT_QUERY(p_RegionName        IN  VARCHAR2,
                            x_SqlStr            OUT NOCOPY VARCHAR2);
*/



PROCEDURE GET_OTHER_PROFILES(x_DebugMode           OUT NOCOPY VARCHAR2);

FUNCTION get_sales_group_id RETURN NUMBER;


FUNCTION chkLogLevel (p_log_level IN NUMBER) RETURN BOOLEAN;



PROCEDURE writeLog (p_log_level     IN NUMBER,
	                  p_module        IN VARCHAR2,
	                  p_msg           IN VARCHAR2);


PROCEDURE writeQuery (p_pkg         IN VARCHAR2,
	                    p_proc        IN VARCHAR2,
	                    p_query       IN VARCHAR2);



PROCEDURE PARSE_PRODCAT_ITEM_ID( p_prodcat_id IN OUT  NOCOPY VARCHAR2,
                                 p_item_id       OUT NOCOPY VARCHAR2);

PROCEDURE PARSE_MULTI_SELECT(p_multi_select_string IN OUT NOCOPY VARCHAR,
                             p_single_select_flag     OUT NOCOPY VARCHAR);

FUNCTION GET_DEF_PRD_TYPE RETURN VARCHAR2;

FUNCTION GET_DEFAULT_PERIOD RETURN VARCHAR2;

FUNCTION GET_DEFAULT_CURRENCY RETURN VARCHAR2;

FUNCTION GET_DEFAULT_RPT_BY RETURN NUMBER;

FUNCTION GET_FROM_DATE (p_from_period_name IN VARCHAR2) RETURN DATE;

FUNCTION GET_TO_DATE (p_to_period_name IN VARCHAR2) RETURN DATE;

FUNCTION GET_RESOURCE_ID RETURN NUMBER;

PROCEDURE days_in_status (p_param   IN  BIS_PMV_PAGE_PARAMETER_TBL,
                          asn_Table OUT NOCOPY BIS_MAP_TBL);

PROCEDURE days_in_status_code (p_param   IN  BIS_PMV_PAGE_PARAMETER_TBL,
           		       asn_Table_code OUT NOCOPY BIS_MAP_TBL);

FUNCTION DEF_STRT_PRD RETURN NUMBER;

FUNCTION DEF_END_PRD RETURN NUMBER;

FUNCTION GET_DEF_FORCST_TYPE RETURN NUMBER;

FUNCTION get_prod_cat_id RETURN NUMBER;

FUNCTION  GET_STATS_CODS_OPTY_FLGS(p_flgs IN VARCHAR2) RETURN VARCHAR2;

FUNCTION GET_WIN_PROB RETURN VARCHAR2;

FUNCTION IS_NUMBER (p_param_in IN VARCHAR2) RETURN BOOLEAN;

FUNCTION WP_IS_NUMBER (p_param_in IN VARCHAR2) RETURN BOOLEAN;

FUNCTION GET_OPTY_SMRY_INF_TIP RETURN VARCHAR2;

PROCEDURE hide_parameter(p_param in bis_pmv_page_parameter_tbl,
                         hideParameter OUT NOCOPY VARCHAR2);

END BIL_TX_UTIL_RPT_PKG;

/
