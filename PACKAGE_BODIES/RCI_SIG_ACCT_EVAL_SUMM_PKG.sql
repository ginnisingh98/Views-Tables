--------------------------------------------------------
--  DDL for Package Body RCI_SIG_ACCT_EVAL_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCI_SIG_ACCT_EVAL_SUMM_PKG" AS
/*$Header: rcisgacb.pls 120.26.12000000.1 2007/01/16 20:46:46 appldev ship $*/

--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

G_USER_ID NUMBER   := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER  := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE get_kpi(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
    l_sqlstmt      VARCHAR2(15000);
    total_qry VARCHAR2(15000);
    counter NUMBER := 0;
    where_clause VARCHAR2(2000) := ' ';
    v_total NUMBER;
	v_period   varchar2(10);
    l_bind_rec BIS_QUERY_ATTRIBUTES;

BEGIN

    counter := p_page_parameter_tbl.COUNT;
    FOR i IN 1..counter LOOP
      IF p_page_parameter_tbl(i).parameter_id IS NOT NULL THEN
        IF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' THEN
            where_clause := where_clause || ' AND accteval.certification_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' THEN
            where_clause := where_clause || ' AND accteval.cert_type='|| p_page_parameter_tbl(i).parameter_id ;
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

    total_qry := 'SELECT COUNT(1) FROM (
    			select
    				sig_acct_id
                    ,acct_eval_result_code
                    ,certification_id
    				,acct_eval_e
    				,acct_eval_ne
    				,acct_eval_ie
    				,proc_cert_result_cwi
    				,proc_cert_result_c
    				,proc_cert_result_nc
    				,orgs_with_ineff_ctrls
    				,unmiti_risks
    				,ineff_ctrls
    			from
    		    	rci_sig_acct_eval_f accteval,fii_time_day ftd
		    	where
		    	accteval.report_date_julian = ftd.report_date_julian
		    	'|| where_clause || '
    			group by
    				sig_acct_id
                    ,acct_eval_result_code
                    ,certification_id
    				,acct_eval_e
    				,acct_eval_ne
    				,acct_eval_ie
    				,proc_cert_result_cwi
    				,proc_cert_result_c
    				,proc_cert_result_nc
    				,orgs_with_ineff_ctrls
    				,unmiti_risks
    				,ineff_ctrls )' ;
    EXECUTE IMMEDIATE total_qry INTO v_total using v_period;

    IF v_total = 0 THEN
        v_total := 1;
    END IF;

    l_sqlstmt :='SELECT
                    ROUND((nvl(MES1,0)*100/'||v_total ||'),2) AS RCI_SIG_ACCT_EVAL_SUMM_DIM1,
                    ROUND((nvl(MES2,0)*100/'||v_total ||'),2) AS RCI_SIG_ACCT_EVAL_SUMM_DIM2,
                    ROUND((nvl(MES3,0)*100/'||v_total ||'),2) AS RCI_SIG_ACCT_EVAL_SUMM_DIM3
                FROM (
                    SELECT
                        SUM(acct_eval_ne) MES1,
                        SUM(acct_eval_ie) MES2,
                        SUM(acct_eval_e) MES3
                    FROM
                        (select
            				sig_acct_id
                            ,acct_eval_result_code
                            ,certification_id
            				,acct_eval_e
            				,acct_eval_ne
            				,acct_eval_ie
            				,proc_cert_result_cwi
            				,proc_cert_result_c
            				,proc_cert_result_nc
            				,orgs_with_ineff_ctrls
            				,unmiti_risks
            				,ineff_ctrls
            			from
            		    	rci_sig_acct_eval_f accteval,fii_time_day ftd
        		    	where
        		    	accteval.report_date_julian = ftd.report_date_julian
        		    	'|| where_clause || '
            			group by
            				sig_acct_id
                            ,acct_eval_result_code
                            ,certification_id
            				,acct_eval_e
            				,acct_eval_ne
            				,acct_eval_ie
            				,proc_cert_result_cwi
            				,proc_cert_result_c
            				,proc_cert_result_nc
            				,orgs_with_ineff_ctrls
            				,unmiti_risks
            				,ineff_ctrls
           				) accteval
                        )
        ';

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

