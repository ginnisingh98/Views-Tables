--------------------------------------------------------
--  DDL for Package Body RCI_PROC_CERT_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCI_PROC_CERT_SUMM_PKG" as
/*$Header: rciproccertb.pls 120.25.12000000.2 2007/03/14 21:08:33 ddesjard ship $*/

---
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below
--- the get_proc_certification_result procedure is called by Process Certification Summary report.

G_USER_ID NUMBER   := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER  := FND_GLOBAL.CONC_LOGIN_ID;

function get_default_year return varchar2 is
begin
    return to_char(sysdate,'YYYY');
end;

PROCEDURE get_kpi(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
    l_sqlstmt      VARCHAR2(15000);
    total_qry VARCHAR2(15000);
    counter NUMBER := 0;
    where_clause VARCHAR2(2000) := ' 1=1 ';
    v_total NUMBER;

	l_qry1 varchar2(2000);
	l_qry2 varchar2(2000);
	l_qry3 varchar2(2000);
--dynamic bind parameters for period
	v_period   varchar2(10);
    l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN
    counter := p_page_parameter_tbl.COUNT;
    FOR i IN 1..counter LOOP
      IF p_page_parameter_tbl(i).parameter_id IS NOT NULL THEN
        IF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' THEN
            where_clause := where_clause || ' AND rpdf.fin_certification_id='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' THEN
            where_clause := where_clause || ' AND rpdf.certification_type='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_period_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_qtr_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_year_id = :TIME ';
        END IF;
      END IF; -- parameter_id IS NOT NULL
    END LOOP;

    ----total_qry := 'SELECT COUNT(1) FROM rci_proc_cert_sum_f rpcm WHERE '|| where_clause;
	total_qry := 'select count(process_id) from (
                         select distinct nvl(certification_result_code,''NOT_CERTIFIED'') as certification_result_code
						       ,project_id,fin_certification_id,organization_id,process_id,evaluation_result_code
                           from rci_process_detail_f rpdf, fii_time_day ftd
                          where rpdf.report_date_julian=ftd.report_date_julian and '||where_clause||' ) ';

	EXECUTE IMMEDIATE total_qry INTO v_total using v_period;

    IF v_total=0 THEN
        v_total := 1;
    END IF;

	l_qry1 := '(select count(process_id) as proc_not_certified from (
                         select distinct nvl(certification_result_code,''NOT_CERTIFIED'') as certification_result_code
						       ,project_id,fin_certification_id,organization_id,process_id,evaluation_result_code
                           from rci_process_detail_f rpdf, fii_time_day ftd
                          where rpdf.report_date_julian=ftd.report_date_julian
                            and certification_result_code is null and '||where_clause||' )) pc1, ';

    l_qry2 := '(select count(process_id) as proc_certified_with_issues from (
                         select distinct nvl(certification_result_code,''NOT_CERTIFIED'') as certification_result_code
						       ,project_id,fin_certification_id,organization_id,process_id,evaluation_result_code
                           from rci_process_detail_f rpdf, fii_time_day ftd
                          where rpdf.report_date_julian=ftd.report_date_julian
                            and certification_result_code=''INEFFECTIVE'' and '||where_clause||' )) pc2,  ';
    l_qry3 := '(select count(process_id) as proc_certified from (
                         select distinct nvl(certification_result_code,''NOT_CERTIFIED'') as certification_result_code
						       ,project_id,fin_certification_id,organization_id,process_id,evaluation_result_code
                           from rci_process_detail_f rpdf, fii_time_day ftd
                          where rpdf.report_date_julian=ftd.report_date_julian
                            and certification_result_code=''EFFECTIVE'' and '||where_clause||' )) pc3 ';

    l_sqlstmt := 'select ROUND((nvl(pc1.proc_not_certified,0)*100/'||v_total ||'),2) AS RCI_PROC_CERT_MEASURE1,
                         ROUND((nvl(pc2.proc_certified_with_issues,0)*100/'||v_total ||'),2) AS RCI_PROC_CERT_MEASURE2,
                         ROUND((nvl(pc3.proc_certified,0)*100/'||v_total ||'),2) AS RCI_PROC_CERT_MEASURE3
					from '||l_qry1||l_qry2||l_qry3;
	/***
    l_sqlstmt :='SELECT
                    ROUND((nvl(MES1,0)*100/'||v_total ||'),2) AS RCI_PROC_CERT_MEASURE1,
                    ROUND((nvl(MES2,0)*100/'||v_total ||'),2) AS RCI_PROC_CERT_MEASURE2,
                    ROUND((nvl(MES3,0)*100/'||v_total ||'),2) AS RCI_PROC_CERT_MEASURE3
                FROM (
                    SELECT
                        SUM(CERT_RESULT_NC) MES1,
                        SUM(CERT_RESULT_CWI) MES2,
                        SUM(CERT_RESULT_C) MES3
                    FROM
                        rci_proc_cert_sum_f rpcm WHERE '|| where_clause ||'
                        )
        ';**/

p_exp_source_sql := l_sqlstmt;
	p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':TIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

END get_kpi;

