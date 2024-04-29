--------------------------------------------------------
--  DDL for Package Body RCI_OPEN_ISSUE_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCI_OPEN_ISSUE_SUMM_PKG" as
/*$Header: rciopenisssummb.pls 120.12 2006/09/21 13:51:44 dpatel noship $*/
--need to remove this function if it is not used in any other package
FUNCTION get_first_day(date_id NUMBER, type VARCHAR2) return varchar2
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
            WHEN 1 THEN v_month := '01';
            WHEN 2 THEN v_month := '04';
            WHEN 3 THEN v_month := '07';
            WHEN 4 THEN v_month := '10';
        END CASE;
    ELSIF type='Y' THEN
        v_year := date_id;
        v_month := '01';
    END IF;
    return v_year||v_month;
END;

procedure initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER) is

   l_cert_id number;
   l_org_id number;
   l_proc_id number;
   l_past_due number;
   l_age number;
   l_age_distribution_1 number;
   l_age_distribution_2 number;
   l_age_distribution_3 number;
   l_age_distribution_4 number;
   l_FIN_CERT_ID number;
   l_FIN_CERT_TYPE varchar2(10);
   l_FIN_CERT_STATUS varchar2(30);
   l_period_year number;
   l_period_num  number;
   l_quarter_num  number;
   l_ent_period_id  number;
   l_ent_qtr_id number;
   l_ent_year_id number;
   l_report_date_julian number;
   l_ent_period_end date;
   l_ent_qtr_end date;
   l_ent_yr_end date;
   l_open_per    number;
   l_past_due_per    number;
   l_age_per    number;
   l_age_distribution1_per    number;
   l_age_distribution2_per    number;
   l_age_distribution3_per    number;
   l_age_distribution4_per    number;
   l_open_yr    number;
   l_past_due_yr    number;
   l_age_yr    number;
   l_age_distribution1_yr    number;
   l_age_distribution2_yr    number;
   l_age_distribution3_yr    number;
   l_age_distribution4_yr    number;
   l_open_qtr    number;
   l_past_due_qtr    number;
   l_age_qtr    number;
   l_age_distribution1_qtr    number;
   l_age_distribution2_qtr    number;
   l_age_distribution3_qtr    number;
   l_age_distribution4_qtr    number;

   cursor cur_f is
      select * from rci_open_issues_f;

   cur_rec cur_f%rowtype;
