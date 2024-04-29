--------------------------------------------------------
--  DDL for Package Body BIX_PMV_DBI_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_DBI_UTL_PKG" AS
/*$Header: bixdutlb.plb 120.1 2006/03/28 22:48:36 pubalasu noship $ */

g_dnis			VARCHAR2(3000);
g_agent_group       VARCHAR2(3000);

FUNCTION get_table (
    dim_name                             VARCHAR2
  , p_version                   IN       VARCHAR2
  ) RETURN VARCHAR2;

FUNCTION get_col_name (
    dim_name                    IN       VARCHAR2
  , mv_set                      IN       VARCHAR2
  , p_version                   IN       VARCHAR2
  ) RETURN VARCHAR2;

PROCEDURE get_join_info (
    p_view_by                   IN       VARCHAR2
  , p_dim_map                   IN       poa_dbi_util_pkg.poa_dbi_dim_map
  , x_join_tbl                  OUT NOCOPY poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2);

PROCEDURE init_dim_map (
    p_dim_map                   OUT NOCOPY poa_dbi_util_pkg.poa_dbi_dim_map
  , p_mv_set                    IN       VARCHAR2
  , p_version                   IN       VARCHAR2/*keep this for extensibility */);


FUNCTION get_viewby_select_clause (
    p_view_by                    IN       VARCHAR2
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2)
    RETURN VARCHAR2 ;

FUNCTION get_row_type_where_clauses(
    p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2
  , p_mv_set                    IN       VARCHAR2
 )     RETURN VARCHAR2 ;

FUNCTION get_mv (
     p_mv_set                    IN       VARCHAR2
   , p_version                   IN       VARCHAR2 /*Retained for extensibility*/)  RETURN VARCHAR2;

FUNCTION get_dnis_where_clause(p_page_parameter_tbl IN bis_pmv_page_parameter_tbl) RETURN VARCHAR2;

FUNCTION get_agent_group_where_clause(p_page_parameter_tbl IN bis_pmv_page_parameter_tbl,
                                      p_mv_set IN VARCHAR2
                                     ) RETURN VARCHAR2;
FUNCTION get_outcome_filter_clause RETURN VARCHAR2;

PROCEDURE process_parameters (
    p_param                     IN      bis_pmv_page_parameter_tbl
  , p_trend                     IN      VARCHAR2
  , p_func_area                 IN      VARCHAR2
  , p_version                   IN      VARCHAR2
  , p_mv_set                    IN      VARCHAR2 --ITM/OTM/ECM
  , p_where_clause              OUT NOCOPY VARCHAR2
  , p_mv                        OUT NOCOPY VARCHAR2
  , p_join_tbl                  OUT NOCOPY poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_comp_type                 OUT NOCOPY VARCHAR2 --001
  , p_xtd                       OUT NOCOPY VARCHAR2 --001
  , p_view_by_select		OUT NOCOPY VARCHAR2
  , p_view_by			OUT NOCOPY VARCHAR2
  )
  IS


    l_dim_map    poa_dbi_util_pkg.poa_dbi_dim_map;

    -- As of now, these are not passed as out params
    l_dim_bmap		NUMBER;
    p_comparison_type	VARCHAR2(1);
    p_as_of_date	DATE;
    p_prev_as_of_date	DATE;
    p_cur_suffix	VARCHAR2 (2);
    p_nested_pattern	NUMBER;


  BEGIN


   l_dim_bmap        := 0;

    /* --
	poa's procedure to retrieve the parameter values requires as input
    amongst others, a table of dimension details.Init_dim_map initializes the same
	-- */

   --
   --If mv set = SES then not all dimensions would be used to filter
   --for example, classification and dnis would not be used to filter out the rows
   --this is taken care of in init_dim_map
   --
       init_dim_map (l_dim_map, p_mv_set,p_version);
       p_mv              := get_mv (p_mv_set,p_version);


       poa_dbi_util_pkg.get_parameter_values (
                                           p_param
                                         , l_dim_map
                                         , p_view_by
                                         , p_comparison_type
                                         , p_xtd
                                         , p_as_of_date
                                         , p_prev_as_of_date
                                         , p_cur_suffix
                                         , p_nested_pattern
                                         , l_dim_bmap);

  p_comp_type :=  p_comparison_type;

/*
insert into bix_debug values
( 'p_view_by:' || p_view_by ||
'p_comparison_type:' || p_comparison_type ||
'p_xtd:' || p_xtd ||
'p_as_of_date:' || p_as_of_date ||
'p_prev_as_of_date:' || p_prev_as_of_date ||
'p_nested_pattern:' || p_nested_pattern
);
*/

       /* Get the filter where clause [value of the dimensions selected ] and
	   concatenate it with the where clause with row_type*/

	   IF p_mv_set='SES' THEN
		p_where_clause   :=poa_dbi_util_pkg.get_where_clauses (l_dim_map, p_trend)
		||get_agent_group_where_clause(p_param,p_mv_set)||' and application_id=696';
       ELSIF p_func_area = 'IORRR' THEN
       p_where_clause    :=  poa_dbi_util_pkg.get_where_clauses (l_dim_map, p_trend)
       ||get_dnis_where_clause(p_param)
       ||get_agent_group_where_clause(p_param,p_mv_set)
       ||get_row_type_where_clauses( p_func_area, p_version, p_mv_set)
       ||get_outcome_filter_clause();
       ELSE
	   p_where_clause    :=  poa_dbi_util_pkg.get_where_clauses (l_dim_map, p_trend)
       ||get_dnis_where_clause(p_param)
       ||get_agent_group_where_clause(p_param,p_mv_set)
       ||get_row_type_where_clauses( p_func_area, p_version, p_mv_set);
       END IF;
	    IF p_trend <> 'Y' THEN /* For Trend portlets, get join info and  view by select is not necessary */
	       get_join_info (p_view_by
                    , l_dim_map
                    , p_join_tbl
                    , p_func_area
                    , p_version);
	        p_view_by_select := get_viewby_select_clause(p_view_by,p_func_area,p_version);
            END IF;


EXCEPTION WHEN OTHERS THEN
RAISE;
END process_parameters;

FUNCTION get_orr_views RETURN VARCHAR2
IS
BEGIN
/* pubalasu: p_insetclause can be any where condition to insert
before the order by clause
*/
RETURN '    jtf_ih_outcomes_vl outcome,jtf_ih_results_vl result,jtf_ih_reasons_vl reason
            WHERE oset.outcome_id = outcome.outcome_id(+)
            AND   oset.result_id  = result.result_id(+)
            AND   oset.reason_id  = reason.reason_id(+)
            order by outcome.outcome_code,result.result_code,reason.reason_code
            ' ;
END get_orr_views;

/* -----------------------------------------------------------------------------
get_row_type_where_clauses: Where clauses for row_type
----------------------------------------------------------------------------- */
 FUNCTION get_row_type_where_clauses (
    p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2
  , p_mv_set                    IN       VARCHAR2
)    RETURN VARCHAR2
  IS
    l_sec_where_clause     VARCHAR2 (1000) := '';
  BEGIN

    l_sec_where_clause := 'and row_type=';
	l_sec_where_clause := l_sec_where_clause ||(CASE p_mv_set
         WHEN 'ECM'
           THEN ''
         WHEN 'ITM'
           THEN
		   (  CASE p_func_area
		         WHEN 'ICSTR' THEN '''CDPR''' /* Telephony Activity by Customer Report */
				 WHEN 'ITATR' THEN '''CDPR''' /* Telephony Activity Report */
				 WHEN 'ICMTP' THEN '''CDR''' /* Calls by media type graph */
				 WHEN 'ITMAT' THEN '''CDR''' /* Abandon Rate graph */
				 WHEN 'IOUTP' THEN '''CDR''' /* Outcomes graph */
				 WHEN 'IAGTR' THEN '''CDR''' /* Inbound Telephony by agent report */
 				 WHEN 'IORRR' THEN '''CORR''' /* Inbound Telephony by agent report */
				 ELSE '''C'''
			  END
		   )
 	     WHEN 'SES' THEN '''CDR''' /* Inbound Telephony by agent report */
         WHEN 'OTM'
           THEN ''
         ELSE ''
     END
   );

    RETURN l_sec_where_clause;
  END get_row_type_where_clauses;
/* -----------------------------------------------------------------------------
get_dnis_where_clause:Determines if DNIS is selected and creates a where clause
accordingly
----------------------------------------------------------------------------- */
 FUNCTION get_dnis_where_clause(p_page_parameter_tbl IN bis_pmv_page_parameter_tbl) RETURN VARCHAR2
 IS
 l_dnis varchar2(3000);
 l_where_clause varchar2(1000);
 BEGIN


  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
	  IF p_page_parameter_tbl(i).parameter_name= 'BIX_TELEPHONY+BIX_DNIS'
	  THEN
		l_dnis := p_page_parameter_tbl(i).parameter_id;
       END IF;
     END LOOP;
    END IF;

	IF l_dnis IS NOT NULL THEN
		IF l_dnis = '''INBOUND''' THEN
			l_where_clause :=' AND fact.dnis_name <> ''OUTBOUND'' ';
		ELSIF l_dnis = '''OUTBOUND''' THEN
			l_where_clause := ' AND fact.dnis_name = ''OUTBOUND'' ';
	    ELSE
		  l_where_clause := ' AND fact.dnis_name IN (to_char(:l_dnis)) ';
	    END IF;
	END IF;
	g_dnis:=l_dnis;
	RETURN l_where_clause;
END get_dnis_where_clause;

