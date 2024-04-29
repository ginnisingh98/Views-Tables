--------------------------------------------------------
--  DDL for Package Body RCI_OPEN_REMED_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCI_OPEN_REMED_SUMM_PKG" as
/*$Header: rciopnrb.pls 120.24.12000000.1 2007/01/16 20:46:31 appldev ship $*/

-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below
-- Global Varaiables
C_ERROR         CONSTANT        NUMBER := -1;   -- concurrent manager error code
C_WARNING       CONSTANT        NUMBER := 1;    -- concurrent manager warning code
C_OK            CONSTANT        NUMBER := 0;    -- concurrent manager success code
C_ERRBUF_SIZE   CONSTANT        NUMBER := 300;  -- length of formatted error message

-- User Defined Exceptions

INITIALIZATION_ERROR EXCEPTION;
PRAGMA EXCEPTION_INIT (INITIALIZATION_ERROR, -20900);
INITIALIZATION_ERROR_MESG CONSTANT VARCHAR2(200) := 'Error in Global setup';

-- File scope variables

g_global_start_date      DATE;
g_rci_schema             VARCHAR2(30);
G_USER_ID                NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID               NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE get_kpi(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
    l_sqlstmt      VARCHAR2(15000);
    counter NUMBER := 0;
    where_clause VARCHAR2(4000) := ' ';
    f_where_clause VARCHAR2(4000) := ' ';
    r_where_clause VARCHAR2(4000) := ' ';

	v_period   varchar2(100);
    v_qtr      varchar2(100);
    v_year     varchar2(100);
    l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN
    counter := p_page_parameter_tbl.COUNT;
    FOR i IN 1..counter LOOP
      IF p_page_parameter_tbl(i).parameter_id IS NOT NULL THEN
        /*IF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' THEN
            where_clause := where_clause || ' AND f.certification_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' THEN
            where_clause := where_clause || ' AND f.cert_type='|| p_page_parameter_tbl(i).parameter_id ;
        ELS*/IF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
--		    v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'M');
            /*04.21.2006 npanandi: implementation of passing time parameters
			  has been changed to account for dynamic binding -- see below
			where_clause := where_clause || ' AND f.ent_period_id ='|| p_page_parameter_tbl(i).parameter_id|| ' AND r.ent_period_id ='|| p_page_parameter_tbl(i).parameter_id;
            f_where_clause := f_where_clause || ' AND f.ent_period_id ='|| p_page_parameter_tbl(i).parameter_id;
            r_where_clause := r_where_clause || ' AND r.ent_period_id ='|| p_page_parameter_tbl(i).parameter_id;
			*/
			/** 12.16.2005 npanandi: added eec.initiation_date below **/
--			where_clause := where_clause || ' AND eec.initiation_date < (select distinct ent_period_end_date from fii_time_day where ent_period_id = f.ent_period_id) ';

            /*04.21.2006 npanandi: adding below for SQL repository fix**/
			v_period := p_page_parameter_tbl(i).parameter_id;
			where_clause := where_clause || ' AND f.ent_period_id = :WFTIME AND r.ent_period_id = :WRTIME';
            f_where_clause := f_where_clause || ' AND f.ent_period_id = :FWTIME ';
            r_where_clause := r_where_clause || ' AND r.ent_period_id = :RWTIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
--		    v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Q');
            /*04.21.2006 npanandi: implementation of passing time parameters
			  has been changed to account for dynamic binding -- see below
			where_clause := where_clause || ' AND f.ent_qtr_id ='|| p_page_parameter_tbl(i).parameter_id|| ' AND r.ent_qtr_id ='|| p_page_parameter_tbl(i).parameter_id;
            f_where_clause := f_where_clause || ' AND f.ent_qtr_id ='|| p_page_parameter_tbl(i).parameter_id;
            r_where_clause := r_where_clause || ' AND r.ent_qtr_id ='|| p_page_parameter_tbl(i).parameter_id;
			*/
			/** 12.16.2005 npanandi: added eec.initiation_date below **/
--			where_clause := where_clause || ' AND eec.initiation_date < (select distinct ent_qtr_end_date from fii_time_day where ent_qtr_id = f.ent_qtr_id) ';

            /*04.21.2006 npanandi: adding below for SQL repository fix**/
			v_period := p_page_parameter_tbl(i).parameter_id;
			where_clause := where_clause || ' AND f.ent_qtr_id = :WFTIME AND r.ent_qtr_id = :WRTIME';
            f_where_clause := f_where_clause || ' AND f.ent_qtr_id = :FWTIME ';
            r_where_clause := r_where_clause || ' AND r.ent_qtr_id = :RWTIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
--		    v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Y');
            /*04.21.2006 npanandi: implementation of passing time parameters
			  has been changed to account for dynamic binding -- see below
            where_clause := where_clause || ' AND f.ent_year_id ='|| p_page_parameter_tbl(i).parameter_id|| ' AND r.ent_year_id ='|| p_page_parameter_tbl(i).parameter_id;
            f_where_clause := f_where_clause || ' AND f.ent_year_id ='|| p_page_parameter_tbl(i).parameter_id;
            r_where_clause := r_where_clause || ' AND r.ent_year_id ='|| p_page_parameter_tbl(i).parameter_id;
			*/
			/** 12.16.2005 npanandi: added eec.initiation_date below **/
--			where_clause := where_clause || ' AND eec.initiation_date < (select distinct ent_year_end_date from fii_time_day where ent_year_id = f.ent_year_id) ';

            /*04.21.2006 npanandi: adding below for SQL repository fix**/
			v_period := p_page_parameter_tbl(i).parameter_id;
			where_clause := where_clause || ' AND f.ent_year_id = :WFTIME AND r.ent_year_id = :WRTIME ';
            f_where_clause := f_where_clause || ' AND f.ent_year_id = :FWTIME ';
            r_where_clause := r_where_clause || ' AND r.ent_year_id = :RWTIME ';
        END IF;
      END IF; --parameter_id not null
    END LOOP;

    l_sqlstmt :='
        SELECT
            null VIEWBY
            ,nvl(sum(r_open),0) RCI_PROC_CERT_MEASURE1
            ,nvl(sum(f_open),0) RCI_PROC_CERT_MEASURE2
        FROM
        (
           SELECT
        		sum(f.open) f_open
        		,0 r_open
            FROM
        		RCI_OPEN_FINDINGS_F f
            WHERE f.open=1 AND f.age_in_days >= 0
            and f.organization_id is not null
            '|| f_where_clause || '
        UNION
           SELECT
                0 f_open
                ,sum(r.open) r_open
            FROM
        		RCI_OPEN_REMEDIATIONS_F r
            WHERE r.open=1 AND r.age_in_days >= 0
            and r.organization_id is not null
            '|| r_where_clause || '
        ) ';

    p_exp_source_sql := l_sqlstmt;

	/**04.21.2006 npanandi: adding code for dynamic binding of time period dimensions**/
	p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':WFTIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':WRTIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':FWTIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

	p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':RWTIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;
    /**04.21.2006 npanandi: finished code for dynamic binding of time period dimensions**/
END get_kpi;