begin

   EXECUTE IMMEDIATE ('TRUNCATE TABLE amw.rci_open_issues_f');

   -- is the change_order open?
   -- status_code, status_type can be confusing. For simplicity, for my purpose,
   -- if the status_code is not in (0, 11), I'll consider this open


   insert into rci_open_issues_f(
      change_id,
      change_name,
      description,
      status_type,
      status_code,
      change_order_type_id,
      change_mgmt_type_code,
      initiation_date,
      need_by_date,
      priority_code,
      reason_code,
      certification_id,
      organization_id,
      process_id,
      fin_cert_id,
      fin_cert_type,
      fin_cert_status,
      open,
      past_due,
      age,
      age_distribution_1,
      age_distribution_2,
      age_distribution_3,
      age_distribution_4,
      implementation_date,
      cancellation_date,
      period_year,
      period_num,
      quarter_num,
      ent_year_id,
      ent_qtr_id,
      ent_period_id,
      report_date_julian)(
      select eec.change_id,
             change_name,
             eec.description,
             status_type,
             status_code,
             change_order_type_id,
             change_mgmt_type_code,
             initiation_date,
             need_by_date,
             priority_code,
             reason_code,
             afpcr.PROC_CERT_ID,/** as certificationId,**/
             null, /**as organizationId,**/
             null, /**as processId,**/
             afpcr.FIN_STMT_CERT_ID, /**as finCertId,**/
	     fin_cert.CERTIFICATION_TYPE, /**as finCertType,**/
             fin_cert.CERTIFICATION_STATUS, /**as finCertStatus,**/
             decode(status_code, 0, 0, 11, 0, 1),/** as open,**/
             0,/** as pastDue,**/
             0,/** as age,**/
             0,/** as ageDistribution1,**/
             0,/** as ageDistribution2,**/
             0,/** as ageDistribution3,**/
             0,/** as ageDistribution4,**/
             implementation_date,
             cancellation_date,
             agpv.PERIOD_YEAR, /**as periodYear,**/
	     agpv.PERIOD_NUM, /**as periodNum,**/
	     agpv.QUARTER_NUM,  /**as quarterNum,**/
	     ftd.ENT_YEAR_ID, /**as entYearId,**/
	     ftd.ENT_QTR_ID, /**as entQuarterId,**/
	     ftd.ENT_PERIOD_ID, /**as entPeriodId,**/
	     to_number(to_char(agpv.end_date,'J')) /**as reportDateJulian**/
        from eng_engineering_changes eec,
             eng_change_subjects ecs,
	     AMW_FIN_PROC_CERT_RELAN afpcr,
	     amw_certification_b proc_cert,
	     amw_certification_b fin_cert,
	     amw_gl_periods_v agpv,
             fii_time_day ftd
       where change_order_type_id in (select change_order_type_id
                                        from eng_change_order_types
                                       where type_classification='HEADER'
                                         and change_mgmt_type_code='AMW_PROC_CERT_ISSUES')
         and ecs.CHANGE_ID = eec.CHANGE_ID
	 and ecs.ENTITY_NAME = 'CERTIFICATION'
         and afpcr.END_DATE is null
	 and proc_cert.CERTIFICATION_ID = ecs.PK1_VALUE
	 and proc_cert.OBJECT_TYPE = 'PROCESS'
	 and proc_cert.CERTIFICATION_ID = afpcr.PROC_CERT_ID
	 and afpcr.FIN_STMT_CERT_ID = fin_cert.CERTIFICATION_ID
	 and fin_cert.CERTIFICATION_PERIOD_NAME = agpv.PERIOD_NAME
	 and fin_cert.CERTIFICATION_PERIOD_SET_NAME = agpv.PERIOD_SET_NAME
	 and ftd.REPORT_DATE_JULIAN = to_number(to_char(agpv.END_DATE,'J')));


   for cur_rec in cur_f loop
   exit when cur_f%notfound;

      l_cert_id := 0;
      l_org_id := 0;
      l_proc_id := 0;
      l_past_due := 0;
      l_age := 0;
      l_age_distribution_1 := 0;
      l_age_distribution_2 := 0;
      l_age_distribution_3 := 0;
      l_age_distribution_4 := 0;

      /*** the below is not needed, as certificationId is prepopulated above
      begin
         select pk1_value
           into l_cert_id
           from ENG_CHANGE_SUBJECTS where change_id = cur_rec.change_id
	    and entity_name = 'CERTIFICATION';
      exception
         when no_data_found then
	    l_cert_id := null;
      end;**/

      /**dbms_output.put_line( '*************** cur_rec.change_id: '||cur_rec.change_id||', l_cert_id: '||l_cert_id );**/

      begin
         select pk1_value
	   into l_org_id
	   from ENG_CHANGE_SUBJECTS where change_id = cur_rec.change_id
	    and entity_name = 'ORGANIZATION';
      exception
         when no_data_found then
            l_org_id := null;
      end;

      /**dbms_output.put_line( '*************** l_org_id: '||l_org_id );**/

      begin
         select pk1_value
           into l_proc_id
	   from ENG_CHANGE_SUBJECTS where change_id = cur_rec.change_id
	    and entity_name = 'PROCESS';
      exception
         when no_data_found then
            l_proc_id := null;
      end;

      /**dbms_output.put_line( '*************** l_proc_id: '||l_proc_id );**/
      -- is it past due? check only for open change orders.

      if (cur_rec.open <> 0) then
         if (cur_rec.need_by_date is not null) and (sysdate > cur_rec.need_by_date) then
            l_past_due := 1;
	 else
	    l_past_due := 0;
	 end if;

	 l_age := sysdate - cur_rec.initiation_date;
         if ((l_age >= 0) and (l_age <= 1)) then
            l_age_distribution_1 := 1;
	 elsif ((l_age >= 2) and (l_age <= 5)) then
	    l_age_distribution_2 := 1;
	 elsif ((l_age >= 6) and (l_age <= 10)) then
	    l_age_distribution_3 := 1;
         elsif (l_age > 10) then
	    l_age_distribution_4 := 1;
	 end if;
      else
         l_past_due := 0;
	 l_age := 0;
	 l_age_distribution_1 := 0;
	 l_age_distribution_2 := 0;
	 l_age_distribution_3 := 0;
	 l_age_distribution_4 := 0;
      end if;

      /**dbms_output.put_line( '*************** outside the cur_rec.open IF-ELSE block' );**/

      /*** do not need the below block, as all the values are prepopulated above
	begin
	   l_FIN_CERT_ID := null;
       l_FIN_CERT_TYPE := null;
       l_FIN_CERT_STATUS := null;

    	select cert2.certification_id
              ,cert2.CERTIFICATION_TYPE
              ,cert2.CERTIFICATION_STATUS,
               agpv.period_year,
               agpv.period_num,
               agpv.quarter_num,
               ftd.ent_period_id,
               ftd.ent_qtr_id,
               ftd.ent_year_id,
               --to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)),
               --to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)),
               --agpv.period_year,
               to_number(to_char(agpv.end_date,'J')),
               ftd.ent_period_end_date,
               ftd.ent_qtr_end_date,
               ftd.ent_year_end_date
          into l_FIN_CERT_ID, l_FIN_CERT_TYPE, l_FIN_CERT_STATUS,
               l_period_year, l_period_num, l_quarter_num, l_ent_period_id,
               l_ent_qtr_id, l_ent_year_id, l_report_date_julian,
               l_ent_period_end, l_ent_qtr_end, l_ent_yr_end
          from AMW_CERTIFICATION_B cert
              ,AMW_FIN_PROC_CERT_RELAN rln
              ,AMW_CERTIFICATION_B cert2
              ,amw_gl_periods_v agpv
              ,fii_time_day ftd
         where cert.OBJECT_TYPE = 'PROCESS'
           and rln.PROC_CERT_ID=cert.CERTIFICATION_ID
           and rln.END_DATE IS NULL
           and rln.fin_stmt_cert_id = cert2.certification_id
           and cert.CERTIFICATION_ID = l_cert_id
           and cert2.certification_period_name = agpv.period_name
           and cert2.certification_period_set_name = agpv.period_set_name
           and ftd.report_date_julian = to_number(to_char(agpv.end_date,'J'));

           dbms_output.put_line( '***1 --> cur_rec.change_id: '||cur_rec.change_id||', l_cert_id: '||l_cert_id||', l_FIN_CERT_ID: '||l_FIN_CERT_ID );

    exception
        when others then
		    dbms_output.put( '##### in null, l_cert_id: '||l_cert_id );
            null;
    end;***/

    /**dbms_output.put_line( '***2 --> l_FIN_CERT_ID: '||l_FIN_CERT_ID||', l_FIN_CERT_TYPE: '||l_FIN_CERT_TYPE||', l_FIN_CERT_STATUS: '||l_FIN_CERT_STATUS );**/
	update rci_open_issues_f
	   set /*certification_id = l_cert_id,*/
	       organization_id = l_org_id,
               process_id = l_proc_id,
               past_due = l_past_due,
	       age = l_age,
	       age_distribution_1 = l_age_distribution_1,
	       age_distribution_2 = l_age_distribution_2,
	       age_distribution_3 = l_age_distribution_3,
	       age_distribution_4 = l_age_distribution_4/**,
	       FIN_CERT_ID = l_FIN_CERT_ID,
	       FIN_CERT_TYPE = l_FIN_CERT_TYPE,
	       FIN_CERT_STATUS = l_FIN_CERT_STATUS,
	       period_year = l_period_year,
	       period_num  = l_period_num,
	       quarter_num  = l_quarter_num,
	       ent_period_id = l_ent_period_id,
	       ent_qtr_id  = l_ent_qtr_id,
	       ent_year_id = l_ent_year_id,
	       report_date_julian  = l_report_date_julian**/
	 where change_id = cur_rec.change_id;


