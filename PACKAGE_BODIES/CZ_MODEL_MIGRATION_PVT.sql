--------------------------------------------------------
--  DDL for Package Body CZ_MODEL_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_MODEL_MIGRATION_PVT" AS
/* $Header: czmdlmgb.pls 120.19 2007/11/29 12:58:12 kdande ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'cz_model_migration_pvt';

BOM_ITEM_TYPE_MODEL    CONSTANT NUMBER := 1;
PS_NODE_TYPE_REFERENCE CONSTANT NUMBER := 263;

MODEL_TYPE_NORMAL    CONSTANT INTEGER := 0;
MODEL_TYPE_ABNORMAL  CONSTANT INTEGER := 1;
MODEL_TYPE_NAME_ERR  CONSTANT INTEGER := 2;

CP_RETCODE_SUCCESS   CONSTANT INTEGER := 0;
CP_RETCODE_WARNING   CONSTANT INTEGER := 1;
CP_RETCODE_FAILURE   CONSTANT INTEGER := 2;

m_commit_size        INTEGER;

TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
TYPE num_tbl_type_index_vc2 IS TABLE OF NUMBER INDEX BY VARCHAR2(15);

procedure log_msg(p_caller IN VARCHAR2
                 ,p_ndebug IN NUMBER
                 ,p_msg    IN VARCHAR2
                 ,p_level  IN NUMBER);

---------------------------------------------------------------------------------------

/*
 * Public API for Model Migration.
 * @param p_request_id This is the CZ_MODEL_PUBLICATIONS, MIGRATION_GROUP_ID of the migration request.
 *                     Migration request is created by Developer and contains the list of all models selected
 *                     for Migration from the source's Configurator Repository, target Instance name and
 *                     target Repository Folder.
 * @param p_userid     Standard parameters required for locking. Represent calling user.
 * @param p_respid     Standard parameters required for locking. Represent calling responsibility.
 * @param p_applid     Standard parameters required for locking. Represent calling application.
 * @param p_run_id     Number identifying the session. If left NULL, the API will generate the number and
 *                     return it in x_run_id.
 * @param x_run_id     Output parameter containing internally generated session identifier if p_run_id
 *                     was NULL, otherwise equal to p_run_id.
 */

PROCEDURE migrate_models(p_request_id  IN  NUMBER,
                         p_user_id     IN  NUMBER,
                         p_resp_id     IN  NUMBER,
                         p_appl_id     IN  NUMBER,
                         p_run_id      IN  NUMBER,
                         x_run_id      OUT NOCOPY NUMBER,
                         x_status      OUT NOCOPY VARCHAR2
                        ) IS

  l_api_name       CONSTANT VARCHAR2(30) := 'migrate_models';
  l_status         VARCHAR2(3);
  l_errbuf         VARCHAR2(4000);
  l_publication_id NUMBER;
BEGIN

  fnd_global.apps_initialize(p_user_id, p_resp_id, p_appl_id);
  x_run_id := p_run_id;

  IF(x_run_id IS NULL)THEN
    SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;
  END IF;

  x_status := FND_API.G_RET_STS_SUCCESS;

  FOR c_pub IN (SELECT publication_id FROM cz_model_publications
                 WHERE migration_group_id = p_request_id AND deleted_flag = '0')LOOP

    cz_pb_mgr.publish_model(c_pub.publication_id, x_run_id, l_status);

    IF l_status <> 'OK' THEN x_status := FND_API.G_RET_STS_ERROR; END IF;
  END LOOP;
EXCEPTION
    WHEN OTHERS THEN
         x_status := FND_API.G_RET_STS_ERROR;
         l_errbuf := SQLERRM;
         cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_UNEXPECTED);
END;
---------------------------------------------------------------------------------------
/*
 * Migrate Models concurrent procedure.
 * @param errbuf       Standard Oracle Concurrent Program output parameters.
 * @param retcode      Standard Oracle Concurrent Program output parameters.
 * @param p_request_id This is the CZ_MODEL_PUBLICATIONS, MIGRATION_GROUP_ID of the migration request.
 *                     Migration request is created by Developer and contains the list of all models selected
 *                     for Migration from the source's Configurator Repository, target Instance name and
 *                     target Repository Folder.
 */

PROCEDURE migrate_models_cp(errbuf       OUT NOCOPY VARCHAR2,
                            retcode      OUT NOCOPY NUMBER,
                            p_request_id IN  NUMBER
                           ) IS
  l_status         VARCHAR2(3);
  l_publication_id NUMBER;
  l_run_id         NUMBER := 0;
  l_mig_group_found BOOLEAN :=FALSE;
  l_api_name        CONSTANT VARCHAR2(30) := 'migrate_models_cp';
  l_ndebug          PLS_INTEGER:=1;

BEGIN

  retcode:=0;
  cz_pb_mgr.GLOBAL_EXPORT_RETCODE := 0;

  FOR c_pub IN (SELECT publication_id FROM cz_model_publications
                 WHERE migration_group_id = p_request_id AND deleted_flag = '0')LOOP

    l_mig_group_found :=TRUE;
    cz_pb_mgr.publish_model(c_pub.publication_id, l_run_id, l_status);

    errbuf := NULL;
    IF(cz_pb_mgr.GLOBAL_EXPORT_RETCODE = 1)THEN

      errbuf := CZ_UTILS.GET_TEXT('CZ_MM_WARNING');

    ELSIF(cz_pb_mgr.GLOBAL_EXPORT_RETCODE = 2) THEN

      errbuf := CZ_UTILS.GET_TEXT('CZ_MM_FAILURE');
    END IF;
  END LOOP;

  IF NOT l_mig_group_found THEN
     errbuf := cz_utils.get_text('CZ_INVALID_MIGR_GROUP_NUMBER', 'MIGRGRP', p_request_id);
     log_msg(l_api_name, l_ndebug, errbuf , FND_LOG.LEVEL_PROCEDURE);
     raise_application_error('-20020', 'INVALID_MIGRATION_GROUP');
  END IF;

  retcode := cz_pb_mgr.GLOBAL_EXPORT_RETCODE;

EXCEPTION
  WHEN OTHERS THEN
    retcode := 2;
    errbuf := CZ_UTILS.GET_TEXT('CZ_MM_UNEXPECTED');
END;
---------------------------------------------------------------------------------------
/*
 * Procedure for persistent id(s) allocation in migrated models.
 * @param p_model_id       devl_project_id of the model.
 * @param x_new_record_id  Candidate for the new id.
 */

