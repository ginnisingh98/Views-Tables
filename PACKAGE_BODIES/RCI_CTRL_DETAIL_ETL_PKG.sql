--------------------------------------------------------
--  DDL for Package Body RCI_CTRL_DETAIL_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCI_CTRL_DETAIL_ETL_PKG" AS
--$Header: rcicdtetlb.pls 120.7 2007/01/20 00:27:54 sbag ship $

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
   l_proc_w_ineff_ctrls number;
   l_ineffective_ctrls  number;
   l_unmitigated_risks  number;
   l_open_issues        number;

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

   l_stmnt_id := 0;
   l_proc_name := 'intitial_load';
   check_initial_load_setup(
      x_global_start_date => g_global_start_date
     ,x_rci_schema        => g_rci_schema);

   l_stmnt_id := 10;
   DELETE FROM rci_dr_inc where fact_name = 'RCI_ORG_CERT_CTRLS_F';


   l_stmnt_id := 20;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_ORG_CERT_CTRLS_F');

   l_stmnt_id := 30;
   l_run_date := sysdate - 5/(24*60);

   INSERT INTO RCI_ORG_CERT_CTRLS_F(
      fin_certification_id
     ,certification_id
     ,certification_status
     ,certification_type
     ,certification_period_name
     ,certification_period_set_name
     ,organization_id
	 ,process_id
	 ,natural_account_id
	 ,control_id
	 ,control_rev_id
	 ,control_type
	 ,control_location
	 ,automation_type
	 ,control_frequency
	 ,key_control
	 ,disclosure_control
	 ,latest_rev_num
	 ,audit_result_code
	 ,last_evaluated_by_id
	 ,last_evaluated_on
	 ,op_eff_id
	 ,des_eff_id
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
      SELECT DISTINCT ctrls.pk1 as certification_id /*fin_certification_id*/
      ,-10000 /*certification_id*/
      ,acv.certification_status
      ,acv.certification_type
      ,acv.certification_period_name
      ,acv.certification_period_set_name
      ,o.organization_id
      ,ctrls.pk3 /*process_id*/
      ,afcs.natural_account_id /*natural_account_id*/
      ,all_ctrls.control_id
      ,all_ctrls.control_rev_id
      ,all_ctrls.control_type
      ,all_ctrls.control_location
	  ,all_ctrls.automation_type
	  ,all_ctrls.control_frequency
	  ,upper(nvl(all_ctrls.key_mitigating,'N'))
	  ,upper(nvl(all_ctrls.disclosure_control,'N'))
	  ,(select max(rev_num) from amw_controls_b where control_id=all_ctrls.control_id) /*latest_rev_num*/
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
      ,agpv.period_year
      ,agpv.period_num
      ,agpv.quarter_num
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num))
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num))
      ,agpv.period_year
      ,to_number(to_char(agpv.end_date,'J'))
	  ,sysdate
	  ,G_USER_ID
	  ,sysdate
	  ,G_USER_ID
	  ,G_LOGIN_ID
  FROM AMW_CONTROL_ASSOCIATIONS ctrls,
       AMW_CONTROLS_ALL_VL all_ctrls,
       HR_ALL_ORGANIZATION_UNITS o,
       HR_ALL_ORGANIZATION_UNITS_TL otl,
       AMW_OPINIONS_LOG_V op,
       amw_certification_vl acv,
       amw_fin_cert_scope afcs,
	   amw_gl_periods_v agpv
 WHERE ctrls.object_type = 'RISK_FINCERT'
   and ctrls.control_rev_id = all_ctrls.control_rev_id
   and all_ctrls.APPROVAL_STATUS = 'A'
   and o.organization_id = ctrls.pk2
   and o.organization_id = otl.organization_id
   and otl.language = userenv('LANG')
   and op.opinion_log_id(+)  = ctrls.pk5
   and op.AUDIT_RESULT_CODE <> 'EFFECTIVE'
   and acv.certification_id = ctrls.pk1
   and afcs.fin_certification_id = ctrls.pk1
   and afcs.organization_id = o.organization_id
   and afcs.process_id = ctrls.pk3
   and acv.certification_period_name = agpv.period_name
   and acv.certification_period_set_name = agpv.period_set_name;


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
	 'RCI_ORG_CERT_CTRLS_F'
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

