--------------------------------------------------------
--  DDL for Package Body RCI_ORG_DFCY_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCI_ORG_DFCY_ETL_PKG" AS
--$Header: rciodfcyetlb.pls 120.6.12000000.1 2007/01/16 20:46:24 appldev ship $

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

-- Common Procedures (for initial and incremental load)

/**
FUNCTION get_master_organization_id
RETURN NUMBER;
**/

--  Common Procedures Definitions
--  check_initial_load_setup
--  Gets the GSD.
--  History:
--  Date        Author                 Action
--  09/05/2005  Panandikar Nilesh G    Defined procedure.

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

--  check_incr_load_setup
--  Gets the GSD.
--  History:
--  Date        Author                 Action
--  09/06/2005  Panandikar Nilesh G    Defined procedure.

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


--  err_mesg
--  History:
--  Date        Author                 Action
--  09/06/2005  Panandikar Nilesh G    Defined procedure.

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

--  run_initial_load
--  Parameters:
--  retcode - 0 on successful completion, -1 on error and 1 for warning.
--  errbuf - empty on successful completion, message on error or warning
--
--  History:
--  Date        Author               Action
--  08/31/2005  Nilesh Panandikar    Defined Body.

PROCEDURE initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER)
IS

   cursor c_load_cols is
      select certification_id
	        ,organization_id
			,process_id
	    from rci_org_proc_dfcy_f;

   l_stmnt_id      NUMBER := 0;
   l_run_date      DATE;
   l_proc_name     VARCHAR2(30);
   l_status        VARCHAR2(30) ;
   l_industry      VARCHAR2(30) ;
   l_master_org	MTL_PARAMETERS.MASTER_ORGANIZATION_ID%TYPE;

   l_user_id                NUMBER ;
   l_login_id               NUMBER ;
   l_program_id             NUMBER ;
   l_program_login_id       NUMBER ;
   l_program_application_id NUMBER ;
   l_request_id             NUMBER ;

   l_counter number := 0;
   l_ineffective_controls   number;
   l_unmitigated_risks      number;

   /** 12.12.2005 npanandi: bug 4862301 fix for keyControl **/
   l_key_control			varchar2(2);
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
   DELETE FROM rci_dr_inc where fact_name = 'RCI_ORG_PROC_DFCY_F';

   ----dbms_output.put_line( '2 **************' );

   l_stmnt_id := 20;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_ORG_PROC_DFCY_F');

   ----dbms_output.put_line( '3 **************' );
   l_stmnt_id := 30;
   l_run_date := sysdate - 5/(24*60);

   INSERT INTO RCI_ORG_PROC_DFCY_F(
      project_id
	 ,fin_certification_id
     ,certification_id
     ,certification_status
     ,certification_type
     ,certification_period_name
     ,certification_period_set_name
     ,organization_id
	 ,process_id
	 ,significant_process_flag
	 ,standard_process_flag
	 ,certification_result_code
	 ,certified_by_id
	 ,evaluation_result_code
	 ,last_evaluated_by_id
	 ,last_evaluated_on
	 ,unmitigated_risks
	 ,ineffective_controls
	 ,natural_account_id
	 /** 10.20.2005 npanandi begin ***/
	 ,period_year
	 ,period_num
	 ,quarter_num
	 ,ent_period_id
	 ,ent_qtr_id
	 ,ent_year_id
	 ,report_date_julian
	 /** 10.20.2005 npanandi end ***/
	 ,creation_date
	 ,created_by
	 ,last_update_date
	 ,last_updated_by
	 ,last_update_login
	 ---,unmitigated_risks hold on to these for now
	 ---,ineffective_controls
	 ) select distinct aolv2.pk2_value /*project_id*/
      ,afpes.fin_certification_id
      ,-10000 /*certification_id*/
      ,acb.certification_status
      ,acb.certification_type
      ,acb.certification_period_name
      ,acb.certification_period_set_name
      ,afpes.organization_id
      ,afpes.process_id
      ,upper(nvl(alrv.significant_process_flag,'N'))
      ,upper(nvl(alrv.standard_process_flag,'N'))
      ,aolv1.audit_result_code /*certification_result_code*/
      ,aolv1.authored_by /*certified_by_id*/
      ,aolv2.audit_result_code /*evaluation_result_code*/
      ,aolv2.authored_by /*last_evaluated_by_id*/
      ,aolv2.authored_date /*last_evaluated_on*/
      ,null /*unmitigated_risks*/
      ,null /*ineffective_controls*/
      ,afkav.natural_account_id
      ,agpv.period_year /*period_year*/
      ,agpv.period_num /*period_num*/
      ,agpv.quarter_num /*quarter_num*/
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)) /*ent_period_id*/
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)) /*ent_qtr_id*/
      ,agpv.period_year /*ent_year_id*/
      ,to_number(to_char(agpv.end_date,'J')) /*report_date_julian*/
      ,sysdate
	  ,G_USER_ID
	  ,sysdate
	  ,G_USER_ID
	  ,G_LOGIN_ID
  from amw_fin_process_eval_sum afpes
      ,amw_certification_b acb
      ,amw_latest_revisions_v alrv
      ,amw_opinions_log_v aolv1
      ,amw_opinions_log_v aolv2
      ,(select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa
	  ,AMW_FIN_KEY_ACCOUNTS_VL AFKAV
	  ,amw_gl_periods_v agpv
 where afpes.fin_certification_id = acb.certification_id
   and afpes.process_id = alrv.process_id
   and afpes.cert_opinion_log_id = aolv1.opinion_log_id(+)
   and afpes.eval_opinion_log_id = aolv2.opinion_log_id(+)
   and aaa.pk1(+) = afpes.organization_id
   and aaa.pk2(+) = afpes.process_id
   and aaa.natural_account_id = afkav.natural_account_id(+)
   and acb.certification_period_name = agpv.period_name
   and acb.certification_period_set_name = agpv.period_set_name
   and exists (SELECT DISTINCT ctrls.pk1 as certification_id /*fin_certification_id*/
      	 	   ,o.organization_id
               ,all_ctrls.control_id
		       ,op.audit_result_code
			   ,op.authored_by /*last_evaluated_by_id*/
			   ,op.authored_date /*last_evaluated_on*/
		  	   ,(select /*aov.OPINION_VALUE_NAME*/ aov.opinion_value_id from AMW_OPINION_LOG_DETAILS aod, AMW_OPINION_VALUES_TL aov
	           	  WHERE aov.language=userenv('LANG') and op.OPINION_LOG_ID = aod.OPINION_LOG_ID
			   	  	and aod.OPINION_VALUE_ID = aov.OPINION_VALUE_ID
			   		and aod.OPINION_COMPONENT_ID = (select OPINION_COMPONENT_ID from AMW_OPINION_COMPONTS_B
	                                               	 where OBJECT_OPINION_TYPE_ID = op.OBJECT_OPINION_TYPE_ID
												  	   and OPINION_COMPONENT_CODE = 'OPERATING')) op_eff_id
	      	   ,(select /*aov.OPINION_VALUE_NAME*/ aov.opinion_value_id from AMW_OPINION_LOG_DETAILS aod, AMW_OPINION_VALUES_TL aov
	           	  WHERE aov.language=userenv('LANG') and op.OPINION_LOG_ID = aod.OPINION_LOG_ID
			   	    and aod.OPINION_VALUE_ID = aov.OPINION_VALUE_ID
			   		and aod.OPINION_COMPONENT_ID = (select OPINION_COMPONENT_ID from AMW_OPINION_COMPONTS_B
	                                                 where OBJECT_OPINION_TYPE_ID = op.OBJECT_OPINION_TYPE_ID
												  	   and OPINION_COMPONENT_CODE = 'DESIGN')) des_eff_id
	       FROM AMW_CONTROL_ASSOCIATIONS ctrls,
	            AMW_CONTROLS_ALL_VL all_ctrls,
		        HR_ALL_ORGANIZATION_UNITS o,
		        HR_ALL_ORGANIZATION_UNITS_TL otl,
		        AMW_OPINIONS_LOG_V op
		  WHERE ctrls.object_type = 'RISK_FINCERT'
		    and ctrls.control_rev_id = all_ctrls.control_rev_id
		    and all_ctrls.APPROVAL_STATUS = 'A'
		    and o.organization_id = ctrls.pk2
		    and o.organization_id = otl.organization_id
		    and otl.language = userenv('LANG')
		    and op.opinion_log_id(+)  = ctrls.pk5
		    and op.AUDIT_RESULT_CODE <> 'EFFECTIVE'
		    AND ctrls.pk1 = afpes.fin_certification_id
		    and o.ORGANIZATION_ID = afpes.organization_id
			and ctrls.pk3 = afpes.process_id);
			/****select distinct aov2.pk2_value ---project_id
      ,aca.pk1 --fin_certified_id
      ,-10000 --certification_id
      ,acb.certification_status
      ,acb.certification_type
      ,acb.certification_period_name
      ,acb.certification_period_set_name
      ,haou.organization_id
      ,alrv.process_id
      ,nvl(alrv.significant_process_flag,'N')
      ,nvl(alrv.standard_process_flag,'N')
      ,aov1.audit_result_code --certification_result_code
      ,aov1.authored_by --certified_by_id
      ,aov2.audit_result_code --evaluation_result_code
      ,aov2.authored_by --last_evaluated_by_id
      ,aov2.authored_date --last_evaluated_on
      ,null --unmitigated_risks
      ,null --ineffective_controls
	  ,afkav.natural_account_id
      ,agpv.period_year --period_year
      ,agpv.period_num --period_num
      ,agpv.quarter_num --quarter_num
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)) --ent_period_id
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)) --ent_qtr_id
      ,agpv.period_year --ent_year_id
      ,to_number(to_char(agpv.end_date,'J')) --report_date_julian
	  ,sysdate
	  ,G_USER_ID
	  ,sysdate
	  ,G_USER_ID
	  ,G_LOGIN_ID
  from amw_control_associations aca
      ,amw_opinions_log_v aolv
      ,amw_latest_revisions_v alrv
      ,HR_ALL_ORGANIZATION_UNITS haou
      ,HR_ALL_ORGANIZATION_UNITS_TL haout
      ,amw_opinions_v aov1
      ,amw_opinions_v aov2
      ,amw_certification_b acb
      ,(select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa
	  ,AMW_FIN_KEY_ACCOUNTS_VL AFKAV
	  ,amw_gl_periods_v agpv
 where aca.object_type='RISK_FINCERT'
   and aca.pk5=aolv.opinion_log_id
   and aca.pk3=alrv.process_id
   and aca.pk2=haou.organization_id
   and haou.organization_id=haout.organization_id
   and haout.language=userenv('LANG')
   and aov1.opinion_type_code='CERTIFICATION'
   and aov1.object_name='AMW_ORG_PROCESS'
   and aov1.pk1_value=alrv.process_id
   and aov1.pk3_value=aca.pk2
   and aov2.opinion_type_code='EVALUATION'
   and aov2.object_name='AMW_ORG_PROCESS'
   and aov2.pk1_value=alrv.process_id
   and aov2.pk3_value=aca.pk2
   and aca.pk1=acb.certification_id
   and aaa.pk1(+) = aca.pk2
   and aaa.pk2(+) = aca.pk3
   and aaa.natural_account_id = afkav.natural_account_id(+)
   and acb.certification_period_name = agpv.period_name
   and acb.certification_period_set_name = agpv.period_set_name
   and aov2.authored_date in (select max(aov.authored_date)
                       from AMW_OPINIONS aov
                       where aov.object_opinion_type_id = aov2.object_opinion_type_id
                       and aov.pk1_value = aov2.pk1_value
                       and aov.pk3_value = aov2.pk3_value);***/


   for r_load_cols in c_load_cols loop
      ----dbms_output.put_line( '' );
      if(r_load_cols.certification_id is not null and
	     r_load_cols.organization_id is not null and
		 r_load_cols.process_id is not null) then
         OPEN c_unmitigated_risks(r_load_cols.certification_id
	                             ,r_load_cols.organization_id
			   	     		     ,r_load_cols.process_id);
            FETCH c_unmitigated_risks INTO l_unmitigated_risks;
         CLOSE c_unmitigated_risks;

		 OPEN c_ineffective_controls(r_load_cols.certification_id
	                             ,r_load_cols.organization_id
			   	     		     ,r_load_cols.process_id);
            FETCH c_ineffective_controls INTO l_ineffective_controls;
         CLOSE c_ineffective_controls;

		 /** 12.12.2005 npanandi: added below for key_control
		                          bug 4862301 fix
			**/
		 SELECT decode(count(aca.control_id),0,'N','Y')
		   into l_key_control
           FROM amw_control_associations aca
      	   	   ,amw_controls_b acb
		  WHERE aca.object_type = 'BUSIPROC_CERTIFICATION'
		    AND aca.pk1 = r_load_cols.certification_id
		    AND aca.pk2 = r_load_cols.organization_id
		    AND aca.pk3 IN (SELECT DISTINCT process_id
			 	 		  	  FROM amw_execution_scope
			 	 		  	 START WITH process_id = r_load_cols.process_id
			 	 		  	   AND organization_id = r_load_cols.organization_id
			 	 		  	   AND entity_id = r_load_cols.certification_id
							   and entity_type='BUSIPROC_CERTIFICATION'
			 	 		   CONNECT BY PRIOR process_id = parent_process_id
			 	 		       AND organization_id = PRIOR organization_id
			 	 		  	   AND entity_id = PRIOR entity_id
							   and entity_type=prior entity_type)
		    and aca.control_id = acb.control_id
		    and acb.curr_approved_flag = 'Y'
		    and nvl(acb.key_mitigating,'N') = 'Y';
	     /** 12.12.2005 npanandi: ends bug 4862301 fix **/
      end if;

	  update RCI_ORG_PROC_DFCY_F
	     set unmitigated_risks = l_unmitigated_risks
		    ,ineffective_controls = l_ineffective_controls
			/** 12.12.2005 npanandi: bug 4862301 fix for keyControl **/
			,key_control = l_key_control
	   where certification_id = r_load_cols.certification_id
	     and organization_id = r_load_cols.organization_id
		 and process_id = r_load_cols.process_id;
   end loop;


   ----dbms_output.put_line( '4 **************' );

   l_stmnt_id :=50;

   ----dbms_output.put_line( '5 **************' );

   l_stmnt_id :=60;
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
	 'RCI_ORG_PROC_DFCY_F'
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
EXCEPTION
   WHEN OTHERS THEN
      retcode := C_ERROR;
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name, l_stmnt_id));
      ROLLBACK;
      RAISE;
