--------------------------------------------------------
--  DDL for Package Body RCI_ORG_CERT_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCI_ORG_CERT_SUMM_PKG" AS
--$Header: rciocsb.pls 120.39.12000000.6 2007/04/09 19:57:49 ddesjard ship $

PROCEDURE get_org_kpi(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
   l_sqlstmt      VARCHAR2(15000);
   v_dummy number := 99;

   l_from_clause  varchar2(15000);
   l_getcnt       varchar2(15000);
   l_grp_by       varchar2(15000);
   l_where_clause varchar2(15000);
   l_qry1         varchar2(15000);
   l_qry2         varchar2(15000);
   l_qry3         varchar2(15000);

   l_total        number;

   v_period   varchar2(100);
   l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN

   /** 12.12.2005 npanandi: changed the construction of this query
                            to remove the NA text in the Org Cert KPI portlet
							bug 4880422 fix ***/
   l_getcnt := 'select count(1) from (
                       select distinct rocsf.fin_certification_id, organization_id
                         from rci_org_cert_summ_f rocsf
						     ,fii_time_day ftd
						where 1=1 and rocsf.report_date_julian = ftd.report_date_julian ';

   ---looping through the parameters
   FOR i in 1..p_page_parameter_tbl.COUNT LOOP

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rocsf.certification_type = '||p_page_parameter_tbl(i).parameter_id;

		 l_getcnt := l_getcnt || ' and rocsf.certification_type = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rocsf.fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;

		 l_getcnt := l_getcnt || ' and rocsf.fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  /** 10.21.2005 npanandi begin ***/
	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.27.2006 npanandi: use dynamic binding here
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_getcnt := l_getcnt || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = :TIME1 ';
		 l_getcnt := l_getcnt || ' and ftd.ent_period_id = :TIME2 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.27.2006 npanandi: use dynamic binding here
	     l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_getcnt := l_getcnt || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = :TIME1 ';
		 l_getcnt := l_getcnt || ' and ftd.ent_qtr_id = :TIME2 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.27.2006 npanandi: use dynamic binding here
	     l_from_clause := l_from_clause || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_getcnt := l_getcnt || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_year_id = :TIME1 ';
		 l_getcnt := l_getcnt || ' and ftd.ent_year_id = :TIME2 ';
      END IF;
	  /** 10.21.2005 npanandi end ***/

   end loop;

   ----now the l_getcnt query is complete, so this can be executed to get the
   ----total which is stored in the variable l_total
   l_getcnt := l_getcnt || ' )';
   EXECUTE IMMEDIATE l_getcnt INTO l_total using v_period;

   if( l_total = 0) then
      ---l_sqlstmt := l_sqlstmt || ', 0 RCI_ORG_CERT_MEASURE3 ';
	  l_total := 1;
   /**else
      l_sqlstmt := l_sqlstmt || ', round(count(rocsf.organization_id)/'||l_total||'*100,2) RCI_ORG_CERT_MEASURE3 ';
	  **/
   end if;

   ---ROUND((nvl(MES1,0)*100/'||v_total ||'),2)
   l_sqlstmt := 'select round((nvl(a1.not_certified,0)*100/'||l_total||'),2) as RCI_ORG_CERT_MEASURE1
                       ,round((nvl(a2.certified_w_issues,0)*100/'||l_total||'),2) as RCI_ORG_CERT_MEASURE2
                       ,round((nvl(a3.certified,0)*100/'||l_total||'),2) as RCI_ORG_CERT_MEASURE3
				   from ';

   l_qry1 := '(select count(1) as certified
                 from (select distinct organization_id,fin_certification_id
                         from rci_org_cert_summ_f rocsf, fii_time_day ftd
                        where rocsf.report_date_julian = ftd.report_date_julian
						  and rocsf.org_certification_status=''EFFECTIVE'''||l_from_clause||')) a3, ';

   l_qry2 := '(select count(1) as certified_w_issues
                 from (select distinct organization_id,fin_certification_id
                         from rci_org_cert_summ_f rocsf, fii_time_day ftd
                        where rocsf.report_date_julian = ftd.report_date_julian
						  and org_certification_status <> ''EFFECTIVE'''||l_from_clause||')) a2, ';

   l_qry3 := '(select count(1) as not_certified
                 from (select distinct organization_id,fin_certification_id
                         from rci_org_cert_summ_f rocsf, fii_time_day ftd
                        where rocsf.report_date_julian = ftd.report_date_julian
						  and org_certification_status is null '||l_from_clause||')) a1';

   p_exp_source_sql := l_sqlstmt || l_qry1 || l_qry2 || l_qry3;
   /***12.12.2005 npanandi: bug 4880422 fix ends ***/

   /**04.27.2006 npanandi: adding code for dynamic binding of time period dimensions**/
   p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
   l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME1';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;
   /**04.27.2006 npanandi: finished code for dynamic binding of time period dimensions**/
END get_org_kpi;

---------------------------------------------------------------------------------
-- the get_org_certification_result procedure is called by Organization Certification Summary report.
PROCEDURE get_org_certification_result(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
   l_multi_factor NUMBER;
   l_sqlstmt      VARCHAR2(15000);
   l_act_sqlstmt  varchar2(15000);
   l_sqlstmt1     VARCHAR2(15000);
   l_subquery_m   varchar2(15000);
   l_subquery1    varchar2(15000);
   l_subquery2    varchar2(15000);
   l_subquery3    varchar2(15000);
   l_subquery4    varchar2(15000);
   l_grp_by       varchar2(100);
   l_where_clause varchar2(15000);
   l_drill_url    varchar2(15000);
   l_unmtg_risks_url varchar2(15000);
   l_ineff_ctrls_url varchar2(15000);
   l_proc_ineff_ctrls_url varchar2(15000);
   l_issue_detail_url varchar2(15000);
   l_proc_certified_url varchar2(15000);

   l_inner_sql varchar2(15000);
   l_outer_sql varchar2(15000);
   l_inner_from varchar2(15000);
   l_org_status_where varchar2(2000);

   /*04.27.2006 npanandi: added 3 variables below for
     purposes of giving unique names for dynamic binding parameters
	*/
   l_org_status_where1 varchar2(2000);
   l_org_status_where2 varchar2(2000);
   l_org_status_where3 varchar2(2000);
   l_index number;

   l_org_statuses varchar2(15000);

   l_issues_sql varchar2(15000);
   l_ctrls_sql varchar2(15000);
   l_risks_sql varchar2(15000);
   l_risks_from varchar2(15000);
   l_ctrls_from varchar2(15000);
   l_def_proc_sql varchar2(15000);
   l_def_proc_where varchar2(2000);

   v_yyyymm varchar2(6);

   v_period   varchar2(100);
   l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN
   l_issues_sql := ' (select roif.organization_id,count(distinct roif.change_id) as open_issues
                              from rci_open_issues_f roif,eng_engineering_changes eec
                             where eec.change_id=roif.change_id and roif.certification_id is not null and roif.organization_id is not null ';

   l_outer_sql := 'select name VIEWBY
                         ,0 RCI_GRAND_TOTAL
                         ,rocsf.organization_id RCI_ORG_CERT_MEASURE1
                         ,nvl(ro1.org_certified_with_issues,0) RCI_ORG_CERT_MEASURE2
                         ,nvl(ro2.org_certified,0) RCI_ORG_CERT_MEASURE3
                         ,nvl(ro3.org_not_certified,0) RCI_ORG_CERT_MEASURE4
	                     ,/*sum(proc_w_ineff_ctrls)*/ nvl(def.processes,0) RCI_ORG_CERT_MEASURE5
                         ,sum(proc_certified_with_issues) RCI_ORG_CERT_MEASURE6
                         ,sum(proc_certified) RCI_ORG_CERT_MEASURE7
                         ,sum(proc_not_certified) RCI_ORG_CERT_MEASURE8
                         ,/*sum(unmitigated_risks)*/ nvl(risk.risk_id,0) RCI_ORG_CERT_MEASURE9
                         ,/*sum(ineffective_controls)*/ nvl(ctrls.controls,0) RCI_ORG_CERT_MEASURE10
                         ,/**sum(**/nvl(op.open_issues,0)/**)**/ RCI_ORG_CERT_MEASURE11
                         ,org_id RCI_ORG_CERT_URL1 from ( ';

   l_inner_sql  := 'select distinct rocsf.fin_certification_id
                          , aauv.name
					      ,rocsf.organization_id
					      ,rocsf.org_certified_with_issues
					      ,rocsf.org_certified
					      ,rocsf.org_not_certified
						  ,rocsf.process_id
					      ,rocsf.proc_w_ineff_ctrls
					      ,rocsf.proc_certified_with_issues
					      ,rocsf.proc_certified
					      ,rocsf.proc_not_certified
					      ,rocsf.unmitigated_risks
					      ,rocsf.organization_id org_id
						  ,rocsf.report_date_julian
					  from rci_org_cert_summ_f rocsf
					      ,amw_audit_units_v aauv
					      ,fii_time_day ftd
					 where rocsf.organization_id = aauv.organization_id
					   and rocsf.report_date_julian = ftd.report_date_julian ';


	FOR i in 1..p_page_parameter_tbl.COUNT LOOP
	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN

		 l_inner_from := l_inner_from || ' and rocsf.certification_status = '||p_page_parameter_tbl(i).parameter_id;
		 l_issues_sql := l_issues_sql || ' and fin_cert_status = '||p_page_parameter_tbl(i).parameter_id;


      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN

		 l_inner_from := l_inner_from || ' and rocsf.certification_type = '||p_page_parameter_tbl(i).parameter_id;
		 l_issues_sql := l_issues_sql || ' and fin_cert_type = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN

		 l_inner_from := l_inner_from || ' and rocsf.fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_risks_from := l_risks_from || ' and fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_ctrls_from := l_ctrls_from || ' and fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_issues_sql := l_issues_sql || ' and fin_cert_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_def_proc_where := l_def_proc_where ||' and fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN

		 l_inner_from := l_inner_from || ' and rocsf.natural_account_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_risks_from := l_risks_from || ' and natural_account_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_ctrls_from := l_ctrls_from || ' and natural_account_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_def_proc_where := l_def_proc_where ||' and natural_account_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN

		 l_inner_from := l_inner_from || ' and rocsf.organization_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_issues_sql := l_issues_sql || ' and roif.organization_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_def_proc_where := l_def_proc_where ||' and organization_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN

		 l_inner_from := l_inner_from || ' and rocsf.process_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_risks_from := l_risks_from ||' and process_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_ctrls_from := l_ctrls_from || ' and process_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_issues_sql := l_issues_sql || ' and process_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_def_proc_where := l_def_proc_where ||' and process_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_ORG_CERT_RESULT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		    if(p_page_parameter_tbl(i).parameter_id = '''EFFECTIVE''')then

			   l_inner_from := l_inner_from || ' and rocsf.org_certified > 0 ';
			elsif(p_page_parameter_tbl(i).parameter_id = '''INEFFECTIVE''') then

			   l_inner_from := l_inner_from || ' and rocsf.org_certified_with_issues > 0 ';
			else

               l_inner_from := l_inner_from || ' and rocsf.org_not_certified > 0 ';
			end if;
      END IF;

	  /** 10.20.2005 npanandi begin ***/
	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN

		 v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'M');

		 /*04.27.2006 npanandi: use dynamic binding for time dimensions
		 l_inner_from := l_inner_from || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_risks_from := l_risks_from || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_ctrls_from := l_ctrls_from || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_def_proc_where := l_def_proc_where ||' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_inner_from := l_inner_from || ' and ftd.ent_period_id = :TIME1 ';
		 l_risks_from := l_risks_from || ' and ftd.ent_period_id = :TIME2 ';
		 l_ctrls_from := l_ctrls_from || ' and ftd.ent_period_id = :TIME3 ';
		 l_def_proc_where := l_def_proc_where ||' and ftd.ent_period_id = :TIME4 ';

		 l_issues_sql := l_issues_sql || ' and ((eec.status_code not in (0,11) and eec.initiation_date < last_day(to_date('''||v_yyyymm||''',''YYYYMM''))
                     ) or (eec.status_code=11 and eec.last_update_date > last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) )) ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN

		 v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Q');

		 /*04.27.2006 npanandi: use dynamic binding for time dimensions
		 l_inner_from := l_inner_from || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_risks_from := l_risks_from || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_ctrls_from := l_ctrls_from || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_def_proc_where := l_def_proc_where ||' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_inner_from := l_inner_from || ' and ftd.ent_qtr_id = :TIME1 ';
		 l_risks_from := l_risks_from || ' and ftd.ent_qtr_id = :TIME2 ';
		 l_ctrls_from := l_ctrls_from || ' and ftd.ent_qtr_id = :TIME3 ';
		 l_def_proc_where := l_def_proc_where ||' and ftd.ent_qtr_id = :TIME4 ';

		 l_issues_sql := l_issues_sql || ' and ((eec.status_code not in (0,11) and eec.initiation_date < last_day(to_date('''||v_yyyymm||''',''YYYYMM''))
                     ) or (eec.status_code=11 and eec.last_update_date > last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) )) ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN

		 v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Y');

		 /*04.27.2006 npanandi: use dynamic binding for time dimensions
		 l_inner_from := l_inner_from || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_risks_from := l_risks_from || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_ctrls_from := l_ctrls_from || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_def_proc_where := l_def_proc_where ||' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_inner_from := l_inner_from || ' and ftd.ent_year_id = :TIME1 ';
		 l_risks_from := l_risks_from || ' and ftd.ent_year_id = :TIME2 ';
		 l_ctrls_from := l_ctrls_from || ' and ftd.ent_year_id = :TIME3 ';
		 l_def_proc_where := l_def_proc_where ||' and ftd.ent_year_id = :TIME4 ';

		 l_issues_sql := l_issues_sql || ' and ((eec.status_code not in (0,11) and eec.initiation_date < last_day(to_date('''||v_yyyymm||''',''YYYYMM''))
                     ) or (eec.status_code=11 and eec.last_update_date > last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) )) ';
      END IF;
	  /** 10.20.2005 npanandi end ***/



   end loop;

   /***04.28.2006 npanandi: what is being done below --- processing the string
       to make each bind variable unique-named
	***/
   l_org_status_where := l_inner_from;
   l_index := instr(l_org_status_where,':TIME');
   l_org_status_where1 := substr(l_org_status_where,0,l_index+4)||'5'||substr(l_org_status_where,l_index+6);
   l_org_status_where2 := substr(l_org_status_where,0,l_index+4)||'6'||substr(l_org_status_where,l_index+6);
   l_org_status_where3 := substr(l_org_status_where,0,l_index+4)||'7'||substr(l_org_status_where,l_index+6);
   /**04.28.2006 npanandi: ends processing for name-uniqueness**/

   l_inner_from := l_inner_from || ') rocsf, ';

   l_org_statuses := ' (select organization_id,count(fin_certification_id) as org_certified_with_issues from (
                               select distinct fin_certification_id,rocsf.report_date_julian,rocsf.organization_id
                                 from rci_org_cert_summ_f rocsf,fii_time_day ftd
								where rocsf.report_date_julian=ftd.report_date_julian and org_certification_status=''INEFFECTIVE'' '||l_org_status_where1||' ) group by organization_id) ro1,
                       (select organization_id,count(fin_certification_id) as org_certified from (
                               select distinct fin_certification_id,rocsf.report_date_julian,rocsf.organization_id
                                 from rci_org_cert_summ_f rocsf,fii_time_day ftd
								where rocsf.report_date_julian=ftd.report_date_julian and org_certification_status=''EFFECTIVE'' '||l_org_status_where2||' ) group by organization_id) ro2,
					   (select organization_id,count(fin_certification_id) as org_not_certified from (
                               select distinct fin_certification_id,rocsf.report_date_julian,rocsf.organization_id
                                 from rci_org_cert_summ_f rocsf,fii_time_day ftd
								where rocsf.report_date_julian=ftd.report_date_julian and org_certification_status is null '||l_org_status_where3||' ) group by organization_id) ro3,';

   l_issues_sql := l_issues_sql ||' group by roif.organization_id)   op, ';
   l_def_proc_sql := '(select organization_id,count(process_id) as processes from (
                              select distinct process_id,organization_id,fin_certification_id,certification_result_code,evaluation_result_code
                                from rci_org_proc_dfcy_f ropdf, fii_time_day ftd
                               where ropdf.report_date_julian=ftd.report_date_julian
							     '||l_def_proc_where||' ) group by organization_id) def, ';
   l_ctrls_sql := '(select organization_id,count(distinct control_id) as controls
				      from RCI_ORG_CERT_CTRLS_F roccf,fii_time_day ftd where 1=1 and roccf.report_date_julian = ftd.report_date_julian '||l_ctrls_from||'
					 group by organization_id) ctrls, ';
   l_risks_sql := '(select organization_id,count(risk_id) as risk_id from (select distinct organization_id,process_id,risk_id
				      from RCI_ORG_CERT_RISKS_F roccf,fii_time_day ftd
					 where roccf.report_date_julian = ftd.report_date_julian and audit_result_code <> ''EFFECTIVE'' and audit_result_code is not null
					 '||l_risks_from||' )
					 group by organization_id) risk
                   where rocsf.organization_id = op.organization_id(+)
				     and rocsf.organization_id = ro1.organization_id(+)
					 and rocsf.organization_id = ro2.organization_id(+)
					 and rocsf.organization_id = ro3.organization_id(+)
				     and rocsf.organization_id = ctrls.organization_id(+)
					 and rocsf.organization_id = risk.organization_id(+)
					 and rocsf.organization_id = def.organization_id(+)
                   group by name,rocsf.organization_id,ro1.org_certified_with_issues,ro2.org_certified,ro3.org_not_certified,def.processes,ctrls.controls,risk.risk_id,op.open_issues  ';

   /***l_inner_from := l_inner_from||' ) group by organization_id,organization_name,org_id '; ***/

   /** 01.01.2006 npanandi: changed the org cert summary SQL according to
       new financial statement changes
   l_sqlstmt := l_sqlstmt1 || l_subquery_m || l_subquery1 || l_subquery2 || l_subquery3 || l_subquery4 ||l_where_clause;
   ***/
   l_sqlstmt := l_outer_sql||l_inner_sql||l_inner_from||l_org_statuses||l_issues_sql||l_def_proc_sql||l_ctrls_sql||l_risks_sql
                /**01.26.2006 npanandi: added below line for bug 5000427**/
				||' order by RCI_ORG_CERT_MEASURE2 desc ';


   /** 09.18.2006 npanandi: added SQL below to handle order_by_clause -- bug 5510667 **/
   l_act_sqlstmt := 'select VIEWBY,RCI_GRAND_TOTAL,RCI_ORG_CERT_MEASURE1
                           ,RCI_ORG_CERT_MEASURE2,RCI_ORG_CERT_MEASURE3
						   ,RCI_ORG_CERT_MEASURE4,RCI_ORG_CERT_MEASURE5
						   ,RCI_ORG_CERT_MEASURE6,RCI_ORG_CERT_MEASURE7
						   ,RCI_ORG_CERT_MEASURE8,RCI_ORG_CERT_MEASURE9
						   ,RCI_ORG_CERT_MEASURE10,RCI_ORG_CERT_MEASURE11
						   ,RCI_ORG_CERT_URL1
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_sqlstmt ||'
							 ) t ) a
					   order by a.col_rank ';

   p_exp_source_sql := l_act_sqlstmt;

   /**04.27.2006 npanandi: adding code for dynamic binding of time period dimensions**/
   p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
   l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME1';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME2';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME3';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME4';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME5';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME6';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME7';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;
   /**04.27.2006 npanandi: finished code for dynamic binding of time period dimensions**/
END get_org_certification_result;

-- the get_org_cert_prcnt procedure is called by
-- Organization Certification Result report.
PROCEDURE get_org_cert_prcnt(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
   l_multi_factor NUMBER;
   l_sqlstmt      VARCHAR2(15000);
   l_act_sqlstmt  varchar2(15000);
   l_from_clause  varchar2(15000);
   l_getcnt       varchar2(15000);
   l_grp_by       varchar2(15000);
   l_where_clause varchar2(15000);

   l_total        number;

   v_period   varchar2(100);
   l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN

   l_getcnt := 'select count(1) from (
                       select distinct nvl(rocsf.fin_certification_id,0) certification_id,
                              nvl(rocsf.organization_id,0) organization_id,
                              nvl(rocsf.org_certification_status,''NOT_CERTIFIED'') org_certification_status
                         from rci_org_cert_summ_f rocsf
						     ,fii_time_day ftd
						where 1=1 and rocsf.report_date_julian = ftd.report_date_julian ';

   l_sqlstmt := 'select rbcrv.value VIEWBY
                       ,count(rocsf.organization_id) RCI_ORG_CERT_MEASURE1 ';

   l_from_clause := ' from rci_bp_cert_result_v rbcrv
                       ,(select distinct nvl(rocsf.fin_certification_id,0) certification_id,
                                nvl(rocsf.organization_id,0) organization_id,
                                /**nvl(rocsf.org_certification_status,''NOT_CERTIFIED'') org_certification_status**/
								decode(rocsf.org_certification_status,null,''NOT_CERTIFIED'',''EFFECTIVE'',''EFFECTIVE'',''INEFFECTIVE'') org_certification_status
                           from rci_org_cert_summ_f rocsf
						       ,fii_time_day ftd
						  where 1=1 and rocsf.report_date_julian = ftd.report_date_julian ';


   FOR i in 1..p_page_parameter_tbl.COUNT LOOP

      IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_QTR' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
	     l_from_clause := l_from_clause || ' and certification_period_name = '||p_page_parameter_tbl(i).parameter_id;

		 l_getcnt := l_getcnt || ' and certification_period_name = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and certification_status = '||p_page_parameter_tbl(i).parameter_id;

		 l_getcnt := l_getcnt || ' and certification_status = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and certification_type = '||p_page_parameter_tbl(i).parameter_id;

		 l_getcnt := l_getcnt || ' and certification_type = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;

		 l_getcnt := l_getcnt || ' and fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and natural_account_id = '||p_page_parameter_tbl(i).parameter_id;

		 l_getcnt := l_getcnt || ' and natural_account_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and organization_id = '||p_page_parameter_tbl(i).parameter_id;

		 l_getcnt := l_getcnt || ' and organization_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and process_id = '||p_page_parameter_tbl(i).parameter_id;

		 l_getcnt := l_getcnt || ' and process_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  /** 10.20.2005 npanandi begin ***/
	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.27.2006 npanandi: use dynamic binding for time dimensions
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_getcnt := l_getcnt || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = :TIME1 ';
		 l_getcnt := l_getcnt || ' and ftd.ent_period_id = :TIME2 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.27.2006 npanandi: use dynamic binding for time dimensions
	     l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_getcnt := l_getcnt || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = :TIME1 ';
		 l_getcnt := l_getcnt || ' and ftd.ent_qtr_id = :TIME2 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.27.2006 npanandi: use dynamic binding for time dimensions
	     l_from_clause := l_from_clause || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_getcnt := l_getcnt || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_year_id = :TIME1 ';
		 l_getcnt := l_getcnt || ' and ftd.ent_year_id = :TIME2 ';
      END IF;
	  /** 10.20.2005 npanandi end ***/

   end loop;

   l_getcnt := l_getcnt || ' )';
   EXECUTE IMMEDIATE l_getcnt INTO l_total using v_period;

   if( l_total = 0) then
      l_sqlstmt := l_sqlstmt || ', 0 RCI_ORG_CERT_MEASURE2,0 RCI_ORG_CERT_MEASURE3,rbcrv.id RCI_ORG_CERT_URL1 ';
   else
      l_sqlstmt := l_sqlstmt || ', round(count(rocsf.organization_id)/'||l_total||'*100,2) RCI_ORG_CERT_MEASURE2
	              ,0 RCI_ORG_CERT_MEASURE3,rbcrv.id RCI_ORG_CERT_URL1 ';
   end if;

   l_grp_by := '  ) rocsf
              where rbcrv.id = rocsf.org_certification_status (+)
              group by rbcrv.value,rbcrv.id   ';

   /** 09.18.2006 npanandi: added SQL below to handle order_by_clause -- bug 5510667 **/
   l_act_sqlstmt := 'select VIEWBY
	,RCI_ORG_CERT_MEASURE1,RCI_ORG_CERT_MEASURE2,RCI_ORG_CERT_MEASURE3,RCI_ORG_CERT_URL1
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_sqlstmt || l_from_clause || l_grp_by||'
							 ) t ) a
					   order by a.col_rank ';
   /**p_exp_source_sql := l_sqlstmt || l_from_clause || l_grp_by;**/
   p_exp_source_sql := l_act_sqlstmt;

   /**04.27.2006 npanandi: adding code for dynamic binding of time period dimensions**/
   p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
   l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME1';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;
   /**04.27.2006 npanandi: finished code for dynamic binding of time period dimensions**/
END get_org_cert_prcnt;

-- the get_unmitigated_risks procedure is called by
-- Organization Certification Unmitigated Risks List report.
PROCEDURE get_unmitigated_risks(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
   l_sqlstmt      VARCHAR2(15000);
   ---12.22.2005 npanandi: added l_act_sqlstmt below
   l_act_sqlstmt  VARCHAR2(15000);
   l_from_clause  varchar2(15000);
   l_getcnt       varchar2(15000);
   l_grp_by       varchar2(15000);
   l_where_clause varchar2(15000);

   l_total        number;

   l_drill_url    varchar2(15000);

   v_period   varchar2(100);
   l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN

   l_sqlstmt := 'select distinct art.name RCI_ORG_CERT_MEASURE1
		        ,aapv.project_name RCI_ORG_CERT_MEASURE2
		        ,aauv.name RCI_ORG_CERT_MEASURE3
		        ,apv.display_name RCI_ORG_CERT_MEASURE4
		        ,/*nvl(arb.material,''N'')*/ flv.meaning RCI_ORG_CERT_MEASURE5
		        ,al1.meaning RCI_ORG_CERT_MEASURE6
		        ,al2.meaning RCI_ORG_CERT_MEASURE7
		        ,rfaev.value RCI_ORG_CERT_MEASURE8
		        ,papf.full_name RCI_ORG_CERT_MEASURE9
		        ,rocrf.last_evaluated_on RCI_ORG_CERT_MEASURE10
				,arb.risk_rev_id RCI_ORG_CERT_URL1
				,arb.risk_id RCI_ORG_CERT_URL2
				,rocrf.process_id RCI_ORG_CERT_URL3
				,rocrf.organization_id RCI_ORG_CERT_URL4
		    from rci_org_cert_risks_f rocrf
		        ,amw_risks_b arb
		        ,amw_risks_tl art
		        ,amw_audit_projects_v aapv
		        ,amw_audit_units_v aauv
		        ,amw_process_vl apv
		        ,amw_lookups al1
		        ,amw_lookups al2
		        ,RCI_FS_ACCT_EVAL_V rfaev
		        ,PER_ALL_PEOPLE_F papf
			    ,FND_USER fu
				/** 10.20.2005 npanandi begin ***/
			    ,fii_time_day ftd
				/** 10.20.2005 npanandi end ***/
				/**01.31.2006 npanandi: changing reference to fnd_lookups below because
				   of lang issues **/
				,/*fnd_lookup_values*/fnd_lookups flv
		   where arb.risk_rev_id = art.risk_rev_id
		     and upper(arb.curr_approved_flag) = ''Y''
		     and art.language = userenv(''LANG'')
		     and arb.risk_id = rocrf.risk_id
			 and rocrf.organization_id = aauv.organization_id
		     and aapv.audit_project_id = rocrf.project_id
		     and aauv.organization_id = rocrf.organization_id
		     and apv.process_id = rocrf.process_id
		     and apv.approval_date is not null
		     and apv.approval_end_date is null
		     and rocrf.risk_impact = al1.lookup_code(+)
		     and al1.lookup_type(+) = ''AMW_IMPACT''
		     and al1.enabled_flag(+) = ''Y''
		     and rocrf.likelihood = al2.lookup_code(+)
		     and al2.lookup_type(+) = ''AMW_LIKELIHOOD''
		     and al2.enabled_flag(+) = ''Y''
		     and rocrf.audit_result_code = rfaev.id
			 and rfaev.OBJ_NAME = ''AMW_ORG_PROCESS_RISK''
		     and rocrf.last_evaluator_id = fu.user_id
		     and fu.employee_id = papf.person_id
		     and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
		     and papf.employee_number is not null
			 and rocrf.report_date_julian = ftd.report_date_julian
			 and nvl(arb.material,''N'') = flv.lookup_code(+)
			 and flv.lookup_type(+) = ''AMW_YES_NO''
			 AND rocrf.audit_result_code <> ''EFFECTIVE'' ';



   FOR i in 1..p_page_parameter_tbl.COUNT LOOP

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rocrf.certification_status = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rocrf.certification_type = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rocrf.fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rocrf.natural_account_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rocrf.organization_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
	     l_from_clause := l_from_clause || ' and rocrf.process_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_ACCT_EVAL' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rfaev.id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  /** 10.20.2005 npanandi begin ***/
	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.27.2006 npanandi: use dynamic binding for below time dimension
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = :TIME1 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.27.2006 npanandi: use dynamic binding for below time dimension
	     l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = :TIME1 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.27.2006 npanandi: use dynamic binding for below time dimension
	     l_from_clause := l_from_clause || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_year_id = :TIME1 ';
      END IF;
	  /** 10.20.2005 npanandi end ***/

	  /**** 12.09.2005 npanandi: bug 4862320 fix ****/
	  ----Impact parameter
	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_LINE' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
	     l_from_clause := l_from_clause || ' and rocrf.risk_impact = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  ----Likelihood parameter
	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_REASON+RCI_ISSUE_REASON' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
	     l_from_clause := l_from_clause || ' and rocrf.likelihood = '||p_page_parameter_tbl(i).parameter_id;
      END IF;
	  /**** 12.09.2005 npanandi: bug 4862320 fix end ****/

	  /**** 12.16.2005 npanandi: bug 4908472 fix --- added material parameter ****/
	  ----Material parameter
	  IF(p_page_parameter_tbl(i).parameter_name = 'DUMMY+DUMMY_LEVEL' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null and p_page_parameter_tbl(i).parameter_id <> 'ALL')  THEN

	     l_from_clause := l_from_clause || ' and nvl(arb.material,''N'') = '''||p_page_parameter_tbl(i).parameter_id||''' ';
      END IF;
	  /**** 12.16.2005 npanandi: ends bug 4908472 fix****/


   end loop;


   /** 12.22.2005 npanandi: added SQL below to handle order_by_clause -- bug 4758762 **/
   l_act_sqlstmt := 'select RCI_ORG_CERT_MEASURE1,RCI_ORG_CERT_MEASURE2
                           ,RCI_ORG_CERT_MEASURE3,RCI_ORG_CERT_MEASURE4
                           ,RCI_ORG_CERT_MEASURE5,RCI_ORG_CERT_MEASURE6
						   ,RCI_ORG_CERT_MEASURE7,RCI_ORG_CERT_MEASURE8
						   ,RCI_ORG_CERT_MEASURE9,RCI_ORG_CERT_MEASURE10
						   ,RCI_ORG_CERT_URL1,RCI_ORG_CERT_URL2
						   ,RCI_ORG_CERT_URL3,RCI_ORG_CERT_URL4
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_sqlstmt || l_from_clause||'
							 ) t ) a
					   order by a.col_rank ';


   p_exp_source_sql := l_act_sqlstmt;

   /**04.27.2006 npanandi: adding code for dynamic binding of time period dimensions**/
   p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
   l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME1';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;
   /**04.27.2006 npanandi: finished code for dynamic binding of time period dimensions**/

END get_unmitigated_risks;

-- the get_control_list procedure is called by
-- Organization Certification Control Detail List report.
PROCEDURE get_control_list(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
   l_sqlstmt      VARCHAR2(15000);
   ---12.22.2005 npanandi: added l_act_sqlstmt below
   l_act_sqlstmt  VARCHAR2(15000);
   l_from_clause  varchar2(15000);
   l_getcnt       varchar2(15000);
   l_grp_by       varchar2(15000);
   l_where_clause varchar2(15000);

   l_total        number;
   l_drill_url    varchar2(15000);

   v_period   varchar2(100);
   l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN

   l_sqlstmt := 'select distinct act.name RCI_ORG_CERT_MEASURE1
                       ,act.description RCI_ORG_CERT_MEASURE2
				       ,aauv.name RCI_ORG_CERT_MEASURE3
				       ,al1.meaning RCI_ORG_CERT_MEASURE4
					   ,fl1.meaning RCI_ORG_CERT_MEASURE5
					   ,fl2.meaning RCI_ORG_CERT_MEASURE6
					   ,rfaev.value RCI_ORG_CERT_MEASURE7
					   ,aovt1.OPINION_VALUE_NAME RCI_ORG_CERT_MEASURE8
					   ,aovt2.OPINION_VALUE_NAME RCI_ORG_CERT_MEASURE9
					   ,papf.FULL_NAME RCI_ORG_CERT_MEASURE10
					   ,roccf.last_evaluated_on RCI_ORG_CERT_MEASURE11
				       ,acb.control_rev_id RCI_ORG_CERT_URL1
				       ,acb.control_id RCI_ORG_CERT_URL2
				   from rci_org_cert_ctrls_f roccf
				       ,amw_controls_b acb
				       ,amw_controls_tl act
				       ,amw_audit_units_v aauv
				       ,amw_lookups al1
					   ,fnd_lookups fl1
					   ,fnd_lookups fl2
				       ,amw_opinion_values_tl aovt1
					   ,amw_opinion_values_tl aovt2
					   ,RCI_FS_ACCT_EVAL_V rfaev
				       ,PER_ALL_PEOPLE_F papf
				       ,FND_USER fu
					   /** 10.20.2005 npanandi begin ***/
					   ,fii_time_day ftd
					   /** 10.20.2005 npanandi end ***/
				  where acb.control_rev_id = act.control_rev_id
				    and upper(acb.curr_approved_flag) = ''Y''
				    and act.language = userenv(''LANG'')
				    and acb.control_id = roccf.control_id
					and roccf.organization_id = aauv.organization_id
				    and al1.LOOKUP_CODE = acb.control_type/*roccf.CONTROL_TYPE*/
				    and al1.LOOKUP_TYPE = ''AMW_CONTROL_TYPE''
				    and fl1.LOOKUP_CODE = roccf.KEY_CONTROL
				    and fl1.LOOKUP_TYPE = ''YES_NO''
				    and fl2.LOOKUP_CODE = roccf.DISCLOSURE_CONTROL
				    and fl2.LOOKUP_TYPE = ''YES_NO''
				    and roccf.audit_result_code = rfaev.id
				    and rfaev.OBJ_NAME = ''AMW_ORG_CONTROL''
				    and roccf.DES_EFF_ID = aovt1.OPINION_VALUE_ID(+)
				    and aovt1.LANGUAGE(+) = userenv(''LANG'')
				    and roccf.OP_EFF_ID = aovt2.OPINION_VALUE_ID(+)
				    and aovt2.LANGUAGE(+) = userenv(''LANG'')
				    and roccf.last_evaluated_by_id = fu.user_id
				    and fu.employee_id = papf.person_id
				    and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
				    and papf.employee_number is not null
					and roccf.report_date_julian = ftd.report_date_julian';


   FOR i in 1..p_page_parameter_tbl.COUNT LOOP
      /**l_from_clause := l_from_clause ||' parameter_name: '||p_page_parameter_tbl(i).parameter_name;
	  l_from_clause := l_from_clause ||' parameter_value: '||p_page_parameter_tbl(i).parameter_id;**/

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and roccf.certification_status = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and roccf.certification_type = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and roccf.fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and roccf.natural_account_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and roccf.organization_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
	     l_from_clause := l_from_clause || ' and roccf.process_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_ACCT_EVAL' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and roccf.audit_result_code = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      ----- 10.20.2005 npanandi begin
	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.28.2006 npanandi: use dynamic binding for time dimensions below
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = :TIME1 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.28.2006 npanandi: use dynamic binding for time dimensions below
	     l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = :TIME1 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.28.2006 npanandi: use dynamic binding for time dimensions below
	     l_from_clause := l_from_clause || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_year_id = :TIME1 ';
      END IF;
	  ---- 10.20.2005 npanandi end

	  ----12.05.2005 npanandi start: bug 4862326
	  --l_from_clause := l_from_clause || 'name: '|| p_page_parameter_tbl(i).parameter_name ||', id: '||p_page_parameter_tbl(i).parameter_id;
	  IF(p_page_parameter_tbl(i).parameter_name = 'DUMMY+DUMMY_LEVEL' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 ---l_from_clause := l_from_clause || 'name: '|| p_page_parameter_tbl(i).parameter_name ||', id: '||p_page_parameter_tbl(i).parameter_id;
		 if(p_page_parameter_tbl(i).parameter_id = 'Y')then
		    l_from_clause := l_from_clause || ' and roccf.key_control = ''Y''';
		 elsif(p_page_parameter_tbl(i).parameter_id = 'N')then
		    l_from_clause := l_from_clause || ' and roccf.key_control = ''N''';
	     end if;
      END IF;

	  --l_from_clause := l_from_clause || 'name: '|| p_page_parameter_tbl(i).parameter_name ||', id: '||p_page_parameter_tbl(i).parameter_id;
	  IF(p_page_parameter_tbl(i).parameter_name = 'DUMMY_DIMENSION+DUMMY_DIMENSION_LEVEL' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 ---l_from_clause := l_from_clause || 'name: '|| p_page_parameter_tbl(i).parameter_name ||', id: '||p_page_parameter_tbl(i).parameter_id;
		 if(p_page_parameter_tbl(i).parameter_id = 'Y')then
		    l_from_clause := l_from_clause || ' and roccf.disclosure_control = ''Y''';
		 elsif(p_page_parameter_tbl(i).parameter_id = 'N')then
		    l_from_clause := l_from_clause || ' and roccf.disclosure_control = ''N''';
		 end if;
      END IF;
	  ----12.05.2005 npanandi end:

   end loop;

   /** 12.22.2005 npanandi: added SQL below to handle order_by_clause -- bug 4758762 **/
   l_act_sqlstmt := 'select RCI_ORG_CERT_MEASURE1,RCI_ORG_CERT_MEASURE2
                           ,RCI_ORG_CERT_MEASURE3,RCI_ORG_CERT_MEASURE4
                           ,RCI_ORG_CERT_MEASURE5,RCI_ORG_CERT_MEASURE6
						   ,RCI_ORG_CERT_MEASURE7,RCI_ORG_CERT_MEASURE8
						   ,RCI_ORG_CERT_MEASURE9,RCI_ORG_CERT_MEASURE10
						   ,RCI_ORG_CERT_MEASURE11,RCI_ORG_CERT_URL1,RCI_ORG_CERT_URL2
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_sqlstmt || l_from_clause||'
							 ) t ) a
					   order by a.col_rank ';


   p_exp_source_sql := l_act_sqlstmt;

   /**04.28.2006 npanandi: adding code for dynamic binding of time period dimensions**/
   p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
   l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME1';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;
   /**04.28.2006 npanandi: finished code for dynamic binding of time period dimensions**/


END get_control_list;

-- the get_issue_detail procedure is called by
-- Issue Detail List report.
PROCEDURE get_issue_detail(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
   l_sqlstmt      VARCHAR2(15000);
   l_act_sqlstmt  varchar2(15000);
   l_from_clause  varchar2(15000);
   l_getcnt       varchar2(15000);
   l_grp_by       varchar2(15000);
   l_where_clause varchar2(15000);
   l_end_date varchar2(35);

   l_total        number;
   l_drill_url    varchar2(15000);

   v_yyyymm varchar2(6);
   l_dummy varchar2(10);
BEGIN


   FOR i in 1..p_page_parameter_tbl.COUNT LOOP

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         /*l_from_clause := l_from_clause || ' and acv.certification_status = '||p_page_parameter_tbl(i).parameter_id;*/
         l_from_clause := l_from_clause || ' and open_issues.fin_cert_status = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         /*l_from_clause := l_from_clause || ' and acv.certification_type = '||p_page_parameter_tbl(i).parameter_id;*/
         l_from_clause := l_from_clause || ' and open_issues.fin_cert_type = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /**01.12.2006 npanandi: changed the below to join with acv.certification_id
		    instead of open_issues.certification_id**/
         /*l_from_clause := l_from_clause || ' and acv.certification_id = '||p_page_parameter_tbl(i).parameter_id;*/
         l_from_clause := l_from_clause || ' and open_issues.fin_cert_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and open_issues.organization_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
	     l_from_clause := l_from_clause || ' and open_issues.process_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_PRIORITY+RCI_ISSUE_PRIORITY' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and open_issues.priority_code = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_REASON+RCI_ISSUE_REASON' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and open_issues.reason_code = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_ISSUE_PHASE+RCI_ISSUE_PHASE' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and open_issues.status_code = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  /** 10.20.2005 npanandi begin ***/
	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'M');
         select min(distinct last_day(to_date(to_char(ent_period_end_date,'YYYYMM'),'YYYYMM')))
         into l_end_date /*gives in the form 30-SEP-06*/
         from fii_time_day
        where ent_period_id=p_page_parameter_tbl(i).parameter_id;
		 ---l_from_clause := l_from_clause || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ((eec.status_code not in (0,11) and eec.initiation_date < last_day(to_date('''||v_yyyymm||''',''YYYYMM''))
                     ) or (eec.status_code=11 and eec.last_update_date > last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) )) ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
	     v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Q');
         select min(distinct last_day(to_date(to_char(ent_qtr_end_date,'YYYYMM'),'YYYYMM')))
         into l_end_date /*gives in the form 30-SEP-06*/
         from fii_time_day
        where ent_qtr_id=p_page_parameter_tbl(i).parameter_id;
		 ---l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ((eec.status_code not in (0,11) and eec.initiation_date < last_day(to_date('''||v_yyyymm||''',''YYYYMM''))
                     ) or (eec.status_code=11 and eec.last_update_date > last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) )) ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
	     v_yyyymm := get_last_day(p_page_parameter_tbl(i).parameter_id,'Y');
         select min(distinct last_day(to_date(to_char(ent_year_end_date,'YYYYMM'),'YYYYMM')))
         into l_end_date /*gives in the form 30-SEP-06*/
         from fii_time_day
        where ent_year_id=p_page_parameter_tbl(i).parameter_id;

		 ---l_from_clause := l_from_clause || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ((eec.status_code not in (0,11) and eec.initiation_date < last_day(to_date('''||v_yyyymm||''',''YYYYMM''))
                     ) or (eec.status_code=11 and eec.last_update_date > last_day(to_date('''||v_yyyymm||''',''YYYYMM'')) )) ';
      END IF;/** 10.20.2005 npanandi end ***/

      /**06.12.2006 npanandi: bug 5014235 fix for links**/
      IF(p_page_parameter_tbl(i).parameter_name = 'DUMMY_DIMENSION+DUMMY_DIMENSION_LEVEL' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_dummy := p_page_parameter_tbl(i).parameter_id;
            /***l_from_clause := l_from_clause || ' and
                           decode((abs((nvl(eec.need_by_date,sysdate)-eec.initiation_date))
                                  +abs((last_day(to_date('||v_yyyymm||',''YYYYMM''))-nvl(eec.need_by_date,sysdate))))
                                  ,abs((last_day(to_date('||v_yyyymm||',''YYYYMM''))-eec.initiation_date)),1,0) past_due ';
             ***/
      end if;
      /**06.12.2006 npanandi: bug 5014235 fix ends**/
   end loop;
/*
   if(l_dummy = '''PASTDUE''') then
      l_from_clause := l_from_clause || ' and
                        (abs((to_number(to_char(nvl(eec.need_by_date,sysdate),''J''))-to_number(to_char(eec.initiation_date,''J''))
                       +abs((to_number(to_char(last_day(to_date('||v_yyyymm||',''YYYYMM'')),''J''))-to_number(to_char(nvl(eec.need_by_date,sysdate),''J'')))))))
                       =abs((to_number(to_char(last_day(to_date('||v_yyyymm||',''YYYYMM'')),''J''))-to_number(to_char(eec.initiation_date,''J'')))) ';
   elsif(l_dummy = '''AGEBUCK1''')then
      l_from_clause := l_from_clause || ' and
                        to_number(to_char(last_day(to_date('||v_yyyymm||',''YYYYMM'')),''J''))-to_number(to_char(eec.initiation_date,''J'')) in (0,1) ';
   elsif(l_dummy = '''AGEBUCK2''')then
      l_from_clause := l_from_clause || ' and
                        to_number(to_char(last_day(to_date('||v_yyyymm||',''YYYYMM'')),''J''))-to_number(to_char(eec.initiation_date,''J'')) in (2,3,4,5) ';
   elsif(l_dummy = '''AGEBUCK3''')then
      l_from_clause := l_from_clause || ' and
                        to_number(to_char(last_day(to_date('||v_yyyymm||',''YYYYMM'')),''J''))-to_number(to_char(eec.initiation_date,''J'')) in (6,7,8,9,10) ';
   elsif(l_dummy = '''AGEBUCK4''')then
      l_from_clause := l_from_clause || ' and
                        to_number(to_char(last_day(to_date('||v_yyyymm||',''YYYYMM'')),''J''))-to_number(to_char(eec.initiation_date,''J'')) > 10 ';
   end if;
*/--commented by dpatel 20.09.2006 (bug 5533367)
   if(l_dummy = '''PASTDUE''') then
      l_from_clause := l_from_clause || ' and to_number(to_char(to_date('''||l_end_date||''',''DD-MON-YYYY''),''J'')) > to_number(to_char(eec.need_by_date,''J'')) ';
   elsif(l_dummy = '''AGEBUCK1''')then
      l_from_clause := l_from_clause || ' and to_number(to_char(to_date('''||v_yyyymm||''',''YYYYMM''),''J'')) - to_number(to_char(eec.need_by_date,''J'')) between 0 and 1 ';
   elsif(l_dummy = '''AGEBUCK2''')then
      l_from_clause := l_from_clause || ' and to_number(to_char(to_date('''||v_yyyymm||''',''YYYYMM''),''J'')) - to_number(to_char(eec.need_by_date,''J'')) between 2 and 5 ';
   elsif(l_dummy = '''AGEBUCK3''')then
      l_from_clause := l_from_clause || ' and to_number(to_char(to_date('''||v_yyyymm||''',''YYYYMM''),''J'')) - to_number(to_char(eec.need_by_date,''J'')) between 6 and 10 ';
   elsif(l_dummy = '''AGEBUCK4''')then
      l_from_clause := l_from_clause || ' and to_number(to_char(to_date('''||v_yyyymm||''',''YYYYMM''),''J'')) - to_number(to_char(eec.need_by_date,''J'')) > 10 ';
   end if;


   l_sqlstmt := 'select distinct eec.change_name RCI_ORG_CERT_MEASURE1
                       ,aecv.full_name RCI_ORG_CERT_MEASURE2
		       ,ecst.status_name RCI_ORG_CERT_MEASURE3
		       ,ecp.description RCI_ORG_CERT_MEASURE4
		       ,round((sysdate - eec.initiation_date)) RCI_ORG_CERT_MEASURE5
		       ,eec.need_by_date RCI_ORG_CERT_MEASURE6
		       /*,decode(eec.need_by_date,null,round(sysdate - eec.initiation_date),round(sysdate - eec.need_by_date)) RCI_ORG_CERT_MEASURE7*/
		       ,to_number(to_char(to_date('''||l_end_date||''',''DD-MON-YYYY''),''J'')) - to_number(to_char(eec.need_by_date,''J'')) RCI_ORG_CERT_MEASURE7
                       , eec.change_notice RCI_ORG_CERT_MEASURE9
                   ,eec.change_id RCI_ORG_CERT_URL1
  		   from rci_open_issues_f open_issues,
                        /*amw_audit_units_v aauv,*/
			amw_latest_revisions_v alrv,
			eng_engineering_changes eec,
			amw_employees_current_v aecv,
			eng_change_statuses_tl ecst,
			eng_change_priorities ecp,
			fii_time_day ftd
                  where /*aauv.organization_id=open_issues.organization_id(+)
		     and*/ open_issues.change_id=eec.change_id
		     and aecv.party_id = eec.assignee_id
		     and eec.status_code = ecst.status_code
		     and ecst.language = userenv(''LANG'')
		     and eec.priority_code = ecp.eng_change_priority_code(+)
		     /*and nvl(open_issues.process_id,-1) = nvl(alrv.process_id,-1)
		     and open_issues.certification_id is not null
		     and open_issues.organization_id is not null*/
		     and open_issues.report_date_julian = ftd.report_date_julian';

   /** 09.18.2006 npanandi: added SQL below to handle order_by_clause -- bug 5510667 **/
   l_act_sqlstmt := 'select RCI_ORG_CERT_MEASURE1,RCI_ORG_CERT_MEASURE2,RCI_ORG_CERT_MEASURE3
                           ,RCI_ORG_CERT_MEASURE4,RCI_ORG_CERT_MEASURE5,RCI_ORG_CERT_MEASURE6
						   ,RCI_ORG_CERT_MEASURE7,RCI_ORG_CERT_MEASURE9,RCI_ORG_CERT_URL1
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_sqlstmt || l_from_clause||'
							 ) t ) a
					   order by a.col_rank ';

   p_exp_source_sql := l_act_sqlstmt;
   ---p_exp_source_sql := l_sqlstmt||l_where_clause||l_grp_by;
END get_issue_detail;

-- the get_deficient_processes procedure is called by
-- Process Deficiency Detail report.
PROCEDURE get_deficient_processes(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
   l_sqlstmt      VARCHAR2(15000);
   ---12.22.2005 npanandi: added l_act_sqlstmt below
   l_act_sqlstmt  VARCHAR2(15000);
   l_from_clause  varchar2(15000);
   l_getcnt       varchar2(15000);
   l_grp_by       varchar2(15000);
   l_where_clause varchar2(15000);

   l_total        number;
   l_drill_url    varchar2(15000);

   v_period   varchar2(100);
   l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN

    /*** distinct is OK here, because the rolled up numbers from
	     the previous page report (Organization Certification Summary)
		 contains the Processes w/ Ineffective Controls, taking into
		 account the Key Accounts
	 ***/
   	l_sqlstmt := 'select distinct alrv.display_name RCI_ORG_CERT_MEASURE1
				        ,aauv.name RCI_ORG_CERT_MEASURE2
				        ,fl1.meaning RCI_ORG_CERT_MEASURE3
				        ,fl2.meaning RCI_ORG_CERT_MEASURE4
				        ,acv.certification_name RCI_ORG_CERT_MEASURE5
				        ,rbcrv.value RCI_ORG_CERT_MEASURE6
				        ,papf1.full_name RCI_ORG_CERT_MEASURE7
				        ,aapv.project_name RCI_ORG_CERT_MEASURE8
				        ,rfaev.value RCI_ORG_CERT_MEASURE9
				        ,papf2.full_name RCI_ORG_CERT_MEASURE10
				        ,ropdf.last_evaluated_on RCI_ORG_CERT_MEASURE11
				        ,ropdf.unmitigated_risks RCI_ORG_CERT_MEASURE12
				        ,ropdf.ineffective_controls RCI_ORG_CERT_MEASURE13
						,alrv.process_id RCI_ORG_CERT_URL1
						,aauv.organization_id RCI_ORG_CERT_URL2
						,alrv.revision_number RCI_ORG_CERT_URL3
				    from rci_org_proc_dfcy_f ropdf
				        ,amw_latest_revisions_v alrv
				        ,amw_audit_units_v aauv
				        ,fnd_lookups fl1
				        ,fnd_lookups fl2
				        ,amw_certification_vl acv
				        ,RCI_BP_CERT_RESULT_V rbcrv
				        ,(select full_name,person_id from PER_ALL_PEOPLE_F where employee_number is not null and (trunc(sysdate) between effective_start_date and effective_end_date)) papf1
					    ,FND_USER fu1
					    ,amw_audit_projects_v aapv
					    ,rci_fs_acct_eval_v rfaev
					    ,(select full_name,person_id from PER_ALL_PEOPLE_F where employee_number is not null and (trunc(sysdate) between effective_start_date and effective_end_date)) papf2
					    ,FND_USER fu2
						/** 10.20.2005 npanandi begin ***/
					    ,fii_time_day ftd
					    /** 10.20.2005 npanandi end ***/
				   where ropdf.process_id = alrv.process_id
				     and ropdf.organization_id = aauv.organization_id
				     and ropdf.significant_process_flag = fl1.lookup_code
				     and fl1.lookup_type = ''YES_NO''
				     and ropdf.standard_process_flag = fl2.lookup_code
				     and fl2.lookup_type = ''YES_NO''
				     and ropdf.fin_certification_id = acv.certification_id
				     /**and acv.object_type = ''PROCESS''**/
				     and nvl(ropdf.certification_result_code,''NOT_CERTIFIED'') = rbcrv.id(+)
				     and ropdf.certified_by_id = fu1.user_id(+)
				     and fu1.employee_id = papf1.person_id(+)
				     and ropdf.project_id = aapv.audit_project_id(+)
				     and ropdf.evaluation_result_code = rfaev.id(+)
				     and rfaev.obj_name(+)=''AMW_ORG_PROCESS''
				     and ropdf.last_evaluated_by_id = fu2.user_id(+)
				     and fu2.employee_id = papf2.person_id(+)
					 and ropdf.report_date_julian = ftd.report_date_julian';
				   ---order by alrv.display_name,aauv.name,acv.certification_name';


   FOR i in 1..p_page_parameter_tbl.COUNT LOOP
	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and ropdf.certification_status = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and ropdf.certification_type = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and ropdf.fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and ropdf.natural_account_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and ropdf.organization_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
	     l_from_clause := l_from_clause || ' and ropdf.process_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_CERT_RESULT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 if(p_page_parameter_tbl(i).parameter_id = '''NOT_CERTIFIED''') then
            l_from_clause := l_from_clause || ' and ropdf.certification_result_code IS NULL ';
		 else
            l_from_clause := l_from_clause || ' and ropdf.certification_result_code = '||p_page_parameter_tbl(i).parameter_id;
	     end if;
      END IF;

	  /** 10.20.2005 npanandi begin ***/
	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.28.2006 npanandi: use dynamic binding for time dimensions below
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = :TIME1 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.28.2006 npanandi: use dynamic binding for time dimensions below
	     l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = :TIME1 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.28.2006 npanandi: use dynamic binding for time dimensions below
	     l_from_clause := l_from_clause || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 **/
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_year_id = :TIME1 ';
      END IF;
	  /** 10.20.2005 npanandi end ***/

	  /** 12.12.2005 npanandi: bug 4862301 fix **/
	  IF(p_page_parameter_tbl(i).parameter_name = 'DUMMY+DUMMY_LEVEL' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 if(p_page_parameter_tbl(i).parameter_id = 'Y') then
	        ---l_from_clause := l_from_clause || ' and ropdf.significant_process_flag = '''||p_page_parameter_tbl(i).parameter_id||'''';
			l_from_clause := l_from_clause || ' and ropdf.significant_process_flag = ''Y''';
	     elsif(p_page_parameter_tbl(i).parameter_id = 'N') then
		    l_from_clause := l_from_clause || ' and ropdf.significant_process_flag = ''N''';
	     end if;
		 ---l_from_clause := l_from_clause || '################# p_page_parameter_tbl('||i||').parameter_name: '||p_page_parameter_tbl(i).parameter_name||', p_page_parameter_tbl('||i||').parameter_id: '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'DUMMY_DIMENSION+DUMMY_DIMENSION_LEVEL' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 if(p_page_parameter_tbl(i).parameter_id = 'Y') then
	        ----l_from_clause := l_from_clause || ' and ropdf.key_control = '''||p_page_parameter_tbl(i).parameter_id||'''';
			l_from_clause := l_from_clause || ' and ropdf.key_control = ''Y''';
	     elsif(p_page_parameter_tbl(i).parameter_id = 'N') then
		    l_from_clause := l_from_clause || ' and ropdf.key_control = ''N''';
		 end if;
      END IF;
	  /** 12.12.2005 npanandi: bug 4862301 fix ends **/
   end loop;

   /** 12.22.2005 npanandi: added SQL below to handle order_by_clause -- bug 4758762 **/
   l_act_sqlstmt := 'select RCI_ORG_CERT_MEASURE1,RCI_ORG_CERT_MEASURE2
                           ,RCI_ORG_CERT_MEASURE3,RCI_ORG_CERT_MEASURE4
                           ,RCI_ORG_CERT_MEASURE5,RCI_ORG_CERT_MEASURE6
						   ,RCI_ORG_CERT_MEASURE7,RCI_ORG_CERT_MEASURE8
						   ,RCI_ORG_CERT_MEASURE9,RCI_ORG_CERT_MEASURE10
						   ,RCI_ORG_CERT_MEASURE11,RCI_ORG_CERT_MEASURE12,RCI_ORG_CERT_MEASURE13
						   ,RCI_ORG_CERT_URL1,RCI_ORG_CERT_URL2,RCI_ORG_CERT_URL3
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_sqlstmt || l_from_clause||'
							 ) t ) a
					   order by a.col_rank ';


   p_exp_source_sql := l_act_sqlstmt;

   /**04.28.2006 npanandi: adding code for dynamic binding of time period dimensions**/
   p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
   l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME1';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;
   /**04.28.2006 npanandi: finished code for dynamic binding of time period dimensions**/