PROCEDURE allocate_persistent_id(p_model_id      IN NUMBER,
                                 x_new_record_id IN OUT NOCOPY NUMBER
                                ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  UPDATE CZ_PERSISTENT_REC_IDS SET max_persistent_rec_id = max_persistent_rec_id + 1
  WHERE devl_project_id= (select devl_project_id from cz_devl_projects
		where deleted_flag = '0' and devl_project_id=p_model_id
     AND post_migr_change_flag <> 'L') and deleted_flag=0
  --If no record returned, the value of the variable will not change.
  RETURNING max_persistent_rec_id INTO x_new_record_id;
  COMMIT;
END;
--------------------------------------------------------------------------------
---------------------------  Configuration Upgrade  ----------------------------
--------------------------------------------------------------------------------
procedure log_msg(p_caller IN VARCHAR2
                 ,p_ndebug IN NUMBER
                 ,p_msg    IN VARCHAR2
                 ,p_level  IN NUMBER)
IS
BEGIN
  IF FND_GLOBAL.CONC_REQUEST_ID > 0 THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, p_msg);
  END IF;
  cz_utils.log_report(G_PKG_NAME, p_caller, p_ndebug, p_msg, p_level);
END log_msg;

--------------------------------------------------------------------------------
PROCEDURE get_commit_size_setting IS
BEGIN
  SELECT NVL(TO_NUMBER(value), 50000) INTO m_commit_size
  FROM cz_db_settings
  WHERE upper(SECTION_NAME) = 'SCHEMA' AND upper(SETTING_ID) = 'BATCHSIZE';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    m_commit_size := 50000;
END get_commit_size_setting;

--------------------------------------------------------------------------------

FUNCTION check_model(p_model_id IN NUMBER) RETURN NUMBER
IS
  l_model_type INTEGER;
BEGIN
  -- each node has name ?
  BEGIN
    SELECT MODEL_TYPE_NAME_ERR INTO l_model_type FROM cz_ps_nodes
    WHERE deleted_flag = '0' AND devl_project_id IN
       (SELECT component_id FROM cz_model_ref_expls
        WHERE deleted_flag = '0' AND model_id = p_model_id
        AND (ps_node_type = PS_NODE_TYPE_REFERENCE OR parent_expl_node_id IS NULL))
        AND name IS NULL AND rownum < 2;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_model_type := MODEL_TYPE_NORMAL;
  END;

  -- 1 pid maps exactly with 1 name ?
  IF l_model_type = MODEL_TYPE_NORMAL THEN
    FOR i IN (SELECT persistent_node_id, COUNT(distinct name)
              FROM cz_ps_nodes
              WHERE deleted_flag = '0' AND devl_project_id IN
                (SELECT component_id FROM cz_model_ref_expls
                 WHERE deleted_flag = '0' AND model_id = p_model_id
                 AND (ps_node_type = PS_NODE_TYPE_REFERENCE OR
                      parent_expl_node_id IS NULL))
              GROUP BY persistent_node_id
              HAVING COUNT(DISTINCT name) > 1)
    LOOP
      l_model_type := MODEL_TYPE_ABNORMAL;
      EXIT;
    END LOOP;
  END IF;

  RETURN l_model_type;
END check_model;

--------------------------------------------------------------------------------
-- to do: 1. collect upgraded hdrs, then check missed items using bulk bind?
--        2. check if child model already in map when building map?
PROCEDURE upgrade_configs_by_model(p_model_id   IN NUMBER
                                  ,p_begin_date IN DATE
                                  ,p_end_date   IN DATE
                                  ,x_retcode    OUT NOCOPY NUMBER
                          --        ,x_msg        OUT NOCOPY VARCHAR2
                                  )
IS
  l_api_name       CONSTANT VARCHAR2(30) := 'upgrade_configs_by_model';
  l_cmt_rec_count  PLS_INTEGER;
  l_ndebug         PLS_INTEGER;
  l_msg            VARCHAR2(1000);
  TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE name_tbl_type IS TABLE OF cz_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;
  TYPE name_tbl_type_idx_vc2 IS TABLE OF cz_ps_nodes.name%TYPE INDEX BY VARCHAR2(15);
  TYPE complex_num_tbl_type IS TABLE OF num_tbl_type_index_vc2 INDEX BY VARCHAR2(15);
  TYPE complex_name_tbl_type IS TABLE OF name_tbl_type_idx_vc2 INDEX BY VARCHAR2(15);

  l_hdr_tbl           num_tbl_type;
  l_rev_tbl           num_tbl_type;
  l_mdl_tbl           num_tbl_type;
  l_model_type_map    num_tbl_type_index_vc2;
  l_prj_pid_name_map  complex_name_tbl_type;
  l_ref_node_map      complex_num_tbl_type;

  l_model_id       NUMBER;
  l_model_type     INTEGER;
  l_model_name     cz_devl_projects.name%TYPE;
  l_item_prj_map   num_tbl_type_index_vc2;
  l_item_tbl       num_tbl_type;
  l_name_tbl       name_tbl_type;
  l_prj_id         NUMBER;

  l_upd_item_count   PLS_INTEGER;
  l_miss_item_count  PLS_INTEGER;
  l_fail_hdr_count   PLS_INTEGER;
  l_miss_item_tbl    num_tbl_type;
  l_no_miss_item     BOOLEAN;

  PROCEDURE create_maps(p_model_id  IN NUMBER)
  IS
  BEGIN
    FOR i IN (SELECT devl_project_id, persistent_node_id, name, ps_node_type, reference_id
              FROM cz_ps_nodes
              WHERE deleted_flag = '0' AND devl_project_id in
                 (SELECT component_id FROM cz_model_ref_expls
                  WHERE deleted_flag = '0' AND model_id = p_model_id
                  AND (ps_node_type = PS_NODE_TYPE_REFERENCE OR parent_expl_node_id IS NULL)))
    LOOP
      l_prj_pid_name_map(i.devl_project_id)(i.persistent_node_id) := i.name;
      IF i.ps_node_type = PS_NODE_TYPE_REFERENCE THEN
        l_ref_node_map(i.persistent_node_id)(i.devl_project_id) := i.reference_id;
      END IF;
    END LOOP;
  END create_maps;

