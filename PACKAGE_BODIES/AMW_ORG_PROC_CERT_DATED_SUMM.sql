--------------------------------------------------------
--  DDL for Package Body AMW_ORG_PROC_CERT_DATED_SUMM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_ORG_PROC_CERT_DATED_SUMM" as
/* $Header: amwpcerb.pls 120.0 2005/07/29 00:36:25 appldev noship $ */


-- ORGANIZATION FUNCTIONs

-- Get number of unmitigated risks given a certification and org within the certification
-- If fromDate and toDate are passed, then only evaluations created within that period are considered.
-- If material risks flag is passed, then only material risks are considered.
-- Considers entity risks also.
FUNCTION get_unmit_risk_for_org
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_unmitigated_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
	 FROM amw_risk_associations ara, amw_opinions_log_v aov, amw_risks_b arb
	 WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
	 AND ara.pk1 = p_certification_id
	 AND ara.pk2 = p_org_id
     AND ara.risk_rev_id = arb.risk_rev_id
     AND nvl(p_material_risks_flag, nvl(arb.material, 'N')) = nvl(arb.material, 'N')
	 AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value = ara.pk2 --org_id
	 AND nvl(aov.pk4_value, -1) = nvl(ara.pk3, -1) --process_id
	 AND aov.pk1_value = ara.risk_id
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1)
				  AND nvl(aov2.pk4_value, -1) = nvl(aov.pk4_value, -1)
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value)
     AND aov.audit_result_code <> 'EFFECTIVE'
	 );

l_unmit_risks NUMBER;
BEGIN
    l_unmit_risks := 0;
	OPEN  get_unmitigated_risks;
	FETCH get_unmitigated_risks into l_unmit_risks;
	CLOSE get_unmitigated_risks;

    RETURN l_unmit_risks;
END get_unmit_risk_for_org;


-- Get number of evaluated risks given a certification and org within the certification
-- If fromDate and toDate are passed, then only evaluations created within that period are considered.
-- If material risks flag is passed, then only material risks are considered.
-- Considers entity risks also.
FUNCTION get_eval_risk_for_org
(p_certification_id         IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_eval_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
	 FROM amw_risk_associations ara, amw_opinions_log_v aov, amw_risks_b arb
	 WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
	 AND ara.pk1 = p_certification_id
	 AND ara.pk2 = p_org_id
     AND ara.risk_rev_id = arb.risk_rev_id
     AND nvl(p_material_risks_flag, nvl(arb.material, 'N')) = nvl(arb.material, 'N')
	 AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value = ara.pk2 --org_id
	 AND nvl(aov.pk4_value, -1) = nvl(ara.pk3, -1) --process_id
	 AND aov.pk1_value = ara.risk_id
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1)
	              AND nvl(aov2.pk4_value, -1) = nvl(aov.pk4_value, -1) --process_id
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value)
	 AND aov.audit_result_code IS NOT NULL
	 );
l_eval_risks          NUMBER;
BEGIN
    l_eval_risks := 0;
	OPEN  get_eval_risks;
	FETCH get_eval_risks into l_eval_risks;
	CLOSE get_eval_risks;
    RETURN l_eval_risks;
END get_eval_risk_for_org;

-- Get number of risks given a certification and org within the certification
-- If material risks flag is passed, then only material risks are considered.
-- Considers entity risks also.
FUNCTION get_total_risks_for_org
(p_certification_id         IN NUMBER,
 p_org_id               in NUMBER,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_total_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
FROM amw_risk_associations ara, amw_risks_b arb
WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
AND ara.risk_rev_id = arb.risk_rev_id
AND nvl(p_material_risks_flag, nvl(arb.material, 'N')) = nvl(arb.material, 'N')
AND ara.pk1 = p_certification_id
AND ara.pk2 = p_org_id);

l_total_risks          NUMBER;
BEGIN
    l_total_risks := 0;
	OPEN  get_total_risks;
	FETCH get_total_risks into l_total_risks;
	CLOSE get_total_risks;
    RETURN l_total_risks;
END get_total_risks_for_org;


FUNCTION get_unmit_risk_prcnt_for_org
(p_certification_id         IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_total_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
FROM amw_risk_associations ara, amw_risks_b arb
WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
AND ara.risk_rev_id = arb.risk_rev_id
AND nvl(p_material_risks_flag, nvl(arb.material, 'N')) = nvl(arb.material, 'N')
AND ara.pk1 = p_certification_id
AND ara.pk2 = p_org_id);

