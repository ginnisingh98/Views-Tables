--------------------------------------------------------
--  DDL for Package Body AMW_PROCCERT_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PROCCERT_EVENT_PVT" AS
/* $Header: amwvpceb.pls 120.11 2005/11/17 20:36:10 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_PROCCERT_EVENT_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
g_pkg_name    CONSTANT VARCHAR2 (30) := 'AMW_PROCCERT_EVENT_PVT';
g_file_name   CONSTANT VARCHAR2 (12) := 'amwvpceb.pls';
l_index number;

PROCEDURE populate_assoc_opinion (
	  p_certification_id  IN NUMBER)
IS
  CURSOR c_obj_opin_type_id (c_obj_name VARCHAR2) IS
    SELECT aoot.object_opinion_type_id
      FROM AMW_OBJECT_OPINION_TYPES aoot, AMW_OPINION_TYPES_B aot,
           FND_OBJECTS fo
     WHERE aoot.OPINION_TYPE_ID = aot.OPINION_TYPE_ID
       AND aoot.OBJECT_ID = fo.OBJECT_ID
       AND aot.opinion_type_code = 'EVALUATION'
       AND fo.obj_name = c_obj_name;

  l_obj_opinion_type_id	 NUMBER;
BEGIN

  OPEN c_obj_opin_type_id ('AMW_ORG_PROCESS_RISK');
  FETCH c_obj_opin_type_id INTO l_obj_opinion_type_id;
  CLOSE c_obj_opin_type_id;

  UPDATE amw_risk_associations assoc
     SET last_update_date = sysdate,
         last_updated_by = fnd_global.user_id,
	 last_update_login = fnd_global.conc_login_id,
         pk4 = (SELECT max(opinion_log_id)
                  FROM amw_opinions_log opin
		 WHERE opin.object_opinion_type_id = l_obj_opinion_type_id
		   AND opin.pk1_value = assoc.risk_id
		   AND opin.pk3_value = assoc.pk2	-- organization_id
		   AND NVL(opin.pk4_value, -1)
		          = NVL(assoc.pk3, -1))	-- process_id
   WHERE pk1 = p_certification_id
     AND pk4 IS NULL;



  OPEN c_obj_opin_type_id ('AMW_ORG_CONTROL');
  FETCH c_obj_opin_type_id INTO l_obj_opinion_type_id;
  CLOSE c_obj_opin_type_id;

  UPDATE amw_control_associations assoc
     SET last_update_date = sysdate,
         last_updated_by = fnd_global.user_id,
	 last_update_login = fnd_global.conc_login_id,
	 pk5 = (SELECT max(opinion_log_id)
                  FROM amw_opinions_log opin
		 WHERE opin.object_opinion_type_id = l_obj_opinion_type_id
		   AND opin.pk1_value = assoc.control_id
		   AND opin.pk3_value = assoc.pk2)	-- organization_id
   WHERE pk1 = p_certification_id
     AND pk5 IS NULL;

  OPEN c_obj_opin_type_id ('AMW_ORG_AP_CONTROL');
  FETCH c_obj_opin_type_id INTO l_obj_opinion_type_id;
  CLOSE c_obj_opin_type_id;

  UPDATE amw_ap_associations assoc
     SET last_update_date = sysdate,
         last_updated_by = fnd_global.user_id,
	 last_update_login = fnd_global.conc_login_id,
	 pk4 = (SELECT max(opinion_log_id)
                  FROM amw_opinions_log opin
		 WHERE opin.object_opinion_type_id = l_obj_opinion_type_id
		   AND opin.pk1_value = assoc.pk3
		   AND opin.pk3_value = assoc.pk2 	-- organization_id
		   AND opin.pk4_value = assoc.audit_procedure_id) -- control_id
   WHERE pk1 = p_certification_id
     AND pk4 IS NULL;
END populate_assoc_opinion;


FUNCTION Scope_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2
IS
  CURSOR c_new_org(c_cert_id NUMBER) IS
    SELECT organization_id
      FROM amw_org_cert_eval_sum
     WHERE certification_id = c_cert_id
       AND unmitigated_risks IS NULL;

  CURSOR c_new_proc(c_cert_id NUMBER) IS
    SELECT organization_id, process_id
      FROM amw_proc_cert_eval_sum
     WHERE certification_id = c_cert_id
       AND unmitigated_risks IS NULL;

  CURSOR c_org_proc(c_cert_id NUMBER, c_org_id NUMBER) IS
    SELECT process_id
      FROM amw_proc_cert_eval_sum
     WHERE certification_id = c_cert_id
       AND organization_id = c_org_id;

  CURSOR c_start_date(c_cert_id NUMBER) IS
    	SELECT period.start_date
          FROM AMW_CERTIFICATION_B cert, AMW_GL_PERIODS_V period
         WHERE cert.certification_period_name = period.period_name
           AND cert.certification_period_set_name = period.period_set_name
           AND cert.certification_id = c_cert_id;

  CURSOR c_fch_vs_id IS
       select flex_value_set_id
         from fnd_flex_value_sets
        where flex_value_set_name = 'FCH_ICM_ENTITY_VALUE_SET';

  l_cert_id		     NUMBER;
  l_org_id		     NUMBER;
  l_mode		     VARCHAR2(30);
  l_start_date		     DATE;

  l_return_status	     VARCHAR2(30);
  l_msg_count_char		     VARCHAR2(2000);
  l_msg_count		     NUMBER;
  l_msg_data		     VARCHAR2(2000);

  l_fch_vs_id number;

l_errbuf VARCHAR2(2000);
l_retcode NUMBER;

BEGIN

  SAVEPOINT Scope_Update_Event;

  l_cert_id := p_event.GetValueForParameter('CERTIFICATION_ID');
  l_mode := p_event.GetValueForParameter('MODE');

  IF l_mode = 'AddToScope' THEN
    -- to support org hierarchy, need to update the org denorm
    -- for all the orgs in the certification
    AMW_ORG_CERT_EVAL_SUM_PVT.populate_org_cert_sum_spec (
             p_certification_id  => l_cert_id);

    -- do not need to update the prcess denorm for the existing
    -- org.
    FOR proc_rec IN c_new_proc(l_cert_id) LOOP
      AMW_PROCESS_CERT_SUMMARY.update_summary_table (
		p_certification_id => l_cert_id,
		p_org_id	   => proc_rec.organization_id,
		p_process_id	   => proc_rec.process_id);
    END LOOP;

    populate_assoc_opinion(l_cert_id);

  ELSIF l_mode = 'ManageProc' THEN
    l_org_id := p_event.GetValueForParameter('ORGANIZATION_ID');
    -- only update the passed org, as there is no impact
    -- on other orgs in the org hierarchy.
    AMW_ORG_CERT_EVAL_SUM_PVT.populate_summary (
	p_api_version_number        => 1.0,
	p_org_id 		    => l_org_id,
	p_certification_id 	    => l_cert_id,
	x_return_status             => l_return_status,
	x_msg_count                 => l_msg_count,
	x_msg_data                  => l_msg_data);

    -- to support proc hierarchy, need to update the proc denorm
    -- for all the processes in the certification-organization.
    FOR proc_rec IN c_org_proc(l_cert_id, l_org_id) LOOP
      AMW_PROCESS_CERT_SUMMARY.update_summary_table (
		p_certification_id => l_cert_id,
		p_org_id	   => l_org_id,
		p_process_id	   => proc_rec.process_id);
    END LOOP;

    populate_assoc_opinion(l_cert_id);

  ELSIF l_mode = 'RemoveFromScope' THEN
    -- to support org hierarchy, need to update the org denorm
    -- for all the orgs in the certification
    AMW_ORG_CERT_EVAL_SUM_PVT.populate_org_cert_sum_spec (
             p_certification_id  => l_cert_id);
  END IF;

  OPEN c_start_date(l_cert_id);
  FETCH c_start_date INTO l_start_date;
  CLOSE c_start_date;
  AMW_PROCESS_CERT_SUMMARY.Populate_Cert_General_Sum(
       l_cert_id, l_start_date);

  OPEN c_fch_vs_id;
  FETCH c_fch_vs_id into l_fch_vs_id;
  CLOSE c_fch_vs_id;

  IF fnd_profile.value('AMW_SUBSIDIARY_AUDIT_UNIT') = to_char(l_fch_vs_id) THEN
  amw_org_cert_aggr_pkg.populate_full_hierarchies(l_errbuf,l_retcode,l_cert_id);
  END IF;

  commit;
  Return 'SUCCESS';

EXCEPTION
  WHEN OTHERS  THEN
     ROLLBACK TO Scope_Update_Event;

     FND_MESSAGE.SET_NAME( 'AMW', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AMW_PROCCERT_EVENT_PVT', 'SCOPE_UPDATE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END Scope_Update;


FUNCTION Evaluation_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2
IS
  CURSOR c_opinion_rec (c_opinion_log_id NUMBER) IS
    SELECT opinion_id, object_name, audit_result_code,
	   pk1_value, pk2_value, pk3_value, pk4_value, pk5_value,
	   pk6_value, pk7_value, pk8_value
      FROM amw_opinions_log_v
     WHERE opinion_log_id = c_opinion_log_id;

  CURSOR c_cert_with_proc (c_proc_id NUMBER, c_org_id NUMBER) IS
    SELECT cert.certification_id, opin.audit_result_code old_eval
      FROM amw_certification_b cert, amw_proc_cert_eval_sum psum,
           amw_opinions_log_v opin
     WHERE cert.certification_status in ('ACTIVE','DRAFT')
       AND cert.certification_id = psum.certification_id
       AND psum.organization_id = c_org_id
       AND psum.process_id = c_proc_id
       AND psum.evaluation_opinion_log_id = opin.opinion_log_id(+);

  CURSOR c_cert_with_risk (c_risk_id NUMBER, c_proc_id NUMBER, c_org_id NUMBER) IS
    SELECT cert.certification_id, opin.audit_result_code old_eval
      FROM amw_certification_b cert, amw_risk_associations assoc,
           amw_opinions_log_v opin
     WHERE cert.certification_status in ('ACTIVE','DRAFT')
       AND cert.certification_id = assoc.pk1
       AND assoc.object_type = 'BUSIPROC_CERTIFICATION'
       AND assoc.risk_id = c_risk_id
       AND assoc.pk2 = c_org_id
       AND NVL(assoc.pk3, -1) = NVL(c_proc_id, -1)
       AND assoc.pk4 = opin.opinion_log_id(+);

  CURSOR c_cert_with_ctrl (c_ctrl_id NUMBER, c_org_id NUMBER) IS
    SELECT cert.certification_id, opin.audit_result_code old_eval
      FROM amw_certification_b cert, amw_control_associations assoc,
           amw_opinions_log_v opin
     WHERE cert.certification_status in ('ACTIVE','DRAFT')
       AND cert.certification_id = assoc.pk1
       AND assoc.object_type = 'BUSIPROC_CERTIFICATION'
       AND assoc.control_id = c_ctrl_id
       AND assoc.pk2 = c_org_id
       AND assoc.pk5 = opin.opinion_log_id(+);



CURSOR Get_org_cert(l_cert_id number, l_org_id number) IS
SELECT ineff_processes, processes_certified, total_processes, evaluated_processes,unmitigated_risks,
evaluated_risks, total_risks, ineffective_controls, evaluated_controls, total_controls
FROM amw_org_cert_eval_sum
WHERE certification_id = l_cert_id
AND organization_id = l_org_id;

CURSOR Get_Dashboard_Info(l_cert_id number) IS
SELECT UNMITIGATED_RISKS, INEFFECTIVE_CONTROLS, PROC_INEFF_CONTROL, ORG_PROC_INEFF_CONTROL
FROM amw_cert_dashboard_sum
WHERE certification_id = l_cert_id;

CURSOR Get_proc_cert_info(l_cert_id number, l_org_id number, l_process_id number) IS
SELECT  ineffective_controls, evaluated_controls, total_controls, unmitigated_risks, evaluated_risks, total_risks
FROM amw_proc_cert_eval_sum
 WHERE certification_id = l_cert_id
           AND organization_id = l_org_id
           AND process_id IN (
	          SELECT process_id
		    FROM amw_execution_scope
	      START WITH process_id = l_process_id
		     AND organization_id = l_org_id
		     AND entity_id = l_cert_id
		     AND entity_type = 'BUSIPROC_CERTIFICATION'
	      CONNECT BY process_id = PRIOR parent_process_id
	     	     AND organization_id = PRIOR organization_id
		     AND entity_id = PRIOR entity_id
		     AND entity_type = PRIOR entity_type);

CURSOR FCH_Get_cert_info(l_org_id number) IS
SELECT certification_id
FROM amw_org_cert_eval_sum
WHERE organization_id = l_org_id
AND certification_id IN (
	          SELECT cert.certification_id
		    FROM amw_certification_b cert
                   WHERE cert.certification_status in ('ACTIVE','DRAFT')
		     AND cert.object_type = 'PROCESS');

  CURSOR c_fch_vs_id IS
       select flex_value_set_id
         from fnd_flex_value_sets
        where flex_value_set_name = 'FCH_ICM_ENTITY_VALUE_SET';


M_org_ineff_proc number;
M_org_proc_cert number;
M_org_proc_total number;
M_org_proc_eval number;
M_org_unmitigated_risk number;
M_org_risk_eval number;
M_org_risk_total number;
M_org_ineff_ctrl number;
M_org_ctrl_eval number;
M_org_ctrl_total number;


M_dashbd_proc_not_cert number;
M_dashbd_proc_cert_issue number;
M_dashbd_org_proc_not_cert number;
M_dashbd_org_proc_cert_issue number;
M_dashbd_unmitigated_risk number;
M_dashbd_ineff_ctrl number;
M_dashbd_proc_ineff_ctrl number;
M_dashbd_org_proc_ineff_ctrl number;

M_proc_ineffective_controls number;
M_proc_evaluated_controls number;
M_proc_total_controls number;
M_proc_unmitigated_risks number;
M_proc_evaluated_risks number;
M_proc_total_risks number;

l_fch_vs_id number;



  l_opin_log_id	     NUMBER;
  l_opin_id	     NUMBER;
  l_obj_name	     VARCHAR2(200);
  l_new_eval	     VARCHAR2(200);
  l_pk1		     NUMBER;
  l_pk2		     NUMBER;
  l_pk3		     NUMBER;
  l_pk4		     NUMBER;
  l_pk5		     NUMBER;
  l_pk6		     NUMBER;
  l_pk7		     NUMBER;
  l_pk8		     NUMBER;

  l_msg_data	    VARCHAR2(2000);
  l_msg_count_char		     VARCHAR2(2000);
  l_msg_count		     NUMBER;

  l_fch_org_id 	NUMBER;

BEGIN

  SAVEPOINT Evaluation_Update_Event;

  g_refresh_flag := 'N';
  l_opin_log_id := p_event.GetValueForParameter('OPINION_LOG_ID');

  OPEN c_opinion_rec(l_opin_log_id);
  FETCH c_opinion_rec INTO l_opin_id, l_obj_name, l_new_eval, l_pk1,
		      l_pk2, l_pk3, l_pk4, l_pk5, l_pk6, l_pk7, l_pk8;
  CLOSE c_opinion_rec;

  IF l_obj_name = 'AMW_ORGANIZATION' THEN
    -- find all the active proc cert that having this org
    -- update amw_org_cert_eval_sum.evaluation_opinion_log_id
    UPDATE amw_org_cert_eval_sum
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   evaluation_opinion_id = l_opin_id,
           evaluation_opinion_log_id = l_opin_log_id
     WHERE organization_id = l_pk1
       AND certification_id IN (
	          SELECT cert.certification_id
		    FROM amw_certification_b cert, amw_execution_scope scope
                   WHERE cert.certification_status in ('ACTIVE','DRAFT')
		     AND cert.object_type = 'PROCESS'
                     AND scope.entity_type = 'BUSIPROC_CERTIFICATION'
		     AND scope.entity_id = cert.certification_id
		     AND scope.level_id = 3
		     AND scope.organization_id = l_pk1);

      -- set organization_id for FCH
       l_fch_org_id := l_pk1;

  ELSIF l_obj_name = 'AMW_ORG_PROCESS' THEN
      -- set organization_id for FCH
       l_fch_org_id := l_pk3;

    -- find all the active proc cert that having this org
   FOR proc_rec IN c_cert_with_proc(l_pk1, l_pk3) LOOP
--get the affected columns
   OPEN Get_org_cert(proc_rec.certification_id, l_pk3);
   FETCH Get_org_cert  INTO m_org_ineff_proc, m_org_proc_cert, m_org_proc_total,m_org_proc_eval,m_org_unmitigated_risk,
   		              m_org_risk_eval,m_org_risk_total,m_org_ineff_ctrl,m_org_ctrl_eval,m_org_ctrl_total;
   CLOSE Get_org_cert;

   OPEN Get_Dashboard_Info(proc_rec.certification_id);
   FETCH Get_Dashboard_Info  INTO M_dashbd_unmitigated_risk, M_dashbd_ineff_ctrl, M_dashbd_proc_ineff_ctrl, M_dashbd_org_proc_ineff_ctrl;
   CLOSE Get_Dashboard_Info;

      IF proc_rec.old_eval IS NULL AND l_new_eval <> 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(proc_rec.certification_id)) OR (g_refresh_flag = 'Y') OR ((M_org_proc_eval + 1 < M_org_proc_total)  AND  (M_org_ineff_proc + 1 <  M_org_proc_eval))) THEN
  	g_refresh_flag := 'Y';
  	m_certification_list(proc_rec.certification_id) := proc_rec.certification_id;
ELSE
*****/
UPDATE amw_org_cert_eval_sum
	   SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       evaluated_processes = least(evaluated_processes+1,total_processes),
	       ineff_processes = least(ineff_processes+1,evaluated_processes+1,total_processes),
	       ineff_processes_prcnt = decode(total_processes, 0, 0,
	           round(least(ineff_processes+1,evaluated_processes+1,total_processes)/total_processes*100))
	 WHERE certification_id = proc_rec.certification_id
	   AND organization_id = l_pk3;