-- populating the newly added age/etc columns per period-type.
-- I could have merged this in the above code, just wanted to keep this seperate
-- for readbility

-- consider qtr
l_open_qtr := 0;
l_past_due_qtr := 0;
l_age_qtr := 0;
l_age_distribution1_qtr := 0;
l_age_distribution2_qtr := 0;
l_age_distribution3_qtr := 0;
l_age_distribution4_qtr := 0;

    if (cur_rec.status_code <> 0) and (cur_rec.status_code <> 11) then
        l_open_qtr := 1;
    elsif ( (cur_rec.implementation_date is not null)
            and (cur_rec.implementation_date > l_ent_qtr_end) ) then
        l_open_qtr := 1;
    elsif ( (cur_rec.cancellation_date is not null)
            and (cur_rec.cancellation_date > l_ent_qtr_end) ) then
        l_open_qtr := 1;
    end if;

	if (cur_rec.open_qtr <> 0) then
		if (cur_rec.need_by_date is not null) and (l_ent_qtr_end > cur_rec.need_by_date) then
			l_past_due_qtr := 1;
		else
			l_past_due_qtr := 0;
		end if;

		l_age_qtr := l_ent_qtr_end - cur_rec.initiation_date;


        if ((l_age_qtr >= 0) and (l_age_qtr <= 1)) then
			l_age_distribution1_qtr := 1;
		elsif ((l_age_qtr >= 2) and (l_age_qtr <= 5)) then
			l_age_distribution2_qtr := 1;
		elsif ((l_age_qtr >= 6) and (l_age_qtr <= 10)) then
			l_age_distribution3_qtr := 1;
		elsif (l_age_qtr > 10) then
			l_age_distribution4_qtr := 1;
		end if;

	else
		l_past_due_qtr := 0;
		l_age_qtr := 0;
		l_age_distribution1_qtr := 0;
		l_age_distribution2_qtr := 0;
		l_age_distribution3_qtr := 0;
		l_age_distribution4_qtr := 0;

	end if;


-- consider yr
l_open_yr := 0;
l_past_due_yr := 0;
l_age_yr := 0;
l_age_distribution1_yr := 0;
l_age_distribution2_yr := 0;
l_age_distribution3_yr := 0;
l_age_distribution4_yr := 0;

    if (cur_rec.status_code <> 0) and (cur_rec.status_code <> 11) then
        l_open_yr := 1;
    elsif ( (cur_rec.implementation_date is not null)
            and (cur_rec.implementation_date > l_ent_yr_end) ) then
        l_open_yr := 1;
    elsif ( (cur_rec.cancellation_date is not null)
            and (cur_rec.cancellation_date > l_ent_yr_end) ) then
        l_open_yr := 1;
    end if;

	if (cur_rec.open_yr <> 0) then
		if (cur_rec.need_by_date is not null) and (l_ent_yr_end > cur_rec.need_by_date) then
			l_past_due_yr := 1;
		else
			l_past_due_yr := 0;
		end if;

		l_age_yr := l_ent_yr_end - cur_rec.initiation_date;


        if ((l_age_yr >= 0) and (l_age_yr <= 1)) then
			l_age_distribution1_yr := 1;
		elsif ((l_age_yr >= 2) and (l_age_yr <= 5)) then
			l_age_distribution2_yr := 1;
		elsif ((l_age_yr >= 6) and (l_age_yr <= 10)) then
			l_age_distribution3_yr := 1;
		elsif (l_age_yr > 10) then
			l_age_distribution4_yr := 1;
		end if;

	else
		l_past_due_yr := 0;
		l_age_yr := 0;
		l_age_distribution1_yr := 0;
		l_age_distribution2_yr := 0;
		l_age_distribution3_yr := 0;
		l_age_distribution4_yr := 0;

	end if;