/*
Procedure to be called by concurrent program
*/
PROCEDURE get_open_remediation_result(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
    counter NUMBER := 0;
    l_sqlstmt VARCHAR2(15000);
	l_act_sqlstmt varchar2(15000);
    join_table VARCHAR2(99) := '';
    view_by_col VARCHAR2(99) := '';
    where_clause VARCHAR2(4000) := ' ';
    f_where_clause VARCHAR2(4000) := ' ';
    r_where_clause VARCHAR2(4000) := ' ';
    outer_where_clause VARCHAR2(2000) := ' ';
    group_by_col VARCHAR2(99) := '';
    group_by_col_name VARCHAR2(99) := '';
    view_by_name varchar2(99) := '';
    v_yyyymm varchar2(6);

	v_period   varchar2(100);
    v_qtr      varchar2(100);
    v_year     varchar2(100);
    l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN

    counter := p_page_parameter_tbl.COUNT;
    FOR i IN 1..counter LOOP
      IF p_page_parameter_tbl(i).parameter_id IS NOT NULL THEN
        IF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
--view by parameters
            view_by_name := p_page_parameter_tbl(i).parameter_id;
            IF p_page_parameter_tbl(i).parameter_id = 'ORGANIZATION+RCI_ORG_AUDIT' THEN
                view_by_col := ' org.name ';
                group_by_col := 'organization_id  ';
                group_by_col_name := ' v_org_id ';
                join_table := ' ,amw_audit_units_v org ';
                outer_where_clause :=  ' opn.v_org_id = org.organization_id ';
            ELSIF p_page_parameter_tbl(i).parameter_id = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
                view_by_col := ' proc.display_name ';
                group_by_col := 'process_id  ';
                group_by_col_name := ' v_process_id ';
                join_table := ' ,amw_process_vl proc ';
                outer_where_clause := ' opn.v_process_id = proc.process_id
                AND (proc.REVISION_NUMBER = (select max(REVISION_NUMBER) from amw_process_vl where proc.process_id=process_id)
	                   OR proc.process_id is null ) ';
            ELSIF p_page_parameter_tbl(i).parameter_id = 'RCI_ISSUE_PRIORITY+RCI_ISSUE_PRIORITY' THEN
                view_by_col := ' ecp.description ';
                group_by_col := 'priority_code  ';
                group_by_col_name := ' v_priority_id ';
                join_table := ' ,eng_change_priorities ecp ';
                outer_where_clause := ' opn.v_priority_id = ecp.eng_change_priority_code ';
            ELSIF p_page_parameter_tbl(i).parameter_id = 'RCI_ISSUE_REASON+RCI_ISSUE_REASON' THEN
                view_by_col := ' ecr.description ';
                group_by_col := 'reason_code  ';
                group_by_col_name := ' v_reason_id ';
                join_table := ' ,eng_change_reasons ecr ';
                outer_where_clause := ' opn.v_reason_id = ecr.eng_change_reason_code ';
            ELSIF p_page_parameter_tbl(i).parameter_id = 'RCI_ISSUE_PHASE+RCI_ISSUE_PHASE' THEN
                view_by_col := ' ecs.status_name ';
                group_by_col := 'phase_code  ';
                group_by_col_name := ' v_phase_id ';
                join_table := ' ,eng_change_statuses_vl ecs ';
                outer_where_clause := ' opn.v_phase_id = ecs.status_code ';
            END IF;
--end view by parameters
        ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' THEN
            where_clause := where_clause || ' AND f.organization_id ='|| p_page_parameter_tbl(i).parameter_id|| ' AND r.organization_id ='|| p_page_parameter_tbl(i).parameter_id;
            f_where_clause := f_where_clause || ' AND f.organization_id ='|| p_page_parameter_tbl(i).parameter_id;
            r_where_clause := r_where_clause || ' AND r.organization_id ='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
            where_clause := where_clause || ' AND f.process_id ='|| p_page_parameter_tbl(i).parameter_id || ' AND r.process_id ='|| p_page_parameter_tbl(i).parameter_id;
            f_where_clause := f_where_clause || ' AND f.process_id ='|| p_page_parameter_tbl(i).parameter_id;
            r_where_clause := r_where_clause || ' AND r.process_id ='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_PRIORITY+RCI_ISSUE_PRIORITY' THEN
            where_clause := where_clause || ' AND f.priority_code ='|| p_page_parameter_tbl(i).parameter_id|| ' AND r.priority_code ='|| p_page_parameter_tbl(i).parameter_id;
            f_where_clause := f_where_clause || ' AND f.priority_code ='|| p_page_parameter_tbl(i).parameter_id;
            r_where_clause := r_where_clause || ' AND r.priority_code ='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_REASON+RCI_ISSUE_REASON' THEN
            where_clause := where_clause || ' AND f.reason_code ='|| p_page_parameter_tbl(i).parameter_id|| ' AND r.reason_code ='|| p_page_parameter_tbl(i).parameter_id;
            f_where_clause := f_where_clause || ' AND f.reason_code ='|| p_page_parameter_tbl(i).parameter_id;
            r_where_clause := r_where_clause || ' AND r.reason_code ='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_PHASE+RCI_ISSUE_PHASE' THEN
            where_clause := where_clause || ' AND f.phase_code ='|| p_page_parameter_tbl(i).parameter_id|| ' AND r.phase_code ='|| p_page_parameter_tbl(i).parameter_id;
            f_where_clause := f_where_clause || ' AND f.phase_code ='|| p_page_parameter_tbl(i).parameter_id;
            r_where_clause := r_where_clause || ' AND r.phase_code ='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
--		    v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'M');
            /** 12.16.2005 npanandi: joining with fii_time_day **/
			/*04.25.2006 npanandi: implementation of passing time parameters
			  has been changed to account for dynamic binding -- see below
            where_clause := where_clause || ' AND f.ent_period_id ='|| p_page_parameter_tbl(i).parameter_id|| ' AND r.ent_period_id ='|| p_page_parameter_tbl(i).parameter_id;
            f_where_clause := f_where_clause || ' AND f.ent_period_id ='|| p_page_parameter_tbl(i).parameter_id;
            r_where_clause := r_where_clause || ' AND r.ent_period_id ='|| p_page_parameter_tbl(i).parameter_id;
			*/
--			where_clause := where_clause || ' AND eec.initiation_date < (select distinct ent_period_end_date from fii_time_day where ent_period_id = f.ent_period_id) ';

            /*04.25.2006 npanandi: adding below for SQL repository fix**/
			v_period := p_page_parameter_tbl(i).parameter_id;
			where_clause := where_clause || ' AND f.ent_period_id = :WFTIME AND r.ent_period_id = :WRTIME';
            f_where_clause := f_where_clause || ' AND f.ent_period_id = :FWTIME ';
            r_where_clause := r_where_clause || ' AND r.ent_period_id = :RWTIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
--		    v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Q');
		    /** 12.16.2005 npanandi: joining with fii_time_day **/
			/*04.25.2006 npanandi: implementation of passing time parameters
			  has been changed to account for dynamic binding -- see below
            where_clause := where_clause || ' AND f.ent_qtr_id ='|| p_page_parameter_tbl(i).parameter_id|| ' AND r.ent_qtr_id ='|| p_page_parameter_tbl(i).parameter_id;
            f_where_clause := f_where_clause || ' AND f.ent_qtr_id ='|| p_page_parameter_tbl(i).parameter_id;
            r_where_clause := r_where_clause || ' AND r.ent_qtr_id ='|| p_page_parameter_tbl(i).parameter_id;
			*/
--			where_clause := where_clause || ' AND eec.initiation_date < (select distinct ent_qtr_end_date from fii_time_day where ent_qtr_id = f.ent_qtr_id) ';

            /*04.25.2006 npanandi: adding below for SQL repository fix**/
			v_period := p_page_parameter_tbl(i).parameter_id;
			where_clause := where_clause || ' AND f.ent_qtr_id = :WFTIME AND r.ent_qtr_id = :WRTIME';
            f_where_clause := f_where_clause || ' AND f.ent_qtr_id = :FWTIME ';
            r_where_clause := r_where_clause || ' AND r.ent_qtr_id = :RWTIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