CURSOR get_unmitigated_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
	 FROM amw_risk_associations ara, amw_opinions_log_v aov, amw_risks_b arb
	 WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
	 AND ara.pk1 = p_certification_id
	 AND ara.pk2 = p_org_id
     AND ara.risk_rev_id = arb.risk_rev_id
     AND nvl(p_material_risks_flag, nvl(arb.material, 'N')) = nvl(arb.material, 'N')
	 AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value = ara.pk2 --org_id
	 AND nvl(aov.pk4_value, -1) = nvl(ara.pk3, -1) --process_id
	 AND aov.pk1_value = ara.risk_id
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1)
				  AND nvl(aov2.pk4_value, -1) = nvl(aov.pk4_value, -1)
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value)
     AND aov.audit_result_code <> 'EFFECTIVE'
	 );

l_total_risks       NUMBER;
l_unmitigated_risks NUMBER;
l_risk_prcnt        NUMBER;
BEGIN
    l_total_risks := 0;
	OPEN  get_total_risks;
	FETCH get_total_risks into l_total_risks;
	CLOSE get_total_risks;

    l_unmitigated_risks := 0;
	OPEN  get_unmitigated_risks;
	FETCH get_unmitigated_risks into l_unmitigated_risks;
	CLOSE get_unmitigated_risks;

    if l_total_risks = 0
    then
        RETURN l_total_risks;
    else
	    l_risk_prcnt	:= round(l_unmitigated_risks/l_total_risks*100);
        RETURN l_risk_prcnt;
    END IF;
END get_unmit_risk_prcnt_for_org;

-- Get number of evaluated controls given a certification and org within the certification
-- If key controls flag is passed, then only key controls are considered.
FUNCTION get_eval_ctrls_for_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_eval_controls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.control_id
	 FROM amw_control_associations aca,amw_opinions_log_v aov, amw_controls_b acb
	 WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
     AND acb.control_rev_id = aca.control_rev_id
     AND nvl(acb.key_mitigating, 'N') = nvl(p_key_ctrls_flag, nvl(acb.key_mitigating, 'N'))
	 AND aca.pk1 		   = p_certification_id
	 AND aca.pk2               = p_org_id
	 AND aov.object_name       = 'AMW_ORG_CONTROL'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value         = p_org_id
	 AND aov.pk1_value         = aca.control_id
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1))
	 AND aov.audit_result_code IS NOT NULL);
l_eval_ctrls          NUMBER;
BEGIN
    l_eval_ctrls := 0;
	OPEN  get_eval_controls;
	FETCH get_eval_controls into l_eval_ctrls;
	CLOSE get_eval_controls;
    RETURN l_eval_ctrls;
END get_eval_ctrls_for_org;


-- Get number of controls given a certification and org within the certification
-- If key controls flag is passed, then only key controls are considered.
FUNCTION get_total_ctrls_for_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_total_controls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.control_id
FROM amw_control_associations aca, amw_controls_b acb
WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
AND acb.control_rev_id = aca.control_rev_id
AND nvl(acb.key_mitigating, 'N') = nvl(p_key_ctrls_flag, nvl(acb.key_mitigating, 'N'))
AND aca.pk1 		  = p_certification_id
AND aca.pk2               = p_org_id);
l_total_ctrls          NUMBER;
BEGIN
    l_total_ctrls := 0;
	OPEN  get_total_controls;
	FETCH get_total_controls into l_total_ctrls;
	CLOSE get_total_controls;
    RETURN l_total_ctrls;
END get_total_ctrls_for_org;

-- Get number of ineffective controls given a certification and org within the certification
-- If key controls flag is passed, then only key controls are considered.
FUNCTION get_ineff_ctrls_for_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_ineff_controls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.control_id
	 FROM amw_control_associations aca,amw_opinions_log_v aov, amw_controls_b acb
	 WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
     AND acb.control_rev_id = aca.control_rev_id
     AND nvl(acb.key_mitigating, 'N') = nvl(p_key_ctrls_flag, nvl(acb.key_mitigating, 'N'))
	 AND aca.pk1 		       = p_certification_id
	 AND aca.pk2               = p_org_id
	 AND aov.object_name       = 'AMW_ORG_CONTROL'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value         = p_org_id
	 AND aov.pk1_value         = aca.control_id
	 AND aov.audit_result_code <> 'EFFECTIVE'
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1))
     );

l_ineff_ctrls          NUMBER;
BEGIN
    l_ineff_ctrls := 0;
	OPEN  get_ineff_controls;
	FETCH get_ineff_controls into l_ineff_ctrls;
	CLOSE get_ineff_controls;
    RETURN l_ineff_ctrls;
END get_ineff_ctrls_for_org;

FUNCTION get_ineff_ctrl_prcnt_for_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_ineff_controls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.control_id
	 FROM amw_control_associations aca,amw_opinions_log_v aov, amw_controls_b acb
	 WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
     AND acb.control_rev_id = aca.control_rev_id
     AND nvl(acb.key_mitigating, 'N') = nvl(p_key_ctrls_flag, nvl(acb.key_mitigating, 'N'))
	 AND aca.pk1 		       = p_certification_id
	 AND aca.pk2               = p_org_id
	 AND aov.object_name       = 'AMW_ORG_CONTROL'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value         = p_org_id
	 AND aov.pk1_value         = aca.control_id
	 AND aov.audit_result_code <> 'EFFECTIVE'
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1))
     );