BEGIN
  l_ndebug := 1;
  log_msg(l_api_name, l_ndebug, 'model_id=' || p_model_id, FND_LOG.LEVEL_PROCEDURE);

  SELECT config_hdr_id, config_rev_nbr, component_id
  BULK COLLECT INTO l_hdr_tbl, l_rev_tbl, l_mdl_tbl
  FROM cz_config_hdrs hdr
  WHERE deleted_flag = '0'
  AND creation_date >= NVL(p_begin_date, cz_utils.EPOCH_BEGIN_)
  AND creation_date <= NVL(p_end_date, SYSDATE)
  AND persistent_component_id = (SELECT persistent_project_id
                                 FROM cz_devl_projects
                                 WHERE devl_project_id = p_model_id)
  AND EXISTS (SELECT NULL FROM cz_config_items
              WHERE config_hdr_id = hdr.config_hdr_id
              AND config_rev_nbr = hdr.config_rev_nbr
              AND (parent_config_item_id IS NULL OR parent_config_item_id = -1)
              AND ps_node_name IS NULL);

  IF l_hdr_tbl.COUNT = 0 THEN
    SELECT name INTO l_model_name
    FROM cz_devl_projects
    WHERE devl_project_id = p_model_id;
    l_msg := cz_utils.get_text('CZ_UPGCFG_NO_CFG', 'MODELNAME', l_model_name);
    log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_STATEMENT);
    x_retcode := CP_RETCODE_SUCCESS;
    RETURN;
  ELSE
    l_msg := 'Number of configs found which need to be upgraded for model '
             || p_model_id|| ': ' || l_hdr_tbl.COUNT;
    log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_STATEMENT);
  END IF;

  l_ndebug := 2;
  l_cmt_rec_count := 0;
  l_fail_hdr_count := 0;
  l_no_miss_item := TRUE;
  FOR i IN l_hdr_tbl.FIRST .. l_hdr_tbl.LAST LOOP
    -- Use the config src model if the model and all its referred models still exist
    -- Use the common model otherwise
    l_model_id := p_model_id;
    BEGIN
      SELECT devl_project_id INTO l_model_id
      FROM cz_devl_projects
      WHERE devl_project_id = l_mdl_tbl(i) AND deleted_flag = '0';

      SELECT p_model_id INTO l_model_id
      FROM cz_model_ref_expls re
      WHERE deleted_flag = '0' AND model_id = l_mdl_tbl(i)
      AND ps_node_type = PS_NODE_TYPE_REFERENCE
      AND NOT EXISTS (SELECT 1 FROM cz_devl_projects
                      WHERE deleted_flag = '0' AND devl_project_id = re.component_id)
      AND ROWNUM < 2;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    l_ndebug := 3;
    IF l_model_type_map.EXISTS(l_model_id) THEN
      l_model_type := l_model_type_map(l_model_id);
    ELSE
      l_model_type := check_model(l_model_id);
      IF l_model_type = MODEL_TYPE_ABNORMAL THEN
        create_maps(l_model_id);
      ELSIF l_model_type = MODEL_TYPE_NAME_ERR THEN
        -- should never happen, otherwise need an fnd msg
        l_msg := 'Model ' || l_model_id || ' cannot be used in config upgrade ' ||
                 'because some nodes have no name';
        log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_ERROR);
      END IF;
      l_model_type_map(l_model_id) := l_model_type;
    END IF;

    -- print_maps(l_prj_pid_name_map, l_ref_node_map, l_model_type_map);
    IF l_model_type <> MODEL_TYPE_NAME_ERR THEN
      l_msg := 'Processing config (' || l_hdr_tbl(i) || ',' || l_rev_tbl(i) ||
               ') vs. type ' || l_model_type || ' model ' || l_model_id;
      log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_STATEMENT);
    END IF;

    l_miss_item_tbl.DELETE;
    IF l_model_type = MODEL_TYPE_NORMAL THEN
      l_ndebug := 4;
      UPDATE cz_config_items item
      SET ps_node_name =
         (SELECT name FROM cz_ps_nodes psn
          WHERE deleted_flag = '0' AND persistent_node_id = item.ps_node_id
            AND EXISTS (SELECT 1 FROM cz_model_ref_expls
                        WHERE deleted_flag = '0' AND model_id = l_model_id
                        AND (ps_node_type = PS_NODE_TYPE_REFERENCE OR parent_expl_node_id IS NULL)
                        AND component_id = psn.devl_project_id)
            AND rownum < 2)
      WHERE config_hdr_id = l_hdr_tbl(i) AND config_rev_nbr = l_rev_tbl(i);
      l_cmt_rec_count := l_cmt_rec_count + SQL%ROWCOUNT;

      SELECT config_item_id BULK COLLECT INTO l_miss_item_tbl
      FROM cz_config_items
      WHERE config_hdr_id = l_hdr_tbl(i) AND config_rev_nbr = l_rev_tbl(i)
      AND deleted_flag = '0' AND ps_node_name IS NULL;

    ELSIF l_model_type = MODEL_TYPE_ABNORMAL THEN
      l_ndebug := 5;
      l_upd_item_count  := 0;
      l_miss_item_count := 0;
      l_item_tbl.DELETE;
      l_name_tbl.DELETE;
      l_item_prj_map.DELETE;
      FOR j IN (SELECT config_item_id, ps_node_id, parent_config_item_id
                FROM cz_config_items
                WHERE deleted_flag = '0'
                START WITH (parent_config_item_id IS NULL OR parent_config_item_id = -1)
                   AND config_hdr_id = l_hdr_tbl(i) AND config_rev_nbr = l_rev_tbl(i)
                CONNECT BY PRIOR config_item_id = parent_config_item_id
                   AND config_hdr_id = l_hdr_tbl(i) AND config_rev_nbr = l_rev_tbl(i)
                   AND deleted_flag = '0')
      LOOP
        IF j.parent_config_item_id IS NULL OR j.parent_config_item_id = -1 THEN
          l_prj_id := l_model_id;
        ELSE
          l_prj_id := l_item_prj_map(j.parent_config_item_id);
        END IF;

        IF l_prj_pid_name_map.EXISTS(l_prj_id) AND l_prj_pid_name_map(l_prj_id).EXISTS(j.ps_node_id) THEN
          l_upd_item_count := l_upd_item_count + 1;
          l_item_tbl(l_upd_item_count) := j.config_item_id;
          l_name_tbl(l_upd_item_count) := l_prj_pid_name_map(l_prj_id)(j.ps_node_id);
        ELSE
          l_miss_item_count := l_miss_item_count + 1;
          l_miss_item_tbl(l_miss_item_count) := j.config_item_id;
        END IF;

        IF l_ref_node_map.EXISTS(j.ps_node_id) AND l_ref_node_map(j.ps_node_id).EXISTS(l_prj_id) THEN
          l_item_prj_map(j.config_item_id) := l_ref_node_map(j.ps_node_id)(l_prj_id);
        ELSE
          l_item_prj_map(j.config_item_id) := l_prj_id;
        END IF;
      END LOOP;

      -- print_maps(l_item_prj_map, l_item_tbl, l_name_tbl, l_miss_item_tbl);
      l_ndebug := 6;
      FORALL j IN l_item_tbl.FIRST .. l_item_tbl.LAST
        UPDATE cz_config_items
        SET ps_node_name = l_name_tbl(j)
        WHERE config_hdr_id = l_hdr_tbl(i) AND config_rev_nbr = l_rev_tbl(i)
        AND config_item_id = l_item_tbl(j);

      l_cmt_rec_count := l_cmt_rec_count + l_upd_item_count;

    ELSE
      -- ? try to use p_model_id if l_model_id <> p_model_id
      l_ndebug := 7;
      l_fail_hdr_count := l_fail_hdr_count + 1;
    END IF;

    l_ndebug := 8;
    IF l_cmt_rec_count >= m_commit_size THEN
      COMMIT;
      l_cmt_rec_count := 0;
    END IF;

    IF l_miss_item_tbl.COUNT > 0 THEN
      l_no_miss_item := FALSE;
      FOR j IN l_miss_item_tbl.FIRST ..l_miss_item_tbl.LAST LOOP
        l_msg := cz_utils.get_text('CZ_UPGCFG_ITEM_NO_NODE', 'ID', to_char(l_miss_item_tbl(j)),
                 'HDR', to_char(l_hdr_tbl(i)), 'REV', to_char(l_rev_tbl(i)));
        log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_STATEMENT);
      END LOOP;
    END IF;

    IF l_model_type = MODEL_TYPE_NAME_ERR THEN
      l_msg := 'config (' || l_hdr_tbl(i) || ',' || l_rev_tbl(i) || ') not upgraded';
    ELSE
      l_msg := 'config (' || l_hdr_tbl(i) || ',' || l_rev_tbl(i) || ') upgraded';
    END IF;
    log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_STATEMENT);
  END LOOP;

  l_ndebug := 10;
  IF l_cmt_rec_count > 0 THEN
    COMMIT;
  END IF;

  IF l_fail_hdr_count = 0 AND l_no_miss_item THEN
    x_retcode := CP_RETCODE_SUCCESS;
    -- x_msg := 'All configs with model ' || p_model_id || ' upgraded';
  ELSIF l_fail_hdr_count = l_hdr_tbl.COUNT THEN
    x_retcode := CP_RETCODE_FAILURE;
    -- x_msg := 'All configs with model ' || p_model_id || ' failed in upgrade';
  ELSE
    x_retcode := CP_RETCODE_WARNING;
    -- x_msg := 'Not all configs with model ' || p_model_id || ' upgraded: ' ||
    --          'some configs either not processed at all or just partially upgraded';
  END IF;
  -- log_msg(l_api_name, l_ndebug, x_msg, FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  WHEN OTHERS THEN
    x_retcode := CP_RETCODE_FAILURE;
    l_msg := 'Fatal error in ' || l_api_name || '.' || l_ndebug || ': ' ||
              substr(SQLERRM,1,900);
    log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_UNEXPECTED);