--		    v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Y');
		    /** 12.16.2005 npanandi: joining with fii_time_day **/
			/*04.25.2006 npanandi: implementation of passing time parameters
			  has been changed to account for dynamic binding -- see below
            where_clause := where_clause || ' AND f.ent_year_id ='|| p_page_parameter_tbl(i).parameter_id|| ' AND r.ent_year_id ='|| p_page_parameter_tbl(i).parameter_id;
            f_where_clause := f_where_clause || ' AND f.ent_year_id ='|| p_page_parameter_tbl(i).parameter_id;
            r_where_clause := r_where_clause || ' AND r.ent_year_id ='|| p_page_parameter_tbl(i).parameter_id;
			*/
--			where_clause := where_clause || ' AND eec.initiation_date < (select distinct ent_year_end_date from fii_time_day where ent_year_id = f.ent_year_id) ';

            /*04.25.2006 npanandi: adding below for SQL repository fix**/
			v_period := p_page_parameter_tbl(i).parameter_id;
			where_clause := where_clause || ' AND f.ent_year_id = :WFTIME AND r.ent_year_id = :WRTIME';
            f_where_clause := f_where_clause || ' AND f.ent_year_id = :FWTIME ';
            r_where_clause := r_where_clause || ' AND r.ent_year_id = :RWTIME ';
        END IF;
      END IF; -- parameter_id IS NOT NULL
    END LOOP;
-- when no view_parameter is passed in the link e.g. from kpi portlet
    IF view_by_col IS NULL THEN
        view_by_col := ' org.name ';
        group_by_col := 'organization_id  ';
        group_by_col_name := ' v_org_id ';
        join_table := ' ,amw_audit_units_v org ';
        outer_where_clause :=  ' opn.v_org_id = org.organization_id ';
    END IF;

l_sqlstmt :='SELECT DISTINCT
    '|| view_by_col ||' VIEWBY
    ,'|| group_by_col_name ||' VIEWBYID
    ,'''||view_by_name || ''' RCI_DRILLDOWN_PARAM1
    ,'|| group_by_col_name ||' RCI_DRILLDOWN_PARAM2
    ,RCI_PROC_CERT_MEASURE1, RCI_PROC_CERT_MEASURE2
    ,decode(RCI_PROC_CERT_MEASURE1,0,0,round(RCI_PROC_CERT_MEASURE2/RCI_PROC_CERT_MEASURE1*100,2)) RCI_PROC_CERT_MEASURE3
    ,RCI_PROC_CERT_MEASURE4, RCI_PROC_CERT_MEASURE5, RCI_PROC_CERT_MEASURE6
    ,RCI_PROC_CERT_MEASURE7, RCI_PROC_CERT_MEASURE8, RCI_PROC_CERT_MEASURE9
    ,RCI_PROC_CERT_MEASURE10
    ,decode(RCI_PROC_CERT_MEASURE10,0,0,round(RCI_PROC_CERT_MEASURE10/RCI_PROC_CERT_MEASURE9*100,2)) RCI_PROC_CERT_MEASURE11
    ,RCI_PROC_CERT_MEASURE12
    ,RCI_PROC_CERT_MEASURE13, RCI_PROC_CERT_MEASURE14, RCI_PROC_CERT_MEASURE15
    ,RCI_PROC_CERT_MEASURE16
    FROM (
   select
	'||group_by_col_name||'
    ,sum(r_open)         RCI_PROC_CERT_MEASURE1
    ,sum(r_past_due)     RCI_PROC_CERT_MEASURE2
    ,sum(r_AGE_IN_DAYS ) RCI_PROC_CERT_MEASURE4
    ,sum(r_AGE_BUCKET_1) RCI_PROC_CERT_MEASURE5
    ,sum(r_AGE_BUCKET_2) RCI_PROC_CERT_MEASURE6
    ,sum(r_AGE_BUCKET_3) RCI_PROC_CERT_MEASURE7
    ,sum(r_AGE_BUCKET_4) RCI_PROC_CERT_MEASURE8
    ,sum(f_open)         RCI_PROC_CERT_MEASURE9
    ,sum(f_past_due)     RCI_PROC_CERT_MEASURE10
    ,sum(f_AGE_IN_DAYS ) RCI_PROC_CERT_MEASURE12
    ,sum(f_AGE_BUCKET_1) RCI_PROC_CERT_MEASURE13
    ,sum(f_AGE_BUCKET_2) RCI_PROC_CERT_MEASURE14
    ,sum(f_AGE_BUCKET_3) RCI_PROC_CERT_MEASURE15
    ,sum(f_AGE_BUCKET_4) RCI_PROC_CERT_MEASURE16
from(
   SELECT  f.'|| group_by_col ||group_by_col_name||'
		,sum(f.open) f_open
		,sum(f.past_due) f_past_due
		,round(avg(f.AGE_IN_DAYS )) f_AGE_IN_DAYS
		,sum(f.AGE_BUCKET_1) f_AGE_BUCKET_1
		,sum(f.AGE_BUCKET_2) f_AGE_BUCKET_2
		,sum(f.AGE_BUCKET_3) f_AGE_BUCKET_3
		,sum(f.AGE_BUCKET_4) f_AGE_BUCKET_4
		,0 r_open
		,0 r_past_due
		,0 r_AGE_IN_DAYS
		,0 r_AGE_BUCKET_1
		,0 r_AGE_BUCKET_2
		,0 r_AGE_BUCKET_3
		,0 r_AGE_BUCKET_4
    FROM
		RCI_OPEN_FINDINGS_F f
    WHERE f.open=1 AND f.age_in_days >= 0
    '|| f_where_clause || '
	group by  f.'|| group_by_col || '
UNION
   SELECT  r.'|| group_by_col ||group_by_col_name||'
        ,0 f_open
        ,0 f_past_due
        ,0 f_AGE_IN_DAYS
        ,0 f_AGE_BUCKET_1
        ,0 f_AGE_BUCKET_2
        ,0 f_AGE_BUCKET_3
        ,0 f_AGE_BUCKET_4
        ,sum(r.open) r_open
        ,sum(r.past_due) r_past_due
        ,round(avg(r.AGE_IN_DAYS )) r_AGE_IN_DAYS
        ,sum(r.AGE_BUCKET_1) r_AGE_BUCKET_1
        ,sum(r.AGE_BUCKET_2) r_AGE_BUCKET_2
        ,sum(r.AGE_BUCKET_3) r_AGE_BUCKET_3
        ,sum(r.AGE_BUCKET_4) r_AGE_BUCKET_4
    FROM
		RCI_OPEN_REMEDIATIONS_F r
    WHERE r.open=1 AND r.age_in_days >= 0
    '|| r_where_clause || '
	group by  r.'|| group_by_col || '
) group by  '||group_by_col_name||'
     ) opn '
    || join_table
    || ' where
    ' ||outer_where_clause
;

   /** 09.18.2006 npanandi: added SQL below to handle order_by_clause -- bug 5510667 **/
   l_act_sqlstmt := 'select VIEWBY,VIEWBYID,RCI_DRILLDOWN_PARAM1,RCI_DRILLDOWN_PARAM2
                    ,RCI_PROC_CERT_MEASURE1,RCI_PROC_CERT_MEASURE2,RCI_PROC_CERT_MEASURE3
					,RCI_PROC_CERT_MEASURE4,RCI_PROC_CERT_MEASURE5,RCI_PROC_CERT_MEASURE6
					,RCI_PROC_CERT_MEASURE7,RCI_PROC_CERT_MEASURE8,RCI_PROC_CERT_MEASURE9
					,RCI_PROC_CERT_MEASURE10,RCI_PROC_CERT_MEASURE11
					,RCI_PROC_CERT_MEASURE12,RCI_PROC_CERT_MEASURE13
					,RCI_PROC_CERT_MEASURE14,RCI_PROC_CERT_MEASURE15
					,RCI_PROC_CERT_MEASURE16
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_sqlstmt||'
							 ) t ) a
					   order by a.col_rank ';


