--------------------------------------------------------
--  DDL for Package Body AMW_PROCESS_CERT_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PROCESS_CERT_SUMMARY" as
/* $Header: amwpcesb.pls 120.5.12000000.6 2007/03/28 21:21:09 npanandi ship $ */

G_USER_ID NUMBER   := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER  := FND_GLOBAL.CONC_LOGIN_ID;



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
     SET pk4 = (SELECT max(opinion_log_id)
                  FROM amw_opinions_log opin
		 WHERE opin.object_opinion_type_id = l_obj_opinion_type_id
		   AND opin.pk1_value = assoc.risk_id
		   AND opin.pk3_value = assoc.pk2	-- organization_id
		   AND NVL(opin.pk4_value, -1) =
		          NVL(assoc.pk3, -1))	-- process_id
		,last_update_date = sysdate
   WHERE pk1 = p_certification_id
     ---04.05.05 npanandi: added object_type below
     and object_type='BUSIPROC_CERTIFICATION';


  OPEN c_obj_opin_type_id ('AMW_ORG_CONTROL');
  FETCH c_obj_opin_type_id INTO l_obj_opinion_type_id;
  CLOSE c_obj_opin_type_id;

  UPDATE amw_control_associations assoc
     SET pk5 = (SELECT max(opinion_log_id)
                  FROM amw_opinions_log opin
		 WHERE opin.object_opinion_type_id = l_obj_opinion_type_id
		   AND opin.pk1_value = assoc.control_id
		   AND opin.pk3_value = assoc.pk2)	-- organization_id
		,last_update_date = sysdate
   WHERE pk1 = p_certification_id
     ---04.05.05 npanandi: added object_type below
     and object_type='BUSIPROC_CERTIFICATION';

  OPEN c_obj_opin_type_id ('AMW_ORG_AP_CONTROL');
  FETCH c_obj_opin_type_id INTO l_obj_opinion_type_id;
  CLOSE c_obj_opin_type_id;


  UPDATE amw_ap_associations assoc
     SET pk4 = (SELECT max(opinion_log_id)
                  FROM amw_opinions_log opin
		 WHERE opin.object_opinion_type_id = l_obj_opinion_type_id
		   AND opin.pk1_value = assoc.pk3   --control_id
		   AND opin.pk3_value = assoc.pk2 	-- organization_id
		   AND opin.pk4_value = assoc.audit_procedure_id)      -- audit_procedure_id
		,last_update_date = sysdate
   WHERE pk1 = p_certification_id
     ---04.05.05 npanandi: added object_type below
     and object_type='BUSIPROC_CERTIFICATION';


END populate_assoc_opinion;


-- ===========================================================================
--   Procedure   : UPDATE_SUMMARY_TABLE
--   Description : Update the various columns in the summary table
--   The values for various columns are derived from different cursors
-- ===========================================================================
PROCEDURE update_summary_table
(p_process_id 		IN 	NUMBER,
 p_org_id 		IN 	NUMBER,
 p_certification_id 	IN 	NUMBER
)
IS
CURSOR get_certification_opinion
IS
SELECT opinion.opinion_id
FROM amw_opinions_v opinion
WHERE opinion.pk3_value = p_org_id
AND   opinion.pk2_value = p_certification_id
AND   opinion.pk1_value = p_process_id
AND   opinion.opinion_type_code = 'CERTIFICATION'
AND   opinion.object_name = 'AMW_ORG_PROCESS';

CURSOR get_evaluation_opinion
IS
SELECT  opinion.opinion_id
FROM    amw_opinions_v opinion
WHERE	(opinion.authored_date in (SELECT MAX(opinion2.authored_date)
			           FROM amw_opinions_v opinion2
			           WHERE opinion2.object_opinion_type_id = opinion.object_opinion_type_id
			           AND   opinion2.pk1_value = opinion.pk1_value
			           AND   opinion2.pk3_value = opinion.pk3_value)
	)
AND	opinion.pk1_value = p_process_id
AND	opinion.pk3_value = p_org_id
AND	opinion.opinion_type_code = 'EVALUATION'
AND	opinion.object_name = 'AMW_ORG_PROCESS';

CURSOR get_evaluation_opinion_log
IS
SELECT  opinion.opinion_log_id
FROM    amw_opinions_log_v opinion
WHERE	(opinion.authored_date in (SELECT MAX(opinion2.authored_date)
			           FROM amw_opinions opinion2
			           WHERE opinion2.object_opinion_type_id = opinion.object_opinion_type_id
			           AND   opinion2.pk1_value = opinion.pk1_value
			           AND   opinion2.pk3_value = opinion.pk3_value)
	)
AND	opinion.pk1_value = p_process_id
AND	opinion.pk3_value = p_org_id
AND	opinion.opinion_type_code = 'EVALUATION'
AND	opinion.object_name = 'AMW_ORG_PROCESS';

CURSOR get_unmitigated_risks
IS
SELECT count(1)
  FROM (SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
	      FROM amw_risk_associations ara, amw_opinions_v aov
	     WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
	       AND ara.pk1 = p_certification_id
	       AND ara.pk2 = p_org_id
	       AND ara.pk3 IN (SELECT DISTINCT process_id
				             FROM amw_execution_scope
				            START WITH process_id = p_process_id
							  AND organization_id = p_org_id
							  AND entity_id = p_certification_id
							  ---07.05.2005 npanandi: add entityType, bugfix 4471783
							  and entity_type='BUSIPROC_CERTIFICATION'
						  CONNECT BY PRIOR process_id = parent_process_id
							  AND organization_id = PRIOR organization_id
							  AND entity_id = PRIOR entity_id
							  ---07.05.2005 npanandi: add entityType, bugfix 4471783
							  and entity_type=prior entity_type)
		   AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
		   AND aov.opinion_type_code = 'EVALUATION'
		   AND aov.pk3_value = ara.pk2 --org_id
		   AND aov.pk4_value = ara.pk3 --process_id
		   AND aov.pk1_value = ara.risk_id
	       AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				                      FROM amw_opinions aov2
				                     WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				                       AND aov2.pk4_value = aov.pk4_value
				                       AND aov2.pk3_value = aov.pk3_value
				                       AND aov2.pk1_value = aov.pk1_value)
	       AND aov.audit_result_code <> 'EFFECTIVE');

CURSOR get_evaluated_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
	 FROM amw_risk_associations ara, amw_opinions_v aov
	 WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
	 AND ara.pk1 = p_certification_id
	 AND ara.pk2 = p_org_id
	 AND ara.pk3 IN (SELECT DISTINCT process_id
				FROM   amw_execution_scope
				START WITH process_id = p_process_id
				AND organization_id = p_org_id
				AND entity_id = p_certification_id
				---07.05.2005 npanandi: add entityType, bugfix 4471783
				and entity_type='BUSIPROC_CERTIFICATION'
				CONNECT BY PRIOR process_id = parent_process_id
				AND organization_id = PRIOR organization_id
				AND entity_id = PRIOR entity_id
				---07.05.2005 npanandi: add entityType, bugfix 4471783
				and entity_type=prior entity_type
			       )
	 AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value = ara.pk2 --org_id
	 AND aov.pk4_value = ara.pk3 --process_id
	 AND aov.pk1_value = ara.risk_id
	 AND aov.audit_result_code IS NOT NULL
	 );

CURSOR get_total_risks
IS
SELECT count(DISTINCT ara.risk_id)
FROM amw_risk_associations ara
WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
AND ara.pk1 = p_certification_id
AND ara.pk2 = p_org_id
AND ara.pk3 IN (SELECT DISTINCT process_id
		FROM   amw_execution_scope
		START WITH process_id = p_process_id
		AND organization_id = p_org_id
		AND entity_id = p_certification_id
		---07.05.2005 npanandi: add entityType, bugfix 4471783
	    and entity_type='BUSIPROC_CERTIFICATION'
		CONNECT BY PRIOR process_id = parent_process_id
		AND organization_id = PRIOR organization_id
		AND entity_id = PRIOR entity_id
		---07.05.2005 npanandi: add entityType, bugfix 4471783
		and entity_type=prior entity_type
	       );

--modified by dliao 10.14.2005
--remove risk_id
CURSOR get_ineffective_controls
IS
SELECT count(1)
--FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.pk3 process_id, aca.pk4 risk_id, aca.control_id
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.pk3 process_id, aca.control_id
	 FROM amw_control_associations aca,amw_opinions_v aov
	 WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
	 AND aca.pk1 		   = p_certification_id
	 AND aca.pk2               = p_org_id
	 AND aca.pk3               IN (SELECT DISTINCT process_id
	 	 		  	       FROM   amw_execution_scope
	 	 		  	       START WITH process_id = p_process_id
	 	 		  	       AND organization_id = p_org_id
	 	 		  	       AND entity_id = p_certification_id
						   ---07.05.2005 npanandi: add entityType, bugfix 4471783
	                       and entity_type='BUSIPROC_CERTIFICATION'
	 	 		  	       CONNECT BY PRIOR process_id = parent_process_id
	 	 		  	       AND organization_id = PRIOR organization_id
	 	 		  	       AND entity_id = PRIOR entity_id
						   ---07.05.2005 npanandi: add entityType, bugfix 4471783
		                   and entity_type=prior entity_type
	 	 		  	       )
	 AND aov.object_name       = 'AMW_ORG_CONTROL'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value         = p_org_id
	 AND aov.pk1_value         = aca.control_id
	 AND aov.audit_result_code <> 'EFFECTIVE'
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value)
     )
	 ;

