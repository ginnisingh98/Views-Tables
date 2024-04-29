--------------------------------------------------------
--  DDL for Package Body AMW_ORG_CERT_EVAL_SUM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_ORG_CERT_EVAL_SUM_PVT" AS
/* $Header: amwocertb.pls 120.4 2005/11/18 19:49:01 appldev noship $ */

G_USER_ID NUMBER   := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER  := FND_GLOBAL.CONC_LOGIN_ID;

G_PKG_NAME    CONSTANT VARCHAR2 (30) := 'AMW_ORG_CERT_EVAL_SUM_PVT';
G_FILE_NAME   CONSTANT VARCHAR2 (15) := 'amwocertb.pls';


PROCEDURE populate_org_cert_summary
(
	x_errbuf 		    OUT      NOCOPY VARCHAR2,
	x_retcode		    OUT      NOCOPY NUMBER,
	p_certification_id     	    IN       NUMBER

)
IS

l_api_name           CONSTANT VARCHAR2(30) := 'populate_org_cert_summary';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);


CURSOR get_all_certifications is
SELECT distinct CERTIFICATION_ID
FROM AMW_CERTIFICATION_VL
WHERE OBJECT_TYPE = 'PROCESS'
AND certification_status in ('ACTIVE','DRAFT');

cert_rec get_all_certifications%rowtype;

BEGIN

	SAVEPOINT populate_org_summary;

	fnd_file.put_line (fnd_file.LOG, 'Certification_Id:'||p_certification_id);

	IF p_certification_id IS NULL
	THEN
		FOR each_rec in get_all_certifications LOOP
			populate_org_cert_sum_spec (each_rec.certification_id);
		END LOOP;
	ELSE
		populate_org_cert_sum_spec (p_certification_id);
	END IF;

	EXCEPTION WHEN NO_DATA_FOUND
	     THEN
	          fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in populate_org_cert_summary'
	          || SUBSTR (SQLERRM, 1, 100), 1, 200));

	     WHEN OTHERS
	     THEN
	          fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in populate_org_cert_summary'
          	  || SUBSTR (SQLERRM, 1, 100), 1, 200));

END populate_org_cert_summary
	;
PROCEDURE populate_org_cert_sum_spec
(
	p_certification_id 	IN 	NUMBER
)
IS

l_api_name           CONSTANT VARCHAR2(30) := 'populate_org_cert_sum_spec';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

-- select all organizations in scope for the certification
CURSOR get_all_orgs
IS
SELECT DISTINCT organization_id
FROM 	amw_execution_scope
WHERE	entity_type = 'BUSIPROC_CERTIFICATION'
AND 	entity_id = p_certification_id
AND 	organization_id is not null;

proc_rec get_all_orgs%rowtype;

BEGIN
	SAVEPOINT populate_org_specific;

	FOR org_rec IN get_all_orgs LOOP
		populate_summary
		(
		p_api_version_number    => 1.0 ,
		p_org_id		=> org_rec.organization_id,
		p_certification_id      => p_certification_id,
		x_return_status         => l_return_status,
		x_msg_count             => l_msg_count,
		x_msg_data              => l_msg_data
		);
	END LOOP;

	fnd_file.put_line(fnd_file.LOG, 'end timestamp :'||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

	EXCEPTION WHEN OTHERS THEN
	ROLLBACK TO POPULATE_ORG_SPECIFIC;
	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'populate_org_cert_sum_spec');

END populate_org_cert_sum_spec;


PROCEDURE populate_summary
(
	p_api_version_number        IN       NUMBER,
	p_init_msg_list             IN       VARCHAR2 := FND_API.g_false,
	p_commit                    IN       VARCHAR2 := FND_API.g_false,
	p_validation_level          IN       NUMBER := fnd_api.g_valid_level_full,
	p_org_id 		    IN 	     NUMBER,
	p_certification_id 	    IN 	     NUMBER,
	x_return_status             OUT      nocopy VARCHAR2,
	x_msg_count                 OUT      nocopy NUMBER,
	x_msg_data                  OUT      nocopy VARCHAR2
)
IS

