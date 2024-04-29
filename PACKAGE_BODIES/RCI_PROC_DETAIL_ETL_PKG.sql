--------------------------------------------------------
--  DDL for Package Body RCI_PROC_DETAIL_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCI_PROC_DETAIL_ETL_PKG" AS
--$Header: rciprdtetlb.pls 120.7.12000000.1 2007/01/16 20:46:40 appldev ship $

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

--  Common Procedures Definitions
--  check_initial_load_setup
--  Gets the GSD.
--  History:
--  Date        Author                 Action
--  09/08/2005  Panandikar Nilesh G    Defined procedure.

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
--  Date        Author              Action
--  10/06/2004  Vijay Babu G    Defined procedure.

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
--  Date        Author                Action
--  09/08/2005 Panandikar Nilesh G    Defined procedure.

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

/**
FUNCTION get_master_organization_id
RETURN NUMBER
IS
   l_func_name     VARCHAR2(40);
   l_profile_name  FND_PROFILE_OPTIONS_VL.USER_PROFILE_OPTION_NAME%TYPE;
   l_stmt_id       NUMBER;
   l_master_org	MTL_PARAMETERS.MASTER_ORGANIZATION_ID%TYPE;
   l_org		MTL_PARAMETERS.MASTER_ORGANIZATION_ID%TYPE;
   MISSING_INV_VALIDATION_ORG EXCEPTION;
   PRAGMA EXCEPTION_INIT (MISSING_INV_VALIDATION_ORG, -20800);
   l_err_msg VARCHAR2(2000);

   cursor master_org_cur IS
      select distinct master_organization_id
        from mtl_parameters;
BEGIN
   l_func_name := 'get_master_organization_id';
   l_stmt_id := 0;

   SELECT user_profile_option_name
     INTO l_profile_name
	 FROM fnd_profile_options_vl
	WHERE profile_option_name = 'CS_INV_VALIDATION_ORG';

   FND_MESSAGE.SET_NAME('ISC','ISC_DEPOT_MISSING_INV_VAL_ORG');
   FND_MESSAGE.SET_TOKEN('ISC_DEPOT_PROFILE_NAME',l_profile_name);
   l_err_msg := FND_MESSAGE.GET;

   FOR master_org_cur_rec IN master_org_cur LOOP
      l_master_org := master_org_cur_rec.master_organization_id;
      IF master_org_cur%rowcount > 1 then
         l_master_org := null;
         EXIT;
      END IF;
   END LOOP;

        ---- Get the site level value for Service: Inventory Validation Organization
	IF (l_master_org IS NULL) THEN
   	    l_org :=  FND_PROFILE.VALUE_SPECIFIC(NAME => 'CS_INV_VALIDATION_ORG',
                                                        USER_ID => -1,
                                                        RESPONSIBILITY_ID => -1,
                                                        APPLICATION_ID => -1);

	    l_stmt_id := 10;

	    IF (l_org IS NULL) THEN
		RAISE MISSING_INV_VALIDATION_ORG;
   	    END IF;

	    SELECT master_organization_id INTO l_master_org FROM mtl_parameters WHERE organization_id = l_org;


	END IF;

        RETURN l_master_org;

EXCEPTION

    WHEN MISSING_INV_VALIDATION_ORG THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM || l_err_msg ));

    WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM, l_func_name,l_stmt_id));
        RAISE ;

END get_master_organization_id;
***/


--  run_initial_load
--  Parameters:
--  retcode - 0 on successful completion, -1 on error and 1 for warning.
--  errbuf - empty on successful completion, message on error or warning
--
--  History:
--  Date        Author               Action
--  08/22/2005  Nilesh Panandikar    Defined Body.


