--------------------------------------------------------
--  DDL for Package Body AMW_ORG_CERT_AGGR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_ORG_CERT_AGGR_PKG" AS
/* $Header: amwocagb.pls 120.0 2005/09/30 15:54:43 appldev noship $ */

G_PKG_NAME    CONSTANT VARCHAR2 (30) := 'AMW_ORG_CERT_AGGR_PKG';
G_FILE_NAME   CONSTANT VARCHAR2 (15) := 'amwocagb.pls';


--
-- Private procedures
--

PROCEDURE recursive_populate_hier
(
	p_certification_id	IN	NUMBER,
	p_child_id		IN	NUMBER
)
IS
  l_parent_id	NUMBER;

  CURSOR row_exists_check(c_parent_id	NUMBER) IS
  SELECT 1
  FROM amw_full_entity_hier
  WHERE entity_type = 'BUSIPROC_CERTIFICATION'
  AND entity_id = p_certification_id
  AND object_type = 'SUBSIDIARY'
  AND object_id = p_child_id
  AND parent_object_type = 'SUBSIDIARY'
  AND parent_object_id = c_parent_id;

  l_dummy	NUMBER;
BEGIN
  IF p_child_id = -1 THEN
    RETURN;
  END IF;

  -- Get the parent_id and insert a row in the table if appropriate
  SELECT nvl(flv2.flex_value_id, -1) parent_id
  INTO l_parent_id
  FROM fnd_flex_values flv,
       fnd_flex_value_children_v fchild,
       fnd_flex_values flv2
  WHERE fchild.flex_value (+)= flv.flex_value
  AND   fchild.flex_value_set_id (+)= flv.flex_value_set_id
  AND   flv2.flex_value (+)= fchild.parent_flex_value
  AND   flv2.flex_value_set_id (+)= fchild.flex_value_set_id
  AND   flv.flex_value_id = p_child_id;

  OPEN row_exists_check(l_parent_id);
  FETCH row_exists_check INTO l_dummy;

  IF row_exists_check%NOTFOUND THEN
    CLOSE row_exists_check;

    INSERT INTO amw_full_entity_hier
    (entity_hierarchy_id, entity_type, entity_id, object_type, object_id,
     parent_object_type, parent_object_id, level_id, creation_date,
     created_by, last_update_date, last_updated_by, last_update_login,
     object_version_number, delete_flag)
    VALUES(amw_full_entity_hier_s.nextval, 'BUSIPROC_CERTIFICATION',
           p_certification_id, 'SUBSIDIARY', p_child_id, 'SUBSIDIARY',
           l_parent_id, 1, sysdate, fnd_global.user_id, sysdate,
           fnd_global.user_id, fnd_global.login_id, 1, 'N');

    recursive_populate_hier(p_certification_id, l_parent_id);
  ELSE
    CLOSE row_exists_check;
  END IF;

END recursive_populate_hier;


PROCEDURE recurse_aggregate
(
	p_certification_id	IN	NUMBER,
	p_subsidiary_id		IN	NUMBER
)
IS
  l_parent_id			NUMBER;