-- consider per
l_open_per := 0;
l_past_due_per := 0;
l_age_per := 0;
l_age_distribution1_per := 0;
l_age_distribution2_per := 0;
l_age_distribution3_per := 0;
l_age_distribution4_per := 0;

    if (cur_rec.status_code <> 0) and (cur_rec.status_code <> 11) then
        l_open_per := 1;
    elsif ( (cur_rec.implementation_date is not null)
            and (cur_rec.implementation_date > l_ent_period_end) ) then
        l_open_per := 1;
    elsif ( (cur_rec.cancellation_date is not null)
            and (cur_rec.cancellation_date > l_ent_period_end) ) then
        l_open_per := 1;
    end if;

	if (cur_rec.open_per <> 0) then
		if (cur_rec.need_by_date is not null) and (l_ent_period_end > cur_rec.need_by_date) then
			l_past_due_per := 1;
		else
			l_past_due_per := 0;
		end if;

		l_age_per := l_ent_period_end - cur_rec.initiation_date;


        if ((l_age_per >= 0) and (l_age_per <= 1)) then
			l_age_distribution1_per := 1;
		elsif ((l_age_per >= 2) and (l_age_per <= 5)) then
			l_age_distribution2_per := 1;
		elsif ((l_age_per >= 6) and (l_age_per <= 10)) then
			l_age_distribution3_per := 1;
		elsif (l_age_per > 10) then
			l_age_distribution4_per := 1;
		end if;

	else
		l_past_due_per := 0;
		l_age_per := 0;
		l_age_distribution1_per := 0;
		l_age_distribution2_per := 0;
		l_age_distribution3_per := 0;
		l_age_distribution4_per := 0;

	end if;

    update rci_open_issues_f
	   set open_per = l_open_per,
           past_due_per = l_past_due_per,
           age_per = l_age_per,
           age_distribution1_per = l_age_distribution1_per,
           age_distribution2_per = l_age_distribution2_per,
           age_distribution3_per = l_age_distribution3_per,
           age_distribution4_per = l_age_distribution4_per,
           open_yr = l_open_yr,
           past_due_yr = l_past_due_yr,
           age_yr = l_age_yr,
           age_distribution1_yr = l_age_distribution1_yr,
           age_distribution2_yr = l_age_distribution2_yr,
           age_distribution3_yr = l_age_distribution3_yr,
           age_distribution4_yr = l_age_distribution4_yr,
           open_qtr = l_open_qtr,
           past_due_qtr = l_past_due_qtr,
           age_qtr = l_age_qtr,
           age_distribution1_qtr = l_age_distribution1_qtr,
           age_distribution2_qtr = l_age_distribution2_qtr,
           age_distribution3_qtr = l_age_distribution3_qtr,
           age_distribution4_qtr = l_age_distribution4_qtr
     where change_id = cur_rec.change_id;


end loop;

end initial_load;


-- currently incremental - initial, this needs to be reviewed
procedure incremental_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER) is
begin
initial_load(
   errbuf    => errbuf
  ,retcode   => retcode);
end incremental_load;



PROCEDURE get_summ_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                       x_custom_sql OUT NOCOPY VARCHAR2,
                       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is
   l_query0 VARCHAR2(32767);
   l_query1 VARCHAR2(32767);
   l_query2 VARCHAR2(32767);
   l_query3 VARCHAR2(32767);
   l_query4 VARCHAR2(32767);
   l_query22 varchar2(32767);
   l_act_sqlstmt varchar2(32767);
   where_flag number := 1;
   proc varchar2(100);
   org varchar2(100);
   l_end_date varchar2(100);
   l_start_date varchar2(100);
   l_report_date_julian number;

   l_dumm1 varchar2(100);
   l_dumm2 varchar2(100);
   l_dumm3 varchar2(100);
   l_dumm4 varchar2(100);
   l_dumm5 varchar2(100);