--END IF;
	IF l_pk3 = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
	  UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 proc_ineff_control = proc_ineff_control+1
  	   WHERE certification_id = proc_rec.certification_id;
        ELSE
	  UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 org_proc_ineff_control = org_proc_ineff_control+1
  	   WHERE certification_id = proc_rec.certification_id;
        END IF;

      ELSIF proc_rec.old_eval IS NULL AND l_new_eval = 'EFFECTIVE' THEN
/**********IF(M_org_proc_eval + 1 > M_org_proc_total) THEN
********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(proc_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  (M_org_proc_eval + 1 < M_org_proc_total)) THEN
  			G_REFRESH_FLAG := 'Y';
  			m_certification_list(proc_rec.certification_id) := proc_rec.certification_id;
ELSE
*********/
UPDATE amw_org_cert_eval_sum
	   SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       evaluated_processes = least(evaluated_processes+1, total_processes)
	 WHERE certification_id = proc_rec.certification_id
	   AND organization_id = l_pk3;
--END IF;

      ELSIF proc_rec.old_eval = 'EFFECTIVE' AND l_new_eval <> 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(proc_rec.certification_id)) OR (g_refresh_flag = 'Y') OR (M_org_ineff_proc + 1 < m_org_proc_eval) ) THEN
       -- IF(M_org_ineff_proc + 1 > m_org_proc_eval) THEN
  		g_refresh_flag := 'Y';
  		m_certification_list(proc_rec.certification_id) := proc_rec.certification_id;