/* -----------------------------------------------------------------------------
get_agent_group_where_clause:Determines if agent group is selected and creates a where clause
accordingly
----------------------------------------------------------------------------- */
 FUNCTION get_agent_group_where_clause(
                                      p_page_parameter_tbl IN bis_pmv_page_parameter_tbl,
                                      p_mv_set IN varchar2
                                      ) RETURN VARCHAR2
 IS
 l_agent_group varchar2(3000);
 l_where_clause varchar2(1000);
 BEGIN


  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
	  IF p_page_parameter_tbl(i).parameter_name= 'ORGANIZATION+JTF_ORG_SUPPORT_GROUP'
	  THEN
		l_agent_group := p_page_parameter_tbl(i).parameter_id;
       END IF;
     END LOOP;
    END IF;

	IF l_agent_group IS NOT NULL THEN
           IF p_mv_set = 'SES'
           THEN
              l_where_clause := ' AND EXISTS (
                                              SELECT 1
                                              FROM   jtf_rs_group_members mem
                                              WHERE  fact.agent_id = mem.resource_id
                                              AND    mem.group_id IN (:l_agent_group)
                                              AND    nvl(mem.delete_flag, ''N'') <> ''Y''
                                              )';

           ELSE
              l_where_clause := ' AND EXISTS (
                                              SELECT 1
                                              FROM   jtf_rs_group_members mem
                                              WHERE  fact.resource_id = mem.resource_id
                                              AND    mem.group_id IN (:l_agent_group)
                                              AND    nvl(mem.delete_flag, ''N'') <> ''Y''
                                              )';
           END IF;

	END IF;

	g_agent_group := l_agent_group;

	RETURN l_where_clause;

END get_agent_group_where_clause;

/* -----------------------------------------------------------------------------
get_outcome_filter_clause:Simple function to return the filter clause for ORR reports
----------------------------------------------------------------------------- */

FUNCTION get_outcome_filter_clause  RETURN VARCHAR2
IS
BEGIN
 RETURN 'and fact.outcome_id <> :l_outcome_filter';
END get_outcome_filter_clause;



/* -----------------------------------------------------------------------------
get_mv:Simple function to return the mv name based on the mv_set name
----------------------------------------------------------------------------- */
  FUNCTION get_mv (
     p_mv_set                    IN       VARCHAR2
   , p_version                   IN       VARCHAR2 /*Retained for extensibility*/)
    RETURN VARCHAR2
  IS
  l_mv_name varchar2(100);
  BEGIN

  l_mv_name:=
  (CASE p_mv_set
         WHEN 'ECM'
           THEN 'BIX_EMAIL_DETAILS_MV'
         WHEN 'ITM'
           THEN 'BIX_AI_CALL_DETAILS_MV'
         WHEN 'OTM'
           THEN 'BIX_AO_CALL_DETAILS_MV'
         WHEN 'SES'
           THEN 'BIX_AGENT_SESSION_F'
         ELSE ''
     END
   );
   return l_mv_name;
   EXCEPTION
   WHEN OTHERS THEN
    RAISE;
  END get_mv;


/* -----------------------------------------------------------------------------
init_dim_map: Initialize the dimension mapping for BIX.
The dimensions are populated depending on the mv set (ie) ECM,ITM,OTM
----------------------------------------------------------------------------- */
 PROCEDURE init_dim_map (
    p_dim_map                   OUT NOCOPY poa_dbi_util_pkg.poa_dbi_dim_map
  , p_mv_set                    IN       VARCHAR2
  , p_version                   IN       VARCHAR2/*keep this for extensibility */)
  IS
    l_dim_rec   poa_dbi_util_pkg.poa_dbi_dim_rec;
  BEGIN
 IF P_MV_SET='ECM' THEN
     -- Email Account Dimension

    l_dim_rec.generate_where_clause    := 'Y';
    l_dim_rec.col_name                 := get_col_name (dim_name    => g_email_accnt_dim
                                                        , mv_set      => p_mv_set
                                                        , p_version => p_version);
    l_dim_rec.view_by_table            := get_table (dim_name       => g_email_accnt_dim
                                                     , p_version    => p_version);
    l_dim_rec.bmap                     := 0;
    p_dim_map (g_email_accnt_dim)    := l_dim_rec;


    -- Email Classification Dimension

    l_dim_rec.generate_where_clause    := 'Y';
    l_dim_rec.col_name                 := get_col_name (dim_name    => g_email_class_dim
                                                        , mv_set      => p_mv_set
                                                        , p_version => p_version);
    l_dim_rec.view_by_table            := get_table (dim_name       => g_email_class_dim
                                                     , p_version    => p_version);
    l_dim_rec.bmap                     := 0;
    p_dim_map (g_email_class_dim)    := l_dim_rec;
ELSIF P_MV_SET='ITM' THEN

	 -- Call Center Dimension

    l_dim_rec.generate_where_clause    := 'Y';
    l_dim_rec.col_name                 := get_col_name (dim_name    => g_ai_ccntr_dim
                                                        , mv_set      => p_mv_set
                                                        , p_version => p_version);
    l_dim_rec.view_by_table            := get_table (dim_name       => g_ai_ccntr_dim
                                                     , p_version    => p_version);
    l_dim_rec.bmap                     := 0;
    p_dim_map (g_ai_ccntr_dim)    := l_dim_rec;


    -- Call Classification Dimension

    l_dim_rec.generate_where_clause    := 'Y';
    l_dim_rec.col_name                 := get_col_name (dim_name    => g_ai_class_dim
                                                        , mv_set      => p_mv_set
                                                        , p_version => p_version);
    l_dim_rec.view_by_table            := get_table (dim_name       => g_ai_class_dim
                                                     , p_version    => p_version);
    l_dim_rec.bmap                     := 0;
    p_dim_map (g_ai_class_dim)    := l_dim_rec;

    -- DNIS Dimension
    /********************
	   In DNIS Dimension ,when 'All Customer Dialed' is chosen from the dropdown, it
	   translates to dnis_name <> 'OUTBOUND' in the where clause. So, we dont
	   generate the where clause using the POA util package
    ********************/

    l_dim_rec.generate_where_clause    := 'N';
    l_dim_rec.col_name                 := get_col_name (dim_name    => g_ai_dnis_dim
                                                        , mv_set      => p_mv_set
                                                        , p_version => p_version);
    l_dim_rec.view_by_table            := get_table (dim_name       => g_ai_dnis_dim
                                                     , p_version    => p_version);
    l_dim_rec.bmap                     := 0;
    p_dim_map (g_ai_dnis_dim)    := l_dim_rec;

    -- Agent Group Dimension
    /********************
           For Agent Group dimension we need a special where clause with a EXISTS clause.
  	   So, we do not generate the where clause using the POA util package
    ********************/

    l_dim_rec.generate_where_clause    := 'N';
    l_dim_rec.col_name                 := get_col_name (dim_name    => g_agent_group_dim
                                                        , mv_set      => p_mv_set
                                                        , p_version => p_version);
    l_dim_rec.view_by_table            := get_table (dim_name       => g_agent_group_dim
                                                     , p_version    => p_version);
    l_dim_rec.bmap                     := 0;
    p_dim_map (g_agent_group_dim)    := l_dim_rec;

	-- Customer Pseudo Dimension

    l_dim_rec.generate_where_clause    := 'N';
    l_dim_rec.col_name                 := get_col_name (dim_name    => g_ai_custm_dim
                                                        , mv_set      => p_mv_set
                                                        , p_version => p_version);
    l_dim_rec.view_by_table            := get_table (dim_name       => g_ai_custm_dim
                                                     , p_version    => p_version);
    l_dim_rec.bmap                     := 0;
    p_dim_map (g_ai_custm_dim)    := l_dim_rec;

ELSIF P_MV_SET='SES' THEN


	 -- Call Center Dimension

    l_dim_rec.generate_where_clause    := 'Y';
    l_dim_rec.col_name                 := get_col_name (dim_name    => g_ai_ccntr_dim
                                                        , mv_set      => p_mv_set
                                                        , p_version => p_version);
    l_dim_rec.view_by_table            := get_table (dim_name       => g_ai_ccntr_dim
                                                     , p_version    => p_version);
    l_dim_rec.bmap                     := 0;
    p_dim_map (g_ai_ccntr_dim)    := l_dim_rec;


    -- Agent Group Dimension
    /********************
           For Agent Group dimension we need a special where clause with a EXISTS clause.
  	   So, we do not generate the where clause using the POA util package
    ********************/

    l_dim_rec.generate_where_clause    := 'N';
    l_dim_rec.col_name                 := get_col_name (dim_name    => g_agent_group_dim
                                                        , mv_set      => p_mv_set
                                                        , p_version => p_version);
    l_dim_rec.view_by_table            := get_table (dim_name       => g_agent_group_dim
                                                     , p_version    => p_version);
    l_dim_rec.bmap                     := 0;
    p_dim_map (g_agent_group_dim)    := l_dim_rec;

	  -- Call Classification Dimension

    l_dim_rec.generate_where_clause    := 'N';
    l_dim_rec.col_name                 := get_col_name (dim_name    => g_ai_class_dim
                                                        , mv_set      => p_mv_set
                                                        , p_version => p_version);
    l_dim_rec.view_by_table            := get_table (dim_name       => g_ai_class_dim
                                                     , p_version    => p_version);
    l_dim_rec.bmap                     := 0;
    p_dim_map (g_ai_class_dim)    := l_dim_rec;

    -- DNIS Dimension
    /********************
	   In DNIS Dimension ,when 'All Customer Dialed' is chosen from the dropdown, it
	   translates to dnis_name <> 'OUTBOUND' in the where clause. So, we dont
	   generate the where clause using the POA util package
    ********************/

    l_dim_rec.generate_where_clause    := 'N';
    l_dim_rec.col_name                 := get_col_name (dim_name    => g_ai_dnis_dim
                                                        , mv_set      => p_mv_set
                                                        , p_version => p_version);
    l_dim_rec.view_by_table            := get_table (dim_name       => g_ai_dnis_dim
                                                     , p_version    => p_version);
    l_dim_rec.bmap                     := 0;
    p_dim_map (g_ai_dnis_dim)    := l_dim_rec;

END IF;

   EXCEPTION
   WHEN OTHERS THEN
    RAISE;

  END init_dim_map;

/* -----------------------------------------------------------------------------
get_col_name: Returns the column name in the MV that is associated with the
dimension.
----------------------------------------------------------------------------- */
  FUNCTION get_col_name (
    dim_name                    IN       VARCHAR2
  , mv_set                      IN       VARCHAR2
  , p_version                   IN       VARCHAR2
  )
    RETURN VARCHAR2
  IS
    l_col_name   VARCHAR2 (100);
  BEGIN
    l_col_name    :=
      (CASE dim_name
         WHEN g_email_accnt_dim
           THEN 'email_account_id'
         WHEN g_email_class_dim
           THEN 'email_classification_id'
         WHEN g_ai_ccntr_dim
           THEN 'server_group_id'
         WHEN g_ai_class_dim
           THEN 'classification_value'
         WHEN g_ai_dnis_dim
           THEN 'dnis_name'
         WHEN g_agent_group_dim
	      THEN
              (CASE mv_set
              WHEN 'SES'
              THEN 'agent_id'
              ELSE 'resource_id'
              END)
         WHEN g_ai_custm_dim
           THEN 'party_id'
         ELSE ''
       END);

    RETURN l_col_name;
  END;