END upgrade_configs_by_model;
--------------------------------------------------------------------------------

PROCEDURE upgrade_configs_by_item(p_organization_id   IN NUMBER
                                 ,p_inventory_item_id IN NUMBER
                                 ,p_application_id    IN NUMBER
                                 ,p_begin_date        IN DATE
                                 ,p_end_date          IN DATE
                                 ,x_retcode   OUT NOCOPY NUMBER
                           --      ,x_msg       OUT NOCOPY VARCHAR2
                                 )
IS
  l_api_name  CONSTANT VARCHAR2(30) := 'upgrade_configs_by_item';
  l_model_id  cz_devl_projects.devl_project_id%TYPE;
  l_ndebug    INTEGER;
  l_msg       VARCHAR2(1000);
  l_msg_name  VARCHAR2(30);
BEGIN
  l_ndebug := 1;
  l_msg := 'BEGIN: org=' || p_organization_id || ', inv item=' || p_inventory_item_id;
  log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_PROCEDURE);
  l_model_id := cz_cf_api.config_model_for_item(p_inventory_item_id,
                     p_organization_id, SYSDATE, p_application_id, NULL);
  IF l_model_id IS NULL THEN
    x_retcode := CP_RETCODE_FAILURE;
    l_msg := cz_utils.get_text('CZ_UPGCFG_NO_PUB_ITEM', 'ITEM', to_char(p_inventory_item_id),
                               'ORG', to_char(p_organization_id));
    log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_ERROR);
    RETURN;
  END IF;

  l_ndebug := 2;
  IF check_model(l_model_id) = MODEL_TYPE_NAME_ERR THEN
    -- should never happen, otherwise need an fnd msg
    x_retcode := CP_RETCODE_FAILURE;
    l_msg := 'Not all nodes in the published model ' || l_model_id || ' have names';
  ELSE
    l_ndebug := 3;
    upgrade_configs_by_model(l_model_id
                            ,p_begin_date
                            ,p_end_date
                            ,x_retcode
                    --        ,x_msg
                            );
  END IF;
  IF x_retcode = CP_RETCODE_SUCCESS THEN
    l_msg_name := 'CZ_UPGCFG_ITEM_SUCC';
  ELSIF x_retcode = CP_RETCODE_WARNING THEN
    l_msg_name := 'CZ_UPGCFG_ITEM_WARN';
  ELSE
    l_msg_name := 'CZ_UPGCFG_ITEM_FAIL';
  END IF;
  l_msg := cz_utils.get_text(l_msg_name, 'ITEM', to_char(p_inventory_item_id),
           'ORG', to_char(p_organization_id));
  log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  WHEN OTHERS THEN
    x_retcode := CP_RETCODE_FAILURE;
    l_msg := 'Fatal error in ' || l_api_name || '.' || l_ndebug || ': ' ||
              substr(SQLERRM,1,900);
    log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_UNEXPECTED);
