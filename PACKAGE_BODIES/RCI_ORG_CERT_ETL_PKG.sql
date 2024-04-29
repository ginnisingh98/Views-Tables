--------------------------------------------------------
--  DDL for Package Body RCI_ORG_CERT_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCI_ORG_CERT_ETL_PKG" AS
--$Header: rciocrtetlb.pls 120.10.12000000.1 2007/01/16 20:46:14 appldev ship $

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
   cursor c_load_cols is
      select distinct fin_certification_id
			,organization_id
			,process_id
	    from rci_org_cert_summ_f;


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

   l_processes_certified_w_issues number := 0 ;
   l_processes_certified 		  number := 0;
   l_processes_not_certified 	  number := 0;
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
   DELETE FROM rci_dr_inc where fact_name = 'RCI_ORG_CERT_SUMM_F';

   ----dbms_output.put_line( '2 **************' );

   l_stmnt_id := 20;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_ORG_CERT_SUMM_F');

   ----dbms_output.put_line( '3 **************' );
   l_stmnt_id := 30;
   l_run_date := sysdate - 5/(24*60);

   INSERT INTO RCI_ORG_CERT_SUMM_F(
      fin_certification_id
	 ,natural_account_id
     ,certification_id
     ,certification_type
     ,certification_status
     ,certification_period_name
     ,certification_period_set_name
	 ,certification_owner_id
     ,organization_id
	 ,org_certification_status
	 ,org_certified_by
	 ,org_certified_on
	 ,org_certified_with_issues
	 ,org_certified
	 ,org_not_certified
	 ,process_id
	 ,proc_certified_with_issues
	 ,proc_certified
	 ,proc_not_certified
	 ,proc_w_ineff_ctrls
	 ,unmitigated_risks
	 ,ineffective_controls
	 ,open_issues
	 ,period_year
	 ,period_num
	 ,quarter_num
	 ,ent_period_id
	 ,ent_qtr_id
	 ,ent_year_id
	 ,report_date_julian
	 ,creation_date
	 ,created_by
	 ,last_update_date
	 ,last_updated_by
	 ,last_update_login)
      SELECT DISTINCT hier.entity_id /*fin_certification_id*/
      ,afcs.natural_account_id /*natural_account_id*/
      ,-10000 /*certification_id, cannot insert NULL*/
      ,acv.certification_type /*certification_type*/
      ,acv.certification_status /*certification_status*/
      ,acv.certification_period_name /*certification_period_name*/
      ,acv.certification_period_set_name /*certification_period_set_name*/
      ,acv.certification_owner_id /*certification_owner_id*/
      ,hier.object_id /*organization_id*/
      ,certopinion.audit_result_code /*org_certification_status*/
      ---,certopinion.audit_result as cert_result
      ,certopinion.authored_by /*org_certified_by*/
      ,certopinion.authored_date /*org_certified_on*/
      ,decode(certopinion.audit_result_code,null,0,'EFFECTIVE',0,1) /*org_certified_with_issues*/
      ,decode(certopinion.audit_result_code,null,0,'EFFECTIVE',1,0) /*org_certified*/
      ,decode(certopinion.audit_result_code,null,1,0) /*org_not_certified*/
      ,afcs.process_id /*process_id*/
      ,null /*proc_certified_with_issues*/
      ,null /*proc_certified*/
      ,null /*proc_not_certified*/
      ,null /*proc_w_ineff_ctrls*/
      ,null /*unmitigated_risks*/
      ,null /*ineffective_controls*/
      ,null /*open_issues*/
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
  FROM amw_entity_hierarchies hier,
  	   amw_fin_org_eval_sum orgeval,
       amw_audit_units_v auv,
       amw_opinions_log_v certopinion,
       amw_opinions_log_v evalopinion,
       amw_certification_vl acv,
       amw_gl_periods_v agpv,
	   amw_fin_cert_scope afcs
 WHERE hier.entity_type = 'FINSTMT_CERTIFICATION'
   AND hier.entity_id = orgeval.fin_certification_id
   and acv.certification_id = hier.entity_id
   and acv.object_type = 'FIN_STMT'
   AND hier.object_type = 'ORG'
   AND hier.object_id = orgeval.organization_id
   AND orgeval.organization_id = auv.organization_id
   and orgeval.cert_opinion_log_id = certopinion.opinion_log_id(+)
   AND orgeval.eval_opinion_log_id = evalopinion.opinion_log_id(+)
   AND hier.parent_object_type IN ('ROOTNODE', 'ORG')
   and acv.certification_period_name = agpv.period_name
   and acv.certification_period_set_name = agpv.period_set_name
   and hier.entity_id = afcs.fin_certification_id
   and afcs.organization_id = orgeval.organization_id;

   l_stmnt_id :=40;


   for r_load_cols in c_load_cols loop
   exit when c_load_cols%notfound;
      l_proc_w_ineff_ctrls := 0;
		l_processes_certified_w_issues := 0;
		l_processes_certified := 0;
		l_processes_not_certified := 0;
		l_unmitigated_risks := 0;
		l_ineffective_ctrls := 0;
		l_open_issues := 0;


		 OPEN c_proc_w_ineff_ctrls(r_load_cols.fin_certification_id
	                              ,r_load_cols.organization_id,r_load_cols.process_id);
            FETCH c_proc_w_ineff_ctrls INTO l_proc_w_ineff_ctrls;
         CLOSE c_proc_w_ineff_ctrls;

		 open c_proc_certified_w_issues(r_load_cols.fin_certification_id,r_load_cols.organization_id
		                               ,r_load_cols.process_id);
            fetch c_proc_certified_w_issues into l_processes_certified_w_issues;
	     close c_proc_certified_w_issues;

		 open c_proc_certified(r_load_cols.fin_certification_id,r_load_cols.organization_id
		                      ,r_load_cols.process_id);
            fetch c_proc_certified into l_processes_certified;
	     close c_proc_certified;

		 open c_proc_not_certified(r_load_cols.fin_certification_id,r_load_cols.organization_id
		                          ,r_load_cols.process_id);
            fetch c_proc_not_certified into l_processes_not_certified;
	     close c_proc_not_certified;

	     /* 01.08.2006 npanandi: added below -- if process is not effective
	        as well as not ineffective, then it has to be not certified yet ***/
	     if(l_processes_certified_w_issues = 0 and l_processes_certified = 0) then
	        l_processes_not_certified := 1;
	     end if;

	     OPEN c_unmitigated_risks(r_load_cols.fin_certification_id,r_load_cols.organization_id);
            FETCH c_unmitigated_risks INTO l_unmitigated_risks;
         CLOSE c_unmitigated_risks;

	     OPEN c_ineffective_ctrls(r_load_cols.fin_certification_id,r_load_cols.organization_id);
            FETCH c_ineffective_ctrls INTO l_ineffective_ctrls;
         CLOSE c_ineffective_ctrls;

	  ----OPEN c_open_org_issues(r_load_cols.certification_id
	  ----                      ,r_load_cols.organization_id);
      ----   FETCH c_open_org_issues INTO l_open_issues;
      ----CLOSE c_open_org_issues;

	/****
      update rci_org_cert_summ_f
         set proc_w_ineff_ctrls = l_proc_w_ineff_ctrls
       where fin_certification_id = r_load_cols.fin_certification_id
         and organization_id = r_load_cols.organization_id;
         ***/

      update rci_org_cert_summ_f
	     set proc_w_ineff_ctrls         = l_proc_w_ineff_ctrls
		    ,proc_certified_with_issues = l_processes_certified_w_issues
			,proc_certified 		 	= l_processes_certified
			,proc_not_certified 	 	= l_processes_not_certified
			,unmitigated_risks 	  	 	= l_unmitigated_risks
			,ineffective_controls 	 	= l_ineffective_ctrls
			/***,open_issues          	 	= l_open_issues***/
       where fin_certification_id = r_load_cols.fin_certification_id
	     and organization_id = r_load_cols.organization_id
		 and process_id = r_load_cols.process_id;

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
	 'RCI_ORG_CERT_SUMM_F'
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

   l_stmnt_id := 60;
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
      select proc_w_ineff_ctrls
	        ,unmitigated_risks
			,ineffective_controls
			,open_issues
			,certification_id
			,organization_id
			,process_id
	    from rci_org_cert_summ_f;

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
   DELETE FROM rci_dr_inc where fact_name = 'RCI_ORG_CERT_SUMM_F';

   ----dbms_output.put_line( '2 **************' );

   l_stmnt_id := 20;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_ORG_CERT_SUMM_F');

   ----dbms_output.put_line( '3 **************' );
   l_stmnt_id := 30;
   l_run_date := sysdate - 5/(24*60);

   INSERT INTO RCI_ORG_CERT_SUMM_F(
      fin_certification_id
	 ,natural_account_id
     ,certification_id
     ,certification_type
     ,certification_status
     ,certification_period_name
     ,certification_period_set_name
	 ,certification_owner_id
     ,organization_id
	 ,org_certification_status
	 ,org_certified_by
	 ,org_certified_on
	 ,process_id
	 ,proc_certified_with_issues
	 ,proc_certified
	 ,proc_not_certified
	 ,proc_w_ineff_ctrls
	 ,unmitigated_risks
	 ,ineffective_controls
	 ,open_issues
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
	 ,last_update_login)
      select distinct acv2.certification_id
	  ,afkav.natural_account_id
	  ,acv.certification_id
      ,acv.certification_type
      ,acv.certification_status
      ,acv.certification_period_name
      ,acv.certification_period_set_name
	  ,acv.CERTIFICATION_OWNER_ID
      ,haou.organization_id
      ,orgcert_aov.audit_result_code
	  ,orgcert_aov.AUTHORED_BY
	  ,orgcert_aov.AUTHORED_DATE
      ,ap.process_id
      ,decode(ap.process_id,null,0,decode(proccert_aolv.audit_result_code,'INEFFECTIVE',1,0))
      ,decode(ap.process_id,null,0,decode(proccert_aolv.audit_result_code,'EFFECTIVE',1,0))
      ,decode(ap.process_id,null,0,decode(proccert_aolv.audit_result_code,null,1,0))
      ,to_number(null)
      ,to_number(null)
      ,to_number(null)
      ,to_number(null)
	  /** 10.20.2005 npanandi begin ***/
	  ,agpv.period_year
      ,agpv.period_num
      ,agpv.quarter_num
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num))
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num))
      ,agpv.period_year
      ,to_number(to_char(agpv.end_date,'J'))
	  /** 10.20.2005 npanandi end ***/
	  ,sysdate
	  ,G_USER_ID
	  ,sysdate
	  ,G_USER_ID
	  ,G_LOGIN_ID
  from amw_execution_scope aes
      ,amw_certification_vl acv
      ,amw_process ap
      ,amw_process_names_tl apnt
      ,amw_process_organization aop
      ,hr_all_organization_units haou
      ,hr_all_organization_units_tl haout
	  ,hr_organization_information hoi
	  ,amw_opinions_v orgcert_aov
	  ,amw_opinions_v proccert_aolv
	  ,amw_certification_vl acv2
	  ,AMW_FIN_PROC_CERT_RELAN afpcr
	  ,(select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa
	  ,AMW_FIN_KEY_ACCOUNTS_VL AFKAV
	  /** 10.20.2005 npanandi begin ***/
	  ,amw_gl_periods_v agpv
	  /** 10.20.2005 npanandi end ***/
 where entity_type='BUSIPROC_CERTIFICATION'
   and acv.object_type='PROCESS'
   and acv.certification_id=aes.entity_id
   and (aes.level_id = (select max(level_id) from amw_execution_scope where entity_type='BUSIPROC_CERTIFICATION' and entity_id=aes.entity_id and organization_id=aes.organization_id) or aes.level_id > 3)
   and haou.organization_id=haout.organization_id
   and haout.language=userenv('LANG')
   and haou.organization_id=hoi.organization_id
   and hoi.org_information_context='CLASS'
   and hoi.org_information1='AMW_AUDIT_UNIT'
   and hoi.org_information2='Y'
   and aes.organization_id=haou.organization_id
   and aes.process_org_rev_id=aop.process_org_rev_id(+)
   and aop.rl_process_rev_id=ap.process_rev_id(+)
   and ap.process_rev_id=apnt.process_rev_id(+)
   and apnt.language(+)=userenv('LANG')
   and aes.entity_id=orgcert_aov.pk2_value(+)
   and aes.organization_id=orgcert_aov.pk1_value(+)
   and orgcert_aov.object_name(+)='AMW_ORGANIZATION'
   and orgcert_aov.opinion_type_code(+)='CERTIFICATION'
   and proccert_aolv.object_name(+)='AMW_ORG_PROCESS'
   and proccert_aolv.opinion_type_code(+)='CERTIFICATION'
   and proccert_aolv.pk1_value(+)=aes.process_id
   and proccert_aolv.pk2_value(+)=aes.entity_id
   and proccert_aolv.pk3_value(+)=aes.organization_id
   and afpcr.PROC_CERT_ID = acv.CERTIFICATION_ID
   and afpcr.END_DATE is null
   and afpcr.FIN_STMT_CERT_ID = acv2.CERTIFICATION_ID
   and acv2.OBJECT_TYPE = 'FIN_STMT'
   and aaa.pk1(+) = aes.organization_id
   and aaa.pk2(+) = aes.process_id
   and aaa.natural_account_id = afkav.natural_account_id(+)
   /** 10.20.2005 npanandi begin ***/
   and acv.certification_period_name = agpv.period_name
   and acv.certification_period_set_name = agpv.period_set_name;
   /** 10.20.2005 npanandi end ***/

   ----dbms_output.put_line( '4 **************' );

   l_stmnt_id :=50;
   /*
   for r_load_cols in c_load_cols loop
   exit when c_load_cols%notfound;

	  ----dbms_output.put_line( 'r_load_cols.certification_id: '||r_load_cols.certification_id );
	  ----dbms_output.put_line( 'r_load_cols.organization_id: '||r_load_cols.organization_id );
	  ----dbms_output.put_line( 'r_load_cols.process_id: '||r_load_cols.process_id );

	  if(r_load_cols.process_id is not null) then
	     OPEN c_proc_w_ineff_ctrls(r_load_cols.certification_id
	                              ,r_load_cols.organization_id
			   	     		      ,r_load_cols.process_id);
            FETCH c_proc_w_ineff_ctrls INTO l_proc_w_ineff_ctrls;
         CLOSE c_proc_w_ineff_ctrls;

	     OPEN c_unmitigated_risks(r_load_cols.certification_id
	                             ,r_load_cols.organization_id
							     ,r_load_cols.process_id);
            FETCH c_unmitigated_risks INTO l_unmitigated_risks;
         CLOSE c_unmitigated_risks;
      end if;

	  OPEN c_ineffective_ctrls(r_load_cols.certification_id
	                          ,r_load_cols.organization_id);
         FETCH c_ineffective_ctrls INTO l_ineffective_ctrls;
      CLOSE c_ineffective_ctrls;

	  OPEN c_open_org_issues(r_load_cols.certification_id
	                        ,r_load_cols.organization_id);
         FETCH c_open_org_issues INTO l_open_issues;
      CLOSE c_open_org_issues;

      update rci_org_cert_summ_f
	     set proc_w_ineff_ctrls = nvl(l_proc_w_ineff_ctrls,0)
		    ,unmitigated_risks = nvl(l_unmitigated_risks,0)
			,ineffective_controls = nvl(l_ineffective_ctrls,0)
			,open_issues = nvl(l_open_issues,0)
       where certification_id = r_load_cols.certification_id
	     and organization_id = r_load_cols.organization_id
		 and process_id = r_load_cols.process_id;
   end loop;*/

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
	 'RCI_ORG_CERT_SUMM_F'
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
	  ----dbms_output.put_line( 'In OTHERS **************' );
	  ----dbms_output.put_line( 'errmsdg: '||substr ((l_proc_name || ' #' ||to_char (l_stmnt_id) || ': ' || SQLERRM),
              -----                         1, C_ERRBUF_SIZE) );
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
   cursor c_load_cols is
      select distinct fin_certification_id
			,organization_id
			,process_id
	    from rci_org_cert_summ_f;

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

   l_processes_certified_w_issues number := 0 ;
   l_processes_certified 		  number := 0;
   l_processes_not_certified 	  number := 0;
BEGIN
   l_user_id                := NVL(fnd_global.USER_ID, -1);
   l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
   l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
   l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
   l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
   l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);

   l_stmnt_id := 10;
   l_proc_name := 'run_incr_load_drm';
   l_last_run_date := get_last_run_date('RCI_ORG_CERT_SUMM_F');

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
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_ORG_CERT_SUMM_F');

   INSERT INTO RCI_ORG_CERT_SUMM_F(
      fin_certification_id
	 ,natural_account_id
     ,certification_id
     ,certification_type
     ,certification_status
     ,certification_period_name
     ,certification_period_set_name
	 ,certification_owner_id
     ,organization_id
	 ,org_certification_status
	 ,org_certified_by
	 ,org_certified_on
	 ,org_certified_with_issues
	 ,org_certified
	 ,org_not_certified
	 ,process_id
	 ,proc_certified_with_issues
	 ,proc_certified
	 ,proc_not_certified
	 ,proc_w_ineff_ctrls
	 ,unmitigated_risks
	 ,ineffective_controls
	 ,open_issues
	 ,period_year
	 ,period_num
	 ,quarter_num
	 ,ent_period_id
	 ,ent_qtr_id
	 ,ent_year_id
	 ,report_date_julian
	 ,creation_date
	 ,created_by
	 ,last_update_date
	 ,last_updated_by
	 ,last_update_login)
      SELECT DISTINCT hier.entity_id /*fin_certification_id*/
      ,afcs.natural_account_id /*natural_account_id*/
      ,-10000 /*certification_id, cannot insert NULL*/
      ,acv.certification_type /*certification_type*/
      ,acv.certification_status /*certification_status*/
      ,acv.certification_period_name /*certification_period_name*/
      ,acv.certification_period_set_name /*certification_period_set_name*/
      ,acv.certification_owner_id /*certification_owner_id*/
      ,hier.object_id /*organization_id*/
      ,certopinion.audit_result_code /*org_certification_status*/
      ---,certopinion.audit_result as cert_result
      ,certopinion.authored_by /*org_certified_by*/
      ,certopinion.authored_date /*org_certified_on*/
      ,decode(certopinion.audit_result_code,null,0,'EFFECTIVE',0,1) /*org_certified_with_issues*/
      ,decode(certopinion.audit_result_code,null,0,'EFFECTIVE',1,0) /*org_certified*/
      ,decode(certopinion.audit_result_code,null,1,0) /*org_not_certified*/
      ,afcs.process_id /*process_id*/
      ,null /*proc_certified_with_issues*/
      ,null /*proc_certified*/
      ,null /*proc_not_certified*/
      ,null /*proc_w_ineff_ctrls*/
      ,null /*unmitigated_risks*/
      ,null /*ineffective_controls*/
      ,null /*open_issues*/
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
  FROM amw_entity_hierarchies hier,
  	   amw_fin_org_eval_sum orgeval,
       amw_audit_units_v auv,
       amw_opinions_log_v certopinion,
       amw_opinions_log_v evalopinion,
       amw_certification_vl acv,
       amw_gl_periods_v agpv,
	   amw_fin_cert_scope afcs
 WHERE hier.entity_type = 'FINSTMT_CERTIFICATION'
   AND hier.entity_id = orgeval.fin_certification_id
   and acv.certification_id = hier.entity_id
   and acv.object_type = 'FIN_STMT'
   AND hier.object_type = 'ORG'
   AND hier.object_id = orgeval.organization_id
   AND orgeval.organization_id = auv.organization_id
   and orgeval.cert_opinion_log_id = certopinion.opinion_log_id(+)
   AND orgeval.eval_opinion_log_id = evalopinion.opinion_log_id(+)
   AND hier.parent_object_type IN ('ROOTNODE', 'ORG')
   and acv.certification_period_name = agpv.period_name
   and acv.certification_period_set_name = agpv.period_set_name
   and hier.entity_id = afcs.fin_certification_id
   and afcs.organization_id = orgeval.organization_id;


   l_stmnt_id :=40;

   for r_load_cols in c_load_cols loop
   exit when c_load_cols%notfound;
      l_proc_w_ineff_ctrls := 0;
		l_processes_certified_w_issues := 0;
		l_processes_certified := 0;
		l_processes_not_certified := 0;
		l_unmitigated_risks := 0;
		l_ineffective_ctrls := 0;
		l_open_issues := 0;


		 OPEN c_proc_w_ineff_ctrls(r_load_cols.fin_certification_id
	                              ,r_load_cols.organization_id,r_load_cols.process_id);
            FETCH c_proc_w_ineff_ctrls INTO l_proc_w_ineff_ctrls;
         CLOSE c_proc_w_ineff_ctrls;

		 open c_proc_certified_w_issues(r_load_cols.fin_certification_id,r_load_cols.organization_id
		                               ,r_load_cols.process_id);
            fetch c_proc_certified_w_issues into l_processes_certified_w_issues;
	     close c_proc_certified_w_issues;

		 open c_proc_certified(r_load_cols.fin_certification_id,r_load_cols.organization_id
		                      ,r_load_cols.process_id);
            fetch c_proc_certified into l_processes_certified;
	     close c_proc_certified;

		 open c_proc_not_certified(r_load_cols.fin_certification_id,r_load_cols.organization_id
		                          ,r_load_cols.process_id);
            fetch c_proc_not_certified into l_processes_not_certified;
	     close c_proc_not_certified;

	     /* 01.08.2006 npanandi: added below -- if process is not effective
	        as well as not ineffective, then it has to be not certified yet ***/
	     if(l_processes_certified_w_issues = 0 and l_processes_certified = 0) then
	        l_processes_not_certified := 1;
	     end if;

	     OPEN c_unmitigated_risks(r_load_cols.fin_certification_id,r_load_cols.organization_id);
            FETCH c_unmitigated_risks INTO l_unmitigated_risks;
         CLOSE c_unmitigated_risks;

	     OPEN c_ineffective_ctrls(r_load_cols.fin_certification_id,r_load_cols.organization_id);
            FETCH c_ineffective_ctrls INTO l_ineffective_ctrls;
         CLOSE c_ineffective_ctrls;

	  ----OPEN c_open_org_issues(r_load_cols.certification_id
	  ----                      ,r_load_cols.organization_id);
      ----   FETCH c_open_org_issues INTO l_open_issues;
      ----CLOSE c_open_org_issues;

	/****
      update rci_org_cert_summ_f
         set proc_w_ineff_ctrls = l_proc_w_ineff_ctrls
       where fin_certification_id = r_load_cols.fin_certification_id
         and organization_id = r_load_cols.organization_id;
         ***/

      update rci_org_cert_summ_f
	     set proc_w_ineff_ctrls         = l_proc_w_ineff_ctrls
		    ,proc_certified_with_issues = l_processes_certified_w_issues
			,proc_certified 		 	= l_processes_certified
			,proc_not_certified 	 	= l_processes_not_certified
			,unmitigated_risks 	  	 	= l_unmitigated_risks
			,ineffective_controls 	 	= l_ineffective_ctrls
			/***,open_issues          	 	= l_open_issues***/
       where fin_certification_id = r_load_cols.fin_certification_id
	     and organization_id = r_load_cols.organization_id
		 and process_id = r_load_cols.process_id;

   end loop;

   l_stmnt_id :=60;
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
      select proc_w_ineff_ctrls
	        ,unmitigated_risks
			,ineffective_controls
			,open_issues
			,certification_id
			,organization_id
			,process_id
	    from rci_org_cert_summ_f;

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
   l_last_run_date := get_last_run_date('RCI_ORG_CERT_SUMM_F');

   IF l_last_run_date IS NULL THEN
      l_message := 'Please launch the Initial Load Request Set for the Organization Certification Summary page.';
      RAISE INITIALIZATION_ERROR;
   END IF;

   l_stmnt_id := 20;
   l_run_date := sysdate - 5/(24*60);
   ---l_master_org  := get_master_organization_id;

   l_stmnt_id := 20;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_ORG_CERT_SUMM_F');

   INSERT INTO RCI_ORG_CERT_SUMM_F(
      fin_certification_id
	 ,natural_account_id
     ,certification_id
     ,certification_type
     ,certification_status
     ,certification_period_name
     ,certification_period_set_name
     ,certification_owner_id
     ,organization_id
	 ,org_certification_status
	 ,org_certified_by
	 ,org_certified_on
	 ,process_id
	 ,proc_certified_with_issues
	 ,proc_certified
	 ,proc_not_certified
	 ,proc_w_ineff_ctrls
	 ,unmitigated_risks
	 ,ineffective_controls
	 ,open_issues
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
	 ,last_update_login)
      select distinct acv2.CERTIFICATION_ID
	  ,afkav.natural_account_id
	  ,acv.certification_id
      ,acv.certification_type
      ,acv.certification_status
      ,acv.certification_period_name
      ,acv.certification_period_set_name
      ,acv.CERTIFICATION_OWNER_ID
      ,haou.organization_id
      ,orgcert_aov.audit_result_code
      ,orgcert_aov.AUTHORED_BY
	  ,orgcert_aov.AUTHORED_DATE
      ,ap.process_id
      ,decode(ap.process_id,null,0,decode(proccert_aolv.audit_result_code,'INEFFECTIVE',1,0))
      ,decode(ap.process_id,null,0,decode(proccert_aolv.audit_result_code,'EFFECTIVE',1,0))
      ,decode(ap.process_id,null,0,decode(proccert_aolv.audit_result_code,null,1,0))
      ,to_number(null)
      ,to_number(null)
      ,to_number(null)
      ,to_number(null)
	  /** 10.20.2005 npanandi begin ***/
	  ,agpv.period_year
      ,agpv.period_num
      ,agpv.quarter_num
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num))
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num))
      ,agpv.period_year
      ,to_number(to_char(agpv.end_date,'J'))
	  /** 10.20.2005 npanandi end ***/
	  ,sysdate
	  ,G_USER_ID
	  ,sysdate
	  ,G_USER_ID
	  ,G_LOGIN_ID
  from amw_execution_scope aes
      ,amw_certification_vl acv
      ,amw_process ap
      ,amw_process_names_tl apnt
      ,amw_process_organization aop
      ,hr_all_organization_units haou
      ,hr_all_organization_units_tl haout
	  ,hr_organization_information hoi
	  ,amw_opinions_v orgcert_aov
	  ,amw_opinions_log_v proccert_aolv
	  ,amw_certification_vl acv2
	  ,AMW_FIN_PROC_CERT_RELAN afpcr
	  ,(select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa
	  ,AMW_FIN_KEY_ACCOUNTS_VL AFKAV
	  /** 10.20.2005 npanandi begin ***/
	  ,amw_gl_periods_v agpv
	  /** 10.20.2005 npanandi end ***/
 where entity_type='BUSIPROC_CERTIFICATION'
   and acv.object_type='PROCESS'
   and acv.certification_id=aes.entity_id
   and haou.organization_id=haout.organization_id
   and haout.language=userenv('LANG')
   and haou.organization_id=hoi.organization_id
   and hoi.org_information_context='CLASS'
   and hoi.org_information1='AMW_AUDIT_UNIT'
   and hoi.org_information2='Y'
   and aes.organization_id=haou.organization_id
   and aes.process_org_rev_id=aop.process_org_rev_id(+)
   and aop.rl_process_rev_id=ap.process_rev_id(+)
   and ap.process_rev_id=apnt.process_rev_id(+)
   and apnt.language(+)=userenv('LANG')
   and aes.entity_id=orgcert_aov.pk2_value(+)
   and aes.organization_id=orgcert_aov.pk1_value(+)
   and orgcert_aov.object_name(+)='AMW_ORGANIZATION'
   and orgcert_aov.opinion_type_code(+)='CERTIFICATION'
   and proccert_aolv.object_name(+)='AMW_ORG_PROCESS'
   and proccert_aolv.opinion_type_code(+)='CERTIFICATION'
   and proccert_aolv.pk1_value(+)=aes.process_id
   and proccert_aolv.pk2_value(+)=aes.entity_id
   and proccert_aolv.pk3_value(+)=aes.organization_id
   and afpcr.PROC_CERT_ID = acv.CERTIFICATION_ID
   and afpcr.END_DATE is null
   and afpcr.FIN_STMT_CERT_ID = acv2.CERTIFICATION_ID
   and acv2.OBJECT_TYPE = 'FIN_STMT'
   and aaa.pk1(+) = aes.organization_id
   and aaa.pk2(+) = aes.process_id
   and aaa.natural_account_id = afkav.natural_account_id(+)
   /** 10.20.2005 npanandi begin ***/
   and acv.certification_period_name = agpv.period_name
   and acv.certification_period_set_name = agpv.period_set_name;
   /** 10.20.2005 npanandi end ***/

   ----dbms_output.put_line( '4 **************' );

   l_stmnt_id :=50;
   /***
   for r_load_cols in c_load_cols loop
   exit when c_load_cols%notfound;

	  ----dbms_output.put_line( 'r_load_cols.certification_id: '||r_load_cols.certification_id );
	  ----dbms_output.put_line( 'r_load_cols.organization_id: '||r_load_cols.organization_id );
	  ----dbms_output.put_line( 'r_load_cols.process_id: '||r_load_cols.process_id );

	  if(r_load_cols.process_id is not null) then
	     OPEN c_proc_w_ineff_ctrls(r_load_cols.certification_id
	                              ,r_load_cols.organization_id
			   	     		      ,r_load_cols.process_id);
            FETCH c_proc_w_ineff_ctrls INTO l_proc_w_ineff_ctrls;
         CLOSE c_proc_w_ineff_ctrls;

	     OPEN c_unmitigated_risks(r_load_cols.certification_id
	                             ,r_load_cols.organization_id
							     ,r_load_cols.process_id);
            FETCH c_unmitigated_risks INTO l_unmitigated_risks;
         CLOSE c_unmitigated_risks;
      end if;

	  OPEN c_ineffective_ctrls(r_load_cols.certification_id
	                          ,r_load_cols.organization_id);
         FETCH c_ineffective_ctrls INTO l_ineffective_ctrls;
      CLOSE c_ineffective_ctrls;

	  OPEN c_open_org_issues(r_load_cols.certification_id
	                        ,r_load_cols.organization_id);
         FETCH c_open_org_issues INTO l_open_issues;
      CLOSE c_open_org_issues;

      update rci_org_cert_summ_f
	     set proc_w_ineff_ctrls = l_proc_w_ineff_ctrls
		    ,unmitigated_risks = l_unmitigated_risks
			,ineffective_controls = l_ineffective_ctrls
			,open_issues = l_open_issues
       where certification_id = r_load_cols.certification_id
	     and organization_id = r_load_cols.organization_id
		 and process_id = r_load_cols.process_id;
   end loop;**/

   ----dbms_output.put_line( '5 **************' );


        l_stmnt_id :=30;
        UPDATE rci_dr_inc
		   SET last_run_date             = l_run_date
              ,last_update_date          = sysdate
              ,last_updated_by           = l_user_id
              ,last_update_login         = l_login_id
              ,program_id                = l_program_id
              ,program_login_id          = l_program_login_id
              ,program_application_id    = l_program_application_id
              ,request_id                = l_request_id
		 WHERE fact_name = 'RCI_ORG_CERT_SUMM_F' ;


        commit;
        retcode := C_OK;

EXCEPTION
   WHEN OTHERS THEN
      retcode := C_ERROR;
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM || ':' || l_message, l_proc_name, l_stmnt_id));
      ROLLBACK;
      RAISE;
END incr_load_obsolete;

END RCI_ORG_CERT_ETL_PKG;

/