CURSOR get_certification_opinion
IS
SELECT opinion.opinion_id
FROM   amw_opinions_v opinion
WHERE opinion.pk1_value = p_org_id
AND   opinion.pk2_value = p_certification_id
AND   opinion.opinion_type_code = 'CERTIFICATION'
AND   opinion.object_name = 'AMW_ORGANIZATION';

CURSOR get_evaluation_opinion
IS
SELECT  opinion.opinion_id
FROM    amw_opinions_v opinion
WHERE	(opinion.authored_date IN (SELECT MAX(opinion2.authored_date)
				   FROM amw_opinions_v opinion2
				   WHERE opinion2.object_opinion_type_id = opinion.object_opinion_type_id
				   AND   opinion2.pk1_value = opinion.pk1_value
				   )
	)
AND	opinion.pk1_value = p_org_id
AND	opinion.opinion_type_code = 'EVALUATION'
AND	opinion.object_name = 'AMW_ORGANIZATION';

CURSOR get_evaluation_opinion_log
IS
SELECT  opinion.opinion_log_id
FROM    amw_opinions_log_v opinion
WHERE	(opinion.authored_date IN (SELECT MAX(opinion2.authored_date)
				   FROM amw_opinions opinion2
				   WHERE opinion2.object_opinion_type_id = opinion.object_opinion_type_id
				   AND   opinion2.pk1_value = opinion.pk1_value)
	)
AND	opinion.pk1_value = p_org_id
AND	opinion.opinion_type_code = 'EVALUATION'
AND	opinion.object_name = 'AMW_ORGANIZATION';

CURSOR get_unmitigated_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
	FROM amw_risk_associations ara,amw_opinions_v aov
	WHERE ara.object_type 	  = 'BUSIPROC_CERTIFICATION'
	AND ara.pk1 		  = p_certification_id
	AND ara.pk2               = p_org_id
	AND aov.object_name 	  = 'AMW_ORG_PROCESS_RISK'
	AND aov.opinion_type_code = 'EVALUATION'
	AND aov.pk1_value 	  = ara.risk_id
	AND aov.pk3_value 	  = p_org_id
	AND NVL(aov.pk4_value,-1)
				  = NVL(ara.pk3, -1) --process_id
	AND aov.audit_result_code <> 'EFFECTIVE'
	AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				  AND NVL(aov2.pk4_value, -1)
						= NVL(aov.pk4_value, -1)
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value)

	);

CURSOR get_evaluated_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
	FROM amw_risk_associations ara,amw_opinions_v aov
	WHERE ara.object_type 	  = 'BUSIPROC_CERTIFICATION'
	AND ara.pk1 		  = p_certification_id
	AND ara.pk2               = p_org_id
	AND aov.object_name 	  = 'AMW_ORG_PROCESS_RISK'
	AND aov.opinion_type_code = 'EVALUATION'
	AND aov.pk1_value 	  = ara.risk_id
	AND aov.pk3_value 	  = ara.pk2 --org_id
	AND NVL(aov.pk4_value, -1)
	    	  = NVL(ara.pk3, -1) --process_id
	AND aov.audit_result_code IS NOT NULL
	);

CURSOR get_total_risks
IS
---07.05.2005 npanandi: added ara.pk3 below for processId --- bugfix for bug 4471783
---10.03.2005 dliao: change count(pk3) to count(1) because of entity_risk
SELECT count(1) from (
select distinct ara.pk3, ara.risk_id
FROM amw_risk_associations ara
WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
AND ara.pk1 		  = p_certification_id
AND ara.pk2           = p_org_id);

CURSOR get_ineffective_controls
IS
SELECT count(1)
---07.05.2005 npanandi: changed below query to have a distinct on
---certificationId, organizationId, controlId
---instead of having a distinct on
---certificationId, organizationId, processId, riskId, controlId
---FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.pk3 process_id, aca.pk4 risk_id, aca.control_id
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.control_id
	FROM amw_control_associations aca,amw_opinions_v aov
	WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
	AND aca.pk1 		  = p_certification_id
	AND aca.pk2               = p_org_id
	AND aov.object_name       = 'AMW_ORG_CONTROL'
	AND aov.opinion_type_code = 'EVALUATION'
	AND aov.pk1_value 	  = aca.control_id
	AND aov.pk3_value 	  = aca.pk2
	AND aov.audit_result_code <> 'EFFECTIVE'
	AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				FROM amw_opinions aov2
				WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				AND aov2.pk3_value = aov.pk3_value
				AND aov2.pk1_value = aov.pk1_value)
	);


