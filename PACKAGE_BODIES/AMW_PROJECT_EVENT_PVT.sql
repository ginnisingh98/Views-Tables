--------------------------------------------------------
--  DDL for Package Body AMW_PROJECT_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PROJECT_EVENT_PVT" AS
/* $Header: amwvpjeb.pls 120.2.12000000.2 2007/08/01 09:12:25 srbalasu ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_PROJECT_EVENT_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
g_pkg_name    CONSTANT VARCHAR2 (30) := 'AMW_PROJECT_EVENT_PVT';
g_file_name   CONSTANT VARCHAR2 (12) := 'amwvpceb.pls';
G_USER_ID     NUMBER  := FND_GLOBAL.USER_ID;
G_LOGIN_ID    NUMBER  := FND_GLOBAL.CONC_LOGIN_ID;

FUNCTION Scope_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2
IS
  CURSOR c_new_org(c_audit_proj_id NUMBER) IS
    SELECT organization_id
      FROM AMW_AUDIT_SCOPE_ORGANIZATIONS
     WHERE audit_project_id = c_audit_proj_id
       AND unmitigated_risks IS NULL;

  CURSOR c_proj_org(c_audit_proj_id NUMBER) IS
    SELECT organization_id
      FROM AMW_AUDIT_SCOPE_ORGANIZATIONS
     WHERE audit_project_id = c_audit_proj_id;


  CURSOR c_new_proc(c_audit_proj_id NUMBER) IS
    SELECT organization_id, process_id
      FROM AMW_AUDIT_SCOPE_PROCESSES
     WHERE audit_project_id = c_audit_proj_id
       AND unmitigated_risks IS NULL;

  CURSOR c_org_proc(c_audit_proj_id NUMBER, c_org_id NUMBER) IS
    SELECT process_id
      FROM AMW_AUDIT_SCOPE_PROCESSES
     WHERE audit_project_id = c_audit_proj_id
       AND organization_id = c_org_id;

  l_audit_proj_id	     NUMBER;
  l_org_id		     NUMBER;
  l_mode		     VARCHAR2(30);
BEGIN

  SAVEPOINT Scope_Update_Event;

  l_audit_proj_id := p_event.GetValueForParameter('AUDIT_PROJECT_ID');
  l_mode := p_event.GetValueForParameter('MODE');

  IF l_mode = 'AddToScope' THEN
    -- to support org hierarchy, need to update the org denorm
    -- for all the orgs in the engagement.
    FOR org_rec IN c_proj_org(l_audit_proj_id) LOOP
      update_org_summary_table (
		p_audit_project_id => l_audit_proj_id,
		p_org_id	   => org_rec.organization_id);
    END LOOP;

    -- populate the denorm table for new processes added into scope
    -- AMW_AUDIT_SCOPE_PROCESSES
    -- do not need to update the prcess denorm for the existing
    -- org.
    FOR proc_rec IN c_new_proc(l_audit_proj_id) LOOP

      update_proc_summary_table (
		p_audit_project_id => l_audit_proj_id,
		p_org_id	   => proc_rec.organization_id,
		p_proc_id	   => proc_rec.process_id);
    END LOOP;

  ELSIF l_mode = 'ManageProc' THEN
    l_org_id := p_event.GetValueForParameter('ORGANIZATION_ID');
    update_org_summary_table (
		p_audit_project_id => l_audit_proj_id,
		p_org_id	   => l_org_id);

    FOR proc_rec IN c_org_proc(l_audit_proj_id, l_org_id) LOOP
      update_proc_summary_table (
		p_audit_project_id => l_audit_proj_id,
		p_org_id	   => l_org_id,
		p_proc_id	   => proc_rec.process_id);
    END LOOP;
  ELSIF l_mode = 'RemoveFromScope' THEN
    -- to support org hierarchy, need to update the org denorm
    -- for all the orgs in the certification
    FOR org_rec IN c_proj_org(l_audit_proj_id) LOOP
      update_org_summary_table (
		p_audit_project_id => l_audit_proj_id,
		p_org_id	   => org_rec.organization_id);
    END LOOP;
  END IF;

  Return 'SUCCESS';

EXCEPTION
  WHEN OTHERS  THEN
     ROLLBACK TO Scope_Update_Event;

     FND_MESSAGE.SET_NAME( 'AMW', 'GENERIC_MESSAGE' );
     FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
     FND_MSG_PUB.ADD;

     WF_CORE.CONTEXT('AMW_PROJECT_EVENT_PVT', 'SCOPE_UPDATE', p_event.getEventName(), p_subscription_guid);
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

  CURSOR c_prev_opinion_rec (c_opinion_id NUMBER, c_opinion_log_id NUMBER) IS
    SELECT audit_result_code
      FROM amw_opinions_log_v
     WHERE opinion_log_id = (SELECT max(opinion_log_id)
			       FROM amw_opinions_log_v
			      WHERE opinion_id = c_opinion_id
			        AND opinion_log_id < c_opinion_log_id);

  l_opin_log_id	     NUMBER;
  l_opin_id	     NUMBER;
  l_obj_name	     VARCHAR2(200);
  l_new_eval	     VARCHAR2(200);
  l_prev_eval	     VARCHAR2(200);
  l_pk1		     NUMBER;
  l_pk2		     NUMBER;
  l_pk3		     NUMBER;
  l_pk4		     NUMBER;
  l_pk5		     NUMBER;
  l_pk6		     NUMBER;
  l_pk7		     NUMBER;
  l_pk8		     NUMBER;

  l_evaluated_diff   NUMBER;
  l_ineff_diff	     NUMBER;
BEGIN

  SAVEPOINT Evaluation_Update_Event;

  l_opin_log_id := p_event.GetValueForParameter('OPINION_LOG_ID');

  OPEN c_opinion_rec(l_opin_log_id);
  FETCH c_opinion_rec INTO l_opin_id, l_obj_name, l_new_eval, l_pk1,
		      l_pk2, l_pk3, l_pk4, l_pk5, l_pk6, l_pk7, l_pk8;
  CLOSE c_opinion_rec;

  OPEN c_prev_opinion_rec(l_opin_id, l_opin_log_id);
  FETCH c_prev_opinion_rec INTO l_prev_eval;
  CLOSE c_prev_opinion_rec;


  select decode(l_prev_eval, null, 1, 0)
    into l_evaluated_diff
    from dual;

  select decode(l_new_eval,
                l_prev_eval, 0,
                'EFFECTIVE', decode(l_prev_eval, null, 0, -1),
		decode(l_prev_eval, 'EFFECTIVE', 1, null, 1, 0))
    into l_ineff_diff
    from dual;

  IF l_obj_name = 'AMW_ORGANIZATION' THEN
    UPDATE amw_audit_scope_organizations
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
           evaluation_opinion_id = l_opin_id
     WHERE organization_id = l_pk1
       AND audit_project_id = l_pk2;

    UPDATE amw_audit_scope_organizations
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   sub_orgs_evaluated = least(sub_orgs_evaluated+l_evaluated_diff,total_sub_orgs),
           ineffective_sub_orgs =
		least(greatest(0,ineffective_sub_orgs+l_ineff_diff),sub_orgs_evaluated+l_evaluated_diff,total_sub_orgs)
     WHERE organization_id IN (
                   SELECT parent_object_id
		     FROM amw_entity_hierarchies
	       START WITH entity_type = 'PROJECT'
		      AND entity_id = l_pk2
		      AND object_type = 'ORG'
		      AND object_id = l_pk1
               CONNECT BY entity_type = PRIOR entity_type
		      AND entity_id = PRIOR entity_id
		      AND object_type = PRIOR object_type
		      AND object_id = PRIOR parent_object_id)
       AND audit_project_id = l_pk2;

  ELSIF l_obj_name = 'AMW_ORG_PROCESS' THEN
    UPDATE amw_audit_scope_processes
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
           evaluation_opinion_id = l_opin_id
     WHERE process_id = l_pk1
       AND audit_project_id = l_pk2
       AND organization_id = l_pk3;

    UPDATE amw_audit_scope_organizations
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   processes_evaluated = least(processes_evaluated+l_evaluated_diff,total_processes),
           ineffective_processes =
		least(greatest(0,ineffective_processes+l_ineff_diff),processes_evaluated+l_evaluated_diff,total_processes)
     WHERE audit_project_id = l_pk2
       AND organization_id = l_pk3;
  ELSIF l_obj_name = 'AMW_ORG_PROCESS_RISK' THEN
    UPDATE amw_audit_scope_organizations
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   risks_evaluated =
                least(risks_evaluated+l_evaluated_diff,total_risks),
           unmitigated_risks =
		least(greatest(0,unmitigated_risks+l_ineff_diff),risks_evaluated+l_evaluated_diff,total_risks)
     WHERE audit_project_id = l_pk2
       AND organization_id = l_pk3;

    UPDATE amw_audit_scope_processes
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   risks_evaluated =
                least(risks_evaluated+l_evaluated_diff,total_risks),
           unmitigated_risks =
		least(greatest(0,unmitigated_risks+l_ineff_diff),risks_evaluated+l_evaluated_diff,total_risks)
     WHERE audit_project_id = l_pk2
       AND organization_id = l_pk3
       AND process_id IN (SELECT process_id
		     FROM amw_execution_scope
	       START WITH process_id = l_pk4
		      AND organization_id = l_pk3
		      AND entity_id = l_pk2
		      AND entity_type = 'PROJECT'
	 CONNECT BY PRIOR parent_process_id = process_id
		      AND organization_id = PRIOR organization_id
		      AND entity_id = PRIOR entity_id
                      AND entity_type = PRIOR entity_type);

  ELSIF l_obj_name = 'AMW_ORG_CONTROL' THEN

    UPDATE amw_audit_scope_organizations
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   controls_evaluated =
	        least(controls_evaluated+l_evaluated_diff,total_controls),
           ineffective_controls =
	        least(greatest(0,ineffective_controls+l_ineff_diff),controls_evaluated+l_evaluated_diff,total_controls)
     WHERE audit_project_id = l_pk2
       AND organization_id = l_pk3;

    UPDATE amw_audit_scope_processes
       SET last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
	   last_update_login = fnd_global.conc_login_id,
	   controls_evaluated =
	        least(controls_evaluated+l_evaluated_diff,total_controls),
           ineffective_controls =
	        least(greatest(0,ineffective_controls+l_ineff_diff),controls_evaluated+l_evaluated_diff,total_controls)
     WHERE audit_project_id = l_pk2
       AND organization_id = l_pk3
       AND process_id IN (SELECT process_id
		     FROM amw_execution_scope
	       START WITH process_id IN ( SELECT pk3
		            FROM amw_control_associations
			   WHERE object_type = 'PROJECT'
			     AND control_id = l_pk1
			     AND pk1 = l_pk2       --audit_project_id
			     AND pk2 = l_pk3       --organization_id
			     )
		      AND organization_id = l_pk3
		      AND entity_id = l_pk2
		      AND entity_type = 'PROJECT'
	 CONNECT BY PRIOR parent_process_id = process_id
		      AND organization_id = PRIOR organization_id
		      AND entity_id = PRIOR entity_id
                      AND entity_type = PRIOR entity_type);
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

     WF_CORE.CONTEXT('AMW_PROJECT_EVENT_PVT', 'EVALUATION_UPDATE', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');

     RETURN 'ERROR';

END Evaluation_Update;


PROCEDURE update_org_summary_table (
	  p_audit_project_id	IN 	NUMBER,
	  p_org_id 		IN 	NUMBER
) IS

  CURSOR get_total_sub_orgs IS
    SELECT count(distinct object_id)
      FROM amw_entity_hierarchies hier
     START WITH entity_id = p_audit_project_id
            AND entity_type = 'PROJECT'
            AND object_type = 'ORG'
            AND parent_object_id = p_org_id
   CONNECT BY entity_type = PRIOR entity_type
	   AND entity_id = PRIOR entity_id
	   AND object_type = PRIOR object_type
	   AND parent_object_id = PRIOR object_id;

  CURSOR get_sub_orgs_evaluated IS
    SELECT count(pk1_value)
      FROM amw_opinions_v
     WHERE opinion_type_code = 'EVALUATION'
       AND object_name = 'AMW_ORGANIZATION'
       AND pk2_value = p_audit_project_id
       AND pk1_value IN (
               SELECT object_id
	         FROM amw_entity_hierarchies
	   START WITH entity_id = p_audit_project_id
                  AND entity_type = 'PROJECT'
                  AND object_type = 'ORG'
                  AND parent_object_id = p_org_id
           CONNECT BY entity_type = PRIOR entity_type
	          AND entity_id = PRIOR entity_id
	          AND object_type = PRIOR object_type
	          AND parent_object_id = PRIOR object_id);

  CURSOR get_ineff_sub_orgs IS
    SELECT count(pk1_value)
      FROM amw_opinions_v
     WHERE opinion_type_code = 'EVALUATION'
       AND object_name = 'AMW_ORGANIZATION'
       AND audit_result_code <> 'EFFECTIVE'
       AND pk2_value = p_audit_project_id
       AND pk1_value IN (
               SELECT object_id
	         FROM amw_entity_hierarchies
	   START WITH entity_id = p_audit_project_id
                  AND entity_type = 'PROJECT'
                  AND object_type = 'ORG'
                  AND parent_object_id = p_org_id
           CONNECT BY entity_type = PRIOR entity_type
	          AND entity_id = PRIOR entity_id
	          AND object_type = PRIOR object_type
	          AND parent_object_id = PRIOR object_id);

  CURSOR get_total_processes IS
    SELECT count(distinct process_id)
      FROM amw_execution_scope
     WHERE entity_type = 'PROJECT'
       AND entity_id = p_audit_project_id
       AND organization_id = p_org_id;

  CURSOR get_processes_evaluated IS
    SELECT count(pk1_value)
      FROM amw_opinions_v opin
     WHERE opinion_type_code = 'EVALUATION'
       AND object_name = 'AMW_ORG_PROCESS'
       AND pk2_value = p_audit_project_id
       AND pk3_value = p_org_id
       AND exists (select 'Y' from amw_execution_scope scope
	       where scope.entity_type='PROJECT'
	         and scope.entity_id=p_audit_project_id
		 and scope.organization_id=opin.pk3_value
		 and scope.process_id=opin.pk1_value);

 CURSOR get_ineff_processes IS
    SELECT count(pk1_value)
      FROM amw_opinions_v opin
     WHERE opinion_type_code = 'EVALUATION'
       AND object_name = 'AMW_ORG_PROCESS'
       AND audit_result_code <> 'EFFECTIVE'
       AND pk2_value = p_audit_project_id
       AND pk3_value = p_org_id
       AND exists (select 'Y' from amw_execution_scope scope
	       where scope.entity_type='PROJECT'
	         and scope.entity_id=p_audit_project_id
		 and scope.organization_id=opin.pk3_value
		 and scope.process_id=opin.pk1_value);

  CURSOR get_total_risks IS
    SELECT count(risk_id)
      FROM amw_risk_associations
     WHERE object_type = 'PROJECT'
       AND pk1 = p_audit_project_id
       AND pk2 = p_org_id;

  CURSOR get_risks_evaluated IS
    SELECT count(opin.pk1_value)
      FROM amw_risk_associations assoc, amw_opinions_v opin
     WHERE assoc.object_type = 'PROJECT'
       AND assoc.pk1 = p_audit_project_id
       AND assoc.pk2 = p_org_id
       AND opin.opinion_type_code = 'EVALUATION'
       AND opin.object_name = 'AMW_ORG_PROCESS_RISK'
       AND opin.pk1_value = assoc.risk_id
       AND opin.pk2_value = assoc.pk1
       AND opin.pk3_value = assoc.pk2;

 CURSOR get_unmitigated_risks IS
    SELECT count(opin.pk1_value)
      FROM amw_risk_associations assoc, amw_opinions_v opin
     WHERE assoc.object_type = 'PROJECT'
       AND assoc.pk1 = p_audit_project_id
       AND assoc.pk2 = p_org_id
       AND opin.opinion_type_code = 'EVALUATION'
       AND opin.object_name = 'AMW_ORG_PROCESS_RISK'
       AND opin.pk1_value = assoc.risk_id
       AND opin.pk2_value = assoc.pk1
       AND opin.pk3_value = assoc.pk2
       AND opin.audit_result_code <> 'EFFECTIVE';

  CURSOR get_total_controls IS
    SELECT count(distinct control_id)
      FROM amw_control_associations
     WHERE object_type = 'PROJECT'
       AND pk1 = p_audit_project_id
       AND pk2 = p_org_id;

  CURSOR get_controls_evaluated IS
    SELECT count(pk1_value)
      FROM amw_opinions_v
     WHERE opinion_type_code = 'EVALUATION'
       AND object_name = 'AMW_ORG_CONTROL'
       AND pk2_value = p_audit_project_id
       AND pk3_value = p_org_id
       AND exists (select 'Y' FROM amw_control_associations
		    WHERE object_type = 'PROJECT'
		      AND pk1 = p_audit_project_id
		      AND pk2 = p_org_id
		      AND control_id = pk1_value);

 CURSOR get_ineff_controls IS
    SELECT count(pk1_value)
      FROM amw_opinions_v
     WHERE opinion_type_code = 'EVALUATION'
       AND object_name = 'AMW_ORG_CONTROL'
       AND audit_result_code <> 'EFFECTIVE'
       AND pk2_value = p_audit_project_id
       AND pk3_value = p_org_id
       AND exists (select 'Y' FROM amw_control_associations
		    WHERE object_type = 'PROJECT'
		      AND pk1 = p_audit_project_id
		      AND pk2 = p_org_id
		      AND control_id = pk1_value);

  l_ineff_sub_orgs      NUMBER;
  l_evaluated_sub_orgs      NUMBER;
  l_total_sub_orgs      NUMBER;

  l_ineff_processes	NUMBER;
  l_evaluated_processes	NUMBER;
  l_total_processes	NUMBER;

  l_unmitigated_risks NUMBER;
  l_evaluated_risks NUMBER;
  l_total_risks NUMBER;

  l_ineff_controls NUMBER;
  l_evaluated_controls NUMBER;
  l_total_controls NUMBER;

  l_open_findings NUMBER;


BEGIN

  OPEN get_total_sub_orgs;
  FETCH get_total_sub_orgs INTO l_total_sub_orgs;
  CLOSE get_total_sub_orgs;

  OPEN get_sub_orgs_evaluated;
  FETCH get_sub_orgs_evaluated INTO l_evaluated_sub_orgs;
  CLOSE get_sub_orgs_evaluated;

  OPEN get_ineff_sub_orgs;
  FETCH get_ineff_sub_orgs INTO l_ineff_sub_orgs;
  CLOSE get_ineff_sub_orgs;

  OPEN get_total_processes;
  FETCH get_total_processes INTO l_total_processes;
  CLOSE get_total_processes;

  OPEN get_ineff_processes;
  FETCH get_ineff_processes INTO l_ineff_processes;
  CLOSE get_ineff_processes;

  OPEN get_processes_evaluated;
  FETCH get_processes_evaluated INTO l_evaluated_processes;
  CLOSE get_processes_evaluated;

  OPEN  get_unmitigated_risks;
  FETCH get_unmitigated_risks into l_unmitigated_risks;
  CLOSE get_unmitigated_risks;

  OPEN  get_risks_evaluated;
  FETCH get_risks_evaluated into l_evaluated_risks;
  CLOSE get_risks_evaluated;

  OPEN  get_total_risks;
  FETCH get_total_risks into l_total_risks;
  CLOSE get_total_risks;

  OPEN  get_ineff_controls;
  FETCH get_ineff_controls into l_ineff_controls;
  CLOSE get_ineff_controls;

  OPEN  get_controls_evaluated;
  FETCH get_controls_evaluated into l_evaluated_controls;
  CLOSE get_controls_evaluated;

  OPEN  get_total_controls;
  FETCH get_total_controls into l_total_controls;
  CLOSE get_total_controls;


  l_open_findings := amw_findings_pkg.calculate_open_findings
		     ('AMW_PROJ_FINDING',
	              'PROJ_ORG', p_org_id,
		      'PROJECT', p_audit_project_id,
	               null, null,
   	       	       null, null, null, null);

  UPDATE amw_audit_scope_organizations
     SET sub_orgs_evaluated	  = l_evaluated_sub_orgs,
         ineffective_sub_orgs	  = l_ineff_sub_orgs,
	 total_sub_orgs		  = l_total_sub_orgs,
	 processes_evaluated	  = l_evaluated_processes,
	 ineffective_processes	  = l_ineff_processes,
	 total_processes	  = l_total_processes,
	 unmitigated_risks        = l_unmitigated_risks,
	 risks_evaluated          = l_evaluated_risks,
	 total_risks              = l_total_risks,
	 ineffective_controls     = l_ineff_controls,
	 controls_evaluated       = l_evaluated_controls,
	 total_controls           = l_total_controls,
	 open_findings            = l_open_findings,
	 last_update_date 	  = SYSDATE,
	 last_updated_by          = G_USER_ID,
	 last_update_login        = G_LOGIN_ID
   WHERE audit_project_id         = p_audit_project_id
     AND organization_id          = p_org_id;

  IF (SQL%NOTFOUND) THEN
    INSERT INTO amw_audit_scope_organizations (
	   audit_project_id,
	   subsidiary_vs,
	   subsidiary_code,
	   lob_vs,
	   lob_code,
	   organization_id,
	   sub_orgs_evaluated,
	   ineffective_sub_orgs,
	   total_sub_orgs,
	   processes_evaluated,
	   ineffective_processes,
	   total_processes,
	   risks_evaluated,
	   unmitigated_risks,
	   total_risks,
	   controls_evaluated,
	   ineffective_controls,
	   total_controls,
	   open_findings,
	   created_by,
	   creation_date,
	   last_updated_by,
	   last_update_date,
	   last_update_login,
	   object_version_number)
    SELECT p_audit_project_id,
	   subsidiary_valueset,
	   company_code,
	   lob_valueset,
	   lob_code,
	   p_org_id,
	   l_evaluated_sub_orgs,
	   l_ineff_sub_orgs,
	   l_total_sub_orgs,
	   l_evaluated_processes,
	   l_ineff_processes,
	   l_total_processes,
	   l_evaluated_risks,
	   l_unmitigated_risks,
	   l_total_risks,
	   l_evaluated_controls,
	   l_ineff_controls,
	   l_total_controls,
	   l_open_findings,
	   g_user_id,
	   sysdate,
	   g_user_id,
	   sysdate,
	   g_login_id,
	   1
      FROM amw_audit_units_v
     WHERE organization_id = p_org_id;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in update_org_summary_table'
	|| SUBSTR (SQLERRM, 1, 100), 1, 200));

  WHEN OTHERS THEN
    fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in update_org_summary_table'
	|| SUBSTR (SQLERRM, 1, 100), 1, 200));
END update_org_summary_table;


PROCEDURE update_proc_summary_table (
	  p_audit_project_id	IN 	NUMBER,
	  p_org_id 		IN 	NUMBER,
	  p_proc_id		IN	NUMBER
) IS

  CURSOR get_total_risks IS
    SELECT count(risk_id)
      FROM amw_risk_associations
     WHERE object_type = 'PROJECT'
       AND pk1 = p_audit_project_id
       AND pk2 = p_org_id
       AND pk3 IN (SELECT process_id
		     FROM amw_execution_scope
	       START WITH process_id = p_proc_id
		      AND organization_id = p_org_id
		      AND entity_id = p_audit_project_id
		      AND entity_type = 'PROJECT'
	 CONNECT BY PRIOR process_id = parent_process_id
		      AND organization_id = PRIOR organization_id
		      AND entity_id = PRIOR entity_id
                      AND entity_type = PRIOR entity_type);

  CURSOR get_risks_evaluated IS
    SELECT count(pk1_value)
      FROM amw_opinions_v
     WHERE opinion_type_code = 'EVALUATION'
       AND object_name = 'AMW_ORG_PROCESS_RISK'
       AND pk2_value = p_audit_project_id
       AND pk3_value = p_org_id
       AND pk4_value IN (SELECT process_id
		     FROM amw_execution_scope
	       START WITH process_id = p_proc_id
		      AND organization_id = p_org_id
		      AND entity_id = p_audit_project_id
		      AND entity_type = 'PROJECT'
	 CONNECT BY PRIOR process_id = parent_process_id
		      AND organization_id = PRIOR organization_id
		      AND entity_id = PRIOR entity_id
                      AND entity_type = PRIOR entity_type)
       AND exists (select 'Y' FROM amw_risk_associations
		    WHERE object_type = 'PROJECT'
		      AND pk1 = p_audit_project_id
		      AND pk2 = p_org_id
		      AND pk3 = pk4_value
		      AND risk_id = pk1_value);

 CURSOR get_unmitigated_risks IS
    SELECT count(pk1_value)
      FROM amw_opinions_v
     WHERE opinion_type_code = 'EVALUATION'
       AND object_name = 'AMW_ORG_PROCESS_RISK'
       AND audit_result_code <> 'EFFECTIVE'
       AND pk2_value = p_audit_project_id
       AND pk3_value = p_org_id
       AND pk4_value IN (SELECT process_id
		     FROM amw_execution_scope
	       START WITH process_id = p_proc_id
		      AND organization_id = p_org_id
		      AND entity_id = p_audit_project_id
		      AND entity_type = 'PROJECT'
	 CONNECT BY PRIOR process_id = parent_process_id
		      AND organization_id = PRIOR organization_id
		      AND entity_id = PRIOR entity_id
                      AND entity_type = PRIOR entity_type)
      AND exists (select 'Y' FROM amw_risk_associations
		    WHERE object_type = 'PROJECT'
		      AND pk1 = p_audit_project_id
		      AND pk2 = p_org_id
		      AND pk3 = pk4_value
		      AND risk_id = pk1_value);

  CURSOR get_total_controls IS
    SELECT count(distinct control_id)
      FROM amw_control_associations
     WHERE object_type = 'PROJECT'
       AND pk1 = p_audit_project_id
       AND pk2 = p_org_id
       AND pk3 IN (SELECT process_id
		     FROM amw_execution_scope
	       START WITH process_id = p_proc_id
		      AND organization_id = p_org_id
		      AND entity_id = p_audit_project_id
		      AND entity_type = 'PROJECT'
	 CONNECT BY PRIOR process_id = parent_process_id
		      AND organization_id = PRIOR organization_id
		      AND entity_id = PRIOR entity_id
                      AND entity_type = PRIOR entity_type);

  CURSOR get_controls_evaluated IS
    SELECT count(distinct opin.pk1_value)
      FROM amw_control_associations assoc, amw_opinions_v opin
     WHERE assoc.object_type = 'PROJECT'
       AND assoc.pk1 = p_audit_project_id
       AND assoc.pk2 = p_org_id
       AND assoc.pk3 IN (SELECT process_id
		     FROM amw_execution_scope
	       START WITH process_id = p_proc_id
		      AND organization_id = p_org_id
		      AND entity_id = p_audit_project_id
		      AND entity_type = 'PROJECT'
	 CONNECT BY PRIOR process_id = parent_process_id
		      AND organization_id = PRIOR organization_id
		      AND entity_id = PRIOR entity_id
                      AND entity_type = PRIOR entity_type)
       AND opin.opinion_type_code = 'EVALUATION'
       AND opin.object_name = 'AMW_ORG_CONTROL'
       AND opin.pk1_value = assoc.control_id
       AND opin.pk2_value = p_audit_project_id
       AND opin.pk3_value = p_org_id;

 CURSOR get_ineff_controls IS
    SELECT count(distinct opin.pk1_value)
      FROM amw_control_associations assoc, amw_opinions_v opin
     WHERE assoc.object_type = 'PROJECT'
       AND assoc.pk1 = p_audit_project_id
       AND assoc.pk2 = p_org_id
       AND assoc.pk3 IN (SELECT process_id
		     FROM amw_execution_scope
	       START WITH process_id = p_proc_id
		      AND organization_id = p_org_id
		      AND entity_id = p_audit_project_id
		      AND entity_type = 'PROJECT'
	 CONNECT BY PRIOR process_id = parent_process_id
		      AND organization_id = PRIOR organization_id
		      AND entity_id = PRIOR entity_id
                      AND entity_type = PRIOR entity_type)
       AND opin.opinion_type_code = 'EVALUATION'
       AND opin.object_name = 'AMW_ORG_CONTROL'
       AND opin.audit_result_code <> 'EFFECTIVE'
       AND opin.pk1_value = assoc.control_id
       AND opin.pk2_value = p_audit_project_id
       AND opin.pk3_value = p_org_id;

  l_unmitigated_risks NUMBER;
  l_evaluated_risks NUMBER;
  l_total_risks NUMBER;

  l_ineff_controls NUMBER;
  l_evaluated_controls NUMBER;
  l_total_controls NUMBER;

  l_open_findings NUMBER;


BEGIN

  OPEN  get_unmitigated_risks;
  FETCH get_unmitigated_risks into l_unmitigated_risks;
  CLOSE get_unmitigated_risks;

  OPEN  get_risks_evaluated;
  FETCH get_risks_evaluated into l_evaluated_risks;
  CLOSE get_risks_evaluated;

  OPEN  get_total_risks;
  FETCH get_total_risks into l_total_risks;
  CLOSE get_total_risks;

  OPEN  get_ineff_controls;
  FETCH get_ineff_controls into l_ineff_controls;
  CLOSE get_ineff_controls;

  OPEN  get_controls_evaluated;
  FETCH get_controls_evaluated into l_evaluated_controls;
  CLOSE get_controls_evaluated;

  OPEN  get_total_controls;
  FETCH get_total_controls into l_total_controls;
  CLOSE get_total_controls;


  l_open_findings := amw_findings_pkg.calculate_open_findings
		     ('AMW_PROJ_FINDING',
	              'PROJ_ORG_PROC', p_proc_id,
		      'PROJ_ORG', p_org_id,
		      'PROJECT', p_audit_project_id,
		       null, null,
		       null, null);

  UPDATE amw_audit_scope_processes
     SET unmitigated_risks        = l_unmitigated_risks,
	 risks_evaluated          = l_evaluated_risks,
	 total_risks              = l_total_risks,
	 ineffective_controls     = l_ineff_controls,
	 controls_evaluated       = l_evaluated_controls,
	 total_controls           = l_total_controls,
	 open_findings            = l_open_findings,
	 last_update_date 	  = SYSDATE,
	 last_updated_by          = G_USER_ID,
	 last_update_login        = G_LOGIN_ID
   WHERE audit_project_id = p_audit_project_id
     AND organization_id = p_org_id
     AND process_id = p_proc_id;

  IF (SQL%NOTFOUND) THEN
    INSERT INTO amw_audit_scope_processes (
	   audit_project_id,
	   organization_id,
	   process_id,
	   risks_evaluated,
	   unmitigated_risks,
	   total_risks,
	   controls_evaluated,
	   ineffective_controls,
	   total_controls,
	   open_findings,
	   created_by,
	   creation_date,
	   last_updated_by,
	   last_update_date,
	   last_update_login,
	   object_version_number)
    SELECT p_audit_project_id,
	   p_org_id,
	   p_proc_id,
	   l_evaluated_risks,
	   l_unmitigated_risks,
	   l_total_risks,
	   l_evaluated_controls,
	   l_ineff_controls,
	   l_total_controls,
	   l_open_findings,
	   g_user_id,
	   sysdate,
	   g_user_id,
	   sysdate,
	   g_login_id,
	   1
      FROM dual;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in update_proc_summary_table'
	|| SUBSTR (SQLERRM, 1, 100), 1, 200));

  WHEN OTHERS THEN
    fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in update_proc_summary_table'
	|| SUBSTR (SQLERRM, 1, 100), 1, 200));
END update_proc_summary_table;


PROCEDURE Synchronize_Eng_Denorm_Tables(
    errbuf       OUT NOCOPY      VARCHAR2,
    retcode      OUT NOCOPY      VARCHAR2,
    p_audit_project_id  IN       NUMBER
)
IS

  CURSOR c_engagements IS
    Select audit_project_id
    from AMW_AUDIT_PROJECTS
    where AUDIT_PROJECT_STATUS = 'ACTI';

  CURSOR c_scope_org(l_audit_project_id NUMBER) IS
    SELECT organization_id
      FROM AMW_AUDIT_SCOPE_ORGANIZATIONS
     WHERE audit_project_id = l_audit_project_id;

  CURSOR c_org_proc(l_audit_project_id NUMBER, l_org_id NUMBER) IS
    SELECT process_id
      FROM AMW_AUDIT_SCOPE_PROCESSES
     WHERE audit_project_id = l_audit_project_id
       AND organization_id = l_org_id;

  eng_rec   c_engagements%rowtype;
  org_rec   c_scope_org%rowtype;
  proc_rec  c_org_proc%rowtype;


BEGIN
  fnd_file.put_line (fnd_file.LOG,'Audit_Project_Id :' || p_audit_project_id);

  IF p_audit_project_id IS NOT NULL THEN
    FOR org_rec IN c_scope_org(p_audit_project_id) LOOP
      update_org_summary_table(p_audit_project_id,org_rec.organization_id);

      FOR proc_rec IN c_org_proc(p_audit_project_id,org_rec.organization_id) LOOP
        update_proc_summary_table(p_audit_project_id,org_rec.organization_id,proc_rec.process_id);
      END LOOP;
    END LOOP;
  ELSE
    FOR eng_rec IN c_engagements LOOP
      FOR org_rec IN c_scope_org(eng_rec.audit_project_id) LOOP
        update_org_summary_table(eng_rec.audit_project_id,org_rec.organization_id);

        FOR proc_rec IN c_org_proc(eng_rec.audit_project_id,org_rec.organization_id) LOOP
          update_proc_summary_table(eng_rec.audit_project_id,org_rec.organization_id,proc_rec.process_id);
        END LOOP;
      END LOOP;
    END LOOP;
  END IF;

  COMMIT;

EXCEPTION
     WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Synchronize_Eng_Denorm_Tables'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
         errbuf := SQLERRM;
         retcode := FND_API.G_RET_STS_UNEXP_ERROR;

END Synchronize_Eng_Denorm_Tables;


FUNCTION Update_Eng_Sign_Off_Status
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2
IS

 l_key                      varchar2(240) := p_event.GetEventKey();
 l_change_id                NUMBER;
 l_approval_status_code     NUMBER;
 l_workflow_route_status    varchar2(240);

 l_audit_project_id         NUMBER;
 l_sign_off_status          varchar2(30);
 l_change_mgmt_type_code    varchar2(30);

BEGIN


  l_change_id              :=  p_event.GetValueForParameter('ChangeId');
  l_approval_status_code   :=  p_event.GetValueForParameter('NewApprovalStatusCode');
  l_workflow_route_status  :=  p_event.GetValueForParameter('WorkflowRouteStatus');

  IF l_change_id IS NOT NULL THEN
    select change_mgmt_type_code into l_change_mgmt_type_code
    from eng_engineering_changes
    where change_id =  l_change_id
    and organization_id = -1
    and rownum < 2;

    select pk1_value into l_audit_project_id
    from eng_change_subjects_v
    where entity_name = 'PROJECT'
      and change_id = l_change_id;
  END IF;

/* Check for change_mgmt_type_code before updating status */
IF l_change_mgmt_type_code = 'AMW_SIGNOFF_REQUESTS' THEN
  IF l_approval_status_code IS NOT NULL THEN
    IF l_approval_status_code = 1 THEN
      l_sign_off_status := 'NOT_SUBMITTED';
    ELSIF l_approval_status_code = 3 THEN
      l_sign_off_status := 'PENDING_APPROVAL';
    ELSIF l_approval_status_code = 4 THEN
      l_sign_off_status := 'REJECTED';
    ELSIF l_approval_status_code = 5 THEN
      l_sign_off_status := 'APPROVED';
    ELSE
      l_sign_off_status := 'NOT_COMPLETED';
    END IF;
  END IF;


  IF l_audit_project_id IS NOT NULL THEN

    /* Update the signOffStatus. */
    UPDATE AMW_AUDIT_PROJECTS
    SET sign_off_status = l_sign_off_status
    WHERE AUDIT_PROJECT_ID = l_audit_project_id;

    /* update the Engagement status */
    IF l_sign_off_status = 'APPROVED' THEN
      UPDATE AMW_AUDIT_PROJECTS
      SET audit_project_status = 'SIGN'
      WHERE AUDIT_PROJECT_ID = l_audit_project_id
        AND AUDIT_PROJECT_STATUS = 'ACTI';
    END IF;

  END IF;