BEGIN
  IF p_subsidiary_id = -1 THEN
    RETURN;
  END IF;

  MERGE INTO amw_org_cert_aggr_sum sum_tab
  USING
  (SELECT nvl(SUM(nvl(SUB_ORG_CERT,0)),0) SUB_ORG_CERT,
          nvl(SUM(nvl(TOTAL_SUB_ORG,0)),0) TOTAL_SUB_ORG,
          nvl(SUM(nvl(PROCESSES_CERTIFIED,0)),0) PROCESSES_CERTIFIED,
          nvl(SUM(nvl(TOTAL_PROCESSES,0)),0) TOTAL_PROCESSES,
          nvl(SUM(nvl(EVALUATED_PROCESSES,0)),0) EVALUATED_PROCESSES,
          nvl(SUM(nvl(INEFF_PROCESSES,0)),0) INEFF_PROCESSES,
          nvl(SUM(nvl(UNMITIGATED_RISKS,0)),0) UNMITIGATED_RISKS,
          nvl(SUM(nvl(EVALUATED_RISKS,0)),0) EVALUATED_RISKS,
          nvl(SUM(nvl(TOTAL_RISKS,0)),0) TOTAL_RISKS,
          nvl(SUM(nvl(INEFFECTIVE_CONTROLS,0)),0) INEFFECTIVE_CONTROLS,
          nvl(SUM(nvl(EVALUATED_CONTROLS,0)),0) EVALUATED_CONTROLS,
          nvl(SUM(nvl(TOTAL_CONTROLS,0)),0) TOTAL_CONTROLS,
          nvl(SUM(nvl(OPEN_FINDINGS,0)),0) OPEN_FINDINGS,
          nvl(SUM(nvl(OPEN_ISSUES,0)),0) OPEN_ISSUES,
          nvl(SUM(nvl(TOP_ORG_PROCESSES,0)),0) TOP_ORG_PROCESSES,
          nvl(SUM(nvl(TOP_ORG_PROC_PENDING_CERT,0)),0) TOP_ORG_PROC_PENDING_CERT,
          nvl(SUM(nvl(SUB_ORG_CERT_ISSUES,0)),0) SUB_ORG_CERT_ISSUES,
          nvl(SUM(nvl(PROC_CERT_ISSUES,0)),0) PROC_CERT_ISSUES
   FROM (SELECT SUB_ORG_CERT,
                TOTAL_SUB_ORG,
                PROCESSES_CERTIFIED,
                TOTAL_PROCESSES,
                EVALUATED_PROCESSES,
                INEFF_PROCESSES,
                UNMITIGATED_RISKS,
                EVALUATED_RISKS,
                TOTAL_RISKS,
                INEFFECTIVE_CONTROLS,
                EVALUATED_CONTROLS,
                TOTAL_CONTROLS,
                OPEN_FINDINGS,
                OPEN_ISSUES,
                TOP_ORG_PROCESSES,
                TOP_ORG_PROC_PENDING_CERT,
                SUB_ORG_CERT_ISSUES,
                PROC_CERT_ISSUES
         FROM fnd_flex_values flv,
              fnd_flex_value_children_v fchild,
              fnd_flex_values flv_c,
              amw_org_cert_aggr_sum ocas
         WHERE flv.flex_value_id = p_subsidiary_id
         AND   fchild.flex_value_set_id = flv.flex_value_set_id
         AND   fchild.parent_flex_value = flv.flex_value
         AND   flv_c.flex_value_set_id = flv.flex_value_set_id
         AND   flv_c.flex_value = fchild.flex_value
         AND   ocas.certification_id = p_certification_id
         AND   ocas.object_type = 'SUBSIDIARY'
         AND   ocas.object_id = flv_c.flex_value_id
         UNION ALL
         SELECT SUB_ORG_CERT,
                TOTAL_SUB_ORG,
                PROCESSES_CERTIFIED,
                TOTAL_PROCESSES,
                EVALUATED_PROCESSES,
                INEFF_PROCESSES,
                UNMITIGATED_RISKS,
                EVALUATED_RISKS,
                TOTAL_RISKS,
                INEFFECTIVE_CONTROLS,
                EVALUATED_CONTROLS,
                TOTAL_CONTROLS,
                OPEN_FINDINGS,
                OPEN_ISSUES,
                TOP_ORG_PROCESSES,
                TOP_ORG_PROC_PENDING_CERT,
                SUB_ORG_CERT_ISSUES,
                PROC_CERT_ISSUES
         FROM fnd_flex_values flv,
              hr_organization_information oi,
              amw_org_cert_eval_sum oces
         WHERE flv.flex_value_id = p_subsidiary_id
         AND   oi.org_information_context = 'AMW_AUDIT_UNIT'
         AND   oi.org_information1 = flv.flex_value
         AND   oi.org_information3 = flv.flex_value_set_id
         AND   oces.certification_id = p_certification_id
         AND   oces.organization_id = oi.organization_id) child_info) sum_query
  ON (sum_tab.certification_id = p_certification_id AND
      sum_tab.object_type = 'SUBSIDIARY' AND
      sum_tab.object_id = p_subsidiary_id)
  WHEN MATCHED THEN
    UPDATE SET SUB_ORG_CERT = sum_query.SUB_ORG_CERT,
               TOTAL_SUB_ORG = sum_query.TOTAL_SUB_ORG,
               PROCESSES_CERTIFIED = sum_query.PROCESSES_CERTIFIED,
               TOTAL_PROCESSES = sum_query.TOTAL_PROCESSES,
               EVALUATED_PROCESSES = sum_query.EVALUATED_PROCESSES,
               INEFF_PROCESSES = sum_query.INEFF_PROCESSES,
               UNMITIGATED_RISKS = sum_query.UNMITIGATED_RISKS,
               EVALUATED_RISKS = sum_query.EVALUATED_RISKS,
               TOTAL_RISKS = sum_query.TOTAL_RISKS,
               INEFFECTIVE_CONTROLS = sum_query.INEFFECTIVE_CONTROLS,
               EVALUATED_CONTROLS = sum_query.EVALUATED_CONTROLS,
               TOTAL_CONTROLS = sum_query.TOTAL_CONTROLS,
               OPEN_FINDINGS = sum_query.OPEN_FINDINGS,
               OPEN_ISSUES = sum_query.OPEN_ISSUES,
               TOP_ORG_PROCESSES = sum_query.TOP_ORG_PROCESSES,
               TOP_ORG_PROC_PENDING_CERT = sum_query.TOP_ORG_PROC_PENDING_CERT,
               SUB_ORG_CERT_ISSUES = sum_query.SUB_ORG_CERT_ISSUES,
               PROC_CERT_ISSUES = sum_query.PROC_CERT_ISSUES,
               INEFF_PROCESSES_PRCNT =
                 decode(sum_query.total_processes,
                        0, 0,
                        trunc(100 * sum_query.ineff_processes /
                              sum_query.total_processes)),
               UNMITIGATED_RISKS_PRCNT =
                 decode(sum_query.total_risks,
                        0, 0,
                        trunc(100 * sum_query.unmitigated_risks /
                              sum_query.total_risks)),
               INEFF_CONTROLS_PRCNT =
                 decode(sum_query.total_controls,
                        0, 0,
                        trunc(100 * sum_query.ineffective_controls /
                              sum_query.total_controls)),
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.login_id
  WHEN NOT MATCHED THEN
    INSERT
    (cert_org_aggr_sum_id,
     certification_id,
     object_type,
     object_id,
     sub_org_cert,
     total_sub_org,
     processes_certified,
     total_processes,
     evaluated_processes,
     ineff_processes,
     unmitigated_risks,
     evaluated_risks,
     total_risks,
     ineffective_controls,
     evaluated_controls,
     total_controls,
     open_findings,
     open_issues,
     top_org_processes,
     top_org_proc_pending_cert,
     created_by,
     creation_date,
     last_updated_by,
     last_update_date,
     last_update_login,
     object_version_number,
     sub_org_cert_issues,
     proc_cert_issues,
     ineff_processes_prcnt,
     unmitigated_risks_prcnt,
     ineff_controls_prcnt
    )
    VALUES
    (amw_org_cert_aggr_sum_s.nextval,
     p_certification_id,
     'SUBSIDIARY',
     p_subsidiary_id,
     sum_query.sub_org_cert,
     sum_query.total_sub_org,
     sum_query.processes_certified,
     sum_query.total_processes,
     sum_query.evaluated_processes,
     sum_query.ineff_processes,
     sum_query.unmitigated_risks,
     sum_query.evaluated_risks,
     sum_query.total_risks,
     sum_query.ineffective_controls,
     sum_query.evaluated_controls,
     sum_query.total_controls,
     sum_query.open_findings,
     sum_query.open_issues,
     sum_query.top_org_processes,
     sum_query.top_org_proc_pending_cert,
     fnd_global.user_id,
     sysdate,
     fnd_global.user_id,
     sysdate,
     fnd_global.login_id,
     1,
     sum_query.sub_org_cert_issues,
     sum_query.proc_cert_issues,
     decode(sum_query.total_processes,
            0, 0,
            trunc(100 * sum_query.ineff_processes /
                  sum_query.total_processes)),
     decode(sum_query.total_risks,
            0, 0,
            trunc(100 * sum_query.unmitigated_risks /
                  sum_query.total_risks)),
     decode(sum_query.total_controls,
            0, 0,
            trunc(100 * sum_query.ineffective_controls /
                  sum_query.total_controls)));

  -- Get the parent_id and recurse up the hierarchy
  SELECT nvl(flv2.flex_value_id, -1) parent_id
  INTO l_parent_id
  FROM fnd_flex_values flv,
       fnd_flex_value_children_v fchild,
       fnd_flex_values flv2
  WHERE fchild.flex_value (+)= flv.flex_value
  AND   fchild.flex_value_set_id (+)= flv.flex_value_set_id
  AND   flv2.flex_value (+)= fchild.parent_flex_value
  AND   flv2.flex_value_set_id (+)= fchild.flex_value_set_id
  AND   flv.flex_value_id = p_subsidiary_id;

  recurse_aggregate(p_certification_id, l_parent_id);