begin
   l_dumm1 := ',''ALL'' ';
   l_dumm2 := ',''ALL'' ';
   l_dumm3 := ',''ALL'' ';
   l_dumm4 := ',''ALL'' ';
   l_dumm5 := ',''ALL'' ';

   l_query0 := '';
   l_query1 := '';
   l_query2 := '';
   l_query3 := '';
   l_query4 := '';

   FOR i in 1..p_param.COUNT LOOP

             IF(p_param(i).parameter_name = 'VIEW_BY' AND
                p_param(i).parameter_id = 'ORGANIZATION+RCI_ORG_AUDIT')  THEN
                    l_dumm1 := ',organization_id ';
                    l_query0 := 'select organization_id as VIEWBYID
                                       ,name as VIEWBY
				       ,-1000 as RCI_OPEN_ISSUE_MEASURE1
				       ,sum(past_due) as RCI_OPEN_ISSUE_MEASURE2
				       ,round(((sum(past_due)/count(change_id))*100),2) as RCI_OPEN_ISSUE_MEASURE3
				       ,floor(sum(open_days)/count(change_id)) as RCI_OPEN_ISSUE_MEASURE4
				       ,sum(age_buck1) as RCI_OPEN_ISSUE_MEASURE5
				       ,sum(age_buck2) as RCI_OPEN_ISSUE_MEASURE6
				       ,sum(age_buck3) as RCI_OPEN_ISSUE_MEASURE7
				       ,sum(age_buck4) as RCI_OPEN_ISSUE_MEASURE8
                                       /**,organization_id as RCI_ORG_CERT_URL1
                                       ,''ALL'' as RCI_ORG_CERT_URL2
                                       ,''ALL'' as RCI_ORG_CERT_URL3
                                       ,''ALL'' as RCI_ORG_CERT_URL4
                                       ,''ALL'' as RCI_ORG_CERT_URL5
				   from ( **/' ;

                    l_query1 := ' select distinct roif.organization_id
                                        ,aauv.name
					,roif.change_id
					,eec.change_name
					,eec.initiation_date ';

                    l_query22 := ' from rci_open_issues_f roif
                                       ,eng_engineering_changes eec
		                       ,amw_audit_units_v aauv
				       ,amw_certification_vl acv
                                  where roif.change_id=eec.change_id
		                    and roif.organization_id=aauv.organization_id
				    and roif.fin_cert_id = acv.certification_id ';

                    l_query4 := ') group by organization_id,name ';
             END IF;

             IF(p_param(i).parameter_name = 'VIEW_BY' AND
                p_param(i).parameter_id = 'RCI_BP_CERT+RCI_BP_PROCESS')  THEN
                    l_dumm2 := ',process_id ';
                    l_query0 := 'select process_id as VIEWBYID
                                       ,display_name as VIEWBY
				       ,-1000 as RCI_OPEN_ISSUE_MEASURE1
				       ,sum(past_due) as RCI_OPEN_ISSUE_MEASURE2
				       ,round(((sum(past_due)/count(change_id))*100),2) as RCI_OPEN_ISSUE_MEASURE3
				       ,floor(sum(open_days)/count(change_id)) as RCI_OPEN_ISSUE_MEASURE4
				       ,sum(age_buck1) as RCI_OPEN_ISSUE_MEASURE5
				       ,sum(age_buck2) as RCI_OPEN_ISSUE_MEASURE6
				       ,sum(age_buck3) as RCI_OPEN_ISSUE_MEASURE7
				       ,sum(age_buck4) as RCI_OPEN_ISSUE_MEASURE8
                                       /**,organization_id as RCI_ORG_CERT_URL1
                                       ,''ALL'' as RCI_ORG_CERT_URL2
                                       ,''ALL'' as RCI_ORG_CERT_URL3
                                       ,''ALL'' as RCI_ORG_CERT_URL4
                                       ,''ALL'' as RCI_ORG_CERT_URL5
				   from ( **/';

                    l_query1 := ' select distinct roif.process_id
                                        ,alrv.display_name
					,roif.change_id
					,eec.change_name
					,eec.initiation_date ';

                    l_query22 := ' from rci_open_issues_f roif
                                       ,eng_engineering_changes eec
				       ,amw_certification_vl acv
                                       ,amw_latest_revisions_v alrv
                                  where roif.change_id=eec.change_id
		                    and roif.process_id=alrv.process_id
				    and roif.fin_cert_id = acv.certification_id ';

                    l_query4 := ') group by process_id,display_name ';

             END IF;

             IF(p_param(i).parameter_name = 'VIEW_BY' AND
                p_param(i).parameter_id = 'RCI_FS_CERT+RCI_FS_CERT')  THEN

                    l_query0 := 'select fin_cert_id as VIEWBYID
                                       ,certification_name as VIEWBY
				       ,-1000 as RCI_OPEN_ISSUE_MEASURE1
				       ,sum(past_due) as RCI_OPEN_ISSUE_MEASURE2
				       ,round(((sum(past_due)/count(change_id))*100),2) as RCI_OPEN_ISSUE_MEASURE3
				       ,floor(sum(open_days)/count(change_id)) as RCI_OPEN_ISSUE_MEASURE4
				       ,sum(age_buck1) as RCI_OPEN_ISSUE_MEASURE5
				       ,sum(age_buck2) as RCI_OPEN_ISSUE_MEASURE6
				       ,sum(age_buck3) as RCI_OPEN_ISSUE_MEASURE7
                                       ,sum(age_buck4) as RCI_OPEN_ISSUE_MEASURE8
                                       /**,organization_id as RCI_ORG_CERT_URL1
                                       ,''ALL'' as RCI_ORG_CERT_URL2
                                       ,''ALL'' as RCI_ORG_CERT_URL3
                                       ,''ALL'' as RCI_ORG_CERT_URL4
                                       ,''ALL'' as RCI_ORG_CERT_URL5
				   from ( **/';

                    l_query1 := ' select distinct roif.fin_cert_id
                                        ,acv.certification_name
					,roif.change_id
					,eec.change_name
					,eec.initiation_date ';

                    l_query22 := ' from rci_open_issues_f roif
                                       ,eng_engineering_changes eec
		                       ,amw_certification_vl acv
                                  where roif.change_id=eec.change_id
		                    and roif.fin_cert_id=acv.certification_id ';

                    l_query4 := ') group by fin_cert_id,certification_name ';

             END IF;

             IF(p_param(i).parameter_name = 'VIEW_BY' AND
                p_param(i).parameter_id = 'RCI_ISSUE_PHASE+RCI_ISSUE_PHASE')  THEN
                    l_dumm3 := ',status_code ';
                    l_query0 := 'select status_code as VIEWBYID
                                       ,value as VIEWBY
				       ,-1000 as RCI_OPEN_ISSUE_MEASURE1
				       ,sum(past_due) as RCI_OPEN_ISSUE_MEASURE2
				       ,round(((sum(past_due)/count(change_id))*100),2) as RCI_OPEN_ISSUE_MEASURE3
				       ,floor(sum(open_days)/count(change_id)) as RCI_OPEN_ISSUE_MEASURE4
				       ,sum(age_buck1) as RCI_OPEN_ISSUE_MEASURE5
				       ,sum(age_buck2) as RCI_OPEN_ISSUE_MEASURE6
				       ,sum(age_buck3) as RCI_OPEN_ISSUE_MEASURE7
				       ,sum(age_buck4) as RCI_OPEN_ISSUE_MEASURE8
                                       /**,organization_id as RCI_ORG_CERT_URL1
                                       ,''ALL'' as RCI_ORG_CERT_URL2
                                       ,''ALL'' as RCI_ORG_CERT_URL3
                                       ,''ALL'' as RCI_ORG_CERT_URL4
                                       ,''ALL'' as RCI_ORG_CERT_URL5
				   from ( **/';

                    l_query1 := ' select distinct roif.status_code
                                        ,ripv.value
				        ,roif.change_id
				        ,eec.change_name
				        ,eec.initiation_date ';

                    l_query22 := ' from rci_open_issues_f roif
		                       ,eng_engineering_changes eec
				       ,amw_certification_vl acv
                                       ,rci_issue_phase_v ripv
                                  where roif.change_id=eec.change_id
                                    and roif.status_code=ripv.id
				    and roif.fin_cert_id = acv.certification_id ';

                    l_query4 := ') group by status_code,value ';

             END IF;

             IF(p_param(i).parameter_name = 'VIEW_BY' AND
                p_param(i).parameter_id = 'RCI_ISSUE_PRIORITY+RCI_ISSUE_PRIORITY')  THEN
                    l_dumm4 := ',priority_code ';
                    l_query0 := 'select priority_code as VIEWBYID
                                       ,value as VIEWBY
				       ,-1000 as RCI_OPEN_ISSUE_MEASURE1
				       ,sum(past_due) as RCI_OPEN_ISSUE_MEASURE2
				       ,round(((sum(past_due)/count(change_id))*100),2) as RCI_OPEN_ISSUE_MEASURE3
				       ,floor(sum(open_days)/count(change_id)) as RCI_OPEN_ISSUE_MEASURE4
				       ,sum(age_buck1) as RCI_OPEN_ISSUE_MEASURE5
				       ,sum(age_buck2) as RCI_OPEN_ISSUE_MEASURE6
				       ,sum(age_buck3) as RCI_OPEN_ISSUE_MEASURE7
				       ,sum(age_buck4) as RCI_OPEN_ISSUE_MEASURE8
                                       /**,organization_id as RCI_ORG_CERT_URL1
                                       ,''ALL'' as RCI_ORG_CERT_URL2
                                       ,''ALL'' as RCI_ORG_CERT_URL3
                                       ,''ALL'' as RCI_ORG_CERT_URL4
                                       ,''ALL'' as RCI_ORG_CERT_URL5
				   from ( **/';

                    l_query1 := ' select distinct roif.priority_code
                                        ,ripv.value
				        ,roif.change_id
				        ,eec.change_name
				        ,eec.initiation_date ';

                    l_query22 := ' from rci_open_issues_f roif
		                       ,eng_engineering_changes eec
				       ,amw_certification_vl acv
                                       ,RCI_ISSUE_PRIORITY_V ripv
                                  where roif.change_id=eec.change_id
                                    and roif.priority_code=ripv.id
			    	    and roif.fin_cert_id = acv.certification_id ';

                    l_query4 := ') group by priority_code,value ';

             END IF;

             IF(p_param(i).parameter_name = 'VIEW_BY' AND
                p_param(i).parameter_id = 'RCI_ISSUE_REASON+RCI_ISSUE_REASON')  THEN
                    l_dumm5 := ',reason_code ';
                    l_query0 := 'select reason_code as VIEWBYID
                                       ,value as VIEWBY
				       ,-1000 as RCI_OPEN_ISSUE_MEASURE1
				       ,sum(past_due) as RCI_OPEN_ISSUE_MEASURE2
				       ,round(((sum(past_due)/count(change_id))*100),2) as RCI_OPEN_ISSUE_MEASURE3
				       ,floor(sum(open_days)/count(change_id)) as RCI_OPEN_ISSUE_MEASURE4
				       ,sum(age_buck1) as RCI_OPEN_ISSUE_MEASURE5
				       ,sum(age_buck2) as RCI_OPEN_ISSUE_MEASURE6
				       ,sum(age_buck3) as RCI_OPEN_ISSUE_MEASURE7
				       ,sum(age_buck4) as RCI_OPEN_ISSUE_MEASURE8
                                       /**,organization_id as RCI_ORG_CERT_URL1
                                       ,''ALL'' as RCI_ORG_CERT_URL2
                                       ,''ALL'' as RCI_ORG_CERT_URL3
                                       ,''ALL'' as RCI_ORG_CERT_URL4
                                       ,''ALL'' as RCI_ORG_CERT_URL5
				   from ( **/';

                    l_query1 := ' select distinct roif.reason_code
                                        ,rirv.value
                                        ,roif.change_id
					,eec.change_name
					,eec.initiation_date ';

                    l_query22 := ' from rci_open_issues_f roif
                                       ,eng_engineering_changes eec
                                       ,amw_certification_vl acv
                                       ,RCI_ISSUE_REASON_V rirv
                                  where roif.change_id=eec.change_id
                                    and roif.reason_code=rirv.id
				    and roif.fin_cert_id = acv.certification_id ';

                    l_query4 := ') group by reason_code,value ';

             END IF;