PROCEDURE initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER)
IS

   l_proc_w_ineff_ctrls number := 0;
   l_ineffective_ctrls  number := 0;
   l_unmitigated_risks  number := 0;
   l_open_issues        number := 0;

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
   DELETE FROM rci_dr_inc where fact_name = 'RCI_PROCESS_DETAIL_F';

   ----dbms_output.put_line( '2 **************' );

   l_stmnt_id := 20;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_PROCESS_DETAIL_F');

   ----dbms_output.put_line( '3 **************' );
   l_stmnt_id := 30;
   l_run_date := sysdate - 5/(24*60);

   INSERT INTO RCI_PROCESS_DETAIL_F(
      project_id
	 ,process_org_rev_id
	 ,fin_certification_id
	 ,certification_id
	 ,certification_status
	 ,certification_type
	 ,certification_period_name
     ,certification_period_set_name
	 ,organization_id
	 ,process_id
	 ,natural_account_id
	 ,significant_process_flag
	 ,standard_process_flag
	 ,process_category
	 ,certification_result_code
	 ,certified_by_id
	 ,certified_on
	 ,evaluation_result_code
	 ,evaluated_by_id
	 ,last_evaluated_on
	 /** 10.19.2005 npanandi begin ***/
	 ,period_year
	 ,period_num
	 ,quarter_num
	 ,ent_period_id
	 ,ent_qtr_id
	 ,ent_year_id
	 ,report_date_julian
	 /** 10.19.2005 npanandi end ***/
	 ,creation_date
	 ,created_by
	 ,last_update_date
	 ,last_updated_by
	 ,last_update_login)
      select distinct evalopn.pk2_value, /*project_id*/
       proc.process_org_rev_id,
       finprocsum.FIN_CERTIFICATION_ID,
       -10000, /*certification_id, cannot insert NULL here*/
       acb.certification_status,
       acb.certification_type,
       acb.certification_period_name,
       acb.certification_period_set_name,
	   o.organization_id,
	   proc.process_id,
	   aaa.natural_account_id,
       nvl(proc.significant_process_flag,'N'),
	   nvl(proc.standard_process_flag,'N'),
	   proc.process_category,
       certopn.audit_result_code, /*certification_result_code*/
       certopn.authored_by, /*certified_by_id*/
       certopn.authored_date, /*certified_on*/
       evalopn.audit_result_code, /*evaluation_result_code*/
       evalopn.authored_by, /*evaluated_by_id*/
       evalopn.authored_date, /*last_evaluated_on*/
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
  from AMW_FIN_CERT_SCOPE finscope,
       AMW_FIN_PROC_CERT_RELAN REL,
       AMW_FIN_PROCESS_EVAL_SUM finprocsum,
       HR_ALL_ORGANIZATION_UNITS o,
       HR_ALL_ORGANIZATION_UNITS_TL otl,
       AMW_PROCESS_ORGANIZATION_VL proc,
       /*AMW_OPINIONS_V*/ AMW_OPINIONS_LOG_V certopn,
       /*AMW_OPINIONS_V*/ AMW_OPINIONS_LOG_V evalopn,
       amw_certification_b acb,
       (select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa,
	   amw_gl_periods_v agpv
 where rel.FIN_STMT_CERT_ID = finprocsum.FIN_CERTIFICATION_ID
   and rel.end_date is null
   and finprocsum.FIN_CERTIFICATION_ID = finscope.fin_certification_id
   and finprocsum.ORGANIZATION_ID = finscope.ORGANIZATION_ID
   and finprocsum.PROCESS_ID  = finscope.PROCESS_ID
   and finprocsum.PROCESS_ORG_REV_ID = proc.PROCESS_ORG_REV_ID
   and o.organization_id = finscope.organization_id
   and o.organization_id = otl.organization_id
   and otl.language = userenv('LANG')
   and finprocsum.EVAL_OPINION_log_ID = evalopn.opinion_log_id(+)
   and finprocsum.cert_opinion_log_id = certopn.opinion_log_id(+)
   /***and certopn.opinion_type_code = 'CERTIFICATION'
   and certopn.object_name = 'AMW_ORG_PROCESS'
   and certopn.pk1_value = finscope.process_id
   and certopn.pk2_value = rel.PROC_CERT_ID
   and certopn.pk3_value = finscope.organization_id
   AND certopn.authored_date = (select max(aov2.authored_date) from AMW_OPINIONS  aov2
                               	 where aov2.object_opinion_type_id = certopn.object_opinion_type_id
                                   and aov2.pk3_value = certopn.pk3_value
				                   AND aov2.pk2_value in (select proc_cert_Id
								                            from AMW_FIN_PROC_CERT_RELAN
           				                                   where fin_stmt_cert_id = finprocsum.FIN_CERTIFICATION_ID
           				                                     and end_date is null)
                                   and aov2.pk1_value = certopn.pk1_value)
								   ***/
   and finprocsum.FIN_CERTIFICATION_ID = acb.certification_id
   and aaa.pk1(+) = finprocsum.organization_id
   and aaa.pk2(+) = finprocsum.process_id
   and acb.certification_period_name = agpv.period_name
   and acb.certification_period_set_name = agpv.period_set_name;

   l_stmnt_id :=40;

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
	 'RCI_PROCESS_DETAIL_F'
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

   l_stmnt_id := 50;
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

   l_proc_w_ineff_ctrls number := 0;
   l_ineffective_ctrls  number := 0;
   l_unmitigated_risks  number := 0;
   l_open_issues        number := 0;

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
   DELETE FROM rci_dr_inc where fact_name = 'RCI_PROCESS_DETAIL_F';

   ----dbms_output.put_line( '2 **************' );

   l_stmnt_id := 20;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_PROCESS_DETAIL_F');

   ----dbms_output.put_line( '3 **************' );
   l_stmnt_id := 30;
   l_run_date := sysdate - 5/(24*60);

   INSERT INTO RCI_PROCESS_DETAIL_F(
      project_id
	 ,process_org_rev_id
	 ,fin_certification_id
	 ,certification_id
	 ,certification_status
	 ,certification_type
	 ,certification_period_name
     ,certification_period_set_name
	 ,organization_id
	 ,process_id
	 ,natural_account_id
	 ,significant_process_flag
	 ,standard_process_flag
	 ,process_category
	 ,certification_result_code
	 ,certified_by_id
	 ,certified_on
	 ,evaluation_result_code
	 ,evaluated_by_id
	 ,last_evaluated_on
	 /** 10.19.2005 npanandi begin ***/
	 ,period_year
	 ,period_num
	 ,quarter_num
	 ,ent_period_id
	 ,ent_qtr_id
	 ,ent_year_id
	 ,report_date_julian
	 /** 10.19.2005 npanandi end ***/
	 ,creation_date
	 ,created_by
	 ,last_update_date
	 ,last_updated_by
	 ,last_update_login)
      SELECT distinct opinions_eval.pk2_value,
	         execs.PROCESS_ORG_REV_ID,
			 acv2.certification_id,
		     execs.entity_id,
	         acv.certification_status,
	         acv.certification_type,
			 acv.CERTIFICATION_PERIOD_NAME,
			 acv.CERTIFICATION_PERIOD_SET_NAME,
	         execs.organization_id,
	         execs.process_id,
			 afkav.natural_account_id,
	         nvl(process.significant_process_flag,'N'),
	         nvl(process.standard_process_flag,'N'),
	         process.process_category,
	         opinions_cert.audit_result_code,
	         opinions_cert.authored_by,
	         opinions_cert.authored_date,
	         opinions_eval.audit_result_code,
	         opinions_eval.authored_by,
	         opinions_eval.authored_date,
			 /** 10.19.2005 npanandi begin ***/
			 agpv.period_year,
             agpv.period_num,
             agpv.quarter_num,
             to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)),
             to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)),
             agpv.period_year,
             to_number(to_char(agpv.end_date,'J')),
			 /** 10.19.2005 npanandi end ***/
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
	         amw_certification_vl acv,
	         amw_audit_projects_v aapv,
		     amw_certification_vl acv2,
		     AMW_FIN_PROC_CERT_RELAN afpcr,
		     (select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa,
		     AMW_FIN_KEY_ACCOUNTS_VL AFKAV,
			 /** 10.19.2005 npanandi begin ***/
		     amw_gl_periods_v agpv
			 /** 10.19.2005 npanandi end ***/
	   WHERE execs.entity_id = opinions_cert.pk2_value(+)
	     AND execs.organization_id = opinions_cert.pk3_value(+)
	     AND execs.process_id = opinions_cert.pk1_value(+)
	     AND execs.entity_type = 'BUSIPROC_CERTIFICATION'
	     AND execs.entity_id = proccert.certification_id
	     AND execs.process_org_rev_id = proccert.process_org_rev_id
	     and execs.entity_id = acv.certification_id
	     AND opinions_cert.opinion_type_code(+) = 'CERTIFICATION'
	     AND opinions_cert.object_name(+) = 'AMW_ORG_PROCESS'
	     AND proccert.evaluation_opinion_log_id = opinions_eval.opinion_log_id(+)
	     AND process.process_org_rev_id = execs.process_org_rev_id
	     AND process.organization_id = audit_v.organization_id
	     and aapv.audit_project_id(+) = opinions_eval.pk2_value
		 and afpcr.PROC_CERT_ID = acv.CERTIFICATION_ID
	     and afpcr.END_DATE is null
	     and afpcr.FIN_STMT_CERT_ID = acv2.CERTIFICATION_ID
	     and acv2.object_type='FIN_STMT'
	     and aaa.pk1(+) = execs.organization_id
	     and aaa.pk2(+) = execs.process_id
	     and aaa.natural_account_id = afkav.natural_account_id(+)
		 /** 10.19.2005 npanandi begin ***/
	     and acv.certification_period_name = agpv.period_name
	     and acv.certification_period_set_name = agpv.period_set_name
		 /** 10.19.2005 npanandi end ***/
	   ORDER BY execs.entity_id,execs.organization_id,execs.process_id asc;

   ----dbms_output.put_line( '4 **************' );

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
	 'RCI_PROCESS_DETAIL_F'
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
-- 09/08/2005  Panandikar Nilesh G    Defined Body.

PROCEDURE incr_load(
   errbuf  in out NOCOPY VARCHAR2
  ,retcode in out NOCOPY NUMBER)
IS

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

   l_proc_w_ineff_ctrls number;
   l_ineffective_ctrls  number;
   l_unmitigated_risks  number;
   l_open_issues        number;

BEGIN
   l_user_id                := NVL(fnd_global.USER_ID, -1);
   l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
   l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
   l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
   l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
   l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);

   l_stmnt_id := 10;
   l_proc_name := 'run_incr_load_drm';
   l_last_run_date := get_last_run_date('RCI_PROCESS_DETAIL_F');

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
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_PROCESS_DETAIL_F');

   INSERT INTO RCI_PROCESS_DETAIL_F(
      project_id
	 ,process_org_rev_id
	 ,fin_certification_id
	 ,certification_id
	 ,certification_status
	 ,certification_type
	 ,certification_period_name
     ,certification_period_set_name
	 ,organization_id
	 ,process_id
	 ,natural_account_id
	 ,significant_process_flag
	 ,standard_process_flag
	 ,process_category
	 ,certification_result_code
	 ,certified_by_id
	 ,certified_on
	 ,evaluation_result_code
	 ,evaluated_by_id
	 ,last_evaluated_on
	 /** 10.19.2005 npanandi begin ***/
	 ,period_year
	 ,period_num
	 ,quarter_num
	 ,ent_period_id
	 ,ent_qtr_id
	 ,ent_year_id
	 ,report_date_julian
	 /** 10.19.2005 npanandi end ***/
	 ,creation_date
	 ,created_by
	 ,last_update_date
	 ,last_updated_by
	 ,last_update_login)
      select distinct evalopn.pk2_value, /*project_id*/
       proc.process_org_rev_id,
       finprocsum.FIN_CERTIFICATION_ID,
       -10000, /*certification_id, cannot insert NULL here*/
       acb.certification_status,
       acb.certification_type,
       acb.certification_period_name,
       acb.certification_period_set_name,
	   o.organization_id,
	   proc.process_id,
	   aaa.natural_account_id,
       nvl(proc.significant_process_flag,'N'),
	   nvl(proc.standard_process_flag,'N'),
	   proc.process_category,
       certopn.audit_result_code, /*certification_result_code*/
       certopn.authored_by, /*certified_by_id*/
       certopn.authored_date, /*certified_on*/
       evalopn.audit_result_code, /*evaluation_result_code*/
       evalopn.authored_by, /*evaluated_by_id*/
       evalopn.authored_date, /*last_evaluated_on*/
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
  from AMW_FIN_CERT_SCOPE finscope,
       AMW_FIN_PROC_CERT_RELAN REL,
       AMW_FIN_PROCESS_EVAL_SUM finprocsum,
       HR_ALL_ORGANIZATION_UNITS o,
       HR_ALL_ORGANIZATION_UNITS_TL otl,
       AMW_PROCESS_ORGANIZATION_VL proc,
       /*AMW_OPINIONS_V*/ AMW_OPINIONS_LOG_V certopn,
       /*AMW_OPINIONS_V*/ AMW_OPINIONS_LOG_V evalopn,
       amw_certification_b acb,
       (select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa,
	   amw_gl_periods_v agpv
 where rel.FIN_STMT_CERT_ID = finprocsum.FIN_CERTIFICATION_ID
   and rel.end_date is null
   and finprocsum.FIN_CERTIFICATION_ID = finscope.fin_certification_id
   and finprocsum.ORGANIZATION_ID = finscope.ORGANIZATION_ID
   and finprocsum.PROCESS_ID  = finscope.PROCESS_ID
   and finprocsum.PROCESS_ORG_REV_ID = proc.PROCESS_ORG_REV_ID
   and o.organization_id = finscope.organization_id
   and o.organization_id = otl.organization_id
   and otl.language = userenv('LANG')
   and finprocsum.EVAL_OPINION_log_ID = evalopn.opinion_log_id(+)
   and finprocsum.cert_opinion_log_id = certopn.opinion_log_id(+)
   /***and certopn.opinion_type_code = 'CERTIFICATION'
   and certopn.object_name = 'AMW_ORG_PROCESS'
   and certopn.pk1_value = finscope.process_id
   and certopn.pk2_value = rel.PROC_CERT_ID
   and certopn.pk3_value = finscope.organization_id
   AND certopn.authored_date = (select max(aov2.authored_date) from AMW_OPINIONS  aov2
                               	 where aov2.object_opinion_type_id = certopn.object_opinion_type_id
                                   and aov2.pk3_value = certopn.pk3_value
				                   AND aov2.pk2_value in (select proc_cert_Id
								                            from AMW_FIN_PROC_CERT_RELAN
           				                                   where fin_stmt_cert_id = finprocsum.FIN_CERTIFICATION_ID
           				                                     and end_date is null)
                                   and aov2.pk1_value = certopn.pk1_value)
								   ***/
   and finprocsum.FIN_CERTIFICATION_ID = acb.certification_id
   and aaa.pk1(+) = finprocsum.organization_id
   and aaa.pk2(+) = finprocsum.process_id
   and acb.certification_period_name = agpv.period_name
   and acb.certification_period_set_name = agpv.period_set_name;

   l_stmnt_id :=40;
        UPDATE rci_dr_inc
		   SET last_run_date             = l_run_date
              ,last_update_date          = sysdate
              ,last_updated_by           = l_user_id
              ,last_update_login         = l_login_id
              ,program_id                = l_program_id
              ,program_login_id          = l_program_login_id
              ,program_application_id    = l_program_application_id
              ,request_id                = l_request_id
		 WHERE fact_name = 'RCI_PROCESS_DETAIL_F' ;

   l_stmnt_id :=50;
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

   l_proc_w_ineff_ctrls number;
   l_ineffective_ctrls  number;
   l_unmitigated_risks  number;
   l_open_issues        number;

BEGIN
   l_user_id                := NVL(fnd_global.USER_ID, -1);
   l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
   l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
   l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
   l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
   l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);

   l_stmnt_id := 10;
   l_proc_name := 'run_incr_load_drm';
   l_last_run_date := get_last_run_date('RCI_PROCESS_DETAIL_F');

   IF l_last_run_date IS NULL THEN
      l_message := 'Please launch the Initial Load Request Set for the Organization Certification Summary page.';
      RAISE INITIALIZATION_ERROR;
   END IF;

   l_stmnt_id := 20;
   l_run_date := sysdate - 5/(24*60);
   ---l_master_org  := get_master_organization_id;

   l_stmnt_id := 30;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_PROCESS_DETAIL_F');

   INSERT INTO RCI_PROCESS_DETAIL_F(
      project_id
	 ,process_org_rev_id
	 ,fin_certification_id
	 ,certification_id
	 ,certification_status
	 ,certification_type
	 ,certification_period_name
     ,certification_period_set_name
	 ,organization_id
	 ,process_id
	 ,natural_account_id
	 ,significant_process_flag
	 ,standard_process_flag
	 ,process_category
	 ,certification_result_code
	 ,certified_by_id
	 ,certified_on
	 ,evaluation_result_code
	 ,evaluated_by_id
	 ,last_evaluated_on
	 /** 10.19.2005 npanandi begin ***/
	 ,period_year
	 ,period_num
	 ,quarter_num
	 ,ent_period_id
	 ,ent_qtr_id
	 ,ent_year_id
	 ,report_date_julian
	 /** 10.19.2005 npanandi end ***/
	 ,creation_date
	 ,created_by
	 ,last_update_date
	 ,last_updated_by
	 ,last_update_login)
      SELECT distinct opinions_eval.pk2_value,
	         execs.PROCESS_ORG_REV_ID,
			 acv2.certification_id,
		     execs.entity_id,
	         acv.certification_status,
	         acv.certification_type,
			 acv.CERTIFICATION_PERIOD_NAME,
			 acv.CERTIFICATION_PERIOD_SET_NAME,
	         execs.organization_id,
	         execs.process_id,
			 afkav.natural_account_id,
	         nvl(process.significant_process_flag,'N'),
	         nvl(process.standard_process_flag,'N'),
	         process.process_category,
	         opinions_cert.audit_result_code,
	         opinions_cert.authored_by,
	         opinions_cert.authored_date,
	         opinions_eval.audit_result_code,
	         opinions_eval.authored_by,
	         opinions_eval.authored_date,
			 /** 10.19.2005 npanandi begin ***/
			 agpv.period_year,
             agpv.period_num,
             agpv.quarter_num,
             to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num)),
             to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)),
             agpv.period_year,
             to_number(to_char(agpv.end_date,'J')),
			 /** 10.19.2005 npanandi end ***/
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
	         amw_certification_vl acv,
	         amw_audit_projects_v aapv,
		     amw_certification_vl acv2,
		     AMW_FIN_PROC_CERT_RELAN afpcr,
		     (select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa,
		     AMW_FIN_KEY_ACCOUNTS_VL AFKAV,
			 /** 10.19.2005 npanandi begin ***/
		     amw_gl_periods_v agpv
			 /** 10.19.2005 npanandi end ***/
	   WHERE execs.entity_id = opinions_cert.pk2_value(+)
	     AND execs.organization_id = opinions_cert.pk3_value(+)
	     AND execs.process_id = opinions_cert.pk1_value(+)
	     AND execs.entity_type = 'BUSIPROC_CERTIFICATION'
	     AND execs.entity_id = proccert.certification_id
	     AND execs.process_org_rev_id = proccert.process_org_rev_id
	     and execs.entity_id = acv.certification_id
	     AND opinions_cert.opinion_type_code(+) = 'CERTIFICATION'
	     AND opinions_cert.object_name(+) = 'AMW_ORG_PROCESS'
	     AND proccert.evaluation_opinion_log_id = opinions_eval.opinion_log_id(+)
	     AND process.process_org_rev_id = execs.process_org_rev_id
	     AND process.organization_id = audit_v.organization_id
	     and aapv.audit_project_id(+) = opinions_eval.pk2_value
		 and afpcr.PROC_CERT_ID = acv.CERTIFICATION_ID
	     and afpcr.END_DATE is null
	     and afpcr.FIN_STMT_CERT_ID = acv2.CERTIFICATION_ID
	     and acv2.object_type='FIN_STMT'
	     and aaa.pk1(+) = execs.organization_id
	     and aaa.pk2(+) = execs.process_id
	     and aaa.natural_account_id = afkav.natural_account_id(+)
		 /** 10.19.2005 npanandi begin ***/
	     and acv.certification_period_name = agpv.period_name
	     and acv.certification_period_set_name = agpv.period_set_name
		 /** 10.19.2005 npanandi end ***/
	   ORDER BY execs.entity_id,execs.organization_id,execs.process_id asc;

   l_stmnt_id :=40;
        UPDATE rci_dr_inc
		   SET last_run_date             = l_run_date
              ,last_update_date          = sysdate
              ,last_updated_by           = l_user_id
              ,last_update_login         = l_login_id
              ,program_id                = l_program_id
              ,program_login_id          = l_program_login_id
              ,program_application_id    = l_program_application_id
              ,request_id                = l_request_id
		 WHERE fact_name = 'RCI_PROCESS_DETAIL_F' ;


        commit;
        retcode := C_OK;

EXCEPTION
   WHEN OTHERS THEN
      retcode := C_ERROR;
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM || ':' || l_message, l_proc_name, l_stmnt_id));
      ROLLBACK;
      RAISE;
END incr_load_obsolete;

END RCI_PROC_DETAIL_ETL_PKG;

/