PROCEDURE get_proc_cert_details(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
    l_sqlstmt      VARCHAR2(15000);
    counter NUMBER := 0;
    where_clause VARCHAR2(2000) := '';
	v_period   varchar2(10);
    l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN
    counter := p_page_parameter_tbl.COUNT;
    FOR i IN 1..counter LOOP
      IF p_page_parameter_tbl(i).parameter_id IS NOT NULL THEN
        IF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' THEN
            where_clause := where_clause || ' AND apov.organization_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
            where_clause := where_clause || ' AND rpdf.process_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' THEN
            where_clause := where_clause || ' AND rpdf.fin_certification_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' THEN
            where_clause := where_clause || ' AND rpdf.certification_status='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' THEN
            where_clause := where_clause || ' AND rpdf.certification_type='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_PROCESS+RCI_BP_CERT_RESULT' THEN
            if p_page_parameter_tbl(i).parameter_id = '''NOT_CERTIFIED''' then
                where_clause := where_clause || ' AND rpdf.certification_result_code is null ' ;
            else
                where_clause := where_clause || ' AND rpdf.certification_result_code='|| p_page_parameter_tbl(i).parameter_id ;
            end if;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_period_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_qtr_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_year_id = :TIME ';
        END IF;
      END IF; -- parameter_id IS NOT NULL
    END LOOP;

    l_sqlstmt := '
        SELECT DISTINCT
        	/*rpdf.process_id*/-100 RCI_DRILLDOWN_PARAM1
        	,/*apov.organization_id*/-100 RCI_DRILLDOWN_PARAM2
        	/*,apov.display_name
            ,apov.revision_number*/
			,/*apov.display_name*/ acv.CERTIFICATION_NAME RCI_PROC_CERT_MEASURE1
        	,rfctv.value RCI_PROC_CERT_MEASURE2
        	,/*apv.person_name*/aecv.full_name  RCI_PROC_CERT_MEASURE3
        	,''Q''||agpv.quarter_num RCI_PROC_CERT_MEASURE4
        	,agpv.period_year RCI_PROC_CERT_MEASURE5
        	,rfcsv.value RCI_PROC_CERT_MEASURE6
        	,acv.certification_creation_date RCI_PROC_CERT_MEASURE7
        	,acv.target_completion_date RCI_PROC_CERT_MEASURE8
        	/*,acv.certification_name RCI_PROC_CERT_MEASURE9*/
        	,rbcrv.value RCI_PROC_CERT_MEASURE9
        	,papf.full_name RCI_PROC_CERT_MEASURE10
        	,rpdf.certified_on RCI_PROC_CERT_MEASURE11
                ,acv.certification_id RCI_ORG_CERT_URL1
        FROM
        	rci_process_detail_f rpdf
        	,amw_process_organization_vl apov
        	/**,amw_people_v apv**/
        	,amw_certification_vl acv
        	,RCI_BP_CERT_RESULT_V rbcrv
        	,RCI_FS_CERT_STATUS_V rfcsv
        	,RCI_FS_CERT_TYPE_V rfctv
        	,amw_gl_periods_v agpv
        	,(select papf.full_name,fu.user_id from PER_ALL_PEOPLE_F papf,fnd_user fu where fu.employee_id = papf.person_id
        	and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
        	and papf.employee_number is not null) papf
			,amw_employees_current_v aecv
        	,fii_time_day ftd
        WHERE
        	rpdf.fin_certification_id = acv.certification_id
        --	rpdf.process_org_rev_id = apov.process_org_rev_id
        	and rpdf.organization_id = apov.organization_id
        	and rpdf.process_id = apov.process_id
			/**01.26.2006 npanandi: bug 5000369 fix**/
        	/**and rpdf.certification_result_code = rbcrv.id(+)**/
			and nvl(rpdf.certification_result_code,''NOT_CERTIFIED'') = rbcrv.id(+)
        	and rpdf.certification_status = rfcsv.id(+)
        	and rpdf.certification_type = rfctv.id(+)
        	/*AND acv.certification_owner_id = apv.person_id*/
			and acv.CERTIFICATION_OWNER_ID = aecv.party_id
        	and rpdf.certified_by_id = papf.user_id(+)
        	and rpdf.certification_period_name = agpv.period_name
        	and rpdf.certification_period_set_name = agpv.period_set_name
        	and rpdf.report_date_julian = ftd.report_date_julian
        	' || where_clause ;

p_exp_source_sql := l_sqlstmt;

	p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':TIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

END get_proc_cert_details;

PROCEDURE get_proc_cert_result(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
    l_sqlstmt      VARCHAR2(15000);
	l_act_sqlstmt  VARCHAR2(15000);
    counter NUMBER := 0;
    where_clause VARCHAR2(2000) := ' 1=1 ';
    total_qry VARCHAR2(15000);
    v_total number;
	v_period   varchar2(10);
    l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN

    counter := p_page_parameter_tbl.COUNT;
    FOR i IN 1..counter LOOP
      IF p_page_parameter_tbl(i).parameter_id IS NOT NULL THEN
        IF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' THEN
            where_clause := where_clause || ' AND rpdf.organization_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
            where_clause := where_clause || ' AND rpdf.process_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' THEN
            where_clause := where_clause || ' AND rpdf.fin_certification_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' THEN
            where_clause := where_clause || ' AND rpdf.certification_status='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' THEN
            where_clause := where_clause || ' AND rpdf.certification_type='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_period_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_qtr_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_year_id = :TIME ';
        END IF;
      END IF; -- parameter_id IS NOT NULL
    END LOOP;

    ----total_qry := 'SELECT COUNT(1) FROM rci_proc_cert_sum_f rpcm WHERE '|| where_clause;
	total_qry := 'select count(process_id) from (
                         select distinct nvl(certification_result_code,''NOT_CERTIFIED'') as certification_result_code
						       ,project_id,fin_certification_id,organization_id,process_id,evaluation_result_code
                           from rci_process_detail_f rpdf, fii_time_day ftd
                          where rpdf.report_date_julian=ftd.report_date_julian and '||where_clause||' ) ';
    EXECUTE IMMEDIATE total_qry INTO v_total using v_period;

    IF v_total=0 THEN
        v_total := 1;
    END IF;

    /*l_sqlstmt :='
    SELECT
        res.value VIEWBY,
        nvl(RCI_PROC_CERT_MEASURE1,0) RCI_PROC_CERT_MEASURE1,
        nvl(RCI_PROC_CERT_MEASURE2,0) RCI_PROC_CERT_MEASURE2,
        0 RCI_PROC_CERT_MEASURE3,
        res.id RCI_DRILLDOWN_PARAM1
    FROM
        (SELECT cert_result,
            COUNT(cert_result) RCI_PROC_CERT_MEASURE1,
            ROUND(COUNT(cert_result)/'||v_total||'*100,2) RCI_PROC_CERT_MEASURE2
        FROM rci_proc_cert_sum_f rpcm
        WHERE
        ' || where_clause ||'
        GROUP BY cert_result) pcs,
        rci_bp_cert_result_v res
    WHERE
        res.id=pcs.cert_result(+)';*/
   l_sqlstmt := 'select value VIEWBY
                       ,count(r.process_id) RCI_PROC_CERT_MEASURE1
					   ,round(count(r.process_id)/'||v_total||'*100,2) RCI_PROC_CERT_MEASURE2
					   ,0 RCI_PROC_CERT_MEASURE3
					   ,id RCI_DRILLDOWN_PARAM1
				   from (
                        select distinct nvl(certification_result_code,''NOT_CERTIFIED'') as certification_result_code,project_id,fin_certification_id
						      ,organization_id,process_id,evaluation_result_code
                          from rci_process_detail_f rpdf,
						       fii_time_day ftd
                         where rpdf.report_date_julian=ftd.report_date_julian
						   and '||where_clause||' ) r,
					    rci_bp_cert_result_v rbcrv
				  where rbcrv.id = r.certification_result_code(+)
				  group by value,id ';

   /** 09.18.2006 npanandi: added SQL below to handle order_by_clause -- bug 5510667 **/
   l_act_sqlstmt := 'select VIEWBY,RCI_PROC_CERT_MEASURE1,RCI_PROC_CERT_MEASURE2
                           ,RCI_PROC_CERT_MEASURE3,RCI_DRILLDOWN_PARAM1
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_sqlstmt||'
							 ) t ) a
					   order by a.col_rank ';

p_exp_source_sql := l_act_sqlstmt;
	p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':TIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

END get_proc_cert_result;