/* -----------------------------------------------------------------------------
get_table : Returns the name of the object to join to to which the MV is joined to
----------------------------------------------------------------------------- */
  FUNCTION get_table (
    dim_name                             VARCHAR2
  , p_version                   IN       VARCHAR2)
    RETURN VARCHAR2
  IS
    l_table   VARCHAR2 (4000);
  BEGIN
    l_table    :=
                 (
                  CASE dim_name
                  WHEN g_email_accnt_dim
                     THEN 'BIX_EMAIL_ACCOUNTS_V'
                  WHEN g_email_class_dim
                     THEN 'BIX_EMAIL_CLASSIFICATIONS_V'
                  WHEN g_ai_ccntr_dim
                     THEN 'IEO_SVR_GROUPS'
                  WHEN g_ai_custm_dim
                     THEN 'HZ_PARTIES'
                  WHEN g_agent_group_dim
                     THEN 'JTF_RS_RESOURCE_EXTNS_VL'
                  ELSE
                     '(Select dummy from dual)'
                  END
                  );

    RETURN l_table;
  END get_table;

/* -----------------------------------------------------------------------------
get_join_info : Returns the join clause to join the view by table with dimension views
----------------------------------------------------------------------------- */

PROCEDURE get_join_info (
    p_view_by                   IN       VARCHAR2
  , p_dim_map                   IN       poa_dbi_util_pkg.poa_dbi_dim_map
  , x_join_tbl                  OUT NOCOPY poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2)
  IS
    l_join_rec   poa_dbi_util_pkg.poa_dbi_join_rec;
	l_view_by    VARCHAR2(120);
  BEGIN


    x_join_tbl                       := poa_dbi_util_pkg.poa_dbi_join_tbl ();
/*
For some of ICI reports, there is no view by clause, but we do join to some other tables like hz_parties
to get customer names.
*/

IF (p_func_area='ICSTR')
THEN
   l_view_by:=g_ai_custm_dim;
   l_join_rec.column_name    := 'party_id(+) group by nvl(party_name,:l_unknown)';
ELSIF (p_func_area='ITATR') AND p_view_by=g_ai_ccntr_dim
THEN
   l_view_by:=p_view_by;
   l_join_rec.column_name    := 'server_group_id group by v.group_name,v.server_group_id';
ELSIF (p_func_area='IAGTR')  --agent activity report
THEN
   l_view_by := g_agent_group_dim;
   l_join_rec.column_name    := 'resource_id group by resource_name ';
ELSE
   l_view_by:=p_view_by;
   l_join_rec.column_name    := 'id';
END IF;

/* For ORR report, we cannot default view by dimension coz it is joining to 3 tables */

IF l_view_by IN (g_ai_custm_dim,g_ai_ccntr_dim,g_ai_class_dim,g_ai_dnis_dim,g_agent_group_dim)
AND (p_func_area<>'IORRR')
THEN

    l_join_rec.table_name            := p_dim_map (l_view_by).view_by_table;
    l_join_rec.table_alias           := 'v';
    l_join_rec.fact_column           := p_dim_map (l_view_by).col_name;

    x_join_tbl.EXTEND;
    x_join_tbl (x_join_tbl.COUNT)    := l_join_rec;
ELSIF p_func_area='IORRR' THEN
   l_join_rec.table_name            := '';
   l_join_rec.table_alias           := '';
   l_join_rec.fact_column           := 'outcome_id,result_id,reason_id';
   l_join_rec.column_name		    := '';

   x_join_tbl.EXTEND;
   x_join_tbl (x_join_tbl.COUNT)    := l_join_rec;

ELSE

   l_join_rec.table_name            := '';
   l_join_rec.table_alias           := '';
   l_join_rec.fact_column           := 'media_item_type';
   l_join_rec.column_name		    := '';

   x_join_tbl.EXTEND;
   x_join_tbl (x_join_tbl.COUNT)    := l_join_rec;

END IF;



  EXCEPTION
   WHEN OTHERS THEN
   RAISE;

END get_join_info;
/* -----------------------------------------------------------------------------
get_viewby_select_clause:returns select clause for view by
----------------------------------------------------------------------------- */
 FUNCTION get_viewby_select_clause (
    p_view_by                    IN       VARCHAR2
  , p_func_area                 IN       VARCHAR2
  , p_version                   IN       VARCHAR2)
    RETURN VARCHAR2
  IS
  l_view_by_select VARCHAR2(1000);
  BEGIN
      l_view_by_select:='SELECT '||
		(CASE p_view_by
		WHEN g_ai_ccntr_dim
           THEN 'v.group_name VIEWBY,v.server_group_id VIEWBYID '
		WHEN g_ai_dnis_dim
           THEN 'dnis_name VIEWBY,dnis_name VIEWBYID '
		WHEN g_ai_class_dim
           THEN 'classification_value VIEWBY,classification_value VIEWBYID '
        ELSE
		   'v.value VIEWBY,v.id VIEWBYID '
	   END);

      RETURN l_view_by_select;
  END;
/* -----------------------------------------------------------------------------
Status_sql_daylevel for ECM backlog measure and AI continued measure wherein
no join to time table is required. .Cross verify if such a thing does not exist in POA already.
----------------------------------------------------------------------------- */
FUNCTION status_sql_daylevel (
    p_fact_name                 IN       VARCHAR2
  , p_row_type_where_clause              IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_join_tables               IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_time_type                 IN       VARCHAR2 default 'ESD'
  , p_union                     IN       VARCHAR2 default 'ALL'
   )
    RETURN VARCHAR2
  IS
  /* Pass ESD OR AOD for p_time_type, for the where clause to choose
  Effective Start Date or As of Date.If both of them are the same, remove this clause.Verify.
  */
    l_query					VARCHAR2 (10000);
    l_col_names				VARCHAR2 (10000);
    l_group_and_sel_clause	VARCHAR2 (10000);
    l_c_calc_end_date		VARCHAR2 (70);
    l_p_calc_end_date		VARCHAR2 (70);
    l_date_decode_begin		VARCHAR2 (1000);
    l_date_decode_end		VARCHAR2(1000);
    l_cur_date_clause 		VARCHAR2(500);
    l_prev_date_clause		VARCHAR2(500);
    l_full_where_clause     VARCHAR2 (10000);


 BEGIN
    --the dimension column name
    l_group_and_sel_clause    := ' fact.' || p_join_tables (1).fact_column;

    IF P_TIME_TYPE='ESD' THEN
	    l_c_calc_end_date    := 'TO_NUMBER(TO_CHAR('||g_c_period_start_date||',''J''))';
	    l_p_calc_end_date    := 'TO_NUMBER(TO_CHAR('||g_p_period_start_date||',''J''))';
    ELSE
	    l_c_calc_end_date    := 'TO_NUMBER(TO_CHAR('||g_c_as_of_date||',''J''))';
	    l_p_calc_end_date    := 'TO_NUMBER(TO_CHAR('||g_p_as_of_date||',''J''))';
    END IF;

    FOR i IN 1 .. p_col_name.COUNT
    LOOP


      IF p_col_name(i).to_date_type='XTD' then

     IF (p_col_name(i).column_name='NULL') THEN
		l_date_decode_begin	:= NULL;
	    l_cur_date_clause	:= NULL;
	    l_prev_date_clause	:= NULL;
		l_date_decode_end	:= NULL;

	   l_col_names    :=
            l_col_names
            || ',NULL c_'|| p_col_name (i).column_alias
            || fnd_global.newline;

     ELSE
	    l_date_decode_begin	:= 'decode(fact.time_id,';
	    l_cur_date_clause	:=  l_c_calc_end_date  || ',';
	    l_prev_date_clause	:= l_p_calc_end_date  || ',';
		l_date_decode_end	:= ',null)';

	   l_col_names    :=
            l_col_names
            || ',sum('
	    || l_date_decode_begin
	    ||l_cur_date_clause
            || p_col_name (i).column_name
	    || l_date_decode_end
            || ') c_'
            || p_col_name (i).column_alias
            || fnd_global.newline;

     END IF;
      -- Regular current column
      -- Prev column (based on prior_code)


      IF (p_col_name (i).prior_code <> poa_dbi_util_pkg.no_priors)
      THEN

		   IF (p_col_name(i).column_name='NULL') THEN
				l_col_names:=
				l_col_names
				|| ',NULL p_'|| p_col_name (i).column_alias
				|| fnd_global.newline;

		  ELSE
				l_col_names        :=
					  l_col_names
				   || ', sum('
			   || l_date_decode_begin
			   || l_prev_date_clause
				   || p_col_name (i).column_name
			   || l_date_decode_end
				   || ') p_'
				   || p_col_name (i).column_alias
				   || fnd_global.newline;
		  END IF;
      END IF;

      -- If grand total is flagged, do current and prior grand totals
      IF (p_col_name (i).grand_total = 'Y')
      THEN
             -- Sum of current column
             l_col_names    :=
                 l_col_names
		 || ', sum(sum('
		 || l_date_decode_begin
  		 || l_cur_date_clause
                 || p_col_name (i).column_name
		 || l_date_decode_end
	         || ')) over () c_'
              || p_col_name (i).column_alias
              || '_total'
	      || fnd_global.newline;

        -- Sum of prev column (based on prior_code flagging)
        IF (   p_col_name (i).prior_code = poa_dbi_util_pkg.both_priors
            OR p_col_name(i).prior_code = poa_dbi_util_pkg.prev_prev
            OR p_col_name(i).prior_code = poa_dbi_util_pkg.OPENING_PRIOR_CURR )
        THEN
          l_col_names    :=
                l_col_names
		|| ', sum(sum('
		|| l_date_decode_begin
		|| l_prev_date_clause
                || p_col_name (i).column_name
		|| l_date_decode_end
             	|| ')) over () p_'
                || p_col_name (i).column_alias
                || '_total'
		|| fnd_global.newline;
        END IF;


      END IF;
      END IF;
    END LOOP;
    l_full_where_clause   := ' WHERE time_id IN ('||l_c_calc_end_date||','||l_p_calc_end_date||') and period_type_id=1 '||p_row_type_where_clause;