END get_deficient_processes;

-- the get_org_certification_detail procedure is called by
-- Organization Certification Detail report.
PROCEDURE get_org_certification_detail(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
   l_sqlstmt      VARCHAR2(15000);
   ---12.22.2005 npanandi: added l_act_sqlstmt below
   l_act_sqlstmt  VARCHAR2(15000);
   l_from_clause  varchar2(15000);
   l_getcnt       varchar2(15000);
   l_grp_by       varchar2(15000);
   l_where_clause varchar2(15000);
   l_group_by     varchar2(15000);

   l_total        number;
   l_drill_url    varchar2(15000);

   v_period   varchar2(100);
   l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN

   	l_sqlstmt := 'select distinct aauv.name RCI_ORG_CERT_MEASURE13
                                        , acv.certification_name RCI_ORG_CERT_MEASURE1
				        ,al1.meaning RCI_ORG_CERT_MEASURE2
				        ,aecv1.full_name RCI_ORG_CERT_MEASURE3
				        ,''Q''||agpv.quarter_num RCI_ORG_CERT_MEASURE4
				        ,agpv.period_year RCI_ORG_CERT_MEASURE5
				        ,al2.meaning RCI_ORG_CERT_MEASURE6
				        ,acv.certification_creation_date RCI_ORG_CERT_MEASURE7
				        ,acv.target_completion_date RCI_ORG_CERT_MEASURE8
				        ,sum(proc_not_certified) RCI_ORG_CERT_MEASURE9
				        ,rbocrv.value RCI_ORG_CERT_MEASURE10
				        ,papf.full_name RCI_ORG_CERT_MEASURE11
				        ,rocsf.org_certified_on RCI_ORG_CERT_MEASURE12
                                ,acv.certification_id RCI_ORG_CERT_URL1
				    from rci_org_cert_summ_f rocsf
				        ,amw_certification_vl acv
				        ,amw_lookups al1
				        ,amw_employees_current_v aecv1
				        ,amw_gl_periods_v agpv
				        ,amw_lookups al2
				        ,(select papf.full_name,fu.user_id from PER_ALL_PEOPLE_F papf,fnd_user fu where fu.employee_id = papf.person_id
				             and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
				             and papf.employee_number is not null) papf
				        ,RCI_BP_ORG_CERT_RESULT_V rbocrv
				        ,hr_all_organization_units_tl aauv
						/** 10.20.2005 npanandi begin ***/
				        ,fii_time_day ftd
					    /** 10.20.2005 npanandi end ***/
				   where rocsf.fin_certification_id = acv.certification_id
				     and acv.object_type = ''FIN_STMT''
				     and rocsf.certification_type = al1.lookup_code
				     and al1.lookup_type = ''AMW_FINSTMT_CERTIFICATION_TYPE''
				     and rocsf.certification_owner_id = aecv1.party_id
				     and rocsf.certification_period_name = agpv.period_name
				     and rocsf.certification_period_set_name = agpv.period_set_name
				     and rocsf.certification_status = al2.lookup_code
				     and al2.lookup_type = ''AMW_PROC_CERTIFICATION_STATUS''
				     and rocsf.org_certified_by = papf.user_id(+)
				     and nvl(rocsf.org_certification_status,''NOT_CERTIFIED'') = rbocrv.id(+)
				     and rocsf.organization_id = aauv.organization_id
                                     and aauv.language = userenv(''LANG'')
					 and rocsf.report_date_julian = ftd.report_date_julian
				   /**** group by acv.certification_name,al1.meaning,aecv1.full_name,agpv.quarter_num,agpv.period_year,al2.meaning
				        ,acv.certification_creation_date,acv.target_completion_date,aauv.name,rbocrv.value,papf.full_name
					    ,rocsf.org_certified_on
				   order by acv.certification_name,aauv.name ****/ ';


   FOR i in 1..p_page_parameter_tbl.COUNT LOOP

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_QTR' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
	     l_from_clause := l_from_clause || ' and r1.certification_period_name = '||p_page_parameter_tbl(i).parameter_id;

		 ---l_url := l_url||'
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rocsf.certification_status = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rocsf.certification_type = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rocsf.fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rocsf.natural_account_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rocsf.organization_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
	     l_from_clause := l_from_clause || ' and rocsf.process_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_ORG_CERT_RESULT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rbocrv.id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  /** 10.20.2005 npanandi begin ***/
	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.28.2006 npanandi: use dynamic binding for below time dimensions
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = :TIME1 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.28.2006 npanandi: use dynamic binding for below time dimensions
	     l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = :TIME1 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /*04.28.2006 npanandi: use dynamic binding for below time dimensions
	     l_from_clause := l_from_clause || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 */
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_year_id = :TIME1 ';
      END IF;
	  /** 10.20.2005 npanandi end ***/

   end loop;

   l_group_by := ' group by acv.certification_name,al1.meaning,aecv1.full_name,agpv.quarter_num,agpv.period_year,al2.meaning
				        ,acv.certification_creation_date,acv.target_completion_date,aauv.name,rbocrv.value,papf.full_name
					    ,rocsf.org_certified_on,acv.certification_id
				   /**order by acv.certification_name,aauv.name**/ ';


   /** 12.22.2005 npanandi: added SQL below to handle order_by_clause -- bug 4758762 **/
   l_act_sqlstmt := 'select RCI_ORG_CERT_MEASURE13, RCI_ORG_CERT_MEASURE1,RCI_ORG_CERT_MEASURE2
                           ,RCI_ORG_CERT_MEASURE3,RCI_ORG_CERT_MEASURE4
                           ,RCI_ORG_CERT_MEASURE5,RCI_ORG_CERT_MEASURE6
						   ,RCI_ORG_CERT_MEASURE7,RCI_ORG_CERT_MEASURE8
						   ,RCI_ORG_CERT_MEASURE9,RCI_ORG_CERT_MEASURE10
						   ,RCI_ORG_CERT_MEASURE11,RCI_ORG_CERT_MEASURE12,RCI_ORG_CERT_URL1
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_sqlstmt || l_from_clause|| l_group_by || '
							 ) t ) a
					   order by a.col_rank ';


   p_exp_source_sql := l_act_sqlstmt;
   ----p_exp_source_sql := l_sqlstmt || l_from_clause || l_group_by;

   /**04.28.2006 npanandi: adding code for dynamic binding of time period dimensions**/
   p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
   l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME1';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;
   /**04.28.2006 npanandi: finished code for dynamic binding of time period dimensions**/