PROCEDURE get_proc_cert_summary(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
   l_sqlstmt      VARCHAR2(15000);
   l_act_sqlstmt  varchar2(15000);
    counter NUMBER := 0;
    where_clause1 VARCHAR2(2000) := ' ';
    where_clause VARCHAR2(2000) := ' 1=1 ';
	inner_where_clause varchar2(2000) := ' 1=1 ';
	l_issues_where varchar2(2000) := ' 1=1 ';
	l_ineffctrls_frm varchar2(2000) := ' 1=1 ';
	l_rf_where varchar2(2000) := ' 1=1 ';

	v_yyyymm varchar2(6);
	v_period   varchar2(10);
    l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN
    counter := p_page_parameter_tbl.COUNT;
    FOR i IN 1..counter LOOP
      IF p_page_parameter_tbl(i).parameter_id IS NOT NULL THEN
        IF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' THEN
            where_clause1 := where_clause1 || ' AND rpcm.ORGANIZATION_ID='|| p_page_parameter_tbl(i).parameter_id ;
            where_clause := where_clause || ' AND rocsf.organization_id='|| p_page_parameter_tbl(i).parameter_id ;
			inner_where_clause := inner_where_clause || ' AND organization_id = '||p_page_parameter_tbl(i).parameter_id;
			l_issues_where := l_issues_where || ' and roif.organization_id = '||p_page_parameter_tbl(i).parameter_id;
			l_ineffctrls_frm := l_ineffctrls_frm || ' and aca.pk2 = '||p_page_parameter_tbl(i).parameter_id;
			l_rf_where := l_rf_where || ' and rf.organization_id = '||p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
            where_clause1 := where_clause1 || ' AND rpcm.PROCESS_ID='|| p_page_parameter_tbl(i).parameter_id ;
            where_clause := where_clause || ' AND rocsf.process_id='|| p_page_parameter_tbl(i).parameter_id ;
			inner_where_clause := inner_where_clause || ' AND process_id = '||p_page_parameter_tbl(i).parameter_id;
			l_issues_where := l_issues_where || ' and roif.process_id = '||p_page_parameter_tbl(i).parameter_id;
			l_ineffctrls_frm := l_ineffctrls_frm || ' and aca.pk3 = '||p_page_parameter_tbl(i).parameter_id;
			l_rf_where := l_rf_where || ' AND rf.process_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' THEN
            where_clause1 := where_clause1 || ' AND rpcm.CERTIFICATION_ID='|| p_page_parameter_tbl(i).parameter_id ;
            where_clause := where_clause || ' AND rocsf.fin_certification_id='|| p_page_parameter_tbl(i).parameter_id ;
			l_issues_where := l_issues_where || ' and roif.fin_cert_id = '||p_page_parameter_tbl(i).parameter_id;
			l_ineffctrls_frm := l_ineffctrls_frm || ' and aca.pk1 = '||p_page_parameter_tbl(i).parameter_id;
			l_rf_where := l_rf_where || ' AND rf.fin_certification_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' THEN
            where_clause1 := where_clause1 || ' AND rpcm.CERT_STATUS='|| p_page_parameter_tbl(i).parameter_id ;
            where_clause := where_clause || ' AND rocsf.certification_status='|| p_page_parameter_tbl(i).parameter_id ;
			inner_where_clause := inner_where_clause || ' AND certification_status = '||p_page_parameter_tbl(i).parameter_id;
			l_issues_where := l_issues_where || ' and fin_cert_status = '||p_page_parameter_tbl(i).parameter_id;
			l_rf_where := l_rf_where || ' AND rf.certification_status='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' THEN
            where_clause1 := where_clause1 || ' AND rpcm.CERT_TYPE='|| p_page_parameter_tbl(i).parameter_id ;
            where_clause := where_clause || ' AND rocsf.certification_type='|| p_page_parameter_tbl(i).parameter_id ;
			inner_where_clause := inner_where_clause || ' AND certification_type = '||p_page_parameter_tbl(i).parameter_id;
			l_issues_where := l_issues_where || ' and fin_cert_type = '||p_page_parameter_tbl(i).parameter_id;
			l_rf_where := l_rf_where || ' AND rf.certification_type='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_PROCESS+RCI_BP_CERT_RESULT' THEN
            where_clause1 := where_clause1 || ' AND rpcm.CERT_RESULT='|| p_page_parameter_tbl(i).parameter_id ;
		    IF p_page_parameter_tbl(i).parameter_id = '''EFFECTIVE''' THEN
                --where_clause := where_clause || ' AND rocsf.certification_result_code = ''EFFECTIVE'' ';
				l_rf_where := l_rf_where || ' AND rf2.proc_certified > 0 ';
				--where_clause := where_clause || ' AND rf.proc_certified>0';
            ELSIF p_page_parameter_tbl(i).parameter_id = '''INEFFECTIVE''' THEN
                --where_clause := where_clause || ' AND rocsf.certification_result_code = ''INEFFECTIVE''';
				l_rf_where := l_rf_where || ' AND rocsf.proc_certified_with_issues > 0 ';
				--where_clause := where_clause || ' AND rf.proc_certified_with_issues>0';
            ELSIF p_page_parameter_tbl(i).parameter_id = '''NOT_CERTIFIED''' THEN
                --where_clause := where_clause || ' AND rocsf.certification_result_code IS NULL ';
				l_rf_where := l_rf_where || ' AND rf3.proc_not_certified > 0 ';
				--where_clause := where_clause || ' AND rocsf.proc_not_certified>0';
            END IF;
--            where_clause := where_clause || ' AND rpcm.cert_result='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
		    /**05.19.2006 npanandi: added below, else giving null**/
                    v_period := p_page_parameter_tbl(i).parameter_id;

                    v_yyyymm := rci_org_cert_summ_pkg.GET_LAST_DAY( p_page_parameter_tbl(i).parameter_id,'M');
			/*01.09.2006 npanandi: changed reference to FII_TIME_DAY for time dimension**/
            where_clause1 := where_clause1 || ' AND ftd.ent_period_id = :TIME ';
			where_clause := where_clause || ' AND ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
			inner_where_clause := inner_where_clause || ' AND ftd.ent_period_id = :TIME ';
			l_rf_where := l_rf_where || ' AND ftd.ent_period_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
                    /**05.19.2006 npanandi: added below, else giving null**/
		    v_period := p_page_parameter_tbl(i).parameter_id;

                    v_yyyymm := rci_org_cert_summ_pkg.GET_LAST_DAY( p_page_parameter_tbl(i).parameter_id,'Q');
			/*01.09.2006 npanandi: changed reference to FII_TIME_DAY for time dimension**/
            where_clause1 := where_clause1 || ' AND ftd.ent_qtr_id = :TIME ';
			where_clause := where_clause || ' AND ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
			inner_where_clause := inner_where_clause || ' AND ftd.ent_qtr_id = :TIME ';
			l_rf_where := l_rf_where || ' AND ftd.ent_qtr_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
		    /**05.19.2006 npanandi: added below, else giving null**/
                    v_period := p_page_parameter_tbl(i).parameter_id;

                    v_yyyymm := rci_org_cert_summ_pkg.GET_LAST_DAY( p_page_parameter_tbl(i).parameter_id,'Y');
			/*01.09.2006 npanandi: changed reference to FII_TIME_DAY for time dimension**/
            where_clause1 := where_clause1 || ' AND ftd.ent_year_id = :TIME ';
			where_clause := where_clause || ' AND ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
			inner_where_clause := inner_where_clause || ' AND ftd.ent_year_id = :TIME ';
			l_rf_where := l_rf_where || ' AND ftd.ent_year_id = :TIME ';
        END IF;
      END IF; -- parameter_id IS NOT NULL
    END LOOP;

   l_sqlstmt := 'SELECT distinct
	display_name VIEWBY
	,0 RCI_GRAND_TOTAL
    ,RCI_DRILLDOWN_PARAM1                               ,RCI_PROC_CERT_MEASURE3
    ,RCI_PROC_CERT_MEASURE4    ,RCI_PROC_CERT_MEASURE5    ,RCI_PROC_CERT_MEASURE6
    ,RCI_PROC_CERT_MEASURE7    ,RCI_PROC_CERT_MEASURE8    ,RCI_PROC_CERT_MEASURE9
    ,RCI_PROC_CERT_MEASURE10    ,RCI_PROC_CERT_MEASURE11    ,RCI_PROC_CERT_MEASURE12
    ,RCI_PROC_CERT_MEASURE13    ,RCI_PROC_CERT_MEASURE14    ,RCI_PROC_CERT_MEASURE15
    ,RCI_PROC_CERT_MEASURE16    ,RCI_PROC_CERT_MEASURE17
    from
        (select distinct /*rocsf.organization_id,*/alrv.display_name,rf.process_id RCI_DRILLDOWN_PARAM1
      ,nvl(rocsf.proc_certified_with_issues,0) RCI_PROC_CERT_MEASURE3
      ,nvl(rf2.proc_certified,0) RCI_PROC_CERT_MEASURE4
      ,nvl(rf3.proc_not_certified,0) RCI_PROC_CERT_MEASURE5
	  ,nvl(risk_ineff_ctrls.risk_id,0) RCI_PROC_CERT_MEASURE6 /*risks with ineffective controls*/
	  ,rpcsf.miti_risks RCI_PROC_CERT_MEASURE7
      ,nvl(r1.risk_id,0) RCI_PROC_CERT_MEASURE8
      ,nvl(r2.risk_id,0) RCI_PROC_CERT_MEASURE9
      ,nvl(r3.risk_id,0) RCI_PROC_CERT_MEASURE10
	  ,rpcsf.ne_risks RCI_PROC_CERT_MEASURE11
	  ,rpcsf.eff_ctrls RCI_PROC_CERT_MEASURE12
      ,nvl(c1.control_id,0) RCI_PROC_CERT_MEASURE14
      ,nvl(c2.control_id,0) RCI_PROC_CERT_MEASURE15
      ,nvl(c3.control_id,0) RCI_PROC_CERT_MEASURE13
	  ,rpcsf.ne_ctrls RCI_PROC_CERT_MEASURE16
	  ,nvl(op.open_issues,0) RCI_PROC_CERT_MEASURE17
  from rci_org_cert_summ_f rf,fii_time_day ftd,
       /***05.24.2006 npanandi: added organizationId in the subquery below
	       for rocsf,rf2,rf3 otherwise number mismatch between the summary page
		   and the Process Detail page
		***/
       (select process_id, count(fin_certification_id) as proc_certified_with_issues from (select distinct fin_certification_id,organization_id,process_id from rci_process_detail_f rocsf,fii_time_day ftd
         where rocsf.report_date_julian = ftd.report_date_julian and rocsf.certification_result_code=''INEFFECTIVE'' and '||where_clause||' ) group by process_id) rocsf
      ,(select process_id, count(fin_certification_id) as proc_certified from (select distinct fin_certification_id,organization_id,process_id from rci_process_detail_f rocsf,fii_time_day ftd
         where rocsf.report_date_julian = ftd.report_date_julian and rocsf.certification_result_code=''EFFECTIVE'' and '||where_clause||' ) group by process_id) rf2
      ,(select process_id, count(fin_certification_id) as proc_not_certified from (select distinct fin_certification_id,organization_id,process_id from rci_process_detail_f rocsf,fii_time_day ftd
         where rocsf.report_date_julian = ftd.report_date_julian and rocsf.certification_result_code IS NULL and '||where_clause||' ) group by process_id) rf3
      /*,fii_time_day ftd*/
      ,amw_latest_revisions_v alrv
	  ,(select aca.pk3 as process_id, count(distinct aca.pk4) as risk_id
          from AMW_CONTROL_ASSOCIATIONS aca,amw_opinions_log_v aolv
         where object_type=''RISK_FINCERT'' and aca.pk5=aolv.opinion_log_id
		   and aolv.audit_result_code <> ''EFFECTIVE'' and '||l_ineffctrls_frm|| '
         group by pk3) risk_ineff_ctrls
      ,(select process_id, count(distinct risk_id) as risk_id from (select distinct organization_id,process_id,risk_id,project_id,audit_result_code
          from RCI_ORG_CERT_RISKS_F,fii_time_day ftd
         where RCI_ORG_CERT_RISKS_F.REPORT_DATE_JULIAN=ftd.REPORT_DATE_JULIAN
		   and audit_result_code=''SOMEWHAT_EFFECTIVE'' and '||inner_where_clause||'
		) group by process_id) r1
      ,(select distinct process_id, count(distinct risk_id) as risk_id from (select distinct organization_id,process_id,risk_id,project_id,audit_result_code
          from RCI_ORG_CERT_RISKS_F,fii_time_day ftd
         where RCI_ORG_CERT_RISKS_F.REPORT_DATE_JULIAN=ftd.REPORT_DATE_JULIAN
		   and audit_result_code=''NEARLY_INEFFECTIVE'' and '||inner_where_clause||'
		) group by process_id) r2
      ,(select distinct process_id, count(distinct risk_id) as risk_id from (select distinct organization_id,process_id,risk_id,project_id,audit_result_code
          from RCI_ORG_CERT_RISKS_F,fii_time_day ftd
         where RCI_ORG_CERT_RISKS_F.REPORT_DATE_JULIAN=ftd.REPORT_DATE_JULIAN
		   and audit_result_code=''INEFFECTIVE'' and '||inner_where_clause||'
		) group by process_id) r3
      ,(select process_id,count(control_id) as control_id from (select distinct process_id,control_id,organization_id,audit_result_code,DES_EFF_ID,OP_EFF_ID
          from RCI_ORG_CERT_CTRLS_F,fii_time_day ftd
         where RCI_ORG_CERT_CTRLS_F.REPORT_DATE_JULIAN=ftd.REPORT_DATE_JULIAN
		   and audit_result_code=''NEARLY_INEFFECTIVE'' and '||inner_where_clause||'
		 ) group by process_id) c1
      ,(select process_id,count(control_id) as control_id from (select distinct process_id,control_id,organization_id,audit_result_code,DES_EFF_ID,OP_EFF_ID
          from RCI_ORG_CERT_CTRLS_F,fii_time_day ftd
         where RCI_ORG_CERT_CTRLS_F.REPORT_DATE_JULIAN=ftd.REPORT_DATE_JULIAN
		   and audit_result_code=''INEFFECTIVE'' and '||inner_where_clause||'
		 ) group by process_id) c2
	  ,(select process_id,count(control_id) as control_id from (select distinct process_id,control_id,organization_id,audit_result_code,DES_EFF_ID,OP_EFF_ID
          from RCI_ORG_CERT_CTRLS_F,fii_time_day ftd
         where RCI_ORG_CERT_CTRLS_F.REPORT_DATE_JULIAN=ftd.REPORT_DATE_JULIAN
		   and audit_result_code=''SOMEWHAT_EFFECTIVE'' and '||inner_where_clause||'
		 ) group by process_id) c3
	  ,(select roif.process_id,count(distinct roif.change_id) as open_issues
         from rci_open_issues_f roif,eng_engineering_changes eec
        where eec.change_id=roif.change_id and roif.certification_id is not null
		  and '||l_issues_where||' and roif.organization_id is not null
		  and ((eec.status_code not in (0,11) and eec.initiation_date < last_day(to_date('''||v_yyyymm||''',''YYYYMM''))
         ) or (eec.status_code=11 and eec.last_update_date > last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) ))
		 group by roif.process_id ) op
	 ,(SELECT
            process_id
            ,sum(nvl(RISK_EVAL_M,0)) miti_risks
            ,sum(nvl(RISK_EVAL_NE,0)) ne_risks
            ,sum(nvl(CTRL_EVAL_E,0)) eff_ctrls
            ,sum(nvl(CTRL_EVAL_NE,0)) ne_ctrls
        from
            rci_proc_cert_sum_f rpcm
            ,fii_time_day ftd
        where
        	rpcm.report_date_julian = ftd.report_date_julian ' || where_clause1 || '
        group by process_id) rpcsf
 where rf.report_date_julian = ftd.report_date_julian and '||l_rf_where|| '
   and rf.process_id = alrv.process_id
   and rf.process_id=rocsf.process_id(+)
   and rf.process_id = rf2.process_id(+)
   and rf.process_id = rf3.process_id(+)
   and rf.process_id = risk_ineff_ctrls.process_id(+)
   and rf.process_id = r1.process_id(+)
   and rf.process_id = r2.process_id(+)
   and rf.process_id = r3.process_id(+)
   and rf.process_id = c1.process_id(+)
   and rf.process_id = c2.process_id(+)
   and rf.process_id = c3.process_id(+)
   and rf.process_id = op.process_id(+)
   and rf.process_id = rpcsf.process_id(+))
   /**01.26.2006 npanandi: added below line for bug 5000427**/
   order by RCI_PROC_CERT_MEASURE3 desc ';

   /** 09.18.2006 npanandi: added SQL below to handle order_by_clause -- bug 5510667 **/
   l_act_sqlstmt := 'select VIEWBY
	,RCI_GRAND_TOTAL,RCI_DRILLDOWN_PARAM1,RCI_PROC_CERT_MEASURE3
    ,RCI_PROC_CERT_MEASURE4,RCI_PROC_CERT_MEASURE5,RCI_PROC_CERT_MEASURE6
    ,RCI_PROC_CERT_MEASURE7,RCI_PROC_CERT_MEASURE8,RCI_PROC_CERT_MEASURE9
    ,RCI_PROC_CERT_MEASURE10,RCI_PROC_CERT_MEASURE11,RCI_PROC_CERT_MEASURE12
    ,RCI_PROC_CERT_MEASURE13,RCI_PROC_CERT_MEASURE14,RCI_PROC_CERT_MEASURE15
    ,RCI_PROC_CERT_MEASURE16,RCI_PROC_CERT_MEASURE17
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_sqlstmt||'
							 ) t ) a
					   order by a.col_rank ';