l_query                   :=
          '(select '
       || l_group_and_sel_clause
       || l_col_names
       || '
from '
       || p_fact_name
       || ' fact'
       || l_full_where_clause
       || '
group by '
       || l_group_and_sel_clause
       || ')';

IF p_union='ALL' then
    l_query := l_query||' UNION ALL ';
END IF;

RETURN l_query;

END status_sql_daylevel;
/* -----------------------------------------------------------------------------------------
Get Bind Vars. Pasees values for  bind variables that are used in the front end query, back to PMV.
Has to be customized based on the report [p_func_area]
-------------------------------------------------------------------------------------------- */
PROCEDURE get_bind_vars (
    x_custom_output             IN OUT NOCOPY bis_query_attributes_tbl
  , p_func_area                 IN VARCHAR2)
IS
    l_custom_rec   bis_query_attributes;
	l_inbound VARCHAR2(50);
	l_webcall VARCHAR2(50);
	l_direct VARCHAR2(50);
	l_dialed VARCHAR2(50);
	l_unsolicited VARCHAR2(50);
	l_unknown VARCHAR2(50);

BEGIN
  l_custom_rec                               := bis_pmv_parameters_pub.initialize_query_type;
  IF p_func_area='ICSTR' THEN
		l_custom_rec.attribute_name                := ':l_unknown';
		l_custom_rec.attribute_value               := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_UNKNOWN');
		l_custom_rec.attribute_type                := bis_pmv_parameters_pub.bind_type;
		l_custom_rec.attribute_data_type           := bis_pmv_parameters_pub.varchar2_bind;
		x_custom_output.EXTEND;
		x_custom_output (x_custom_output.COUNT)    := l_custom_rec;
  END IF;
  IF p_func_area='IOUTP' THEN
		l_custom_rec.attribute_name                := ':l_lookup_type';
		l_custom_rec.attribute_value               := 'BIX_PMV_AI_OUTCOMES';
		l_custom_rec.attribute_type                := bis_pmv_parameters_pub.bind_type;
		l_custom_rec.attribute_data_type           := bis_pmv_parameters_pub.varchar2_bind;
		x_custom_output.EXTEND;
		x_custom_output (x_custom_output.COUNT)    := l_custom_rec;
  END IF;
  IF p_func_area='IORRR' THEN

      	l_unknown := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_UNKNOWN');

        IF l_unknown IS NULL OR l_unknown = 'BIX_PMV_UNKNOWN'
        THEN
           l_unknown := 'Unknown';
        END IF;

		l_custom_rec.attribute_name                := ':l_outcome_filter';
		l_custom_rec.attribute_value               := -1;
		l_custom_rec.attribute_type                := bis_pmv_parameters_pub.bind_type;
		l_custom_rec.attribute_data_type           := bis_pmv_parameters_pub.numeric_bind;
		x_custom_output.EXTEND;
		x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

		l_custom_rec.attribute_name                := ':l_unknown';
		l_custom_rec.attribute_value               := l_unknown;
		l_custom_rec.attribute_type                := bis_pmv_parameters_pub.bind_type;
		l_custom_rec.attribute_data_type           := bis_pmv_parameters_pub.varchar2_bind;
		x_custom_output.EXTEND;
		x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

  END IF;

  IF p_func_area='ICMTP' THEN

		l_inbound := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_AI_INBOUND');

		IF l_inbound IS NULL OR l_inbound = 'BIX_PMV_AI_INBOUND'
		THEN
		   l_inbound := 'Inbound';
		END IF;

		l_webcall := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_AI_WEBCALL');

		IF l_webcall IS NULL OR l_webcall = 'BIX_PMV_AI_WEBCALL'
		THEN
		   l_webcall := 'Web Callback';
		END IF;

		l_dialed := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_AI_DIALED');

		IF l_dialed IS NULL OR l_dialed = 'BIX_PMV_AI_DIALED'
		THEN
		   l_dialed := 'Agent Dialed';
		END IF;

		l_direct := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_AI_DIRECT');

		IF l_direct IS NULL OR l_direct = 'BIX_PMV_AI_DIRECT'
		THEN
		   l_direct := 'Direct Dialed';
		END IF;

		l_unsolicited := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_AI_UNSOLICITED');

		IF l_unsolicited IS NULL OR l_unsolicited = 'BIX_PMV_AI_UNSOLICITED'
		THEN
		   l_unsolicited := 'Unsolicited';
		END IF;

		l_custom_rec.attribute_name := ':l_inbound';
		l_custom_rec.attribute_value:= l_inbound;
		l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

		x_custom_output.Extend();
		x_custom_output(x_custom_output.count) := l_custom_rec;

		l_custom_rec.attribute_name := ':l_direct';
		l_custom_rec.attribute_value:= l_direct;
		l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

		x_custom_output.Extend();
		x_custom_output(x_custom_output.count) := l_custom_rec;

		l_custom_rec.attribute_name := ':l_dialed';
		l_custom_rec.attribute_value:= l_dialed;
		l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

		x_custom_output.Extend();
		x_custom_output(x_custom_output.count) := l_custom_rec;

		l_custom_rec.attribute_name := ':l_webcall';
		l_custom_rec.attribute_value:= l_webcall;
		l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

		x_custom_output.Extend();
		x_custom_output(x_custom_output.count) := l_custom_rec;

		l_custom_rec.attribute_name := ':l_unsolicited';
		l_custom_rec.attribute_value:= l_unsolicited;
		l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

		x_custom_output.Extend();
		x_custom_output(x_custom_output.count) := l_custom_rec;

  END IF;
  IF g_dnis is NOT NULL AND g_dnis NOT IN ('INBOUND','OUTBOUND') THEN
		l_custom_rec                               := bis_pmv_parameters_pub.initialize_query_type;
		l_custom_rec.attribute_name                := ':l_dnis';
		l_custom_rec.attribute_value               := g_dnis;
		l_custom_rec.attribute_type                := bis_pmv_parameters_pub.bind_type;
		l_custom_rec.attribute_data_type           := bis_pmv_parameters_pub.varchar2_bind;
		x_custom_output.EXTEND;
		x_custom_output (x_custom_output.COUNT)    := l_custom_rec;
  END IF;

  IF p_func_area='IAGTR' THEN
		l_custom_rec.attribute_name                := ':l_agent_group';
		l_custom_rec.attribute_value               := g_agent_group;
		l_custom_rec.attribute_type                := bis_pmv_parameters_pub.bind_type;
		l_custom_rec.attribute_data_type           := bis_pmv_parameters_pub.varchar2_bind;
		x_custom_output.EXTEND;
		x_custom_output (x_custom_output.COUNT)    := l_custom_rec;
  END IF;

  EXCEPTION
	WHEN OTHERS THEN
	RAISE;
END;
/* -----------------------------------------------------------------------------------------
Get Divided Measure ex: For a measure, if current value is a*100/(b+c)
and prior value is a1*100/(b1+c1)
p_num	->a
p_denom	->b+c
p_percentage->Y
p_pnum	->a1
p_pdenom->b1+c1
The others are attribute names

-------------------------------------------------------------------------------------------- */

FUNCTION GET_DIVIDED_MEASURE (
p_percentage VARCHAR2,
p_num VARCHAR2,
p_denom VARCHAR2,
p_measurecol VARCHAR2,
p_pnum VARCHAR2:=NULL,
p_pdenom VARCHAR2:=NULL,
p_totalcol VARCHAR2:=NULL,
p_changecol VARCHAR2:=NULL,
p_changetotalcol VARCHAR2:=NULL,
p_convunitfordenom VARCHAR2:=NULL
) RETURN VARCHAR2
IS
l_percentage VARCHAR2(4);
l_col_text VARCHAR2(2000);
l_curr_text VARCHAR2(1000);
l_prev_text VARCHAR2(1000);
l_prev_text_denom VARCHAR2(1000);
l_conv_text VARCHAR2(1000);

BEGIN

IF p_percentage='Y' THEN
 l_percentage:='*100';
END IF;


--This is if the measure needs to be converted between 2 time units
--say secs to hours for Login Time. p_convunitfordenom contains /3600

l_conv_text := ' ';
IF p_convunitfordenom IS NOT NULL THEN
    l_conv_text:=p_convunitfordenom||' ';
END IF;

--Current value
l_col_text:='SUM('||p_num||')'||l_percentage||'/DECODE(sum('||p_denom||')'||l_conv_text||',0,NULL,sum('||p_denom||')'||l_conv_text||') '||p_measurecol;

IF p_totalcol IS NOT NULL THEN
	--Total
	l_col_text:=l_col_text||','||'SUM(SUM('||p_num||')) over()'||l_percentage||'/DECODE(SUM(SUM('||p_denom||')) OVER()'||l_conv_text||',0,NULL,SUM(SUM('||p_denom||')) over()'||l_conv_text||') '||p_totalcol;
END IF;