CURSOR get_evaluated_controls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.pk3 process_id, aca.control_id
	 FROM amw_control_associations aca,amw_opinions_v aov
	 WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
	 AND aca.pk1 		   = p_certification_id
	 AND aca.pk2               = p_org_id
	 AND aca.pk3               IN (SELECT DISTINCT process_id
	 	 		  	       FROM   amw_execution_scope
	 	 		  	       START WITH process_id = p_process_id
	 	 		  	       AND organization_id = p_org_id
	 	 		  	       AND entity_id = p_certification_id
						   ---07.05.2005 npanandi: add entityType, bugfix 4471783
	                       and entity_type='BUSIPROC_CERTIFICATION'
	 	 		  	       CONNECT BY PRIOR process_id = parent_process_id
	 	 		  	       AND organization_id = PRIOR organization_id
	 	 		  	       AND entity_id = PRIOR entity_id
						   ---07.05.2005 npanandi: add entityType, bugfix 4471783
		                   and entity_type=prior entity_type
	 	 		  	       )
	 AND aov.object_name       = 'AMW_ORG_CONTROL'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value         = p_org_id
	 AND aov.pk1_value         = aca.control_id
	 AND aov.audit_result_code IS NOT NULL);

CURSOR get_total_controls
IS
SELECT count(1) from
(select DISTINCT aca.pk2 organization_id,aca.pk3 process_id, aca.control_id
FROM amw_control_associations aca
WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
AND aca.pk1 		  = p_certification_id
AND aca.pk2               = p_org_id
AND aca.pk3               IN (SELECT DISTINCT process_id
			       FROM   amw_execution_scope
			       START WITH process_id = p_process_id
			       AND organization_id = p_org_id
			       AND entity_id = p_certification_id
				   ---07.05.2005 npanandi: add entityType, bugfix 4471783
	               and entity_type='BUSIPROC_CERTIFICATION'
			       CONNECT BY PRIOR process_id = parent_process_id
			       AND organization_id = PRIOR organization_id
			       AND entity_id = PRIOR entity_id
				   ---07.05.2005 npanandi: add entityType, bugfix 4471783
		           and entity_type=prior entity_type
			       ));

CURSOR get_total_org_certified
IS
SELECT count(distinct processorg.organization_id)
FROM amw_execution_scope processorg
WHERE processorg.process_id = p_process_id
AND   processorg.organization_id IN
        (SELECT object_id
	   FROM amw_entity_hierarchies
	  START WITH parent_object_id = p_org_id
	    AND object_type = 'ORG'
	    AND entity_id = p_certification_id
	    AND entity_type='BUSIPROC_CERTIFICATION'
	  CONNECT BY parent_object_id = PRIOR object_id
	    AND parent_object_type = PRIOR object_type
	    AND entity_id = PRIOR entity_id
	    AND entity_type = PRIOR entity_type)
AND   processorg.entity_id=p_certification_id
AND   processorg.entity_type='BUSIPROC_CERTIFICATION';

CURSOR get_var_total_org_certified
IS
SELECT count(1)
FROM (SELECT distinct procorg.organization_id, procorg.process_id
      FROM amw_execution_scope scp,
	   amw_process_organization procorg
      WHERE scp.process_org_rev_id = procorg.process_org_rev_id
        AND procorg.standard_variation IN
	      (select process_rev_id
	         from amw_process
                where process_id = p_process_id)
        AND scp.organization_id IN
	        (SELECT object_id
		   FROM amw_entity_hierarchies
 	     START WITH parent_object_id = p_org_id
	     	    AND object_type = 'ORG'
		    AND entity_id = p_certification_id
	            AND entity_type='BUSIPROC_CERTIFICATION'
	     CONNECT BY parent_object_id = PRIOR object_id
	            AND parent_object_type = PRIOR object_type
	            AND entity_id = PRIOR entity_id
	            AND entity_type = PRIOR entity_type)
       AND  scp.entity_id=p_certification_id
       AND  scp.entity_type='BUSIPROC_CERTIFICATION');


CURSOR get_org_processes_certified
IS
SELECT count(distinct pk3_value)
FROM   amw_opinions_v opinion
WHERE  opinion.pk2_value = p_certification_id
AND    opinion.pk1_value = p_process_id
AND    opinion.opinion_type_code = 'CERTIFICATION'
AND    opinion.object_name = 'AMW_ORG_PROCESS'
AND    opinion.pk3_value IN
	      (SELECT object_id
		   FROM amw_entity_hierarchies
 	     START WITH parent_object_id = p_org_id
	     	    AND object_type = 'ORG'
		    AND entity_id = p_certification_id
	            AND entity_type='BUSIPROC_CERTIFICATION'
	     CONNECT BY parent_object_id = PRIOR object_id
	            AND parent_object_type = PRIOR object_type
	            AND entity_id = PRIOR entity_id
	            AND entity_type = PRIOR entity_type)
AND    exists (select 'Y' from amw_execution_scope scope
	       where scope.entity_type='BUSIPROC_CERTIFICATION'
	         and scope.entity_id=p_certification_id
		 and scope.organization_id=opinion.pk3_value
		 and scope.process_id=opinion.pk1_value);

CURSOR get_var_org_proc_certified
IS
SELECT count(1)
FROM (SELECT distinct opinion.pk1_value, opinion.pk3_value
      FROM  amw_opinions_v opinion,
            amw_execution_scope scp,
	    amw_process_organization procorg
      WHERE opinion.pk2_value = p_certification_id
      AND   opinion.pk1_value = scp.process_id
      AND   opinion.pk3_value = scp.organization_id
      AND   scp.entity_type = 'BUSIPROC_CERTIFICATION'
      AND   scp.entity_id = p_certification_id
      AND   scp.process_org_rev_id = procorg.process_org_rev_id
      AND   procorg.standard_variation in
	        (select process_rev_id
		 from amw_process
		 where process_id = p_process_id)
      AND   scp.organization_id IN
                (SELECT object_id
		   FROM amw_entity_hierarchies
 	     START WITH parent_object_id = p_org_id
	     	    AND object_type = 'ORG'
		    AND entity_id = p_certification_id
	            AND entity_type='BUSIPROC_CERTIFICATION'
	     CONNECT BY parent_object_id = PRIOR object_id
	            AND parent_object_type = PRIOR object_type
	            AND entity_id = PRIOR entity_id
	            AND entity_type = PRIOR entity_type)
      AND   opinion.opinion_type_code = 'CERTIFICATION'
      AND   opinion.object_name = 'AMW_ORG_PROCESS');


CURSOR get_all_sub_processes
IS
SELECT count(distinct process_id)
FROM   amw_execution_scope
START WITH parent_process_id = p_process_id
AND 	   organization_id   = p_org_id
AND 	   entity_id         = p_certification_id
---07.05.2005 npanandi: add entityType, bugfix 4471783
and entity_type='BUSIPROC_CERTIFICATION'
CONNECT BY PRIOR process_id     = parent_process_id
AND 		organization_id = PRIOR organization_id
AND 		entity_id       = PRIOR entity_id
---07.05.2005 npanandi: add entityType, bugfix 4471783
and entity_type=prior entity_type;

CURSOR get_certified_sub_processes
IS
SELECT count(distinct process_id)
FROM   amw_execution_scope amw_exec
WHERE EXISTS (SELECT  opinion.opinion_id
		FROM amw_opinions_v opinion
		WHERE opinion.pk1_value = amw_exec.process_id
		AND   opinion.pk3_value = p_org_id
		AND   opinion.pk2_value = p_certification_id
		AND   opinion.opinion_type_code = 'CERTIFICATION'
		AND   opinion.object_name = 'AMW_ORG_PROCESS'
	     )
START WITH parent_process_id = p_process_id
AND 	   organization_id   = p_org_id
AND 	   entity_id         = p_certification_id
---07.05.2005 npanandi: add entityType, bugfix 4471783
and entity_type='BUSIPROC_CERTIFICATION'
CONNECT BY PRIOR process_id     = parent_process_id
AND 		organization_id = PRIOR organization_id
AND 		entity_id       = PRIOR entity_id
---07.05.2005 npanandi: add entityType, bugfix 4471783
and entity_type=prior entity_type;