ELSE
*****/
        UPDATE amw_org_cert_eval_sum
	   SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       ineff_processes = least(ineff_processes+1,evaluated_processes,total_processes),
	       ineff_processes_prcnt = decode(total_processes, 0, 0,
	           round(least(ineff_processes+1,evaluated_processes,total_processes)/total_processes*100))
	 WHERE certification_id = proc_rec.certification_id
	   AND organization_id = l_pk3;
--END IF;
	IF l_pk3 = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
	  UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 proc_ineff_control = proc_ineff_control+1
  	   WHERE certification_id = proc_rec.certification_id;
        ELSE
	  UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 org_proc_ineff_control = org_proc_ineff_control+1
  	   WHERE certification_id = proc_rec.certification_id;
        END IF;

      ELSIF proc_rec.old_eval <> 'EFFECTIVE' AND l_new_eval = 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(proc_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  (M_org_ineff_proc - 1 > 0 ) ) THEN
       -- IF(M_org_ineff_proc - 1 < 0 ) THEN
  			G_REFRESH_FLAG := 'Y';
  			m_certification_list(proc_rec.certification_id) := proc_rec.certification_id;
ELSE
*************/
        UPDATE amw_org_cert_eval_sum
	   SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       ineff_processes = greatest(0,ineff_processes-1),
	       ineff_processes_prcnt = decode(total_processes, 0, 0,
	           round(greatest(0,ineff_processes-1)/total_processes*100))
	 WHERE certification_id = proc_rec.certification_id
	   AND organization_id = l_pk3;
--END IF;
	IF l_pk3 = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
    IF NOT ( (m_certification_list.exists(proc_rec.certification_id)) OR (g_refresh_flag = 'Y') OR (M_dashbd_proc_ineff_ctrl -1 >  0 ) ) THEN
  			g_refresh_flag := 'Y';
  		m_certification_list(proc_rec.certification_id) := proc_rec.certification_id;

ELSE
**********/
	  UPDATE amw_cert_dashboard_sum
             SET last_update_date = sysdate,
                 last_updated_by = fnd_global.user_id,
	         last_update_login = fnd_global.conc_login_id,
		 proc_ineff_control = greatest(0,proc_ineff_control-1)
  	   WHERE certification_id = proc_rec.certification_id;
--END IF;
        ELSE
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
        	IF NOT ( (m_certification_list.exists(proc_rec.certification_id)) OR  (M_dashbd_org_proc_ineff_ctrl -1 > 0 )  OR (g_refresh_flag = 'Y') ) THEN
  	  		m_certification_list(proc_rec.certification_id) := proc_rec.certification_id;
	ELSE
*******/
 	UPDATE amw_cert_dashboard_sum
             	SET 	last_update_date = sysdate,
                 		last_updated_by = fnd_global.user_id,
	        	 last_update_login = fnd_global.conc_login_id,
		 org_proc_ineff_control = greatest(0,org_proc_ineff_control-1)
 	WHERE certification_id = proc_rec.certification_id;