CURSOR get_total_controls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.control_id
FROM amw_control_associations aca, amw_controls_b acb
WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
AND acb.control_rev_id = aca.control_rev_id
AND nvl(acb.key_mitigating, 'N') = nvl(p_key_ctrls_flag, nvl(acb.key_mitigating, 'N'))
AND aca.pk1 		  = p_certification_id
AND aca.pk2               = p_org_id);

l_total_controls NUMBER;
l_ineff_controls NUMBER;
l_ctrl_prcnt     NUMBER;

BEGIN
    l_ineff_controls := 0;
	OPEN  get_ineff_controls;
	FETCH get_ineff_controls into l_ineff_controls;
	CLOSE get_ineff_controls;

    l_total_controls := 0;
	OPEN  get_total_controls;
	FETCH get_total_controls into l_total_controls;
	CLOSE get_total_controls;

    if l_total_controls = 0
    then
        RETURN l_total_controls;
    else
	    l_ctrl_prcnt	:= round(l_ineff_controls/l_total_controls*100);
        RETURN l_ctrl_prcnt;
    END IF;
END get_ineff_ctrl_prcnt_for_org;


-- Get number of process given a certification and org within the certification
-- If significant process flag is passed then filter on significant process flag.
FUNCTION get_all_process_in_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_sig_process in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_all_processes
IS
SELECT count(distinct process_id)
FROM   amw_execution_scope
WHERE  organization_id   = p_org_id
AND    entity_id         = p_certification_id
AND level_id > 4;
l_total_proc           NUMBER;
BEGIN
    l_total_proc := 0;
	OPEN  get_all_processes;
	FETCH get_all_processes into l_total_proc;
	CLOSE get_all_processes;
    RETURN l_total_proc;
END get_all_process_in_org;


-- Get number of process certified given a certification and org within the certification
-- If significant process flag is passed then filter on significant process flag.
FUNCTION get_cert_process_in_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_sig_process in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_certified_processes
IS
SELECT count(DISTINCT aes.process_id)
FROM   amw_execution_scope aes, amw_opinions_log_v opinion, amw_process_organization apo
WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
AND aes.organization_id = p_org_id
AND aes.entity_id = p_certification_id
AND aes.level_id > 4
AND apo.process_org_rev_id = aes.process_org_rev_id
AND nvl(apo.significant_process_flag, 'N') = nvl(p_sig_process, nvl(apo.significant_process_flag, 'N'))
AND opinion.pk1_value = aes.process_id
AND   opinion.pk3_value = aes.organization_id
AND   opinion.pk2_value = aes.entity_id
AND   opinion.opinion_type_code = 'CERTIFICATION'
AND   opinion.object_name = 'AMW_PROCESS_ORG'
AND opinion.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = opinion.object_opinion_type_id
				  AND aov2.pk3_value = opinion.pk3_value
				  AND aov2.pk1_value = opinion.pk1_value
				  AND aov2.pk2_value = opinion.pk2_value
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1));
l_certified_proc           NUMBER;
BEGIN
    l_certified_proc := 0;
	OPEN  get_certified_processes;
	FETCH get_certified_processes into l_certified_proc;
	CLOSE get_certified_processes;
    RETURN l_certified_proc;
END get_cert_process_in_org;


-- Get number of process certified with issues given a certification and org within the certification
-- If significant process flag is passed then filter on significant process flag.
FUNCTION get_process_cert_issues_in_org
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_sig_process in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_proc_cert_issues
IS
SELECT count(DISTINCT aes.process_id)
FROM   amw_execution_scope aes, amw_opinions_log_v opinion, amw_process_organization apo
WHERE aes.entity_type = 'BUSIPROC_CERTIFICATION'
AND aes.organization_id = p_org_id
AND aes.entity_id = p_certification_id
AND aes.level_id > 4
AND apo.process_org_rev_id = aes.process_org_rev_id
AND nvl(apo.significant_process_flag, 'N') = nvl(p_sig_process, nvl(apo.significant_process_flag, 'N'))
AND opinion.pk1_value = aes.process_id
AND   opinion.pk3_value = aes.organization_id
AND   opinion.pk2_value = aes.entity_id
AND   opinion.opinion_type_code = 'CERTIFICATION'
AND   opinion.object_name = 'AMW_PROCESS_ORG'
AND opinion.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = opinion.object_opinion_type_id
				  AND aov2.pk3_value = opinion.pk3_value
				  AND aov2.pk1_value = opinion.pk1_value
				  AND aov2.pk2_value = opinion.pk2_value
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1))
AND   opinion.audit_result_code <> 'EFFECTIVE';
l_proc_CWI           NUMBER;
BEGIN
    l_proc_CWI := 0;
	OPEN  get_proc_cert_issues;
	FETCH get_proc_cert_issues into l_proc_CWI;
	CLOSE get_proc_cert_issues;
    RETURN l_proc_CWI;
