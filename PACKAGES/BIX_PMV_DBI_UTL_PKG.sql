--------------------------------------------------------
--  DDL for Package BIX_PMV_DBI_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_PMV_DBI_UTL_PKG" AUTHID CURRENT_USER AS
/*$Header: bixdutls.pls 120.1 2006/03/28 22:49:04 pubalasu noship $ */

g_email_accnt_dim      CONSTANT VARCHAR2 (100) := 'EMAIL ACCOUNT+EMAIL ACCOUNT';
g_email_class_dim      CONSTANT VARCHAR2 (100) := 'EMAIL CLASSIFICATION+EMAIL CLASSIFICATION';
g_ai_ccntr_dim		   CONSTANT VARCHAR2 (100) := 'BIX_TELEPHONY+BIX_CALL_CENTER';
g_ai_class_dim         CONSTANT VARCHAR2 (100) := 'BIX_TELEPHONY+BIX_CALL_CLASSIFICATION';
g_ai_dnis_dim          CONSTANT VARCHAR2 (100) := 'BIX_TELEPHONY+BIX_DNIS';
g_ai_custm_dim         CONSTANT VARCHAR2(100)  := 'CUSTOMER';

g_agent_group_dim          CONSTANT VARCHAR2 (100) := 'ORGANIZATION+JTF_ORG_SUPPORT_GROUP';


g_c_period_start_date   CONSTANT VARCHAR2 (60) := '&BIS_CURRENT_EFFECTIVE_START_DATE';
g_p_period_start_date   CONSTANT VARCHAR2 (60) := '&BIS_PREVIOUS_EFFECTIVE_START_DATE';
g_c_as_of_date          CONSTANT VARCHAR2 (60) := '&BIS_CURRENT_ASOF_DATE';
g_p_as_of_date          CONSTANT VARCHAR2 (60) := '&BIS_PREVIOUS_ASOF_DATE';
g_pp_date               CONSTANT VARCHAR2 (60) := '&PREV_PREV_DATE';
g_c_period_end_date     CONSTANT VARCHAR2 (60) := '&BIS_CURRENT_EFFECTIVE_END_DATE';
g_p_period_end_date     CONSTANT VARCHAR2 (60) := '&BIS_PREVIOUS_EFFECTIVE_END_DATE';

/* Two bitmap variables used for the inlist generation */
g_inlist_xed            CONSTANT NUMBER        := 1; -- Bit 0
g_inlist_xtd            CONSTANT NUMBER        := 2; -- Bit 1
g_inlist_ytd            CONSTANT NUMBER        := 4; -- Bit 2

/* for balance */
g_c_as_of_date_balance  constant varchar2(60) := 'least(&BIS_CURRENT_EFFECTIVE_END_DATE,&LAST_COLLECTION)';
g_p_as_of_date_balance  constant varchar2(60) := 'least(&BIS_PREVIOUS_EFFECTIVE_END_DATE,&LAST_COLLECTION)';
g_c_as_of_date_o_balance constant varchar2(70) := 'least((&BIS_CURRENT_EFFECTIVE_START_DATE -1),&LAST_COLLECTION)';

/* for rolling and balance */
g_inlist_rlx            constant number        := 8; -- Bit 3
g_inlist_bal            constant number        := 16; -- Bit 4


PROCEDURE process_parameters (
    p_param                     IN         bis_pmv_page_parameter_tbl
  , p_trend                     IN         VARCHAR2
  , p_func_area                 IN         VARCHAR2
  , p_version                   IN         VARCHAR2
  , p_mv_set                    IN         VARCHAR2 /*-- ITM/OTM/ECM --*/
  , p_where_clause              OUT NOCOPY VARCHAR2
  , p_mv                        OUT NOCOPY VARCHAR2
  , p_join_tbl                  OUT NOCOPY poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_comp_type                 OUT NOCOPY VARCHAR2
  , p_xtd                        OUT NOCOPY VARCHAR2
  , p_view_by_select		OUT	   NOCOPY VARCHAR2
  , p_view_by			OUT NOCOPY VARCHAR2
  );


PROCEDURE get_bind_vars (
    x_custom_output             IN OUT NOCOPY bis_query_attributes_tbl
  , p_func_area			IN VARCHAR2);

FUNCTION get_orr_views RETURN VARCHAR2;

FUNCTION status_sql_daylevel (
    p_fact_name                 IN       VARCHAR2
  , p_row_type_where_clause              IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_time_type                 IN       VARCHAR2 default 'ESD'
  , p_union                     IN       VARCHAR2 default 'ALL'
   )
    RETURN VARCHAR2;