END upgrade_configs_by_item;
--------------------------------------------------------------------------------

/*
 * Concurrent procedure for Configuration Upgrade by Item(s).
 * @param errbuf              Standard Oracle Concurrent Program output parameters.
 * @param retcode             Standard Oracle Concurrent Program output parameters.
 * @param p_organization_id   Used to search configurations by organization ID, required.
 * @param p_top_inv_item_from Used to search configurations by top item, optional
 * @param p_top_inv_item_to   Used to search configurations by top item, optional
 * @param p_application_id    Used to refine search for equivalent published
 *                            models to use as baselines for upgrade, optional.
 * @param p_config_begin_date Optional, if present, indicates the date of the oldest
 *                            configuration to be updated.
 * @param p_config_end_date   Optional, if present, indicates the date of the newest
 *                            configuration to be updated.
 */

PROCEDURE upgrade_configs_by_items_cp
       (errbuf              OUT NOCOPY VARCHAR2
       ,retcode             OUT NOCOPY NUMBER
       ,p_organization_code IN VARCHAR2
       ,p_organization_id   IN NUMBER
       ,p_top_inv_item_from IN VARCHAR2
       ,p_top_inv_item_to   IN VARCHAR2
       ,p_application_id    IN NUMBER
       ,p_config_begin_date IN VARCHAR2
       ,p_config_end_date   IN VARCHAR2
       )
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'upgrade_configs_by_items';
  l_item_tbl      num_tbl_type;
  l_org_tbl       num_tbl_type;
  l_org_id        NUMBER;
  l_one_org       BOOLEAN;
  l_begin_date    DATE;
  l_end_date      DATE;
  l_num_invitem   INTEGER;
  l_num_success   PLS_INTEGER;
  l_num_warning   PLS_INTEGER;
  l_num_failure   PLS_INTEGER;
  l_ndebug        PLS_INTEGER;
  l_retcode       NUMBER;
  l_msg           VARCHAR2(1000);

BEGIN
  l_ndebug := 1;
  l_msg := 'BEGIN: org=' || nvl(to_char(p_organization_id), 'null') || ',' ||
           'from_item=' || nvl(p_top_inv_item_from, 'null') || ',' ||
           'to_item=' || nvl(p_top_inv_item_to, 'null') || ',' ||
           'application=' || nvl(to_char(p_application_id), 'null') || ',' ||
           'begin_date=' || nvl(p_config_begin_date, 'null') || ',' ||
           'end_date=' || nvl(p_config_end_date, 'null');
  log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_PROCEDURE);

  l_num_success := 0;
  l_num_warning := 0;
  l_num_failure := 0;

  l_begin_date := fnd_date.canonical_to_date(p_config_begin_date);
  l_end_date   := fnd_date.canonical_to_date(p_config_end_date);

  l_ndebug := 2;
  IF p_organization_id IS NULL THEN
    l_one_org := FALSE;
    SELECT DISTINCT top_item_id, organization_id
    BULK COLLECT INTO l_item_tbl, l_org_tbl
    FROM cz_model_publications
    WHERE deleted_flag = '0' AND object_type = 'PRJ'
    AND   source_target_flag = 'T' AND export_status = 'OK'
    AND   top_item_id IS NOT NULL AND organization_id IS NOT NULL;
  ELSE
    l_one_org := TRUE;
    IF p_top_inv_item_from IS NULL AND p_top_inv_item_to IS NULL THEN
      SELECT DISTINCT top_item_id BULK COLLECT INTO l_item_tbl
      FROM cz_model_publications
      WHERE deleted_flag = '0' AND object_type = 'PRJ'
      AND   source_target_flag = 'T' AND export_status = 'OK'
      AND   organization_id = p_organization_id;
    ELSE
      SELECT inventory_item_id BULK COLLECT INTO l_item_tbl
      FROM mtl_system_items_vl item
      WHERE organization_id = p_organization_id
      AND concatenated_segments BETWEEN NVL(p_top_inv_item_from, p_top_inv_item_to)
                                    AND NVL(p_top_inv_item_to, p_top_inv_item_from)
      AND bom_item_type = BOM_ITEM_TYPE_MODEL
      AND exists (SELECT NULL FROM cz_model_publications
                  WHERE deleted_flag = '0' AND object_type = 'PRJ'
                  AND   source_target_flag = 'T' AND export_status = 'OK'
                  AND   top_item_id = item.inventory_item_id
                  AND   organization_id = p_organization_id);
    END IF;
  END IF;

  l_num_invitem := l_item_tbl.COUNT;
  log_msg(l_api_name, l_ndebug, 'Number of items: ' || l_num_invitem, FND_LOG.LEVEL_ERROR);
  IF l_num_invitem = 0 THEN
    retcode := CP_RETCODE_SUCCESS;
    RETURN;
  END IF;

  l_ndebug := 3;
  l_org_id := p_organization_id;
  get_commit_size_setting;
  FOR i IN l_item_tbl.FIRST .. l_item_tbl.LAST LOOP
    IF NOT l_one_org THEN
      l_org_id := l_org_tbl(i);
    END IF;
    upgrade_configs_by_item(l_org_id
                           ,l_item_tbl(i)
                           ,p_application_id
                           ,l_begin_date
                           ,l_end_date
                           ,l_retcode
                     --      ,l_msg
                           );
    l_ndebug := l_ndebug + 1;
    IF l_retcode = CP_RETCODE_SUCCESS THEN
      l_num_success := l_num_success + 1;
    ELSIF l_retcode = CP_RETCODE_WARNING THEN
      l_num_warning := l_num_warning + 1;
    ELSE
      l_num_failure := l_num_failure + 1;
    END IF;
  END LOOP;

  IF l_num_success = l_num_invitem THEN
    retcode := CP_RETCODE_SUCCESS;
  ELSIF l_num_failure = l_num_invitem THEN
    retcode := CP_RETCODE_FAILURE;
  ELSE
     retcode := CP_RETCODE_WARNING;
  END IF;
  l_msg := cz_utils.get_text('CZ_UPGCFG_ITEMS', 'NSUCC', to_char(l_num_success),
          'NWARN', to_char(l_num_warning), 'NFAIL', to_char(l_num_failure));
  -- log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_ERROR);
  errbuf := l_msg;
EXCEPTION
  WHEN OTHERS THEN
    retcode := CP_RETCODE_FAILURE;
    errbuf := 'Fatal error in ' || l_api_name || '.' || l_ndebug || ': ' ||
               substr(SQLERRM,1,900);