END get_process_cert_issues_in_org;


-----------------------------------------------------------------------------------------------------
-- ORG PROCESS FUNCTIONs

-- Get number of ineffective controls given a certification, process and org within the certification
-- If key controls flag is passed, then only key controls are considered.
FUNCTION get_ineff_ctrls_for_org_proc
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER
IS

CURSOR get_ineff_controls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.pk3 process_id, aca.control_id
	 FROM amw_control_associations aca,amw_opinions_log_v aov, amw_controls_b acb
	 WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
     AND acb.control_rev_id = aca.control_rev_id
     AND nvl(acb.key_mitigating, 'N') = nvl(p_key_ctrls_flag, nvl(acb.key_mitigating, 'N'))
	 AND aca.pk1 		       = p_certification_id
	 AND aca.pk2               = p_org_id
	 AND aca.pk3               IN (SELECT DISTINCT process_id
	 	 		  	       FROM   amw_execution_scope
	 	 		  	       START WITH process_id = p_process_id
                           AND entity_type = aca.object_type
	 	 		  	       AND organization_id = p_org_id
	 	 		  	       AND entity_id = p_certification_id
	 	 		  	       CONNECT BY PRIOR process_id = parent_process_id
	 	 		  	       AND organization_id = PRIOR organization_id
	 	 		  	       AND entity_id = PRIOR entity_id
                           AND entity_type = PRIOR entity_type
	 	 		  	       )
	 AND aov.object_name       = 'AMW_ORG_CONTROL'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value         = p_org_id
	 AND aov.pk1_value         = aca.control_id
	 AND aov.audit_result_code <> 'EFFECTIVE'
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1))
     );
 l_ineff_ctrls          NUMBER;
BEGIN
    l_ineff_ctrls := 0;
	OPEN  get_ineff_controls;
	FETCH get_ineff_controls into l_ineff_ctrls;
	CLOSE get_ineff_controls;
    RETURN l_ineff_ctrls;
END get_ineff_ctrls_for_org_proc;


-- Get number of evaluated controls given a certification, process and org within the certification
-- If key controls flag is passed, then only key controls are considered.
FUNCTION get_eval_ctrls_for_org_proc
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_eval_controls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.pk3 process_id, aca.control_id
	 FROM amw_control_associations aca,amw_opinions_log_v aov, amw_controls_b acb
	 WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
     AND acb.control_rev_id = aca.control_rev_id
     AND nvl(acb.key_mitigating, 'N') = nvl(p_key_ctrls_flag, nvl(acb.key_mitigating, 'N'))
	 AND aca.pk1 		   = p_certification_id
	 AND aca.pk2               = p_org_id
	 AND aca.pk3               IN (SELECT DISTINCT process_id
	 	 		  	       FROM   amw_execution_scope
	 	 		  	       START WITH process_id = p_process_id
                           AND entity_type = aca.object_type
	 	 		  	       AND organization_id = p_org_id
	 	 		  	       AND entity_id = p_certification_id
	 	 		  	       CONNECT BY PRIOR process_id = parent_process_id
	 	 		  	       AND organization_id = PRIOR organization_id
	 	 		  	       AND entity_id = PRIOR entity_id
                           AND entity_type = PRIOR entity_type
	 	 		  	       )
	 AND aov.object_name       = 'AMW_ORG_CONTROL'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value         = p_org_id
	 AND aov.pk1_value         = aca.control_id
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1))
	 AND aov.audit_result_code IS NOT NULL);
l_eval_ctrls          NUMBER;
BEGIN
    l_eval_ctrls := 0;
	OPEN  get_eval_controls;
	FETCH get_eval_controls into l_eval_ctrls;
	CLOSE get_eval_controls;
    RETURN l_eval_ctrls;
END get_eval_ctrls_for_org_proc;

-- Get number of controls given a certification, process and org within the certification
-- If key controls flag is passed, then only key controls are considered.
FUNCTION get_total_ctrls_for_org_proc
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_total_controls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.pk3 process_id, aca.control_id
FROM amw_control_associations aca, amw_controls_b acb
WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
AND acb.control_rev_id = aca.control_rev_id
AND nvl(acb.key_mitigating, 'N') = nvl(p_key_ctrls_flag, nvl(acb.key_mitigating, 'N'))
AND aca.pk1 		  = p_certification_id
AND aca.pk2           = p_org_id
AND aca.pk3           IN (SELECT DISTINCT process_id
			       FROM   amw_execution_scope
			       START WITH process_id = p_process_id
                   AND entity_type = aca.object_type
			       AND organization_id = p_org_id
			       AND entity_id = p_certification_id
			       CONNECT BY PRIOR process_id = parent_process_id
			       AND organization_id = PRIOR organization_id
			       AND entity_id = PRIOR entity_id
                   AND entity_type = PRIOR entity_type
			       ));