/*           IF(p_param(i).parameter_name = 'VIEW_BY' AND
                p_param(i).parameter_id = 'RCI_FINANCIAL_ACCT+RCI_FINANCIAL_ACCT')  THEN

                    l_query0 :=

                    l_query2 := ' group by (f.account_group_id, f.natural_account_id)';

             END IF;
*/

             IF(p_param(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query3 := l_query3 || ' and roif.FIN_CERT_ID = '||p_param(i).parameter_id;
             END IF;

             IF(p_param(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query3 := l_query3 || ' and roif.organization_id = '||p_param(i).parameter_id;
                    l_dumm1 := ','||p_param(i).parameter_id;
             END IF;

             IF(p_param(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query3 := l_query3 || ' and roif.process_id = '||p_param(i).parameter_id;
                    l_dumm2 := ','||p_param(i).parameter_id;
             END IF;

/*             IF(p_param(i).parameter_name = 'RCI_FINANCIAL_ACCT+RCI_FINANCIAL_ACCT' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query1 := l_query1 || ' and natural_account_id = '||p_param(i).parameter_id;
             END IF;
*/

             IF(p_param(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query3 := l_query3 || ' and acv.certification_status = '||p_param(i).parameter_id;
             END IF;

             IF(p_param(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query3 := l_query3 || ' and acv.certification_type = '||p_param(i).parameter_id;
             END IF;

             IF(p_param(i).parameter_name = 'RCI_ISSUE_PHASE+RCI_ISSUE_PHASE' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query3 := l_query3 || ' and roif.status_code = '||p_param(i).parameter_id;
                    l_dumm3 := ','||p_param(i).parameter_id;
             END IF;

             IF(p_param(i).parameter_name = 'RCI_ISSUE_PRIORITY+RCI_ISSUE_PRIORITY' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query3 := l_query3 || ' and roif.priority_code = '||p_param(i).parameter_id;
                    l_dumm4 := ','||p_param(i).parameter_id;
             END IF;

    	     IF(p_param(i).parameter_name = 'RCI_ISSUE_REASON+RCI_ISSUE_REASON' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query3 := l_query3 || ' and roif.reason_code = '||p_param(i).parameter_id;
                    l_dumm5 := ','||p_param(i).parameter_id;
             END IF;

       	     IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' AND
        	     p_param(i).parameter_id is NOT null)  THEN
                    select distinct last_day(to_date(to_char(ent_period_end_date,'YYYYMM'),'YYYYMM'))
                      into l_end_date
                      from fii_time_day
                     where ent_period_id=p_param(i).parameter_id;

                   select min(distinct last_day(to_date(to_char(ent_period_start_date,'YYYYMM'),'YYYYMM')))
                     into l_start_date /*gives in the form 30-SEP-06*/
                     from fii_time_day
                    where ent_period_id=p_param(i).parameter_id;

		        l_query3 := l_query3 ||' and eec.initiation_date < to_date('''||l_end_date||''',''DD-MON-YYYY'')
                                                and (eec.status_code not in (0,11)
                                                 or (eec.status_code=11 and eec.last_update_date > to_date('''||l_end_date||''',''DD-MON-YYYY'')))';

             END IF;

            IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' AND
        	     p_param(i).parameter_id is NOT null)  THEN
                   select distinct last_day(to_date(to_char(ent_qtr_end_date,'YYYYMM'),'YYYYMM'))
                      into l_end_date
                      from fii_time_day
                     where ent_qtr_id=p_param(i).parameter_id;

                   select min(distinct last_day(to_date(to_char(ent_qtr_start_date,'YYYYMM'),'YYYYMM')))
                     into l_start_date /*gives in the form 30-SEP-06*/
                     from fii_time_day
                    where ent_qtr_id=p_param(i).parameter_id;

                       l_query3 := l_query3 ||' and eec.initiation_date < to_date('''||l_end_date||''',''DD-MON-YYYY'')
                                                and (eec.status_code not in (0,11)
                                                 or (eec.status_code=11 and eec.last_update_date > to_date('''||l_end_date||''',''DD-MON-YYYY'')))';

            END IF;

            IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' AND
        	     p_param(i).parameter_id is NOT null)  THEN
                   select min(distinct last_day(to_date(to_char(ent_year_end_date,'YYYYMM'),'YYYYMM')))
                     into l_end_date /*gives in the form 30-SEP-06*/
                     from fii_time_day
                    where ent_year_id=p_param(i).parameter_id;

                   select min(distinct last_day(to_date(to_char(ent_year_start_date,'YYYYMM'),'YYYYMM')))
                     into l_start_date /*gives in the form 30-SEP-06*/
                     from fii_time_day
                    where ent_year_id=p_param(i).parameter_id;

                       l_query3 := l_query3 ||' and eec.initiation_date < to_date('''||l_end_date||''',''DD-MON-YYYY'')
                                                and (eec.status_code not in (0,11)
                                                 or (eec.status_code=11 and eec.last_update_date > to_date('''||l_end_date||''',''DD-MON-YYYY'')))';

            END IF;


        END LOOP;

     /** 09.20.2006 npanandi: Nilesh's version**/
     l_query2 := ' ,decode(eec.need_by_date,null,trunc(to_date('''||l_end_date||''',''DD-MON-YYYY'')-eec.initiation_date),
                  trunc(to_date('''||l_end_date||''',''DD-MON-YYYY'')-eec.need_by_date)) past_due_days
            ,case when (to_number(to_char(to_date('''||l_end_date||''',''DD-MON-YYYY''),''J'')) > to_number(to_char(eec.need_by_date,''J'')))
                  then 1 else 0 end past_due
            ,trunc(last_day(to_date('''||l_end_date||''',''DD-MON-YYYY''))-eec.initiation_date) open_days
            ,case when (to_number(to_char(to_date('''||l_end_date||''',''DD-MON-YYYY''),''J'')) - to_number(to_char(eec.need_by_date,''J'')) = 1)
                  then 1 else 0 end age_buck1
            ,case when (to_number(to_char(to_date('''||l_end_date||''',''DD-MON-YYYY''),''J'')) - to_number(to_char(eec.need_by_date,''J'')) between 2 and 5)
                  then 1 else 0 end age_buck2
            ,case when (to_number(to_char(to_date('''||l_end_date||''',''DD-MON-YYYY''),''J'')) - to_number(to_char(eec.need_by_date,''J'')) between 6 and 10)
                  then 1 else 0 end age_buck3
            ,case when (to_number(to_char(to_date('''||l_end_date||''',''DD-MON-YYYY''),''J'')) - to_number(to_char(eec.need_by_date,''J'')) > 10)
                  then 1 else 0 end age_buck4 ';

        /*** 09.20.2006 npanandi: commenting this out -- not sure why this is needed**/
        /***l_query3 := l_query3 ||' and (eec.implementation_date is null or (eec.implementation_date > to_date('''||v_yyyymm||''',''YYYYMM'')))
            and ((eec.status_code not in (0,11)) or (eec.status_code=11 and eec.last_update_date > last_day(to_date('||v_yyyymm||',''YYYYMM''))))';
         ***/

    l_query0 := l_query0||' '||l_dumm1||' as RCI_ORG_CERT_URL1 '||
                l_dumm2||' as RCI_ORG_CERT_URL2 '||
                l_dumm3||' as RCI_ORG_CERT_URL3 '||
                l_dumm4||' as RCI_ORG_CERT_URL4 '||
                l_dumm5||' as RCI_ORG_CERT_URL5 from ( ';

   /** 09.18.2006 npanandi: added SQL below to handle order_by_clause -- bug 5510667 **/
   l_act_sqlstmt := 'select VIEWBYID,VIEWBY,RCI_OPEN_ISSUE_MEASURE1,RCI_OPEN_ISSUE_MEASURE2
                           ,RCI_OPEN_ISSUE_MEASURE3,RCI_OPEN_ISSUE_MEASURE4
						   ,RCI_OPEN_ISSUE_MEASURE5,RCI_OPEN_ISSUE_MEASURE6
						   ,RCI_OPEN_ISSUE_MEASURE7,RCI_OPEN_ISSUE_MEASURE8
						   ,RCI_ORG_CERT_URL1,RCI_ORG_CERT_URL2,RCI_ORG_CERT_URL3
						   ,RCI_ORG_CERT_URL4,RCI_ORG_CERT_URL5
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_query0||l_query1||l_query2||l_query22||l_query3||l_query4||'
							 ) t ) a
					   order by a.col_rank ';

    /**x_custom_sql := l_query0||l_query1||l_query2||l_query22||l_query3||l_query4;**/
	x_custom_sql := l_act_sqlstmt;

end;



end RCI_OPEN_ISSUE_SUMM_PKG;

/