CURSOR get_evaluated_controls
IS
SELECT count(1)
---07.05.2005 npanandi: changed below query to have a distinct on
---certificationId, organizationId, controlId
---instead of having a distinct on
---certificationId, organizationId, processId, riskId, controlId
---FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.pk3 process_id, aca.pk4 risk_id, aca.control_id
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.control_id
	FROM amw_control_associations aca,amw_opinions_v aov
	WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
	AND aca.pk1 		  = p_certification_id
	AND aca.pk2               = p_org_id
	AND aov.object_name       = 'AMW_ORG_CONTROL'
	AND aov.opinion_type_code = 'EVALUATION'
	AND aov.pk1_value 	  = aca.control_id
	AND aov.pk3_value 	  = aca.pk2
	AND aov.audit_result_code IS NOT NULL
	);

CURSOR get_total_controls
IS
SELECT count(DISTINCT aca.control_id)
FROM amw_control_associations aca
WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
AND aca.pk1 		  = p_certification_id
AND aca.pk2               = p_org_id;

CURSOR get_all_processes
IS
SELECT count(distinct process_id)
FROM   amw_execution_scope
WHERE  organization_id   = p_org_id
AND    entity_id         = p_certification_id
---07.05.2005 npanandi: added entity_type below, bugfix for bug 4471783
AND    entity_type       = 'BUSIPROC_CERTIFICATION';

--modified by dliao 11.8.2005
--change object_name to 'AMW_ORG_PROCESS' from 'AMW_PROCESS_ORG'
CURSOR get_certified_processes
IS
SELECT count(DISTINCT process_id)
FROM   amw_execution_scope amw_exec
WHERE EXISTS (SELECT  opinion.opinion_id
	FROM amw_opinions_v opinion
	WHERE opinion.pk1_value = amw_exec.process_id
	AND   opinion.pk3_value = p_org_id
	AND   opinion.pk2_value = p_certification_id
	AND   opinion.opinion_type_code = 'CERTIFICATION'
	AND   opinion.object_name = 'AMW_ORG_PROCESS'
);

--modified by dliao 11.8.2005
--change object_name to 'AMW_ORG_PROCESS' from 'AMW_PROCESS_ORG'
CURSOR get_proc_cert_issues
IS
SELECT count(DISTINCT process_id)
FROM   amw_execution_scope amw_exec
WHERE EXISTS (SELECT  opinion.opinion_id
	FROM amw_opinions_v opinion
	WHERE opinion.pk1_value = amw_exec.process_id
	AND   opinion.pk3_value = p_org_id
	AND   opinion.pk2_value = p_certification_id
	AND   opinion.opinion_type_code = 'CERTIFICATION'
	AND   opinion.object_name = 'AMW_ORG_PROCESS'
	AND   opinion.audit_result_code <> 'EFFECTIVE'
);

--modified by dliao 10.13.2005
--pk2_value should be project id when the type code is evaluation
--add max() to get the latest evaluation result
--add entity_type and entity_id
CURSOR get_evaluated_processes
IS
SELECT count(DISTINCT process_id)
FROM   amw_execution_scope amw_exec
WHERE amw_exec.entity_type = 'BUSIPROC_CERTIFICATION'
AND amw_exec.entity_id = p_certification_id
AND EXISTS (SELECT  opinion.opinion_id
	FROM amw_opinions_v opinion
	WHERE opinion.pk1_value = amw_exec.process_id
	--AND   opinion.pk2_value = p_certification_id
	AND   opinion.pk3_value = p_org_id
	AND   opinion.opinion_type_code = 'EVALUATION'
	AND   opinion.object_name = 'AMW_ORG_PROCESS'
	AND   opinion.audit_result_code IS NOT NULL
	AND    opinion.authored_date = (SELECT MAX(aov2.authored_date)
                                FROM amw_opinions aov2
                                WHERE aov2.object_opinion_type_id = opinion.object_opinion_type_id
                                AND aov2.pk3_value = opinion.pk3_value
                                AND aov2.pk1_value = opinion.pk1_value)
);