CURSOR get_sub_process_cert_issues
IS
SELECT count(distinct process_id)
FROM   amw_execution_scope amw_exec
WHERE EXISTS (SELECT  opinion.opinion_id
		FROM amw_opinions_v opinion
		WHERE opinion.pk1_value = amw_exec.process_id
		AND   opinion.pk3_value = p_org_id
		AND   opinion.pk2_value = p_certification_id
		AND   opinion.opinion_type_code = 'CERTIFICATION'
		AND   opinion.object_name = 'AMW_ORG_PROCESS'
		AND   opinion.audit_result_code <> 'EFFECTIVE'
	     )
START WITH parent_process_id = p_process_id
AND 	   organization_id   = p_org_id
AND 	   entity_id         = p_certification_id
---07.05.2005 npanandi: add entityType, bugfix 4471783
and entity_type='BUSIPROC_CERTIFICATION'
CONNECT BY PRIOR process_id     = parent_process_id
AND 		organization_id = PRIOR organization_id
AND 		entity_id       = PRIOR entity_id
---07.05.2005 npanandi: add entityType, bugfix 4471783
and entity_type=prior entity_type;


CURSOR get_org_process_cert_issues
IS
SELECT count(distinct pk3_value)
FROM   amw_opinions_v opinion
WHERE  opinion.pk2_value = p_certification_id
AND    opinion.pk1_value = p_process_id
AND    opinion.opinion_type_code = 'CERTIFICATION'
AND    opinion.object_name = 'AMW_ORG_PROCESS'
AND    opinion.audit_result_code <> 'EFFECTIVE'
AND    opinion.pk3_value IN
	      (SELECT object_id
		   FROM amw_entity_hierarchies
 	     START WITH parent_object_id = p_org_id
	     	    AND object_type = 'ORG'
		    AND entity_id = p_certification_id
	            AND entity_type='BUSIPROC_CERTIFICATION'
	     CONNECT BY parent_object_id = PRIOR object_id
	            AND parent_object_type = PRIOR object_type
	            AND entity_id = PRIOR entity_id
	            AND entity_type = PRIOR entity_type)
AND    exists (select 'Y' from amw_execution_scope scope
	       where scope.entity_type='BUSIPROC_CERTIFICATION'
	         and scope.entity_id=p_certification_id
		 and scope.organization_id=opinion.pk3_value
		 and scope.process_id=opinion.pk1_value);

CURSOR get_var_org_proc_cert_issues
IS
SELECT count(1)
FROM (SELECT distinct opinion.pk1_value, opinion.pk3_value
      FROM  amw_opinions_v opinion,
            amw_execution_scope scp,
	    amw_process_organization procorg
      WHERE opinion.pk2_value = p_certification_id
      AND   opinion.pk1_value = scp.process_id
      AND   opinion.pk3_value = scp.organization_id
      AND   scp.entity_type = 'BUSIPROC_CERTIFICATION'
      AND   scp.entity_id = p_certification_id
      AND   scp.process_org_rev_id = procorg.process_org_rev_id
      AND   procorg.standard_variation in
	        (select process_rev_id
		 from amw_process
		 where process_id = p_process_id)
      AND   scp.organization_id IN
                (SELECT object_id
		   FROM amw_entity_hierarchies
 	     START WITH parent_object_id = p_org_id
	     	    AND object_type = 'ORG'
		    AND entity_id = p_certification_id
	            AND entity_type='BUSIPROC_CERTIFICATION'
	     CONNECT BY parent_object_id = PRIOR object_id
	            AND parent_object_type = PRIOR object_type
	            AND entity_id = PRIOR entity_id
	            AND entity_type = PRIOR entity_type)
      AND   opinion.opinion_type_code = 'CERTIFICATION'
      AND   opinion.object_name = 'AMW_ORG_PROCESS'
      AND   opinion.audit_result_code <> 'EFFECTIVE');

l_certification_opinion_id NUMBER;
l_evaluation_opinion_id NUMBER;
l_evaluation_opinion_log_id NUMBER;

l_unmitigated_risks NUMBER;
l_evaluated_risks NUMBER;
l_total_risks NUMBER;

l_ineffective_controls NUMBER;
l_evaluated_controls NUMBER;
l_total_controls NUMBER;

l_global_process VARCHAR2(1);
l_global_org_id NUMBER;
l_total_org_process_cert NUMBER;
l_org_process_cert NUMBER;
l_var_total_org_process_cert NUMBER;
l_var_org_process_cert NUMBER;

l_sub_process_certified NUMBER;
l_sub_process_total NUMBER;
l_open_findings NUMBER;
l_open_issues NUMBER;

l_org_process_cert_issues NUMBER;
l_var_org_proc_cert_issues NUMBER;
l_sub_process_cert_issues NUMBER;

BEGIN

	OPEN  get_certification_opinion;
	FETCH get_certification_opinion into l_certification_opinion_id;
	CLOSE get_certification_opinion;

	OPEN  get_evaluation_opinion;
	FETCH get_evaluation_opinion into l_evaluation_opinion_id;
	CLOSE get_evaluation_opinion;

	OPEN  get_evaluation_opinion_log;
	FETCH get_evaluation_opinion_log into l_evaluation_opinion_log_id;
	CLOSE get_evaluation_opinion_log;

	OPEN  get_unmitigated_risks;
	FETCH get_unmitigated_risks into l_unmitigated_risks;
	CLOSE get_unmitigated_risks;

	OPEN  get_evaluated_risks;
	FETCH get_evaluated_risks into l_evaluated_risks;
	CLOSE get_evaluated_risks;

	OPEN  get_total_risks;
	FETCH get_total_risks into l_total_risks;
	CLOSE get_total_risks;

	OPEN  get_ineffective_controls;
	FETCH get_ineffective_controls into l_ineffective_controls;
	CLOSE get_ineffective_controls;

	OPEN  get_evaluated_controls;
	FETCH get_evaluated_controls into l_evaluated_controls;
	CLOSE get_evaluated_controls;

	OPEN  get_total_controls;
	FETCH get_total_controls into l_total_controls;
	CLOSE get_total_controls;