IF p_changecol IS NOT NULL THEN
	IF p_percentage='Y' THEN
		--Change - absolute value ex: 80%-40%
		l_curr_text:='(SUM('||p_num||')'||l_percentage||'/DECODE(sum('||p_denom||'),0,NULL,sum('||p_denom||'))) ';
		l_prev_text:='(SUM('||p_pnum||')'||l_percentage||'/DECODE(sum('||p_pdenom||'),0,NULL,sum('||p_pdenom||'))) ';
		l_col_text:=l_col_text||', '||l_curr_text||'-'||l_prev_text||p_changecol;

		--Change Total - absolute value ex: 100%-120%
		l_curr_text:='(SUM(SUM('||p_num||')) over()'||l_percentage||'/DECODE(SUM(SUM('||p_denom||')) OVER(),0,NULL,SUM(SUM('||p_denom||')) over())) ';
		l_prev_text:='(SUM(SUM('||p_pnum||')) over()'||l_percentage||'/DECODE(SUM(SUM('||p_pdenom||')) OVER(),0,NULL,SUM(SUM('||p_pdenom||')) over())) ';

		l_col_text:=l_col_text||', '||l_curr_text||'-'||l_prev_text||p_changetotalcol;
	ELSE

		--Change - percentage value ex: 4 to 5 is 25%
		l_curr_text:='(SUM('||p_num||')'||l_percentage||'/DECODE(sum('||p_denom||'),0,NULL,sum('||p_denom||'))) ';
		l_prev_text:='(SUM('||p_pnum||')'||l_percentage||'/DECODE(sum('||p_pdenom||'),0,NULL,sum('||p_pdenom||'))) ';
		l_prev_text_denom:='DECODE('||l_prev_text||',0,NULL,'||l_prev_text||')';
		l_col_text:=l_col_text||',('||l_curr_text||'-'||l_prev_text||' )*100/'||l_prev_text_denom||p_changecol;
		--Change Total - percentage value ex: 4 to 5 is 25%
		l_curr_text:='(SUM(SUM('||p_num||')) over()'||l_percentage||'/DECODE(SUM(SUM('||p_denom||')) OVER(),0,NULL,SUM(SUM('||p_denom||')) over())) ';
		l_prev_text:='(SUM(SUM('||p_pnum||')) over()'||l_percentage||'/DECODE(SUM(SUM('||p_pdenom||')) OVER(),0,NULL,SUM(SUM('||p_pdenom||')) over())) ';
		l_prev_text_denom:='DECODE('||l_prev_text||',0,NULL,'||l_prev_text||')';
		l_col_text:=l_col_text||',('||l_curr_text||'-'||l_prev_text||' )*100/'||l_prev_text_denom||p_changetotalcol;
	END IF;

END IF;
RETURN l_col_text;

EXCEPTION
WHEN OTHERS THEN
RAISE;
END get_divided_measure;


/****START GET_PERTOTAL_MEASURE ****/

FUNCTION GET_PERTOTAL_MEASURE
(
p_num VARCHAR2,
p_measurecol VARCHAR2
) RETURN VARCHAR2
IS
l_col_text VARCHAR2(2000);

BEGIN


--Current value
l_col_text:='SUM('||p_num||')*100
             /DECODE(sum(sum('||p_num||')) over(),0,NULL,
               sum(sum('||p_num||')) over()) ' || p_measurecol ;


RETURN l_col_text;

EXCEPTION
WHEN OTHERS THEN
RAISE;
END get_pertotal_measure;

/****END GET_PERTOTAL_MEASURE ****/

/**** START GET_DEVAVG_MEASURE ***/

FUNCTION GET_DEVAVG_MEASURE
(
p_percentage VARCHAR2,
p_num VARCHAR2,
p_denom VARCHAR2,
p_col VARCHAR2,
p_convunitfordenom VARCHAR2:=NULL
) RETURN VARCHAR2
IS
l_percentage VARCHAR2(4);
l_col_text VARCHAR2(2000);
l_curr_text VARCHAR2(1000);
l_prev_text VARCHAR2(1000);
l_conv_text VARCHAR2(1000);
BEGIN


IF p_percentage='Y' THEN
 l_percentage:='*100';
END IF;

--This is if the measure needs to be converted between 2 time units
--say secs to hours for Login Time. p_convunitfordenom contains /3600

l_conv_text := ' ';
IF p_convunitfordenom IS NOT NULL THEN
    l_conv_text:=p_convunitfordenom||' ';
END IF;


--Current value
l_col_text:='SUM('||p_num||')'||l_percentage||'/DECODE(sum('||p_denom||')'||l_conv_text||',0,NULL,sum('||p_denom||')'||l_conv_text||')
             -
            SUM(SUM('||p_num||')) over()'||l_percentage||'/DECODE(sum(sum('||p_denom||')) over()'||l_conv_text||',0,NULL,
                                                                   sum(sum('||p_denom||')) over()'||l_conv_text||'
                                                                  ) ' || p_col ;


RETURN l_col_text;

EXCEPTION
WHEN OTHERS THEN
RAISE;
END get_devavg_measure;

/**** END GET_DEVAVG_MEASURES ***/

/* -----------------------------------------------------------------------------------------
Get Simple Measure ex: For a measure, if current value is a
and prior value is a1
p_curr	->a
p_prev	->a1
The others are attribute names


-------------------------------------------------------------------------------------------- */
FUNCTION GET_SIMPLE_MEASURE (
p_curr VARCHAR2,p_measurecol VARCHAR2,p_prev VARCHAR2:=NULL,p_totalcol VARCHAR2:=NULL,
p_changecol VARCHAR2:=NULL,p_changetotalcol VARCHAR2:=NULL,
p_convertunit VARCHAR2:=NULL
) RETURN VARCHAR2
IS

l_col_text VARCHAR2(2000);
l_curr_text VARCHAR2(1000);
l_prev_text VARCHAR2(1000);
l_conv_text VARCHAR2(1000);
BEGIN


--This is if the measure needs to be converted between 2 time units
--say secs to hours for Login Time. p_convertunit contains /3600
l_conv_text := ' ';
IF p_convertunit IS NOT NULL THEN
    l_conv_text:=p_convertunit||' ';
END IF;


--Current value
l_col_text:='SUM('||p_curr||')'||l_conv_text||' '||p_measurecol;

IF p_totalcol IS NOT NULL THEN
	--Total
	l_col_text:=l_col_text||','||'SUM(SUM('||p_curr||')) over()'||l_conv_text||p_totalcol;
END IF;

IF p_changecol IS NOT NULL THEN
	--Change - percentage value ex: 4 to 5 is 25%
	l_curr_text:='SUM('||p_curr||') ';
	l_prev_text:='SUM('||p_prev||') ';
	l_col_text:=l_col_text||',('||l_curr_text||'-'||l_prev_text||' )*100/DECODE('||l_prev_text||',0,NULL,'||l_prev_text||')'||p_changecol;
	--Change Total - percentage value ex: 4 to 5 is 25%
	l_curr_text:='SUM(SUM('||p_curr||')) over() ';
	l_prev_text:='SUM(SUM('||p_prev||')) over() ';
	l_col_text:=l_col_text||',('||l_curr_text||'-'||l_prev_text||' )*100/DECODE('||l_prev_text||',0,NULL,'||l_prev_text||')'||p_changetotalcol;
END IF;


RETURN l_col_text;
EXCEPTION
WHEN OTHERS THEN
RAISE;
END GET_SIMPLE_MEASURE;


FUNCTION trend_sql (
    p_xtd                       IN       VARCHAR2
  , p_comparison_type           IN       VARCHAR2
  , p_fact_name                 IN       VARCHAR2
  , p_where_clause              IN       VARCHAR2
  , p_col_name                  IN       poa_dbi_util_pkg.poa_dbi_col_tbl
  , p_use_grpid                 IN       VARCHAR2 := 'Y'
  , p_in_join_tables            IN       poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_fact_hint 		IN	 VARCHAR2 := null
  , p_union_clause              IN       VARCHAR2 DEFAULT NULL) --This parameter is specific to ICI
    RETURN VARCHAR2
  IS
    l_query               VARCHAR2 (10000);
    l_col_names           VARCHAR2 (4000);
    l_inner_col_names     VARCHAR2 (4000);
    l_col_alias           VARCHAR2 (4000);
    l_total_col_alias     VARCHAR2 (4000);
    l_view_by             VARCHAR2 (120);
    l_cal_clause          VARCHAR2 (1000);
    l_time_clause         VARCHAR2 (400);
    l_grpid_clause        VARCHAR2 (200);
    l_c_calc_end_date     VARCHAR2 (1000);
    l_p_calc_end_date     VARCHAR2 (1000);
    l_c_report_date_str   VARCHAR2 (1000);
    l_p_report_date_str   VARCHAR2 (1000);
    l_inlist_bmap         NUMBER           := 0;
    l_in_join_tables         VARCHAR2 (240) := '';
    l_compute_opening_bal varchar2(1)     := 'N';
    l_balance_report      varchar2(1) := 'N';
    l_outer_time_clause         VARCHAR2 (400);
  BEGIN

    IF(p_in_join_tables is not null) then

      FOR i in 1 .. p_in_join_tables.COUNT
      LOOP
        l_in_join_tables := l_in_join_tables || ' , ' ||  p_in_join_tables(i).table_name || ' ' || p_in_join_tables(i).table_alias;
      END LOOP;
    END IF;

    IF p_col_name.FIRST IS NOT NULL
    THEN
      FOR i IN p_col_name.FIRST .. p_col_name.LAST
      LOOP
        IF p_col_name (i).to_date_type = 'XED'
        THEN
          l_c_calc_end_date      := g_c_period_end_date;
          l_p_calc_end_date      := g_p_period_end_date;
          l_c_report_date_str    := ' n.end_date ';
          l_p_report_date_str    := ' n.end_date ';
          l_inlist_bmap          := poa_dbi_util_pkg.bitor (l_inlist_bmap
                                                          , g_inlist_xed);
        elsif p_col_name(i).to_date_type = 'RLX' then
          l_c_calc_end_date   := g_c_as_of_date;
          l_p_calc_end_date   := g_p_as_of_date;
          l_c_report_date_str := ' n.end_date ';
          l_p_report_date_str := ' n.end_date ';
          l_inlist_bmap       := poa_dbi_util_pkg.bitor( l_inlist_bmap
                                                       , g_inlist_rlx);
        elsif p_col_name(i).to_date_type = 'BAL' then
          l_c_calc_end_date   := g_c_as_of_date_balance;
          l_p_calc_end_date   := g_p_as_of_date_balance;
          l_c_report_date_str := ' n.end_date ';
          l_p_report_date_str := ' n.end_date ';
          l_inlist_bmap       := poa_dbi_util_pkg.bitor( l_inlist_bmap
                                                       , g_inlist_bal);
          l_balance_report := 'Y';
        ELSE -- XTD or YTD
          l_c_calc_end_date      := g_c_as_of_date;
          l_p_calc_end_date      := g_p_as_of_date;
          l_c_report_date_str    := ' LEAST (n.end_date, &BIS_CURRENT_ASOF_DATE) ';
          l_p_report_date_str    := ' LEAST (n.end_date, &BIS_PREVIOUS_ASOF_DATE) ';

          IF p_col_name (i).to_date_type = 'XTD'
          THEN
            l_inlist_bmap    := poa_dbi_util_pkg.bitor (l_inlist_bmap
                                                      , g_inlist_xtd);
          ELSE -- YTD
            l_inlist_bmap    := poa_dbi_util_pkg.bitor (l_inlist_bmap
                                                      , g_inlist_ytd);
          END IF;
        END IF;

        l_col_names :=
           l_col_names
           || ', sum(case when (n.start_date between '
           || case
                when p_col_name(i).to_date_type = 'RLX' or
                     p_col_name(i).to_date_type = 'BAL' then
                   poa_dbi_util_pkg.get_report_start_date(p_xtd)
                   || ' and &BIS_CURRENT_EFFECTIVE_END_DATE and n.ordinal in (-1,2)'
                else
                  '&BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE'
              end
           || ' and i.report_date = '
           || l_c_report_date_str
           || ') then '
           || p_col_name (i).column_alias
           || ' else null end) CURR_'
           || p_col_name (i).column_alias
           || '
