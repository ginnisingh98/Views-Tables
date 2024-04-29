--------------------------------------------------------
--  DDL for Package Body RCI_COMPL_ENV_CHG_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCI_COMPL_ENV_CHG_SUMM_PKG" as
/*$Header: rcicmpenvchgsumb.pls 120.11 2006/09/19 23:23:34 npanandi noship $*/

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

/*** 12.09.2005 npanandi: added below procedure ***/
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

FUNCTION err_mesg (
   p_mesg      IN VARCHAR2
  ,p_proc_name IN VARCHAR2 DEFAULT NULL
  ,p_stmt_id   IN NUMBER DEFAULT -1)
RETURN VARCHAR2
IS
   l_proc_name         VARCHAR2 (60);
   l_stmt_id           NUMBER;
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

FUNCTION get_last_run_date(p_fact_name VARCHAR2)
RETURN DATE
IS
   l_func_name     VARCHAR2(40);
   l_stmt_id       NUMBER;
   l_last_run_date DATE;
BEGIN
   -- Initialization
   l_func_name := 'get_last_run_date';
   l_stmt_id := 0;

   SELECT last_run_date
     into l_last_run_date
	 FROM rci_dr_inc
	WHERE fact_name =  p_fact_name ;

   RETURN l_last_run_date;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg ('Please launch the Initial Load Request Set for the RCI Organization Certifications Summary page.'
							,l_func_name,l_stmt_id));
      RAISE ;
   WHEN OTHERS THEN
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_func_name,l_stmt_id));
      RAISE ;
END get_last_run_date;


procedure initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER) is

/*02.02.2006 npanandi: changed below cursor for performance reasons
cursor cur_f is
   select * from rci_compl_env_chg_summ_f;
   */
   cursor cur_f is
      select distinct fin_certification_id,organization_id,process_id
        from rci_compl_env_chg_summ_f
       where organization_id is not null
	     and process_id is not null;

   cur_rec cur_f%rowtype;

   l_curr_rev_num number;
   l_risk_count number;
   l_control_count number;

   l_user_id                NUMBER ;
   l_login_id               NUMBER ;
   l_program_id             NUMBER ;
   l_program_login_id       NUMBER ;
   l_program_application_id NUMBER ;
   l_request_id             NUMBER ;

   l_stmnt_id      NUMBER := 0;
   l_run_date      DATE;
   l_proc_name     VARCHAR2(30);
   l_status        VARCHAR2(30) ;
   l_industry      VARCHAR2(30) ;

   l_significant_process varchar2(1);
   l_key_control varchar2(1);