/*
	l_global_org_id := fnd_profile.value('AMW_GLOBAL_ORG_ID');

	IF  (l_global_org_id IS NOT NULL) AND (l_global_org_id = p_org_id)
	THEN
		l_global_process := 'Y';

		OPEN  get_total_org_certified(l_global_org_id);
		FETCH get_total_org_certified into l_total_org_process_cert;
		CLOSE get_total_org_certified;

		OPEN  get_org_processes_certified(l_global_org_id);
		FETCH get_org_processes_certified into l_org_process_cert;
		CLOSE get_org_processes_certified;

		OPEN  get_var_total_org_certified;
		FETCH get_var_total_org_certified
		 into l_var_total_org_process_cert;
		CLOSE get_var_total_org_certified;

		OPEN  get_var_org_proc_certified;
		FETCH get_var_org_proc_certified
		 into l_var_org_process_cert;
		CLOSE get_var_org_proc_certified;

		l_total_org_process_cert := l_total_org_process_cert +
					l_var_total_org_process_cert;
		l_org_process_cert := l_org_process_cert +
				     l_var_org_process_cert;
	END IF;
*/

	OPEN  get_certified_sub_processes;
	FETCH get_certified_sub_processes into l_sub_process_certified;
	CLOSE get_certified_sub_processes;

	OPEN  get_all_sub_processes;
	FETCH get_all_sub_processes into l_sub_process_total;
	CLOSE get_all_sub_processes;

	OPEN  get_sub_process_cert_issues;
	FETCH get_sub_process_cert_issues into l_sub_process_cert_issues;
	CLOSE get_sub_process_cert_issues;

    ---04.28.2005 npanandi: commenting below uniform setting to 'Y'
	---and setting to 'Y' only if p_org is the profile option Global Org
    ---l_global_process := 'Y';
	l_global_org_id := fnd_profile.value('AMW_GLOBAL_ORG_ID');
	IF  (l_global_org_id IS NOT NULL) AND (l_global_org_id = p_org_id) then
	   l_global_process := 'Y';
	end if;

	OPEN  get_total_org_certified;
	FETCH get_total_org_certified into l_total_org_process_cert;
	CLOSE get_total_org_certified;

	OPEN  get_org_processes_certified;
	FETCH get_org_processes_certified into l_org_process_cert;
	CLOSE get_org_processes_certified;

	OPEN  get_var_total_org_certified;
	FETCH get_var_total_org_certified  into l_var_total_org_process_cert;
	CLOSE get_var_total_org_certified;

	OPEN  get_var_org_proc_certified;
	FETCH get_var_org_proc_certified into l_var_org_process_cert;
	CLOSE get_var_org_proc_certified;


	OPEN  get_org_process_cert_issues;
	FETCH get_org_process_cert_issues into l_org_process_cert_issues;
	CLOSE get_org_process_cert_issues;

	OPEN  get_var_org_proc_cert_issues;
	FETCH get_var_org_proc_cert_issues into l_var_org_proc_cert_issues;
	CLOSE get_var_org_proc_cert_issues;

	l_total_org_process_cert := l_total_org_process_cert +
					l_var_total_org_process_cert;
	l_org_process_cert := l_org_process_cert +
				     l_var_org_process_cert;
	l_org_process_cert_issues := l_org_process_cert_issues +
				     l_var_org_proc_cert_issues;

	l_open_findings := amw_findings_pkg.calculate_open_findings('AMW_PROJ_FINDING',
	               						    'PROJ_ORG_PROC',
	               						    p_process_id,
	               						    'PROJ_ORG',
	               						    p_org_id,
							       	    null, null,
							       	    null, null,
							            null, null);

	l_open_issues := amw_findings_pkg.calculate_open_findings('AMW_PROC_CERT_ISSUES',
		               					  'PROCESS',
		               					  p_process_id,
		               					  'ORGANIZATION',
		               					  p_org_id,
								  'CERTIFICATION',
								  p_certification_id,
								  null, null,
							          null, null);

	UPDATE amw_proc_cert_eval_sum
	SET certification_opinion_id = l_certification_opinion_id,
	    evaluation_opinion_id    = l_evaluation_opinion_id,
	    evaluation_opinion_log_id= l_evaluation_opinion_log_id,
	    unmitigated_risks        = l_unmitigated_risks,
	    evaluated_risks          = l_evaluated_risks,
	    total_risks              = l_total_risks,
	    ineffective_controls     = l_ineffective_controls,
	    evaluated_controls       = l_evaluated_controls,
	    total_controls           = l_total_controls,
	    total_org_process_cert   = l_total_org_process_cert,
	    global_process           = l_global_process,
	    org_process_cert         = l_org_process_cert,
	    sub_process_cert         = l_sub_process_certified,
	    org_process_cert_issues  = l_org_process_cert_issues,
	    sub_process_cert_issues  = l_sub_process_cert_issues,
	    total_sub_process_cert   = l_sub_process_total,
	    open_findings            = l_open_findings,
	    open_issues		     = l_open_issues,
	    last_update_date 	     = SYSDATE,
	    last_updated_by          = G_USER_ID,
	    last_update_login        = G_LOGIN_ID,
	    UNMITIGATED_RISKS_PRCNT	=
				decode(l_total_risks, 0, 0, round(l_unmitigated_risks/l_total_risks*100)),
	    INEFFECTIVE_CONTROLS_PRCNT	=
				decode(l_total_controls, 0, 0, round(l_ineffective_controls/l_total_controls*100))
	WHERE process_id             = p_process_id
	AND certification_id         = p_certification_id
	AND organization_id          = p_org_id;

	IF (SQL%NOTFOUND)
	THEN

		INSERT INTO amw_proc_cert_eval_sum(certification_opinion_id,
						   evaluation_opinion_id,
						   evaluation_opinion_log_id,
	    					   unmitigated_risks,
	    					   evaluated_risks,
	    					   total_risks,
	    					   ineffective_controls,
	    					   evaluated_controls,
	    					   total_controls,
	    					   total_org_process_cert,
	    					   global_process,
	    					   org_process_cert,
	    					   sub_process_cert,
						   org_process_cert_issues,
						   sub_process_cert_issues,
	    					   total_sub_process_cert,
	    					   open_findings,
	    					   open_issues,
						   certification_id,
		                                   process_id,
		                                   organization_id,
		                                   created_by,
		                                   creation_date,
		                                   last_updated_by,
		                                   last_update_date,
		                                   last_update_login,
						   UNMITIGATED_RISKS_PRCNT,
						   INEFFECTIVE_CONTROLS_PRCNT)
		VALUES (l_certification_opinion_id,
			l_evaluation_opinion_id,
            l_evaluation_opinion_log_id,
			l_unmitigated_risks,
            l_evaluated_risks,
            l_total_risks,
			l_ineffective_controls,
            l_evaluated_controls,
            l_total_controls,
			l_total_org_process_cert,
			l_global_process,
			l_org_process_cert,
			l_sub_process_certified,
			l_org_process_cert_issues,
			l_sub_process_cert_issues,
			l_sub_process_total,
			l_open_findings,
			l_open_issues,
			p_certification_id,
		        p_process_id,
		        p_org_id,
		        G_USER_ID,
		        sysdate,
		        G_USER_ID,
		        sysdate,
		        G_LOGIN_ID,
			decode(l_total_risks, 0, 0, round(l_unmitigated_risks/l_total_risks*100)),
			decode(l_total_controls, 0, 0, round(l_ineffective_controls/l_total_controls*100)));

	END IF;

	EXCEPTION
	WHEN NO_DATA_FOUND
	THEN
	fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in update_summary_table'
	|| SUBSTR (SQLERRM, 1, 100), 1, 200));

	WHEN OTHERS
	THEN
	fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in update_summary_table'
	|| SUBSTR (SQLERRM, 1, 100), 1, 200));


END update_summary_table;

-- ===========================================================================
--   Procedure   : Populate_Summary
--   Description : Procedure will be called from concurrent program
-- ===========================================================================
PROCEDURE populate_summary
(p_certification_id 	IN 	NUMBER
)
IS

-- select all processes in scope for the certification
CURSOR get_all_processes
IS
SELECT DISTINCT process_id, organization_id
FROM amw_execution_scope
WHERE entity_type = 'BUSIPROC_CERTIFICATION'
AND entity_id = p_certification_id
AND process_id IS NOT NULL;

CURSOR get_specific_records
IS
SELECT last_update_date
FROM amw_proc_cert_eval_sum
WHERE certification_id = p_certification_id
FOR UPDATE NOWAIT;


proc_rec get_all_processes%rowtype;

BEGIN
	fnd_file.put_line (fnd_file.LOG, 'p_certification_id='||to_char(p_certification_id));
        fnd_file.put_line(fnd_file.LOG, 'start timestamp :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
	OPEN  get_specific_records;
	CLOSE get_specific_records;

	FOR proc_rec IN get_all_processes LOOP

		update_summary_table(proc_rec.process_id, proc_rec.organization_id, p_certification_id);

	END LOOP;

        populate_assoc_opinion(p_certification_id);
        fnd_file.put_line(fnd_file.LOG, 'end timestamp :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
	COMMIT;
	EXCEPTION
	     WHEN NO_DATA_FOUND
	     THEN
		fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Populate_Summary'
		|| SUBSTR (SQLERRM, 1, 100), 1, 200));

	     WHEN OTHERS
	     THEN
		fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_Summary'
		|| SUBSTR (SQLERRM, 1, 100), 1, 200));

END populate_summary;

-- ===========================================================================
--   Procedure   : POPULATE_ALL_CERT_SUMMARY
--   Description : Procedure will be called from concurrent program
-- ===========================================================================
PROCEDURE POPULATE_ALL_CERT_SUMMARY
(x_errbuf 		OUT 	NOCOPY VARCHAR2,
 x_retcode 		OUT 	NOCOPY NUMBER,
 p_certification_id     IN    	NUMBER
)
IS

-- select all processes in scope for the certification
CURSOR get_all_processes is
SELECT distinct CERTIFICATION_ID
FROM AMW_CERTIFICATION_VL
WHERE OBJECT_TYPE = 'PROCESS'
  AND certification_status in ('ACTIVE','DRAFT');

proc_rec get_all_processes%rowtype;

BEGIN
	fnd_file.put_line (fnd_file.LOG, 'Certification_Id:'||p_certification_id);

    	IF p_certification_id IS NOT NULL
    	THEN
		Populate_Summary(p_certification_id);
    	ELSE
    		FOR proc_rec in get_all_processes LOOP
			Populate_Summary(proc_rec.CERTIFICATION_ID);
		END LOOP;
    	END IF;

EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
          fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Populate_All_Cert_Summary'
          || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
     THEN
          fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_All_Cert_Summary'
          || SUBSTR (SQLERRM, 1, 100), 1, 200));

END POPULATE_ALL_CERT_SUMMARY;