/*****
PROCEDURE initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER)
IS
   l_proc_w_ineff_ctrls number;
   l_ineffective_ctrls  number;
   l_unmitigated_risks  number;
   l_open_issues        number;

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

   l_stmnt_id := 0;
   l_proc_name := 'intitial_load';
   check_initial_load_setup(
      x_global_start_date => g_global_start_date
     ,x_rci_schema        => g_rci_schema);

   l_stmnt_id := 10;
   DELETE FROM rci_dr_inc where fact_name = 'RCI_ORG_CERT_CTRLS_F';


   l_stmnt_id := 20;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_ORG_CERT_CTRLS_F');

   l_stmnt_id := 30;
   l_run_date := sysdate - 5/(24*60);

   INSERT INTO RCI_ORG_CERT_CTRLS_F(
      fin_certification_id
     ,certification_id
     ,certification_status
     ,certification_type
     ,certification_period_name
     ,certification_period_set_name
     ,organization_id
	 ,process_id
	 ,natural_account_id
	 ,control_id
	 ,control_rev_id
	 ,control_type
	 ,control_location
	 ,automation_type
	 ,control_frequency
	 ,key_control
	 ,disclosure_control
	 ,latest_rev_num
	 ,audit_result_code
	 ,last_evaluated_by_id
	 ,last_evaluated_on
	 ,op_eff_id
	 ,des_eff_id
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
      SELECT DISTINCT acv2.certification_id,
		     ctrlassoc.pk1,
	         acv.certification_status,
	         acv.certification_type,
		     acv.certification_period_name,
		     acv.certification_period_set_name,
	         orgtable.organization_id,
	         procorg.process_id,
		     afkav.natural_account_id,
	         controltable.control_id,
		     ctrlassoc.control_rev_id,
		     controltable.control_type,
		     controltable.control_location,
		     controltable.automation_type,
		     controltable.control_frequency,
		     nvl(controltable.key_mitigating,'N'),
		     nvl(controltable.disclosure_control,'N'),
		     (select max(rev_num) from amw_controls_b where control_id=controltable.control_id),
	         opinionstable.audit_result_code,
	         opinionstable.last_updated_by,
	         opinionstable.authored_date,
	         (SELECT valuestable.opinion_value_id
		        FROM amw_opinion_log_details details,
			         amw_opinion_values_tl valuestable,
			         amw_opinion_componts_b compb
		       WHERE opinionstable.opinion_log_id = details.opinion_log_id
		         AND details.opinion_component_id = compb.opinion_component_id
		         AND compb.object_opinion_type_id = opinionstable.object_opinion_type_id
		         AND compb.opinion_component_code = 'OPERATING'
		         AND valuestable.language = userenv('LANG')
		         AND details.opinion_value_id = valuestable.opinion_value_id ),
		     (SELECT valuestable.opinion_value_id
		        FROM amw_opinion_log_details details,
		             amw_opinion_values_tl valuestable,
		             amw_opinion_componts_b compb
		       WHERE opinionstable.opinion_log_id = details.opinion_log_id
		         AND details.opinion_component_id = compb.opinion_component_id
		         AND compb.object_opinion_type_id = opinionstable.object_opinion_type_id
		         AND compb.opinion_component_code = 'DESIGN'
		         AND valuestable.language = userenv('LANG')
		         AND details.opinion_value_id = valuestable.opinion_value_id ),
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
	    FROM amw_control_associations ctrlassoc,
	         amw_controls_all_vl controltable,
	         amw_audit_units_v orgtable,
	         amw_opinions_log_v opinionstable,
	         amw_execution_scope execs,
	         AMW_PROCESS_ORGANIZATION_VL procorg,
	         amw_certification_vl acv,
	         amw_certification_vl acv2,
	         AMW_FIN_PROC_CERT_RELAN afpcr,
	         (select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa,
	         AMW_FIN_KEY_ACCOUNTS_VL AFKAV
		    ,amw_gl_periods_v agpv
	   WHERE execs.entity_id            = ctrlassoc.pk1
	     AND execs.entity_type          = ctrlassoc.object_type
	     AND execs.organization_id      = orgtable.organization_id
	     AND procorg.process_org_rev_id(+) = execs.process_org_rev_id
	     AND ctrlassoc.control_rev_id   = controltable.control_rev_id
	     AND ctrlassoc.pk5              = opinionstable.opinion_log_id (+)
	     AND ctrlassoc.object_type      = 'BUSIPROC_CERTIFICATION'
	     AND ctrlassoc.pk2              = orgtable.organization_id
	     AND NVL(ctrlassoc.pk3,-1)      = NVL(execs.process_id,-1)
	     and acv.certification_id       = execs.entity_id
	     and opinionstable.audit_result_code <> 'EFFECTIVE'
	     and opinionstable.OBJECT_NAME  = 'AMW_ORG_CONTROL'
	     and opinionstable.OPINION_TYPE_CODE = 'EVALUATION'
   		 and afpcr.PROC_CERT_ID = acv.CERTIFICATION_ID
	     and afpcr.END_DATE is null
	     and afpcr.FIN_STMT_CERT_ID = acv2.CERTIFICATION_ID
	     and acv2.object_type='FIN_STMT'
	     and aaa.pk1(+) = execs.organization_id
	     and aaa.pk2(+) = execs.process_id
	     and aaa.natural_account_id = afkav.natural_account_id(+)
		 and acv.certification_period_name = agpv.period_name
   		 and acv.certification_period_set_name = agpv.period_set_name
   		 order by acv2.certification_id,ctrlassoc.pk1,orgtable.organization_id,procorg.process_id,controltable.control_id;

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
	 'RCI_ORG_CERT_CTRLS_F'
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
******/


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
BEGIN
   l_user_id                := NVL(fnd_global.USER_ID, -1);
   l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
   l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
   l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
   l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
   l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);

   l_stmnt_id := 10;
   l_proc_name := 'run_incr_load_drm';
   l_last_run_date := get_last_run_date('RCI_ORG_CERT_CTRLS_F');

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
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_ORG_CERT_CTRLS_F');

   l_stmnt_id := 40;

   INSERT INTO RCI_ORG_CERT_CTRLS_F(
      fin_certification_id
     ,certification_id
     ,certification_status
     ,certification_type
     ,certification_period_name
     ,certification_period_set_name
     ,organization_id
	 ,process_id
	 ,natural_account_id
	 ,control_id
	 ,control_rev_id
	 ,control_type
	 ,control_location
	 ,automation_type
	 ,control_frequency
	 ,key_control
	 ,disclosure_control
	 ,latest_rev_num
	 ,audit_result_code
	 ,last_evaluated_by_id
	 ,last_evaluated_on
	 ,op_eff_id
	 ,des_eff_id
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
      SELECT DISTINCT ctrls.pk1 as certification_id /*fin_certification_id*/
      ,-10000 /*certification_id*/
      ,acv.certification_status
      ,acv.certification_type
      ,acv.certification_period_name
      ,acv.certification_period_set_name
      ,o.organization_id
      ,ctrls.pk3 /*process_id*/
      ,afcs.natural_account_id /*natural_account_id*/
      ,all_ctrls.control_id
      ,all_ctrls.control_rev_id
      ,all_ctrls.control_type
      ,all_ctrls.control_location
	  ,all_ctrls.automation_type
	  ,all_ctrls.control_frequency
	  ,upper(nvl(all_ctrls.key_mitigating,'N'))
	  ,upper(nvl(all_ctrls.disclosure_control,'N'))
	  ,(select max(rev_num) from amw_controls_b where control_id=all_ctrls.control_id) /*latest_rev_num*/
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
      ,agpv.period_year
      ,agpv.period_num
      ,agpv.quarter_num
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num)||to_char(agpv.period_num))
      ,to_number(to_char(agpv.period_year)||to_char(agpv.quarter_num))
      ,agpv.period_year
      ,to_number(to_char(agpv.end_date,'J'))
	  ,sysdate
	  ,G_USER_ID
	  ,sysdate
	  ,G_USER_ID
	  ,G_LOGIN_ID
  FROM AMW_CONTROL_ASSOCIATIONS ctrls,
       AMW_CONTROLS_ALL_VL all_ctrls,
       HR_ALL_ORGANIZATION_UNITS o,
       HR_ALL_ORGANIZATION_UNITS_TL otl,
       AMW_OPINIONS_LOG_V op,
       amw_certification_vl acv,
       amw_fin_cert_scope afcs,
	   amw_gl_periods_v agpv
 WHERE ctrls.object_type = 'RISK_FINCERT'
   and ctrls.control_rev_id = all_ctrls.control_rev_id
   and all_ctrls.APPROVAL_STATUS = 'A'
   and o.organization_id = ctrls.pk2
   and o.organization_id = otl.organization_id
   and otl.language = userenv('LANG')
   and op.opinion_log_id(+)  = ctrls.pk5
   and op.AUDIT_RESULT_CODE <> 'EFFECTIVE'
   and acv.certification_id = ctrls.pk1
   and afcs.fin_certification_id = ctrls.pk1
   and afcs.organization_id = o.organization_id
   and afcs.process_id = ctrls.pk3
   and acv.certification_period_name = agpv.period_name
   and acv.certification_period_set_name = agpv.period_set_name;


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
    WHERE fact_name                 = 'RCI_ORG_CERT_CTRLS_F' ;


   commit;
   retcode := C_OK;
