--------------------------------------------------------
--  DDL for Package BIM_PMV_DBI_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_PMV_DBI_UTL_PKG" AUTHID CURRENT_USER AS
/*$Header: bimvutls.pls 120.1 2005/08/04 23:32:27 sbassi noship $ */

PROCEDURE get_bim_page_params (p_page_parameter_tbl                IN     BIS_PMV_PAGE_PARAMETER_TBL,
								l_as_of_date              OUT NOCOPY DATE,
								l_period_type             IN OUT NOCOPY VARCHAR2,
								l_record_type_id          OUT NOCOPY NUMBER,
								l_comp_type               OUT NOCOPY VARCHAR2,
								l_country                 in OUT NOCOPY VARCHAR2,
								l_view_by                 in OUT NOCOPY VARCHAR2,
								l_cat_id                  in OUT NOCOPY VARCHAR2,
								l_campaign_id             in OUT NOCOPY VARCHAR2,
								l_currency                in OUT NOCOPY VARCHAR2,
								l_col_id                  in OUT NOCOPY NUMBER,
								l_area                    in OUT NOCOPY VARCHAR2,
								l_media                    in OUT NOCOPY VARCHAR2,
								l_report_name             in OUT NOCOPY VARCHAR2
				      ) ;
PROCEDURE get_bim_page_sgmt_params  (p_page_parameter_tbl      IN  BIS_PMV_PAGE_PARAMETER_TBL,
									p_as_of_date              OUT NOCOPY DATE,
									p_period_type             IN  OUT NOCOPY VARCHAR2,
									p_record_type_id          OUT NOCOPY NUMBER,
									p_view_by                 IN OUT NOCOPY VARCHAR2,
									p_cat_id                  IN OUT NOCOPY VARCHAR2,
									p_sgmt_id                 IN OUT NOCOPY VARCHAR2,
									p_currency                IN OUT NOCOPY VARCHAR2,
									p_url_metric			  IN OUT NOCOPY VARCHAR2,
									p_url_viewby			  IN OUT NOCOPY VARCHAR2,
									p_url_viewbyid			  IN OUT NOCOPY VARCHAR2
				) ;
PROCEDURE get_viewby_id (p_page_parameter_tbl                IN     BIS_PMV_PAGE_PARAMETER_TBL,
                         l_viewby_id in OUT NOCOPY NUMBER);

  FUNCTION Current_Period_Start_Date(l_as_of_date	DATE,
                                   	 l_period_type	VARCHAR2) RETURN DATE;

  FUNCTION Previous_Period_Start_Date(l_as_of_date	DATE,
                              	  l_period_type	VARCHAR2,
                              	  l_comp_type	VARCHAR2) RETURN DATE;

  FUNCTION Current_Report_Start_Date(l_as_of_date	DATE,
                              	 l_period_type	VARCHAR2) RETURN DATE ;

  FUNCTION Previous_Report_Start_Date(l_as_of_date	DATE,
                              	  l_period_type	VARCHAR2,
                              	  l_comp_type	VARCHAR2) RETURN DATE;

  FUNCTION Previous_Period_Asof_Date(l_as_of_date	DATE,
                                   	 l_period_type	VARCHAR2,
                                   	 l_comp_type	VARCHAR2) RETURN DATE ;

PROCEDURE GET_TREND_PARAMS(  p_page_period_type  IN VARCHAR2,
                             p_comp_type         IN VARCHAR2,
                             p_curr_as_of_date   IN DATE,
                             p_table_name        OUT NOCOPY VARCHAR2,
                             p_column_name       OUT NOCOPY VARCHAR2,
                             p_curr_start_date   OUT NOCOPY DATE,
                             p_prev_start_date   OUT NOCOPY DATE,
                             p_prev_end_date     OUT NOCOPY DATE,
			     p_series_name       OUT NOCOPY VARCHAR2,
			     p_time_ids          OUT NOCOPY VARCHAR2
                             );

FUNCTION GET_COLUMN_A ( p_name IN Varchar2)  RETURN VARCHAR2;


FUNCTION get_rpl_label(p_name in varchar2,pld in varchar2) RETURN VARCHAR2;

FUNCTION GET_LOOKUP_VALUE (code in  varchar2) return VARCHAR2 ;

FUNCTION GET_CONTEXT_VIEWBY (code in  varchar2) return VARCHAR2 ;

END  BIM_PMV_DBI_UTL_PKG;

 

/