-- ===========================================================================
--   Procedure   : POPULATE_CERT_GENERAL_SUM
--   Description : Procedure will be called from concurrent program
-- ===========================================================================
PROCEDURE  POPULATE_CERT_GENERAL_SUM
(p_certification_id     IN    	NUMBER,
 p_start_date		IN  	DATE
)
IS

    ---04.04.2005 npanandi: changed below query for bug 4253074
    CURSOR new_risks_added
    IS
	/*
        SELECT count(1)
	  FROM AMW_RISK_ASSOCIATIONS
         WHERE creation_date >= p_start_date
           AND object_type = 'PROCESS_ORG'
           AND pk1 in (SELECT apo.process_organization_id
           	         FROM AMW_CURR_APPROVED_REV_ORG_V apo, amw_execution_scope aes
           	        WHERE apo.process_id = aes.process_id
           	          AND apo.organization_id = aes.organization_id
           	          AND aes.entity_type = 'BUSIPROC_CERTIFICATION'
           	          AND aes.entity_id = p_certification_id);*/
       SELECT count(1)
         from (select distinct ara.risk_id, ara.pk1, ara.pk2
	     FROM AMW_RISK_ASSOCIATIONS ara,
		      amw_execution_scope aes,
			  ---05.24.2005 npanandi: added AmwCertificationB, AmwGlPeriodsV
			  ---in the joins below
			  amw_certification_b acb,
			  amw_gl_periods_v period,
			  amw_audit_units_v aauv --03.28.2007 npanandi: bug 5764832 fix -- added join to
                                     --AmwAuditUnitsV to make count consistent with the
                                     --'New Risks' added page results
		---05.24.2005 npanandi: changed below reference to creationDate
		---and added references to ApprovalDate and DeletionApprovalDate resp
        ---WHERE ara.creation_date >= p_start_date
		WHERE acb.certification_period_name = period.period_name
          and acb.certification_period_set_name = period.period_set_name
          and acb.certification_id = aes.entity_id
          ----and ara.APPROVAL_DATE <= p_start_date
		  ----05.24.2005 npanandi: p_start_date is the same as period.start_date here
		  and ara.APPROVAL_DATE between period.START_DATE and period.END_DATE
		  and nvl(ara.deletion_approval_date,period.END_DATE) >= period.END_DATE
		  --03.28.2007 npanandi: bug 5764832 fix -- added join to
          --AmwAuditUnitsV to make count consistent with the 'New Risks'
          --added page results
		  and aauv.organization_id = ara.pk1
          AND ara.object_type = 'PROCESS_ORG'
		  and ara.pk1=aes.ORGANIZATION_ID
		  and ara.pk2=aes.PROCESS_ID
		  and aes.ENTITY_TYPE='BUSIPROC_CERTIFICATION'
		  and aes.ENTITY_ID=p_certification_id);

    ---04.04.2005 npanandi: changed below query for bug 4253074
    CURSOR new_controls_added
    IS
        SELECT count(1)
          FROM (SELECT distinct aca.control_id, aes.organization_id
	              FROM AMW_CONTROL_ASSOCIATIONS aca,
				       AMW_RISK_ASSOCIATIONS ara,
	                   AMW_EXECUTION_SCOPE aes,
					   ---05.24.2005 npanandi: added AmwCertificationB, AmwGlPeriodsV
			           ---in the joins below
			           amw_certification_b acb,
			           amw_gl_periods_v period,
			           amw_audit_units_v aauv --03.28.2007 npanandi: bug 5764832 fix -- added join to
                                              --AmwAuditUnitsV to make count consistent with the
                                              --'New Controls' added page results
				 ---05.24.2005 npanandi: changed below reference to creationDate
		         ---and added references to ApprovalDate and DeletionApprovalDate resp
                 ---WHERE aca.creation_date >= p_start_date
                 WHERE acb.certification_period_name = period.period_name
                   and acb.certification_period_set_name = period.period_set_name
                   and acb.certification_id = aes.entity_id
		           and aca.approval_date between period.START_DATE and period.END_DATE ---<= p_start_date
				   and nvl(aca.deletion_approval_date,period.END_DATE) >= period.END_DATE ---p_start_date
                   AND aca.object_type = 'RISK_ORG'
                   --03.28.2007 npanandi: bug 5764832 fix -- added join to
                   --AmwAuditUnitsV to make count consistent with the 'New Controls'
                   --added page results
                   and aca.pk1 = aauv.organization_id
                   AND aca.pk1 = aes.ORGANIZATION_ID
				   and aca.pk2 = aes.PROCESS_ID
				   and aca.pk3 = ara.RISK_ID
                   AND ara.object_type = 'PROCESS_ORG'
           	       AND ara.pk1 = aca.pk1
				   AND ara.pk2 = aca.pk2
           	       AND aes.entity_type = 'BUSIPROC_CERTIFICATION'
           	       AND aes.entity_id = p_certification_id);

    CURSOR global_proc_not_certified IS
        SELECT count(1)
          FROM (SELECT distinct aes.organization_id, aes.process_id
                  FROM AMW_EXECUTION_SCOPE aes
                 WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
                   AND aes.entity_id = p_certification_id
                   AND aes.level_id > 3
                   AND aes.organization_id = fnd_profile.value('AMW_GLOBAL_ORG_ID')
                   AND not exists (SELECT 'Y'
				     FROM AMW_OPINIONS_V aov
				    WHERE aov.object_name = 'AMW_ORG_PROCESS'
				      AND aov.opinion_type_code = 'CERTIFICATION'
				      AND aov.pk3_value = aes.organization_id
				      AND aov.pk2_value = p_certification_id
				      AND aov.pk1_value = aes.process_id));