--END IF;
END IF;
      END IF;
    END LOOP;

    -- update amw_proc_cert_eval_sum.evaluation_opinion_log_id
    UPDATE amw_proc_cert_eval_sum
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
           evaluation_opinion_id = l_opin_id,
           evaluation_opinion_log_id = l_opin_log_id
     WHERE process_id = l_pk1
       AND organization_id = l_pk3
       AND certification_id in (
	          SELECT cert.certification_id
		    FROM amw_certification_b cert, amw_proc_cert_eval_sum psum
                   WHERE cert.certification_status in ('ACTIVE','DRAFT')
		     AND cert.certification_id = psum.certification_id
		     AND psum.organization_id = l_pk3
		     AND psum.process_id = l_pk1);

  ELSIF l_obj_name = 'AMW_ORG_PROCESS_RISK' THEN
      -- set organization_id for FCH
       l_fch_org_id := l_pk3;

    -- find all the active proc cert that having this org-proc-risk
    FOR risk_rec IN c_cert_with_risk(l_pk1, l_pk4, l_pk3) LOOP

   --get the affected columns
     OPEN Get_org_cert(risk_rec.certification_id, l_pk3);
   FETCH Get_org_cert  INTO m_org_ineff_proc, m_org_proc_cert, m_org_proc_total,m_org_proc_eval,m_org_unmitigated_risk,
   		              m_org_risk_eval,m_org_risk_total,m_org_ineff_ctrl,m_org_ctrl_eval,m_org_ctrl_total;
   CLOSE Get_org_cert;

   OPEN Get_Dashboard_Info(risk_rec.certification_id);
   FETCH Get_Dashboard_Info  INTO M_dashbd_unmitigated_risk, M_dashbd_ineff_ctrl, M_dashbd_proc_ineff_ctrl, M_dashbd_org_proc_ineff_ctrl;
   CLOSE Get_Dashboard_Info;

    OPEN Get_proc_cert_info(risk_rec.certification_id, l_pk3, l_pk4);
   FETCH Get_proc_cert_info  INTO m_proc_ineffective_controls,m_proc_evaluated_controls ,m_proc_total_controls ,m_proc_unmitigated_risks ,m_proc_evaluated_risks ,m_proc_total_risks;
   CLOSE Get_proc_cert_info;


      IF risk_rec.old_eval IS NULL AND l_new_eval <> 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b *********/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF ((m_org_risk_eval + 1 >  m_org_risk_total)  or (m_org_unmitigated_risk + 1 > m_org_risk_eval)) THEN
  IF NOT ( (m_certification_list.exists(risk_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  ((m_org_risk_eval + 1 <  m_org_risk_total)  AND (m_org_unmitigated_risk + 1 < m_org_risk_eval)) ) THEN
  			g_refresh_flag := 'Y';
  		m_certification_list(risk_rec.certification_id) := risk_rec.certification_id;
ELSE
***********/
UPDATE amw_org_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       evaluated_risks = least(evaluated_risks+1,total_risks),
	       unmitigated_risks = least(unmitigated_risks+1,evaluated_risks+1,total_risks),
	       unmitigated_risks_prcnt = decode(total_risks, 0, 0,
	           round(least(unmitigated_risks+1,evaluated_risks+1,total_risks)/total_risks*100))
         WHERE certification_id = risk_rec.certification_id
           AND organization_id = l_pk3;
--END IF;

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
  /********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(risk_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  ((m_proc_evaluated_risks + 1 <  m_proc_total_risks)  AND (m_proc_unmitigated_risks + 1 <  m_proc_evaluated_risks)) ) THEN
    --    	IF ((m_proc_evaluated_risks + 1 >  m_proc_total_risks)  or (m_proc_unmitigated_risks + 1 > m_proc_evaluated_risks)) THEN
  			g_refresh_flag := 'Y';
			m_certification_list(risk_rec.certification_id) := risk_rec.certification_id;
ELSE
**********/
        UPDATE amw_proc_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       evaluated_risks = least(evaluated_risks+1,total_risks),
	       unmitigated_risks = least(unmitigated_risks+1,evaluated_risks+1,total_risks),
	       unmitigated_risks_prcnt = decode(total_risks, 0, 0,
	           round(least(unmitigated_risks+1,evaluated_risks+1,total_risks)/total_risks*100))
         WHERE certification_id = risk_rec.certification_id
           AND organization_id = l_pk3
           AND process_id IN (
	          SELECT process_id
		    FROM amw_execution_scope
	      START WITH process_id = l_pk4
		     AND organization_id = l_pk3
		     AND entity_id = risk_rec.certification_id
		     AND entity_type = 'BUSIPROC_CERTIFICATION'
	      CONNECT BY process_id = PRIOR parent_process_id
	     	     AND organization_id = PRIOR organization_id
		     AND entity_id = PRIOR entity_id
		     AND entity_type = PRIOR entity_type);
--END IF;

        UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       unmitigated_risks = unmitigated_risks+1
  	 WHERE certification_id = risk_rec.certification_id;

      ELSIF risk_rec.old_eval IS NULL AND l_new_eval = 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
 /********* remove 'IF' logic now because the refresh logic is disabled temporarily
 IF NOT ( (m_certification_list.exists(risk_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  (m_org_risk_eval + 1 <  m_org_risk_total) ) THEN
        	----IF (m_org_risk_eval + 1 >  m_org_risk_total)  THEN
  			g_refresh_flag := 'Y';
			m_certification_list(risk_rec.certification_id) := risk_rec.certification_id;
ELSE
****/
        UPDATE amw_org_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       evaluated_risks = least(evaluated_risks+1,total_risks)
         WHERE certification_id = risk_rec.certification_id
           AND organization_id = l_pk3;
--END IF;
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
 IF NOT ( (m_certification_list.exists(risk_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  (m_proc_evaluated_risks + 1 <   m_proc_total_risks)  ) THEN
        	------IF (m_proc_evaluated_risks + 1 >  m_proc_total_risks)   THEN
  			g_refresh_flag := 'Y';
			m_certification_list(risk_rec.certification_id) := risk_rec.certification_id;
ELSE
**************/
UPDATE amw_proc_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       evaluated_risks = least(evaluated_risks+1,total_risks)
         WHERE certification_id = risk_rec.certification_id
           AND organization_id = l_pk3
           AND process_id IN (
	          SELECT process_id
		    FROM amw_execution_scope
	      START WITH process_id = l_pk4
		     AND organization_id = l_pk3
		     AND entity_id = risk_rec.certification_id
		     AND entity_type = 'BUSIPROC_CERTIFICATION'
	      CONNECT BY process_id = PRIOR parent_process_id
	     	     AND organization_id = PRIOR organization_id
		     AND entity_id = PRIOR entity_id
		     AND entity_type = PRIOR entity_type);
--END IF;
      ELSIF risk_rec.old_eval = 'EFFECTIVE' AND l_new_eval <> 'EFFECTIVE' THEN
/***************** If the display format is a/b/c, then a >= 0 and b>= a and c>= b
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
 IF NOT ( (m_certification_list.exists(risk_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  (m_org_unmitigated_risk + 1 < m_org_risk_eval) ) THEN
  			g_refresh_flag := 'Y';
 			m_certification_list(risk_rec.certification_id) := risk_rec.certification_id;
ELSE
*************/
UPDATE amw_org_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       unmitigated_risks = least(unmitigated_risks+1,evaluated_risks,total_risks),
	       unmitigated_risks_prcnt = decode(total_risks, 0, 0,
	           round(least(unmitigated_risks+1,evaluated_risks,total_risks)/total_risks*100))
         WHERE certification_id = risk_rec.certification_id
           AND organization_id = l_pk3;
-- END IF;

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********IF  (m_proc_unmitigated_risks + 1 > m_proc_evaluated_risks) THEN   ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
 IF NOT ( (m_certification_list.exists(risk_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  (m_proc_unmitigated_risks + 1 <  m_proc_evaluated_risks) ) THEN
  			g_refresh_flag := 'Y';
			m_certification_list( risk_rec.certification_id) := risk_rec.certification_id;
ELSE
**********/
 UPDATE amw_proc_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       unmitigated_risks = least(unmitigated_risks+1,evaluated_risks,total_risks),
	       unmitigated_risks_prcnt = decode(total_risks, 0, 0,
	           round(least(unmitigated_risks+1,evaluated_risks,total_risks)/total_risks*100))
         WHERE certification_id = risk_rec.certification_id
           AND organization_id = l_pk3
           AND process_id IN (
	          SELECT process_id
		    FROM amw_execution_scope
	      START WITH process_id = l_pk4
		     AND organization_id = l_pk3
		     AND entity_id = risk_rec.certification_id
		     AND entity_type = 'BUSIPROC_CERTIFICATION'
	      CONNECT BY process_id = PRIOR parent_process_id
	     	     AND organization_id = PRIOR organization_id
		     AND entity_id = PRIOR entity_id
		     AND entity_type = PRIOR entity_type);
--END IF;
        UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       unmitigated_risks = unmitigated_risks+1
  	 WHERE certification_id = risk_rec.certification_id;

      ELSIF risk_rec.old_eval <> 'EFFECTIVE' AND l_new_eval = 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
*****************IF (m_org_unmitigated_risk -1 < 0 ) THEN     ************************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(risk_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  (m_org_unmitigated_risk -1 >  0 ) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(risk_rec.certification_id) := risk_rec.certification_id;
ELSE
******************/
        UPDATE amw_org_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       unmitigated_risks = greatest(0,unmitigated_risks-1),
	       unmitigated_risks_prcnt = decode(total_risks, 0, 0,
	           round(greatest(0,unmitigated_risks-1)/total_risks*100))
         WHERE certification_id = risk_rec.certification_id
           AND organization_id = l_pk3;
--END IF;

/*************** If the display format is a/b/c, then a >= 0 and b>= a and c>= b
****************IF (m_proc_unmitigated_risks - 1 < 0 ) THEN   ***********************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(risk_rec.certification_id)) OR (g_refresh_flag = 'Y') OR (m_proc_unmitigated_risks - 1 > 0 ) ) THEN
  			g_refresh_flag := 'Y';
			m_certification_list(risk_rec.certification_id) := risk_rec.certification_id;
ELSE
************/
UPDATE amw_proc_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       unmitigated_risks = greatest(0,unmitigated_risks-1),
	       unmitigated_risks_prcnt = decode(total_risks, 0, 0,
	           round(greatest(0,unmitigated_risks-1)/total_risks*100))
         WHERE certification_id = risk_rec.certification_id
           AND organization_id = l_pk3
           AND process_id IN (
	          SELECT process_id
		    FROM amw_execution_scope
	      START WITH process_id = l_pk4
		     AND organization_id = l_pk3
		     AND entity_id = risk_rec.certification_id
		     AND entity_type = 'BUSIPROC_CERTIFICATION'
	      CONNECT BY process_id = PRIOR parent_process_id
	     	     AND organization_id = PRIOR organization_id
		     AND entity_id = PRIOR entity_id
		     AND entity_type = PRIOR entity_type);
--END IF;

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  *********
**********IF ((m_dashbd_unmitigated_risk -1 < 0 )  THEN       ****************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(risk_rec.certification_id)) OR (g_refresh_flag = 'Y') OR (m_dashbd_unmitigated_risk -1 > 0 ) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(risk_rec.certification_id) := risk_rec.certification_id;
ELSE
************/
        UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       unmitigated_risks = greatest(0,unmitigated_risks-1)
  	 WHERE certification_id = risk_rec.certification_id;
--END IF;
      END IF;
    END LOOP;

    -- update amw_risk_association.pk4 with evaluation_opinion_log_id
    UPDATE amw_risk_associations
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
           pk4 = l_opin_log_id
     WHERE object_type = 'BUSIPROC_CERTIFICATION'
       AND risk_id = l_pk1
       AND pk2 = l_pk3	-- organization_id
       AND NVL(pk3,-1) = NVL(l_pk4,-1)	-- process_id
       AND pk1 IN (
	          SELECT assoc.pk1
		    FROM amw_certification_b cert, amw_risk_associations assoc
                   WHERE cert.certification_status in ('ACTIVE','DRAFT')
		     AND cert.certification_id = assoc.pk1
		     AND assoc.object_type = 'BUSIPROC_CERTIFICATION'
		     AND assoc.risk_id = l_pk1
		     AND assoc.pk2 = l_pk3	-- organization_id
		     AND NVL(assoc.pk3, -1) = NVL(l_pk4, -1));	-- proccess_id

  ELSIF l_obj_name = 'AMW_ORG_CONTROL' THEN
      -- set organization_id for FCH
       l_fch_org_id := l_pk3;


    -- find all the active proc cert that having this org-ctrl
    FOR ctrl_rec IN c_cert_with_ctrl(l_pk1, l_pk3) LOOP
     --get the affected columns
     OPEN Get_org_cert(ctrl_rec.certification_id, l_pk3);
   FETCH Get_org_cert  INTO m_org_ineff_proc, m_org_proc_cert, m_org_proc_total,m_org_proc_eval,m_org_unmitigated_risk,
   		              m_org_risk_eval,m_org_risk_total,m_org_ineff_ctrl,m_org_ctrl_eval,m_org_ctrl_total;
   CLOSE Get_org_cert;

   OPEN Get_Dashboard_Info(ctrl_rec.certification_id);
   FETCH Get_Dashboard_Info  INTO M_dashbd_unmitigated_risk, M_dashbd_ineff_ctrl, M_dashbd_proc_ineff_ctrl, M_dashbd_org_proc_ineff_ctrl;
   CLOSE Get_Dashboard_Info;


   OPEN Get_proc_cert_info(ctrl_rec.certification_id, l_pk3, l_pk4);
   FETCH Get_proc_cert_info  INTO m_proc_ineffective_controls,m_proc_evaluated_controls ,m_proc_total_controls ,m_proc_unmitigated_risks ,m_proc_evaluated_risks ,m_proc_total_risks;
   CLOSE Get_proc_cert_info;


      IF ctrl_rec.old_eval IS NULL AND l_new_eval <> 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********     	IF ((m_org_ctrl_eval + 1 >  m_org_ctrl_total)  or (m_org_ineff_ctrl + 1 > m_org_ctrl_eval)) THEN ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
   IF NOT ( (m_certification_list.exists(ctrl_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  ((m_org_ctrl_eval + 1 <  m_org_ctrl_total)  AND (m_org_ineff_ctrl + 1 < m_org_ctrl_eval)) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(ctrl_rec.certification_id) := ctrl_rec.certification_id;
ELSE
**********/
UPDATE amw_org_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       evaluated_controls = least(evaluated_controls+1,total_controls),
	       ineffective_controls = least(ineffective_controls+1,evaluated_controls+1,total_controls),
	       ineff_controls_prcnt = decode(total_controls, 0, 0,
	           round(least(ineffective_controls+1,evaluated_controls+1,total_controls)/total_controls*100))
         WHERE certification_id = ctrl_rec.certification_id
           AND organization_id = l_pk3;
--END IF;

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
 ********  IF ((m_proc_evaluated_controls  + 1 >  m_proc_total_controls )  or (m_proc_ineffective_controls + 1 > m_proc_evaluated_controls )) THEN  ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
   IF NOT ( (m_certification_list.exists(ctrl_rec.certification_id)) OR (g_refresh_flag = 'Y') OR ((m_proc_evaluated_controls  + 1 <  m_proc_total_controls )  AND  (m_proc_ineffective_controls + 1 <  m_proc_evaluated_controls )) ) THEN
  			g_refresh_flag := 'Y';
			m_certification_list(ctrl_rec.certification_id) := ctrl_rec.certification_id;
ELSE
************/
        UPDATE amw_proc_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       evaluated_controls = least(evaluated_controls+1,total_controls),
	       ineffective_controls = least(ineffective_controls+1,evaluated_controls+1,total_controls),
	       ineffective_controls_prcnt = decode(total_controls, 0, 0,
	           round(least(ineffective_controls+1,evaluated_controls+1,total_controls)/total_controls*100))
         WHERE certification_id = ctrl_rec.certification_id
           AND organization_id = l_pk3
           AND process_id IN (
	          SELECT process_id
		    FROM amw_execution_scope --, amw_control_associations assoc
	      START WITH process_id IN (
				    SELECT pk3
				      FROM amw_control_associations
				     WHERE object_type = 'BUSIPROC_CERTIFICATION'
				       AND control_id = l_pk1
				       AND pk1 = ctrl_rec.certification_id
				       AND pk2 = l_pk3)  -- organization_id
		     AND organization_id = l_pk3
		     AND entity_id = ctrl_rec.certification_id
		     AND entity_type = 'BUSIPROC_CERTIFICATION'
	      CONNECT BY process_id = PRIOR parent_process_id
	     	     AND organization_id = PRIOR organization_id
		     AND entity_id = PRIOR entity_id
		     AND entity_type = PRIOR entity_type);
--END IF;
        UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       ineffective_controls = ineffective_controls+1
  	 WHERE certification_id = ctrl_rec.certification_id;

      ELSIF ctrl_rec.old_eval IS NULL AND l_new_eval = 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
*********IF (m_org_ctrl_eval + 1 >  m_org_ctrl_total)  THEN  *******************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(ctrl_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  (m_org_ctrl_eval + 1 <  m_org_ctrl_total) ) THEN
  			g_refresh_flag := 'Y';
 			m_certification_list(ctrl_rec.certification_id) := ctrl_rec.certification_id;
ELSE
***********/
UPDATE amw_org_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       evaluated_controls = least(evaluated_controls+1,total_controls)
         WHERE certification_id = ctrl_rec.certification_id
           AND organization_id = l_pk3;
--END IF;

--CHECK AGAIN WHY NOT LOOP
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
********* IF (m_proc_evaluated_controls  + 1 >  m_proc_total_controls )  THEN  ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(ctrl_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  (m_proc_evaluated_controls  + 1 <  m_proc_total_controls ) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(ctrl_rec.certification_id) := ctrl_rec.certification_id;
ELSE
**************/
 UPDATE amw_proc_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       evaluated_controls = least(evaluated_controls+1,total_controls)
         WHERE certification_id = ctrl_rec.certification_id
           AND organization_id = l_pk3
           AND process_id IN (
	          SELECT process_id
		    FROM amw_execution_scope --, amw_control_associations assoc
	      START WITH process_id IN (
				    SELECT pk3
				      FROM amw_control_associations
				     WHERE object_type = 'BUSIPROC_CERTIFICATION'
				       AND control_id = l_pk1
				       AND pk1 = ctrl_rec.certification_id
				       AND pk2 = l_pk3)  -- organization_id
		     AND organization_id = l_pk3
		     AND entity_id = ctrl_rec.certification_id
		     AND entity_type = 'BUSIPROC_CERTIFICATION'
	      CONNECT BY process_id = PRIOR parent_process_id
	     	     AND organization_id = PRIOR organization_id
		     AND entity_id = PRIOR entity_id
		     AND entity_type = PRIOR entity_type);
--END IF;

      ELSIF ctrl_rec.old_eval = 'EFFECTIVE' AND l_new_eval <> 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********IF (m_org_ineff_ctrl + 1 > m_org_ctrl_eval)  THEN  *****************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(ctrl_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  (m_org_ineff_ctrl + 1 < m_org_ctrl_eval) ) THEN
  			g_refresh_flag := 'Y';
			m_certification_list(ctrl_rec.certification_id) := ctrl_rec.certification_id;
ELSE
*********/
UPDATE amw_org_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       ineffective_controls = least(ineffective_controls+1,evaluated_controls,total_controls),
	       ineff_controls_prcnt = decode(total_controls, 0, 0,
	           round(least(ineffective_controls+1,evaluated_controls,total_controls)/total_controls*100))
         WHERE certification_id = ctrl_rec.certification_id
           AND organization_id = l_pk3;
--END IF;

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
***********IF  (m_proc_ineffective_controls + 1 > m_proc_evaluated_controls ) THEN   ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(ctrl_rec.certification_id)) OR (g_refresh_flag = 'Y') OR (m_proc_ineffective_controls + 1 <  m_proc_evaluated_controls ) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(ctrl_rec.certification_id) := ctrl_rec.certification_id;
ELSE
***********/
UPDATE amw_proc_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       ineffective_controls = least(ineffective_controls+1,evaluated_controls,total_controls),
	       ineffective_controls_prcnt = decode(total_controls, 0, 0,
	           round(least(ineffective_controls+1,evaluated_controls,total_controls)/total_controls*100))
         WHERE certification_id = ctrl_rec.certification_id
           AND organization_id = l_pk3
           AND process_id IN (
	          SELECT process_id
		    FROM amw_execution_scope --, amw_control_associations assoc
	      START WITH process_id IN (
				    SELECT pk3
				      FROM amw_control_associations
				     WHERE object_type = 'BUSIPROC_CERTIFICATION'
				       AND control_id = l_pk1
				       AND pk1 = ctrl_rec.certification_id
				       AND pk2 = l_pk3)  -- organization_id
		     AND organization_id = l_pk3
		     AND entity_id = ctrl_rec.certification_id
		     AND entity_type = 'BUSIPROC_CERTIFICATION'
	      CONNECT BY process_id = PRIOR parent_process_id
	     	     AND organization_id = PRIOR organization_id
		     AND entity_id = PRIOR entity_id
		     AND entity_type = PRIOR entity_type);
--END IF;

        UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       ineffective_controls = ineffective_controls+1
  	 WHERE certification_id = ctrl_rec.certification_id;

      ELSIF ctrl_rec.old_eval <> 'EFFECTIVE' AND l_new_eval = 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**************IF (m_org_ineff_ctrl -1 < 0 ) THEN    *************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(ctrl_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  (m_org_ineff_ctrl -1 >  0 ) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(ctrl_rec.certification_id) := ctrl_rec.certification_id;
ELSE
***********/
 UPDATE amw_org_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       ineffective_controls = greatest(0,ineffective_controls-1),
	       ineff_controls_prcnt = decode(total_controls, 0, 0,
	           round(greatest(0,ineffective_controls-1)/total_controls*100))
         WHERE certification_id = ctrl_rec.certification_id
           AND organization_id = l_pk3;
--END IF;


/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**************IF (m_proc_ineffective_controls -1 < 0 ) THEN  *******************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(ctrl_rec.certification_id)) OR (g_refresh_flag = 'Y') OR  (m_proc_ineffective_controls -1 > 0 ) ) THEN
  			g_refresh_flag := 'Y';
			m_certification_list(ctrl_rec.certification_id) := ctrl_rec.certification_id;
ELSE
************/
        UPDATE amw_proc_cert_eval_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       ineffective_controls = greatest(0,ineffective_controls-1),
	       ineffective_controls_prcnt = decode(total_controls, 0, 0,
	           round(greatest(0,ineffective_controls-1)/total_controls*100))
         WHERE certification_id = ctrl_rec.certification_id
           AND organization_id = l_pk3
           AND process_id IN (
	          SELECT process_id
		    FROM amw_execution_scope --, amw_control_associations assoc
	      START WITH process_id IN (
				    SELECT pk3
				      FROM amw_control_associations
				     WHERE object_type = 'BUSIPROC_CERTIFICATION'
				       AND control_id = l_pk1
				       AND pk1 = ctrl_rec.certification_id
				       AND pk2 = l_pk3)  -- organization_id
		     AND organization_id = l_pk3
		     AND entity_id = ctrl_rec.certification_id
		     AND entity_type = 'BUSIPROC_CERTIFICATION'
	      CONNECT BY process_id = PRIOR parent_process_id
	     	     AND organization_id = PRIOR organization_id
		     AND entity_id = PRIOR entity_id
		     AND entity_type = PRIOR entity_type);
--END IF;

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********IF ((m_dashbd_ineff_ctrl -1 < 0 )  THEN   ****************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(ctrl_rec.certification_id)) OR (g_refresh_flag = 'Y') OR (m_dashbd_ineff_ctrl -1 >  0 ) ) THEN
  			g_refresh_flag := 'Y';
 			m_certification_list(ctrl_rec.certification_id) := ctrl_rec.certification_id;
ELSE
*************/
 UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       ineffective_controls = greatest(0,ineffective_controls-1)
  	 WHERE certification_id = ctrl_rec.certification_id;
--END IF;
      END IF;
    END LOOP;

    -- update amw_contrl_associations.pk5 with evaluation_opinion_log_id
    UPDATE amw_control_associations
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   pk5 = l_opin_log_id
     WHERE object_type = 'BUSIPROC_CERTIFICATION'
       AND control_id = l_pk1
       AND pk2 = l_pk3	-- organization_id
       AND pk1 IN (
	          SELECT assoc.pk1
		    FROM amw_certification_b cert, amw_control_associations assoc
                   WHERE cert.certification_status in ('ACTIVE','DRAFT')
		     AND cert.certification_id = assoc.pk1
		     AND assoc.object_type = 'BUSIPROC_CERTIFICATION'
		     AND assoc.control_id = l_pk1
		     AND assoc.pk2 = l_pk3);	-- organization_id

  ELSIF l_obj_name = 'AMW_ORG_AP_CONTROL' THEN
    UPDATE amw_ap_associations
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   pk4 = l_opin_log_id
     WHERE object_type = 'BUSIPROC_CERTIFICATION'
       AND audit_procedure_id = l_pk1
       AND pk2 = l_pk3	-- organization_id
       AND pk3 = l_pk4	-- control_id
       AND pk1 IN (
	          SELECT assoc.pk1
		    FROM amw_certification_b cert, amw_ap_associations assoc
                   WHERE cert.certification_status in ('ACTIVE','DRAFT')
		     AND cert.certification_id = assoc.pk1
		     AND assoc.object_type = 'BUSIPROC_CERTIFICATION'
		     AND assoc.audit_procedure_id = l_pk1
		     AND assoc.pk2 = l_pk3 	-- organization_id
		     AND assoc.pk3 = l_pk4);    -- control_id

  END IF;


 --refresh all of the summary tables amw_cert_dashboard_sum, amw_proc_cert_eval_sum, amw_org_cert_eval_sum
-- IF (G_REFRESH_FLAG = 'Y') THEN
--l_index := m_certification_list.FIRST;
--WHILE  l_index <= m_certification_list.LAST LOOP

--AMW_PROCESS_CERT_SUMMARY.POPULATE_ALL_CERT_SUMMARY
--(x_errbuf => l_msg_data,
-- x_retcode => l_msg_count,
-- p_certification_id =>  m_certification_list(l_index)
--);

--AMW_PROCESS_CERT_SUMMARY.Populate_All_Cert_General_Sum
--(errbuf => l_msg_data,
-- retcode => l_msg_count,
-- p_certification_id =>  m_certification_list(l_index)
--);

--AMW_ORG_CERT_EVAL_SUM_PVT.populate_org_cert_summary
--(x_errbuf => l_msg_data,
-- x_retcode => l_msg_count,
-- p_certification_id =>  m_certification_list(l_index)
--);
-- l_index := l_index + 1;
--END LOOP;

--END IF;

 OPEN c_fch_vs_id;
  FETCH c_fch_vs_id into l_fch_vs_id;
  CLOSE c_fch_vs_id;

  IF fnd_profile.value('AMW_SUBSIDIARY_AUDIT_UNIT') = to_char(l_fch_vs_id) THEN

       FOR FCH_Get_cert_info_rec IN FCH_Get_cert_info(l_fch_org_id) LOOP
       amw_org_cert_aggr_pkg.update_org_cert_aggr_rows(FCH_Get_cert_info_rec.certification_id, l_fch_org_id);
       END LOOP;


  END IF;


  -- somehow the change was not being committed to db without
  -- the following commit. so we temporarily put commit here, and we
  -- still need to invetigate why the transaction was not committed
  -- automatically.
  commit;
  Return 'SUCCESS';

EXCEPTION
  WHEN OTHERS  THEN
     ROLLBACK TO Evaluation_Update_Event;

     FND_MESSAGE.SET_NAME( 'AMW', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AMW_PROCCERT_EVENT_PVT', 'EVALUATION_UPDATE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END Evaluation_Update;

FUNCTION Certification_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2
IS
  CURSOR c_opinion_rec (c_opinion_log_id NUMBER) IS
    SELECT opinion_id, object_name, audit_result_code,
	   pk1_value, pk2_value, pk3_value, pk4_value, pk5_value,
	   pk6_value, pk7_value, pk8_value
      FROM amw_opinions_log_v
     WHERE opinion_log_id = c_opinion_log_id;

  CURSOR c_old_opinion (c_opin_log_id NUMBER) IS
    SELECT audit_result_code
      FROM amw_opinions_log_v
     WHERE opinion_log_id =
			  (SELECT max(v2.opinion_log_id)
			     FROM amw_opinions_log_v v1, amw_opinions_log_v v2
			    WHERE v1.opinion_log_id = c_opin_log_id
			      AND v1.opinion_id = v2.opinion_id
			      AND v2.opinion_log_id < c_opin_log_id);

  CURSOR c_orgs_pending_in_scope(c_cert_id NUMBER) IS
    SELECT count(distinct aes.organization_id)
      FROM AMW_EXECUTION_SCOPE aes
     WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
       AND aes.entity_id = c_cert_id
       AND aes.level_id = 4
       AND not exists (SELECT 'Y'
                         FROM AMW_OPINIONS_V aov
                        WHERE aov.object_name = 'AMW_ORG_PROCESS'
                          AND aov.opinion_type_code = 'CERTIFICATION'
                          AND aov.pk3_value = aes.organization_id
                          AND aov.pk2_value = c_cert_id
                          AND aov.pk1_value = aes.process_id);

CURSOR Get_org_cert(l_cert_id number, l_org_id number) IS
SELECT organization_id, sub_org_cert,  total_sub_org , sub_org_cert_issues, proc_cert_issues, processes_certified, total_processes
FROM amw_org_cert_eval_sum
WHERE certification_id = l_cert_id
AND organization_id IN (
	           SELECT parent_object_id
		     FROM amw_entity_hierarchies
	       START WITH entity_type = 'BUSIPROC_CERTIFICATION'
		      AND entity_id = l_org_id
		      AND object_type = 'ORG'
		      AND object_id = l_cert_id
               CONNECT BY entity_type = PRIOR entity_type
		      AND entity_id = PRIOR entity_id
		      AND object_type = PRIOR object_type
		      AND object_id = PRIOR parent_object_id);




CURSOR Get_Dashboard_Info(l_cert_id number) IS
SELECT orgs_pending_certification,  processes_cert_issues, processes_not_cert, org_process_cert_issues, org_process_not_cert
FROM amw_cert_dashboard_sum
WHERE certification_id = l_cert_id;

CURSOR Get_cert_dashboard(l_cert_id number) IS
SELECT processes_not_cert, org_process_not_cert, processes_cert_issues, org_process_cert_issues
FROM amw_cert_dashboard_sum
WHERE certification_id = l_cert_id;

CURSOR c_org_cert(l_cert_id number, l_org_id number) IS
SELECT processes_certified, total_processes, proc_cert_issues
FROM amw_org_cert_eval_sum
WHERE certification_id = l_cert_id
AND organization_id = l_org_id;


CURSOR Get_parent_process(l_cert_id number, l_org_id number, l_process_id number) IS
SELECT certification_id, organization_id, process_id, sub_process_cert, total_sub_process_cert, sub_process_cert_issues
FROM amw_proc_cert_eval_sum
       WHERE certification_id = l_cert_id
         AND organization_id = l_org_id
	 AND process_id in (
	          SELECT parent_process_id
		    FROM amw_execution_scope
	      START WITH entity_type = 'BUSIPROC_CERTIFICATION'
		     AND entity_id = l_cert_id
		     AND organization_id = l_org_id
		     AND process_id = l_process_id
              CONNECT BY entity_type = PRIOR entity_type
		     AND entity_id = PRIOR entity_id
		     AND organization_id = PRIOR organization_id
		     AND process_id = PRIOR parent_process_id);

CURSOR Get_related_org_proc(l_cert_id number, l_org_id number, l_process_id number) IS
SELECT certification_id, organization_id, process_id, org_process_cert, org_process_cert_issues, total_org_process_cert
FROM amw_proc_cert_eval_sum
 WHERE certification_id = l_cert_id
         AND (process_id = l_process_id
	      OR
              process_id IN (
	         SELECT proc.process_id
		   FROM amw_execution_scope scp,
		        amw_process_organization procorg,
			amw_process proc
		  WHERE scp.entity_id = l_cert_id
		    AND scp.entity_type = 'BUSIPROC_CERTIFICATION'
		    AND scp.organization_id = l_org_id
		    AND scp.process_id = l_process_id
		    AND scp.process_org_rev_id = procorg.process_org_rev_id
		    AND procorg.standard_variation = proc.process_rev_id))
	 AND organization_id in (
                   SELECT parent_object_id
		     FROM amw_entity_hierarchies
	       START WITH entity_type = 'BUSIPROC_CERTIFICATION'
		      AND entity_id = l_cert_id
		      AND object_type = 'ORG'
		      AND object_id = l_org_id
               CONNECT BY entity_type = PRIOR entity_type
		      AND entity_id = PRIOR entity_id
		      AND object_type = PRIOR object_type
		      AND object_id = PRIOR parent_object_id);

  CURSOR c_fch_vs_id IS
       select flex_value_set_id
         from fnd_flex_value_sets
        where flex_value_set_name = 'FCH_ICM_ENTITY_VALUE_SET';

M_dashbd_org_pending_cert number;
M_dashbd_org_proc_cert_issues number;
M_dashbd_org_process_not_cert number;
M_dashbd_proc_cert_issues number;
M_dashbd_proc_not_cert number;
M_dashbd_org_proc_not_cert number;

M_org_cert_proc_certified number;
M_org_cert_total_proc number;
M_org_cert_proc_cert_issues number;

  l_opin_log_id	     NUMBER;
  l_opin_id	     NUMBER;
  l_obj_name	     VARCHAR2(200);
  l_new_cert	     VARCHAR2(200);
  l_pk1		     NUMBER;
  l_pk2		     NUMBER;
  l_pk3		     NUMBER;
  l_pk4		     NUMBER;
  l_pk5		     NUMBER;
  l_pk6		     NUMBER;
  l_pk7		     NUMBER;
  l_pk8		     NUMBER;
  l_old_cert	     VARCHAR2(200);
  l_orgs_pending     NUMBER;
  l_msg_data 	    VARCHAR2(2000);
   l_msg_count_char		     VARCHAR2(200);
  l_msg_count		     NUMBER;

  l_fch_org_id NUMBER;
  l_fch_cert_id NUMBER;

  l_fch_vs_id NUMBER;


BEGIN

  SAVEPOINT Certification_Update_Event;

  g_refresh_flag := 'N';
  l_opin_log_id := p_event.GetValueForParameter('OPINION_LOG_ID');

  OPEN c_opinion_rec(l_opin_log_id);
  FETCH c_opinion_rec INTO l_opin_id, l_obj_name, l_new_cert, l_pk1,
		      l_pk2, l_pk3, l_pk4, l_pk5, l_pk6, l_pk7, l_pk8;
  CLOSE c_opinion_rec;


  IF l_obj_name = 'AMW_ORGANIZATION' THEN
  	--set organization_id, certification_id for FCH
  	l_fch_org_id := l_pk1;
  	l_fch_cert_id := l_pk2;

    OPEN c_old_opinion(l_opin_log_id);
    FETCH c_old_opinion INTO l_old_cert;
    CLOSE c_old_opinion;

    UPDATE amw_org_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
             certification_opinion_id = l_opin_id
       WHERE certification_id = l_pk2
         AND organization_id = l_pk1;


  OPEN Get_Dashboard_Info(l_pk2);
  FETCH Get_Dashboard_Info INTO m_dashbd_org_pending_cert,  m_dashbd_proc_cert_issues, m_dashbd_proc_not_cert, m_dashbd_org_proc_cert_issues, m_dashbd_org_process_not_cert;
  CLOSE Get_Dashboard_Info;

 IF l_old_cert IS NULL THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********IF(m_dashbd_org_pending_cert - 1 < 0 ) THEN   ************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
  IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR (m_dashbd_org_pending_cert - 1 >  0 ) ) THEN
  			g_refresh_flag := 'Y';
 			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
*************/
UPDATE amw_cert_dashboard_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     orgs_pending_certification = greatest(0,orgs_pending_certification-1)
       WHERE certification_id = l_pk1;
--END IF;

     END IF;

    --find all of parent organizations
    FOR Get_org_cert_Rec in Get_org_cert(l_pk1, l_pk2) LOOP
	 exit when Get_org_cert %notfound;

    IF l_old_cert IS NULL AND l_new_cert = 'EFFECTIVE' THEN

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********IF(get_org_cert_rec.sub_org_cert  + 1 > get_org_cert_rec.total_sub_org) THEN   ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR (get_org_cert_rec.sub_org_cert  + 1 <  get_org_cert_rec.total_sub_org) ) THEN
  			g_refresh_flag := 'Y';
			m_certification_list(l_pk2) := l_pk2;
			goto refresh_all_records;
ELSE
************/
        UPDATE amw_org_cert_eval_sum
         SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   sub_org_cert = least(sub_org_cert+1,total_sub_org)
       WHERE certification_id = l_pk1
       AND organization_id = Get_org_cert_Rec.organization_id;
--END IF;
    ELSIF l_old_cert IS NULL AND l_new_cert <> 'EFFECTIVE' THEN

/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
*********IF((get_org_cert_rec.sub_org_cert  + 1 > get_org_cert_rec.total_sub_org) or (get_org_cert_rec.sub_org_cert_issues + 1 > get_org_cert_rec.sub_org_cert ))THEN  ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR ((get_org_cert_rec.sub_org_cert  + 1 < get_org_cert_rec.total_sub_org) AND (get_org_cert_rec.sub_org_cert_issues + 1 < get_org_cert_rec.sub_org_cert )) ) THEN
  			g_refresh_flag := 'Y';
			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
***********/
        UPDATE amw_org_cert_eval_sum
         SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   sub_org_cert = least(sub_org_cert+1,total_sub_org),
	   sub_org_cert_issues = least(sub_org_cert_issues+1,sub_org_cert+1,total_sub_org)
       WHERE certification_id = l_pk1
       AND organization_id = Get_org_cert_Rec.organization_id;
-- END IF;

    ELSIF l_old_cert = 'EFFECTIVE' AND l_new_cert <> 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
*********IF (get_org_cert_rec.sub_org_cert_issues + 1 > get_org_cert_rec.sub_org_cert )THEN   ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR  (get_org_cert_rec.sub_org_cert_issues + 1 <  get_org_cert_rec.sub_org_cert ) ) THEN
  			g_refresh_flag := 'Y';
			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
***********/
          UPDATE amw_org_cert_eval_sum
         SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   sub_org_cert_issues = least(sub_org_cert_issues+1,sub_org_cert,total_sub_org)
       WHERE certification_id = l_pk1
       AND organization_id = Get_org_cert_Rec.organization_id;
--END IF;

    ELSIF l_old_cert <> 'EFFECTIVE' AND l_new_cert = 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
*********IF (get_org_cert_rec.sub_org_cert_issues + 1 > get_org_cert_rec.sub_org_cert )THEN   ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR  (get_org_cert_rec.sub_org_cert_issues + 1 <  get_org_cert_rec.sub_org_cert ) ) THEN
  			g_refresh_flag := 'Y';
			m_certification_list( l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
************/
        UPDATE amw_org_cert_eval_sum
         SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   sub_org_cert_issues = greatest(0,sub_org_cert_issues-1)
       WHERE certification_id = l_pk1
       AND organization_id = Get_org_cert_Rec.organization_id;
--END IF;
    END IF;

   END LOOP;

  ELSIF l_obj_name = 'AMW_ORG_PROCESS' THEN

  --set organization_id, certification_id for FCH
  	l_fch_org_id := l_pk3;
  	l_fch_cert_id := l_pk2;


    OPEN c_old_opinion(l_opin_log_id);
    FETCH c_old_opinion INTO l_old_cert;
    CLOSE c_old_opinion;

    OPEN c_orgs_pending_in_scope(l_pk2);
    FETCH c_orgs_pending_in_scope INTO l_orgs_pending;
    CLOSE c_orgs_pending_in_scope;

     UPDATE amw_proc_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     certification_opinion_id = l_opin_id
       WHERE certification_id = l_pk2
         AND organization_id = l_pk3
	 AND process_id = l_pk1;

m_org_cert_proc_certified := 0;
m_org_cert_total_proc := 0;
m_org_cert_proc_cert_issues := 0;
m_dashbd_proc_not_cert := 0;
m_dashbd_org_proc_not_cert := 0;
m_dashbd_proc_cert_issues := 0;
m_dashbd_org_proc_cert_issues := 0;

  OPEN c_org_cert(l_pk2, l_pk3);
  FETCH c_org_cert INTO m_org_cert_proc_certified, m_org_cert_total_proc, m_org_cert_proc_cert_issues;
  CLOSE c_org_cert;

   OPEN Get_cert_dashboard(l_pk2);
  FETCH Get_cert_dashboard INTO m_dashbd_proc_not_cert,m_dashbd_org_proc_not_cert ,m_dashbd_proc_cert_issues ,m_dashbd_org_proc_cert_issues;
  CLOSE Get_cert_dashboard;

    IF l_old_cert IS NULL AND l_new_cert = 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
********* IF (m_org_cert_proc_certified + 1 > m_org_cert_total_proc)THEN   ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR (m_org_cert_proc_certified + 1 <  m_org_cert_total_proc) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
**********/
      UPDATE amw_org_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     processes_certified = least(processes_certified+1,total_processes)
       WHERE certification_id = l_pk2
         AND organization_id = l_pk3;
--END IF;


      IF l_pk3 = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
/************ If the display format is a/b/c, then a >= 0 and b>= a and c>= b
************IF (M_dashbd_proc_not_cert  -1 < 0 )THEN   *************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR  (M_dashbd_proc_not_cert  -1 >  0 ) ) THEN
  			g_refresh_flag := 'Y';
			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
*************/
	UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       orgs_pending_in_scope = l_orgs_pending,
	       processes_not_cert = greatest(0,processes_not_cert-1)
  	 WHERE certification_id = l_pk2;
--END IF;

      ELSE
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
************ IF (M_dashbd_org_proc_not_cert  -1 < 0 )THEN ******* *******/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR (M_dashbd_org_proc_not_cert  -1 >  0 ) ) THEN
  			g_refresh_flag := 'Y';
			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
********/
	UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.conc_login_id,
	       orgs_pending_in_scope = l_orgs_pending,
	       org_process_not_cert = greatest(0,org_process_not_cert-1)
  	 WHERE certification_id = l_pk2;
 --     END IF;
END IF;


    ELSIF l_old_cert IS NULL AND l_new_cert <> 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********IF (m_org_cert_proc_certified + 1 > m_org_cert_total_proc) or (M_org_cert_proc_cert_issues + 1 > m_org_cert_proc_certified)) THEN    ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR ( (m_org_cert_proc_certified + 1 < m_org_cert_total_proc) AND (M_org_cert_proc_cert_issues + 1 < m_org_cert_proc_certified)) ) THEN
  			g_refresh_flag := 'Y';
   			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
***************/
 UPDATE amw_org_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     processes_certified = least(processes_certified+1,total_processes),
	     proc_cert_issues = least(proc_cert_issues+1,processes_certified+1,total_processes)
       WHERE certification_id = l_pk2
         AND organization_id = l_pk3;
--END IF;

      IF l_pk3 = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
	UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       orgs_pending_in_scope = l_orgs_pending,
	       processes_not_cert = greatest(0,processes_not_cert-1),
	       processes_cert_issues = processes_cert_issues+1
  	 WHERE certification_id = l_pk2;
      ELSE

	UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.conc_login_id,
	       orgs_pending_in_scope = l_orgs_pending,
	       org_process_not_cert = greatest(0,org_process_not_cert-1),
	       org_process_cert_issues = org_process_cert_issues+1
  	 WHERE certification_id = l_pk2;
      END IF;

    ELSIF l_old_cert <> 'EFFECTIVE' AND l_new_cert = 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
*********IF (M_org_cert_proc_cert_issues -1 < 0 ) THEN  ***************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR  (M_org_cert_proc_cert_issues -1 > 0 ) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
***********/
      UPDATE amw_org_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     proc_cert_issues = greatest(0,proc_cert_issues-1)
       WHERE certification_id = l_pk2
         AND organization_id = l_pk3;
--END IF;


      IF l_pk3 = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
**********IF (M_dashbd_proc_not_cert  -1 < 0 )THEN   *********************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR   (M_dashbd_proc_not_cert  -1 > 0 ) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
*************/
	UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       orgs_pending_in_scope = l_orgs_pending,
	       processes_cert_issues = greatest(0,processes_cert_issues-1)
  	 WHERE certification_id = l_pk2;
-- END IF;
     ELSE
/***************** If the display format is a/b/c, then a >= 0 and b>= a and c>= b
***************** IF (M_dashbd_org_proc_not_cert  -1 < 0 )THEN    *************************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR  (M_dashbd_org_proc_not_cert  -1 >  0 ) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
**************/
	UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.conc_login_id,
	       orgs_pending_in_scope = l_orgs_pending,
	       org_process_cert_issues = greatest(org_process_cert_issues-1,0)
  	 WHERE certification_id = l_pk2;
--      END IF;
END IF;

    ELSIF l_old_cert = 'EFFECTIVE' AND l_new_cert <> 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
********* IF (M_org_cert_proc_cert_issues + 1 > m_org_cert_proc_certified)  THEN  ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR  (M_org_cert_proc_cert_issues + 1 <  m_org_cert_proc_certified) ) THEN
  			g_refresh_flag := 'Y';
   			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
**************/
      UPDATE amw_org_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     proc_cert_issues = least(proc_cert_issues+1,processes_certified,total_processes)
       WHERE certification_id = l_pk2
         AND organization_id = l_pk3;
--END IF;

      IF l_pk3 = fnd_profile.value('AMW_GLOBAL_ORG_ID') THEN
	UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
	       last_update_login = fnd_global.conc_login_id,
	       orgs_pending_in_scope = l_orgs_pending,
	       processes_cert_issues = processes_cert_issues+1
  	 WHERE certification_id = l_pk2;
      ELSE
	UPDATE amw_cert_dashboard_sum
           SET last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.conc_login_id,
	       orgs_pending_in_scope = l_orgs_pending,
	       org_process_cert_issues = org_process_cert_issues+1
  	 WHERE certification_id = l_pk2;
      END IF;

    END IF;

        --find all of parent organizations
    FOR Get_parent_process_Rec in Get_parent_process(l_pk2, l_pk3, l_pk1) LOOP
	 exit when Get_parent_process %notfound;
    IF l_old_cert IS NULL AND l_new_cert = 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
******        IF (Get_parent_process_Rec.sub_process_cert + 1 > Get_parent_process_Rec.total_sub_process_cert)  THEN  ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR  (Get_parent_process_Rec.sub_process_cert + 1 <  Get_parent_process_Rec.total_sub_process_cert)  ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
************/
        UPDATE amw_proc_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     sub_process_cert = least(sub_process_cert+1,total_sub_process_cert)
       WHERE certification_id = Get_parent_process_Rec.certification_id
         AND organization_id = Get_parent_process_Rec.organization_id
         AND process_id = Get_parent_process_Rec.process_id;
--END IF;

     ELSIF l_old_cert IS NULL AND l_new_cert <> 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
******        IF ( (Get_parent_process_Rec.sub_process_cert + 1 > Get_parent_process_Rec.total_sub_process_cert)
*******    OR  (Get_parent_process_Rec.sub_process_cert_issues + 1 > Get_parent_process_Rec.sub_process_cert)) THEN   ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR  ( (Get_parent_process_Rec.sub_process_cert + 1 <  Get_parent_process_Rec.total_sub_process_cert)
    AND   (Get_parent_process_Rec.sub_process_cert_issues + 1 < Get_parent_process_Rec.sub_process_cert)) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
********/
     UPDATE amw_proc_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     sub_process_cert = least(sub_process_cert+1,total_sub_process_cert),
	     sub_process_cert_issues = least(sub_process_cert_issues+1,sub_process_cert+1,total_sub_process_cert)
       WHERE certification_id = Get_parent_process_Rec.certification_id
        	 AND organization_id = Get_parent_process_Rec.organization_id
         	AND process_id = Get_parent_process_Rec.process_id;
--END IF;

 ELSIF l_old_cert <> 'EFFECTIVE' AND l_new_cert = 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
*********IF  (Get_parent_process_Rec.sub_process_cert_issues - 1 < 0 ) THEN  ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR  (Get_parent_process_Rec.sub_process_cert_issues - 1 >  0 ) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
************/
      UPDATE amw_proc_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     sub_process_cert_issues = greatest(0,sub_process_cert_issues-1)
WHERE certification_id = Get_parent_process_Rec.certification_id
        	 AND organization_id = Get_parent_process_Rec.organization_id
         	AND process_id = Get_parent_process_Rec.process_id;
--END IF;
    ELSIF l_old_cert = 'EFFECTIVE' AND l_new_cert <> 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
*********IF (Get_parent_process_Rec.sub_process_cert_issues + 1 > Get_parent_process_Rec.sub_process_cert ) THEN   ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR   (Get_parent_process_Rec.sub_process_cert_issues + 1 < Get_parent_process_Rec.sub_process_cert ) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
***********/
   UPDATE amw_proc_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     sub_process_cert_issues = least(sub_process_cert_issues+1,sub_process_cert,total_sub_process_cert)
	WHERE certification_id = Get_parent_process_Rec.certification_id
        	 AND organization_id = Get_parent_process_Rec.organization_id
         	AND process_id = Get_parent_process_Rec.process_id;
--    END IF;
END IF;
    END LOOP;

       --find related org processes
    FOR Get_related_org_proc_Rec in Get_related_org_proc(l_pk2, l_pk3, l_pk1) LOOP
	 exit when Get_related_org_proc %notfound;

  IF l_old_cert IS NULL AND l_new_cert = 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
********* IF (Get_related_org_proc_Rec.org_process_cert  + 1 > Get_related_org_proc_Rec.total_org_process_cert) THEN   ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR (Get_related_org_proc_Rec.org_process_cert  + 1 <  Get_related_org_proc_Rec.total_org_process_cert) )  THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
************/
     UPDATE amw_proc_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     org_process_cert = least(org_process_cert+1,total_org_process_cert)
       WHERE certification_id = Get_related_org_proc_Rec.certification_id
         AND process_id = Get_related_org_proc_Rec.process_id
         AND organization_id = Get_related_org_proc_Rec.organization_id;