begin
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
   DELETE FROM rci_dr_inc where fact_name = 'RCI_COMPL_ENV_CHG_SUMM_F';


   -- change the following line to have schema.tablename
   l_stmnt_id := 20;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_COMPL_ENV_CHG_SUMM_F');

   l_stmnt_id := 25;
   l_run_date := sysdate - 5/(24*60);


   l_stmnt_id := 30;
   insert into rci_compl_env_chg_summ_f(
      fin_certification_id,
	  cert_status,
	  cert_type,
	  cert_period_name,
	  cert_period_set_name,
	  statement_group_id,
	  financial_statement_id,
	  financial_item_id,
	  account_group_id,
	  natural_account_id,
	  organization_id,
	  process_id,
	  revision_number,
	  latest_appr_revision_number,
	  NEW_REVISIONS_SINCE,
	  REVISED_PROCESS,
	  Total_Risks,
	  Num_Changed_Risks,
	  Total_Controls,
	  Num_Changed_Controls,
	  period_year,
	  period_num,
	  quarter_num,
	  ent_period_id,
	  ent_qtr_id,
	  ent_year_id,
	  report_date_julian,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login) /*02.02.2006 npanandi: added distinct below*/
	  (select distinct sc.fin_certification_id,
	  		  b.certification_status,
			  b.certification_type,
			  b.certification_period_name,
			  b.certification_period_set_name,
			  /*02.02.2006 npanandi: not using the below columns for performance reasons*/
			  /*sc.statement_group_id,*/ -1000,
			  /*sc.financial_statement_id,*/ -1000,
			  /*sc.financial_item_id,*/ -1000,
			  /*sc.account_group_id,*/ -1000,
			  sc.natural_account_id,
			  sc.organization_id,
			  sc.process_id,
			  nvl(peval.revision_number,1),
			  0, 0, 0, 0, 0, 0, 0,
			  agpv.period_year,
			  agpv.period_num,
			  agpv.quarter_num,
			  to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)),
			  to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)),
			  agpv.period_year,
			  to_number(to_char(agpv.end_date,'J')),
	  		  sysdate,
			  G_USER_ID,
			  sysdate,
			  G_USER_ID,
			  G_LOGIN_ID
		 from amw_fin_cert_scope sc,
		      amw_fin_process_eval_sum peval,
			  amw_certification_b b,
			  amw_gl_periods_v agpv
	    where peval.fin_certification_id (+) = sc.fin_certification_id
		  and peval.organization_id (+) = sc.organization_id
		  and peval.process_id (+) = sc.process_id
		  and sc.fin_certification_id = b.certification_id
		  and b.certification_period_name = agpv.period_name
		  and b.certification_period_set_name = agpv.period_set_name);


   l_stmnt_id := 40;
   for cur_rec in cur_f loop
   exit when cur_f%notfound;

    if (cur_rec.organization_id is not null and cur_rec.process_id is not null) then
        l_significant_process := NULL;
        select revision_number, significant_process_flag
          into l_curr_rev_num, l_significant_process
          from amw_process_organization a
         where a.approval_date is not null
           and a.approval_end_date is null
           and process_id = cur_rec.process_id
           and organization_id = cur_rec.organization_id;

        select count(risk_id)
          into l_risk_count
          from amw_risk_associations
         where object_type = 'PROCESS_FINCERT'
           and pk1 = cur_rec.fin_certification_id
           and pk2 = cur_rec.organization_id
           and pk3 = cur_rec.process_id;

        select count(control_id)
          into l_control_count
          from amw_control_associations
         where object_type = 'RISK_FINCERT'
           and pk1 = cur_rec.fin_certification_id
           and pk2 = cur_rec.organization_id
           and pk3 = cur_rec.process_id;

		select DECODE(count(ACA.control_id),0,'N','Y')
		  into l_key_control
          from amw_control_associations ACA, AMW_CONTROLS_ALL_VL ACAV
		 where object_type = 'RISK_FINCERT'
		   and pk1 = cur_rec.fin_certification_id
		   and pk2 = cur_rec.organization_id
		   and pk3 = cur_rec.process_id
		   AND ACA.CONTROL_ID = ACAV.CONTROL_ID
		   AND ACAV.CURR_APPROVED_FLAG = 'Y'
		   AND NVL(ACAV.KEY_MITIGATING,'N') = 'Y';

        update rci_compl_env_chg_summ_f
		   set LATEST_APPR_REVISION_NUMBER = l_curr_rev_num,
               /**01.25.2006 npanandi: changed below math, since it results in
			      negative values at times***/
			   /***NEW_REVISIONS_SINCE = latest_appr_revision_number - revision_number,***/
			   NEW_REVISIONS_SINCE = l_curr_rev_num - revision_number,
               /**REVISED_PROCESS = decode(NEW_REVISIONS_SINCE, 0, 0, 1),***/
               REVISED_PROCESS = decode((l_curr_rev_num - revision_number), 0, 0, 1),
               Total_Risks = l_risk_count,
               Total_Controls = l_control_count,
               Num_Changed_Risks = calculate_risks_chg(cur_rec.fin_certification_id,
                                                cur_rec.organization_id,
                                                cur_rec.process_id),
               Num_Changed_Controls = calculate_cntrl_chg(cur_rec.fin_certification_id,
                                                cur_rec.organization_id,
                                                cur_rec.process_id),
			   significant_process = NVL(l_significant_process,'N'),
			   key_control = l_key_control
         where fin_certification_id = cur_rec.fin_certification_id
           and organization_id = cur_rec.organization_id
           and process_id = cur_rec.process_id;


    end if;