END upgrade_configs_by_items_cp;

---------------------------------------------------------------------------------------
/*
 * Concurrent procedure for Configuration Upgrade by Product key.
 * @param errbuf              Standard Oracle Concurrent Program output parameters.
 * @param retcode             Standard Oracle Concurrent Program output parameters.
 * @param p_product_key       Used to search configurations, required.
 * @param p_application_id    Used to refine search for equivalent published models
 *                            to use as baselines for upgrade, optional.
 * @param p_config_begin_date Optional, if present, indicates the date of the oldest
 *                            configuration to be updated.
 * @param p_config_end_date   Optional, if present, indicates the date of the newest
 *                            configuration to be updated.
 */

PROCEDURE upgrade_configs_by_product_cp
       (errbuf               OUT NOCOPY VARCHAR2
       ,retcode              OUT NOCOPY NUMBER
       ,p_product_key        IN VARCHAR2
       ,p_application_id     IN NUMBER
       ,p_config_begin_date  IN VARCHAR2
       ,p_config_end_date    IN VARCHAR2
       )
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'upgrade_configs_by_product';
  l_begin_date  DATE;
  l_end_date    DATE;
  l_model_id    cz_devl_projects.devl_project_id%TYPE;
  l_ndebug      INTEGER;
  l_msg         VARCHAR2(1000);
  l_msg_name    VARCHAR2(30);
  v_publication_id NUMBER;
BEGIN
  l_ndebug := 1;
  l_msg := 'BEGIN: product_key=' || p_product_key || ',' ||
           'application=' || nvl(to_char(p_application_id), 'null') || ',' ||
           'begin_date=' || nvl(p_config_begin_date, 'null') || ',' ||
           'end_date=' || nvl(p_config_end_date, 'null');
  log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_PROCEDURE);

  l_begin_date := fnd_date.canonical_to_date(p_config_begin_date);
  l_end_date   := fnd_date.canonical_to_date(p_config_end_date);

  get_commit_size_setting;

  l_ndebug := 2;
  l_model_id := cz_cf_api.config_model_for_product(p_product_key,SYSDATE,p_application_id,NULL);
  IF l_model_id IS NULL THEN
    errbuf := cz_utils.get_text('CZ_UPGCFG_NO_PUB_PRD', 'PRD', p_product_key);
    retcode := CP_RETCODE_FAILURE;
    log_msg(l_api_name, l_ndebug, errbuf, FND_LOG.LEVEL_ERROR);
    RETURN;
  ELSE
    -- Bug 5496507; 14-Sep-2006; kdande; See if the model derived from publication is migrated and error out if it is, else proceed with upgrade.
    DECLARE
      -- Check if the model is a migrated one
      CURSOR cur_model_migrated IS
        SELECT 'Y' migrated
        FROM   cz_devl_projects dp
        WHERE  dp.devl_project_id = l_model_id
        AND    dp.post_migr_change_flag IS NOT NULL
        AND    dp.post_migr_change_flag <> 'L';
      rec_model_migrated cur_model_migrated%ROWTYPE;
    BEGIN
      OPEN cur_model_migrated;
      FETCH cur_model_migrated INTO rec_model_migrated;
      IF (cur_model_migrated%FOUND) THEN
        CLOSE cur_model_migrated;
        v_publication_id := cz_cf_api.publication_for_product (
                              product_key => p_product_key,
                              config_lookup_date => SYSDATE,
                              calling_application_id => p_application_id,
                              usage_name => NULL,
                              publication_mode => NULL,
                              language => NULL
                            );
        errbuf := cz_utils.get_text ('CZ_UPGCFG_WRONG_PUB4PRODKEY', 'PUBID1', v_publication_id, 'PUBID2', v_publication_id);
        retcode := CP_RETCODE_FAILURE;
        log_msg (l_api_name, l_ndebug, errbuf, FND_LOG.LEVEL_ERROR);
        RETURN;
      ELSE
        CLOSE cur_model_migrated;
      END IF;
    END;
    -- End of fix for bug 5496507
  END IF;

  l_ndebug := 3;
  IF check_model(l_model_id) = MODEL_TYPE_NAME_ERR THEN
    errbuf := 'Not all model nodes in model ' || l_model_id || ' have names';
    retcode := CP_RETCODE_FAILURE;
  ELSE
    l_ndebug := 4;
    upgrade_configs_by_model(l_model_id
                            ,l_begin_date
                            ,l_end_date
                            ,retcode
                            -- ,errbuf
                            );
  END IF;
  IF retcode = CP_RETCODE_SUCCESS THEN
    l_msg_name := 'CZ_UPGCFG_PROD_SUCC';
  ELSIF retcode = CP_RETCODE_WARNING THEN
    l_msg_name := 'CZ_UPGCFG_PROD_WARN';
  ELSE
    l_msg_name := 'CZ_UPGCFG_PROD_FAIL';
  END IF;
  errbuf := cz_utils.get_text(l_msg_name, 'PRD', p_product_key);
  -- l_msg := 'retcode=' || retcode || ',msg=' || errbuf;
  -- log_msg(l_api_name, l_ndebug, l_msg, FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  WHEN OTHERS THEN
    retcode := CP_RETCODE_FAILURE;
    errbuf := 'Fatal error in ' || l_api_name || '.' || l_ndebug || ': ' ||
               substr(SQLERRM,1,900);
END upgrade_configs_by_product_cp;

---------------------------------------------------------------------------------------
---------------------------  End of Configuration Upgrade  ----------------------------
---------------------------------------------------------------------------------------

/*
 * This procedure converts a publication target to a Development Instance.
 * @param errbuf       Standard Oracle Concurrent Program output parameters.
 * @param retcode      Standard Oracle Concurrent Program output parameters.
 */

PROCEDURE convert_instance_cp(errbuf       OUT NOCOPY VARCHAR2,
                              retcode      OUT NOCOPY NUMBER
                             ) IS

ALREADY_MIGRATED_EXCEPTION EXCEPTION;

l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);

p_run_id    NUMBER;
l_return BOOLEAN;

l_new_pb_id      t_num_array_tbl_type;
l_old_pb_id      t_num_array_tbl_type;

l_inst_str	    VARCHAR2(8000);
l_converted_target_flag VARCHAR2(1) ;

v_errorString		VARCHAR2(1024) :='convert_instance: ';