END recurse_aggregate;

--
-- Public procedures
--

PROCEDURE populate_full_hierarchies
(
	x_errbuf 		    OUT      NOCOPY VARCHAR2,
	x_retcode		    OUT      NOCOPY NUMBER,
	p_certification_id     	    IN       NUMBER
)
IS
  l_api_name           CONSTANT VARCHAR2(30) := 'populate_full_hierarchies';

  -- select all bottom-level subsidiaries in scope for the certification
  CURSOR get_all_subs IS
  SELECT DISTINCT fv.flex_value_id
  FROM amw_execution_scope es,
       fnd_flex_values fv
  WHERE es.entity_type = 'BUSIPROC_CERTIFICATION'
  AND   es.entity_id = p_certification_id
  AND   es.level_id = 3
  AND   fv.flex_value_set_id = es.subsidiary_vs
  AND   fv.flex_value = es.subsidiary_code
  AND   fv.flex_value_set_id = fnd_profile.value('AMW_SUBSIDIARY_AUDIT_UNIT');

BEGIN
	fnd_file.put_line(fnd_file.LOG, 'begin '||g_pkg_name||'.'||l_api_name||': '||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

	fnd_file.put_line(fnd_file.LOG, 'Certification_Id:'||p_certification_id);

	-- First clear out the hierarchy
	DELETE FROM amw_full_entity_hier
        WHERE entity_id = p_certification_id;

	-- Loop through the flex values and create the hierarchy
	FOR sub_info IN get_all_subs LOOP
	  recursive_populate_hier(p_certification_id, sub_info.flex_value_id);
	END LOOP;

	populate_org_cert_aggr_rows(p_certification_id);

	fnd_file.put_line(fnd_file.LOG, 'end '||g_pkg_name||'.'||l_api_name||': '||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

EXCEPTION
  WHEN OTHERS THEN
	fnd_file.put_line(fnd_file.LOG, 'error '||g_pkg_name||'.'||l_api_name||': '||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
	RAISE;
END populate_full_hierarchies;


PROCEDURE populate_org_cert_aggr_rows
(
	p_certification_id 	IN 	NUMBER
)
IS
  l_api_name           CONSTANT VARCHAR2(30) := 'populate_org_cert_aggr_rows';

  -- select all bottom-level subsidiaries in scope for the certification
  CURSOR get_all_subs IS
  SELECT DISTINCT fv.flex_value_id
  FROM amw_execution_scope es,
       fnd_flex_values fv
  WHERE es.entity_type = 'BUSIPROC_CERTIFICATION'
  AND   es.entity_id = p_certification_id
  AND   es.level_id = 3
  AND   fv.flex_value_set_id = es.subsidiary_vs
  AND   fv.flex_value = es.subsidiary_code
  AND   fv.flex_value_set_id = fnd_profile.value('AMW_SUBSIDIARY_AUDIT_UNIT');

BEGIN
	fnd_file.put_line(fnd_file.LOG, 'begin '||g_pkg_name||'.'||l_api_name||': '||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

	SAVEPOINT populate_org_cert_aggr_rows;

	-- First clear out the existing data
	DELETE FROM amw_org_cert_aggr_sum
	WHERE certification_id = p_certification_id;

	-- Loop through the flex values and populate the aggregation info
	FOR sub_info IN get_all_subs LOOP
	  recurse_aggregate(p_certification_id, sub_info.flex_value_id);
	END LOOP;

	fnd_file.put_line(fnd_file.LOG, 'end '||g_pkg_name||'.'||l_api_name||': '||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

EXCEPTION
  WHEN OTHERS THEN
	ROLLBACK TO populate_org_cert_aggr_rows;
	fnd_file.put_line(fnd_file.LOG, 'error '||g_pkg_name||'.'||l_api_name||': '||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
	RAISE;
END populate_org_cert_aggr_rows;


PROCEDURE update_org_cert_aggr_rows
(
	p_certification_id	IN	NUMBER,
	p_organization_id	IN	NUMBER
)
IS
  l_api_name           CONSTANT VARCHAR2(30) := 'update_org_cert_aggr_rows';

  l_flex_value_id      NUMBER;
BEGIN
	fnd_file.put_line(fnd_file.LOG, 'begin '||g_pkg_name||'.'||l_api_name||': '||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

	SAVEPOINT update_org_cert_aggr_rows;

	SELECT to_number(org_information1)
	INTO l_flex_value_id
	FROM hr_organization_information
	WHERE organization_id = p_organization_id
	AND org_information_context = 'AMW_AUDIT_UNIT'
	AND org_information3 = fnd_profile.value('AMW_SUBSIDIARY_AUDIT_UNIT');

	recurse_aggregate(p_certification_id, l_flex_value_id);


	fnd_file.put_line(fnd_file.LOG, 'end '||g_pkg_name||'.'||l_api_name||': '||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));

EXCEPTION
  WHEN OTHERS THEN
	ROLLBACK TO update_org_cert_aggr_rows;
	fnd_file.put_line(fnd_file.LOG, 'error '||g_pkg_name||'.'||l_api_name||': '||to_char(sysdate, 'hh:mi:ss dd-mon-rrrr'));
	RAISE;
END update_org_cert_aggr_rows;


END AMW_ORG_CERT_AGGR_PKG;

/