--modified by dliao 10.13.2005
--pk2_value should be project id when the type code is evaluation
--add max() to get the latest evaluation result
--add entity_type and entity_id
CURSOR get_ineffective_processes
IS
SELECT count(DISTINCT process_id)
FROM   amw_execution_scope amw_exec
WHERE amw_exec.entity_type = 'BUSIPROC_CERTIFICATION'
AND amw_exec.entity_id = p_certification_id
AND EXISTS (SELECT  opinion.opinion_id
	FROM amw_opinions_v opinion
	WHERE opinion.pk1_value = amw_exec.process_id
	--AND   opinion.pk2_value = p_certification_id
	AND   opinion.pk3_value = p_org_id
	AND   opinion.opinion_type_code = 'EVALUATION'
	AND   opinion.object_name = 'AMW_ORG_PROCESS'
	AND   opinion.audit_result_code <> 'EFFECTIVE'
	AND    opinion.authored_date = (SELECT MAX(aov2.authored_date)
                                FROM amw_opinions aov2
                                WHERE aov2.object_opinion_type_id = opinion.object_opinion_type_id
                                AND aov2.pk3_value = opinion.pk3_value
                                AND aov2.pk1_value = opinion.pk1_value)
);

CURSOR get_certified_sub_orgs
IS
SELECT count(distinct object_id)
FROM   amw_entity_hierarchies ent
WHERE EXISTS (SELECT  opinion.opinion_id
		FROM  amw_opinions_v opinion
		WHERE opinion.pk1_value = p_org_id
		AND   opinion.pk2_value = p_certification_id
		AND   opinion.opinion_type_code = 'CERTIFICATION'
		AND   opinion.object_name = 'AMW_ORGANIZATION'
	     )
START WITH parent_object_id = p_org_id
       AND parent_object_type = 'ORG'
       AND entity_id = p_certification_id
       AND entity_type = 'BUSIPROC_CERTIFICATION'
CONNECT BY PRIOR object_id = PRIOR parent_object_id
             AND object_type = PRIOR parent_object_type
	     AND entity_id = PRIOR entity_id
	     AND entity_type = PRIOR entity_type;

CURSOR get_sub_org_cert_issues
IS
SELECT count(distinct object_id)
FROM   amw_entity_hierarchies ent
WHERE EXISTS (SELECT  opinion.opinion_id
		FROM  amw_opinions_v opinion
		WHERE opinion.pk1_value = p_org_id
		AND   opinion.pk2_value = p_certification_id
		AND   opinion.opinion_type_code = 'CERTIFICATION'
		AND   opinion.object_name = 'AMW_ORGANIZATION'
		AND   opinion.audit_result_code <> 'EFFECTIVE'
	     )
START WITH parent_object_id = p_org_id
       AND parent_object_type = 'ORG'
       AND entity_id = p_certification_id
       AND entity_type = 'BUSIPROC_CERTIFICATION'
CONNECT BY PRIOR object_id = PRIOR parent_object_id
             AND object_type = PRIOR parent_object_type
	     AND entity_id = PRIOR entity_id
	     AND entity_type = PRIOR entity_type;

CURSOR get_total_sub_orgs
IS
SELECT count(distinct object_id)
FROM   amw_entity_hierarchies ent
START WITH parent_object_id = p_org_id
       AND parent_object_type = 'ORG'
       AND entity_id = p_certification_id
	   ---07.05.2005 npanandi: add entityType, bugfix 4471783
	   and entity_type='BUSIPROC_CERTIFICATION'
CONNECT BY PRIOR object_id = PRIOR parent_object_id
     	     AND object_type = PRIOR parent_object_type
	     AND entity_id = PRIOR entity_id
		 ---07.05.2005 npanandi: add entityType, bugfix 4471783
	     and entity_type=prior entity_type;

CURSOR get_top_org_processes
IS
SELECT count(distinct aes.process_id)
FROM amw_execution_scope aes
WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
AND aes.level_id = 4
AND aes.parent_process_id = -1
AND aes.entity_id = p_certification_id
AND aes.organization_id = p_org_id;