--modified by dliao on 10.06.05, add distinct on select statement.
--suggest to use amw_proc_cert_eval_sum instead of amw_execution_scope because it can sync with ProcCertIssuesVO definition.

    CURSOR global_proc_with_issue IS
    	SELECT count(1)
          FROM (SELECT distinct aes.organization_id, aes.process_id
                      FROM AMW_EXECUTION_SCOPE aes, AMW_OPINIONS_V aov
                     WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
                       AND aes.entity_id = p_certification_id
                       AND aes.organization_id = fnd_profile.value('AMW_GLOBAL_ORG_ID')
                       AND aes.level_id > 3
                       AND aov.object_name = 'AMW_ORG_PROCESS'
                       AND aov.opinion_type_code = 'CERTIFICATION'
                       AND aov.pk3_value = aes.organization_id
                       AND aov.pk2_value = p_certification_id
                       AND aov.pk1_value = aes.process_id
                   AND aov.audit_result_code <> 'EFFECTIVE');

    CURSOR local_proc_not_certified IS
        SELECT count(1)
          FROM (SELECT distinct aes.organization_id, aes.process_id
                  FROM AMW_EXECUTION_SCOPE aes
                 WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
                   AND aes.entity_id = p_certification_id
                   AND aes.level_id > 3
                   AND aes.organization_id <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999)
                   AND not exists (SELECT 'Y'
				     FROM AMW_OPINIONS_V aov
				    WHERE aov.object_name = 'AMW_ORG_PROCESS'
				      AND aov.opinion_type_code = 'CERTIFICATION'
				      AND aov.pk3_value = aes.organization_id
				      AND aov.pk2_value = p_certification_id
				      AND aov.pk1_value = aes.process_id));

    CURSOR local_proc_with_issue IS
    	SELECT count(1)
          FROM (SELECT aes.organization_id, aes.process_id
	      FROM AMW_EXECUTION_SCOPE aes, AMW_OPINIONS_V aov
	     WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
	       AND aes.entity_id = p_certification_id
	       AND aes.organization_id <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999)
	       AND aes.level_id > 3
	       AND aov.object_name = 'AMW_ORG_PROCESS'
	       AND aov.opinion_type_code = 'CERTIFICATION'
	       AND aov.pk3_value = aes.organization_id
	       AND aov.pk2_value = p_certification_id
	       AND aov.pk1_value = aes.process_id
               AND aov.audit_result_code <> 'EFFECTIVE');

    CURSOR global_proc_with_ineff_ctrl IS
    	SELECT count(distinct aes.process_id)
        FROM amw_execution_scope aes,amw_opinions_v aov
        WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
	AND aes.entity_id = p_certification_id
	AND aes.level_id > 3
	AND aes.organization_id = fnd_profile.value('AMW_GLOBAL_ORG_ID')
	AND aov.object_name = 'AMW_ORG_PROCESS'
	AND aov.opinion_type_code = 'EVALUATION'
	AND aov.pk3_value = aes.organization_id
	AND aov.pk1_value = aes.process_id
	AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				   FROM amw_opinions_v aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				    AND aov2.pk3_value = aov.pk3_value
				    AND aov2.pk1_value = aov.pk1_value)
        AND aov.audit_result_code <> 'EFFECTIVE';

    CURSOR local_proc_with_ineff_ctrl IS
    	SELECT count(1)
          FROM 	(SELECT distinct aes.organization_id, aes.process_id
               	 FROM amw_execution_scope aes,amw_opinions_v aov
		 WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
		 AND aes.entity_id = p_certification_id
		 AND aes.level_id > 3
		 AND aes.organization_id <> NVL(fnd_profile.value('AMW_GLOBAL_ORG_ID'),-999)
		 AND aov.object_name = 'AMW_ORG_PROCESS'
		 AND aov.opinion_type_code = 'EVALUATION'
		 AND aov.pk3_value = aes.organization_id
		 AND aov.pk1_value = aes.process_id
                 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
    			      		   FROM amw_opinions_v aov2
    			      		  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
    			      		    AND aov2.pk3_value = aov.pk3_value
                                            AND aov2.pk1_value = aov.pk1_value)
		 AND aov.audit_result_code <> 'EFFECTIVE');


    ---04.04.05 npanandi: changed the query below as per
	---AMw.D datamodel
    /** CURSOR unmitigated_risks IS
        SELECT count(1)
	  FROM (SELECT distinct aes.organization_id, aes.process_id, ara.risk_id
		  FROM AMW_EXECUTION_SCOPE aes, AMW_CURR_APPROVED_REV_ORG_V apo,
		       AMW_RISK_ASSOCIATIONS ara,
		       AMW_OPINIONS_V aov
		 WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
		   AND aes.entity_id = p_certification_id
		   AND aes.level_id > 3
		   AND apo.organization_id = aes.organization_id
		   AND apo.process_id = aes.process_id
		   AND ara.object_type = 'PROCESS_ORG'
		   AND ara.pk1 = apo.process_organization_id
		   AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
		   AND aov.opinion_type_code = 'EVALUATION'
		   AND aov.pk3_value = aes.organization_id
		   AND aov.pk4_value = aes.process_id
		   AND aov.pk1_value = ara.risk_id
		   AND aov.authored_date =
					(select max(aov2.authored_date)
					   from AMW_OPINIONS_V aov2
					  where aov2.object_opinion_type_id = aov.object_opinion_type_id
					    and aov2.pk4_value = aov.pk4_value
					    and aov2.pk3_value = aov.pk3_value
					    and aov2.pk1_value = aov.pk1_value)
	   AND aov.audit_result_code <> 'EFFECTIVE'); **/
    CURSOR unmitigated_risks IS
    SELECT count(1)
	  FROM (SELECT distinct aes.organization_id, aes.process_id, ara.risk_id
		      FROM AMW_EXECUTION_SCOPE aes,
		           AMW_RISK_ASSOCIATIONS ara,
		           AMW_OPINIONS_V aov, amw_audit_units_v aauv /* 03.19.2007 npanandi: bug 5862215 -- only consider those Orgs that are valid*/
		     WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
			   AND aes.entity_id = p_certification_id
			   AND aes.level_id > 3
			   ---AND apo.organization_id = aes.organization_id
			   ---AND apo.process_id = aes.process_id
			   AND ara.object_type = 'PROCESS_ORG'
			   AND ara.pk1 = aes.ORGANIZATION_ID
			   and ara.pk2 = aes.PROCESS_ID
			   /*03.19.2007 npanandi: bug 5862215 - consider those Orgs only that are valid*/
			   and ara.pk1 = aauv.organization_id
			   AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
			   AND aov.opinion_type_code = 'EVALUATION'
			   AND aov.pk3_value = aes.organization_id
			   AND aov.pk4_value = aes.process_id
			   AND aov.pk1_value = ara.risk_id
		   	   AND aov.authored_date = (select max(aov2.authored_date)
									      from AMW_OPINIONS_V aov2
									     where aov2.object_opinion_type_id = aov.object_opinion_type_id
									       and aov2.pk4_value = aov.pk4_value
									       and aov2.pk3_value = aov.pk3_value
									       and aov2.pk1_value = aov.pk1_value)
	   AND aov.audit_result_code <> 'EFFECTIVE');

    ---04.04.05 npanandi: changed the query below as per
	---AMw.D datamodel
    /* CURSOR ineffective_controls IS
        SELECT count(1)
          FROM (SELECT distinct aes.organization_id, aca.control_id
                  FROM AMW_EXECUTION_SCOPE aes, AMW_CURR_APPROVED_REV_ORG_V apo,
                       AMW_RISK_ASSOCIATIONS ara, AMW_CONTROL_ASSOCIATIONS aca,
                       AMW_OPINIONS_V aov
                 WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
                   AND aes.entity_id = p_certification_id
                   AND aes.level_id > 3
   	           AND apo.organization_id = aes.organization_id
   	           AND apo.process_id = aes.process_id
           	   AND ara.object_type = 'PROCESS_ORG'
           	   AND ara.pk1 = apo.process_organization_id
                   AND aca.object_type = 'RISK_ORG'
                   AND aca.pk1 = ara.risk_association_id
                   AND aov.object_name = 'AMW_ORG_CONTROL'
                   AND aov.opinion_type_code = 'EVALUATION'
                   AND aov.pk3_value = aes.organization_id
                   AND aov.pk1_value = aca.control_id
                   AND aov.authored_date =
			      		(select max(aov2.authored_date)
			      		   from AMW_OPINIONS_V aov2
			      		  where aov2.object_opinion_type_id = aov.object_opinion_type_id
			      		    and aov2.pk3_value = aov.pk3_value
                                            and aov2.pk1_value = aov.pk1_value)
                   AND aov.audit_result_code <> 'EFFECTIVE'); */
    CURSOR ineffective_controls IS
        SELECT count(1)
          FROM (SELECT distinct aes.organization_id, aca.control_id, aes.process_id /** 01/31/2007 npanandi: added processId in distinct **/
                  FROM AMW_EXECUTION_SCOPE aes, ---AMW_CURR_APPROVED_REV_ORG_V apo,
                       AMW_RISK_ASSOCIATIONS ara, AMW_CONTROL_ASSOCIATIONS aca,
                       AMW_OPINIONS_V aov, amw_audit_units_v aauv /* 03.19.2007 npanandi: bug 5862215: consider only those Orgs that are valid*/
                 WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
                   AND aes.entity_id = p_certification_id
                   AND aes.level_id > 3
   	               AND ara.object_type = 'PROCESS_ORG'
           	       AND ara.pk1 = aes.organization_id
				   AND ara.pk2 = aes.process_id
		   /* 03.19.2007 npanandi: bug 5862215: consider only those Orgs that are valid*/
		   and aauv.organization_id = aes.organization_id
                   AND aca.object_type = 'RISK_ORG'
                   AND aca.pk1 = ara.pk1
				   AND aca.pk2 = ara.pk2
				   AND aca.pk3 = ara.risk_id
                   AND aov.object_name = 'AMW_ORG_CONTROL'
                   AND aov.opinion_type_code = 'EVALUATION'
                   AND aov.pk3_value = aes.organization_id
                   AND aov.pk1_value = aca.control_id
                   AND aov.authored_date = (select max(aov2.authored_date)
							      		      from AMW_OPINIONS_V aov2
							      		     where aov2.object_opinion_type_id = aov.object_opinion_type_id
							      		       and aov2.pk3_value = aov.pk3_value
                                               and aov2.pk1_value = aov.pk1_value)
                   AND aov.audit_result_code <> 'EFFECTIVE');

    CURSOR orgs_pending_in_scope IS
        SELECT count(distinct aes.organization_id)
                  FROM AMW_EXECUTION_SCOPE aes
                 WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
                   AND aes.entity_id = p_certification_id
                   AND aes.level_id = 4
                   AND not exists (SELECT 'Y'
                             FROM AMW_OPINIONS_V aov
                            WHERE aov.object_name = 'AMW_ORG_PROCESS'
                              AND aov.opinion_type_code = 'CERTIFICATION'
                              AND aov.pk3_value = aes.organization_id
                              AND aov.pk2_value = p_certification_id
                              AND aov.pk1_value = aes.process_id);

    CURSOR orgs_in_scope IS
        SELECT count(distinct aes.organization_id)
                  FROM AMW_EXECUTION_SCOPE aes
                 WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
                   AND aes.entity_id = p_certification_id
                   AND aes.level_id = 3;

    CURSOR orgs_pending_cert IS
        SELECT count(distinct aes.organization_id)
                  FROM AMW_EXECUTION_SCOPE aes
                 WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
                   AND aes.entity_id = p_certification_id
                   AND aes.level_id = 3
                   AND not exists (SELECT 'Y'
                             FROM AMW_OPINIONS_V aov
                            WHERE aov.object_name = 'AMW_ORGANIZATION'
                              AND aov.opinion_type_code = 'CERTIFICATION'
                              AND aov.pk1_value = aes.organization_id
                              AND aov.pk2_value = p_certification_id);

    l_new_risks_added                	NUMBER;
    l_new_controls_added             	NUMBER;
    l_global_proc_not_certified      	NUMBER;
    l_global_proc_with_issue 	     	NUMBER;
    l_local_proc_not_certified 	     	NUMBER;
    l_local_proc_with_issue          	NUMBER;
    l_global_proc_with_ineff_ctrl 	NUMBER;
    l_local_proc_with_ineff_ctrl 	NUMBER;
    l_unmitigated_risks 		NUMBER;
    l_ineffective_controls 		NUMBER;
    l_orgs_in_scope			NUMBER;
    l_orgs_pending_in_scope		NUMBER;
    l_orgs_pending_cert			NUMBER;