p_exp_source_sql := l_act_sqlstmt;
	p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':TIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

END get_proc_cert_summary;

/*
--Procedure to be called from concurrent program--
*/
PROCEDURE proc_cert_incremental_load
(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER)
IS
BEGIN
    EXECUTE IMMEDIATE ('TRUNCATE TABLE amw.rci_proc_cert_sum_f');
    proc_cert_initial_load(
   errbuf    => errbuf
  ,retcode   => retcode);
END proc_cert_incremental_load;
/*
--------------------------------------------------------------------------
*/
PROCEDURE proc_cert_initial_load
(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER)
IS
/*todo remove this later
CURSOR c_all_certifications is
SELECT DISTINCT acb.certification_id, acb.certification_status, acb.certification_type,
	fin_scope.process_id, fin_scope.organization_id,
    agpv.period_year period_year,
    agpv.period_num period_num,
    agpv.quarter_num quarter_num,
    to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)) ent_period_id,
    to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)) ent_qtr_id,
    agpv.period_year ent_year_id,
    to_number(to_char(agpv.end_date,'J')) report_date_julian
FROM
    amw_certification_b acb, amw_gl_periods_v agpv, amw_fin_cert_scope fin_scope
WHERE
    acb.object_type = 'FIN_STMT'
--    AND acb.certification_status in ('ACTIVE','DRAFT')
    AND acb.certification_id = fin_scope.fin_certification_id
    AND acb.certification_period_name = agpv.period_name
    AND acb.certification_period_set_name = agpv.period_set_name
    AND fin_scope.process_id IS NOT NULL
	AND fin_scope.organization_id IS NOT NULL;
r_proc c_all_certifications%rowtype;
time_rec TIME_DIMENSIONS_RECORD;
cert_rec CERT_DETAIL_RECORD;*/
CURSOR c_all_certifications is
SELECT CERTIFICATION_ID, ORGANIZATION_ID, PROCESS_ID
FROM rci_proc_cert_sum_f;
r_proc c_all_certifications%rowtype;

   l_user_id                NUMBER ;
   l_login_id               NUMBER ;
   l_program_id             NUMBER ;
   l_program_login_id       NUMBER ;
   l_program_application_id NUMBER ;
   l_request_id             NUMBER ;
   l_run_date      DATE;