l_total_ctrls          NUMBER;
BEGIN
    l_total_ctrls := 0;
	OPEN  get_total_controls;
	FETCH get_total_controls into l_total_ctrls;
	CLOSE get_total_controls;
    RETURN l_total_ctrls;
END get_total_ctrls_for_org_proc;


FUNCTION get_ineff_ctrl_prcnt_org_proc
(p_certification_id     IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_key_ctrls_flag    in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_ineff_controls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.pk3 process_id, aca.control_id
	 FROM amw_control_associations aca,amw_opinions_log_v aov, amw_controls_b acb
	 WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
     AND acb.control_rev_id = aca.control_rev_id
     AND nvl(acb.key_mitigating, 'N') = nvl(p_key_ctrls_flag, nvl(acb.key_mitigating, 'N'))
	 AND aca.pk1 		       = p_certification_id
	 AND aca.pk2               = p_org_id
	 AND aca.pk3               IN (SELECT DISTINCT process_id
	 	 		  	       FROM   amw_execution_scope
	 	 		  	       START WITH process_id = p_process_id
                           AND entity_type = aca.object_type
	 	 		  	       AND organization_id = p_org_id
	 	 		  	       AND entity_id = p_certification_id
	 	 		  	       CONNECT BY PRIOR process_id = parent_process_id
	 	 		  	       AND organization_id = PRIOR organization_id
	 	 		  	       AND entity_id = PRIOR entity_id
                           AND entity_type = PRIOR entity_type
	 	 		  	       )
	 AND aov.object_name       = 'AMW_ORG_CONTROL'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value         = p_org_id
	 AND aov.pk1_value         = aca.control_id
	 AND aov.audit_result_code <> 'EFFECTIVE'
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1))
     );
CURSOR get_total_controls
IS
SELECT count(1)
FROM 	(SELECT DISTINCT aca.pk1 certification_id, aca.pk2 organization_id, aca.pk3 process_id, aca.control_id
FROM amw_control_associations aca, amw_controls_b acb
WHERE aca.object_type     = 'BUSIPROC_CERTIFICATION'
AND acb.control_rev_id = aca.control_rev_id
AND nvl(acb.key_mitigating, 'N') = nvl(p_key_ctrls_flag, nvl(acb.key_mitigating, 'N'))
AND aca.pk1 		  = p_certification_id
AND aca.pk2           = p_org_id
AND aca.pk3           IN (SELECT DISTINCT process_id
			       FROM   amw_execution_scope
			       START WITH process_id = p_process_id
                   AND entity_type = aca.object_type
			       AND organization_id = p_org_id
			       AND entity_id = p_certification_id
			       CONNECT BY PRIOR process_id = parent_process_id
			       AND organization_id = PRIOR organization_id
			       AND entity_id = PRIOR entity_id
                   AND entity_type = PRIOR entity_type
			       ));
l_total_controls NUMBER;
l_ineff_controls NUMBER;
l_ctrl_prcnt     NUMBER;

BEGIN
    l_ineff_controls := 0;
	OPEN  get_ineff_controls;
	FETCH get_ineff_controls into l_ineff_controls;
	CLOSE get_ineff_controls;

    l_total_controls := 0;
	OPEN  get_total_controls;
	FETCH get_total_controls into l_total_controls;
	CLOSE get_total_controls;

    if l_total_controls = 0
    then
        RETURN l_total_controls;
    else
	    l_ctrl_prcnt	:= round(l_ineff_controls/l_total_controls*100);
        RETURN l_ctrl_prcnt;
    END IF;
END get_ineff_ctrl_prcnt_org_proc;


FUNCTION get_unmit_risk_prcnt_org_proc
(p_certification_id         IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_total_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
FROM amw_risk_associations ara, amw_risks_b arb
WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
AND ara.risk_rev_id = arb.risk_rev_id
AND nvl(p_material_risks_flag, nvl(arb.material, 'N')) = nvl(arb.material, 'N')
AND ara.pk1 = p_certification_id
AND ara.pk2 = p_org_id
AND ara.pk3 IN (SELECT DISTINCT process_id
		FROM   amw_execution_scope
		START WITH process_id = p_process_id
        AND entity_type = ara.object_type
		AND organization_id = p_org_id
		AND entity_id = p_certification_id
		CONNECT BY PRIOR process_id = parent_process_id
		AND organization_id = PRIOR organization_id
		AND entity_id = PRIOR entity_id
        AND entity_type = PRIOR entity_type
	       ));