';
        l_inner_col_names :=
           l_inner_col_names
           || ', sum(' || p_col_name(i).column_name || ') ' || p_col_name(i).column_alias;

        IF (p_col_name (i).prior_code <> poa_dbi_util_pkg.no_priors)
        THEN
          l_col_names :=
             l_col_names
             || ', lag(sum(case when (n.start_date between '
             || case
                  when p_col_name(i).to_date_type = 'RLX' or
                       p_col_name(i).to_date_type = 'BAL' then
                     poa_dbi_util_pkg.get_report_start_date(p_xtd,'Y')
                     || ' and &BIS_PREVIOUS_EFFECTIVE_END_DATE and n.ordinal in (-1,1)'
                   else
                     '&BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE'
                end
             || ' and i.report_date = '
             || l_p_report_date_str
             || ' ) then '
             || p_col_name (i).column_alias
             || ' else null end), &LAG'
             || ') over (order by '
             || case when p_xtd like 'RL%' then 'n.ordinal, ' end
             || 'n.start_date) p_'
             || p_col_name (i).column_alias
             || '
';
        END IF;

        -- Opening Balance Column
        if p_col_name(i).prior_code = 5 and
           p_col_name(i).to_date_type = 'BAL' then
          l_compute_opening_bal := 'Y';
          l_col_names :=
                l_col_names
             || ', lag(sum('
             || p_col_name(i).column_alias
             || '), decode(&BIS_TIME_COMPARISON_TYPE,''YEARLY'',&LAG *2,1)) over (order by n.ordinal,n.start_date) o_'
             || p_col_name(i).column_alias
             || ' ';
        end if;

        -- Grand total for current columns
        -- Note: RLX and BAL not supported here
        IF (p_col_name (i).grand_total = 'Y')
        THEN
          l_col_names    :=
                l_col_names
             || ',
                           sum(sum('
             || p_col_name (i).column_alias
             || ')) over () CURR_'
             || p_col_name (i).column_alias
             || '_total ';

          -- Grand total for previous columns
          IF (p_col_name (i).prior_code = poa_dbi_util_pkg.both_priors)
          THEN
            l_col_names    :=
                  l_col_names
               || ',
          sum(lag(sum('
               || p_col_name (i).column_alias
               || '))) over () p_'
               || p_col_name (i).column_alias
               || '_total';
          END IF;
        END IF;

      END LOOP;

    END IF;

    IF (    p_xtd = 'WTD'
        AND p_comparison_type = 'Y')
    THEN
      l_time_clause    :=
        ' ((cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE) or (cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE)) ';
      l_outer_time_clause    :=
        ' and ((n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE) or (n.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE)) ';
    ELSE
      if p_xtd like 'RL%' then
        l_time_clause := '1=1 ';
      else
        l_time_clause    := ' cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE ';
        l_outer_time_clause    := ' and n.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE ';
      end if;
    END IF;

    IF (    p_comparison_type = 'Y'
        AND p_xtd <> 'YTD')
    THEN
      -- Yearly
      l_cal_clause    :=
        CASE
          WHEN -- (XTD or YTD) only
                    (   BITAND (l_inlist_bmap
                              , g_inlist_xtd) = g_inlist_xtd
                     OR BITAND (l_inlist_bmap
                              , g_inlist_ytd) = g_inlist_ytd)
                AND NOT BITAND (l_inlist_bmap
                              , g_inlist_xed) = g_inlist_xed
            THEN -- (XTD or YTD) only
                 ' and n.report_date = (case when (cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE)
                                             then least(cal.end_date, &BIS_PREVIOUS_ASOF_DATE)
                                             else least(cal.end_date, &BIS_CURRENT_ASOF_DATE) end) '
          WHEN -- (XTD or YTD) and XED
                    (   BITAND (l_inlist_bmap
                              , g_inlist_xtd) = g_inlist_xtd
                     OR BITAND (l_inlist_bmap
                              , g_inlist_ytd) = g_inlist_ytd)
                AND BITAND (l_inlist_bmap
                          , g_inlist_xed) = g_inlist_xed
            THEN -- (XTD or YTD) and XED
                 ' and n.report_date in ( (case when (cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE)
                                               then least(cal.end_date, &BIS_PREVIOUS_ASOF_DATE)
                                               else least(cal.end_date, &BIS_CURRENT_ASOF_DATE) end)
                                        , &BIS_CURRENT_EFFECTIVE_END_DATE
                                        , &BIS_PREVIOUS_EFFECTIVE_END_DATE) '
          WHEN -- XED only
                    NOT (   BITAND (l_inlist_bmap
                                  , g_inlist_xtd) = g_inlist_xtd
                         OR BITAND (l_inlist_bmap
                                  , g_inlist_ytd) = g_inlist_ytd)
                AND BITAND (l_inlist_bmap
                          , g_inlist_xed) = g_inlist_xed
            THEN -- placeholder for XED only
                 ' '
          when bitand(l_inlist_bmap,g_inlist_rlx) = g_inlist_rlx then
            ' and n.report_date = cal.report_date '
          when bitand(l_inlist_bmap,g_inlist_bal) = g_inlist_bal then
            ' '
        END;
    ELSE
      -- Sequential comparison type
      l_cal_clause    :=
        CASE
          WHEN -- (XTD or YTD) only
                    (   BITAND (l_inlist_bmap
                              , g_inlist_xtd) = g_inlist_xtd
                     OR BITAND (l_inlist_bmap
                              , g_inlist_ytd) = g_inlist_ytd)
                AND NOT BITAND (l_inlist_bmap
                              , g_inlist_xed) = g_inlist_xed
            THEN -- (XTD or YTD) only
                 ' and n.report_date in (least(cal.end_date, &BIS_CURRENT_ASOF_DATE) , &BIS_PREVIOUS_ASOF_DATE)
                   and n.report_date between cal.start_date and cal.end_date '
          WHEN -- (XTD or YTD) and XED
                    (   BITAND (l_inlist_bmap
                              , g_inlist_xtd) = g_inlist_xtd
                     OR BITAND (l_inlist_bmap
                              , g_inlist_ytd) = g_inlist_ytd)
                AND BITAND (l_inlist_bmap
                          , g_inlist_xed) = g_inlist_xed
            THEN -- (XTD or YTD) and XED
                 ' and n.report_date in (least(cal.end_date, &BIS_CURRENT_ASOF_DATE) , &BIS_PREVIOUS_ASOF_DATE, &BIS_CURRENT_EFFECTIVE_END_DATE)
                   and n.report_date between cal.start_date and cal.end_date '
          WHEN -- XED only
                    NOT (   BITAND (l_inlist_bmap
                                  , g_inlist_xtd) = g_inlist_xtd
                         OR BITAND (l_inlist_bmap
                                  , g_inlist_ytd) = g_inlist_ytd)
                AND BITAND (l_inlist_bmap
                          , g_inlist_xed) = g_inlist_xed
            THEN -- XED only
                 ' and 555 = 555 /* sequential xed only */ '
          when bitand(l_inlist_bmap,g_inlist_rlx) = g_inlist_rlx then
            ' and n.report_date = cal.report_date '
          when bitand(l_inlist_bmap,g_inlist_bal) = g_inlist_bal then
            ' '
        END;
    END IF;

    IF (p_use_grpid = 'Y')
    THEN
      l_grpid_clause    := ' and fact.grp_id = decode(n.period_type_id,1,14,16,13,32,11,64,7)';
    ELSIF (p_use_grpid = 'R')
    THEN
      	l_grpid_clause    := 'and fact.grp_id = decode(cal.period_type_id,1,0,16,1,32,3,64,7)';
    END IF;

    l_query    :=
       '(select n.start_date'
       || case when p_xtd like 'RL%' then ', n.ordinal ' end
       || '
       ' ||l_col_names || '
       from (select ' || p_fact_hint || ' '
       || case when p_xtd like 'RL%' then 'n.ordinal, ' end
       || 'n.start_date, n.report_date '
       || l_inner_col_names
       || ' from '
       || p_fact_name
       || ' fact,
'
       || case
            when p_xtd like 'RL%' then
              case
                when l_balance_report = 'N' then
                  '( select /*+ NO_MERGE */ cal.ordinal,n.time_id,n.record_type_id,n.period_type_id,n.report_date,cal.start_date,cal.end_date'
                  || ' from ' || poa_dbi_util_pkg.get_calendar_table(p_xtd)
                  || ' cal, fii_time_structures n
where '
                  || l_time_clause
                  || l_cal_clause
                        -- &RLX_NESTED_PATTERN should be replaced with
                        -- some &BIS bind substitution when available from fii/bis team.
                  || ' and bitand(n.record_type_id,&RLX_NESTED_PATTERN) = &RLX_NESTED_PATTERN ) n'
		 || l_in_join_tables
		 || '
where fact.time_id = n.time_id
and fact.period_type_id = n.period_type_id
 '
                else
                  '( select /*+ NO_MERGE */ cal.ordinal,cal.start_date, cal.report_date'
                  || ' from ' || poa_dbi_util_pkg.get_calendar_table(p_xtd,'Y',l_compute_opening_bal)
                  || ' cal where '
                  || l_time_clause
                  || l_cal_clause
                  || ' ) n
where fact.report_date = least(n.report_date,&LAST_COLLECTION)
'
              end
            else -- non RL%
              ' (select /*+ NO_MERGE */ n.time_id,n.record_type_id, n.period_type_id,n.report_date,cal.start_date,cal.end_date
       from '
              || poa_dbi_util_pkg.get_calendar_table (p_xtd)
              || ' cal, fii_time_rpt_struct_v n
where '
              || l_time_clause
              || l_cal_clause
              || ' and bitand(n.record_type_id, '
              || CASE -- if one or more columns = YTD then use nested pattern
                   WHEN BITAND (l_inlist_bmap, g_inlist_ytd) = g_inlist_ytd
                     THEN '&YTD_NESTED_PATTERN'
                   ELSE '&BIS_NESTED_PATTERN'
                 END
              || ') = n.record_type_id ) n
        '     || l_in_join_tables || '
where fact.time_id = n.time_id
'
          end
       || l_grpid_clause || '
'      || p_where_clause || '
group by '
       || case when p_xtd like 'RL%' then 'n.ordinal, ' end
       || ' n.start_date, n.report_date) i, '
       || poa_dbi_util_pkg.get_calendar_table(p_xtd,'Y',l_compute_opening_bal)
       || ' n where i.start_date (+) = n.start_date '
       || l_outer_time_clause
       || case when p_xtd like 'RL%' then 'and i.ordinal(+) = n.ordinal ' end
       || ' group by '
       || case when p_xtd like 'RL%' then 'n.ordinal, ' end
       || 'n.start_date  '
       || p_union_clause
       || ') iset, '
       || poa_dbi_util_pkg.get_calendar_table (p_xtd,'N','N')
       || ' cal '
       || '
where cal.start_date between '
       || case
            when p_xtd like 'RL%' then
              poa_dbi_util_pkg.get_report_start_date(p_xtd)
            else
              '&BIS_CURRENT_REPORT_START_DATE'
          end
       || ' and &BIS_CURRENT_ASOF_DATE
and cal.start_date = iset.start_date(+)'
       || case when p_xtd like 'RL%' then ' and cal.ordinal = iset.ordinal(+)' end
       || '
order by cal.start_date';
    RETURN l_query;

END trend_sql;

FUNCTION get_continued_measures(
      p_bix_col_tab        IN OUT NOCOPY poa_dbi_util_pkg.poa_dbi_col_tbl,
      p_where_clause       IN OUT NOCOPY VARCHAR2,
      p_xtd                IN  VARCHAR2,
      p_comparison_type    IN  VARCHAR2,
      p_mv_set             IN  VARCHAR2
    ) RETURN VARCHAR2 IS

       l_select_list     VARCHAR2(4000);
       l_from_list       VARCHAR2(4000);
       l_group_by_clause VARCHAR2(4000);
       l_where_clause    VARCHAR2(4000);
       l_tele_inb        VARCHAR2(40) := 'TELE_INB';
       l_tele_direct     VARCHAR2(40) := 'TELE_DIRECT';

    BEGIN

       l_select_list :=  'SELECT fii1.START_DATE ' ;

       FOR i IN 1..p_bix_col_tab.COUNT
       LOOP
          --Move into the IF block if its just a pseudo column value ('0')
          IF p_bix_col_tab(i).COLUMN_NAME = '0' THEN
          --If prior value for this measure is also to be calculated, then do it here.
           IF p_bix_col_tab(i).prior_code = 2 THEN
             l_select_list := l_select_list||fnd_global.newline||','||p_bix_col_tab(i).COLUMN_NAME||'  '||'curr_'||p_bix_col_tab(i).COLUMN_ALIAS
                                           ||fnd_global.newline||','||p_bix_col_tab(i).COLUMN_NAME||'  '||'p_'||p_bix_col_tab(i).COLUMN_ALIAS;
           ELSE--003
            --Form the SELECT list where prior value is not required.
             l_select_list := l_select_list||fnd_global.newline||','||p_bix_col_tab(i).COLUMN_NAME||'  '||'curr_'||p_bix_col_tab(i).COLUMN_ALIAS;
           END IF;
          ELSE
          --Get the prior values for the actual column names.
            IF p_bix_col_tab(i).prior_code = 2 THEN
                       l_select_list := l_select_list||fnd_global.newline||','||
                       'SUM(CASE when(fii1.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE)
                                 THEN  '||p_bix_col_tab(i).COLUMN_NAME||'  ELSE 0 END)  '||'curr_'||p_bix_col_tab(i).COLUMN_ALIAS
                                        ||fnd_global.newline||','||'SUM(CASE when(fii1.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE)
                                 THEN  '||p_bix_col_tab(i).COLUMN_NAME||'  ELSE 0 END)  '||'p_'||p_bix_col_tab(i).COLUMN_ALIAS;
            ELSE --003
                       l_select_list := l_select_list||fnd_global.newline||','||
                       'SUM(CASE when(fii1.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE)
                                 THEN  '||p_bix_col_tab(i).COLUMN_NAME||'  ELSE 0 END)  '||'curr_'||p_bix_col_tab(i).COLUMN_ALIAS;
            END IF;
          END IF;
       END LOOP;

       p_bix_col_tab.DELETE;

       --Form the FROM list and the where clause for reports that display session level values.
       IF p_mv_set = 'SES' THEN
       l_from_list := fnd_global.newline||'  FROM  '||get_mv(p_mv_set,'6.0.4') ||' fact,'||' fii_time_rpt_struct ' ||' cal ,'|| poa_dbi_util_pkg.get_calendar_table(p_xtd) ||' fii1 ';
       l_where_clause := fnd_global.newline
                         ||'WHERE fact.time_id        = cal.time_id  '
                         ||fnd_global.newline||'AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id  '
                         ||fnd_global.newline||'AND cal.period_type_id = fact.period_type_id  '
                         ||fnd_global.newline||'AND fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE  '
                         ||p_where_clause;

                 IF (p_comparison_type = 'Y'  AND p_xtd <> 'YTD') THEN
                 l_where_clause := l_where_clause ||fnd_global.newline||'AND cal.report_date = (CASE WHEN(fii1.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE)
                   THEN least(fii1.end_date, &BIS_PREVIOUS_ASOF_DATE) ELSE least(fii1.end_date, &BIS_CURRENT_ASOF_DATE) END) ';
                 ELSE
                   l_where_clause := l_where_clause || fnd_global.newline||' AND cal.report_date = least(fii1.end_date, &BIS_CURRENT_ASOF_DATE) ';
                 END IF;

        ELSE
        l_from_list := fnd_global.newline||'  FROM  '||get_mv(p_mv_set,'6.0.4') ||' fact,'|| poa_dbi_util_pkg.get_calendar_table(p_xtd) ||' fii1';
        l_where_clause := fnd_global.newline
                         ||'WHERE fact.period_type_id = 1 '
                         ||fnd_global.newline||'AND fact.time_id = TO_CHAR(fii1.start_date,''J'') '
                         ||fnd_global.newline||'AND fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE  '
                         ||p_where_clause;
        END IF;


       l_group_by_clause := ' GROUP BY fii1.start_date order by start_date ';--002

       l_select_list := l_select_list||l_from_list||l_where_clause||l_group_by_clause;

       RETURN l_select_list;