CURSOR get_top_orgproc_pend_cert
IS
SELECT count(distinct aes.process_id)
FROM amw_execution_scope aes
WHERE aes.entity_type 	= 'BUSIPROC_CERTIFICATION'
AND aes.level_id 	= 4
AND aes.parent_process_id = -1   --need to verify if this is -2
AND aes.entity_id 	= p_certification_id
AND aes.organization_id = p_org_id
AND NOT EXISTS (SELECT 'Y'
     		FROM AMW_OPINIONS_V aov
    		WHERE aov.object_name = 'AMW_ORG_PROCESS'
    		  AND aov.opinion_type_code = 'CERTIFICATION'
    		  AND aov.pk3_value = aes.organization_id
    		  AND aov.pk2_value = p_certification_id
    		  AND aov.pk1_value = aes.process_id);

l_certification_opinion_id NUMBER;
l_evaluation_opinion_id NUMBER;
l_evaluation_opinion_log_id NUMBER;
l_unmitigated_risks NUMBER;
l_evaluated_risks NUMBER;
l_total_risks NUMBER;
l_ineffective_controls NUMBER;
l_evaluated_controls NUMBER;
l_total_controls NUMBER;
l_processes_certified NUMBER;
l_processes_total NUMBER;
l_sub_orgs NUMBER;
l_all_orgs NUMBER;
l_open_findings NUMBER;
l_open_issues NUMBER;
l_top_org_processes NUMBER;
l_top_orgproc_pend_cert NUMBER;
l_evaluated_processes NUMBER;
l_ineffective_processes NUMBER;
l_proc_cert_issues	NUMBER;
l_sub_org_cert_issues	NUMBER;

l_api_name           CONSTANT VARCHAR2(30) := 'populate_summary';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);