end loop;

   l_stmnt_id :=50;
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
	 'RCI_COMPL_ENV_CHG_SUMM_F'
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

	 ----dbms_output.put_line( '6 **************' );
   l_stmnt_id := 70;
   commit;
   retcode := C_OK;

end initial_load;


-- currently incremental - initial, this needs to be reviewed
procedure incremental_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER)
is
   /*02.02.2006 npanandi: changed below cursor for performance reasons
   cursor cur_f is
   select * from rci_compl_env_chg_summ_f;
   */
   cursor cur_f is
      select distinct fin_certification_id,organization_id,process_id
        from rci_compl_env_chg_summ_f
       where organization_id is not null
	     and process_id is not null;

   cur_rec cur_f%rowtype;

   l_curr_rev_num number;
   l_risk_count number;
   l_control_count number;

   l_stmnt_id      NUMBER := 0;
   l_run_date      DATE;
   l_last_run_date DATE;
   l_proc_name     VARCHAR2(30);
   l_message	   VARCHAR2(30);
   l_count		   NUMBER;

   l_user_id                NUMBER;
   l_login_id               NUMBER;
   l_program_id             NUMBER;
   l_program_login_id       NUMBER;
   l_program_application_id NUMBER;
   l_request_id             NUMBER;

   l_significant_process varchar2(1);
   l_key_control varchar2(1);
begin