FUNCTION GET_DIVIDED_MEASURE (
    p_percentage VARCHAR2
	, p_num VARCHAR2
	, p_denom VARCHAR2
	, p_measurecol VARCHAR2
	, p_pnum VARCHAR2:=NULL
	, p_pdenom VARCHAR2:=NULL
	, p_totalcol VARCHAR2:=NULL
	, p_changecol VARCHAR2:=NULL
	, p_changetotalcol VARCHAR2:=NULL
	, p_convunitfordenom VARCHAR2:=NULL
) RETURN VARCHAR2;

FUNCTION GET_PERTOTAL_MEASURE (
p_num VARCHAR2,
p_measurecol VARCHAR2
) RETURN VARCHAR2;

FUNCTION GET_DEVAVG_MEASURE (
p_percentage VARCHAR2,
p_num VARCHAR2,
p_denom VARCHAR2,
p_col VARCHAR2,
p_convunitfordenom VARCHAR2:=NULL
) RETURN VARCHAR2;

FUNCTION GET_SIMPLE_MEASURE (
    p_curr VARCHAR2
	, p_measurecol VARCHAR2
	, p_prev VARCHAR2:=NULL
	, p_totalcol VARCHAR2:=NULL
	, p_changecol VARCHAR2:=NULL
	, p_changetotalcol VARCHAR2:=NULL
	, p_convertunit VARCHAR2:=NULL
) RETURN VARCHAR2;

FUNCTION TREND_SQL (
    p_xtd                       IN       VARCHAR2
  , p_comparison_type           IN       VARCHAR2
  , p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_use_grpid                 IN       VARCHAR2 := 'Y'
  , p_in_join_tables            IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_fact_hint 		        IN	 VARCHAR2 := null
  , p_union_clause              IN       VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;

FUNCTION GET_CONTINUED_MEASURES(
      p_bix_col_tab        IN OUT NOCOPY poa_dbi_util_pkg.poa_dbi_col_tbl,
      p_where_clause       IN OUT NOCOPY VARCHAR2,
      p_xtd                IN  VARCHAR2,
      p_comparison_type    IN  VARCHAR2,
      p_mv_set             IN  VARCHAR2
    ) RETURN VARCHAR2;

PROCEDURE get_emc_page_params (
	p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL
	, l_as_of_date              OUT NOCOPY DATE
	, l_period_type             OUT NOCOPY VARCHAR2
	, l_record_type_id          OUT NOCOPY NUMBER
	, l_comp_type               OUT NOCOPY VARCHAR2
	, l_account                 OUT NOCOPY VARCHAR2
	, l_classification          OUT NOCOPY VARCHAR2
	, l_view_by                 OUT NOCOPY VARCHAR2);


FUNCTION period_start_date(
l_as_of_date IN DATE
, l_period_type IN VARCHAR2 ) RETURN DATE;

FUNCTION GET_DEFAULT_PARAMS RETURN VARCHAR2;

PROCEDURE get_ai_page_params (
	p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL
	, l_as_of_date              OUT NOCOPY DATE
	, l_period_type             OUT NOCOPY VARCHAR2
	, l_record_type_id          OUT NOCOPY NUMBER
	, l_comp_type               OUT NOCOPY VARCHAR2
	, l_call_center             OUT NOCOPY VARCHAR2
	, l_classification          OUT NOCOPY VARCHAR2
	, l_dnis                    OUT NOCOPY VARCHAR2
	, l_view_by                 OUT NOCOPY VARCHAR2);

FUNCTION GET_AI_DEFAULT_PAGE_PARAMS RETURN VARCHAR2;


PROCEDURE GET_AO_PAGE_PARAMS (
	p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL
	, l_as_of_date              OUT NOCOPY DATE
	, l_period_type             OUT NOCOPY VARCHAR2
	, l_record_type_id          OUT NOCOPY NUMBER
	, l_comp_type               OUT NOCOPY VARCHAR2
	, l_call_center             OUT NOCOPY VARCHAR2
	, l_campaign_id             OUT NOCOPY VARCHAR2
	, l_schedule_id             OUT NOCOPY VARCHAR2
	, l_source_code_id          OUT NOCOPY VARCHAR2
	, l_agent_group             OUT NOCOPY VARCHAR2
	, l_view_by                 OUT NOCOPY VARCHAR2) ;



FUNCTION GET_AO_DEFAULT_PAGE_PARAMS RETURN VARCHAR2;

END  BIX_PMV_DBI_utl_pkg;

 

/