END initial_load;


PROCEDURE initial_load_obsolete(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER)
IS

   cursor c_load_cols is
      select certification_id
	        ,organization_id
			,process_id
	    from rci_org_proc_dfcy_f;

   l_stmnt_id      NUMBER := 0;
   l_run_date      DATE;
   l_proc_name     VARCHAR2(30);
   l_status        VARCHAR2(30) ;
   l_industry      VARCHAR2(30) ;
   l_master_org	MTL_PARAMETERS.MASTER_ORGANIZATION_ID%TYPE;

   l_user_id                NUMBER ;
   l_login_id               NUMBER ;
   l_program_id             NUMBER ;
   l_program_login_id       NUMBER ;
   l_program_application_id NUMBER ;
   l_request_id             NUMBER ;

   l_counter number := 0;
   l_ineffective_controls   number;
   l_unmitigated_risks      number;

   /** 12.12.2005 npanandi: bug 4862301 fix for keyControl **/
   l_key_control			varchar2(2);
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
   DELETE FROM rci_dr_inc where fact_name = 'RCI_ORG_PROC_DFCY_F';

   ----dbms_output.put_line( '2 **************' );

   l_stmnt_id := 20;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_ORG_PROC_DFCY_F');

   ----dbms_output.put_line( '3 **************' );
   l_stmnt_id := 30;
   l_run_date := sysdate - 5/(24*60);

   INSERT INTO RCI_ORG_PROC_DFCY_F(
      project_id
	 ,fin_certification_id
     ,certification_id
     ,certification_status
     ,certification_type
     ,certification_period_name
     ,certification_period_set_name
     ,organization_id
	 ,process_id
	 ,significant_process_flag
	 ,standard_process_flag
	 ,certification_result_code
	 ,certified_by_id
	 ,evaluation_result_code
	 ,last_evaluated_by_id
	 ,last_evaluated_on
	 ,natural_account_id
	 /** 10.20.2005 npanandi begin ***/
	 ,period_year
	 ,period_num
	 ,quarter_num
	 ,ent_period_id
	 ,ent_qtr_id
	 ,ent_year_id
	 ,report_date_julian
	 /** 10.20.2005 npanandi end ***/
	 ,creation_date
	 ,created_by
	 ,last_update_date
	 ,last_updated_by
	 ,last_update_login
	 ---,unmitigated_risks hold on to these for now
	 ---,ineffective_controls
	 ) SELECT distinct aapv.AUDIT_PROJECT_ID,
	          acv2.certification_id,
	          execs.entity_id,
		      acv.CERTIFICATION_STATUS,
		      acv.CERTIFICATION_TYPE,
		      acv.CERTIFICATION_PERIOD_NAME,
		      acv.CERTIFICATION_PERIOD_SET_NAME,
	          execs.organization_id,
	          execs.process_id,
	          nvl(process.significant_process_flag,'N'),
	          nvl(process.standard_process_flag,'N'),
		      opinions_cert.audit_result_code,
	          opinions_cert.authored_by,
	          opinions_eval.audit_result_code,
	          opinions_eval.AUTHORED_BY,
	          opinions_eval.authored_date,
	          afkav.natural_account_id,
			  /** 10.20.2005 npanandi begin ***/
	          agpv.period_year,
      		  agpv.period_num,
      		  agpv.quarter_num,
      		  to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)),
      		  to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)),
      		  agpv.period_year,
      		  to_number(to_char(agpv.end_date,'J')),
	  		  /** 10.20.2005 npanandi end ***/
	  	  	  sysdate,
			  G_USER_ID,
			  sysdate,
			  G_USER_ID,
			  G_LOGIN_ID
	     FROM amw_proc_cert_eval_sum proccert,
	          amw_opinions_log_v opinions_eval,
	          amw_opinions_v opinions_cert,
	          amw_process_organization_vl process,
	          amw_execution_scope execs,
	          amw_audit_units_v audit_v,
	          amw_audit_projects_v aapv,
		      amw_certification_vl acv,
		      amw_certification_vl acv2,
		      AMW_FIN_PROC_CERT_RELAN afpcr,
		      (select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa,
		      AMW_FIN_KEY_ACCOUNTS_VL AFKAV
			  /** 10.20.2005 npanandi begin ***/
	         ,amw_gl_periods_v agpv
	  		 /** 10.20.2005 npanandi end ***/
	    WHERE execs.entity_id = opinions_cert.pk2_value(+)
	      AND execs.organization_id = opinions_cert.pk3_value(+)
	      AND execs.process_id = opinions_cert.pk1_value(+)
	      AND execs.entity_type = 'BUSIPROC_CERTIFICATION'
	      AND execs.entity_id = proccert.certification_id
	      and acv.CERTIFICATION_ID = proccert.CERTIFICATION_ID
	      and acv.OBJECT_TYPE = 'PROCESS'
	      and aapv.audit_project_id(+) = opinions_eval.pk2_value
	      AND execs.process_org_rev_id = proccert.process_org_rev_id
	      AND opinions_cert.opinion_type_code(+) = 'CERTIFICATION'
	      AND opinions_cert.object_name(+) = 'AMW_ORG_PROCESS'
	      AND proccert.evaluation_opinion_log_id = opinions_eval.opinion_log_id(+)
	      AND process.process_org_rev_id = execs.process_org_rev_id
	      AND process.organization_id = audit_v.organization_id
	      and afpcr.PROC_CERT_ID = acv.CERTIFICATION_ID
	      and afpcr.END_DATE is null
	      and afpcr.FIN_STMT_CERT_ID = acv2.CERTIFICATION_ID
	      and acv2.object_type='FIN_STMT'
	      and aaa.pk1(+) = execs.organization_id
	      and aaa.pk2(+) = execs.process_id
	      and aaa.natural_account_id = afkav.natural_account_id(+)
		  /** 10.20.2005 npanandi begin ***/
	      and acv.certification_period_name = agpv.period_name
	      and acv.certification_period_set_name = agpv.period_set_name;
	      /** 10.20.2005 npanandi end ***/

   for r_load_cols in c_load_cols loop
      ----dbms_output.put_line( '' );
      if(r_load_cols.certification_id is not null and
	     r_load_cols.organization_id is not null and
		 r_load_cols.process_id is not null) then
         OPEN c_unmitigated_risks(r_load_cols.certification_id
	                             ,r_load_cols.organization_id
			   	     		     ,r_load_cols.process_id);
            FETCH c_unmitigated_risks INTO l_unmitigated_risks;
         CLOSE c_unmitigated_risks;

		 OPEN c_ineffective_controls(r_load_cols.certification_id
	                             ,r_load_cols.organization_id
			   	     		     ,r_load_cols.process_id);
            FETCH c_ineffective_controls INTO l_ineffective_controls;
         CLOSE c_ineffective_controls;

		 /** 12.12.2005 npanandi: added below for key_control
		                          bug 4862301 fix
			**/
		 SELECT decode(count(aca.control_id),0,'N','Y')
		   into l_key_control
           FROM amw_control_associations aca
      	   	   ,amw_controls_b acb
		  WHERE aca.object_type = 'BUSIPROC_CERTIFICATION'
		    AND aca.pk1 = r_load_cols.certification_id
		    AND aca.pk2 = r_load_cols.organization_id
		    AND aca.pk3 IN (SELECT DISTINCT process_id
			 	 		  	  FROM amw_execution_scope
			 	 		  	 START WITH process_id = r_load_cols.process_id
			 	 		  	   AND organization_id = r_load_cols.organization_id
			 	 		  	   AND entity_id = r_load_cols.certification_id
							   and entity_type='BUSIPROC_CERTIFICATION'
			 	 		   CONNECT BY PRIOR process_id = parent_process_id
			 	 		       AND organization_id = PRIOR organization_id
			 	 		  	   AND entity_id = PRIOR entity_id
							   and entity_type=prior entity_type)
		    and aca.control_id = acb.control_id
		    and acb.curr_approved_flag = 'Y'
		    and nvl(acb.key_mitigating,'N') = 'Y';
	     /** 12.12.2005 npanandi: ends bug 4862301 fix **/
      end if;

	  update RCI_ORG_PROC_DFCY_F
	     set unmitigated_risks = l_unmitigated_risks
		    ,ineffective_controls = l_ineffective_controls
			/** 12.12.2005 npanandi: bug 4862301 fix for keyControl **/
			,key_control = l_key_control
	   where certification_id = r_load_cols.certification_id
	     and organization_id = r_load_cols.organization_id
		 and process_id = r_load_cols.process_id;
   end loop;


   ----dbms_output.put_line( '4 **************' );

   l_stmnt_id :=50;

   ----dbms_output.put_line( '5 **************' );

   l_stmnt_id :=60;
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
	 'RCI_ORG_PROC_DFCY_F'
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
EXCEPTION
   WHEN OTHERS THEN
      retcode := C_ERROR;
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_proc_name, l_stmnt_id));
      ROLLBACK;
      RAISE;