CURSOR get_unmitigated_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
	 FROM amw_risk_associations ara, amw_opinions_log_v aov, amw_risks_b arb
	 WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
	 AND ara.pk1 = p_certification_id
	 AND ara.pk2 = p_org_id
     AND ara.risk_rev_id = arb.risk_rev_id
     AND nvl(p_material_risks_flag, nvl(arb.material, 'N')) = nvl(arb.material, 'N')
	 AND ara.pk3 IN (SELECT DISTINCT process_id
				FROM   amw_execution_scope
				START WITH process_id = p_process_id
                AND entity_type = ara.object_type
                AND organization_id = p_org_id
				AND entity_id = p_certification_id
				CONNECT BY PRIOR process_id = parent_process_id
				AND organization_id = PRIOR organization_id
				AND entity_id = PRIOR entity_id
                AND entity_type = PRIOR entity_type
			       )
	 AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value = ara.pk2 --org_id
	 AND aov.pk4_value = ara.pk3 --process_id
	 AND aov.pk1_value = ara.risk_id
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1)
				  AND aov2.pk4_value = aov.pk4_value
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value)
     AND aov.audit_result_code <> 'EFFECTIVE'
	 );

l_total_risks NUMBER;
l_unmitigated_risks NUMBER;
l_risk_prcnt        NUMBER;
BEGIN
    l_total_risks := 0;
	OPEN  get_total_risks;
	FETCH get_total_risks into l_total_risks;
	CLOSE get_total_risks;

    l_unmitigated_risks := 0;
	OPEN  get_unmitigated_risks;
	FETCH get_unmitigated_risks into l_unmitigated_risks;
	CLOSE get_unmitigated_risks;

    if l_total_risks = 0
    then
        RETURN l_total_risks;
    else
	    l_risk_prcnt	:= round(l_unmitigated_risks/l_total_risks*100);
        RETURN l_risk_prcnt;
    END IF;
END get_unmit_risk_prcnt_org_proc;

-- Get number of risks given a certification, process and org within the certification
-- If material risks flag is passed, then only material risks are considered.
FUNCTION get_total_risks_for_org_proc
(p_certification_id         IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_total_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
FROM amw_risk_associations ara, amw_risks_b arb
WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
AND ara.risk_rev_id = arb.risk_rev_id
AND nvl(p_material_risks_flag, nvl(arb.material, 'N')) = nvl(arb.material, 'N')
AND ara.pk1 = p_certification_id
AND ara.pk2 = p_org_id
AND ara.pk3 IN (SELECT DISTINCT process_id
		FROM   amw_execution_scope
		START WITH process_id = p_process_id
        AND entity_type = ara.object_type
		AND organization_id = p_org_id
		AND entity_id = p_certification_id
		CONNECT BY PRIOR process_id = parent_process_id
		AND organization_id = PRIOR organization_id
		AND entity_id = PRIOR entity_id
        AND entity_type = PRIOR entity_type
	       ));
l_total_risks          NUMBER;
BEGIN
    l_total_risks := 0;
	OPEN  get_total_risks;
	FETCH get_total_risks into l_total_risks;
	CLOSE get_total_risks;
    RETURN l_total_risks;
END get_total_risks_for_org_proc;


-- Get number of evaluated risks given a certification, process and org within the certification
-- If fromDate and toDate are passed, then only evaluations created within that period are considered.
-- If material risks flag is passed, then only material risks are considered.
FUNCTION get_eval_risk_for_org_proc
(p_certification_id         IN NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_eval_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
	 FROM amw_risk_associations ara, amw_opinions_log_v aov, amw_risks_b arb
	 WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
	 AND ara.pk1 = p_certification_id
	 AND ara.pk2 = p_org_id
     AND ara.risk_rev_id = arb.risk_rev_id
     AND nvl(p_material_risks_flag, nvl(arb.material, 'N')) = nvl(arb.material, 'N')
	 AND ara.pk3 IN (SELECT DISTINCT process_id
				FROM   amw_execution_scope
				START WITH process_id = p_process_id
                AND entity_type = ara.object_type
                AND organization_id = p_org_id
				AND entity_id = p_certification_id
				CONNECT BY PRIOR process_id = parent_process_id
				AND organization_id = PRIOR organization_id
				AND entity_id = PRIOR entity_id
                AND entity_type = PRIOR entity_type
			       )
	 AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value = ara.pk2 --org_id
	 AND aov.pk4_value = ara.pk3 --process_id
	 AND aov.pk1_value = ara.risk_id
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1)
				  AND aov2.pk4_value = aov.pk4_value
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value)
	 AND aov.audit_result_code IS NOT NULL
	 );
l_eval_risks          NUMBER;
BEGIN
    l_eval_risks := 0;
	OPEN  get_eval_risks;
	FETCH get_eval_risks into l_eval_risks;
	CLOSE get_eval_risks;
    RETURN l_eval_risks;