BEGIN

    fnd_file.put_line (fnd_file.LOG, 'p_certification_id='||to_char(p_certification_id));

    fnd_file.put_line(fnd_file.LOG, 'before new_risks_added :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN new_risks_added;
    FETCH new_risks_added INTO l_new_risks_added;
    CLOSE new_risks_added;

    fnd_file.put_line(fnd_file.LOG, 'before new_controls_added :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN new_controls_added;
    FETCH new_controls_added INTO l_new_controls_added;
    CLOSE new_controls_added;

    fnd_file.put_line(fnd_file.LOG, 'before global_proc_not_certified:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN global_proc_not_certified;
    FETCH global_proc_not_certified INTO l_global_proc_not_certified;
    CLOSE global_proc_not_certified;

    fnd_file.put_line(fnd_file.LOG, 'before global_proc_with_issue:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN global_proc_with_issue;
    FETCH global_proc_with_issue INTO l_global_proc_with_issue;
    CLOSE global_proc_with_issue;

    fnd_file.put_line(fnd_file.LOG, 'before local_proc_not_certified:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN local_proc_not_certified;
    FETCH local_proc_not_certified INTO l_local_proc_not_certified;
    CLOSE local_proc_not_certified;

    fnd_file.put_line(fnd_file.LOG, 'before local_proc_with_issue:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN local_proc_with_issue;
    FETCH local_proc_with_issue INTO l_local_proc_with_issue;
    CLOSE local_proc_with_issue;

    fnd_file.put_line(fnd_file.LOG, 'before global_proc_with_ineff_ctrl:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN global_proc_with_ineff_ctrl;
    FETCH global_proc_with_ineff_ctrl INTO l_global_proc_with_ineff_ctrl;
    CLOSE global_proc_with_ineff_ctrl;

    fnd_file.put_line(fnd_file.LOG, 'before local_proc_with_ineff_ctrl:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN local_proc_with_ineff_ctrl;
    FETCH local_proc_with_ineff_ctrl INTO l_local_proc_with_ineff_ctrl;
    CLOSE local_proc_with_ineff_ctrl;

    fnd_file.put_line(fnd_file.LOG, 'before unmitigated_risks:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN unmitigated_risks;
    FETCH unmitigated_risks INTO l_unmitigated_risks;
    CLOSE unmitigated_risks;

    fnd_file.put_line(fnd_file.LOG, 'before ineffective_controls:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN ineffective_controls;
    FETCH ineffective_controls INTO l_ineffective_controls;
    CLOSE ineffective_controls;

    fnd_file.put_line(fnd_file.LOG, 'before orgs_pending_in_scop:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN orgs_pending_in_scope;
    FETCH orgs_pending_in_scope INTO l_orgs_pending_in_scope;
    CLOSE orgs_pending_in_scope;

    fnd_file.put_line(fnd_file.LOG, 'before orgs_in_scope:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
    OPEN orgs_in_scope;
    FETCH orgs_in_scope INTO l_orgs_in_scope;
    CLOSE orgs_in_scope;
    fnd_file.put_line(fnd_file.LOG, 'after orgs_in_scope:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));


    OPEN orgs_pending_cert;
    FETCH orgs_pending_cert INTO l_orgs_pending_cert;
    CLOSE orgs_pending_cert;
    fnd_file.put_line(fnd_file.LOG, 'after orgs_pending_cert:'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

    UPDATE  AMW_CERT_DASHBOARD_SUM
       SET NEW_RISKS_ADDED = l_new_risks_added,
           NEW_CONTROLS_ADDED = l_new_controls_added,
           PROCESSES_NOT_CERT = l_global_proc_not_certified,
           PROCESSES_CERT_ISSUES = l_global_proc_with_issue,
           ORG_PROCESS_NOT_CERT = l_local_proc_not_certified,
           ORG_PROCESS_CERT_ISSUES = l_local_proc_with_issue,
           PROC_INEFF_CONTROL = l_global_proc_with_ineff_ctrl,
           ORG_PROC_INEFF_CONTROL = l_local_proc_with_ineff_ctrl,
           UNMITIGATED_RISKS = l_unmitigated_risks,
           INEFFECTIVE_CONTROLS = l_ineffective_controls,
           ORGS_IN_SCOPE = l_orgs_in_scope,
           ORGS_PENDING_IN_SCOPE = l_orgs_pending_in_scope,
           PERIOD_START_DATE = p_start_date,
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	       LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID,
           ORGS_PENDING_CERTIFICATION = l_orgs_pending_cert
     WHERE certification_id = p_certification_id;

    IF (SQL%NOTFOUND) THEN
       INSERT INTO AMW_CERT_DASHBOARD_SUM (
	          CERTIFICATION_ID,
                  NEW_RISKS_ADDED,
                  NEW_CONTROLS_ADDED,
                  PROCESSES_NOT_CERT,
                  PROCESSES_CERT_ISSUES,
                  ORG_PROCESS_NOT_CERT,
                  ORG_PROCESS_CERT_ISSUES,
                  PROC_INEFF_CONTROL,
                  ORG_PROC_INEFF_CONTROL,
                  UNMITIGATED_RISKS,
                  INEFFECTIVE_CONTROLS,
                  ORGS_IN_SCOPE,
                  ORGS_PENDING_IN_SCOPE,
                  PERIOD_START_DATE,
	          CREATED_BY,
	          CREATION_DATE,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
	          LAST_UPDATE_LOGIN,
		  ORGS_PENDING_CERTIFICATION)
	SELECT p_certification_id,
       	       l_new_risks_added,
       	       l_new_controls_added,
       	       l_global_proc_not_certified,
       	       l_global_proc_with_issue,
       	       l_local_proc_not_certified,
       	       l_local_proc_with_issue,
	       l_global_proc_with_ineff_ctrl,
               l_local_proc_with_ineff_ctrl,
               l_unmitigated_risks,
               l_ineffective_controls,
               l_orgs_in_scope,
               l_orgs_pending_in_scope,
               p_start_date,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               SYSDATE,
	       FND_GLOBAL.USER_ID,
	       FND_GLOBAL.USER_ID,
	       l_orgs_pending_cert
	FROM  DUAL;
    END IF;
    commit;
EXCEPTION
WHEN OTHERS THEN
    fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_All_Cert_DetSummary'
    || SUBSTR (SQLERRM, 1, 100), 1, 200));

END POPULATE_CERT_GENERAL_SUM;


-- ===========================================================================
--   Procedure   : Populate_All_Cert_General_Sum
--   Description : Procedure will be called from concurrent program
-- ===========================================================================
PROCEDURE POPULATE_ALL_CERT_GENERAL_SUM
(errbuf       		OUT NOCOPY      VARCHAR2,
 retcode      		OUT NOCOPY      NUMBER,
 p_certification_id	IN	 	NUMBER
)
IS
    -- select all processes in scope for the certification
    CURSOR c_cert IS
        SELECT cert.CERTIFICATION_ID, period.start_date
          FROM AMW_CERTIFICATION_B cert, AMW_GL_PERIODS_V period
         WHERE cert.certification_period_name = period.period_name
           AND cert.certification_period_set_name = period.period_set_name
	   AND cert.certification_status in ('ACTIVE','DRAFT')
	   AND cert.OBJECT_TYPE = 'PROCESS';

    CURSOR c_start_date IS
    	SELECT period.start_date
          FROM AMW_CERTIFICATION_B cert, AMW_GL_PERIODS_V period
         WHERE cert.certification_period_name = period.period_name
           AND cert.certification_period_set_name = period.period_set_name
           AND cert.certification_id = p_certification_id;

    l_start_date DATE;

BEGIN

    fnd_file.put_line (fnd_file.LOG,
		      'Certification_Id:'||p_certification_id);
    IF p_certification_id IS NOT NULL
    THEN
        OPEN c_start_date;
        FETCH c_start_date INTO l_start_date;
        CLOSE c_start_date;
        Populate_Cert_General_Sum(p_certification_id, l_start_date);
    ELSE
        FOR cert_rec IN c_cert
        LOOP
            Populate_Cert_General_Sum(cert_rec.certification_id, cert_rec.start_date);
        END LOOP;
    END IF;

EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Populate_All_Cert_General_Sum'
         || SUBSTR (SQLERRM, 1, 100), 1, 200));
     WHEN OTHERS
     THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_All_Cert_General_Sum'
         || SUBSTR (SQLERRM, 1, 100), 1, 200));
         errbuf := SQLERRM;
		 ---05.24.2005 npanandi: changed retcode to 2 to comply with number datatype
         retcode := 2; --FND_API.G_RET_STS_UNEXP_ERROR;
END POPULATE_ALL_CERT_GENERAL_SUM;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Populate_Proc_Cert_Sum  	                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  This procedure is called by the concurrent program.                      |
 |  This procedure will call 2 sub requests to synchronize the Business      |
 |  Process Certification Data.                                              |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS : IN :                                                          |
 |    p_certification_id : The Certification id
 |                                                                           |
 | RETURNS   : NONE                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE  Populate_Proc_Cert_Sum(
    errbuf       OUT NOCOPY      VARCHAR2,
    retcode      OUT NOCOPY      VARCHAR2,
    p_certification_id  IN       NUMBER
)
IS

l_request_id            NUMBER;
l_msg                   VARCHAR2(2000);
l_reqdata               VARCHAR2(240);
lx_return_status	VARCHAR2(1);
lx_msg_count		NUMBER;
lx_msg_data		VARCHAR2(2000);

CURSOR get_all_certifications IS
SELECT cert.certification_id
  FROM amw_certification_b cert
 WHERE cert.certification_status in ('ACTIVE','DRAFT')
   AND cert.object_type = 'PROCESS';

BEGIN
  fnd_file.put_line (fnd_file.LOG,'Certification Id :' || p_certification_id);

  l_reqdata := FND_CONC_GLOBAL.request_data;
  IF (l_reqdata is NOT NULL) THEN
     return;
  END IF;
  l_reqdata := 1;

  fnd_file.put_line(fnd_file.LOG, 'reset execution scope start...'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

  --The following section is commented
  --In AMW.D and future releases we don't need to rescope everytime the user runs the concurrent program

  /*IF p_certification_id IS NOT NULL
     THEN
          amw_process_cert_scope_pvt.insert_audit_units
	    (p_certification_id => p_certification_id,
	     x_return_status    => lx_return_status,
	     x_msg_count        => lx_msg_count,
             x_msg_data         => lx_msg_data);
          commit;

          IF lx_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     	fnd_file.put_line(fnd_file.LOG, 'Problems in insert audit units' || lx_msg_data ||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
     	  END IF;

     ELSE
          FOR each_record IN get_all_certifications
          LOOP
              amw_process_cert_scope_pvt.insert_audit_units
	       (p_certification_id => each_record.certification_id,
	        x_return_status    => lx_return_status,
	        x_msg_count        => lx_msg_count,
                x_msg_data         => lx_msg_data);
              commit;

              IF lx_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	        fnd_file.put_line(fnd_file.LOG, 'Problems in insert audit units' || lx_msg_data || to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
     	      END IF;
          END LOOP;
  END IF;*/


  fnd_file.put_line(fnd_file.LOG, 'reset execution scope end...'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

  /* Sub Request for Dashboard Summary */
  l_request_id := FND_REQUEST.SUBMIT_REQUEST('AMW',
                                             'PCDASHSUM',
                                             null,
                                             null,
                                             TRUE,
                                             to_char(p_certification_id));
  IF l_request_id = 0 THEN
    l_msg:=FND_MESSAGE.GET;
    fnd_file.put_line (fnd_file.LOG,l_msg);
  ELSE
    fnd_file.put_line (fnd_file.LOG,'Submitted Request for Dashboard Summary :' || l_request_id );
  END IF;


  /* Sub Request for Evaluation Summary for Processes */
  l_request_id := FND_REQUEST.SUBMIT_REQUEST('AMW',
                                             'PCEVALSUM',
                                             null,
                                             null,
                                             TRUE,
                                             to_char(p_certification_id));
  IF l_request_id = 0 THEN
    l_msg:=FND_MESSAGE.GET;
    fnd_file.put_line (fnd_file.LOG,l_msg);
  ELSE
    fnd_file.put_line (fnd_file.LOG,'Submitted Request for Evaluation Summary for processes :' || l_request_id );
  END IF;

  /* Sub Request for Evaluation Summary for Organizations */
  l_request_id := FND_REQUEST.SUBMIT_REQUEST('AMW',
                                             'PCORGSUM',
                                              null,
                                              null,
                                              TRUE,
                                              to_char(p_certification_id));
  IF l_request_id = 0 THEN
     l_msg:=FND_MESSAGE.GET;
     fnd_file.put_line (fnd_file.LOG,l_msg);
  ELSE
     fnd_file.put_line (fnd_file.LOG,'Submitted Request for Evaluation Summary for organizations :' || l_request_id );
  END IF;


  FND_CONC_GLOBAL.set_req_globals(conc_status       => 'PAUSED',
                                   request_data      => l_reqdata);
  COMMIT;

EXCEPTION
     WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_Proc_Cert_Sum'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));
         errbuf := SQLERRM;
         retcode := FND_API.G_RET_STS_UNEXP_ERROR;

END Populate_Proc_Cert_Sum;


PROCEDURE populate_findings
(p_certification_id 	IN 	NUMBER
)
IS

-- select all processes in scope for the certification
CURSOR get_all_processes
IS
SELECT DISTINCT process_id, organization_id
FROM amw_execution_scope
WHERE entity_type = 'BUSIPROC_CERTIFICATION'
AND entity_id = p_certification_id
AND process_id IS NOT NULL;

CURSOR get_all_orgs
IS
SELECT DISTINCT organization_id
FROM amw_execution_scope
WHERE entity_type = 'BUSIPROC_CERTIFICATION'
AND entity_id = p_certification_id
AND level_id = 3;

l_open_findings NUMBER;
l_open_issues NUMBER;


BEGIN
  fnd_file.put_line (fnd_file.LOG, 'p_certification_id='||to_char(p_certification_id));
  fnd_file.put_line(fnd_file.LOG, 'start timestamp :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));


  FOR proc_rec IN get_all_processes LOOP
    l_open_findings := amw_findings_pkg.calculate_open_findings(
		    'AMW_PROJ_FINDING',
	            'PROJ_ORG_PROC',
	            proc_rec.process_id,
	            'PROJ_ORG',
	            proc_rec.organization_id,
		    null, null,
	       	    null, null,
		    null, null);

    l_open_issues := amw_findings_pkg.calculate_open_findings(
		    'AMW_PROC_CERT_ISSUES',
		    'PROCESS',
		    proc_rec.process_id,
		    'ORGANIZATION',
		    proc_rec.organization_id,
		    'CERTIFICATION',
		    p_certification_id,
		    null, null,
		    null, null);

    UPDATE amw_proc_cert_eval_sum
	SET open_findings            = l_open_findings,
	    open_issues		     = l_open_issues,
	    last_update_date 	     = SYSDATE,
	    last_updated_by          = G_USER_ID,
	    last_update_login        = G_LOGIN_ID
    WHERE process_id		     = proc_rec.process_id
	AND certification_id         = p_certification_id
	AND organization_id          = proc_rec.organization_id;
  END LOOP;

  FOR org_rec IN get_all_orgs LOOP
    l_open_findings := amw_findings_pkg.calculate_open_findings(
		    'AMW_PROJ_FINDING',
	            'PROJ_ORG',
	            org_rec.organization_id,
		    null, null,
		    null, null,
	       	    null, null,
		    null, null);

    l_open_issues := amw_findings_pkg.calculate_open_findings(
		    'AMW_PROC_CERT_ISSUES',
		    'ORGANIZATION',
		    org_rec.organization_id,
		    'CERTIFICATION',
		    p_certification_id,
		    null, null,
		    null, null,
		    null, null);

    UPDATE amw_org_cert_eval_sum
	SET open_findings            = l_open_findings,
	    open_issues		     = l_open_issues,
	    last_update_date 	     = SYSDATE,
	    last_updated_by          = G_USER_ID,
	    last_update_login        = G_LOGIN_ID
    WHERE certification_id         = p_certification_id
	AND organization_id          = org_rec.organization_id;
  END LOOP;

  fnd_file.put_line(fnd_file.LOG, 'end timestamp :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
  COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Populate_Summary'
		|| SUBSTR (SQLERRM, 1, 100), 1, 200));
  WHEN OTHERS THEN
    fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_Summary'
		|| SUBSTR (SQLERRM, 1, 100), 1, 200));

END populate_findings;

PROCEDURE Populate_Proccert_Findings
(x_errbuf 		OUT 	NOCOPY VARCHAR2,
 x_retcode 		OUT 	NOCOPY NUMBER,
 p_certification_id     IN    	NUMBER
)
IS

-- select all processes in scope for the certification
CURSOR get_all_processes is
SELECT distinct CERTIFICATION_ID
FROM AMW_CERTIFICATION_VL
WHERE OBJECT_TYPE = 'PROCESS'
  AND certification_status in ('ACTIVE','DRAFT');

proc_rec get_all_processes%rowtype;

BEGIN
	fnd_file.put_line (fnd_file.LOG, 'Certification_Id:'||p_certification_id);

    	IF p_certification_id IS NOT NULL
    	THEN
		Populate_Findings(p_certification_id);
    	ELSE
    		FOR proc_rec in get_all_processes LOOP
			Populate_Findings(proc_rec.CERTIFICATION_ID);
		END LOOP;
    	END IF;

EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
          fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Populate_Proccert_Findings'
          || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
     THEN
          fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Populate_Proccert_Findings'
          || SUBSTR (SQLERRM, 1, 100), 1, 200));

END Populate_Proccert_Findings;


END AMW_PROCESS_CERT_SUMMARY;

/