BEGIN
    DELETE FROM rci_proc_cert_sum_f;

	INSERT INTO rci_proc_cert_sum_f(
        CERTIFICATION_ID, ORGANIZATION_ID, PROCESS_ID,
        CERT_STATUS, CERT_TYPE, CERT_RESULT,
        CERT_RESULT_CWI, CERT_RESULT_C, CERT_RESULT_NC,
        PERIOD_YEAR, PERIOD_NUM, QUARTER_NUM,
        ENT_PERIOD_ID, ENT_QTR_ID, ENT_YEAR_ID,
        REPORT_DATE_JULIAN,
        CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
    SELECT DISTINCT
		acb.certification_id, aolv.pk3_value org_id, aolv.pk1_value process_id,
		acb.certification_status, acb.certification_type, nvl(aolv.audit_result_code,'NOT_CERTIFIED'),
		decode(aolv.audit_result_code,'INEFFECTIVE',1,0),
		decode(aolv.audit_result_code,'EFFECTIVE',1,0),
		decode(aolv.audit_result_code,NULL,1,0),
	    agpv.period_year period_year,
	    agpv.period_num period_num,
	    agpv.quarter_num quarter_num,
	    to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)) ent_period_id,
        to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)) ent_qtr_id,
        agpv.period_year ent_year_id,
        to_number(to_char(agpv.end_date,'J')) report_date_julian,
        G_USER_ID, sysdate, G_USER_ID, sysdate, G_LOGIN_ID
	FROM
	    amw_certification_b acb, amw_gl_periods_v agpv, amw_opinions_log_v aolv
	WHERE
	    acb.object_type = 'PROCESS'
	    AND aolv.opinion_type_code = 'CERTIFICATION'
	    AND aolv.object_name = 'AMW_ORG_PROCESS'
	    AND aolv.pk2_value = acb.certification_id
	    AND acb.certification_period_name = agpv.period_name
	    AND acb.certification_period_set_name = agpv.period_set_name;

	FOR r_proc in c_all_certifications LOOP
    	update_proc_cert_table(r_proc.process_id, r_proc.organization_id, r_proc.certification_id);
	END LOOP;