--END IF;


 ELSIF l_old_cert IS NULL AND l_new_cert <> 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
*********  IF ( (Get_related_org_proc_Rec.org_process_cert  + 1 > Get_related_org_proc_Rec.total_org_process_cert)  or
*******(  (Get_related_org_proc_Rec.org_process_cert_issues  + 1 > Get_related_org_proc_Rec.org_process_cert)  ) THEN ****/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR  ( (Get_related_org_proc_Rec.org_process_cert  + 1 <  Get_related_org_proc_Rec.total_org_process_cert)
and   (Get_related_org_proc_Rec.org_process_cert_issues  + 1 <  Get_related_org_proc_Rec.org_process_cert) )  ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
***************/
  UPDATE amw_proc_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     org_process_cert = least(org_process_cert+1,total_org_process_cert),
	     org_process_cert_issues = least(org_process_cert_issues+1,org_process_cert+1,total_org_process_cert)
    WHERE certification_id = Get_related_org_proc_Rec.certification_id
         AND process_id = Get_related_org_proc_Rec.process_id
         AND organization_id = Get_related_org_proc_Rec.organization_id;
-- END IF;

     ELSIF l_old_cert <> 'EFFECTIVE' AND l_new_cert = 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
******* IF (Get_related_org_proc_Rec.org_process_cert_issues  -1 < 0 ) THEN   ********************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR   (Get_related_org_proc_Rec.org_process_cert_issues  -1 >  0 ) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
************/
       UPDATE amw_proc_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     org_process_cert_issues = greatest(0,org_process_cert_issues-1)
       WHERE certification_id = Get_related_org_proc_Rec.certification_id
         AND process_id = Get_related_org_proc_Rec.process_id
         AND organization_id = Get_related_org_proc_Rec.organization_id;
-- END IF;

      ELSIF l_old_cert = 'EFFECTIVE' AND l_new_cert <> 'EFFECTIVE' THEN
/********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b
******* IF (Get_related_org_proc_Rec.org_process_cert_issues  + 1 > Get_related_org_proc_Rec.org_process_cert ) THEN   ********************/
/********* remove 'IF' logic now because the refresh logic is disabled temporarily
IF NOT ( (m_certification_list.exists(l_pk2)) OR (g_refresh_flag = 'Y') OR    (Get_related_org_proc_Rec.org_process_cert_issues  + 1 <  Get_related_org_proc_Rec.org_process_cert ) ) THEN
  			g_refresh_flag := 'Y';
  			m_certification_list(l_pk2) := l_pk2;
  			goto refresh_all_records;
ELSE
*************/
      UPDATE amw_proc_cert_eval_sum
         SET last_update_date = sysdate,
             last_updated_by = fnd_global.user_id,
	     last_update_login = fnd_global.conc_login_id,
	     org_process_cert_issues = least(org_process_cert_issues+1,org_process_cert,total_org_process_cert)
   WHERE certification_id = Get_related_org_proc_Rec.certification_id
         AND process_id = Get_related_org_proc_Rec.process_id
         AND organization_id = Get_related_org_proc_Rec.organization_id;
--END IF;
   END IF;
   END LOOP;

  END IF;

 <<refresh_all_records>>
   --refresh all of the summary tables amw_cert_dashboard_sum, amw_proc_cert_eval_sum, amw_org_cert_eval_sum
--IF ((G_REFRESH_FLAG = 'Y')  or (G_REFRESH_FLAG = 'y') ) THEN
--l_index := m_certification_list.FIRST;
--WHILE  l_index <= m_certification_list.LAST LOOP

--AMW_PROCESS_CERT_SUMMARY.POPULATE_ALL_CERT_SUMMARY
--(x_errbuf => l_msg_data,
-- x_retcode => l_msg_count,
-- p_certification_id => m_certification_list(l_index)
--);


--AMW_PROCESS_CERT_SUMMARY.Populate_All_Cert_General_Sum
--(errbuf => l_msg_data,
-- retcode => l_msg_count,
-- p_certification_id =>  m_certification_list(l_index)
--);

--AMW_ORG_CERT_EVAL_SUM_PVT.populate_org_cert_summary
--(x_errbuf => l_msg_data,
-- x_retcode => l_msg_count,
-- p_certification_id  => m_certification_list(l_index)
--);

--l_index := l_index + 1;
--END LOOP;

--END IF;

     OPEN c_fch_vs_id;
  FETCH c_fch_vs_id into l_fch_vs_id;
  CLOSE c_fch_vs_id;

  IF fnd_profile.value('AMW_SUBSIDIARY_AUDIT_UNIT') = to_char(l_fch_vs_id) THEN
       amw_org_cert_aggr_pkg.update_org_cert_aggr_rows(l_fch_cert_id, l_fch_org_id);
  END IF;

  -- somehow the change was not being committed to db without
  -- the following commit. so we temporarily put commit here, and we
  -- still need to invetigate why the transaction was not committed
  -- automatically.
  commit;
  Return 'SUCCESS';

EXCEPTION
  WHEN OTHERS  THEN
     ROLLBACK TO Certification_Update_Event;

     FND_MESSAGE.SET_NAME( 'AMW', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AMW_PROCCERT_EVENT_PVT', 'CERTIFICAITON_UPDATE',
		p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END Certification_Update;

END AMW_PROCCERT_EVENT_PVT;

/