END initial_load_obsolete;


-- run_incr_load_opm
-- Parameters:
-- retcode - 0 on successful completion, -1 on error and 1 for warning.
-- errbuf - empty on successful completion, message on error or warning
--
-- History:
-- Date        Author                 Action
-- 09/06/2005  Panandikar Nilesh G    Defined Body.

PROCEDURE incr_load(
   errbuf  in out NOCOPY VARCHAR2
  ,retcode in out NOCOPY NUMBER)
IS
   cursor c_load_cols is
      select certification_id
	        ,organization_id
			,process_id
	    from rci_org_proc_dfcy_f;

   l_stmnt_id      NUMBER := 0;
   l_run_date      DATE;
   l_last_run_date DATE;
   l_proc_name     VARCHAR2(30);
   l_message	   VARCHAR2(30);
   l_master_org    MTL_PARAMETERS.MASTER_ORGANIZATION_ID%TYPE;
   l_count		   NUMBER;

   l_user_id                NUMBER;
   l_login_id               NUMBER;
   l_program_id             NUMBER;
   l_program_login_id       NUMBER;
   l_program_application_id NUMBER;
   l_request_id             NUMBER;

   l_unmitigated_risks      number;
   l_ineffective_controls   number;

   /** 12.12.2005 npanandi: bug 4862301 fix for keyControl **/
   l_key_control			varchar2(2);