BEGIN

  --get the current value for converted flag
  SELECT converted_target_flag
  INTO l_converted_target_flag
  FROM cz_servers
  WHERE local_name = 'LOCAL';

  IF l_converted_target_flag = '1' THEN
    RAISE ALREADY_MIGRATED_EXCEPTION;
  END IF;

  --update the target server flag
  update cz_servers
  set converted_target_flag = '1' where
  LOCAL_NAME = 'LOCAL';

  --update the source server flag
  --this will ensure that this server will be presented as a
  --migration target my target_open_for function.
  update cz_servers
  set source_server_flag = '0' where
  source_server_flag = '1';
   --create a pseudo record for all the target publications
  SELECT cz_model_publications_s.NEXTVAL, publication_id
  BULK COLLECT
  INTO l_new_pb_id, l_old_pb_id
  FROM cz_model_publications
  WHERE SOURCE_TARGET_FLAG = 'T'
  AND cz_model_publications.deleted_flag = '0';

  l_inst_str:= 'INSERT INTO cz_model_publications ' ||
'     (PUBLICATION_ID ' ||
'     ,MODEL_ID ' ||
'     ,OBJECT_ID ' ||
'     ,OBJECT_TYPE ' ||
'     ,SERVER_ID ' ||
'     ,ORGANIZATION_ID ' ||
'     ,TOP_ITEM_ID ' ||
'     ,PRODUCT_KEY ' ||
'     ,PUBLICATION_MODE ' ||
'     ,UI_DEF_ID ' ||
'     ,UI_STYLE ' ||
'     ,APPLICABLE_FROM ' ||
'     ,APPLICABLE_UNTIL ' ||
'     ,EXPORT_STATUS ' ||
'     ,MODEL_PERSISTENT_ID ' ||
'     ,DELETED_FLAG ' ||
'     ,MODEL_LAST_STRUCT_UPDATE ' ||
'     ,MODEL_LAST_LOGIC_UPDATE ' ||
'     ,MODEL_LAST_UPDATED ' ||
'     ,SOURCE_TARGET_FLAG ' ||
'     ,REMOTE_PUBLICATION_ID ' ||
'     ,CONTAINER ' ||
'     ,PAGE_LAYOUT ' ||
'     ,disabled_flag ' ||
'     ,converted_target_flag ' ||
'     ) ' ||
'  SELECT :1 ' ||
'     ,MODEL_ID ' ||
'     ,OBJECT_ID ' ||
'     ,OBJECT_TYPE ' ||
'     ,SERVER_ID ' ||
'     ,ORGANIZATION_ID ' ||
'     ,TOP_ITEM_ID ' ||
'     ,PRODUCT_KEY ' ||
'     ,PUBLICATION_MODE ' ||
'     ,UI_DEF_ID ' ||
'     ,UI_STYLE ' ||
'     ,APPLICABLE_FROM ' ||
'     ,APPLICABLE_UNTIL ' ||
'     ,EXPORT_STATUS ' ||
'     ,MODEL_PERSISTENT_ID ' ||
'     ,DELETED_FLAG ' ||
'     ,MODEL_LAST_STRUCT_UPDATE ' ||
'     ,MODEL_LAST_LOGIC_UPDATE ' ||
'     ,MODEL_LAST_UPDATED ' ||
'     ,''S'' ' ||
'     ,PUBLICATION_ID ' ||
'     ,CONTAINER ' ||
'     ,PAGE_LAYOUT ' ||
'     ,disabled_flag ' ||
'     ,''1'' ' ||
'   FROM  cz_model_publications ' ||
'  WHERE publication_id = :2 ';

  --insert the pseudo record
  FORALL i IN 1..l_new_pb_id.COUNT
    EXECUTE IMMEDIATE l_inst_str USING l_new_pb_id(i), l_old_pb_id(i);

  COMMIT;

EXCEPTION
WHEN ALREADY_MIGRATED_EXCEPTION THEN
  retcode:=2;
  errbuf:=CZ_UTILS.Get_Text('CZ_ALREADY_CONVERTED_MESSAGE');
  l_return := cz_utils.log_report(Msg        => errbuf,
                                  Urgency    => 1,
                                  ByCaller   => 'CZ_MODEL_MIGRATION',
                                  StatusCode => 11276,
                                  RunId      => p_run_id);
WHEN OTHERS THEN
   rollback;
   retcode:=2;
   errbuf:=SQLERRM;
   l_return := cz_utils.log_report(Msg       => errbuf,
                                  Urgency    => 1,
                                  ByCaller   => 'CZ_MODEL_MIGRATION',
                                  StatusCode => 11276,
                                  RunId      => p_run_id);
END;
---------------------------------------------------------------------------------------
/*
* Once the target has been converted to a development instance,
* obselete all the source publications to that target.
*/

PROCEDURE obsolete_nonpublishable(
                       p_commit_flag       IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count     OUT NOCOPY NUMBER,
                	   x_msg_data      OUT NOCOPY VARCHAR2
                       )
IS
l_server_id NUMBER ;
r_instance_name_tbl t_varchar40_array_tbl_type;
obselete_exists VARCHAR2(1) := '0';
r_instance_name VARCHAR2(40);



BEGIN


FND_MSG_PUB.initialize;
x_return_status := FND_API.G_RET_STS_SUCCESS;

--get the instance name(s) that has been converted
r_instance_name_tbl := get_target_name_if_converted();


--we need to display a message in Developer
--if there are obseleted records.
--for each of the instances that have converted, check if there
--are obseleted records
IF ( r_instance_name_tbl.COUNT > 0) THEN

    FOR i IN r_instance_name_tbl.FIRST..r_instance_name_tbl.LAST LOOP
        r_instance_name := r_instance_name_tbl(i);

        IF (r_instance_name IS NULL) THEN
            RETURN;
        END IF;

        --get the local server id of the instance name
        SELECT server_local_id
           INTO l_server_id
           FROM cz_servers
           WHERE UPPER (local_name) = UPPER (r_instance_name);


        obselete_exists := '0';

        -- check if obselete exists
        BEGIN

         SELECT '1'
            INTO obselete_exists
            FROM DUAL
            WHERE EXISTS (
              SELECT publication_id
                FROM cz_model_publications
                WHERE source_target_flag = 'S'
                  AND deleted_flag = '0'
                  AND export_status <> MODEL_PUBLICATION_OBSELETE
                  AND server_id = l_server_id);

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             obselete_exists := '0';
        END;

        --if obselete exists

        IF (obselete_exists = '1') THEN

            x_return_status := FND_API.G_RET_STS_ERROR;

            --add message to the error stack
            CZ_UTILS.add_error_message_to_stack(p_message_name   => 'CZ_OBSELETE_RECORDS_EXISTS',
                         p_token_name1    => 'INSTANCE_NAME',
                         p_token_value1   => r_instance_name,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data);


           --update all publications for local server id
            UPDATE cz_model_publications
              set export_status = MODEL_PUBLICATION_OBSELETE
              WHERE SOURCE_TARGET_FLAG = 'S'
              AND deleted_flag = '0'
              AND export_status <> MODEL_PUBLICATION_OBSELETE
              AND server_id = l_server_id;

        END IF;

    END LOOP;