/*todo remove this later
	FOR r_proc in c_all_certifications LOOP
	   cert_rec.cert_id := r_proc.CERTIFICATION_ID;
	   cert_rec.cert_status := r_proc.CERTIFICATION_STATUS;
	   cert_rec.cert_type := r_proc.CERTIFICATION_TYPE;
        time_rec.period_year := r_proc.period_year;
        time_rec.period_num := r_proc.period_num;
        time_rec.quarter_num := r_proc.quarter_num;
        time_rec.ent_period_id := r_proc.ent_period_id;
        time_rec.ent_qtr_id := r_proc.ent_qtr_id;
        time_rec.ent_year_id := r_proc.ent_year_id;
        time_rec.report_date_julian := r_proc.report_date_julian;
		update_proc_cert_table(r_proc.process_id, r_proc.organization_id, cert_rec, time_rec);
	END LOOP;
*/
    l_user_id                := NVL(fnd_global.USER_ID, -1);
    l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
    l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
    l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
    l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
    l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);
    l_run_date := sysdate - 5/(24*60);

   DELETE FROM rci_dr_inc WHERE fact_name='RCI_PROC_CERT_SUM_F';

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
	 'RCI_PROC_CERT_SUM_F'
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

END proc_cert_initial_load;
/*
--------------------------------------------------------------------------
*/
PROCEDURE update_proc_cert_table(
    p_process_id IN NUMBER,
    p_org_id IN NUMBER,
    p_cert_id IN NUMBER
)
IS
CURSOR c_get_risks_with_ineff_ctrls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.pk3 process_id, aca.pk4 risk_id
	 FROM amw_control_associations aca,amw_opinions_v aov
	 WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
	 AND aca.pk1 		   = p_cert_id
	 AND aca.pk2               = p_org_id
	 AND aca.pk3               IN (SELECT DISTINCT process_id
	 	 		  	       FROM   amw_execution_scope
	 	 		  	       START WITH process_id = p_process_id
	 	 		  	       AND organization_id = p_org_id
	 	 		  	       AND entity_id = p_cert_id
	                       and entity_type='BUSIPROC_CERTIFICATION'
	 	 		  	       CONNECT BY PRIOR process_id = parent_process_id
	 	 		  	       AND organization_id = PRIOR organization_id
	 	 		  	       AND entity_id = PRIOR entity_id
		                   and entity_type=prior entity_type
	 	 		  	       )
	 AND aov.object_name       = 'AMW_ORG_CONTROL'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value         = p_org_id
	 AND aov.pk1_value         = aca.control_id
	 AND aov.audit_result_code <> 'EFFECTIVE'
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value)
     );
CURSOR c_get_risk_evals
IS
SELECT
      riskevalopin.audit_result_code AS risk_eval,
      count(nvl(riskevalopin.audit_result_code,1)) cnt
FROM
	(SELECT object_type,risk_id,pk1,pk2,pk3,pk4,pk5,risk_rev_id
		FROM amw_risk_associations WHERE object_type='BUSIPROC_CERTIFICATION') ara,
	amw_risks_all_vl arav,
	amw_opinions_log_v riskevalopin
WHERE
	ara.pk1(+)=p_cert_id
	AND ara.pk2(+)=p_org_id
	AND ara.pk3(+)=p_process_id
	AND ara.risk_id=arav.risk_id
	AND ara.risk_rev_id=arav.risk_rev_id
	AND arav.latest_revision_flag(+)='Y'
	AND riskevalopin.opinion_log_id(+)=ara.pk4
group by riskevalopin.audit_result_code;
CURSOR c_get_control_evals
IS
SELECT
      ctrlevalopin.audit_result_code AS ctrl_eval,
      count(nvl(ctrlevalopin.audit_result_code,1)) cnt
FROM
	(SELECT object_type,control_id,pk1,pk2,pk3,pk4,pk5,control_rev_id
		FROM amw_control_associations WHERE object_type='BUSIPROC_CERTIFICATION') aca,
	amw_controls_all_vl acav,
	amw_opinions_log_v ctrlevalopin
WHERE
	aca.pk1(+)=p_cert_id
	AND aca.pk2(+)=p_org_id
	AND aca.pk3(+)=p_process_id
	AND aca.control_id=acav.control_id
	AND aca.control_rev_id=acav.control_rev_id
	AND ctrlevalopin.opinion_log_id(+)=aca.pk5
	AND acav.latest_revision_flag(+)='Y'
group by ctrlevalopin.audit_result_code;
r_get_risk_evals c_get_risk_evals%rowtype;
r_get_control_evals c_get_control_evals%rowtype;
v_risks_with_ineff_ctrls NUMBER;
v_re_mitigated rci_proc_cert_sum_f.RISK_EVAL_M%type := 0;
v_re_somewhat_mitigated rci_proc_cert_sum_f.RISK_EVAL_SM%type := 0;
v_re_somewhat_exposed rci_proc_cert_sum_f.RISK_EVAL_SE%type := 0;
v_re_fully_exposed rci_proc_cert_sum_f.RISK_EVAL_FE%type := 0;
v_re_not_evaluated rci_proc_cert_sum_f.RISK_EVAL_NE%type := 0;
v_ce_effective rci_proc_cert_sum_f.CTRL_EVAL_E%type := 0;
v_ce_materially_weak rci_proc_cert_sum_f.CTRL_EVAL_MW%type := 0;
v_ce_deficient rci_proc_cert_sum_f.CTRL_EVAL_D%type := 0;
v_ce_significantly_deficient rci_proc_cert_sum_f.CTRL_EVAL_SD%type := 0;
v_ce_not_evaluated rci_proc_cert_sum_f.CTRL_EVAL_NE%type := 0;
v_open_issues NUMBER;
BEGIN
	v_open_issues := amw_findings_pkg.calculate_open_findings('AMW_PROC_CERT_ISSUES',
                                    'PROCESS',
                                    p_process_id,
                                    'ORGANIZATION',
                                    p_org_id,
                                    'CERTIFICATION',
                                    p_cert_id,
                                    null, null, null, null);
	OPEN  c_get_risks_with_ineff_ctrls;
	FETCH c_get_risks_with_ineff_ctrls into v_risks_with_ineff_ctrls;
	CLOSE c_get_risks_with_ineff_ctrls;
	FOR r_get_risk_evals IN c_get_risk_evals LOOP
		  IF r_get_risk_evals.risk_eval is null THEN
		      v_re_not_evaluated := r_get_risk_evals.cnt;
		  END IF;
		  IF r_get_risk_evals.risk_eval = 'EFFECTIVE' THEN
		      v_re_mitigated := r_get_risk_evals.cnt;
		  END IF;
		  IF r_get_risk_evals.risk_eval = 'SOMEWHAT_EFFECTIVE' THEN
		      v_re_somewhat_mitigated := r_get_risk_evals.cnt;
		  END IF;
		  IF r_get_risk_evals.risk_eval = 'NEARLY_INEFFECTIVE' THEN
		      v_re_somewhat_exposed := r_get_risk_evals.cnt;
		  END IF;
		  IF r_get_risk_evals.risk_eval = 'INEFFECTIVE' THEN
		      v_re_fully_exposed := r_get_risk_evals.cnt;
		  END IF;
	END LOOP;
    FOR r_get_control_evals IN c_get_control_evals LOOP
		  IF r_get_control_evals.ctrl_eval is null THEN
		      v_ce_not_evaluated := r_get_control_evals.cnt;
		  END IF;
		  IF r_get_control_evals.ctrl_eval = 'EFFECTIVE' THEN
		      v_ce_effective := r_get_control_evals.cnt;
		  END IF;
		  IF r_get_control_evals.ctrl_eval = 'SOMEWHAT_EFFECTIVE' THEN
		      v_ce_materially_weak := r_get_control_evals.cnt;
		  END IF;
		  IF r_get_control_evals.ctrl_eval = 'NEARLY_INEFFECTIVE' THEN
		      v_ce_deficient := r_get_control_evals.cnt;
		  END IF;
		  IF r_get_control_evals.ctrl_eval = 'INEFFECTIVE' THEN
		      v_ce_significantly_deficient := r_get_control_evals.cnt;
		  END IF;
	END LOOP;