END get_eval_risk_for_org_proc;

-- Get number of unmitigated risks given a certification, org and process within the certification
-- If fromDate and toDate are passed, then only evaluations created within that period are considered.
-- If material risks flag is passed, then only material risks are considered.
FUNCTION get_unmit_risk_for_org_proc
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE,
 p_material_risks_flag  in VARCHAR2)
RETURN NUMBER
IS
CURSOR get_unmitigated_risks
IS
SELECT count(1)
FROM 	(SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
	 FROM amw_risk_associations ara, amw_opinions_log_v aov, amw_risks_b arb
	 WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
	 AND ara.pk1 = p_certification_id
	 AND ara.pk2 = p_org_id
     AND ara.risk_rev_id = arb.risk_rev_id
     AND nvl(p_material_risks_flag, nvl(arb.material, 'N')) = nvl(arb.material, 'N')
	 AND ara.pk3 IN (SELECT DISTINCT process_id
				FROM   amw_execution_scope
				START WITH process_id = p_process_id
                AND entity_type = ara.object_type
                AND organization_id = p_org_id
				AND entity_id = p_certification_id
				CONNECT BY PRIOR process_id = parent_process_id
				AND organization_id = PRIOR organization_id
				AND entity_id = PRIOR entity_id
                AND entity_type = PRIOR entity_type
			       )
	 AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
	 AND aov.opinion_type_code = 'EVALUATION'
	 AND aov.pk3_value = ara.pk2 --org_id
	 AND aov.pk4_value = ara.pk3 --process_id
	 AND aov.pk1_value = ara.risk_id
	 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1)
				  AND aov2.pk4_value = aov.pk4_value
				  AND aov2.pk3_value = aov.pk3_value
				  AND aov2.pk1_value = aov.pk1_value)
     AND aov.audit_result_code <> 'EFFECTIVE'
	 );
l_unmit_risks          NUMBER;

BEGIN
    l_unmit_risks := 0;
	OPEN  get_unmitigated_risks;
	FETCH get_unmitigated_risks into l_unmit_risks;
	CLOSE get_unmitigated_risks;
    RETURN l_unmit_risks;
END get_unmit_risk_for_org_proc;


-- Get number of sub orgs associated to the given process within a given org.
FUNCTION get_total_org
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER)
RETURN NUMBER
IS
CURSOR get_total_org
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

CURSOR get_var_total_org
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

l_total_org     NUMBER;
l_var_total_org NUMBER;
BEGIN
    l_total_org := 0;
    l_var_total_org := 0;
	OPEN  get_total_org;
	FETCH get_total_org into l_total_org;
	CLOSE get_total_org;

	OPEN  get_var_total_org;
	FETCH get_var_total_org into l_var_total_org;
	CLOSE get_var_total_org;

    l_total_org := l_total_org + l_var_total_org;

    RETURN l_total_org;

END get_total_org;


-- Get number of sub orgs certified with issues that are associated to the given process and within a given org.
-- If fromDate and toDate are passed, then only evaluations created within that period are considered.
FUNCTION get_total_org_cert_issues
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE)
RETURN NUMBER
IS
CURSOR get_org_proc_cert_issues
IS
SELECT count(distinct pk3_value)
FROM   amw_opinions_log_v opinion
WHERE  opinion.pk2_value = p_certification_id
AND    opinion.pk1_value = p_process_id
AND    opinion.opinion_type_code = 'CERTIFICATION'
AND    opinion.object_name = 'AMW_ORG_PROCESS'
AND    opinion.audit_result_code <> 'EFFECTIVE'
AND    opinion.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = opinion.object_opinion_type_id
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1)
				  AND aov2.pk2_value = opinion.pk2_value
				  AND aov2.pk3_value = opinion.pk3_value
				  AND aov2.pk1_value = opinion.pk1_value)
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
      FROM  amw_opinions_log_v opinion,
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
      AND   opinion.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = opinion.object_opinion_type_id
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1)
				  AND aov2.pk2_value = opinion.pk2_value
				  AND aov2.pk3_value = opinion.pk3_value
				  AND aov2.pk1_value = opinion.pk1_value)
      AND   opinion.audit_result_code <> 'EFFECTIVE');
l_total_org     NUMBER;
l_var_total_org NUMBER;
BEGIN
    l_total_org := 0;
    l_var_total_org := 0;
	OPEN  get_org_proc_cert_issues;
	FETCH get_org_proc_cert_issues into l_total_org;
	CLOSE get_org_proc_cert_issues;

	OPEN  get_var_org_proc_cert_issues;
	FETCH get_var_org_proc_cert_issues into l_var_total_org;
	CLOSE get_var_org_proc_cert_issues;

    l_total_org := l_total_org + l_var_total_org;
    RETURN l_total_org;
END get_total_org_cert_issues;