END IF;

IF (p_commit_flag = FND_API.G_TRUE) THEN
    COMMIT;
END IF;

EXCEPTION
WHEN others THEN
    CZ_UTILS.add_exc_msg_to_fndstack(
                 p_package_name => 'CZ_MODEL_MIGRATION',
                 p_procedure_name => 'obselete_nonpublishable',
                 p_error_message  => SQLERRM);


END;
---------------------------------------------------------------------------------------
/* The target machine may have been convrted into
 * a Developer enabled, migratable machine.
 * If so, the target is publishable no more.

 * This method will also be called from Developer
 * when a drop down of eligible targets is loaded
 * at the time of creating or editing a publication
 */

FUNCTION target_open_for (
   p_migration_or_publishing   IN   VARCHAR2,
   p_link_name                 IN   VARCHAR2,
   p_local_name                IN   VARCHAR2
)  RETURN VARCHAR2
IS
   target_open            VARCHAR2 (1)    := '1';
   target_not_open        VARCHAR2 (1)    := '0';
   l_source_server_flag           VARCHAR2 (1);
   l_source_server_flag_for_pub   VARCHAR2 (1);
   l_sql_str              VARCHAR2 (2000);
   l_sql_str_for_pub      VARCHAR2 (2000);
   target_instance_for_pub VARCHAR2(2000);
   local_instance_name VARCHAR2(2000);

BEGIN

   IF (p_migration_or_publishing = MODE_PUBLICATION) THEN
       IF (p_local_name='LOCAL') THEN
         RETURN target_open;
       END IF;
   END IF;

   IF p_link_name IS NULL THEN
      RETURN target_not_open;
   END IF;

   l_sql_str :=
         'SELECT NVL(source_server_flag,''0''), local_name FROM cz_servers@' || p_link_name || ' ' ||
         'WHERE source_server_flag = ''1'' ';

   EXECUTE IMMEDIATE l_sql_str
                INTO l_source_server_flag, target_instance_for_pub;


   IF (p_migration_or_publishing = MODE_PUBLICATION) THEN

      SELECT instance_name
       INTO local_instance_name
      FROM cz_servers
       WHERE local_name = 'LOCAL';

       IF (local_instance_name=target_instance_for_pub) THEN
         RETURN target_open;
       END IF;
   END IF;

   RETURN target_not_open;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN target_open;
   WHEN OTHERS THEN
      RETURN target_not_open;
END;
---------------------------------------------------------------------------------------
/*
 * For a given link name, get the converted target name.
 * The target machine may have been convrted into
 * a Developer enabled, migratable machine.
 * This method will get the converted target instance name
 */

FUNCTION get_converted_target(p_link_name  IN VARCHAR2, p_instance_name IN VARCHAR2) RETURN VARCHAR2
is


l_instance_name VARCHAR(40);
r_converted_target_flag VARCHAR(1);
r_instance_name VARCHAR(40);

TYPE ref_cursor IS REF CURSOR;
gl_ref_cursor	      ref_cursor;

BEGIN

--get the local name in the source server,
--we will look for this instance in the remote target to check
--if publication is still allowed.

IF p_link_name IS NULL then
    RETURN NULL;
END IF;

-- check if publishable, this query will using the link on the remote machine
OPEN gl_ref_cursor FOR 'SELECT converted_target_flag
            		   	FROM   cz_servers@'||p_link_name || ' where converted_target_flag = ''1''
                        and local_name = ''LOCAL'' ';
LOOP
  FETCH gl_ref_cursor INTO r_converted_target_flag;
    IF (r_converted_target_flag = TARGET_SERVER_PUBLISH_NOTALLOW) THEN
        CLOSE gl_ref_cursor ;
        RETURN p_instance_name;
        EXIT;
    END if;
   	EXIT WHEN gl_ref_cursor%NOTFOUND;
 END LOOP;
CLOSE gl_ref_cursor ;

RETURN NULL;

-- there may be exceptions where the remote link may not
-- be available, the target may be at a different schema level
-- just return the converted_target_flag as being allowed to
-- publish in this case

EXCEPTION
WHEN OTHERS THEN
RETURN r_converted_target_flag;

END;
---------------------------------------------------------------------------------------

/* The target machine may have been convrted into
 * a Developer enabled, migratable machine.
 * If so, the target is publishable no more
 */

FUNCTION get_target_name_if_converted RETURN t_varchar40_array_tbl_type
is

l_instance_name_tbl t_varchar40_array_tbl_type;
l_link_name_tbl t_varchar40_array_tbl_type ;

r_converted_target VARCHAR2(40);
r_converted_target_tbl t_varchar40_array_tbl_type;
r_converted_target_count PLS_INTEGER :=1;

TYPE ref_cursor IS REF CURSOR;
gl_ref_cursor	      ref_cursor;

BEGIN

-- collect the link name of the publishing target
SELECT fndnam_link_name, instance_name
  BULK COLLECT
  INTO l_link_name_tbl, l_instance_name_tbl
  FROM cz_servers
  WHERE local_name <> 'LOCAL' AND FNDNAM_LINK_NAME IS NOT NULL ;

-- for each of the link_names collected, check if the
-- remote target is still publishable

FOR i IN l_link_name_tbl.FIRST..l_link_name_tbl.LAST LOOP
    r_converted_target := get_converted_target(l_link_name_tbl(i), l_instance_name_tbl(i));
    IF (r_converted_target IS NOT NULL) THEN
        r_converted_target_tbl(r_converted_target_count) :=  r_converted_target;
        r_converted_target_count := r_converted_target_count + 1;
    END IF;
END LOOP;

RETURN r_converted_target_tbl;

END;
---------------------------------------------------------------------------------------
END;

/