END get_continued_measures;



/*-------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------*/

PROCEDURE get_emc_page_params (p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL,
 						 l_as_of_date              OUT NOCOPY DATE,
                               l_period_type             OUT NOCOPY VARCHAR2,
						 l_record_type_id          OUT NOCOPY NUMBER,
                               l_comp_type               OUT NOCOPY VARCHAR2,
                               l_account                 OUT NOCOPY VARCHAR2,
						 l_classification          OUT NOCOPY VARCHAR2,
						 l_view_by                 OUT NOCOPY VARCHAR2
                              ) IS
l_sql_errm VARCHAR2(32000);
BEGIN
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
          l_period_type := p_page_parameter_tbl(i).parameter_value;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'AS_OF_DATE' THEN
       --   l_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
            l_as_of_date := p_page_parameter_tbl(i).period_date;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'TIME_COMPARISON_TYPE' THEN
          l_comp_type := p_page_parameter_tbl(i).parameter_value;
       END IF;
	  IF p_page_parameter_tbl(i).parameter_name= 'EMAIL ACCOUNT+EMAIL ACCOUNT' THEN
		l_account := p_page_parameter_tbl(i).parameter_id;
       END IF;
	  IF p_page_parameter_tbl(i).parameter_name= 'EMAIL CLASSIFICATION+EMAIL CLASSIFICATION' THEN
		l_classification := p_page_parameter_tbl(i).parameter_id;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'VIEW_BY' THEN
	  l_view_by := p_page_parameter_tbl(i).parameter_id;
       END IF;
     END LOOP;
  END IF;
  --
  --First time page patch is applied, sometimes period type
  --is not being passed. Force it to MONTH if this happens.
  --If at all this happens, this will only happen the very first
  --time page patch is applied.
  --
  IF l_period_type IS NULL THEN
     l_period_type := 'FII_TIME_ENT_PERIOD';
  END IF;
  --
  --l_period_type is used to derive the table name. It can only be
  --the following values. If it is not, then we will fail the SQL.
  --
  IF  l_period_type <> 'FII_TIME_WEEK'
  AND l_period_type <> 'FII_TIME_ENT_PERIOD'
  AND l_period_type <> 'FII_TIME_ENT_QTR'
  AND l_period_type <> 'FII_TIME_ENT_YEAR'
  THEN
    l_period_type := NULL;
  END IF;
  CASE l_period_type
    WHEN 'FII_TIME_WEEK' THEN l_record_type_id := 11;
    WHEN 'FII_TIME_ENT_PERIOD' THEN l_record_type_id := 23;
    WHEN 'FII_TIME_ENT_QTR' THEN l_record_type_id := 55;
    WHEN 'FII_TIME_ENT_YEAR' THEN l_record_type_id := 119;
    ELSE l_record_type_id := null;
  END CASE;
EXCEPTION
WHEN OTHERS THEN
NULL;
END get_emc_page_params;

FUNCTION period_start_date(l_as_of_date IN DATE,
					  l_period_type IN VARCHAR2 ) RETURN DATE IS