BEGIN
   l_user_id                := NVL(fnd_global.USER_ID, -1);
   l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
   l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
   l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
   l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
   l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);

   l_stmnt_id := 10;
   l_proc_name := 'run_incr_load_drm';
   l_last_run_date := get_last_run_date('RCI_ORG_PROC_DFCY_F');

   IF l_last_run_date IS NULL THEN
      l_message := 'Please launch the Initial Load Request Set for the Organization Certification Summary page.';
      RAISE INITIALIZATION_ERROR;
   END IF;

   l_stmnt_id := 20;
   l_run_date := sysdate - 5/(24*60);
   ---l_master_org  := get_master_organization_id;

   l_stmnt_id := 30;
   /** 01.16.06 npanandi: added below procedure cal as RSG errors otherwise **/
   check_initial_load_setup(
      x_global_start_date => g_global_start_date
     ,x_rci_schema        => g_rci_schema);
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_ORG_PROC_DFCY_F');

   l_stmnt_id := 40;

   INSERT INTO RCI_ORG_PROC_DFCY_F(
      project_id
	 ,fin_certification_id
     ,certification_id
     ,certification_status
     ,certification_type
     ,certification_period_name
     ,certification_period_set_name
     ,organization_id
	 ,process_id
	 ,significant_process_flag
	 ,standard_process_flag
	 ,certification_result_code
	 ,certified_by_id
	 ,evaluation_result_code
	 ,last_evaluated_by_id
	 ,last_evaluated_on
	 ,unmitigated_risks
	 ,ineffective_controls
	 ,natural_account_id
	 /** 10.20.2005 npanandi begin ***/
	 ,period_year
	 ,period_num
	 ,quarter_num
	 ,ent_period_id
	 ,ent_qtr_id
	 ,ent_year_id
	 ,report_date_julian
	 /** 10.20.2005 npanandi end ***/
	 ,creation_date
	 ,created_by
	 ,last_update_date
	 ,last_updated_by
	 ,last_update_login
	 ---,unmitigated_risks hold on to these for now
	 ---,ineffective_controls
	 ) select distinct aolv2.pk2_value /*project_id*/
      ,afpes.fin_certification_id
      ,-10000 /*certification_id*/
      ,acb.certification_status
      ,acb.certification_type
      ,acb.certification_period_name
      ,acb.certification_period_set_name
      ,afpes.organization_id
      ,afpes.process_id
      ,upper(nvl(alrv.significant_process_flag,'N'))
      ,upper(nvl(alrv.standard_process_flag,'N'))
      ,aolv1.audit_result_code /*certification_result_code*/
      ,aolv1.authored_by /*certified_by_id*/
      ,aolv2.audit_result_code /*evaluation_result_code*/
      ,aolv2.authored_by /*last_evaluated_by_id*/
      ,aolv2.authored_date /*last_evaluated_on*/
      ,null /*unmitigated_risks*/
      ,null /*ineffective_controls*/
      ,afkav.natural_account_id
      ,agpv.period_year /*period_year*/
      ,agpv.period_num /*period_num*/
      ,agpv.quarter_num /*quarter_num*/
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)) /*ent_period_id*/
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)) /*ent_qtr_id*/
      ,agpv.period_year /*ent_year_id*/
      ,to_number(to_char(agpv.end_date,'J')) /*report_date_julian*/
      ,sysdate
	  ,G_USER_ID
	  ,sysdate
	  ,G_USER_ID
	  ,G_LOGIN_ID
  from amw_fin_process_eval_sum afpes
      ,amw_certification_b acb
      ,amw_latest_revisions_v alrv
      ,amw_opinions_log_v aolv1
      ,amw_opinions_log_v aolv2
      ,(select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa
	  ,AMW_FIN_KEY_ACCOUNTS_VL AFKAV
	  ,amw_gl_periods_v agpv
 where afpes.fin_certification_id = acb.certification_id
   and afpes.process_id = alrv.process_id
   and afpes.cert_opinion_log_id = aolv1.opinion_log_id(+)
   and afpes.eval_opinion_log_id = aolv2.opinion_log_id(+)
   and aaa.pk1(+) = afpes.organization_id
   and aaa.pk2(+) = afpes.process_id
   and aaa.natural_account_id = afkav.natural_account_id(+)
   and acb.certification_period_name = agpv.period_name
   and acb.certification_period_set_name = agpv.period_set_name
   and exists (SELECT DISTINCT ctrls.pk1 as certification_id /*fin_certification_id*/
      	 	   ,o.organization_id
               ,all_ctrls.control_id
		       ,op.audit_result_code
			   ,op.authored_by /*last_evaluated_by_id*/
			   ,op.authored_date /*last_evaluated_on*/
		  	   ,(select /*aov.OPINION_VALUE_NAME*/ aov.opinion_value_id from AMW_OPINION_LOG_DETAILS aod, AMW_OPINION_VALUES_TL aov
	           	  WHERE aov.language=userenv('LANG') and op.OPINION_LOG_ID = aod.OPINION_LOG_ID
			   	  	and aod.OPINION_VALUE_ID = aov.OPINION_VALUE_ID
			   		and aod.OPINION_COMPONENT_ID = (select OPINION_COMPONENT_ID from AMW_OPINION_COMPONTS_B
	                                               	 where OBJECT_OPINION_TYPE_ID = op.OBJECT_OPINION_TYPE_ID
												  	   and OPINION_COMPONENT_CODE = 'OPERATING')) op_eff_id
	      	   ,(select /*aov.OPINION_VALUE_NAME*/ aov.opinion_value_id from AMW_OPINION_LOG_DETAILS aod, AMW_OPINION_VALUES_TL aov
	           	  WHERE aov.language=userenv('LANG') and op.OPINION_LOG_ID = aod.OPINION_LOG_ID
			   	    and aod.OPINION_VALUE_ID = aov.OPINION_VALUE_ID
			   		and aod.OPINION_COMPONENT_ID = (select OPINION_COMPONENT_ID from AMW_OPINION_COMPONTS_B
	                                                 where OBJECT_OPINION_TYPE_ID = op.OBJECT_OPINION_TYPE_ID
												  	   and OPINION_COMPONENT_CODE = 'DESIGN')) des_eff_id
	       FROM AMW_CONTROL_ASSOCIATIONS ctrls,
	            AMW_CONTROLS_ALL_VL all_ctrls,
		        HR_ALL_ORGANIZATION_UNITS o,
		        HR_ALL_ORGANIZATION_UNITS_TL otl,
		        AMW_OPINIONS_LOG_V op
		  WHERE ctrls.object_type = 'RISK_FINCERT'
		    and ctrls.control_rev_id = all_ctrls.control_rev_id
		    and all_ctrls.APPROVAL_STATUS = 'A'
		    and o.organization_id = ctrls.pk2
		    and o.organization_id = otl.organization_id
		    and otl.language = userenv('LANG')
		    and op.opinion_log_id(+)  = ctrls.pk5
		    and op.AUDIT_RESULT_CODE <> 'EFFECTIVE'
		    AND ctrls.pk1 = afpes.fin_certification_id
		    and o.ORGANIZATION_ID = afpes.organization_id
			and ctrls.pk3 = afpes.process_id);

   for r_load_cols in c_load_cols loop
      ----dbms_output.put_line( '' );
      if(r_load_cols.certification_id is not null and
	     r_load_cols.organization_id is not null and
		 r_load_cols.process_id is not null) then
         OPEN c_unmitigated_risks(r_load_cols.certification_id
	                             ,r_load_cols.organization_id
			   	     		     ,r_load_cols.process_id);
            FETCH c_unmitigated_risks INTO l_unmitigated_risks;
         CLOSE c_unmitigated_risks;

		 OPEN c_ineffective_controls(r_load_cols.certification_id
	                             ,r_load_cols.organization_id
			   	     		     ,r_load_cols.process_id);
            FETCH c_ineffective_controls INTO l_ineffective_controls;
         CLOSE c_ineffective_controls;

		 /** 12.12.2005 npanandi: added below for key_control
		                          bug 4862301 fix
			**/
		 SELECT decode(count(aca.control_id),0,'N','Y')
		   into l_key_control
           FROM amw_control_associations aca
      	   	   ,amw_controls_b acb
		  WHERE aca.object_type = 'BUSIPROC_CERTIFICATION'
		    AND aca.pk1 = r_load_cols.certification_id
		    AND aca.pk2 = r_load_cols.organization_id
		    AND aca.pk3 IN (SELECT DISTINCT process_id
			 	 		  	  FROM amw_execution_scope
			 	 		  	 START WITH process_id = r_load_cols.process_id
			 	 		  	   AND organization_id = r_load_cols.organization_id
			 	 		  	   AND entity_id = r_load_cols.certification_id
							   and entity_type='BUSIPROC_CERTIFICATION'
			 	 		   CONNECT BY PRIOR process_id = parent_process_id
			 	 		       AND organization_id = PRIOR organization_id
			 	 		  	   AND entity_id = PRIOR entity_id
							   and entity_type=prior entity_type)
		    and aca.control_id = acb.control_id
		    and acb.curr_approved_flag = 'Y'
		    and nvl(acb.key_mitigating,'N') = 'Y';
	     /** 12.12.2005 npanandi: ends bug 4862301 fix **/
      end if;

	  update RCI_ORG_PROC_DFCY_F
	     set unmitigated_risks = l_unmitigated_risks
		    ,ineffective_controls = l_ineffective_controls
			/** 12.12.2005 npanandi: bug 4862301 fix for keyControl **/
			,key_control = l_key_control
	   where certification_id = r_load_cols.certification_id
	     and organization_id = r_load_cols.organization_id
		 and process_id = r_load_cols.process_id;
   end loop;


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
    WHERE fact_name                 = 'RCI_ORG_PROC_DFCY_F' ;


   commit;
   retcode := C_OK;
EXCEPTION
   WHEN OTHERS THEN
      retcode := C_ERROR;
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM || ':' || l_message, l_proc_name, l_stmnt_id));
      ROLLBACK;
      RAISE;