--todo remove the status_code condition
p_exp_source_sql := l_act_sqlstmt;

   /**04.25.2006 npanandi: adding code for dynamic binding of time period dimensions**/
	p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':WFTIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':WRTIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':FWTIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

	p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':RWTIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;
    /**04.25.2006 npanandi: finished code for dynamic binding of time period dimensions**/

END get_open_remediation_result;

PROCEDURE get_findings_details(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
    counter NUMBER := 0;
    l_sqlstmt VARCHAR2(15000);
    where_clause VARCHAR2(2000) := ' ';
    param_name VARCHAR2(99) ;
    param_value VARCHAR2(99);
    v_yyyymm varchar2(6);

	v_period   varchar2(100);
    v_qtr      varchar2(100);
    v_year     varchar2(100);
    l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN
    counter := p_page_parameter_tbl.COUNT;
    FOR i IN 1..counter LOOP
      IF p_page_parameter_tbl(i).parameter_id IS NOT NULL THEN
        IF p_page_parameter_tbl(i).parameter_name = 'PARAM_VALUE' THEN
            param_value := p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'PARAM_NAME' THEN
            param_name := p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'OPEN' THEN
            where_clause := where_clause || ' AND f.open=1 ';
/*dpatel 21-dec-05*/
--           where_clause := where_clause || ' AND (f.completion_date is null OR round(f.completion_date-last_day(to_date('''||v_yyyymm||''',''YYYYMM''))) >0 ) ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'PAST_DUE' THEN
            where_clause := where_clause || ' AND f.past_due=1 ';
/*dpatel 21-dec-05*/
--            where_clause := where_clause || ' AND (round(last_day(to_date('''||v_yyyymm||''',''YYYYMM''))-f.need_by_date) >0 AND (f.completion_date is null OR round(f.completion_date-last_day(to_date('''||v_yyyymm||''',''YYYYMM''))) >0) ) ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'BUCKET_ID' THEN
            where_clause := where_clause || ' AND f.age_bucket_'||p_page_parameter_tbl(i).parameter_id ||'=1 ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' THEN
            where_clause := where_clause || ' AND f.organization_id ='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
            where_clause := where_clause || ' AND f.process_id ='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_PRIORITY+RCI_ISSUE_PRIORITY' THEN
            where_clause := where_clause || ' AND f.priority_code ='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_REASON+RCI_ISSUE_REASON' THEN
            where_clause := where_clause || ' AND f.reason_code ='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_PHASE+RCI_ISSUE_PHASE' THEN
            where_clause := where_clause || ' AND f.phase_code='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
            v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'M');
            /*04.25.2006 npanandi: commenting below, to enable dynamic binding, see below
			where_clause := where_clause || ' AND f.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
			*/

			/*04.25.2006 npanandi: adding below for SQL repository fix**/
			v_period := p_page_parameter_tbl(i).parameter_id;
			where_clause := where_clause || ' AND f.ent_period_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
            v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Q');
			/*04.25.2006 npanandi: commenting below, to enable dynamic binding, see below
            where_clause := where_clause || ' AND f.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
			*/

			/*04.25.2006 npanandi: adding below for SQL repository fix**/
			v_period := p_page_parameter_tbl(i).parameter_id;
			where_clause := where_clause || ' AND f.ent_qtr_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
            v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Y');
            /*04.25.2006 npanandi: commenting below, to enable dynamic binding, see below
			where_clause := where_clause || ' AND f.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
			**/

			/*04.25.2006 npanandi: adding below for SQL repository fix**/
			v_period := p_page_parameter_tbl(i).parameter_id;
			where_clause := where_clause || ' AND f.ent_year_id = :TIME ';
/*dpatel 21-dec-05*/
/*        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
            v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'M');
            where_clause := where_clause || ' AND (f.completion_date is null or round(f.completion_date- last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) )>0) ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
            v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Q');
            where_clause := where_clause || ' AND (f.completion_date is null or round(f.completion_date- last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) )>0) ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
            v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Y');
            where_clause := where_clause || ' AND (f.completion_date is null or round(f.completion_date- last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) )>0) ';
*/        END IF;
      END IF; -- parameter_id IS NOT NULL
    END LOOP;

    IF v_yyyymm IS NULL THEN
        v_yyyymm := TO_CHAR(sysdate,'YYYYMM');
    END IF;

    IF param_name IS NOT NULL THEN
        IF(Trim(param_value) IS NULL) THEN
            IF param_name = 'ORGANIZATION+RCI_ORG_AUDIT' THEN
                where_clause := where_clause || ' AND f.organization_id is null ';
            ELSIF param_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
                where_clause := where_clause || ' AND f.process_id is null ';
            ELSIF param_name = '+RCI_ISSUE_PRIORITY' THEN
                where_clause := where_clause || ' AND f.priority_code is null ';
            ELSIF param_name = '+RCI_ISSUE_REASON' THEN
                where_clause := where_clause || ' AND f.reason_code is null ';
            ELSIF param_name = '+RCI_ISSUE_PHASE' THEN
                where_clause := where_clause || ' AND f.phase_code is null ';
            END IF;
        END IF;
    END IF;

l_sqlstmt :='
    SELECT
        ecv.change_id RCI_DRILLDOWN_PARAM1
        ,ecv.change_name RCI_PROC_CERT_MEASURE7
        ,ecv.requestor RCI_PROC_CERT_MEASURE1
        ,ecst.status_name RCI_PROC_CERT_MEASURE2
        ,ecv.priority_code RCI_PROC_CERT_MEASURE3
        ,ecv.reported_days_since RCI_PROC_CERT_MEASURE4
        ,-ecv.days_until_due RCI_PROC_CERT_MEASURE5
        ,trunc(last_day(to_date('''||v_yyyymm||''',''YYYYMM''))-ecv.days_until_due) RCI_PROC_CERT_MEASURE6
    FROM
        eng_changes_v ecv, eng_change_statuses_tl ecst
    WHERE
        change_mgmt_type_code = ''AMW_PROJ_FINDING''
		and ecst.status_code = ecv.status_code
		and ecst.language = userenv(''LANG'')
        and change_id in (  SELECT
                            finding_id
                        FROM
                            rci_open_findings_f f
                        WHERE age_in_days >= 0
						/** 12.26.2005 npanandi: added following clause to display
						               only OPEN findings from rci_open_findings_f
									   bug 4908320 fix ***/
						  and f.OPEN=1
						' || where_clause ||
                    ')'
    ;
p_exp_source_sql := l_sqlstmt;

   /**04.25.2006 npanandi: adding code for dynamic binding of time period dimensions**/
	p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':TIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;
    /**04.25.2006 npanandi: finished code for dynamic binding of time period dimensions**/

END get_findings_details;

PROCEDURE get_remediations_details(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
    counter NUMBER := 0;
    l_sqlstmt VARCHAR2(15000);
    where_clause VARCHAR2(2000) := ' ';
    param_name VARCHAR2(99) := ' ';
    param_value VARCHAR2(99) := ' ';
    v_yyyymm varchar2(6);

	v_period   varchar2(100);
    v_qtr      varchar2(100);
    v_year     varchar2(100);
    l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN

    counter := p_page_parameter_tbl.COUNT;
    FOR i IN 1..counter LOOP
      IF p_page_parameter_tbl(i).parameter_id IS NOT NULL THEN
        IF p_page_parameter_tbl(i).parameter_name = 'PARAM_VALUE' THEN
            param_value := p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'PARAM_NAME' THEN
            param_name := p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'OPEN' THEN
            where_clause := where_clause || ' AND r.open=1 ';
/*dpatel 21-dec-05*/
--           where_clause := where_clause || ' AND (r.completion_date is null OR round(r.completion_date-last_day(to_date('''||v_yyyymm||''',''YYYYMM''))) >0 ) ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'PAST_DUE' THEN
            where_clause := where_clause || ' AND r.past_due=1 ';
/*dpatel 21-dec-05*/
--            where_clause := where_clause || ' AND (round(last_day(to_date('''||v_yyyymm||''',''YYYYMM''))-r.need_by_date) >0 AND(r.completion_date is null OR round(r.completion_date-last_day(to_date('''||v_yyyymm||''',''YYYYMM''))) >0) ) ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'BUCKET_ID' THEN
            where_clause := where_clause || ' AND r.age_bucket_'||p_page_parameter_tbl(i).parameter_id ||'=1 ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' THEN
		    if(p_page_parameter_tbl(i).parameter_id is not null and trim(p_page_parameter_tbl(i).parameter_id) is not null) then
               where_clause := where_clause || ' AND r.organization_id ='|| p_page_parameter_tbl(i).parameter_id ||' ';
			end if;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
            where_clause := where_clause || ' AND r.process_id ='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_PRIORITY+RCI_ISSUE_PRIORITY' THEN
            where_clause := where_clause || ' AND r.priority_code ='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_REASON+RCI_ISSUE_REASON' THEN
            where_clause := where_clause || ' AND r.reason_code ='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_PHASE+RCI_ISSUE_PHASE' THEN
            where_clause := where_clause || ' AND r.phase_code='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
            v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'M');
			/*04.25.2006 npanandi: commenting below, to enable dynamic binding, see below
            where_clause := where_clause || ' AND r.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
			*/

			/*04.25.2006 npanandi: adding below for SQL repository fix**/
			v_period := p_page_parameter_tbl(i).parameter_id;
			where_clause := where_clause || ' AND r.ent_period_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
            v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Q');
            /*04.25.2006 npanandi: commenting below, to enable dynamic binding, see below
			where_clause := where_clause || ' AND r.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
			*/

			/*04.25.2006 npanandi: adding below for SQL repository fix**/
			v_period := p_page_parameter_tbl(i).parameter_id;
			where_clause := where_clause || ' AND r.ent_qtr_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
            v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Y');
            /*04.25.2006 npanandi: commenting below, to enable dynamic binding, see below
			where_clause := where_clause || ' AND r.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
			*/

			/*04.25.2006 npanandi: adding below for SQL repository fix**/
			v_period := p_page_parameter_tbl(i).parameter_id;
			where_clause := where_clause || ' AND r.ent_year_id = :TIME ';
/*dpatel 21-dec-05*/
/*        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
            v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'M');
            where_clause := where_clause || ' AND (r.completion_date is null or round(r.completion_date- last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) )>0) ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
            v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Q');
            where_clause := where_clause || ' AND (r.completion_date is null or round(r.completion_date- last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) )>0) ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
            v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Y');
            where_clause := where_clause || ' AND (r.completion_date is null or round(r.completion_date- last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) )>0) ';
*/        END IF;
      END IF; -- parameter_id IS NOT NULL
    END LOOP;

    IF v_yyyymm IS NULL THEN
        v_yyyymm := TO_CHAR(sysdate,'YYYYMM');
    END IF;

    IF param_name IS NOT NULL THEN
        IF(Trim(param_value) IS NULL) THEN
        	IF param_name = 'ORGANIZATION+RCI_ORG_AUDIT' THEN
               where_clause := where_clause || ' AND r.organization_id is null ';
            ELSIF param_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
                where_clause := where_clause || ' AND r.process_id is null ';
            ELSIF param_name = '+RCI_ISSUE_PRIORITY' THEN
                where_clause := where_clause || ' AND r.priority_code is null ';
            ELSIF param_name = '+RCI_ISSUE_REASON' THEN
                where_clause := where_clause || ' AND r.reason_code is null ';
            ELSIF param_name = '+RCI_ISSUE_PHASE' THEN
                where_clause := where_clause || ' AND r.phase_code is null ';
            END IF;
        END IF;
	END IF;

l_sqlstmt :='
    SELECT
        ecv.change_id RCI_DRILLDOWN_PARAM1
        ,ecv.change_name RCI_PROC_CERT_MEASURE7
        ,ecv.requestor RCI_PROC_CERT_MEASURE1
        ,ecst.status_name RCI_PROC_CERT_MEASURE2
        ,ecv.priority_code RCI_PROC_CERT_MEASURE3
        ,ecv.reported_days_since RCI_PROC_CERT_MEASURE4
        ,-ecv.days_until_due RCI_PROC_CERT_MEASURE5
        ,trunc(last_day(to_date('''||v_yyyymm||''',''YYYYMM''))-ecv.days_until_due) RCI_PROC_CERT_MEASURE6
    FROM
        eng_changes_v ecv, eng_change_statuses_tl ecst
    WHERE
        ecv.change_mgmt_type_code = ''AMW_REMEDIATION''
		and ecst.status_code = ecv.status_code
		and ecst.language = userenv(''LANG'')
		/** 12.19.2005 npanandi: adding the below, because only those remediations
		    should be chosen which are initiated BEFORE the chosen periods last day
			**/
	    and ecv.INITIATION_DATE < last_day(to_date('''||v_yyyymm||''',''YYYYMM''))
		/** 12.19.2005 npanandi: need to see if this is open, and if not open,
			               whether it was set to completed AFTER the last day of the
						   chosen period ***/
		and (ecv.STATUS_CODE not in (0,11) or (ecv.status_code=11 and round(ecv.last_update_date-last_day(to_date('''||v_yyyymm||''',''YYYYMM''))) > 0 ))
        and ecv.change_id in (  SELECT
                            remediation_id
                        FROM
                            rci_open_remediations_f r
                        WHERE 1=1 ' || where_clause ||
                    ')'
    ;

p_exp_source_sql := l_sqlstmt;

   /**04.25.2006 npanandi: adding code for dynamic binding of time period dimensions**/
	p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':TIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;
    /**04.25.2006 npanandi: finished code for dynamic binding of time period dimensions**/


END get_remediations_details;

/*
--Procedure to be called from concurrent program--
*/
PROCEDURE open_remed_act_increment_load
(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER)
IS
BEGIN
    EXECUTE IMMEDIATE ('TRUNCATE TABLE amw.RCI_OPEN_FINDINGS_F');
    EXECUTE IMMEDIATE ('TRUNCATE TABLE amw.RCI_OPEN_REMEDIATIONS_F');
    insert_findings_increment_load(
   errbuf    => errbuf
  ,retcode   => retcode);

    insert_remeds_increment_load(
   errbuf    => errbuf
  ,retcode   => retcode);
    EXECUTE IMMEDIATE ('COMMIT');
END open_remed_act_increment_load;

PROCEDURE open_remed_act_initial_load
(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER)
IS
   l_user_id                NUMBER ;
   l_login_id               NUMBER ;
   l_program_id             NUMBER ;
   l_program_login_id       NUMBER ;
   l_program_application_id NUMBER ;
   l_request_id             NUMBER ;
   l_run_date      DATE;

BEGIN

    insert_findings_initial_load(
   errbuf    => errbuf
  ,retcode   => retcode);

    insert_remeds_initial_load(
   errbuf    => errbuf
  ,retcode   => retcode);

  /***
    l_user_id                := NVL(fnd_global.USER_ID, -1);
    l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
    l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
    l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
    l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
    l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);
    l_run_date := sysdate - 5/(24*60);

   INSERT INTO rci_dr_inc(  fact_name
     ,last_run_date
     ,created_by
     ,creation_date
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,program_id
     ,program_login_id
     ,program_application_id
     ,request_id ) VALUES (
	 'RCI_OPEN_FINDINGS_F'
     ,l_run_date
     ,l_user_id
     ,sysdate
     ,sysdate
     ,l_user_id
     ,l_login_id
     ,l_program_id
     ,l_program_login_id
     ,l_program_application_id
     ,l_request_id );
   INSERT INTO rci_dr_inc(  fact_name
     ,last_run_date
     ,created_by
     ,creation_date
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,program_id
     ,program_login_id
     ,program_application_id
     ,request_id ) VALUES (
	 'RCI_OPEN_REMEDIATIONS_F'
     ,l_run_date
     ,l_user_id
     ,sysdate
     ,sysdate
     ,l_user_id
     ,l_login_id
     ,l_program_id
     ,l_program_login_id
     ,l_program_application_id
     ,l_request_id );

    EXECUTE IMMEDIATE ('COMMIT');
	***/

END open_remed_act_initial_load;

PROCEDURE insert_findings_increment_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER) IS
BEGIN
    insert_findings_initial_load(
   errbuf    => errbuf
  ,retcode   => retcode);

END insert_findings_increment_load;

/** 12.16.2005 npanandi: changed a lot of things here
    added valid report_date_julian in the ETL insert
	added entries in rci_dr_inc audit table for every load
	added misc procedures -- check_initial_load_setup and err_mesg
	**/
PROCEDURE insert_findings_initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER) IS

CURSOR c_find_age IS
	SELECT
        DISTINCT finding_id, age_in_days
    FROM
        rci_open_findings_f rof;

CURSOR c_find IS
	SELECT
        DISTINCT finding_id
    FROM
        rci_open_findings_f rof, eng_change_subjects ecs
	WHERE
        rof.finding_id = ecs.change_id AND
        (ecs.entity_name = 'PROJ_ORG' OR ecs.entity_name = 'PROJ_ORG_PROC');

CURSOR c_ch_sub(p_change_id eng_change_subjects.change_id%TYPE) IS
    SELECT
        entity_name, pk1_value
    FROM
        eng_change_subjects ecs
    WHERE change_id = p_change_id;

v_finding_id rci_open_findings_f.finding_id%TYPE;
v_age rci_open_findings_f.age_in_days%TYPE;
v_bucket_1 Number;
v_bucket_2 Number;
v_bucket_3 Number;
v_bucket_4 Number;
v_end_date date;
v_period number;
v_qtr number;
v_year number;
q number(1);

l_stmnt_id      NUMBER := 0;
l_run_date      DATE;
l_proc_name     VARCHAR2(30);
l_status        VARCHAR2(30) ;
l_industry      VARCHAR2(30) ;

l_user_id                NUMBER ;
l_login_id               NUMBER ;
l_program_id             NUMBER ;
l_program_login_id       NUMBER ;
l_program_application_id NUMBER ;
l_request_id             NUMBER ;

BEGIN
   l_user_id                := NVL(fnd_global.USER_ID, -1);
   l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
   l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
   l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
   l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
   l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);

   ----dbms_output.put_line( '1 **************' );

   l_stmnt_id := 0;
   l_proc_name := 'intitial_load';
   check_initial_load_setup(
      x_global_start_date => g_global_start_date
     ,x_rci_schema        => g_rci_schema);

   l_stmnt_id := 10;
   DELETE FROM rci_dr_inc where fact_name = 'RCI_OPEN_FINDINGS_F';

   ----dbms_output.put_line( '2 **************' );

   l_stmnt_id := 20;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_OPEN_FINDINGS_F');

   ----dbms_output.put_line( '3 **************' );
   l_stmnt_id := 30;
   l_run_date := sysdate - 5/(24*60);


    FOR y IN 2001..2010 LOOP
        FOR m IN 1..12 LOOP
            v_end_date := last_day(to_date(to_char(y)||to_char(m),'YYYYMM'));

            CASE m
                WHEN 3 THEN
                    v_qtr := to_number(to_char(y)||'1');
                WHEN 6 THEN
                    v_qtr := to_number(to_char(y)||'2');
                WHEN 9 THEN
                    v_qtr := to_number(to_char(y)||'3');
                WHEN 12 THEN
                    v_qtr := to_number(to_char(y)||'4');
                    v_year := y;
                ELSE
                    v_qtr := null;
                    v_year := null;
            END CASE;

            q := floor((m-1)/3)+1;
			if(m < 10)then
               v_period := to_number(to_char(y)||to_char(q)||'0'||to_char(m));
			else
			   v_period := to_number(to_char(y)||to_char(q)||to_char(m));
			end if;

            INSERT INTO rci_open_findings_f (
                finding_id, priority_code, reason_code, phase_code,
                age_in_days,
                need_by_date, completion_date,
                open, past_due,
                period_year, period_num, quarter_num,
                ent_period_id, ent_qtr_id, ent_year_id,
                report_date_julian,
                created_by,last_update_login,creation_date,last_updated_by,last_update_date)
            SELECT
                eec1.change_id , eec1.priority_code, eec1.reason_code, eec1.status_code,
                ROUND(v_end_date-eec1.initiation_date),
                eec1.need_by_date, eec1.implementation_date,
                case when(eec1.STATUS_CODE not in (0,11) or (eec1.status_code=11 and round(eec1.last_update_date-v_end_date) > 0 )) then 1 else 0 end,
--                case when( implementation_date is null or round(implementation_date-v_end_date)>0) then 1 else 0 end,
                case when( round(v_end_date-need_by_date)>0 and (implementation_date is null or (implementation_date-v_end_date) >0 )) then 1 else 0 end,
                y, m, q,
                v_period, v_qtr, v_year,
				to_number(to_char(v_end_date,'J')),/** 12.16.2005 npanandi: added report_date_julian **/
                G_USER_ID, G_USER_ID, SYSDATE, G_USER_ID, SYSDATE
            FROM
                eng_engineering_changes eec1
            WHERE
                eec1.change_mgmt_type_code = 'AMW_PROJ_FINDING';
        END LOOP;--inner loop
    END LOOP;--outer loop

-- to update the bucket ids
    FOR r_find_age IN c_find_age LOOP
        v_finding_id := r_find_age.finding_id;
        v_age := r_find_age.age_in_days;
        fn_get_Bucket_Id(v_age, v_bucket_1,v_bucket_2,v_bucket_3,v_bucket_4);
        UPDATE rci_open_findings_f
            SET age_bucket_1 = v_bucket_1 , age_bucket_2 = v_bucket_2,
                age_bucket_3 = v_bucket_3, age_bucket_4 = v_bucket_4
            WHERE finding_id = v_finding_id;
    END LOOP;

-- to update the organization id and process id
    FOR r_find IN c_find LOOP
        v_finding_id := r_find.finding_id;
        FOR r_ch_sub IN c_ch_sub(v_finding_id) LOOP
            IF r_ch_sub.entity_name = 'PROJ_ORG' THEN
                UPDATE rci_open_findings_f
                    SET organization_id = r_ch_sub.pk1_value
                	WHERE finding_id = v_finding_id;
            ELSIF r_ch_sub.entity_name = 'PROJ_ORG_PROC' THEN
                UPDATE rci_open_findings_f
                    SET process_id = r_ch_sub.pk1_value
            		WHERE finding_id = v_finding_id;
        	END IF;
		END LOOP;
    END LOOP;

	begin
	UPDATE rci_dr_inc
		   SET last_run_date             = l_run_date
              ,last_update_date          = sysdate
              ,last_updated_by           = l_user_id
              ,last_update_login         = l_login_id
              ,program_id                = l_program_id
              ,program_login_id          = l_program_login_id
              ,program_application_id    = l_program_application_id
              ,request_id                = l_request_id
	WHERE fact_name = 'RCI_OPEN_FINDINGS_F' ;

	IF (SQL%NOTFOUND) THEN
     RAISE  NO_DATA_FOUND;
   END IF;

	exception
       when NO_DATA_FOUND then
	      INSERT INTO rci_dr_inc(  fact_name
     	  		 	  			   ,last_run_date
							     ,created_by
							     ,creation_date
							     ,last_update_date
							     ,last_updated_by
							     ,last_update_login
							     ,program_id
							     ,program_login_id
							     ,program_application_id
							     ,request_id ) VALUES (
								 'RCI_OPEN_FINDINGS_F'
							     ,l_run_date
							     ,l_user_id
							     ,sysdate
							     ,sysdate
							     ,l_user_id
							     ,l_login_id
							     ,l_program_id
							     ,l_program_login_id
							     ,l_program_application_id
							     ,l_request_id );
    end;

	l_stmnt_id := 70;
   commit;
   retcode := C_OK;

EXCEPTION
   WHEN OTHERS THEN
      retcode := C_ERROR;
	  ----dbms_output.put_line( 'In OTHERS **************' );
	  ----dbms_output.put_line( 'errmsdg: '||substr ((l_proc_name || ' #' ||to_char (l_stmnt_id) || ': ' || SQLERRM),
              -----                         1, C_ERRBUF_SIZE) );
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name, l_stmnt_id));
      ROLLBACK;
      RAISE;

END insert_findings_initial_load;

PROCEDURE insert_remeds_increment_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER) IS
BEGIN
    insert_remeds_initial_load(
   errbuf    => errbuf
  ,retcode   => retcode);
END insert_remeds_increment_load;

/** 12.16.2005 npanandi: changed a lot of things here
    added valid report_date_julian in the ETL insert
	added entries in rci_dr_inc audit table for every load
	added misc procedures -- check_initial_load_setup and err_mesg
	**/
PROCEDURE insert_remeds_initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER) IS

CURSOR c_remed_age IS
	SELECT
        DISTINCT finding_id, age_in_days
    FROM
        rci_open_remediations_f;

CURSOR c_remed IS
	SELECT
        DISTINCT finding_id, age_in_days
    FROM
        rci_open_remediations_f rof, eng_change_subjects ecs
	WHERE
        rof.finding_id = ecs.change_id AND
        (ecs.entity_name = 'PROJ_ORG' OR ecs.entity_name = 'PROJ_ORG_PROC');

CURSOR c_ch_sub(p_change_id eng_change_subjects.change_id%TYPE) IS
    SELECT
        entity_name, pk1_value
    FROM
        eng_change_subjects ecs
    WHERE change_id = p_change_id;
v_finding_id rci_open_remediations_f.finding_id%TYPE;
v_age rci_open_remediations_f.age_in_days%TYPE;
v_bucket_1 Number;
v_bucket_2 Number;
v_bucket_3 Number;
v_bucket_4 Number;
v_end_date date;
v_period number;
v_qtr number;
v_year number;
q number(1);

l_stmnt_id      NUMBER := 0;
   l_run_date      DATE;
   l_proc_name     VARCHAR2(30);
   l_status        VARCHAR2(30) ;
   l_industry      VARCHAR2(30) ;

l_user_id                NUMBER ;
   l_login_id               NUMBER ;
   l_program_id             NUMBER ;
   l_program_login_id       NUMBER ;
   l_program_application_id NUMBER ;
   l_request_id             NUMBER ;
BEGIN
   l_user_id                := NVL(fnd_global.USER_ID, -1);
   l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
   l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
   l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
   l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
   l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);

   ----dbms_output.put_line( '1 **************' );

   l_stmnt_id := 0;
   l_proc_name := 'intitial_load';
   check_initial_load_setup(
      x_global_start_date => g_global_start_date
     ,x_rci_schema        => g_rci_schema);

   l_stmnt_id := 10;
   DELETE FROM rci_dr_inc where fact_name = 'RCI_OPEN_REMEDIATIONS_F';

   ----dbms_output.put_line( '2 **************' );

   l_stmnt_id := 20;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_OPEN_REMEDIATIONS_F');

   ----dbms_output.put_line( '3 **************' );
   l_stmnt_id := 30;
   l_run_date := sysdate - 5/(24*60);

    FOR y IN 2001..2010 LOOP
        FOR m IN 1..12 LOOP
            v_end_date := last_day(to_date(to_char(y)||to_char(m),'YYYYMM'));

            CASE m
                WHEN 3 THEN
                    v_qtr := to_number(to_char(y)||'1');
                WHEN 6 THEN
                    v_qtr := to_number(to_char(y)||'2');
                WHEN 9 THEN
                    v_qtr := to_number(to_char(y)||'3');
                WHEN 12 THEN
                    v_qtr := to_number(to_char(y)||'4');
                    v_year := y;
                ELSE
                    v_qtr := null;
                    v_year := null;
            END CASE;

            q := floor((m-1)/3)+1;
			if(m < 10)then
			   v_period := to_number(to_char(y)||to_char(q)||'0'||to_char(m));
			else
			   v_period := to_number(to_char(y)||to_char(q)||to_char(m));
			end if;

            INSERT INTO rci_open_remediations_f(
                finding_id, remediation_id, priority_code, reason_code, phase_code,
                age_in_days,
                need_by_date, completion_date,
                open, past_due,
                period_year, period_num, quarter_num,
                ent_period_id, ent_qtr_id, ent_year_id,
                report_date_julian,
                created_by,last_update_login,creation_date,last_updated_by,last_update_date)
            SELECT
                ecor.change_id , ecor.object_to_id1, eec1.priority_code, eec1.reason_code, eec1.status_code,
                ROUND(v_end_date-eec1.initiation_date),
                eec1.need_by_date, eec1.implementation_date,
                case when(eec1.STATUS_CODE not in (0,11) or (eec1.status_code=11 and round(eec1.last_update_date-v_end_date) > 0 )) then 1 else 0 end,
--                case when( implementation_date is null or round(implementation_date-v_end_date)>0) then 1 else 0 end,
                case when( round(v_end_date-need_by_date)>0 and (implementation_date is null or (implementation_date-v_end_date) >0 )) then 1 else 0 end,
                y, m, q,
                v_period, v_qtr, v_year,
				to_number(to_char(v_end_date,'J')),/** 12.16.2005 npanandi: added report_date_julian **/
                G_USER_ID, G_USER_ID, SYSDATE, G_USER_ID, SYSDATE
            FROM
                eng_engineering_changes eec1, eng_change_obj_relationships ecor
            WHERE
                eec1.change_mgmt_type_code = 'AMW_REMEDIATION'
                AND ecor.relationship_code = 'RESOLVED_BY'
                AND eec1.change_id = ecor.object_to_id1;

        END LOOP;--inner loop
    END LOOP;--outer loop

-- to update the bucket ids
    FOR r_remed_age IN c_remed_age LOOP
        v_finding_id := r_remed_age.finding_id;
        v_age := r_remed_age.age_in_days;
        fn_get_Bucket_Id(v_age, v_bucket_1,v_bucket_2,v_bucket_3,v_bucket_4);
        UPDATE rci_open_remediations_f
            SET age_bucket_1 = v_bucket_1 , age_bucket_2 = v_bucket_2,
                age_bucket_3 = v_bucket_3, age_bucket_4 = v_bucket_4
            WHERE finding_id = v_finding_id;
    END LOOP;

-- to update the organization id and process id
    FOR r_remed in c_remed LOOP
        v_finding_id := r_remed.finding_id;
        FOR r_ch_sub in c_ch_sub(v_finding_id) LOOP
            IF r_ch_sub.entity_name = 'PROJ_ORG' THEN
                update rci_open_remediations_f set organization_id = r_ch_sub.pk1_value
                	WHERE finding_id = v_finding_id;
            ELSIF r_ch_sub.entity_name = 'PROJ_ORG_PROC' THEN
                update rci_open_remediations_f set process_id = r_ch_sub.pk1_value
            		WHERE finding_id = v_finding_id;
        	END IF;
		END LOOP;
    END LOOP;

	begin
	UPDATE rci_dr_inc
		   SET last_run_date             = l_run_date
              ,last_update_date          = sysdate
              ,last_updated_by           = l_user_id
              ,last_update_login         = l_login_id
              ,program_id                = l_program_id
              ,program_login_id          = l_program_login_id
              ,program_application_id    = l_program_application_id
              ,request_id                = l_request_id
	WHERE fact_name = 'RCI_OPEN_REMEDIATIONS_F' ;

	IF (SQL%NOTFOUND) THEN
     RAISE  NO_DATA_FOUND;
   END IF;

	exception
       when NO_DATA_FOUND then
	      INSERT INTO rci_dr_inc(  fact_name
     	  		 	  			   ,last_run_date
							     ,created_by
							     ,creation_date
							     ,last_update_date
							     ,last_updated_by
							     ,last_update_login
							     ,program_id
							     ,program_login_id
							     ,program_application_id
							     ,request_id ) VALUES (
								 'RCI_OPEN_REMEDIATIONS_F'
							     ,l_run_date
							     ,l_user_id
							     ,sysdate
							     ,sysdate
							     ,l_user_id
							     ,l_login_id
							     ,l_program_id
							     ,l_program_login_id
							     ,l_program_application_id
							     ,l_request_id );
    end;

	l_stmnt_id := 70;
   commit;
   retcode := C_OK;

EXCEPTION
   WHEN OTHERS THEN
      retcode := C_ERROR;
	  ----dbms_output.put_line( 'In OTHERS **************' );
	  ----dbms_output.put_line( 'errmsdg: '||substr ((l_proc_name || ' #' ||to_char (l_stmnt_id) || ': ' || SQLERRM),
              -----                         1, C_ERRBUF_SIZE) );
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name, l_stmnt_id));
      ROLLBACK;
      RAISE;
END insert_remeds_initial_load;

PROCEDURE fn_Get_Bucket_Id(age_in_days Number, v_1 out NOCOPY Number, v_2 out NOCOPY Number, v_3 out NOCOPY Number, v_4 out NOCOPY Number)
IS
v_bucket_id Number := 0;
BEGIN
    v_1 := 0; v_2 := 0; v_3 := 0; v_4 := 0;
--todo remove the hardcoding
    CASE
    WHEN age_in_days BETWEEN 0 AND 1 THEN
        v_bucket_id := 1;
        v_1 := 1;
    WHEN age_in_days BETWEEN 2 AND 5 THEN
        v_bucket_id := 2;
        v_2 := 1;
    WHEN age_in_days BETWEEN 6 AND 10 THEN
        v_bucket_id := 3;
        v_3 := 1;
    WHEN age_in_days > 10 THEN
        v_bucket_id := 4;
        v_4 := 1;
    ELSE
        v_1 := 0; v_2 := 0; v_3 := 0; v_4 := 0;
    END CASE;
END fn_get_Bucket_Id;

FUNCTION get_last_day(date_id NUMBER, type VARCHAR2) return varchar2
IS
v_year varchar2(4);
v_month varchar2(2);
v_qtr number(1);
BEGIN
    IF type='M' THEN
        v_year := SUBSTR(date_id,1,4);
        v_month := SUBSTR(date_id,6);
    ELSIF type='Q' THEN
        v_year := SUBSTR(date_id,1,4);
        v_qtr := SUBSTR(date_id,5,1);
        CASE v_qtr
            WHEN 1 THEN v_month := '03';
            WHEN 2 THEN v_month := '06';
            WHEN 3 THEN v_month := '09';
            WHEN 4 THEN v_month := '12';
        END CASE;
    ELSIF type='Y' THEN
        v_year := date_id;
        v_month := '12';
    END IF;
    return v_year||v_month;
END;

--  Common Procedures Definitions
--  check_initial_load_setup
--  Gets the GSD.
--  History:
--  Date        Author                 Action
--  12/16/2005  Panandikar Nilesh G    Defined procedure.

PROCEDURE check_initial_load_setup (
   x_global_start_date OUT NOCOPY DATE
  ,x_rci_schema 	   OUT NOCOPY VARCHAR2)
IS
   l_proc_name     VARCHAR2 (40);
   l_stmt_id       NUMBER;
   l_setup_good    BOOLEAN;
   l_status        VARCHAR2(30) ;
   l_industry      VARCHAR2(30) ;
   l_message	   VARCHAR2(100);
BEGIN

   -- Initialization
   l_proc_name := 'setup_load';
   l_stmt_id := 0;

   -- Check for the global start date setup.
   -- These parameter must be set up prior to any DBI load.

   x_global_start_date := trunc (bis_common_parameters.get_global_start_date);
   IF (x_global_start_date IS NULL) THEN
      l_message := ' Global Start Date is NULL ';
      RAISE INITIALIZATION_ERROR;
   END IF;

   l_setup_good := fnd_installation.get_app_info('AMW', l_status, l_industry, x_rci_schema);
   IF (l_setup_good = FALSE OR x_rci_schema IS NULL) THEN
      l_message := 'Schema not found';
      RAISE INITIALIZATION_ERROR;
   END IF;
EXCEPTION
   WHEN INITIALIZATION_ERROR THEN
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (INITIALIZATION_ERROR_MESG || ':' || l_message,l_proc_name, l_stmt_id));
   WHEN OTHERS THEN
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name,l_stmt_id));
      RAISE;
END check_initial_load_setup;

--  err_mesg
--  History:
--  Date        Author                Action
--  12/16/2005 Panandikar Nilesh G    Defined procedure.

FUNCTION err_mesg (
   p_mesg      IN VARCHAR2
  ,p_proc_name IN VARCHAR2 DEFAULT NULL
  ,p_stmt_id   IN NUMBER DEFAULT -1)
RETURN VARCHAR2
IS
   l_proc_name     VARCHAR2 (60);
   l_stmt_id       NUMBER;
   l_formatted_message VARCHAR2 (300) ;
BEGIN
   l_formatted_message := substr ((p_proc_name || ' #' ||to_char (p_stmt_id) || ': ' || p_mesg),
                                       1, C_ERRBUF_SIZE);
   RETURN l_formatted_message;
EXCEPTION
   WHEN OTHERS THEN
      -- the exception happened in the exception reporting function !!
      -- return with ERROR.
      l_formatted_message := 'Error in error reporting.';
      RETURN l_formatted_message;
END err_mesg;

END RCI_OPEN_REMED_SUMM_PKG;

/