l_period_start_Date DATE;
BEGIN
  CASE l_period_type
     WHEN 'FII_TIME_WEEK' THEN
	SELECT week_start_date INTO l_period_start_date
	FROM   fii_time_day WHERE report_date = l_as_of_date;
	WHEN 'FII_TIME_ENT_PERIOD' THEN
	SELECT ent_period_start_date INTO l_period_start_date
     FROM   fii_time_day WHERE report_date = l_as_of_date;
     WHEN 'FII_TIME_ENT_QTR' THEN
	SELECT ent_qtr_start_date INTO l_period_start_date
	FROM   fii_time_day WHERE report_date = l_as_of_date;
     WHEN 'FII_TIME_ENT_YEAR' THEN
	SELECT ent_year_start_date INTO l_period_start_date
	FROM   fii_time_day WHERE report_date = l_as_of_date;
     ELSE l_period_start_date := null;
  END CASE;
  RETURN l_period_start_date;
EXCEPTION
WHEN OTHERS THEN
return NULL;
END period_start_date;

FUNCTION get_default_params
RETURN VARCHAR2 IS
v_date VARCHAR2(11);
BEGIN
--SELECT to_char(add_months(to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),
			   --'MM/DD/YYYY'),13),'DD-MON-YYYY')
SELECT to_char(sysdate,'DD-MON-YYYY')
INTO v_date
FROM dual;
RETURN 'BIX_PMV_WEEK_FROM=ALL&BIX_PMV_WEEK_TO=ALL&BIX_PMV_SEQUENTIAL=TIME_COMPARISON_TYPE+SEQUENTIAL&AS_OF_DATE='||v_date;
EXCEPTION
WHEN OTHERS
THEN
RETURN 'BIX_PMV_WEEK_FROM=ALL&BIX_PMV_WEEK_TO=ALL&BIX_PMV_SEQUENTIAL=TIME_COMPARISON_TYPE+SEQUENTIAL&AS_OF_DATE='||TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY');
END get_default_params;

PROCEDURE get_ai_page_params (p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL,
 						 l_as_of_date              OUT NOCOPY DATE,
                               l_period_type             OUT NOCOPY VARCHAR2,
						 l_record_type_id          OUT NOCOPY NUMBER,
                               l_comp_type               OUT NOCOPY VARCHAR2,
						 l_call_center             OUT NOCOPY VARCHAR2,
                               l_classification          OUT NOCOPY VARCHAR2,
						 l_dnis                    OUT NOCOPY VARCHAR2,
						 l_view_by                 OUT NOCOPY VARCHAR2
                              ) IS
l_sql_errm VARCHAR2(32000);
BEGIN
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
          l_period_type := p_page_parameter_tbl(i).parameter_value;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'AS_OF_DATE' THEN
          --l_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
            l_as_of_date := p_page_parameter_tbl(i).period_date;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'TIME_COMPARISON_TYPE' THEN
          l_comp_type := p_page_parameter_tbl(i).parameter_value;
       END IF;
	  IF p_page_parameter_tbl(i).parameter_name = 'BIX_TELEPHONY+BIX_CALL_CLASSIFICATION'
	  THEN
		l_classification := p_page_parameter_tbl(i).parameter_id;
       END IF;
	  IF p_page_parameter_tbl(i).parameter_name= 'BIX_TELEPHONY+BIX_CALL_CENTER'
	  THEN
		l_call_center := p_page_parameter_tbl(i).parameter_id;
       END IF;
	  IF p_page_parameter_tbl(i).parameter_name= 'BIX_TELEPHONY+BIX_DNIS'
	  THEN
		l_dnis := p_page_parameter_tbl(i).parameter_id;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'VIEW_BY' THEN
	     l_view_by := p_page_parameter_tbl(i).parameter_id;
       END IF;
     END LOOP;
  END IF;
  --
  --First time page patch is applied, sometimes period type
  --is not being passed. Force it to MONTH if this happens.
  --If at all this happens, this will only happen the very first
  --time page patch is applied.
  --
  IF l_period_type IS NULL THEN
     l_period_type := 'FII_TIME_ENT_PERIOD';
  END IF;
  --
  --l_period_type is used to derive the table name. It can only be
  --the following values. If it is not, then we will fail the SQL.
  --
  IF  l_period_type <> 'FII_TIME_WEEK'
  AND l_period_type <> 'FII_TIME_ENT_PERIOD'
  AND l_period_type <> 'FII_TIME_ENT_QTR'
  AND l_period_type <> 'FII_TIME_ENT_YEAR'
  THEN
    l_period_type := NULL;
  END IF;
  CASE l_period_type
    WHEN 'FII_TIME_WEEK' THEN l_record_type_id := 11;
    WHEN 'FII_TIME_ENT_PERIOD' THEN l_record_type_id := 23;
    WHEN 'FII_TIME_ENT_QTR' THEN l_record_type_id := 55;
    WHEN 'FII_TIME_ENT_YEAR' THEN l_record_type_id := 119;
    ELSE l_record_type_id := null;
  END CASE;
EXCEPTION
WHEN OTHERS THEN
NULL;
END get_ai_page_params;

FUNCTION get_ai_default_page_params
RETURN VARCHAR2 IS
v_date VARCHAR2(11);
BEGIN
SELECT to_char(sysdate,'DD-MON-YYYY')
INTO v_date
FROM dual;
RETURN 'FII_TIME_WEEK_FROM=All&FII_TIME_WEEK_TO=All&SEQUENTIAL=TIME_COMPARISON_TYPE+SEQUENTIAL&AS_OF_DATE='||v_date;
EXCEPTION
WHEN OTHERS
THEN
RETURN 'FII_TIME_WEEK_FROM=All&FII_TIME_WEEK_TO=All&SEQUENTIAL=TIME_COMPARISON_TYPE+SEQUENTIAL&AS_OF_DATE='||TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY');
END get_ai_default_page_params;

PROCEDURE GET_AO_PAGE_PARAMS
				  (p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL,
 			       l_as_of_date              OUT NOCOPY DATE,
                   l_period_type             OUT NOCOPY VARCHAR2,
			       l_record_type_id          OUT NOCOPY NUMBER,
                   l_comp_type               OUT NOCOPY VARCHAR2,
			       l_call_center             OUT NOCOPY VARCHAR2,
                   l_campaign_id             OUT NOCOPY VARCHAR2,
                   l_schedule_id             OUT NOCOPY VARCHAR2,
                   l_source_code_id          OUT NOCOPY VARCHAR2,
                   l_agent_group             OUT NOCOPY VARCHAR2,
			       l_view_by                 OUT NOCOPY VARCHAR2

                              ) IS
l_sql_errm VARCHAR2(32000);
tmp varchar2(1000);
BEGIN
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
          l_period_type := p_page_parameter_tbl(i).parameter_value;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'AS_OF_DATE' THEN
          --l_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
            l_as_of_date := p_page_parameter_tbl(i).period_date;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'TIME_COMPARISON_TYPE' THEN
          l_comp_type := p_page_parameter_tbl(i).parameter_value;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'BIX_TELEPHONY+BIX_CALL_CENTER'
       THEN
		l_call_center := p_page_parameter_tbl(i).parameter_id;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'CAMPAIGN+CAMPAIGN'
       THEN
        l_source_code_id := p_page_parameter_tbl(i).parameter_id;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'BIX_TELEPHONY+BIX_CAMPAIGN_SCHEDULE'
       THEN
		l_schedule_id := p_page_parameter_tbl(i).parameter_id;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'BIX_TELEPHONY+BIX_SOURCE_CODE'
       THEN
		l_source_code_id := p_page_parameter_tbl(i).parameter_id;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'ORGANIZATION+JTF_ORG_SUPPORT_GROUP' THEN
         l_agent_group := p_page_parameter_tbl(i).parameter_id;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'VIEW_BY' THEN
	     l_view_by := p_page_parameter_tbl(i).parameter_id;
       END IF;
     END LOOP;
  END IF;
  --
  --First time page patch is applied, sometimes period type
  --is not being passed. Force it to MONTH if this happens.
  --If at all this happens, this will only happen the very first
  --time page patch is applied.
  --
  IF l_period_type IS NULL THEN
----     l_period_type := 'FII_TIME_MONTH';
		l_period_type := 'FII_TIME_ENT_PERIOD';
  END IF;
  --
  --l_period_type is used to derive the table name. It can only be
  --the following values. If it is not, then we will fail the SQL.
  --

  IF  l_period_type <> 'FII_TIME_WEEK'
  AND l_period_type <> 'FII_TIME_DAY'
  AND l_period_type <> 'FII_TIME_ENT_PERIOD'
  AND l_period_type <> 'FII_TIME_ENT_QTR'
  AND l_period_type <> 'FII_TIME_ENT_YEAR'
  THEN
    l_period_type := NULL;
  END IF;
  CASE l_period_type
    WHEN 'FII_TIME_WEEK' THEN l_record_type_id := 11;
    WHEN 'FII_TIME_ENT_PERIOD' THEN l_record_type_id := 23;
    WHEN 'FII_TIME_ENT_QTR' THEN l_record_type_id := 55;
    WHEN 'FII_TIME_ENT_YEAR' THEN l_record_type_id := 119;
  --  WHEN 'FII_TIME_DAY' THEN l_record_type_id := 119;
    ELSE l_record_type_id := null;
  END CASE;
EXCEPTION
WHEN OTHERS THEN
  tmp:=sqlerrm;
END GET_AO_PAGE_PARAMS;

FUNCTION get_ao_default_page_params
RETURN VARCHAR2 IS
v_date VARCHAR2(11);
BEGIN
SELECT to_char(sysdate,'DD-MON-YYYY')
INTO v_date
FROM dual;
RETURN '+FII_TIME_ENT_PERIOD=TIME+FII_TIME_ENT_PERIOD+SEQUENTIAL=TIME_COMPARISON_TYPE+SEQUENTIAL='||v_date;
EXCEPTION
WHEN OTHERS
THEN
RETURN '+FII_TIME_ENT_PERIOD=TIME+FII_TIME_ENT_PERIOD+
SEQUENTIAL=TIME_COMPARISON_TYPE+SEQUENTIAL='||TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY');
END get_ao_default_page_params;


END  BIX_PMV_DBI_utl_pkg;


/