PROCEDURE get_sig_acct_eval_details(
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
            where_clause := where_clause || ' AND accteval.organization_id='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
            where_clause := where_clause || ' AND accteval.process_id='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' THEN
            where_clause := where_clause || ' AND accteval.certification_id='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' THEN
            where_clause := where_clause || ' AND accteval.cert_status='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' THEN
            /* 12.16.2005 npanandi: changed below because cert_type is a number
			              bug 4893008 fix **/
			where_clause := where_clause || ' AND accteval.cert_type='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_ACCT_EVAL' THEN
            if p_page_parameter_tbl(i).parameter_id = 'NOT_EVALUATED' then
                where_clause := where_clause || ' AND accteval.acct_eval_result_code is null ';
            else
			    /* 12.16.2005 npanandi: changed below because 3 quotes gives error bug 4893008 fix **/
                where_clause := where_clause || ' AND accteval.acct_eval_result_code='|| p_page_parameter_tbl(i).parameter_id;
            end if;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' THEN
            where_clause := where_clause || ' AND accteval.sig_acct_id='|| p_page_parameter_tbl(i).parameter_id;
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
--todo if needed join ,amw_fin_key_accounts_tl afka on afka.natural_account_id
l_sqlstmt :=
'
SELECT DISTINCT
	accteval.sig_acct_id RCI_DRILLDOWN_PARAM2
	,'' '' RCI_PROC_CERT_MEASURE14
    ,afces.fin_certification_id RCI_DRILLDOWN_PARAM1
    ,acv.certification_name RCI_PROC_CERT_MEASURE1
    ,typelook.value RCI_PROC_CERT_MEASURE2
    ,aecv.full_name RCI_PROC_CERT_MEASURE3
    ,afsv.name RCI_PROC_CERT_MEASURE4
    ,agpv.quarter_num RCI_PROC_CERT_MEASURE5
    ,agpv.period_year RCI_PROC_CERT_MEASURE6
    ,statuslook.value RCI_PROC_CERT_MEASURE7
    ,trunc(acv.certification_creation_date) RCI_PROC_CERT_MEASURE8
    ,trunc(acv.target_completion_date) RCI_PROC_CERT_MEASURE9
	,proc_pending_certification RCI_PROC_CERT_MEASURE10
--	,evallook.value RCI_PROC_CERT_MEASURE11
    /*01.26.2006 npanandi: bug 5000443 fix below**/
	,/*o.audit_result*/rfaev.value RCI_PROC_CERT_MEASURE11
    ,o.author RCI_PROC_CERT_MEASURE12
    ,trunc(o.authored_date) RCI_PROC_CERT_MEASURE13
FROM
    rci_sig_acct_eval_f accteval
    ,fii_time_day ftd
	,amw_fin_cert_eval_sum afces
	,amw_opinions_v o
	,amw_certification_vl acv
	,amw_employees_current_v aecv
	,amw_fin_stmnt_vl afsv
/*	,(select id,value from rci_fs_acct_eval_v where obj_name=''AMW_KEY_ACCOUNT'') evallook
	,(select * from rci_fs_cert_status_v rfcsv) statuslook
	,(select * from rci_fs_cert_type_v rfctv) typelook
	,(select period_name, quarter_num, period_year from amw_gl_periods_v) agpv*/
	,rci_fs_cert_status_v statuslook
	,rci_fs_cert_type_v typelook
	,amw_gl_periods_v agpv
	/*01.26.2006 npanandi: bug 5000443 fix below**/
	,RCI_FS_ACCT_EVAL_V rfaev
WHERE
	accteval.sig_acct_id = afces.natural_account_id
	AND accteval.report_date_julian = ftd.report_date_julian
	AND afces.object_type = ''ACCOUNT''
	AND accteval.certification_id = acv.certification_id
	AND afces.fin_certification_id = acv.certification_id
	AND o.pk1_value(+) = afces.natural_account_id
	AND o.pk2_value (+)= afces.fin_certification_id
	AND o.opinion_type_code(+) = ''EVALUATION''
	AND o.object_name(+) = ''AMW_KEY_ACCOUNT''
	/*01.26.2006 npanandi: bug 5000443 fix below 2 lines**/
    and nvl(o.audit_result_code,''NOT_EVALUATED'')=rfaev.id(+)
	and rfaev.obj_name(+)=''AMW_KEY_ACCOUNT''
    AND typelook.id(+) = accteval.cert_type
    AND statuslook.id(+) = accteval.cert_status
--	AND evallook.id(+) = o.audit_result_code
	AND acv.certification_owner_id = aecv.party_id
	AND acv.financial_statement_id = afsv.financial_statement_id
	' || where_clause || '
    and acv.certification_period_name = agpv.period_name
';

p_exp_source_sql := l_sqlstmt;
	p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':TIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

END get_sig_acct_eval_details;

-- used in get_org_details
FUNCTION get_risk_count(p_org_id number) return number is
v_count number;
BEGIN
    select count(*) into v_count from amw_risk_Associations where pk1=p_org_id and (object_type='PROCESS_ORG' or object_type='ENTITY_RISK' );
    return v_count;
END;

-- used in get_org_details
FUNCTION get_control_count(p_org_id number) return number is
v_count number;
BEGIN
    select count(*) into v_count from amw_control_Associations where pk1=p_org_id and (object_type='RISK_ORG' or object_type='ENTITY_CONTROL');
    return v_count;
END;

-- used in get_org_details
FUNCTION get_latest_engagement(p_org_id number) return varchar2 is
v_name varchar2(80);
BEGIN
    select project_name into v_name from amw_audit_projects_v where audit_project_id =
        (select entity_id from
            (select distinct entity_id,creation_date from amw_Execution_scope
                where entity_type='PROJECT' and organization_id=p_org_id
                order by creation_date desc
        ) where rownum<2
        );

    return v_name;
END;

PROCEDURE get_org_details(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
    l_sqlstmt      VARCHAR2(15000);
    counter NUMBER := 0;
    where_clause VARCHAR2(2000) := '';
    ---01.05.2006 npanandi: added l_act_sqlstmt below
   l_act_sqlstmt  VARCHAR2(15000);
	v_period   varchar2(10);
    l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN
    counter := p_page_parameter_tbl.COUNT;
    FOR i IN 1..counter LOOP
      IF p_page_parameter_tbl(i).parameter_id IS NOT NULL THEN
        IF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' THEN
            where_clause := where_clause || ' AND rocsf.organization_id='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
            where_clause := where_clause || ' AND rocsf.process_id='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' THEN
            where_clause := where_clause || ' AND rocsf.fin_certification_id='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' THEN
		    /***12.19.2005 npanandi: 3 quotes below give error ***/
            where_clause := where_clause || ' AND rocsf.certification_status='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' THEN
		    /***12.19.2005 npanandi: 3 quotes below give error ***/
            where_clause := where_clause || ' AND rocsf.certification_type='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_ORG_CERT_RESULT' THEN
		    /***12.07.2005 npanandi: commented out Divyesh's parameter handler***/
            /**if p_page_parameter_tbl(i).parameter_id = '''NOT_CERTIFIED''' then
                where_clause := where_clause || ' AND rocsf.org_certification_status is null ';
            else
                where_clause := where_clause || ' AND rocsf.org_certification_status='|| p_page_parameter_tbl(i).parameter_id ||' ';
            end if;***/
			/*** and added the following modified parameter handler ***/
			if(p_page_parameter_tbl(i).parameter_id = '''EFFECTIVE''')then
			   where_clause := where_clause || ' and rocsf.org_certification_status=''EFFECTIVE'' ';
			elsif(p_page_parameter_tbl(i).parameter_id = '''INEFFECTIVE''') then
			   /**01.11.2006 npanandi: changed below to handle bug in populating
					   cert_opinion_log_id column in amw_org_eval_sum tbl ***/
			   where_clause := where_clause || ' and decode(rocsf.org_certification_status,null,''NOT_CERTIFIED'',''EFFECTIVE'',''EFFECTIVE'',''INEFFECTIVE'')=''INEFFECTIVE'' ';
			else
			   where_clause := where_clause || ' and rocsf.org_certification_status IS NULL ';
			end if;
			/***12.07.2005 npanandi: ends changed code ***/
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' THEN
            where_clause := where_clause || ' AND rocsf.natural_account_id='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
            ----12.08.2005 npanandi: changed from agpv to ftd below
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_period_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
		    ----12.08.2005 npanandi: changed from agpv to ftd below
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_qtr_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
		    ----12.08.2005 npanandi: changed from agpv to ftd below
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_year_id = :TIME ';
        END IF;
      END IF; -- parameter_id IS NOT NULL
    END LOOP;

/*** 12.08.2005 npanandi: commenting Divyesh's SQL query construction below
l_sqlstmt :=
'
SELECT DISTINCT
	aauv.organization_id RCI_DRILLDOWN_PARAM1
	,aauv.NAME                   RCI_PROC_CERT_MEASURE1
	,aauv.company                RCI_PROC_CERT_MEASURE2
	,aauv.lob_description        RCI_PROC_CERT_MEASURE3
	,RCI_SIG_ACCT_EVAL_SUMM_PKG.get_risk_count(aauv.organization_id) RCI_PROC_CERT_MEASURE4
	,RCI_SIG_ACCT_EVAL_SUMM_PKG.get_control_count(aauv.organization_id) RCI_PROC_CERT_MEASURE5
	,'' '' RCI_PROC_CERT_MEASURE6
	,acv.certification_name RCI_PROC_CERT_MEASURE7
	,certres.value	RCI_PROC_CERT_MEASURE8
	,trunc(rocsf.ORG_CERTIFIED_ON)	RCI_PROC_CERT_MEASURE9
	,RCI_SIG_ACCT_EVAL_SUMM_PKG.get_latest_engagement(aauv.organization_id) RCI_PROC_CERT_MEASURE10
	,evalopinion.eval_result RCI_PROC_CERT_MEASURE11
	,trunc(evalopinion.eval_date)RCI_PROC_CERT_MEASURE12
	,evalopinion.eval_by RCI_PROC_CERT_MEASURE13
FROM
	amw_audit_units_v           aauv
	,rci_org_cert_summ_f rocsf
	,amw_certification_vl acv
	,rci_bp_cert_result_v certres
	,(select audit_result eval_result,authored_date eval_date,pk1_value org_id,pk2_value project_id,author eval_by from amw_opinions_v aov1
		where aov1.opinion_type_code(+) = ''EVALUATION'' and aov1.object_name(+) = ''AMW_ORGANIZATION''
		and aov1.authored_date = (select max(aov2.authored_date) from amw_opinions_v aov2
									where aov2.opinion_type_code(+) = ''EVALUATION'' and aov2.object_name(+) = ''AMW_ORGANIZATION''
									and aov1.pk1_value=aov2.pk1_value))
	evalopinion
	,(select period_name, period_set_name,
	to_number(to_char(period_year)||to_char(quarter_num)||to_char(period_num)) ent_period_id,
	to_number(to_char(period_year)||to_char(quarter_num)) ent_qtr_id,
	period_year ent_year_id from amw_gl_periods_v) agpv
WHERE
	aauv.organization_id = rocsf.organization_id
	AND acv.certification_id = rocsf.certification_id
	AND certres.id = nvl(rocsf.org_certification_status,''NOT_CERTIFIED'')
	AND evalopinion.org_id(+) = aauv.organization_id
	' || where_clause || '
	AND acv.certification_period_name = agpv.period_name
	AND acv.certification_period_set_name = agpv.period_set_name
';
***/
/**** 12.08.2005 npanandi: ends commenting of Divyesh's SQL query above ***/


   /*** 12.08.2005 npanandi: modified SQL query for report generation ***/
   l_sqlstmt := 'SELECT DISTINCT aauv.organization_id RCI_DRILLDOWN_PARAM1
	                   ,aauv.NAME RCI_PROC_CERT_MEASURE1
	  				   ,aauv.company RCI_PROC_CERT_MEASURE2
	  				   ,aauv.lob_description RCI_PROC_CERT_MEASURE3
	  				   ,RCI_SIG_ACCT_EVAL_SUMM_PKG.get_risk_count(aauv.organization_id) RCI_PROC_CERT_MEASURE4
	  				   ,RCI_SIG_ACCT_EVAL_SUMM_PKG.get_control_count(aauv.organization_id) RCI_PROC_CERT_MEASURE5
	  				   ,'' '' RCI_PROC_CERT_MEASURE6
	  				   ,acv.certification_name RCI_PROC_CERT_MEASURE7
	  				   ,certres.value RCI_PROC_CERT_MEASURE8
	  				   ,trunc(rocsf.ORG_CERTIFIED_ON) RCI_PROC_CERT_MEASURE9
	  				   ,RCI_SIG_ACCT_EVAL_SUMM_PKG.get_latest_engagement(aauv.organization_id) RCI_PROC_CERT_MEASURE10
	  				   ,evalopinion.eval_result RCI_PROC_CERT_MEASURE11
	  				   ,evalopinion.eval_by RCI_PROC_CERT_MEASURE12
	  				   ,trunc(evalopinion.eval_date) RCI_PROC_CERT_MEASURE13
  				   FROM amw_audit_units_v aauv
	                   ,rci_org_cert_summ_f rocsf
	                   ,amw_certification_vl acv
	                   ,rci_bp_cert_result_v certres
	                   ,(select audit_result eval_result,authored_date eval_date,pk1_value org_id,pk2_value project_id,author eval_by
                           from amw_opinions_v aov1
		                  where aov1.opinion_type_code(+) = ''EVALUATION''
                            and aov1.object_name(+) = ''AMW_ORGANIZATION''
		                    and aov1.authored_date = (select max(aov2.authored_date)
							                            from amw_opinions_v aov2
									                   where aov2.opinion_type_code(+) = ''EVALUATION''
                                                         and aov2.object_name(+) = ''AMW_ORGANIZATION''
									                     and aov1.pk1_value=aov2.pk1_value)) evalopinion
	                   ,fii_time_day ftd
 				  WHERE aauv.organization_id = rocsf.organization_id
				    /***01.10.2006 npanandi: changed below to join to rocsf
					     fin_certification_id instead of previous certification_id ***/
   				    AND acv.certification_id = rocsf.fin_certification_id
					/**01.11.2006 npanandi: changed below to handle bug in populating
					   cert_opinion_log_id column in amw_org_eval_sum tbl ***/
   					/***AND certres.id = nvl(rocsf.org_certification_status,''NOT_CERTIFIED'')***/
					AND certres.id = decode(rocsf.org_certification_status,null,''NOT_CERTIFIED'',''EFFECTIVE'',''EFFECTIVE'',''INEFFECTIVE'')
   					AND evalopinion.org_id(+) = aauv.organization_id
   					and rocsf.report_date_julian=ftd.report_date_julian';
      /*** 12.08.2005 npanandi: ends modified SQL query for report generation ***/

      /*** 01.05.2006 npanandi: added following modification for sorting **/
      /** 12.22.2005 npanandi: added SQL below to handle order_by_clause -- bug 4758762 **/
   l_act_sqlstmt := 'select RCI_DRILLDOWN_PARAM1,RCI_PROC_CERT_MEASURE1,RCI_PROC_CERT_MEASURE2
                           ,RCI_PROC_CERT_MEASURE3,RCI_PROC_CERT_MEASURE4
                           ,RCI_PROC_CERT_MEASURE5,RCI_PROC_CERT_MEASURE6
						   ,RCI_PROC_CERT_MEASURE7,RCI_PROC_CERT_MEASURE8
						   ,RCI_PROC_CERT_MEASURE9,RCI_PROC_CERT_MEASURE10
						   ,RCI_PROC_CERT_MEASURE11,RCI_PROC_CERT_MEASURE12,RCI_PROC_CERT_MEASURE13
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_sqlstmt || where_clause||'
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
END get_org_details;

-- used in get_org_def_details
FUNCTION get_unmiti_risks(p_cert_id number, p_org_id number) return number is
v_cnt number;
BEGIN
    SELECT
        count(1) into v_cnt
    FROM 	(SELECT DISTINCT aca.pk1 cert_id, aca.pk2 org_id, aca.control_id
    	FROM amw_control_associations aca,amw_opinions_v aov
    	WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
    	AND aca.pk1 		  = p_cert_id
    	AND aca.pk2               = p_org_id
    	AND aov.object_name       = 'AMW_ORG_CONTROL'
    	AND aov.opinion_type_code = 'EVALUATION'
    	AND aov.pk1_value 	  = aca.control_id
    	AND aov.pk3_value 	  = aca.pk2
    	AND aov.audit_result_code <> 'EFFECTIVE'
    	AND aov.authored_date = (SELECT MAX(aov2.authored_date)
    				FROM amw_opinions aov2
    				WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
    				AND aov2.pk3_value = aov.pk3_value
    				AND aov2.pk1_value = aov.pk1_value)
    	);

    return v_cnt;
END get_unmiti_risks;

-- used in get_org_def_details
FUNCTION get_ineff_ctrls(p_cert_id number, p_org_id number) return number is
v_cnt number;
BEGIN
    SELECT count(1) into v_cnt
    FROM 	(SELECT DISTINCT aca.pk1 cert_id, aca.pk2 org_id, aca.control_id
    	FROM amw_control_associations aca,amw_opinions_v aov
    	WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
    	AND aca.pk1 		  = p_cert_id
    	AND aca.pk2               = p_org_id
    	AND aov.object_name       = 'AMW_ORG_CONTROL'
    	AND aov.opinion_type_code = 'EVALUATION'
    	AND aov.pk1_value 	  = aca.control_id
    	AND aov.pk3_value 	  = aca.pk2
    	AND aov.audit_result_code <> 'EFFECTIVE'
    	AND aov.authored_date = (SELECT MAX(aov2.authored_date)
    				FROM amw_opinions aov2
    				WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
    				AND aov2.pk3_value = aov.pk3_value
    				AND aov2.pk1_value = aov.pk1_value)
    	);
    return v_cnt;
END get_ineff_ctrls;

-- used in get_org_def_details
FUNCTION get_ineff_procs(p_cert_id number, p_org_id number) return number is
v_cnt number;
BEGIN
    SELECT
        count(DISTINCT amw_exec.process_id) into v_cnt
	FROM
        amw_execution_scope amw_exec
	WHERE
        amw_exec.entity_type = 'BUSIPROC_CERTIFICATION'
    	AND amw_exec.entity_id = p_cert_id
        AND EXISTS (SELECT  opinion.opinion_id
            		FROM amw_opinions_v opinion
            		WHERE opinion.pk1_value = amw_exec.process_id
            		AND   opinion.pk3_value = p_org_id
            		AND   opinion.opinion_type_code = 'EVALUATION'
            		AND   opinion.object_name = 'AMW_ORG_PROCESS'
            		AND   opinion.audit_result_code <> 'EFFECTIVE'
            		AND    opinion.authored_date = (SELECT MAX(aov2.authored_date)
        	                                FROM amw_opinions aov2
        	                                WHERE aov2.object_opinion_type_id = opinion.object_opinion_type_id
        	                                AND aov2.pk3_value = opinion.pk3_value
        	                                AND aov2.pk1_value = opinion.pk1_value)
        	                                );
    return v_cnt;
END get_ineff_procs;

PROCEDURE get_org_def_details(
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
                where_clause := where_clause || ' AND rocsf.organization_id='|| p_page_parameter_tbl(i).parameter_id ||' ';
            ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
                where_clause := where_clause || ' AND rocsf.process_id='|| p_page_parameter_tbl(i).parameter_id ||' ';
            ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' THEN
                where_clause := where_clause || ' AND rocsf.fin_certification_id='|| p_page_parameter_tbl(i).parameter_id ||' ';
            ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' THEN
                where_clause := where_clause || ' AND rocsf.certification_status='|| p_page_parameter_tbl(i).parameter_id ||' ';
            ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' THEN
                where_clause := where_clause || ' AND rocsf.certification_type='|| p_page_parameter_tbl(i).parameter_id ||' ';
            ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_ORG_CERT_RESULT' THEN
    			if(p_page_parameter_tbl(i).parameter_id = '''EFFECTIVE''')then
    			   where_clause := where_clause || ' and rocsf.org_certification_status=''EFFECTIVE'' ';
    			elsif(p_page_parameter_tbl(i).parameter_id = '''INEFFECTIVE''') then
    			   where_clause := where_clause || ' and rocsf.org_certification_status=''INEFFECTIVE'' ';
    			else
    			   where_clause := where_clause || ' and rocsf.org_certification_status IS NULL ';
    			end if;
            ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' THEN
                where_clause := where_clause || ' AND rocsf.natural_account_id='|| p_page_parameter_tbl(i).parameter_id ||' ';
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

l_sqlstmt :=
'
SELECT
    DISTINCT aauv.organization_id RCI_DRILLDOWN_PARAM1
       ,aauv.NAME RCI_PROC_CERT_MEASURE1
	   ,aauv.company RCI_PROC_CERT_MEASURE2
	   ,aauv.lob_description RCI_PROC_CERT_MEASURE3
	   ,RCI_SIG_ACCT_EVAL_SUMM_PKG.get_unmiti_risks(acv.certification_id,aauv.organization_id) RCI_PROC_CERT_MEASURE4
	   ,RCI_SIG_ACCT_EVAL_SUMM_PKG.get_ineff_ctrls(acv.certification_id,aauv.organization_id) RCI_PROC_CERT_MEASURE5
	   ,RCI_SIG_ACCT_EVAL_SUMM_PKG.get_ineff_procs(acv.certification_id,aauv.organization_id) RCI_PROC_CERT_MEASURE6
	   ,'' '' RCI_PROC_CERT_MEASURE7
	   ,acv.certification_name RCI_PROC_CERT_MEASURE8
	   ,certres.value RCI_PROC_CERT_MEASURE9
	   ,trunc(rocsf.ORG_CERTIFIED_ON) RCI_PROC_CERT_MEASURE10
	   ,RCI_SIG_ACCT_EVAL_SUMM_PKG.get_latest_engagement(aauv.organization_id) RCI_PROC_CERT_MEASURE11
	   ,evalopinion.eval_result RCI_PROC_CERT_MEASURE12
	   ,evalopinion.eval_by RCI_PROC_CERT_MEASURE13
	   ,trunc(evalopinion.eval_date) RCI_PROC_CERT_MEASURE14
   FROM amw_audit_units_v aauv
       ,rci_org_cert_summ_f rocsf
       ,amw_certification_vl acv
       ,rci_bp_cert_result_v certres
       ,(select audit_result eval_result,authored_date eval_date,pk1_value org_id,pk2_value project_id,author eval_by
           from amw_opinions_v aov1
          where aov1.opinion_type_code(+) = ''EVALUATION''
            and aov1.object_name(+) = ''AMW_ORGANIZATION''
            and aov1.authored_date = (select max(aov2.authored_date)
			                            from amw_opinions_v aov2
					                   where aov2.opinion_type_code(+) = ''EVALUATION''
                                         and aov2.object_name(+) = ''AMW_ORGANIZATION''
					                     and aov1.pk1_value=aov2.pk1_value)) evalopinion
       ,fii_time_day ftd
  WHERE aauv.organization_id = rocsf.organization_id
    AND acv.certification_id = rocsf.fin_certification_id
    AND certres.id = decode(rocsf.org_certification_status,null,''NOT_CERTIFIED'',''EFFECTIVE'',''EFFECTIVE'',''INEFFECTIVE'')
	AND evalopinion.org_id(+) = aauv.organization_id
	AND rocsf.report_date_julian=ftd.report_date_julian
	AND rocsf.ineffective_controls > 0
'||where_clause;

p_exp_source_sql := l_sqlstmt;
	p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':TIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

END get_org_def_details;

PROCEDURE get_sig_acct_details(
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
            where_clause := where_clause || ' AND accteval.organization_id='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
            where_clause := where_clause || ' AND accteval.process_id='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' THEN
            where_clause := where_clause || ' AND accteval.certification_id='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' THEN
		    /* 12.16.2005 npanandi: changed below because 3 quotes gives an error -- bug 4893008 fix **/
            where_clause := where_clause || ' AND accteval.cert_status='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' THEN
		    /* 12.16.2005 npanandi: changed below because cert_type is a number
			              bug 4893008 fix **/
            where_clause := where_clause || ' AND accteval.cert_type='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_ACCT_EVAL' THEN
            if p_page_parameter_tbl(i).parameter_id = 'NOT_EVALUATED' then
                where_clause := where_clause || ' AND accteval.acct_eval_result_code is null ';
            else
			    /* 12.16.2005 npanandi: changed below because 3 quotes gives an error -- bug 4893008 fix **/
                where_clause := where_clause || ' AND accteval.acct_eval_result_code='|| p_page_parameter_tbl(i).parameter_id ||' ';
            end if;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' THEN
            where_clause := where_clause || ' AND accteval.sig_acct_id='|| p_page_parameter_tbl(i).parameter_id ||' ';
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
--add (+) on the first two lines of where clause
l_sqlstmt :=
'
SELECT DISTINCT
    accteval.certification_id RCI_DRILLDOWN_PARAM1
	,accteval.sig_acct_id RCI_DRILLDOWN_PARAM2
	,afka.account_name RCI_PROC_CERT_MEASURE1
	,nvl(afces.proc_pending_certification,0) RCI_PROC_CERT_MEASURE2
	,nvl(afces.proc_with_ineffective_controls,0) RCI_PROC_CERT_MEASURE3
	,nvl(afces.unmitigated_risks,0) RCI_PROC_CERT_MEASURE4
	,nvl(afces.ineffective_controls,0) RCI_PROC_CERT_MEASURE5
	,acv.certification_name RCI_PROC_CERT_MEASURE6
	,rfaev.value RCI_PROC_CERT_MEASURE7
	,o.author RCI_PROC_CERT_MEASURE8
	,trunc(o.authored_date) RCI_PROC_CERT_MEASURE9
FROM
    rci_sig_acct_eval_f accteval
    ,fii_time_day ftd
	,amw_fin_cert_eval_sum afces
	,amw_fin_key_accounts_vl afka
   ,(select distinct authored_date,pk1_value,pk2_value,author
       from amw_opinions_v aov1
      where aov1.opinion_type_code(+) = ''EVALUATION''
        and aov1.object_name(+) = ''AMW_KEY_ACCOUNT''
        and aov1.authored_date = (select max(aov2.authored_date)
		                            from amw_opinions_v aov2
				                   where aov2.opinion_type_code(+) = ''EVALUATION''
                                     and aov2.object_name(+) = ''AMW_KEY_ACCOUNT''
				                     and aov1.pk1_value=aov2.pk1_value
                                     and aov1.pk2_value=aov2.pk2_value)) o
	,amw_certification_vl acv
	,RCI_FS_ACCT_EVAL_V rfaev
WHERE
	afces.fin_certification_id(+) = accteval.certification_id
	AND accteval.report_date_julian = ftd.report_date_julian
	AND afces.natural_account_id(+) = accteval.sig_acct_id
	AND afces.financial_Statement_id(+) = accteval.financial_Statement_id
	AND afces.financial_item_id(+) = accteval.financial_item_id
	AND rfaev.id = accteval.acct_eval_result_code
	AND o.pk1_value(+) = accteval.sig_acct_id
	AND o.pk2_value (+)= accteval.certification_id
	AND rfaev.obj_name=''AMW_KEY_ACCOUNT''
	AND acv.certification_id = accteval.certification_id
	AND afka.natural_account_id = accteval.sig_acct_id
	' || where_clause;

p_exp_source_sql := l_sqlstmt;
	p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    p_exp_source_output.EXTEND;
    l_bind_rec.attribute_name := ':TIME';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

END get_sig_acct_details;

PROCEDURE get_sig_acct_eval_result(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
    l_sqlstmt      VARCHAR2(15000);
	l_act_sqlstmt  VARCHAR2(15000);
    counter NUMBER := 0;
    where_clause VARCHAR2(2000) := ' ';
    total_qry VARCHAR2(15000);
    v_total number;
	v_period   varchar2(10);
    l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN
    counter := p_page_parameter_tbl.COUNT;
    FOR i IN 1..counter LOOP
      IF p_page_parameter_tbl(i).parameter_id IS NOT NULL THEN
        IF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' THEN
            where_clause := where_clause || ' AND accteval.organization_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
            where_clause := where_clause || ' AND accteval.process_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' THEN
            where_clause := where_clause || ' AND accteval.certification_id='|| p_page_parameter_tbl(i).parameter_id ;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' THEN
		    /* 12.16.2005 npanandi: changed the way cert_status was in the where clause
			                        because 3 quotes gives error --> bug 4893008 fix **/
            where_clause := where_clause || ' AND accteval.cert_status='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' THEN
		    /* 12.16.2005 npanandi: changed the way cert_type was in the where clause
			                        bug 4893008 fix **/
            /* where_clause := where_clause || ' AND accteval.cert_type='''|| p_page_parameter_tbl(i).parameter_id ||''' '; */
			where_clause := where_clause || ' AND accteval.cert_type='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_ACCT_EVAL' THEN
            where_clause := where_clause || ' AND accteval.acct_eval_result_code='|| p_page_parameter_tbl(i).parameter_id ||' ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' THEN
            where_clause := where_clause || ' AND accteval.sig_acct_id='|| p_page_parameter_tbl(i).parameter_id;
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

    total_qry := 'SELECT COUNT(1) FROM (
    			select
    				sig_acct_id
                    ,acct_eval_result_code
                    ,certification_id
    				,acct_eval_e
    				,acct_eval_ne
    				,acct_eval_ie
    				,proc_cert_result_cwi
    				,proc_cert_result_c
    				,proc_cert_result_nc
    				,orgs_with_ineff_ctrls
    				,unmiti_risks
    				,ineff_ctrls
    			from
    		    	rci_sig_acct_eval_f accteval
    		    	,fii_time_day ftd
		    	where
		    	accteval.report_date_julian = ftd.report_date_julian
		    	'|| where_clause || '
    			group by
    				sig_acct_id
                    ,acct_eval_result_code
                    ,certification_id
    				,acct_eval_e
    				,acct_eval_ne
    				,acct_eval_ie
    				,proc_cert_result_cwi
    				,proc_cert_result_c
    				,proc_cert_result_nc
    				,orgs_with_ineff_ctrls
    				,unmiti_risks
    				,ineff_ctrls )' ;
    EXECUTE IMMEDIATE total_qry INTO v_total using v_period;

    IF v_total=0 THEN
        v_total := 1;
    END IF;

l_sqlstmt :=
'
    SELECT
		value VIEWBY,
		nvl(RCI_SIG_ACCT_EVAL_SUMM_DIM1,0) RCI_SIG_ACCT_EVAL_SUMM_DIM1,
		nvl(RCI_SIG_ACCT_EVAL_SUMM_DIM2,0) RCI_SIG_ACCT_EVAL_SUMM_DIM2,
		0 RCI_SIG_ACCT_EVAL_SUMM_DIM3,
		rci_fs_acct_eval_v.id RCI_DRILLDOWN_PARAM1
	FROM
		(SELECT
            acct_eval_result_code,
			count(acct_eval_result_code) RCI_SIG_ACCT_EVAL_SUMM_DIM1,
			ROUND(COUNT(acct_eval_result_code)/'||v_total||'*100,2) RCI_SIG_ACCT_EVAL_SUMM_DIM2
		FROM
			(select
				sig_acct_id
                ,acct_eval_result_code
                ,certification_id
				,acct_eval_e
				,acct_eval_ne
				,acct_eval_ie
				,proc_cert_result_cwi
				,proc_cert_result_c
				,proc_cert_result_nc
				,orgs_with_ineff_ctrls
				,unmiti_risks
				,ineff_ctrls
			from
		    	rci_sig_acct_eval_f accteval
		    	,fii_time_day ftd
	    	where
	    	accteval.report_date_julian = ftd.report_date_julian
	    	'|| where_clause || '
			group by
				sig_acct_id
                ,acct_eval_result_code
                ,certification_id
				,acct_eval_e
				,acct_eval_ne
				,acct_eval_ie
				,proc_cert_result_cwi
				,proc_cert_result_c
				,proc_cert_result_nc
				,orgs_with_ineff_ctrls
				,unmiti_risks
				,ineff_ctrls) accteval
		GROUP BY
            acct_eval_result_code) rsae
        ,(select id,value from rci_fs_acct_eval_v where obj_name=''AMW_KEY_ACCOUNT'') rci_fs_acct_eval_v
	WHERE
		id = acct_eval_result_code(+)
';

   /** 09.18.2006 npanandi: added SQL below to handle order_by_clause -- bug 5510667 **/
   l_act_sqlstmt := 'select VIEWBY,RCI_SIG_ACCT_EVAL_SUMM_DIM1,RCI_SIG_ACCT_EVAL_SUMM_DIM2
                           ,RCI_SIG_ACCT_EVAL_SUMM_DIM3,RCI_DRILLDOWN_PARAM1
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

END get_sig_acct_eval_result;

PROCEDURE get_sig_acct_eval_summ_result(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
    l_sqlstmt      VARCHAR2(15000);
	l_act_sqlstmt  varchar2(15000);
    counter NUMBER := 0;
    where_clause VARCHAR2(2000) := ' ';
    where_clause1 VARCHAR2(2000) := ' ';
	v_period   varchar2(10);
    l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN
    counter := p_page_parameter_tbl.COUNT;
    FOR i IN 1..counter LOOP
      IF p_page_parameter_tbl(i).parameter_id IS NOT NULL THEN
        IF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' THEN
            where_clause := where_clause || ' AND accteval.organization_id='|| p_page_parameter_tbl(i).parameter_id;
            where_clause1 := where_clause1 || ' AND fa_tab.organization_id='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' THEN
            where_clause := where_clause || ' AND accteval.process_id='|| p_page_parameter_tbl(i).parameter_id ;
            where_clause1 := where_clause1 || ' AND fa_tab.process_id='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' THEN
            where_clause := where_clause || ' AND accteval.certification_id='|| p_page_parameter_tbl(i).parameter_id ;
            where_clause1 := where_clause1 || ' AND fa_tab.fin_certification_id='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' THEN
		    /* 12.16.2005 npanandi: 3 quotes give error bug 4893008 fix **/
            where_clause := where_clause || ' AND accteval.cert_status='|| p_page_parameter_tbl(i).parameter_id;
            where_clause1 := where_clause1 || ' AND fa_tab.certification_status='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' THEN
            /* 12.16.2005 npanandi: changed the way cert_type was in the where clause
			                        bug 4893008 fix **/
			where_clause := where_clause || ' AND accteval.cert_type='|| p_page_parameter_tbl(i).parameter_id;
            where_clause1 := where_clause1 || ' AND fa_tab.certification_type='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_ACCT_EVAL' THEN
            IF p_page_parameter_tbl(i).parameter_id = 'EFFECTIVE' THEN
                where_clause := where_clause || ' AND accteval.acct_eval_e=1';
            ELSIF p_page_parameter_tbl(i).parameter_id = 'NOT_EVALUATED' THEN
                where_clause := where_clause || ' AND accteval.acct_eval_ne=1';
            ELSE
			    /* 12.16.2005 npanandi: 3 quotes give error bug 4893008 fix **/
                where_clause := where_clause || ' AND accteval.acct_eval_result_code='|| p_page_parameter_tbl(i).parameter_id;
            END IF;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' THEN
            where_clause := where_clause || ' AND accteval.sig_acct_id='|| p_page_parameter_tbl(i).parameter_id ;
            where_clause1 := where_clause1 || ' AND fa_tab.natural_account_id='|| p_page_parameter_tbl(i).parameter_id;
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_period_id = :TIME ';
            where_clause1 := where_clause1 || ' AND ftd.ent_period_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' THEN
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_qtr_id = :TIME ';
            where_clause1 := where_clause1 || ' AND ftd.ent_qtr_id = :TIME ';
        ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
			v_period := p_page_parameter_tbl(i).parameter_id;
            where_clause := where_clause || ' AND ftd.ent_year_id = :TIME ';
            where_clause1 := where_clause1 || ' AND ftd.ent_year_id = :TIME ';
        END IF;
      END IF; -- parameter_id IS NOT NULL
    END LOOP;

    l_sqlstmt :=
	'
    SELECT
        DISTINCT name || '' ('' || one.natural_account_value || '')'' VIEWBY
        ,0 RCI_GRAND_TOTAL
        ,sig_acct_id RCI_DRILLDOWN_PARAM1
        ,RCI_SIG_ACCT_EVAL_SUMM_DIM1    ,RCI_SIG_ACCT_EVAL_SUMM_DIM2    ,RCI_SIG_ACCT_EVAL_SUMM_DIM3
        ,RCI_SIG_ACCT_EVAL_SUMM_DIM4    ,RCI_SIG_ACCT_EVAL_SUMM_DIM5    ,RCI_SIG_ACCT_EVAL_SUMM_DIM6
        ,RCI_SIG_ACCT_EVAL_SUMM_DIM7    ,RCI_SIG_ACCT_EVAL_SUMM_DIM8    ,RCI_SIG_ACCT_EVAL_SUMM_DIM9
	FROM
	    (SELECT DISTINCT natural_account_value, sig_acct_id
	        ,RCI_SIG_ACCT_EVAL_SUMM_DIM1    ,RCI_SIG_ACCT_EVAL_SUMM_DIM2    ,RCI_SIG_ACCT_EVAL_SUMM_DIM3
	        ,RCI_SIG_ACCT_EVAL_SUMM_DIM4    ,RCI_SIG_ACCT_EVAL_SUMM_DIM5    ,RCI_SIG_ACCT_EVAL_SUMM_DIM6
	        ,RCI_SIG_ACCT_EVAL_SUMM_DIM7    ,RCI_SIG_ACCT_EVAL_SUMM_DIM8    ,RCI_SIG_ACCT_EVAL_SUMM_DIM9
	    FROM
	    (
            select
            	acct_eval.sig_acct_id
            	,acct_eval.ie RCI_SIG_ACCT_EVAL_SUMM_DIM1
            	,acct_eval.e RCI_SIG_ACCT_EVAL_SUMM_DIM2
            	,acct_eval.ne RCI_SIG_ACCT_EVAL_SUMM_DIM3
            	,nvl(ineff_org.org_with_ie_ctrls,0) RCI_SIG_ACCT_EVAL_SUMM_DIM4
            	,nvl(proc_cert.ie,0) RCI_SIG_ACCT_EVAL_SUMM_DIM5
            	,nvl(proc_cert.e,0) RCI_SIG_ACCT_EVAL_SUMM_DIM6
            	,nvl(proc_cert.ne,0) RCI_SIG_ACCT_EVAL_SUMM_DIM7
            	,nvl(unmiti_risks.risk_cnt,0) RCI_SIG_ACCT_EVAL_SUMM_DIM8
            	,nvl(ineff_ctrls.ctrl_cnt,0) RCI_SIG_ACCT_EVAL_SUMM_DIM9
            from
            	(select
                	sig_acct_id
                	,sum(acct_eval_ie) ie
                	,sum(acct_eval_e) e
                	,sum(acct_eval_ne) ne
            	from (
                	select
                    	sig_acct_id
                    	,acct_eval_result_code
                    	,certification_id
                    	,acct_eval_ie
                    	,acct_eval_e
                    	,acct_eval_ne
                	from
                    	rci_sig_acct_eval_f accteval
                    	,fii_time_day ftd
                	where
                		accteval.report_date_julian = ftd.report_date_julian
                		' || where_clause || '
                	group by
                    	sig_acct_id
                    	,acct_eval_result_code
                    	,certification_id
                    	,acct_eval_ie
                    	,acct_eval_e
                    	,acct_eval_ne
                	)
            	group by
            	    sig_acct_id
            	) acct_eval
            	,(select
            		NATURAL_ACCOUNT_ID, count(1) org_with_ie_ctrls
                from (
            			select
            				distinct NATURAL_ACCOUNT_ID, ORGANIZATION_ID, fin_certification_id
                		from
            				rci_org_cert_summ_f fa_tab, fii_time_day ftd
                		where
            	    		fa_tab.report_date_julian = ftd.report_date_julian
                			and fa_tab.ineffective_controls > 0
                			' || where_clause1 || '
                	)
                group by
            	    NATURAL_ACCOUNT_ID
            	) ineff_org
            	,(select
            	    NATURAL_ACCOUNT_ID, sum(ne) ne, sum(e) e, sum(ie) ie
            	from(
            	    select
            	        NATURAL_ACCOUNT_ID
            	        ,sum(decode(CERTIFICATION_RESULT_CODE, null,1,0)) ne
            	        ,sum(decode(CERTIFICATION_RESULT_CODE, ''EFFECTIVE'',1,0)) e
            	        ,sum(decode(CERTIFICATION_RESULT_CODE, ''INEFFECTIVE'',1,0)) ie
            	    from
            	        rci_process_detail_f fa_tab,fii_time_day ftd
            	    where
            	        fa_tab.report_date_julian = ftd.report_date_julian
            	        ' || where_clause1 || '
            	    group by
            	        NATURAL_ACCOUNT_ID, CERTIFICATION_RESULT_CODE
            	)
            	group by
            	    NATURAL_ACCOUNT_ID
            	) proc_cert
            	,(select NATURAL_ACCOUNT_ID, count(1) risk_cnt
                from (
                        select
                            distinct NATURAL_ACCOUNT_ID, RISK_ID, ORGANIZATION_ID, PROCESS_ID
                		from
                		    rci_org_cert_risks_f fa_tab, fii_time_day ftd
                		where
                    		fa_tab.report_date_julian = ftd.report_date_julian
                    		and fa_tab.AUDIT_RESULT_CODE <> ''EFFECTIVE''
            				' || where_clause1 || '
                	)
                group by
                    NATURAL_ACCOUNT_ID
                ) unmiti_risks
            	,(select NATURAL_ACCOUNT_ID, count(1) ctrl_cnt
                from (
                        select
                            distinct NATURAL_ACCOUNT_ID, CONTROL_ID, ORGANIZATION_ID
                		from
                		    rci_org_cert_ctrls_f fa_tab, fii_time_day ftd
                		where
                    		fa_tab.report_date_julian = ftd.report_date_julian
                    		and fa_tab.AUDIT_RESULT_CODE <> ''EFFECTIVE''
                    		' || where_clause1 || '
                	)
                group by
                    NATURAL_ACCOUNT_ID
                ) ineff_ctrls
            where
            	acct_eval.sig_acct_id = proc_cert.NATURAL_ACCOUNT_ID(+)
            	and acct_eval.sig_acct_id = ineff_org.NATURAL_ACCOUNT_ID(+)
            	and acct_eval.sig_acct_id = unmiti_risks.NATURAL_ACCOUNT_ID(+)
            	and acct_eval.sig_acct_id = ineff_ctrls.NATURAL_ACCOUNT_ID(+)
	    ) rsae, amw_fin_key_accounts_b accts
	    where sig_acct_id = natural_account_id
    ) one, AMW_FIN_KEY_ACCOUNTS_TL two
    WHERE one.sig_acct_id = two.natural_account_id
    and two.language=userenv(''LANG'')
    ';
--    WHERE one.natural_account_value = two.natural_account_value

   /** 09.18.2006 npanandi: added SQL below to handle order_by_clause -- bug 5510667 **/
   l_act_sqlstmt := 'select VIEWBY,RCI_GRAND_TOTAL,RCI_DRILLDOWN_PARAM1
          ,RCI_SIG_ACCT_EVAL_SUMM_DIM1,RCI_SIG_ACCT_EVAL_SUMM_DIM2,RCI_SIG_ACCT_EVAL_SUMM_DIM3
          ,RCI_SIG_ACCT_EVAL_SUMM_DIM4,RCI_SIG_ACCT_EVAL_SUMM_DIM5,RCI_SIG_ACCT_EVAL_SUMM_DIM6
          ,RCI_SIG_ACCT_EVAL_SUMM_DIM7,RCI_SIG_ACCT_EVAL_SUMM_DIM8,RCI_SIG_ACCT_EVAL_SUMM_DIM9
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
END get_sig_acct_eval_summ_result;

/*
--Procedure to be called from concurrent program--
*/
PROCEDURE sig_acct_incremental_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER)
IS
BEGIN
    EXECUTE IMMEDIATE ('TRUNCATE TABLE amw.rci_sig_acct_eval_f');
    sig_acct_initial_load(
   errbuf    => errbuf
  ,retcode   => retcode);
    EXECUTE IMMEDIATE ('COMMIT');
END sig_acct_incremental_load;
/*
--------------------------------------------------------------------------
*/
PROCEDURE sig_acct_initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER)
IS
/*todo 01/06/2005 remove this
CURSOR c_get_acct_evaluations
IS
SELECT pk1_value, pk2_value, audit_result_code
FROM amw_opinions_v
WHERE opinion_type_code = 'EVALUATION'
AND   object_name = 'AMW_KEY_ACCOUNT';

CURSOR c_get_process_certifications
IS
SELECT pk1_value, pk2_value, pk3_value, audit_result_code
FROM amw_opinions_v
WHERE opinion_type_code = 'CERTIFICATION'
AND   object_name = 'AMW_ORG_PROCESS';

CURSOR c_stmt_grp is
SELECT DISTINCT STATEMENT_GROUP_ID, FINANCIAL_STATEMENT_ID, FINANCIAL_ITEM_ID
FROM rci_sig_acct_eval_f;

v_certification_result amw_opinion_values_b.opinion_value_code%type;
v_cert_with_issues rci_sig_acct_eval_f.proc_cert_result_cwi%type := 0;
v_certified rci_sig_acct_eval_f.proc_cert_result_c%type := 0;
v_not_certified rci_sig_acct_eval_f.proc_cert_result_nc%type := 0;

v_evaluation_result amw_opinion_values_b.opinion_value_code%type;
v_ineffective rci_sig_acct_eval_f.acct_eval_ie%type := 0;
v_effective rci_sig_acct_eval_f.acct_eval_e%type := 0;
v_not_evaluated rci_sig_acct_eval_f.acct_eval_ne%type := 0;

p_statement_group_id rci_sig_acct_eval_f.statement_group_id%type := 0;
p_financial_statement_id rci_sig_acct_eval_f.financial_statement_id%type := 0;
p_financial_item_id rci_sig_acct_eval_f.financial_item_id%type := 0;

v_orgs_with_ineff_ctrls rci_sig_acct_eval_f.orgs_with_ineff_ctrls%type := 0;
v_unmiti_risks rci_sig_acct_eval_f.unmiti_risks%type := 0;
v_ineff_ctrls rci_sig_acct_eval_f.ineff_ctrls%type := 0;
*/
   l_user_id                NUMBER ;
   l_login_id               NUMBER ;
   l_program_id             NUMBER ;
   l_program_login_id       NUMBER ;
   l_program_application_id NUMBER ;
   l_request_id             NUMBER ;
   l_run_date      DATE;
--upd_flag BOOLEAN;
BEGIN
    EXECUTE IMMEDIATE ('TRUNCATE TABLE amw.rci_sig_acct_eval_f');

    INSERT INTO RCI_SIG_ACCT_EVAL_F(
        STATEMENT_GROUP_ID
        ,FINANCIAL_STATEMENT_ID
        ,FINANCIAL_ITEM_ID
        ,ACCOUNT_GROUP_ID
        ,CERT_STATUS
        ,CERT_TYPE
        ,CERTIFICATION_ID
        ,SIG_ACCT_ID
        ,ORGANIZATION_ID
        ,PROCESS_ID
        ,ACCT_EVAL_RESULT_CODE
        ,ACCT_EVAL_E
        ,ACCT_EVAL_IE
        ,ACCT_EVAL_NE
        ,ORGS_WITH_INEFF_CTRLS
        ,PROC_CERT_RESULT_CWI
        ,PROC_CERT_RESULT_C
        ,PROC_CERT_RESULT_NC
        ,UNMITI_RISKS
        ,INEFF_CTRLS
        ,PERIOD_YEAR
        ,PERIOD_NUM
        ,QUARTER_NUM
        ,ENT_PERIOD_ID
        ,ENT_QTR_ID
        ,ENT_YEAR_ID
        ,REPORT_DATE_JULIAN
        ,CREATED_BY
        ,LAST_UPDATE_LOGIN
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE)
    SELECT
       DISTINCT
        a.statement_group_id
        ,a.financial_statement_id
        ,a.financial_item_id
        ,a.account_group_id
        ,acb.certification_status CERT_STATUS
        ,acb.certification_type CERT_TYPE
        ,acb.certification_id
        ,a.natural_account_id sig_acct_id
        ,a.organization_id
        ,a.process_id
        ,nvl(o.audit_result_code,'NOT_EVALUATED') ACCT_EVAL_RESULT_CODE
        ,decode(o.audit_result_code, 'EFFECTIVE', 1,0) ACCT_EVAL_E
	,case o.audit_result_code when 'INEFFECTIVE' then 1 when 'SOMEWHAT_EFFECTIVE' then 1
		when 'NEARLY_INEFFECTIVE' then 1 else 0 end ACCT_EVAL_IE
        ,decode(o.audit_result_code, null, 1,0) ACCT_EVAL_NE
        ,nvl(afces.org_with_ineffective_controls,0) ORGS_WITH_INEFF_CTRLS
        ,nvl(afces.proc_certified_with_issues,0) PROC_CERT_RESULT_CWI
        ,nvl(afces.procs_for_cert_done,0) PROC_CERT_RESULT_C
        ,nvl(afces.proc_pending_certification,0) PROC_CERT_RESULT_NC
        ,nvl(afces.unmitigated_risks,0) UNMITI_RISKS
        ,nvl(afces.ineffective_controls,0) INEFF_CTRLS
        ,agpv.period_year
        ,agpv.period_num
        ,agpv.quarter_num
        ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)) ENT_PERIOD_ID
        ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)) ENT_QTR_ID
        ,agpv.period_year ENT_YEAR_ID
        ,to_number(to_char(agpv.end_date,'J')) REPORT_DATE_JULIAN
        ,G_USER_ID,G_LOGIN_ID,sysdate,G_USER_ID,sysdate
    FROM
        amw_fin_cert_scope a
        ,amw_fin_cert_eval_sum afces
        ,amw_certification_b acb
        ,amw_opinions_v o
        ,amw_gl_periods_v agpv
    WHERE
        a.fin_certification_id = acb.certification_id
        and acb.object_type = 'FIN_STMT'
        and afces.object_type = 'ACCOUNT'
        and afces.natural_account_id = a.natural_account_id
        and afces.fin_certification_id = a.fin_certification_id
        and afces.financial_statement_id(+) = a.financial_statement_id
        and afces.financial_item_id(+) =  a.financial_item_id
        and o.pk1_value(+) = a.natural_account_id
        and o.pk2_value (+)= a.fin_certification_id
        and o.opinion_type_code(+) = 'EVALUATION'
        and o.object_name(+) = 'AMW_KEY_ACCOUNT'
        and acb.certification_period_name = agpv.period_name
        and acb.certification_period_set_name = agpv.period_set_name