-- Get number of sub orgs certified that are associated to the given process and within a given org.
-- If fromDate and toDate are passed, then only evaluations created within that period are considered.
FUNCTION get_total_org_cert
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE)
RETURN NUMBER
IS
CURSOR get_org_proc_certified
IS
SELECT count(distinct pk3_value)
FROM   amw_opinions_log_v opinion
WHERE  opinion.pk2_value = p_certification_id
AND    opinion.pk1_value = p_process_id
AND    opinion.opinion_type_code = 'CERTIFICATION'
AND    opinion.object_name = 'AMW_ORG_PROCESS'
AND    opinion.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = opinion.object_opinion_type_id
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1)
				  AND aov2.pk2_value = opinion.pk2_value
				  AND aov2.pk3_value = opinion.pk3_value
				  AND aov2.pk1_value = opinion.pk1_value)
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
      FROM  amw_opinions_log_v opinion,
            amw_execution_scope scp,
	    amw_process_organization procorg
      WHERE opinion.pk2_value = p_certification_id
      AND   opinion.pk1_value = scp.process_id
      AND   opinion.pk3_value = scp.organization_id
      AND   opinion.authored_date = (SELECT MAX(aov2.authored_date)
				  FROM amw_opinions_log aov2
				  WHERE aov2.object_opinion_type_id = opinion.object_opinion_type_id
                  AND aov2.authored_date >= nvl(p_from_date, sysdate-10000)
                  AND aov2.authored_date < nvl(p_to_date, sysdate+1)
				  AND aov2.pk2_value = opinion.pk2_value
				  AND aov2.pk3_value = opinion.pk3_value
				  AND aov2.pk1_value = opinion.pk1_value)
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
l_total_org     NUMBER;
l_var_total_org NUMBER;
BEGIN
    l_total_org := 0;
    l_var_total_org := 0;
	OPEN  get_org_proc_certified;
	FETCH get_org_proc_certified into l_total_org;
	CLOSE get_org_proc_certified;

	OPEN  get_var_org_proc_certified;
	FETCH get_var_org_proc_certified into l_var_total_org;
	CLOSE get_var_org_proc_certified;

    l_total_org := l_total_org + l_var_total_org;
    RETURN l_total_org;
END get_total_org_cert;

-- Get number of sub processes of a process
FUNCTION get_total_sub_process
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER)
RETURN NUMBER
IS
CURSOR get_all_sub_processes
IS
SELECT count(distinct process_id)
FROM   amw_execution_scope
START WITH parent_process_id = p_process_id
AND 	   organization_id   = p_org_id
AND 	   entity_id         = p_certification_id
AND        entity_type       = 'BUSIPROC_CERTIFICATION'
CONNECT BY PRIOR process_id     = parent_process_id
AND 		organization_id = PRIOR organization_id
AND 		entity_id       = PRIOR entity_id
AND 		entity_type       = PRIOR entity_type;
l_total_proc           NUMBER;
BEGIN
    l_total_proc := 0;
	OPEN  get_all_sub_processes;
	FETCH get_all_sub_processes into l_total_proc;
	CLOSE get_all_sub_processes;
    RETURN l_total_proc;
END get_total_sub_process;

FUNCTION get_cert_sub_process
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE)
RETURN NUMBER
IS
CURSOR get_cert_sub_process
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
AND        entity_type       = 'BUSIPROC_CERTIFICATION'
CONNECT BY PRIOR process_id     = parent_process_id
AND 		organization_id = PRIOR organization_id
AND 		entity_id       = PRIOR entity_id
AND 		entity_type       = PRIOR entity_type;
l_total_proc           NUMBER;
BEGIN
    l_total_proc := 0;
	OPEN  get_cert_sub_process;
	FETCH get_cert_sub_process into l_total_proc;
	CLOSE get_cert_sub_process;
    RETURN l_total_proc;
END get_cert_sub_process;

FUNCTION get_sub_process_cert_issues
(p_certification_id     in NUMBER,
 p_org_id               in NUMBER,
 p_process_id           in NUMBER,
 p_from_date            in DATE,
 p_to_date              in DATE)
RETURN NUMBER
IS
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
AND        entity_type       = 'BUSIPROC_CERTIFICATION'
CONNECT BY PRIOR process_id     = parent_process_id
AND 		organization_id = PRIOR organization_id
AND 		entity_id       = PRIOR entity_id
AND 		entity_type       = PRIOR entity_type;
l_total_proc           NUMBER;
BEGIN
    l_total_proc := 0;
	OPEN  get_sub_process_cert_issues;
	FETCH get_sub_process_cert_issues into l_total_proc;
	CLOSE get_sub_process_cert_issues;
    RETURN l_total_proc;
END get_sub_process_cert_issues;


END AMW_ORG_PROC_CERT_DATED_SUMM;

/