END incr_load;

PROCEDURE incr_load_obsolete(
   errbuf  in out NOCOPY VARCHAR2
  ,retcode in out NOCOPY NUMBER)
IS
   cursor c_load_cols is
      select certification_id
	        ,organization_id
			,process_id
	    from rci_org_proc_dfcy_f;

   l_stmnt_id      NUMBER := 0;
   l_run_date      DATE;
   l_last_run_date DATE;
   l_proc_name     VARCHAR2(30);
   l_message	   VARCHAR2(30);
   l_master_org    MTL_PARAMETERS.MASTER_ORGANIZATION_ID%TYPE;
   l_count		   NUMBER;

   l_user_id                NUMBER;
   l_login_id               NUMBER;
   l_program_id             NUMBER;
   l_program_login_id       NUMBER;
   l_program_application_id NUMBER;
   l_request_id             NUMBER;

   l_unmitigated_risks      number;
   l_ineffective_controls   number;

   /** 12.12.2005 npanandi: bug 4862301 fix for keyControl **/
   l_key_control			varchar2(2);
BEGIN
   l_user_id                := NVL(fnd_global.USER_ID, -1);
   l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
   l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
   l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
   l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
   l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);

   l_stmnt_id := 10;
   l_proc_name := 'run_incr_load_drm';
   l_last_run_date := get_last_run_date('RCI_ORG_PROC_DFCY_F');

   IF l_last_run_date IS NULL THEN
      l_message := 'Please launch the Initial Load Request Set for the Organization Certification Summary page.';
      RAISE INITIALIZATION_ERROR;
   END IF;

   l_stmnt_id := 20;
   l_run_date := sysdate - 5/(24*60);
   ---l_master_org  := get_master_organization_id;

   l_stmnt_id := 30;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_ORG_PROC_DFCY_F');

   l_stmnt_id := 40;

   INSERT INTO RCI_ORG_PROC_DFCY_F(
      project_id
	 ,fin_certification_id
     ,certification_id
     ,certification_status
     ,certification_type
     ,certification_period_name
     ,certification_period_set_name
     ,organization_id
	 ,process_id
	 ,significant_process_flag
	 ,standard_process_flag
	 ,certification_result_code
	 ,certified_by_id
	 ,evaluation_result_code
	 ,last_evaluated_by_id
	 ,last_evaluated_on
	 ,natural_account_id
	 /** 10.20.2005 npanandi begin ***/
	 ,period_year
	 ,period_num
	 ,quarter_num
	 ,ent_period_id
	 ,ent_qtr_id
	 ,ent_year_id
	 ,report_date_julian
	 /** 10.20.2005 npanandi end ***/
	 ,creation_date
	 ,created_by
	 ,last_update_date
	 ,last_updated_by
	 ,last_update_login
	 ---,unmitigated_risks hold on to these for now
	 ---,ineffective_controls
	 ) SELECT distinct aapv.AUDIT_PROJECT_ID,
	          acv2.certification_id,
	          execs.entity_id,
		      acv.CERTIFICATION_STATUS,
		      acv.CERTIFICATION_TYPE,
		      acv.CERTIFICATION_PERIOD_NAME,
		      acv.CERTIFICATION_PERIOD_SET_NAME,
	          execs.organization_id,
	          execs.process_id,
	          nvl(process.significant_process_flag,'N'),
	          nvl(process.standard_process_flag,'N'),
		      opinions_cert.audit_result_code,
	          opinions_cert.authored_by,
	          opinions_eval.audit_result_code,
	          opinions_eval.AUTHORED_BY,
	          opinions_eval.authored_date,
	          afkav.natural_account_id,
			  /** 10.20.2005 npanandi begin ***/
	          agpv.period_year,
      		  agpv.period_num,
      		  agpv.quarter_num,
      		  to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)),
      		  to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)),
      		  agpv.period_year,
      		  to_number(to_char(agpv.end_date,'J')),
	  		  /** 10.20.2005 npanandi end ***/
	  	  	  sysdate,
	          G_USER_ID,
			  sysdate,
			  G_USER_ID,
			  G_LOGIN_ID
         FROM amw_proc_cert_eval_sum proccert,
	          amw_opinions_log_v opinions_eval,
	          amw_opinions_v opinions_cert,
	          amw_process_organization_vl process,
	          amw_execution_scope execs,
	          amw_audit_units_v audit_v,
	          amw_audit_projects_v aapv,
		      amw_certification_vl acv,
		      amw_certification_vl acv2,
		      AMW_FIN_PROC_CERT_RELAN afpcr,
		      (select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa,
		      AMW_FIN_KEY_ACCOUNTS_VL AFKAV
			  /** 10.20.2005 npanandi begin ***/
	         ,amw_gl_periods_v agpv
	  		 /** 10.20.2005 npanandi end ***/
	    WHERE execs.entity_id = opinions_cert.pk2_value(+)
	      AND execs.organization_id = opinions_cert.pk3_value(+)
	      AND execs.process_id = opinions_cert.pk1_value(+)
	      AND execs.entity_type = 'BUSIPROC_CERTIFICATION'
	      AND execs.entity_id = proccert.certification_id
	      and acv.CERTIFICATION_ID = proccert.CERTIFICATION_ID
	      and acv.OBJECT_TYPE = 'PROCESS'
	      and aapv.audit_project_id(+) = opinions_eval.pk2_value
	      AND execs.process_org_rev_id = proccert.process_org_rev_id
	      AND opinions_cert.opinion_type_code(+) = 'CERTIFICATION'
	      AND opinions_cert.object_name(+) = 'AMW_ORG_PROCESS'
	      AND proccert.evaluation_opinion_log_id = opinions_eval.opinion_log_id(+)
	      AND process.process_org_rev_id = execs.process_org_rev_id
	      AND process.organization_id = audit_v.organization_id
	      and afpcr.PROC_CERT_ID = acv.CERTIFICATION_ID
	      and afpcr.END_DATE is null
	      and afpcr.FIN_STMT_CERT_ID = acv2.CERTIFICATION_ID
	      and acv2.object_type='FIN_STMT'
	      and aaa.pk1(+) = execs.organization_id
	      and aaa.pk2(+) = execs.process_id
	      and aaa.natural_account_id = afkav.natural_account_id(+)
		  /** 10.20.2005 npanandi begin ***/
   		  and acv.certification_period_name = agpv.period_name
   		  and acv.certification_period_set_name = agpv.period_set_name;
   		  /** 10.20.2005 npanandi end ***/

   for r_load_cols in c_load_cols loop
      ----dbms_output.put_line( '' );
      if(r_load_cols.certification_id is not null and
	     r_load_cols.organization_id is not null and
		 r_load_cols.process_id is not null) then
         OPEN c_unmitigated_risks(r_load_cols.certification_id
	                             ,r_load_cols.organization_id
			   	     		     ,r_load_cols.process_id);
            FETCH c_unmitigated_risks INTO l_unmitigated_risks;
         CLOSE c_unmitigated_risks;

		 OPEN c_ineffective_controls(r_load_cols.certification_id
	                             ,r_load_cols.organization_id
			   	     		     ,r_load_cols.process_id);
            FETCH c_ineffective_controls INTO l_ineffective_controls;
         CLOSE c_ineffective_controls;

		 /** 12.12.2005 npanandi: added below for key_control
		                          bug 4862301 fix
			**/
		 SELECT decode(count(aca.control_id),0,'N','Y')
		   into l_key_control
           FROM amw_control_associations aca
      	   	   ,amw_controls_b acb
		  WHERE aca.object_type = 'BUSIPROC_CERTIFICATION'
		    AND aca.pk1 = r_load_cols.certification_id
		    AND aca.pk2 = r_load_cols.organization_id
		    AND aca.pk3 IN (SELECT DISTINCT process_id
			 	 		  	  FROM amw_execution_scope
			 	 		  	 START WITH process_id = r_load_cols.process_id
			 	 		  	   AND organization_id = r_load_cols.organization_id
			 	 		  	   AND entity_id = r_load_cols.certification_id
							   and entity_type='BUSIPROC_CERTIFICATION'
			 	 		   CONNECT BY PRIOR process_id = parent_process_id
			 	 		       AND organization_id = PRIOR organization_id
			 	 		  	   AND entity_id = PRIOR entity_id
							   and entity_type=prior entity_type)
		    and aca.control_id = acb.control_id
		    and acb.curr_approved_flag = 'Y'
		    and nvl(acb.key_mitigating,'N') = 'Y';
	     /** 12.12.2005 npanandi: ends bug 4862301 fix **/
      end if;

	  update RCI_ORG_PROC_DFCY_F
	     set unmitigated_risks = l_unmitigated_risks
		    ,ineffective_controls = l_ineffective_controls
			/** 12.12.2005 npanandi: bug 4862301 fix for keyControl **/
			,key_control = l_key_control
	   where certification_id = r_load_cols.certification_id
	     and organization_id = r_load_cols.organization_id
		 and process_id = r_load_cols.process_id;
   end loop;


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
    WHERE fact_name                 = 'RCI_ORG_PROC_DFCY_F' ;


   commit;
   retcode := C_OK;
EXCEPTION
   WHEN OTHERS THEN
      retcode := C_ERROR;
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM || ':' || l_message, l_proc_name, l_stmnt_id));
      ROLLBACK;
      RAISE;
END incr_load_obsolete;

END RCI_ORG_DFCY_ETL_PKG;

/