--      and a.natural_account_id is not null
;
/*todo 01/06/2005 remove this
    FOR r_get_acct_evaluations IN c_get_acct_evaluations LOOP
        upd_flag := false;
        v_not_evaluated := 0; v_effective := 0; v_ineffective := 0;
        v_evaluation_result := r_get_acct_evaluations.audit_result_code;

        IF v_evaluation_result='EFFECTIVE' THEN
            upd_flag := true;
            v_effective := 1;
        ELSE --INEFFECTIVE, NEARLY_INEFFECTIVE or SOMEWHAT_EFFECTIVE
            upd_flag := true;
            v_ineffective := 1;
        END IF;
        IF upd_flag THEN
            UPDATE rci_sig_acct_eval_f
        	SET
                ACCT_EVAL_RESULT_CODE = v_evaluation_result,
                ACCT_EVAL_IE	  = v_ineffective,
                ACCT_EVAL_E	  = v_effective,
                ACCT_EVAL_NE	  =	v_not_evaluated,
        	    lAST_UPDATE_DATE 	     = SYSDATE,
        	    lAST_UPDATED_BY          = G_USER_ID,
        	    lAST_UPDATE_LOGIN        = G_LOGIN_ID
        	WHERE
            	CERTIFICATION_ID         = r_get_acct_evaluations.pk2_value
                AND SIG_ACCT_ID          = r_get_acct_evaluations.pk1_value;
         END IF; --end upd_flag IF
	END LOOP;

    FOR r_get_process_certifications IN c_get_process_certifications LOOP
        upd_flag := false;
        v_not_certified := 0; v_certified := 0; v_cert_with_issues := 0;
        v_certification_result := r_get_process_certifications.audit_result_code;

        IF v_certification_result='INEFFECTIVE' THEN
            upd_flag := true;
            v_cert_with_issues := 1;
        ELSIF v_certification_result='EFFECTIVE' THEN
            upd_flag := true;
            v_certified := 1;
        END IF;

        IF upd_flag THEN
            UPDATE rci_sig_acct_eval_f
        	SET
                PROC_CERT_RESULT_CWI	  = v_cert_with_issues,
                PROC_CERT_RESULT_C	  = v_certified,
                PROC_CERT_RESULT_NC	  =	v_not_certified,
        	    lAST_UPDATE_DATE 	     = SYSDATE,
        	    lAST_UPDATED_BY          = G_USER_ID,
        	    lAST_UPDATE_LOGIN        = G_LOGIN_ID
        	WHERE
                PROCESS_ID             = r_get_process_certifications.pk1_value
            	AND CERTIFICATION_ID         = r_get_process_certifications.pk2_value
            	AND ORGANIZATION_ID          = r_get_process_certifications.pk3_value;
        END IF; --end upd_flag IF
	END LOOP;

    FOR r_stmt_grp IN c_stmt_grp LOOP
        p_statement_group_id := r_stmt_grp.STATEMENT_GROUP_ID;
        p_financial_statement_id := r_stmt_grp.FINANCIAL_STATEMENT_ID;
        p_financial_item_id := r_stmt_grp.FINANCIAL_ITEM_ID;

        CountOrgsIneffCtrl_finitem(p_statement_group_id ,
        p_financial_statement_id, p_financial_item_id , v_orgs_with_ineff_ctrls );
        CountUnmittigatedRisk_finitem(p_statement_group_id ,
        p_financial_statement_id, p_financial_item_id , v_unmiti_risks );
        CountIneffectiveCtrls_finitem(p_statement_group_id ,
        p_financial_statement_id, p_financial_item_id , v_ineff_ctrls );

        UPDATE rci_sig_acct_eval_f
    	SET
            ORGS_WITH_INEFF_CTRLS = v_orgs_with_ineff_ctrls,
            UNMITI_RISKS = v_unmiti_risks,
            INEFF_CTRLS = v_ineff_ctrls,
    	    lAST_UPDATE_DATE 	     = SYSDATE,
    	    lAST_UPDATED_BY          = G_USER_ID,
    	    lAST_UPDATE_LOGIN        = G_LOGIN_ID
    	WHERE STATEMENT_GROUP_ID = p_statement_group_id
    	AND FINANCIAL_STATEMENT_ID = p_financial_statement_id
        AND FINANCIAL_ITEM_ID = p_financial_item_id;

    END LOOP;
*/
    l_user_id                := NVL(fnd_global.USER_ID, -1);
    l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
    l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
    l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
    l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
    l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);
    l_run_date := sysdate - 5/(24*60);

   DELETE FROM rci_dr_inc WHERE fact_name='RCI_SIG_ACCT_EVAL_F';

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
	 'RCI_SIG_ACCT_EVAL_F'
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
END sig_acct_initial_load;
END RCI_SIG_ACCT_EVAL_SUMM_PKG;

/