/***
initial_load(
   errbuf    => errbuf
  ,retcode   => retcode);
***/
   l_user_id                := NVL(fnd_global.USER_ID, -1);
   l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
   l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
   l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
   l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
   l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);

   l_stmnt_id := 10;
   l_proc_name := 'run_incr_load_drm';
   l_last_run_date := get_last_run_date('RCI_COMPL_ENV_CHG_SUMM_F');

   IF l_last_run_date IS NULL THEN
      l_message := 'Please launch the Initial Load Request Set for the Compliance Environment Change Summary page.';
      RAISE INITIALIZATION_ERROR;
   END IF;

   l_stmnt_id := 20;
   l_run_date := sysdate - 5/(24*60);

   l_stmnt_id := 30;
   /** 01.16.06 npanandi: added below procedure cal as RSG errors otherwise **/
   check_initial_load_setup(
      x_global_start_date => g_global_start_date
     ,x_rci_schema        => g_rci_schema);
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_COMPL_ENV_CHG_SUMM_F');


   /*** initial load query comes here ***/
   l_stmnt_id := 30;
   insert into rci_compl_env_chg_summ_f(
      fin_certification_id,
	  cert_status,
	  cert_type,
	  cert_period_name,
	  cert_period_set_name,
	  statement_group_id,
	  financial_statement_id,
	  financial_item_id,
	  account_group_id,
	  natural_account_id,
	  organization_id,
	  process_id,
	  revision_number,
	  latest_appr_revision_number,
	  NEW_REVISIONS_SINCE,
	  REVISED_PROCESS,
	  Total_Risks,
	  Num_Changed_Risks,
	  Total_Controls,
	  Num_Changed_Controls,
	  period_year,
	  period_num,
	  quarter_num,
	  ent_period_id,
	  ent_qtr_id,
	  ent_year_id,
	  report_date_julian,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login) /*02.02.2006 npanandi: added distinct below*/
	  (select distinct sc.fin_certification_id,
	  		  b.certification_status,
			  b.certification_type,
			  b.certification_period_name,
			  b.certification_period_set_name,
			  /*02.02.2006 npanandi: not using the below columns for performance reasons*/
			  /*sc.statement_group_id,*/ -1000,
			  /*sc.financial_statement_id,*/ -1000,
			  /*sc.financial_item_id,*/ -1000,
			  /*sc.account_group_id,*/ -1000,
			  sc.natural_account_id,
			  sc.organization_id,
			  sc.process_id,
			  nvl(peval.revision_number,1),
			  0, 0, 0, 0, 0, 0, 0,
			  agpv.period_year,
			  agpv.period_num,
			  agpv.quarter_num,
			  to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)),
			  to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)),
			  agpv.period_year,
			  to_number(to_char(agpv.end_date,'J')),
	  		  sysdate,
			  G_USER_ID,
			  sysdate,
			  G_USER_ID,
			  G_LOGIN_ID
		 from amw_fin_cert_scope sc,
		      amw_fin_process_eval_sum peval,
			  amw_certification_b b,
			  amw_gl_periods_v agpv
	    where peval.fin_certification_id (+) = sc.fin_certification_id
		  and peval.organization_id (+) = sc.organization_id
		  and peval.process_id (+) = sc.process_id
		  and sc.fin_certification_id = b.certification_id
		  and b.certification_period_name = agpv.period_name
		  and b.certification_period_set_name = agpv.period_set_name);


   l_stmnt_id := 40;
   for cur_rec in cur_f loop
   exit when cur_f%notfound;

    if (cur_rec.organization_id is not null and cur_rec.process_id is not null) then
        l_significant_process := NULL;
        select revision_number, significant_process_flag
          into l_curr_rev_num, l_significant_process
          from amw_process_organization a
         where a.approval_date is not null
           and a.approval_end_date is null
           and process_id = cur_rec.process_id
           and organization_id = cur_rec.organization_id;

        select count(risk_id)
          into l_risk_count
          from amw_risk_associations
         where object_type = 'PROCESS_FINCERT'
           and pk1 = cur_rec.fin_certification_id
           and pk2 = cur_rec.organization_id
           and pk3 = cur_rec.process_id;

        select count(control_id)
          into l_control_count
          from amw_control_associations
         where object_type = 'RISK_FINCERT'
           and pk1 = cur_rec.fin_certification_id
           and pk2 = cur_rec.organization_id
           and pk3 = cur_rec.process_id;

		select DECODE(count(ACA.control_id),0,'N','Y')
		  into l_key_control
          from amw_control_associations ACA, AMW_CONTROLS_ALL_VL ACAV
		 where object_type = 'RISK_FINCERT'
		   and pk1 = cur_rec.fin_certification_id
		   and pk2 = cur_rec.organization_id
		   and pk3 = cur_rec.process_id
		   AND ACA.CONTROL_ID = ACAV.CONTROL_ID
		   AND ACAV.CURR_APPROVED_FLAG = 'Y'
		   AND NVL(ACAV.KEY_MITIGATING,'N') = 'Y';

        update rci_compl_env_chg_summ_f
		   set LATEST_APPR_REVISION_NUMBER = l_curr_rev_num,
               /**01.25.2006 npanandi: changed below math, since it results in
			      negative values at times***/
			   /***NEW_REVISIONS_SINCE = latest_appr_revision_number - revision_number,***/
			   NEW_REVISIONS_SINCE = l_curr_rev_num - revision_number,
               REVISED_PROCESS = decode(NEW_REVISIONS_SINCE, 0, 0, 1),
               Total_Risks = l_risk_count,
               Total_Controls = l_control_count,
               Num_Changed_Risks = calculate_risks_chg(cur_rec.fin_certification_id,
                                                cur_rec.organization_id,
                                                cur_rec.process_id),
               Num_Changed_Controls = calculate_cntrl_chg(cur_rec.fin_certification_id,
                                                cur_rec.organization_id,
                                                cur_rec.process_id),
			   significant_process = NVL(l_significant_process,'N'),
			   key_control = l_key_control
         where fin_certification_id = cur_rec.fin_certification_id
           and organization_id = cur_rec.organization_id
           and process_id = cur_rec.process_id;


    end if;
   end loop;
   /*** initial load query ends here ***/

   l_stmnt_id :=50;

   UPDATE rci_dr_inc
      SET last_run_date		        = l_run_date
         ,last_update_date          = sysdate
	     ,last_updated_by           = l_user_id
         ,last_update_login         = l_login_id
         ,program_id                = l_program_id
         ,program_login_id          = l_program_login_id
         ,program_application_id    = l_program_application_id
         ,request_id                = l_request_id
    WHERE fact_name                 = 'RCI_COMPL_ENV_CHG_SUMM_F' ;

   commit;
   retcode := C_OK;