END get_org_certification_detail;

-- the get_process_detail procedure is called by
-- Organization Certification Detail + Significant Account Evaluation Summary report.
PROCEDURE get_process_detail(
   p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
  ,p_exp_source_sql     out NOCOPY VARCHAR2
  ,p_exp_source_output  out NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
   l_sqlstmt      VARCHAR2(15000);
   ---12.22.2005 npanandi: added l_act_sqlstmt below
   l_act_sqlstmt  VARCHAR2(15000);
   l_from_clause  varchar2(15000);
   l_getcnt       varchar2(15000);
   l_grp_by       varchar2(15000);
   l_where_clause varchar2(15000);

   l_total        number;
   l_drill_url    varchar2(15000);

   v_period   varchar2(100);
   l_bind_rec BIS_QUERY_ATTRIBUTES;
BEGIN

   /** 12.02.2005 npanandi: added distinct clause below ***/
   l_sqlstmt := 'select distinct apov.display_name RCI_ORG_CERT_MEASURE1
				       ,aauv.name RCI_ORG_CERT_MEASURE2
				       ,al1.meaning RCI_ORG_CERT_MEASURE3
				       ,al2.meaning RCI_ORG_CERT_MEASURE4
				       ,al3.meaning RCI_ORG_CERT_MEASURE5
				       ,acv.certification_name RCI_ORG_CERT_MEASURE6
				       ,rbcrv.value RCI_ORG_CERT_MEASURE7
				       ,rpdf.certified_on RCI_ORG_CERT_MEASURE8
				       ,aapv.project_name RCI_ORG_CERT_MEASURE9
				       ,rfaev.value RCI_ORG_CERT_MEASURE10
				       ,papf.full_name RCI_ORG_CERT_MEASURE11
				       ,rpdf.last_evaluated_on RCI_ORG_CERT_MEASURE12
					   ,apov.process_id RCI_ORG_CERT_URL1
					   ,apov.organization_id RCI_ORG_CERT_URL2
					   ,apov.revision_number RCI_ORG_CERT_URL3
				   from rci_process_detail_f rpdf
				       ,amw_process_organization_vl apov
				       ,amw_audit_units_v aauv
				       ,amw_lookups al1
				       ,amw_lookups al2
				       ,amw_lookups al3
				       ,amw_certification_vl acv
				       ,RCI_BP_CERT_RESULT_V rbcrv
				       ,amw_audit_projects_v aapv
					   /*** ,RCI_FS_ACCT_EVAL_V rfaev  ***/
					   ,(select id,value from RCI_FS_ACCT_EVAL_V where obj_name=''AMW_ORG_PROCESS'') rfaev
					   ,(select papf.full_name,fu.user_id from PER_ALL_PEOPLE_F papf,fnd_user fu where fu.employee_id = papf.person_id
						    and trunc(sysdate) between papf.effective_start_date and papf.effective_end_date
						    and papf.employee_number is not null) papf
					   /** 10.19.2005 npanandi begin ***/
					   ,fii_time_day ftd
					   /** 10.19.2005 npanandi end ***/
				  where rpdf.process_org_rev_id = apov.process_org_rev_id
				    and rpdf.process_id = apov.process_id
				    and rpdf.organization_id = apov.organization_id
				    and rpdf.organization_id = aauv.organization_id
				    and rpdf.significant_process_flag = al1.lookup_code
				    and al1.lookup_type = ''AMW_SIGNIFICANT_PROCESS''
				    and rpdf.standard_process_flag = al2.lookup_code
				    and al2.lookup_type = ''AMW_STANDARD_PROCESS''
				    and rpdf.process_category = al3.lookup_code(+)
				    and al3.lookup_type(+) = ''AMW_PROCESS_CATEGORY''
				    and rpdf.fin_certification_id = acv.certification_id
				    /**01.25.2006 npanandi: bug 5000369 fix**/
                    /**and rpdf.certification_result_code = rbcrv.id(+)**/
				    and nvl(rpdf.certification_result_code,''NOT_CERTIFIED'') = rbcrv.id(+)and rpdf.project_id = aapv.audit_project_id(+)
				    and rpdf.evaluation_result_code = rfaev.id(+)
				    and rpdf.evaluated_by_id = papf.user_id(+)
					and rpdf.report_date_julian = ftd.report_date_julian';

   FOR i in 1..p_page_parameter_tbl.COUNT LOOP

      ---l_from_clause := l_from_clause || ' p_page_parameter_tbl(i).parameter_name = '||p_page_parameter_tbl(i).parameter_id;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rpdf.certification_status = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rpdf.certification_type = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rpdf.fin_certification_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_FINANCIAL_STATEMENT+RCI_FINANCIAL_ACCT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rpdf.natural_account_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
         l_from_clause := l_from_clause || ' and rpdf.organization_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

      IF(p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
	     l_from_clause := l_from_clause || ' and rpdf.process_id = '||p_page_parameter_tbl(i).parameter_id;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'RCI_BP_CERT+RCI_ORG_CERT_RESULT' AND
         p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 if(p_page_parameter_tbl(i).parameter_id = '''NOT_CERTIFIED''')then
            l_from_clause := l_from_clause || ' and rpdf.certification_result_code is null ';
	     else
		    l_from_clause := l_from_clause || ' and rpdf.certification_result_code = '||p_page_parameter_tbl(i).parameter_id;
		 end if;
      END IF;

	  /** 10.19.2005 npanandi begin ***/
	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /**04.28.2006 npanandi: use dynamic binding for below time dimensions
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = '||p_page_parameter_tbl(i).parameter_id;
		 **/
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_period_id = :TIME1 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /**04.28.2006 npanandi: use dynamic binding for below time dimensions
	     l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = '||p_page_parameter_tbl(i).parameter_id;
		 **/
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_qtr_id = :TIME1 ';
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		 /**04.28.2006 npanandi: use dynamic binding for below time dimensions
	     l_from_clause := l_from_clause || ' and ftd.ent_year_id = '||p_page_parameter_tbl(i).parameter_id;
		 **/
		 v_period := p_page_parameter_tbl(i).parameter_id;
		 l_from_clause := l_from_clause || ' and ftd.ent_year_id = :TIME1 ';
      END IF;
	  /** 10.19.2005 npanandi end ***/

	  /*** 01.01.2006 npanandi: added if clauses for handling Significant Process and Key Control parameters ***/
	  IF(p_page_parameter_tbl(i).parameter_name = 'DUMMY+DUMMY_LEVEL' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		    if((p_page_parameter_tbl(i).parameter_id <> 'ALL') AND (p_page_parameter_tbl(i).parameter_id <> 'All')) then
		       l_from_clause := l_from_clause || ' and nvl(rpdf.significant_process_flag,''N'') = '''||p_page_parameter_tbl(i).parameter_id||''' ';
			end if;
      END IF;

	  IF(p_page_parameter_tbl(i).parameter_name = 'DUMMY_DIMENSION+DUMMY_DIMENSION_LEVEL' AND
	     p_page_parameter_tbl(i).parameter_id is NOT null)  THEN
		    if(p_page_parameter_tbl(i).parameter_id <> 'ALL') then
		       ---l_from_clause := l_from_clause || ' and nvl(rpdf.key_control,''N'') = '''||p_page_parameter_tbl(i).parameter_id||''' ';
			   l_from_clause := l_from_clause || ' and 1=1 ';
            end if;
      END IF;
      /*** 01.01.2006 npanandi: ends ***/
   end loop;



   /** 12.22.2005 npanandi: added SQL below to handle order_by_clause -- bug 4758762 **/
   l_act_sqlstmt := 'select RCI_ORG_CERT_MEASURE1,RCI_ORG_CERT_MEASURE2
                           ,RCI_ORG_CERT_MEASURE3,RCI_ORG_CERT_MEASURE4
                           ,RCI_ORG_CERT_MEASURE5,RCI_ORG_CERT_MEASURE6
						   ,RCI_ORG_CERT_MEASURE7,RCI_ORG_CERT_MEASURE8
						   ,RCI_ORG_CERT_MEASURE9,RCI_ORG_CERT_MEASURE10
						   ,RCI_ORG_CERT_MEASURE11,RCI_ORG_CERT_MEASURE12
						   ,RCI_ORG_CERT_URL1,RCI_ORG_CERT_URL2,RCI_ORG_CERT_URL3
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_sqlstmt || l_from_clause||'
							 ) t ) a
					   order by a.col_rank ';


   p_exp_source_sql := l_act_sqlstmt;

   /**04.28.2006 npanandi: adding code for dynamic binding of time period dimensions**/
   p_exp_source_output := BIS_QUERY_ATTRIBUTES_TBL();
   l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

   p_exp_source_output.EXTEND;
   l_bind_rec.attribute_name := ':TIME1';
   l_bind_rec.attribute_value := v_period;
   l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
   p_exp_source_output(p_exp_source_output.COUNT) := l_bind_rec;
   /**04.28.2006 npanandi: finished code for dynamic binding of time period dimensions**/
END get_process_detail;

---12.08.2005 npanandi: added below function
function get_default_year return varchar2
is
   l_current_year varchar2(5);
begin
    ---return '2004';
	select to_char(sysdate,'YYYY') into l_current_year from dual;

	return l_current_year;
end;

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

--  Common Procedures

END RCI_ORG_CERT_SUMM_PKG;

/