END IF; -- end of l_change_mgmt_type_code

  return 'SUCCESS';

EXCEPTION
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('AMW_PROJECT_EVENT_PVT', 'Update_Eng_Sign_Off_Status', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';

END Update_Eng_Sign_Off_Status;


procedure UPDATE_SIGNOFF_STATUS(
   p_change_id 			in number
  ,p_base_change_mgmt_type_code in varchar2
  ,p_new_approval_status_code   in varchar2
  ,p_workflow_status_code	in varchar2
  ,x_return_status		out nocopy varchar2
  ,x_msg_count			out nocopy number
  ,x_msg_data 			out nocopy varchar2
)
is

 l_audit_project_id         NUMBER;
 l_sign_off_status          varchar2(30);

begin
   x_return_status := fnd_api.g_ret_sts_success;


  IF p_change_id IS NOT NULL THEN
    select pk1_value into l_audit_project_id
    from eng_change_subjects_v
    where entity_name = 'PROJECT'
      and change_id = p_change_id;
  END IF;

  IF p_new_approval_status_code IS NOT NULL THEN
    IF p_new_approval_status_code = 1 THEN
      l_sign_off_status := 'NOT_SUBMITTED';
    ELSIF p_new_approval_status_code = 3 THEN
      l_sign_off_status := 'PENDING_APPROVAL';
    ELSIF p_new_approval_status_code = 4 THEN
      l_sign_off_status := 'REJECTED';
    ELSIF p_new_approval_status_code = 5 THEN
      l_sign_off_status := 'APPROVED';
    ELSE
      l_sign_off_status := 'NOT_COMPLETED';
    END IF;
  END IF;


  IF l_audit_project_id IS NOT NULL THEN

    /* Update the signOffStatus. */
    UPDATE AMW_AUDIT_PROJECTS
    SET sign_off_status = l_sign_off_status
    WHERE AUDIT_PROJECT_ID = l_audit_project_id;

    /* update the Engagement status */
    IF l_sign_off_status = 'APPROVED' THEN
      UPDATE AMW_AUDIT_PROJECTS
      SET audit_project_status = 'SIGN'
      WHERE AUDIT_PROJECT_ID = l_audit_project_id
        AND AUDIT_PROJECT_STATUS = 'ACTI';
    END IF;

  END IF;


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
	  -- Standard call to get message count and if count=1, get the message
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);
end UPDATE_SIGNOFF_STATUS;


END AMW_PROJECT_EVENT_PVT;




/