EXCEPTION
   WHEN OTHERS THEN
      retcode := C_ERROR;
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM || ':' || l_message, l_proc_name, l_stmnt_id));
      ROLLBACK;
      RAISE;
end incremental_load;


-- this function copmares the risks that were attached to an org-process
-- when the certification was created to the current list of risks.
-- the number returned is the sum of risks deleted and risks added.
-- Note that if a risk is deleted and added back, it may create revisions
-- but won't show up here. Also, if risk association attributes are changed,
-- process will get revised, as internally it'll be risk deleted+added,
-- but that won't show up here either. This is to keep the code
-- simple, and functionally, I feel this makes sense.
function calculate_risks_chg(cert_id in number,
                             org_id in number,
                             process_id in number) return number
is
   l_cnt1 number;
   l_cnt2 number;
begin
   select count(risk_id)
     into l_cnt1
     from amw_risk_associations
    where object_type = 'PROCESS_FINCERT'
      and pk1 = cert_id
      and pk2 = org_id
      and pk3 = process_id
      and risk_id not in (select risk_id
                            from amw_risk_associations
        				   where object_type = 'PROCESS_ORG'
        				   	 and pk1 = org_id
        					 and pk2 = process_id
        					 and approval_date is not null
        					 and deletion_approval_date is null);


   select count(risk_id)
     into l_cnt2
     from amw_risk_associations
    where object_type = 'PROCESS_ORG'
      and pk1 = org_id
	  and pk2 = process_id
	  and approval_date is not null
	  and deletion_approval_date is null
	  and risk_id not in (select risk_id
                            from amw_risk_associations
                           where object_type = 'PROCESS_FINCERT'
                             and pk1 = cert_id
        					 and pk2 = org_id
        					 and pk3 = process_id);

   return l_cnt1+l_cnt2;
end calculate_risks_chg;

-- the same concept as calculate_risks_chg
function calculate_cntrl_chg(cert_id in number,
                             org_id in number,
                             process_id in number) return number
is
   l_cnt1 number;
   l_cnt2 number;
begin
   select count(control_id)
     into l_cnt1
     from amw_control_associations
    where object_type = 'RISK_FINCERT'
      and pk1 = cert_id
	  and pk2 = org_id
	  and pk3 = process_id
	  and control_id not in (select control_id
          			 	 	   from amw_control_associations
        					  where object_type = 'RISK_ORG'
        					    and pk1 = org_id
        						and pk2 = process_id
        						and approval_date is not null
        						and deletion_approval_date is null);

   select count(control_id)
     into l_cnt2
	 from amw_control_associations
    where object_type = 'RISK_ORG'
      and pk1 = org_id
	  and pk2 = process_id
	  and approval_date is not null
	  and deletion_approval_date is null
	  and control_id not in (select control_id
          			 	 	   from amw_control_associations
        					  where object_type = 'RISK_FINCERT'
                                and pk1 = cert_id
        						and pk2 = org_id
        						and pk3 = process_id);

   return l_cnt1+l_cnt2;
end calculate_cntrl_chg;



PROCEDURE         get_summ_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
is

l_query0 VARCHAR2(32767);
l_query1 VARCHAR2(32767);
l_query2 VARCHAR2(32767);
l_act_sqlstmt varchar2(32767);
where_flag number := 1;
proc varchar2(100);
org varchar2(100);

   v_period   varchar2(100);
   l_bind_rec BIS_QUERY_ATTRIBUTES;