BEGIN

	SAVEPOINT populate_summ;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					     p_api_version_number,
					     l_api_name,
					     G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

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

	OPEN  get_certified_processes;
	FETCH get_certified_processes into l_processes_certified;
	CLOSE get_certified_processes;

	OPEN  get_evaluated_processes;
	FETCH get_evaluated_processes into l_evaluated_processes;
	CLOSE get_evaluated_processes;

	OPEN  get_ineffective_processes;
	FETCH get_ineffective_processes into l_ineffective_processes;
	CLOSE get_ineffective_processes;

	OPEN  get_all_processes;
	FETCH get_all_processes into l_processes_total;
	CLOSE get_all_processes;

	OPEN  get_certified_sub_orgs;
	FETCH get_certified_sub_orgs into l_sub_orgs;
	CLOSE get_certified_sub_orgs;

	OPEN get_total_sub_orgs;
	FETCH get_total_sub_orgs into l_all_orgs;
	CLOSE get_total_sub_orgs;

	OPEN get_top_org_processes;
	FETCH get_top_org_processes into l_top_org_processes;
	CLOSE get_top_org_processes;

	OPEN get_top_orgproc_pend_cert;
	FETCH get_top_orgproc_pend_cert into l_top_orgproc_pend_cert;
	CLOSE get_top_orgproc_pend_cert;

	OPEN get_sub_org_cert_issues;
	FETCH get_sub_org_cert_issues into l_sub_org_cert_issues;
	CLOSE get_sub_org_cert_issues;

	OPEN get_proc_cert_issues;
	FETCH get_proc_cert_issues into l_proc_cert_issues;
	CLOSE get_proc_cert_issues;

	l_open_findings := amw_findings_pkg.calculate_open_findings('AMW_PROJ_FINDING',
								    'PROJ_ORG',
								    p_org_id,
								    null, null,
								    null, null,
								    null, null,
								    null, null);

	l_open_issues := amw_findings_pkg.calculate_open_findings('AMW_PROC_CERT_ISSUES',
								  'ORGANIZATION',
								  p_org_id,
								  'CERTIFICATION',
								  p_certification_id,
								  null, null,
								  null, null,
								  null, null);
	UPDATE AMW_ORG_CERT_EVAL_SUM
	SET certification_opinion_id = l_certification_opinion_id,
	    evaluation_opinion_id    = l_evaluation_opinion_id,
	    evaluation_opinion_log_id= l_evaluation_opinion_log_id,
	    unmitigated_risks        = l_unmitigated_risks,
	    evaluated_risks          = l_evaluated_risks,
	    total_risks              = l_total_risks,
	    ineffective_controls     = l_ineffective_controls,
	    evaluated_controls       = l_evaluated_controls,
	    total_controls           = l_total_controls,
	    processes_certified      = l_processes_certified,
	    evaluated_processes      = l_evaluated_processes,
	    ineff_processes          = l_ineffective_processes,
	    total_processes          = l_processes_total,
	    sub_org_cert   	     = l_sub_orgs,
	    total_sub_org	     = l_all_orgs,
	    top_org_processes	     = l_top_org_processes,
	    top_org_proc_pending_cert= l_top_orgproc_pend_cert,
	    open_findings            = l_open_findings,
	    open_issues		     = l_open_issues,
	    last_update_date 	     = SYSDATE,
	    last_updated_by          = G_USER_ID,
	    last_update_login        = G_LOGIN_ID,
	    SUB_ORG_CERT_ISSUES	     = l_sub_org_cert_issues,
	    PROC_CERT_ISSUES	     = l_proc_cert_issues,
	    INEFF_PROCESSES_PRCNT    =
		decode(l_processes_total, 0, 0, round(l_ineffective_processes/l_processes_total*100)),
	    UNMITIGATED_RISKS_PRCNT  =
	        decode(l_total_risks, 0, 0, round(l_unmitigated_risks/l_total_risks*100)),
	    INEFF_CONTROLS_PRCNT     =
	        decode(l_total_controls, 0, 0, round(l_ineffective_controls/l_total_controls*100))
	WHERE certification_id       = p_certification_id
	AND organization_id          = p_org_id;

	IF (SQL%NOTFOUND)
	THEN

		INSERT INTO AMW_ORG_CERT_EVAL_SUM(certification_opinion_id,
						   evaluation_opinion_id,
						   evaluation_opinion_log_id,
						   unmitigated_risks,
						   evaluated_risks,
	    					   total_risks,
	    					   ineffective_controls,
	    					   evaluated_controls,
	    					   total_controls,
						   processes_certified,
						   evaluated_processes,
						   ineff_processes,
						   total_processes,
						   sub_org_cert,
						   total_sub_org,
						   top_org_processes,
		   				   top_org_proc_pending_cert,
						   open_findings,
						   open_issues,
						   certification_id,
						   organization_id,
						   created_by,
						   creation_date,
						   last_updated_by,
						   last_update_date,
						   last_update_login,
						   sub_org_cert_issues,
						   proc_cert_issues,
						   INEFF_PROCESSES_PRCNT,
						   UNMITIGATED_RISKS_PRCNT,
						   INEFF_CONTROLS_PRCNT)

		VALUES (l_certification_opinion_id,
			l_evaluation_opinion_id,
			l_evaluation_opinion_log_id,
			l_unmitigated_risks,
			l_evaluated_risks,
			l_total_risks,
			l_ineffective_controls,
			l_evaluated_controls,
			l_total_controls,
			l_processes_certified,
			l_evaluated_processes,
			l_ineffective_processes,
			l_processes_total,
			l_sub_orgs,
			l_all_orgs,
			l_top_org_processes,
			l_top_orgproc_pend_cert,
			l_open_findings,
			l_open_issues,
			p_certification_id,
			p_org_id,
			G_USER_ID,
			sysdate,
			G_USER_ID,
			sysdate,
			G_LOGIN_ID,
			l_sub_org_cert_issues,
			l_proc_cert_issues,
			decode(l_processes_total, 0, 0, round(l_ineffective_processes/l_processes_total*100)),
			decode(l_total_risks, 0, 0, round(l_unmitigated_risks/l_total_risks*100)),
			decode(l_total_controls, 0, 0, round(l_ineffective_controls/l_total_controls*100)));
	END IF;

	EXCEPTION WHEN OTHERS
	THEN
		ROLLBACK TO populate_summ;
		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'populate_summary');
		FND_MSG_PUB.Count_And_Get(
		p_encoded =>  FND_API.G_FALSE,
		p_count   =>  x_msg_count,
		p_data    =>  x_msg_data);
END populate_summary;

END AMW_ORG_CERT_EVAL_SUM_PVT;

/
