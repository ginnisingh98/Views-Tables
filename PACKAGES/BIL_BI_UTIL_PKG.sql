--------------------------------------------------------
--  DDL for Package BIL_BI_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_BI_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: bilbuts.pls 120.4 2005/10/10 03:08:35 hrpandey noship $ */


FUNCTION chkLogLevel (p_log_level IN NUMBER) RETURN BOOLEAN;

PROCEDURE GET_CONV_RATE(p_as_of_date          IN  DATE
                       ,p_currency            IN  VARCHAR2
                       ,x_conv_rate_selected  OUT NOCOPY VARCHAR2
                       ,x_err_desc            OUT NOCOPY VARCHAR2
                       ,x_err_msg             OUT NOCOPY VARCHAR2
                       ,x_parameter_valid     OUT NOCOPY BOOLEAN );

PROCEDURE GET_CURR_DATE(x_curr_date OUT NOCOPY DATE);

PROCEDURE GET_CURR_START_DATE (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                               p_as_of_date         IN DATE,
                               p_period_type        IN VARCHAR2,
                               x_curr_start_date    OUT NOCOPY DATE);

FUNCTION GET_DBI_PARAMS(p_region_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_dbi_sales_group_id RETURN VARCHAR2;

PROCEDURE GET_DEFAULT_QUERY(p_RegionName IN  VARCHAR2,
                            x_SqlStr     OUT NOCOPY VARCHAR2);

PROCEDURE GET_FORECAST_PROFILES(x_FstCrdtType OUT NOCOPY VARCHAR2 );

PROCEDURE GET_GLOBAL_CONTS(x_bitand_id   OUT NOCOPY VARCHAR2,
                           x_calendar_id OUT NOCOPY VARCHAR2,
                           x_curr_date   OUT NOCOPY DATE,
                           x_fii_struct  OUT NOCOPY VARCHAR2);

PROCEDURE GET_LATEST_SNAP_DATE(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                               p_as_of_date         IN DATE,
                               p_period_type        IN VARCHAR2,
                               x_snapshot_date      OUT NOCOPY DATE);


PROCEDURE GET_OTHER_PROFILES(x_DebugMode OUT NOCOPY VARCHAR2);



PROCEDURE GET_PAGE_PARAMS (p_page_parameter_tbl  IN  BIS_PMV_PAGE_PARAMETER_TBL,
                           p_region_id           IN  VARCHAR2,
                           x_as_of_date          OUT NOCOPY DATE,
                           x_comp_type           OUT NOCOPY VARCHAR2,
                           x_conv_rate_selected  OUT NOCOPY VARCHAR2,
                           x_curr_page_time_id   OUT NOCOPY NUMBER,
                           x_page_period_type    OUT NOCOPY VARCHAR2,
                           x_parameter_valid     OUT NOCOPY BOOLEAN,
                           x_period_type         OUT NOCOPY VARCHAR2,
                           x_prev_page_time_id   OUT NOCOPY NUMBER,
                           x_prior_as_of_date    OUT NOCOPY DATE,
                           x_prodcat_id          OUT NOCOPY VARCHAR2,
                           x_record_type_id      OUT NOCOPY NUMBER,
                           x_resource_id         OUT NOCOPY VARCHAR2,
                           x_sg_id               OUT NOCOPY VARCHAR2,
                           x_parent_sg_id        OUT NOCOPY NUMBER,
                           x_viewby              OUT NOCOPY VARCHAR2);


PROCEDURE GET_PRODUCT_WHERE_CLAUSE(p_prodcat       IN VARCHAR2,
                                   p_viewby        IN VARCHAR2,
                                   x_denorm        OUT NOCOPY VARCHAR2,
                                   x_where_clause  OUT NOCOPY VARCHAR2);

PROCEDURE  GET_PC_NOROLLUP_WHERE_CLAUSE(p_prodcat       IN VARCHAR2,
                                   p_viewby        IN VARCHAR2,
                                   x_denorm        OUT NOCOPY VARCHAR2,
                                   x_where_clause  OUT NOCOPY VARCHAR2);

PROCEDURE GET_TREND_PARAMS (p_comp_type              IN VARCHAR2,
                            p_curr_as_of_date        IN DATE,
                            p_page_parameter_tbl     IN BIS_PMV_PAGE_PARAMETER_TBL,
                            p_page_period_type       IN VARCHAR2,
                            x_column_name            OUT NOCOPY VARCHAR2,
                            x_curr_eff_end_date      OUT NOCOPY DATE,
                            x_curr_start_date        OUT NOCOPY DATE,
                            x_prev_eff_end_date      OUT NOCOPY DATE,
                            x_prev_start_date        OUT NOCOPY DATE,
                            x_table_name             OUT NOCOPY VARCHAR2);

FUNCTION isUserCurrency (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL) RETURN BOOLEAN;

FUNCTION GET_UNASSIGNED_PC RETURN VARCHAR2;

FUNCTION isLeafNode (p_prodcat_id IN NUMBER) RETURN BOOLEAN;

PROCEDURE PARSE_SALES_GROUP_ID(p_salesgroup_id  IN OUT NOCOPY VARCHAR2,
                               x_resource_id    OUT NOCOPY VARCHAR2 );

FUNCTION getLookupMeaning (p_lookuptype IN VARCHAR2,p_lookupcode IN VARCHAR2) RETURN VARCHAR2;



PROCEDURE GET_PARENT_SLS_GRP_ID(p_sales_grp_id IN NUMBER,
                                x_parent_sls_grp_id OUT NOCOPY NUMBER,
                                x_parameter_valid OUT NOCOPY BOOLEAN);




PROCEDURE GET_PRIOR_PRIOR_TIME (p_comp_type   IN VARCHAR2,
                                p_period_type IN VARCHAR2,
                                p_prev_date   IN DATE,
                                p_prev_page_time_id IN NUMBER,
                                x_prior_prior_date    OUT NOCOPY DATE,
                                x_prior_prior_time_id OUT NOCOPY NUMBER);

FUNCTION GET_DRILL_LINKS ( p_view_by           IN     VARCHAR2,
                           p_salesgroup_id     IN     VARCHAR2,
                           p_resource_id       IN     VARCHAR2
) RETURN VARCHAR2;


FUNCTION GET_LBL_SGFST (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL) RETURN VARCHAR2;


PROCEDURE GET_PIPE_SNAP_DATE( p_as_of_date          IN DATE,
                              p_prev_date           IN DATE,
                              p_period_type         IN VARCHAR2,
                              p_coll_st_date        IN DATE,
                              p_coll_end_date       IN DATE,
                              p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                              x_snap_date           OUT NOCOPY DATE,
                              x_prev_snap_date      OUT NOCOPY DATE
                             );

PROCEDURE GET_PIPE_MV(
                                     p_asof_date          IN  DATE,
                                     p_period_type        IN  VARCHAR2,
                                     p_compare_to         IN  VARCHAR2,
                                     p_prev_date          IN DATE,
                                     p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                                     x_pipe_mv            OUT NOCOPY VARCHAR2,
                                     x_snapshot_date      OUT NOCOPY DATE,
                                     x_prev_snap_date     OUT NOCOPY DATE
				    ) ;

FUNCTION GET_HIST_SNAPSHOT_DATE (p_asof_date IN DATE,
                                 x_period_type IN VARCHAR2
				 ) RETURN DATE;

FUNCTION GET_PIPE_COL_NAMES(p_period_type   IN  VARCHAR2,
                            p_compare_to    IN  VARCHAR2,
                            p_column_type   IN  VARCHAR2,
                            p_curr_suffix   IN  VARCHAR2
			   ) RETURN VARCHAR2;


PROCEDURE GET_PIPE_TREND_SOURCE (p_as_of_date          IN DATE,
                                 p_prev_date           IN DATE,
                                 p_trend_type          IN VARCHAR2,
                                 p_period_type         IN VARCHAR2,
                                 p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                                 x_pipe_mv             OUT NOCOPY VARCHAR2,
                                 x_snap_date           OUT NOCOPY DATE,
                                 x_prev_snap_date      OUT NOCOPY DATE);

END BIL_BI_UTIL_PKG;

 

/