UPDATE rci_proc_cert_sum_f
	SET
        RISKS_WITH_INEFF_CTRLS = v_risks_with_ineff_ctrls,
		RISK_EVAL_M = v_re_mitigated,
		RISK_EVAL_SM = v_re_somewhat_mitigated,
		RISK_EVAL_SE = v_re_somewhat_exposed,
		RISK_EVAL_FE = 	v_re_somewhat_exposed,
		RISK_EVAL_NE = v_re_not_evaluated,
		CTRL_EVAL_E = 	v_ce_effective,
		CTRL_EVAL_MW =v_ce_materially_weak,
		CTRL_EVAL_D = v_ce_deficient,
		CTRL_EVAL_SD = v_ce_significantly_deficient,
		CTRL_EVAL_NE =	v_ce_not_evaluated,
        OPEN_ISSUES       = v_open_issues,
	    lAST_UPDATE_DATE 	     = SYSDATE,
	    lAST_UPDATED_BY          = G_USER_ID,
	    lAST_UPDATE_LOGIN        = G_LOGIN_ID
	WHERE
	CERTIFICATION_ID         = p_cert_id
	AND ORGANIZATION_ID          = p_org_id
    AND PROCESS_ID             = p_process_id;

END update_proc_cert_table;
/*todo remove this later
PROCEDURE update_proc_cert_table(
    p_process_id IN NUMBER,
    p_org_id IN NUMBER,
    cert_rec IN CERT_DETAIL_RECORD, time_rec IN TIME_DIMENSIONS_RECORD)
IS

CURSOR c_get_certification_opinion
IS
SELECT opinion.opinion_id,opinion.audit_result_code
FROM amw_opinions_v opinion
WHERE opinion.pk3_value = p_org_id
AND   opinion.pk2_value = cert_rec.cert_id
AND   opinion.pk1_value = p_process_id
AND   opinion.opinion_type_code = 'CERTIFICATION'
AND   opinion.object_name = 'AMW_ORG_PROCESS';
CURSOR c_get_risks_with_ineff_ctrls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.pk3 process_id, aca.pk4 risk_id
	 FROM amw_control_associations aca,amw_opinions_v aov
	 WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
	 AND aca.pk1 		   = cert_rec.cert_id
	 AND aca.pk2               = p_org_id
	 AND aca.pk3               IN (SELECT DISTINCT process_id
	 	 		  	       FROM   amw_execution_scope
	 	 		  	       START WITH process_id = p_process_id
	 	 		  	       AND organization_id = p_org_id
	 	 		  	       AND entity_id = cert_rec.cert_id
	                       and entity_type='BUSIPROC_CERTIFICATION'
	 	 		  	       CONNECT BY PRIOR process_id = parent_process_id
	 	 		  	       AND organization_id = PRIOR organization_id
	 	 		  	       AND entity_id = PRIOR entity_id
		                   and entity_type=prior entity_type
	 	 		  	       )
	 AND aov.object_name       = 'AMW_ORG_CONTROL'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value         = p_org_id
	 AND aov.pk1_value         = aca.control_id
	 AND aov.audit_result_code <> 'EFFECTIVE'
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value)
     );
CURSOR c_get_risk_evals
IS
SELECT
      riskevalopin.audit_result_code AS risk_eval,
      count(nvl(riskevalopin.audit_result_code,1)) cnt
FROM
	(SELECT object_type,risk_id,pk1,pk2,pk3,pk4,pk5,risk_rev_id
		FROM amw_risk_associations WHERE object_type='BUSIPROC_CERTIFICATION') ara,
	amw_risks_all_vl arav,
	amw_opinions_log_v riskevalopin
WHERE
	ara.pk1(+)=cert_rec.cert_id
	AND ara.pk2(+)=p_org_id
	AND ara.pk3(+)=p_process_id
	AND ara.risk_id=arav.risk_id
	AND ara.risk_rev_id=arav.risk_rev_id
	AND arav.latest_revision_flag(+)='Y'
	AND riskevalopin.opinion_log_id(+)=ara.pk4
group by riskevalopin.audit_result_code;
CURSOR c_get_control_evals
IS
SELECT
      ctrlevalopin.audit_result_code AS ctrl_eval,
      count(nvl(ctrlevalopin.audit_result_code,1)) cnt
FROM
	(SELECT object_type,control_id,pk1,pk2,pk3,pk4,pk5,control_rev_id
		FROM amw_control_associations WHERE object_type='BUSIPROC_CERTIFICATION') aca,
	amw_controls_all_vl acav,
	amw_opinions_log_v ctrlevalopin
WHERE
	aca.pk1(+)=cert_rec.cert_id
	AND aca.pk2(+)=p_org_id
	AND aca.pk3(+)=p_process_id
	AND aca.control_id=acav.control_id
	AND aca.control_rev_id=acav.control_rev_id
	AND ctrlevalopin.opinion_log_id(+)=aca.pk5
	AND acav.latest_revision_flag(+)='Y'
group by ctrlevalopin.audit_result_code;
v_proc_name VARCHAR2(50);
r_certification_opinion c_get_certification_opinion%rowtype;
r_get_risk_evals c_get_risk_evals%rowtype;
r_get_control_evals c_get_control_evals%rowtype;
v_certification_result amw_opinions_v.audit_result%type;
v_cert_with_issues rci_proc_cert_sum_f.CERT_RESULT_CWI%type := 0;
v_certified rci_proc_cert_sum_f.CERT_RESULT_C%type := 0;
v_not_certified rci_proc_cert_sum_f.CERT_RESULT_NC%type := 0;
v_risks_with_ineff_ctrls NUMBER;
v_re_mitigated rci_proc_cert_sum_f.RISK_EVAL_M%type := 0;
v_re_somewhat_mitigated rci_proc_cert_sum_f.RISK_EVAL_SM%type := 0;
v_re_somewhat_exposed rci_proc_cert_sum_f.RISK_EVAL_SE%type := 0;
v_re_fully_exposed rci_proc_cert_sum_f.RISK_EVAL_FE%type := 0;
v_re_not_evaluated rci_proc_cert_sum_f.RISK_EVAL_NE%type := 0;
v_ce_effective rci_proc_cert_sum_f.CTRL_EVAL_E%type := 0;
v_ce_materially_weak rci_proc_cert_sum_f.CTRL_EVAL_MW%type := 0;
v_ce_deficient rci_proc_cert_sum_f.CTRL_EVAL_D%type := 0;
v_ce_significantly_deficient rci_proc_cert_sum_f.CTRL_EVAL_SD%type := 0;
v_ce_not_evaluated rci_proc_cert_sum_f.CTRL_EVAL_NE%type := 0;
v_open_issues NUMBER;
BEGIN
    v_proc_name := 'update_proc_cert_table';
    fnd_file.put_line (fnd_file.LOG, v_proc_name||' start');
	v_open_issues := amw_findings_pkg.calculate_open_findings('AMW_PROC_CERT_ISSUES',
                                    'PROCESS',
                                    p_process_id,
                                    'ORGANIZATION',
                                    p_org_id,
                                    'CERTIFICATION',
                                    cert_rec.cert_id,
                                    null, null, null, null);
    open c_get_certification_opinion;
    fetch c_get_certification_opinion into r_certification_opinion;
    close c_get_certification_opinion;
	OPEN  c_get_risks_with_ineff_ctrls;
	FETCH c_get_risks_with_ineff_ctrls into v_risks_with_ineff_ctrls;
	CLOSE c_get_risks_with_ineff_ctrls;
	FOR r_get_risk_evals IN c_get_risk_evals LOOP
		  IF r_get_risk_evals.risk_eval is null THEN
		      v_re_not_evaluated := r_get_risk_evals.cnt;
		  END IF;
		  IF r_get_risk_evals.risk_eval = 'EFFECTIVE' THEN
		      v_re_mitigated := r_get_risk_evals.cnt;
		  END IF;
		  IF r_get_risk_evals.risk_eval = 'SOMEWHAT_EFFECTIVE' THEN
		      v_re_somewhat_mitigated := r_get_risk_evals.cnt;
		  END IF;
		  IF r_get_risk_evals.risk_eval = 'NEARLY_INEFFECTIVE' THEN
		      v_re_somewhat_exposed := r_get_risk_evals.cnt;
		  END IF;
		  IF r_get_risk_evals.risk_eval = 'INEFFECTIVE' THEN
		      v_re_fully_exposed := r_get_risk_evals.cnt;
		  END IF;
	END LOOP;
    FOR r_get_control_evals IN c_get_control_evals LOOP
		  IF r_get_control_evals.ctrl_eval is null THEN
		      v_ce_not_evaluated := r_get_control_evals.cnt;
		  END IF;
		  IF r_get_control_evals.ctrl_eval = 'EFFECTIVE' THEN
		      v_ce_effective := r_get_control_evals.cnt;
		  END IF;
		  IF r_get_control_evals.ctrl_eval = 'SOMEWHAT_EFFECTIVE' THEN
		      v_ce_materially_weak := r_get_control_evals.cnt;
		  END IF;
		  IF r_get_control_evals.ctrl_eval = 'NEARLY_INEFFECTIVE' THEN
		      v_ce_deficient := r_get_control_evals.cnt;
		  END IF;
		  IF r_get_control_evals.ctrl_eval = 'INEFFECTIVE' THEN
		      v_ce_significantly_deficient := r_get_control_evals.cnt;
		  END IF;
	END LOOP;

    v_certification_result := r_certification_opinion.audit_result_code;
    IF v_certification_result is null THEN
        v_not_certified := 1;
        v_certification_result := 'NOT_CERTIFIED';
    ELSIF v_certification_result='INEFFECTIVE' THEN
        v_cert_with_issues := 1;
    ELSIF v_certification_result='EFFECTIVE' THEN
        v_certified := 1;
    END IF;
UPDATE rci_proc_cert_sum_f
	SET
        CERT_RESULT		  = v_certification_result,
        CERT_RESULT_CWI	  = v_cert_with_issues,
        CERT_RESULT_C	  = v_certified,
        CERT_RESULT_NC	  =	v_not_certified,
        CERT_STATUS = cert_rec.cert_status,
        CERT_TYPE = cert_rec.cert_type,
        RISKS_WITH_INEFF_CTRLS = v_risks_with_ineff_ctrls,
		RISK_EVAL_M = v_re_mitigated,
		RISK_EVAL_SM = v_re_somewhat_mitigated,
		RISK_EVAL_SE = v_re_somewhat_exposed,
		RISK_EVAL_FE = 	v_re_somewhat_exposed,
		RISK_EVAL_NE = v_re_not_evaluated,
		CTRL_EVAL_E = 	v_ce_effective,
		CTRL_EVAL_MW =v_ce_materially_weak,
		CTRL_EVAL_D = v_ce_deficient,
		CTRL_EVAL_SD = v_ce_significantly_deficient,
		CTRL_EVAL_NE =	v_ce_not_evaluated,
        OPEN_ISSUES       = v_open_issues,
--	    certification_opinion_id = l_certification_opinion_id,
	    lAST_UPDATE_DATE 	     = SYSDATE,
	    lAST_UPDATED_BY          = G_USER_ID,
	    lAST_UPDATE_LOGIN        = G_LOGIN_ID
	WHERE
	CERTIFICATION_ID         = cert_rec.cert_id
	AND ORGANIZATION_ID          = p_org_id
    AND PROCESS_ID             = p_process_id;

	IF (SQL%NOTFOUND) THEN
		INSERT INTO rci_proc_cert_sum_f(
            CERTIFICATION_ID,
            ORGANIZATION_ID,
            PROCESS_ID,
            CERT_STATUS,
            CERT_TYPE,
            CERT_RESULT,
            CERT_RESULT_CWI,
            CERT_RESULT_C,
            CERT_RESULT_NC,
            RISKS_WITH_INEFF_CTRLS,
			RISK_EVAL_M,
			RISK_EVAL_SM,
			RISK_EVAL_SE,
			RISK_EVAL_FE,
			RISK_EVAL_NE,
			CTRL_EVAL_E,
			CTRL_EVAL_MW,
			CTRL_EVAL_D,
			CTRL_EVAL_SD,
			CTRL_EVAL_NE,
            OPEN_ISSUES,
            PERIOD_YEAR,
            PERIOD_NUM,
            QUARTER_NUM,
            ENT_PERIOD_ID,
            ENT_QTR_ID,
            ENT_YEAR_ID,
            REPORT_DATE_JULIAN,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN)
        VALUES (
			cert_rec.cert_id,
	        p_org_id,
	        p_process_id,
	        cert_rec.cert_status,
	        cert_rec.cert_type,
	        v_certification_result,
	        v_cert_with_issues,
	        v_certified,
	        v_not_certified,
	        v_risks_with_ineff_ctrls,
			v_re_mitigated,
			v_re_somewhat_mitigated,
			v_re_somewhat_exposed,
			v_re_fully_exposed,
			v_re_not_evaluated,
			v_ce_effective,
			v_ce_materially_weak,
			v_ce_deficient,
			v_ce_significantly_deficient,
			v_ce_not_evaluated,
	        v_open_issues,
            time_rec.period_year ,
            time_rec.period_num ,
            time_rec.quarter_num ,
            time_rec.ent_period_id ,
            time_rec.ent_qtr_id ,
            time_rec.ent_year_id ,
            time_rec.report_date_julian ,
	        G_USER_ID,
	        sysdate,
	        G_USER_ID,
	        sysdate,
	        G_LOGIN_ID);
	END IF;
    fnd_file.put_line (fnd_file.LOG, v_proc_name||' end');
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in '||v_proc_name || ' '
	|| SUBSTR (SQLERRM, 1, 100), 1, 200));
	WHEN OTHERS THEN
	fnd_file.put_line (fnd_file.LOG, SUBSTR ('Error in '||v_proc_name || ' '
	|| SUBSTR (SQLERRM, 1, 100), 1, 200));
END update_proc_cert_table;*/

end RCI_PROC_CERT_SUMM_PKG;

/