EXCEPTION
   WHEN OTHERS THEN
      retcode := C_ERROR;
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM || ':' || l_message, l_proc_name, l_stmnt_id));
      ROLLBACK;
      RAISE;
END incr_load;

/*****
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
BEGIN
   l_user_id                := NVL(fnd_global.USER_ID, -1);
   l_login_id               := NVL(fnd_global.LOGIN_ID, -1);
   l_program_id             := NVL(fnd_global.CONC_PROGRAM_ID,-1);
   l_program_login_id       := NVL(fnd_global.CONC_LOGIN_ID,-1);
   l_program_application_id := NVL(fnd_global.PROG_APPL_ID,-1);
   l_request_id             := NVL(fnd_global.CONC_REQUEST_ID,-1);

   l_stmnt_id := 10;
   l_proc_name := 'run_incr_load_drm';
   l_last_run_date := get_last_run_date('RCI_ORG_CERT_CTRLS_F');

   IF l_last_run_date IS NULL THEN
      l_message := 'Please launch the Initial Load Request Set for the Organization Certification Summary page.';
      RAISE INITIALIZATION_ERROR;
   END IF;

   l_stmnt_id := 20;
   l_run_date := sysdate - 5/(24*60);
   ---l_master_org  := get_master_organization_id;

   l_stmnt_id := 30;
   EXECUTE IMMEDIATE ('TRUNCATE TABLE ' || g_rci_schema || '.RCI_ORG_CERT_CTRLS_F');

   l_stmnt_id := 40;

   INSERT INTO RCI_ORG_CERT_CTRLS_F(
      fin_certification_id
     ,certification_id
     ,certification_status
     ,certification_type
     ,certification_period_name
     ,certification_period_set_name
     ,organization_id
	 ,process_id
	 ,natural_account_id
	 ,control_id
	 ,control_rev_id
	 ,control_type
	 ,control_location
	 ,automation_type
	 ,control_frequency
	 ,key_control
	 ,disclosure_control
	 ,latest_rev_num
	 ,audit_result_code
	 ,last_evaluated_by_id
	 ,last_evaluated_on
	 ,op_eff_id
	 ,des_eff_id
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
      SELECT DISTINCT acv2.certification_id,
		     ctrlassoc.pk1,
	         acv.certification_status,
	         acv.certification_type,
		     acv.certification_period_name,
		     acv.certification_period_set_name,
	         orgtable.organization_id,
	         procorg.process_id,
			 afkav.natural_account_id,
	         controltable.control_id,
		     ctrlassoc.control_rev_id,
		     controltable.control_type,
		     controltable.control_location,
		     controltable.automation_type,
		     controltable.control_frequency,
		     nvl(controltable.key_mitigating,'N'),
		     nvl(controltable.disclosure_control,'N'),
		     (select max(rev_num) from amw_controls_b where control_id=controltable.control_id),
	         opinionstable.audit_result_code,
	         opinionstable.last_updated_by,
	         opinionstable.authored_date,
	         (SELECT valuestable.opinion_value_id
		        FROM amw_opinion_log_details details,
			         amw_opinion_values_tl valuestable,
			         amw_opinion_componts_b compb
		       WHERE opinionstable.opinion_log_id = details.opinion_log_id
		         AND details.opinion_component_id = compb.opinion_component_id
		         AND compb.object_opinion_type_id = opinionstable.object_opinion_type_id
		         AND compb.opinion_component_code = 'OPERATING'
		         AND valuestable.language = userenv('LANG')
		         AND details.opinion_value_id = valuestable.opinion_value_id ),
		     (SELECT valuestable.opinion_value_id
		        FROM amw_opinion_log_details details,
		             amw_opinion_values_tl valuestable,
		             amw_opinion_componts_b compb
		       WHERE opinionstable.opinion_log_id = details.opinion_log_id
		         AND details.opinion_component_id = compb.opinion_component_id
		         AND compb.object_opinion_type_id = opinionstable.object_opinion_type_id
		         AND compb.opinion_component_code = 'DESIGN'
		         AND valuestable.language = userenv('LANG')
		         AND details.opinion_value_id = valuestable.opinion_value_id ),
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
	    FROM amw_control_associations ctrlassoc,
	         amw_controls_all_vl controltable,
	         amw_audit_units_v orgtable,
	         amw_opinions_log_v opinionstable,
	         amw_execution_scope execs,
	         AMW_PROCESS_ORGANIZATION_VL procorg,
	         amw_certification_vl acv,
		     amw_certification_vl acv2,
		     AMW_FIN_PROC_CERT_RELAN afpcr,
		     (select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa,
		     AMW_FIN_KEY_ACCOUNTS_VL AFKAV
		    ,amw_gl_periods_v agpv
	   WHERE execs.entity_id            = ctrlassoc.pk1
	     AND execs.entity_type          = ctrlassoc.object_type
	     AND execs.organization_id      = orgtable.organization_id
	     AND procorg.process_org_rev_id(+) = execs.process_org_rev_id
	     AND ctrlassoc.control_rev_id   = controltable.control_rev_id
	     AND ctrlassoc.pk5              = opinionstable.opinion_log_id (+)
	     AND ctrlassoc.object_type      = 'BUSIPROC_CERTIFICATION'
	     AND ctrlassoc.pk2              = orgtable.organization_id
	     AND NVL(ctrlassoc.pk3,-1)      = NVL(execs.process_id,-1)
	     and acv.certification_id       = execs.entity_id
	     and opinionstable.audit_result_code <> 'EFFECTIVE'
	     and opinionstable.OBJECT_NAME  = 'AMW_ORG_CONTROL'
	     and opinionstable.OPINION_TYPE_CODE = 'EVALUATION'
   		 and afpcr.PROC_CERT_ID = acv.CERTIFICATION_ID
	     and afpcr.END_DATE is null
	     and afpcr.FIN_STMT_CERT_ID = acv2.CERTIFICATION_ID
	     and acv2.object_type='FIN_STMT'
	     and aaa.pk1(+) = execs.organization_id
	     and aaa.pk2(+) = execs.process_id
	     and aaa.natural_account_id = afkav.natural_account_id(+)
		 and acv.certification_period_name = agpv.period_name
   		 and acv.certification_period_set_name = agpv.period_set_name
       order by acv2.certification_id,ctrlassoc.pk1,orgtable.organization_id,procorg.process_id,controltable.control_id;


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
    WHERE fact_name                 = 'RCI_ORG_CERT_CTRLS_F' ;


   commit;
   retcode := C_OK;
EXCEPTION
   WHEN OTHERS THEN
      retcode := C_ERROR;
      BIS_COLLECTION_UTILITIES.PUT_LINE (err_mesg (SQLERRM || ':' || l_message, l_proc_name, l_stmnt_id));
      ROLLBACK;
      RAISE;
END incr_load;
***/

END RCI_CTRL_DETAIL_ETL_PKG;

/