begin
        l_query0 := '';
        l_query1 := '';
        l_query2 := '';

        FOR i in 1..p_param.COUNT LOOP

             IF(p_param(i).parameter_name = 'VIEW_BY' AND
                p_param(i).parameter_id = 'ORGANIZATION+RCI_ORG_AUDIT')  THEN

                    l_query0 :=
                    'select f.organization_id VIEWBYID,
                            (select name from hr_all_organization_units_tl v
                              where v.organization_id= f.organization_id
                                and v.language = userenv(''LANG'')) VIEWBY,
                            count(distinct process_id) RCI_COMP_ENV_MEASURE3,
                            SUM(REVISED_PROCESS) RCI_COMP_ENV_MEASURE2,
                    		sum(NEW_REVISIONS_SINCE) RCI_COMP_ENV_MEASURE1,
                    		decode(count(process_id), 0, null, SUM(REVISED_PROCESS)/count(process_id)*100) RCI_COMP_ENV_MEASURE4,
                    		sum(Total_Risks) RCI_COMP_ENV_ATT1,
                    		sum(Num_Changed_Risks) RCI_COMP_ENV_MEASURE5,
                    		decode(sum(Total_Risks), 0, null, sum(Num_Changed_Risks)/sum(Total_Risks)*100) RCI_COMP_ENV_MEASURE6,
                    		sum(Total_Controls) RCI_COMP_ENV_ATT2,
                    		sum(Num_Changed_Controls) RCI_COMP_ENV_MEASURE7,
                    		decode(sum(Total_Controls), 0, null, sum(Num_Changed_Controls)/sum(Total_Controls)*100) RCI_COMP_ENV_MEASURE8
                       from rci_compl_env_chg_summ_f f, fii_time_day ftd
                      where f.organization_id is not null
                        and f.report_date_julian = ftd.report_date_julian';

                    l_query2 := ' group by f.organization_id ';

             END IF;

             IF(p_param(i).parameter_name = 'VIEW_BY' AND
                p_param(i).parameter_id = 'RCI_BP_CERT+RCI_BP_PROCESS')  THEN

                    l_query0 :=
                    'select f.process_id VIEWBYID,
                            (select display_name from AMW_CURRENT_APPRVD_REV_V v
                              where v.process_id= f.process_id) VIEWBY,
                            count(distinct process_id) RCI_COMP_ENV_MEASURE3,
                    		SUM(REVISED_PROCESS) RCI_COMP_ENV_MEASURE2,
                    		sum(NEW_REVISIONS_SINCE) RCI_COMP_ENV_MEASURE1,
                    		decode(count(process_id), 0, null, SUM(REVISED_PROCESS)/count(process_id)*100) RCI_COMP_ENV_MEASURE4,
                    		sum(Total_Risks) RCI_COMP_ENV_ATT1,
                    		sum(Num_Changed_Risks) RCI_COMP_ENV_MEASURE5,
                    		decode(sum(Total_Risks), 0, null, sum(Num_Changed_Risks)/sum(Total_Risks)*100) RCI_COMP_ENV_MEASURE6,
                    		sum(Total_Controls) RCI_COMP_ENV_ATT2,
                    		sum(Num_Changed_Controls) RCI_COMP_ENV_MEASURE7,
                    		decode(sum(Total_Controls), 0, null, sum(Num_Changed_Controls)/sum(Total_Controls)*100) RCI_COMP_ENV_MEASURE8
                       from rci_compl_env_chg_summ_f f, fii_time_day ftd
                      where f.process_id is not null
                        and f.report_date_julian = ftd.report_date_julian';

                    l_query2 := ' group by f.process_id ';

             END IF;

             IF(p_param(i).parameter_name = 'VIEW_BY' AND
                p_param(i).parameter_id = 'RCI_FS_CERT+RCI_FS_CERT')  THEN

                    l_query0 :=
                    'select f.fin_certification_id VIEWBYID,
                            (select certification_name from amw_certification_vl v
                              where v.certification_id= f.fin_certification_id) VIEWBY,
                    		count(distinct process_id) RCI_COMP_ENV_MEASURE3,
                    		SUM(REVISED_PROCESS) RCI_COMP_ENV_MEASURE2,
                    		sum(NEW_REVISIONS_SINCE) RCI_COMP_ENV_MEASURE1,
                    		decode(count(process_id), 0, null, SUM(REVISED_PROCESS)/count(process_id)*100) RCI_COMP_ENV_MEASURE4,
                    		sum(Total_Risks) RCI_COMP_ENV_ATT1,
                    		sum(Num_Changed_Risks) RCI_COMP_ENV_MEASURE5,
                    		decode(sum(Total_Risks), 0, null, sum(Num_Changed_Risks)/sum(Total_Risks)*100) RCI_COMP_ENV_MEASURE6,
                    		sum(Total_Controls) RCI_COMP_ENV_ATT2,
                    		sum(Num_Changed_Controls) RCI_COMP_ENV_MEASURE7,
                    		decode(sum(Total_Controls), 0, null, sum(Num_Changed_Controls)/sum(Total_Controls)*100) RCI_COMP_ENV_MEASURE8
                       from rci_compl_env_chg_summ_f f, fii_time_day ftd
                      where f.fin_certification_id is not null
                        and f.report_date_julian = ftd.report_date_julian';

                    l_query2 := ' group by f.fin_certification_id';

             END IF;

             IF(p_param(i).parameter_name = 'VIEW_BY' AND
                p_param(i).parameter_id = 'RCI_FINANCIAL_ACCT+RCI_FINANCIAL_ACCT')  THEN

                    l_query0 :=
                    'select f.natural_account_id VIEWBYID,
                            /**(select name from AMW_FIN_KEY_ACCOUNTS_TL tl
                              where tl.ACCOUNT_GROUP_ID= f.ACCOUNT_GROUP_ID
                                and tl.NATURAL_ACCOUNT_ID= f.NATURAL_ACCOUNT_ID
                                and tl.language=userenv('||'''LANG'''||')) VIEWBY,**/
							rsav.value VIEWBY,
                    	    count(distinct process_id) RCI_COMP_ENV_MEASURE3,
                    		SUM(REVISED_PROCESS) RCI_COMP_ENV_MEASURE2,
                    		sum(NEW_REVISIONS_SINCE) RCI_COMP_ENV_MEASURE1,
                    		decode(count(process_id), 0, null, SUM(REVISED_PROCESS)/count(process_id)*100) RCI_COMP_ENV_MEASURE4,
                    		sum(Total_Risks) RCI_COMP_ENV_ATT1,
                    		sum(Num_Changed_Risks) RCI_COMP_ENV_MEASURE5,
                    		decode(sum(Total_Risks), 0, null, sum(Num_Changed_Risks)/sum(Total_Risks)*100) RCI_COMP_ENV_MEASURE6,
                    		sum(Total_Controls) RCI_COMP_ENV_ATT2,
                    		sum(Num_Changed_Controls) RCI_COMP_ENV_MEASURE7,
                    		decode(sum(Total_Controls), 0, null, sum(Num_Changed_Controls)/sum(Total_Controls)*100) RCI_COMP_ENV_MEASURE8
                       from rci_compl_env_chg_summ_f f, fii_time_day ftd, RCI_SIGNIFICANT_ACCT_V rsav
                      where f.account_group_id is not null
                        and f.natural_account_id is not null
						and f.natural_account_id = rsav.id
                        and f.report_date_julian = ftd.report_date_julian';

                    l_query2 := ' group by (rsav.value, f.natural_account_id)';

             END IF;

             IF(p_param(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query1 := l_query1 || ' and fin_certification_id = '||p_param(i).parameter_id;
             END IF;

             IF(p_param(i).parameter_name = 'ORGANIZATION+RCI_ORG_AUDIT' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query1 := l_query1 || ' and organization_id = '||p_param(i).parameter_id;
             END IF;

             IF(p_param(i).parameter_name = 'RCI_BP_CERT+RCI_BP_PROCESS' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query1 := l_query1 || ' and process_id = '||p_param(i).parameter_id;
             END IF;

             IF(p_param(i).parameter_name = 'RCI_FINANCIAL_ACCT+RCI_FINANCIAL_ACCT' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query1 := l_query1 || ' and natural_account_id = '||p_param(i).parameter_id;
             END IF;

             IF(p_param(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_STATUS' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query1 := l_query1 || ' and cert_status = '||p_param(i).parameter_id;
             END IF;

             IF(p_param(i).parameter_name = 'RCI_FS_CERT+RCI_FS_CERT_TYPE' AND
                p_param(i).parameter_id is NOT null)  THEN
                    l_query1 := l_query1 || ' and cert_type = '||p_param(i).parameter_id;
             END IF;


    	  IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM' AND
             p_param(i).parameter_id is NOT null)  THEN
                /***05.05.2006 npanandi: use dynamic binding for time dimensions below
                l_query1 := l_query1 || ' and ftd.ent_period_id = '||p_param(i).parameter_id;
                ***/
                v_period := p_param(i).parameter_id;
                l_query1 := l_query1 || ' and ftd.ent_period_id = :TIME1 ';
          END IF;

    	  IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM' AND
             p_param(i).parameter_id is NOT null)  THEN
                /***05.05.2006 npanandi: use dynamic binding for time dimensions below
                l_query1 := l_query1 || ' and ftd.ent_qtr_id = '||p_param(i).parameter_id;
                **/
                v_period := p_param(i).parameter_id;
                l_query1 := l_query1 || ' and ftd.ent_qtr_id = :TIME1 ';
          END IF;

    	  IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM' AND
             p_param(i).parameter_id is NOT null)  THEN
                /***05.05.2006 npanandi: use dynamic binding for time dimensions below
                l_query1 := l_query1 || ' and ftd.ent_year_id = '||p_param(i).parameter_id;
                **/
                v_period := p_param(i).parameter_id;
                l_query1 := l_query1 || ' and ftd.ent_year_id = :TIME1 ';
          END IF;

		  /** 12.09.2005 npanandi: added below parameter checks -- bug 4862313 fix ***/
		  IF(p_param(i).parameter_name = 'DUMMY+DUMMY_LEVEL' AND
        	     p_param(i).parameter_id is NOT null)  THEN
				 if(p_param(i).parameter_id = 'Y') then
				    l_query1 := l_query1 || ' and significant_process = ''Y''';
				 elsif(p_param(i).parameter_id = 'N') then
				    l_query1 := l_query1 || ' and significant_process = ''N''';
				 end if;
				 ---l_query1 := l_query1 || ' ************ p_param('||i||').parameter_name: '||p_param(i).parameter_name||', p_param('||i||').parameter_id: '||p_param(i).parameter_id;
          END IF;

		  IF(p_param(i).parameter_name = 'DUMMY_DIMENSION+DUMMY_DIMENSION_LEVEL' AND
        	     p_param(i).parameter_id is NOT null)  THEN
				 if(p_param(i).parameter_id = 'Y') then
				    l_query1 := l_query1 || ' and key_control = ''Y''';
				 elsif(p_param(i).parameter_id = 'N') then
				    l_query1 := l_query1 || ' and key_control = ''N''';
				 end if;
				 ---l_query1 := l_query1 || ' ************ p_param('||i||').parameter_name: '||p_param(i).parameter_name||', p_param('||i||').parameter_id: '||p_param(i).parameter_id;
          END IF;
		  /** 12.09.2005 npanandi: ends bug 4862313 fix ***/

        END LOOP;


    /** 09.18.2006 npanandi: added SQL below to handle order_by_clause -- bug 5510667 **/
   l_act_sqlstmt := 'select VIEWBYID,VIEWBY,RCI_COMP_ENV_MEASURE3,RCI_COMP_ENV_MEASURE2
                           ,RCI_COMP_ENV_MEASURE1,RCI_COMP_ENV_MEASURE4,RCI_COMP_ENV_ATT1
						   ,RCI_COMP_ENV_MEASURE5,RCI_COMP_ENV_MEASURE6,RCI_COMP_ENV_ATT2
						   ,RCI_COMP_ENV_MEASURE7,RCI_COMP_ENV_MEASURE8
					   from (select t.*
					               ,(rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last) - 1) col_rank
							   from ( '||l_query0||l_query1||l_query2||'
							 ) t ) a
					   order by a.col_rank ';


    x_custom_sql := l_act_sqlstmt;

    /**05.05.2006 npanandi: adding code for dynamic binding of time period dimensions**/
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    x_custom_output.EXTEND;
    l_bind_rec.attribute_name := ':TIME1';
    l_bind_rec.attribute_value := v_period;
    l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    x_custom_output(x_custom_output.COUNT) := l_bind_rec;
    /**05.05.2006 npanandi: finished code for dynamic binding of time period dimensions**/
end;


end rci_compl_env_chg_summ_pkg;

/
