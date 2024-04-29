--------------------------------------------------------
--  DDL for Package Body CZ_MODELOPERATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_MODELOPERATIONS_PUB" AS
/*  $Header: czmodopb.pls 120.4.12010000.2 2008/09/12 10:00:51 jonatara ship $   */
------------------------------------------------------------------------------------------

G_INCOMPATIBLE_API   EXCEPTION;
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'ModelOperationsPub';
-----------------------------------------------------
PROCEDURE generate_logic(p_api_version     IN  NUMBER,
                         p_devl_project_id IN  NUMBER,
                         x_run_id          OUT NOCOPY NUMBER,
                         x_status          OUT NOCOPY NUMBER) IS
l_api_name      CONSTANT VARCHAR2(30) := 'generate_logic';
l_api_version   CONSTANT NUMBER := 1.0;
l_urgency       NUMBER;
l_found         NUMBER;
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(10000);
l_errbuf        VARCHAR2(2000);
NOT_VALID_PROJECT_ID    EXCEPTION;

BEGIN
  SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  BEGIN
    SELECT 1
    INTO l_found
    FROM cz_rp_entries
    WHERE object_type = 'PRJ' AND object_id = p_devl_project_id AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NOT_VALID_PROJECT_ID;
  END;

  CZ_LOGIC_GEN.GENERATE_LOGIC(p_devl_project_id, x_run_id);

  SELECT MIN(urgency)
    INTO l_urgency
  FROM cz_db_logs
  WHERE run_id = x_run_id;

  IF l_urgency = 0 THEN
    x_status := G_STATUS_ERROR;
  ELSIF l_urgency = 1 THEN
    x_status := G_STATUS_WARNING;
  ELSIF l_urgency IS NULL THEN
    x_status := G_STATUS_SUCCESS;
    x_run_id := 0;
  END IF;

EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN NOT_VALID_PROJECT_ID THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_DEV_PRJ_ID_ERR', 'PROJID', p_devl_project_id);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN OTHERS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := SQLERRM;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_UNEXPECTED);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
END generate_logic;
------------------------------------------------------------------------------------------------
PROCEDURE generate_logic(p_api_version     IN  NUMBER,
                         p_devl_project_id IN  NUMBER,
                         p_user_id         IN NUMBER,
                         p_resp_id         IN NUMBER,
                         p_appl_id         IN NUMBER,
                         x_run_id          OUT NOCOPY NUMBER,
                         x_status          OUT NOCOPY NUMBER) IS

BEGIN
 fnd_global.apps_initialize(p_user_id,p_resp_id,p_appl_id);
 generate_logic(p_api_version,p_devl_project_id,x_run_id,x_status);
END generate_logic;
--------------------------------------
PROCEDURE create_ui(p_api_version      IN  NUMBER,
                    p_devl_project_id  IN  NUMBER,
                    x_ui_def_id        OUT NOCOPY NUMBER,
                    x_run_id           OUT NOCOPY NUMBER,
                    x_status           OUT NOCOPY NUMBER,
                    p_ui_style         IN  VARCHAR2 , -- DEFAULT 'COMPONENTS',
                    p_frame_allocation IN  NUMBER   , -- DEFAULT 30,
                    p_width            IN  NUMBER   , -- DEFAULT 640,
                    p_height           IN  NUMBER   , -- DEFAULT 480,
                    p_show_all_nodes   IN  VARCHAR2 , -- DEFAULT '0',
                    p_look_and_feel    IN  VARCHAR2 , -- DEFAULT 'BLAF',
                    p_wizard_style     IN  VARCHAR2 , -- DEFAULT '0',
                    p_max_bom_per_page IN  NUMBER   , -- DEFAULT 10,
                    p_use_labels       IN  VARCHAR2   -- DEFAULT '1'
                   ) IS
l_api_name      CONSTANT VARCHAR2(30) := 'create_ui';
l_api_version   CONSTANT NUMBER := 1.0;
l_errbuf        VARCHAR2(2000);
l_found         NUMBER;
NOT_VALID_PROJECT_ID    EXCEPTION;
WRONG_UI_STYLE          EXCEPTION;
WRONG_FRAME_ALLCN       EXCEPTION;
WRONG_WIDTH             EXCEPTION;
WRONG_HEIGHT            EXCEPTION;
WRONG_SHOW_NODES        EXCEPTION;
WRONG_USE_LABELS        EXCEPTION;
WRONG_LOOK_AND_FEEL     EXCEPTION;
WRONG_MAX_BOM           EXCEPTION;
WRONG_WIZARD_STYLE      EXCEPTION;

BEGIN
  SAVEPOINT create_ui_PUB;

  SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  BEGIN
    SELECT 1
    INTO l_found
    FROM cz_rp_entries
    WHERE object_type = 'PRJ' AND object_id = p_devl_project_id AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NOT_VALID_PROJECT_ID;
  END;

  IF p_ui_style NOT IN ('0','3','COMPONENTS','APPLET') THEN
    RAISE WRONG_UI_STYLE;
  END IF;

  IF p_frame_allocation < 0 OR p_frame_allocation > 50 THEN
    RAISE WRONG_FRAME_ALLCN;
  END IF;

  IF p_width < 0 OR p_width > 1600 THEN
    RAISE WRONG_WIDTH;
  END IF;

  IF p_height < 0 OR p_height > 1200 THEN
    RAISE WRONG_HEIGHT;
  END IF;

  IF p_show_all_nodes NOT IN (0,1) THEN
    RAISE WRONG_SHOW_NODES;
  END IF;

  IF p_use_labels NOT IN (0,1,2) THEN
    RAISE WRONG_USE_LABELS;
  END IF;

  IF p_use_labels NOT IN (0,1,2) THEN
    RAISE WRONG_USE_LABELS;
  END IF;

  IF p_look_and_feel NOT IN ('BLAF','FORMS','APPLET') THEN
    RAISE WRONG_LOOK_AND_FEEL;
  END IF;

  IF p_use_labels < 1 THEN
    RAISE WRONG_MAX_BOM;
  END IF;

  IF p_wizard_style NOT IN (0,1) THEN
    RAISE WRONG_WIZARD_STYLE;
  END IF;

  CZ_UI_GENERATOR.createUI(p_devl_project_id, x_ui_def_id, x_run_id, p_ui_style, p_frame_allocation, p_width,
                           p_height, p_show_all_nodes, p_use_labels, p_look_and_feel, p_max_bom_per_page, p_wizard_style);
  IF x_run_id = 0 THEN
    x_status := G_STATUS_SUCCESS;
    COMMIT WORK;
  ELSE
    x_status := G_STATUS_ERROR;
    ROLLBACK TO create_ui_PUB;
  END IF;

EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN NOT_VALID_PROJECT_ID THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_DEV_PRJ_ID_ERR', 'PROJID', p_devl_project_id);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN WRONG_UI_STYLE THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_UI_STYLE_ERR');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN WRONG_FRAME_ALLCN THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_FRAME_ALLCN_ERR');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN WRONG_WIDTH THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_WIDTH_ERR');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN WRONG_HEIGHT THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_HEIGHT_ERR');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN WRONG_SHOW_NODES THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_SHOW_ALL_NODES_ERR');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN WRONG_USE_LABELS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_USE_LABELS_ERR');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN WRONG_LOOK_AND_FEEL THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_LOOK_AND_FEEL_ERR');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN WRONG_MAX_BOM THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_MAX_BOM_PER_PAGE_ERR');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN WRONG_WIZARD_STYLE THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_WIZARD_STYLE_ERR');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN OTHERS THEN
         x_status := G_STATUS_ERROR;
         ROLLBACK TO create_ui_PUB;
         l_errbuf := SQLERRM;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_UNEXPECTED);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
END create_ui;

------------------------------------------------------------------------------------------------
PROCEDURE create_ui(p_api_version      IN  NUMBER,
                    p_devl_project_id  IN  NUMBER,
                    p_user_id          IN NUMBER,
                    p_resp_id          IN NUMBER,
                    p_appl_id          IN NUMBER,
                    x_ui_def_id        OUT NOCOPY NUMBER,
                    x_run_id           OUT NOCOPY NUMBER,
                    x_status           OUT NOCOPY NUMBER,
                    p_ui_style         IN  VARCHAR2 , -- DEFAULT 'COMPONENTS',
                    p_frame_allocation IN  NUMBER   , -- DEFAULT 30,
                    p_width            IN  NUMBER   , -- DEFAULT 640,
                    p_height           IN  NUMBER   , -- DEFAULT 480,
                    p_show_all_nodes   IN  VARCHAR2 , -- DEFAULT '0',
                    p_look_and_feel    IN  VARCHAR2 , -- DEFAULT 'BLAF',
                    p_wizard_style     IN  VARCHAR2 , -- DEFAULT '0',
                    p_max_bom_per_page IN  NUMBER   , -- DEFAULT 10,
                    p_use_labels       IN  VARCHAR2   -- DEFAULT '1'
          ) IS
BEGIN
   fnd_global.apps_initialize(p_user_id,p_resp_id,p_appl_id);
   create_ui(p_api_version,
           p_devl_project_id,
           x_ui_def_id,
           x_run_id,
           x_status,
           p_ui_style,
           p_frame_allocation,
           p_width,
           p_height,
           p_show_all_nodes,
           p_look_and_feel,
           p_wizard_style,
           p_max_bom_per_page,
           p_use_labels
           );
END create_ui;

--------------------------------------------------------

/* generate JRAD style UI
 *   Parameters :
 *      p_api_version         -- identifies version of API
 *      p_devl_project_id     -- identifies Model for which UI will be generated
 *      p_show_all_nodes      -- '1' - ignore ps node property "DO NOT SHOW IN UI"
 *      p_master_template_id  -- identifies UI Master Template
 *      p_create_empty_ui     -- '1' - create empty UI ( which contains only one record in CZ_UI_DEFS )
 *      x_ui_def_id           -- ui_def_id of UI that has been generated
 *      x_return_status       -- status string
 *      x_msg_count           -- number of error messages
 *      x_msg_data            -- string which contains error messages
 */
PROCEDURE create_jrad_ui(p_api_version        IN  NUMBER,
                         p_devl_project_id    IN  NUMBER,
                         p_show_all_nodes     IN  VARCHAR2,
                         p_master_template_id IN  NUMBER,
                         p_create_empty_ui    IN  VARCHAR2,
                         x_ui_def_id          OUT NOCOPY NUMBER,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_msg_count          OUT NOCOPY NUMBER,
                         x_msg_data           OUT NOCOPY VARCHAR2) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'create_jrad_ui';
  l_api_version   CONSTANT NUMBER := 1.0;
  l_errbuf        VARCHAR2(2000);
  l_found         NUMBER;
  NOT_VALID_PROJECT_ID    EXCEPTION;
  WRONG_SHOW_NODES        EXCEPTION;

BEGIN
  SAVEPOINT create_ui_PUB;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  BEGIN
    SELECT 1
    INTO l_found
    FROM cz_rp_entries
    WHERE object_type = 'PRJ' AND object_id = p_devl_project_id AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NOT_VALID_PROJECT_ID;
  END;

  IF p_show_all_nodes NOT IN ('0','1') THEN
    RAISE WRONG_SHOW_NODES;
  END IF;

  CZ_UIOA_PVT.create_UI
    (
     p_model_id           => p_devl_project_id,
     p_master_template_id => p_master_template_id,
     p_show_all_nodes     => p_show_all_nodes,
     p_create_empty_ui    => p_create_empty_ui,
     x_ui_def_id          => x_ui_def_id,
     x_return_status      => x_return_status,
     x_msg_count          => x_msg_count,
     x_msg_data           => x_msg_data
    );

  IF x_msg_count = 0 THEN
    COMMIT WORK;
  ELSE
    ROLLBACK TO create_ui_PUB;
  END IF;

EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('CZ', 'CZ_MOP_API_VERSION_ERR');
         FND_MESSAGE.SET_TOKEN('CODE_VERSION', l_api_version);
         FND_MESSAGE.SET_TOKEN('IN_VERSION', p_api_version);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

    WHEN NOT_VALID_PROJECT_ID THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('CZ', 'CZ_MOP_DEV_PRJ_ID_ERR');
         FND_MESSAGE.SET_TOKEN('PROJID', p_devl_project_id);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);
    WHEN WRONG_SHOW_NODES THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_SHOW_ALL_NODES_ERR');


         FND_MESSAGE.SET_NAME('CZ', 'CZ_MOP_SHOW_ALL_NODES_ERR');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         ROLLBACK TO create_ui_PUB;
         l_errbuf := SQLERRM;
END create_jrad_ui;

------------------------------------------------------------------------------------------------
PROCEDURE create_jrad_ui(p_api_version        IN  NUMBER,
                         p_user_id            IN  NUMBER,
                         p_resp_id            IN  NUMBER,
                         p_appl_id            IN  NUMBER,
                         p_devl_project_id    IN  NUMBER,
                         p_show_all_nodes     IN  VARCHAR2,
                         p_master_template_id IN  NUMBER,
                         p_create_empty_ui    IN  VARCHAR2,
                         x_ui_def_id          OUT NOCOPY NUMBER,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_msg_count          OUT NOCOPY NUMBER,
                         x_msg_data           OUT NOCOPY VARCHAR2) IS

BEGIN
    fnd_global.apps_initialize(p_user_id,p_resp_id,p_appl_id);
    create_jrad_ui(p_api_version        => p_api_version,
                   p_devl_project_id    => p_devl_project_id,
                   p_show_all_nodes     => p_show_all_nodes,
                   p_master_template_id => p_master_template_id,
                   p_create_empty_ui    => p_create_empty_ui,
                   x_ui_def_id          => x_ui_def_id,
                   x_return_status      => x_return_status,
                   x_msg_count          => x_msg_count,
                   x_msg_data           => x_msg_data);
END create_jrad_ui;

--------------------------------------------------------

PROCEDURE refresh_ui(p_api_version IN     NUMBER,
                     p_ui_def_id   IN OUT NOCOPY NUMBER,
                     x_run_id      OUT NOCOPY    NUMBER,
                     x_status      OUT NOCOPY    NUMBER) IS
l_api_name      CONSTANT VARCHAR2(30) := 'refresh_ui';
l_api_version   CONSTANT NUMBER := 1.0;
l_urgency       NUMBER;
l_errbuf        VARCHAR2(2000);
l_found         NUMBER;
l_found_ui      NUMBER;
NOT_VALID_UI_DEF_ID     EXCEPTION;
NOT_VALID_PROJECT_ID    EXCEPTION;

BEGIN
  -- Start of API savepoint
  SAVEPOINT refresh_ui_PUB;

  SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  BEGIN
    SELECT 1
    INTO l_found_ui
    FROM cz_ui_defs
    WHERE ui_def_id = p_ui_def_id AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NOT_VALID_UI_DEF_ID;
  END;

  BEGIN
    SELECT 1
    INTO l_found
    FROM cz_rp_entries rp, cz_ui_defs uidef
    WHERE object_type = 'PRJ' AND object_id = devl_project_id AND ui_def_id = p_ui_def_id
       AND rp.deleted_flag = '0' AND uidef.deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NOT_VALID_PROJECT_ID;
  END;

  CZ_UI_GENERATOR.refreshUI(p_ui_def_id, x_run_id);

  IF x_run_id = 0 THEN
    x_status := G_STATUS_SUCCESS;
  ELSE
    SELECT max(urgency)
      INTO l_urgency
    FROM cz_db_logs
    WHERE run_id = x_run_id;

    IF l_urgency = 1 THEN
      x_status := G_STATUS_ERROR;
      ROLLBACK TO refresh_ui_PUB;
    ELSIF l_urgency = 0 THEN
      x_status := G_STATUS_WARNING;
    END IF;
  END IF;

  COMMIT WORK;
EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN NOT_VALID_UI_DEF_ID THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_UI_DEF_ID_ERR');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN NOT_VALID_PROJECT_ID THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_UI_PRJ_ERR', 'UIDEF', p_ui_def_id);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN OTHERS THEN
         x_status := G_STATUS_ERROR;
         ROLLBACK TO refresh_ui_PUB;
         l_errbuf := SQLERRM;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_UNEXPECTED);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
END refresh_ui;
------------------------------------------------------------------------------------------------
PROCEDURE refresh_ui(p_api_version IN NUMBER,
                     p_ui_def_id   IN OUT NOCOPY NUMBER,
                     p_user_id     IN NUMBER,
                     p_resp_id     IN NUMBER,
                     p_appl_id     IN NUMBER,
                     x_run_id      OUT NOCOPY    NUMBER,
                     x_status      OUT NOCOPY    NUMBER)
IS
BEGIN
  fnd_global.apps_initialize(p_user_id,p_resp_id,p_appl_id);
  refresh_ui( p_api_version,
              p_ui_def_id,
              x_run_id,
              x_status);
END refresh_ui;

------------------------------------------------------------
-- Start of comments
--    API name    : refresh_Jrad_UI
--    Type        : Public.
--    Function    : Refresh an existing JRAD style user interface based on the current model data.
--    Pre-reqs    : None.
--    Parameters  :
--    IN          : p_api_version           - identifies version of API
--                  p_ui_def_id             - identifies UI to refresh
--    OUT         :
--      x_return_status       -- status string
--      x_msg_count           -- number of error messages
--      x_msg_data            -- string which contains error messages
--
--    Version     : Current version       1.0
--                  Initial version       1.0
--    Notes       :
--
-- End of comments
--
PROCEDURE refresh_jrad_ui(p_api_version     IN     NUMBER,
                          p_ui_def_id       IN OUT NOCOPY NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2) IS

    l_api_name              CONSTANT VARCHAR2(30) := 'refresh_ui';
    l_api_version           CONSTANT NUMBER := 1.0;
    l_urgency               NUMBER;
    l_errbuf                VARCHAR2(2000);
    l_found                 NUMBER;
    l_ui_style              CZ_UI_DEFS.ui_style%TYPE;
    NOT_VALID_UI_DEF_ID     EXCEPTION;
    WRONG_UI_STYLE          EXCEPTION;

BEGIN
  -- Start of API savepoint
  SAVEPOINT refresh_ui_PUB;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  BEGIN
    SELECT ui_style
    INTO l_ui_style
    FROM cz_ui_defs
    WHERE ui_def_id = p_ui_def_id AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NOT_VALID_UI_DEF_ID;
  END;

  IF l_ui_style NOT IN ('7','JRAD') THEN
     RAISE WRONG_UI_STYLE;
  END IF;

  CZ_UIOA_PVT.refresh_UI(p_ui_def_id        => p_ui_def_id,
                         x_return_status    => x_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data);

  IF x_msg_count > 0 THEN
     ROLLBACK TO refresh_ui_PUB;
  END IF;

  COMMIT WORK;

EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('CZ', 'CZ_MOP_API_VERSION_ERR');
         FND_MESSAGE.SET_TOKEN('CODE_VERSION', l_api_version);
         FND_MESSAGE.SET_TOKEN('IN_VERSION', p_api_version);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

    WHEN NOT_VALID_UI_DEF_ID THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('CZ', 'CZ_MOP_UI_DEF_ID_ERR');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

    WHEN WRONG_UI_STYLE THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('CZ', 'CZ_UI_STYLE_ERR');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         ROLLBACK TO refresh_ui_PUB;
END refresh_jrad_ui;

------------------------------------------------------------------------------------------------

PROCEDURE refresh_jrad_ui(p_api_version     IN NUMBER,
                          p_user_id         IN NUMBER,
                          p_resp_id         IN NUMBER,
                          p_appl_id         IN NUMBER,
                          p_ui_def_id       IN OUT NOCOPY NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2) IS
BEGIN
    fnd_global.apps_initialize(p_user_id,p_resp_id,p_appl_id);
    refresh_jrad_ui(p_api_version   => p_api_version,
                    p_ui_def_id     => p_ui_def_id,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data);
END refresh_jrad_ui;

------------------------------------------------------------

PROCEDURE import_single_bill(p_api_version      IN  NUMBER,
                             p_org_id           IN  NUMBER,
                             p_top_inv_item_id  IN  NUMBER,
                             x_run_id           OUT NOCOPY NUMBER,
                             x_status           OUT NOCOPY NUMBER) IS -- sselahi: removed x_run_info_id
l_api_name           CONSTANT VARCHAR2(30) := 'import_single_bill';
l_api_version        CONSTANT NUMBER := 1.0;
l_error              BOOLEAN := FALSE;
l_db_link            CZ_SERVERS.fndnam_link_name%TYPE;
l_Exist              VARCHAR2(1):= 'N';
l_err                VARCHAR2(1);
l_errbuf             VARCHAR2(2000);
l_retcode            NUMBER;
l_user_name          VARCHAR2(100);
l_user_id            NUMBER;
l_resp_id            NUMBER;
l_appl_id            NUMBER;
TOO_MANY_IMP_SERVERS EXCEPTION;
NO_IMP_SERVERS       EXCEPTION;
WRONG_EXV_VIEWS      EXCEPTION;
DB_LINK_IS_DOWN      EXCEPTION;
SESS_NOT_INITIALIZED EXCEPTION;

BEGIN

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  l_user_id := FND_GLOBAL.user_id;
  IF (l_user_id IS NULL) THEN
  RAISE SESS_NOT_INITIALIZED;
  END IF;

  BEGIN
      SELECT fndnam_link_name
      INTO l_db_link
      FROM cz_servers
      WHERE import_enabled = '1';
  EXCEPTION
      WHEN TOO_MANY_ROWS THEN
           RAISE TOO_MANY_IMP_SERVERS;
      WHEN NO_DATA_FOUND THEN
           RAISE NO_IMP_SERVERS;
  END;

  --Bug #4865395. Changing the probe query to be against cz_exv_item_properties which is
  --much lighter view than cz_exv_organizations.

     -- probe select --
  BEGIN
      EXECUTE IMMEDIATE
      'SELECT ''Y'' FROM cz_exv_item_properties where rownum < 2'
      INTO l_Exist;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
  END;


   --
   -- if cz_exv_item_properties is empty then
   -- this means that EXV views were recreated based on local tables
   -- with rownum<1 where condition
   -- in this case try to recreate views based on remote tables if
   -- db link is alive
   --
   IF l_Exist='N' THEN
      IF CZ_ORAAPPS_INTEGRATE.isLinkAlive(l_db_link)=CZ_ORAAPPS_INTEGRATE.LINK_WORKS THEN
         l_err:=CZ_ORAAPPS_INTEGRATE.create_exv_views(l_db_link);
         IF l_err<>'0' THEN
            -- not all EXV views have been recreated --
            RAISE WRONG_EXV_VIEWS;
         END IF;
      ELSE
         RAISE DB_LINK_IS_DOWN;
      END IF;
   END IF;


  CZ_IMP_ALL.goSingleBill (p_org_id, p_top_inv_item_id, '0', -1, '0', x_run_id); -- sselahi: added x_run_id
  x_status := G_STATUS_SUCCESS;


EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN SESS_NOT_INITIALIZED THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_SESS_NOT_INITIALIZED');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN TOO_MANY_IMP_SERVERS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_IMP_TOO_MANY_SERVERS');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN NO_IMP_SERVERS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_IMP_NO_SERVERS');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN WRONG_EXV_VIEWS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := 'Error : not all EXV views have been recreated successfully';
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN DB_LINK_IS_DOWN THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_DB_LINK_IS_DOWN','DBLINK',l_db_link);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
         x_status := G_STATUS_ERROR;
         l_errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED');
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := SQLERRM;
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN OTHERS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := SQLERRM;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_UNEXPECTED);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
END import_single_bill;
------------------------------------------------------------------------------------------------
PROCEDURE import_single_bill(p_api_version      IN  NUMBER,
                             p_org_id           IN  NUMBER,
                             p_top_inv_item_id  IN  NUMBER,
                             p_user_id          IN NUMBER,
                             p_resp_id          IN NUMBER,
                             p_appl_id          IN NUMBER,
                             x_run_id           OUT NOCOPY NUMBER,
                             x_status           OUT NOCOPY NUMBER)
IS
BEGIN
 fnd_global.apps_initialize(p_user_id,p_resp_id,p_appl_id);
 import_single_bill(p_api_version,
                    p_org_id,
                    p_top_inv_item_id,
                    x_run_id,
                    x_status);
END import_single_bill;
---------------------------------------
PROCEDURE refresh_single_model(p_api_version       IN  NUMBER,
                               p_devl_project_id   IN  VARCHAR2,
                               x_run_id            OUT NOCOPY NUMBER,
                               x_status            OUT NOCOPY NUMBER) IS
l_api_name              CONSTANT VARCHAR2(30) := 'refresh_single_model';
l_api_version           CONSTANT NUMBER := 1.0;
l_errbuf                VARCHAR2(2000);
l_found                 NUMBER;
l_db_link               CZ_SERVERS.fndnam_link_name%TYPE;
l_Exist                 VARCHAR2(1):= 'N';
l_err                   VARCHAR2(1);
l_user_id               NUMBER;
TOO_MANY_IMP_SERVERS    EXCEPTION;
NO_IMP_SERVERS          EXCEPTION;
WRONG_EXV_VIEWS         EXCEPTION;
DB_LINK_IS_DOWN         EXCEPTION;
PROJECT_ID_NOT_EXITS    EXCEPTION;
SESS_NOT_INITIALIZED    EXCEPTION;
lOrg_Id                 CZ_XFR_PROJECT_BILLS.ORGANIZATION_ID%TYPE;
lTop_Id                 CZ_XFR_PROJECT_BILLS.TOP_ITEM_ID%TYPE;

BEGIN

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;
  l_user_id := FND_GLOBAL.user_id;
  IF (l_user_id IS NULL) THEN
  RAISE SESS_NOT_INITIALIZED;
  END IF;

  -- verify p_devl_project_id
  BEGIN
    SELECT 1
    INTO l_found
    FROM cz_rp_entries
    WHERE object_type = 'PRJ'
    AND object_id = p_devl_project_id
    AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE PROJECT_ID_NOT_EXITS;
  END;

    -- get the org id and top model id
  SELECT rtrim(substr(orig_sys_ref,instr(orig_sys_ref,':',1,1)+1,length(substr(orig_sys_ref,instr(orig_sys_ref,':',1,1)+1)) -
              length(substr(orig_sys_ref,instr(orig_sys_ref,':',1,2)))  )) ,
    rtrim(substr(orig_sys_ref,instr(orig_sys_ref,':',1,2)+1))
  INTO lOrg_Id, lTop_Id
  FROM cz_devl_projects
  WHERE devl_project_id = p_devl_project_id
  AND deleted_flag = '0';

  -- check the imp server
  BEGIN
      SELECT fndnam_link_name
      INTO l_db_link
      FROM cz_servers
      WHERE import_enabled = '1';
  EXCEPTION
      WHEN TOO_MANY_ROWS THEN
           RAISE TOO_MANY_IMP_SERVERS;
      WHEN NO_DATA_FOUND THEN
           RAISE NO_IMP_SERVERS;
  END;

  --Bug #4865395. Changing the probe query to be against cz_exv_item_properties which is
  --much lighter view than cz_exv_organizations.

     -- probe select --
  BEGIN
      EXECUTE IMMEDIATE
      'SELECT ''Y'' FROM cz_exv_item_properties where rownum < 2'
      INTO l_Exist;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
  END;
   --
   -- if cz_exv_item_properties is empty then
   -- this means that EXV views were recreated based on local tables
   -- with rownum<1 where condition
   -- in this case try to recreate views based on remote tables if
   -- db link is alive
   --
   IF l_Exist='N' THEN
      IF CZ_ORAAPPS_INTEGRATE.isLinkAlive(l_db_link)=CZ_ORAAPPS_INTEGRATE.LINK_WORKS THEN
         l_err:=CZ_ORAAPPS_INTEGRATE.create_exv_views(l_db_link);
         IF l_err<>'0' THEN
            -- not all EXV views have been recreated --
            RAISE WRONG_EXV_VIEWS;
         END IF;
      ELSE
         RAISE DB_LINK_IS_DOWN;
      END IF;
   END IF;

  -- call the import
  CZ_IMP_ALL.goSingleBill (lOrg_Id, lTop_Id, '0', -1, '0', x_run_id);
  x_status := G_STATUS_SUCCESS;

EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN SESS_NOT_INITIALIZED THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_SESS_NOT_INITIALIZED');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN TOO_MANY_IMP_SERVERS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_IMP_TOO_MANY_SERVERS');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN NO_IMP_SERVERS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_IMP_NO_SERVERS');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN WRONG_EXV_VIEWS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := 'Error : not all EXV views have been recreated successfully';
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN DB_LINK_IS_DOWN THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_DB_LINK_IS_DOWN','DBLINK',l_db_link);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN PROJECT_ID_NOT_EXITS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_DEV_PRJ_ID_ERR', 'PROJID', p_devl_project_id);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
         x_status := G_STATUS_ERROR;
         l_errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED');
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := SQLERRM;
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN OTHERS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := SQLERRM;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_UNEXPECTED);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
end refresh_single_model;
------------------------------------------------------------------------------------------------
PROCEDURE refresh_single_model(p_api_version     IN  NUMBER,
                               p_devl_project_id IN  VARCHAR2,
                               p_user_id         IN NUMBER,
                               p_resp_id         IN NUMBER,
                               p_appl_id         IN NUMBER,
                               x_run_id          OUT NOCOPY NUMBER,
                               x_status          OUT NOCOPY NUMBER)
IS
BEGIN
 fnd_global.apps_initialize(p_user_id,p_resp_id,p_appl_id);
 refresh_single_model(p_api_version,
                       p_devl_project_id,
                       x_run_id,
                       x_status);
END refresh_single_model;

-------------------------------------------------------------
PROCEDURE publish_model(p_api_version    IN  NUMBER,
                        p_publication_id IN  NUMBER,
                        x_run_id         OUT NOCOPY NUMBER,
                        x_status         OUT NOCOPY NUMBER) IS
l_api_name      CONSTANT VARCHAR2(30) := 'publish_model';
l_api_version   CONSTANT NUMBER := 1.0;
l_status        VARCHAR2(3);
l_errbuf        VARCHAR2(2000);

BEGIN
  SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;


  cz_pb_mgr.publish_model(p_publication_id, x_run_id, l_status);

  IF l_status = 'OK' THEN
    x_status := G_STATUS_SUCCESS;
  ELSE
    x_status := G_STATUS_ERROR;
  END IF;

EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN OTHERS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := SQLERRM;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_UNEXPECTED);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
END publish_model;
------------------------------------------------------------------------------------------------
PROCEDURE publish_model(p_api_version    IN  NUMBER,
                        p_publication_id IN  NUMBER,
                        p_user_id        IN NUMBER,
                        p_resp_id        IN NUMBER,
                        p_appl_id        IN NUMBER,
                        x_run_id         OUT NOCOPY NUMBER,
                        x_status         OUT NOCOPY NUMBER) IS
BEGIN
 fnd_global.apps_initialize(p_user_id,p_resp_id,p_appl_id);
 publish_model(p_api_version,
               p_publication_id,
               x_run_id,
               x_status);
END publish_model;
--------------------------------------
PROCEDURE deep_model_copy(p_api_version     IN  NUMBER,
                          p_devl_project_id IN  NUMBER,
                          p_folder          IN  NUMBER,
                          p_copy_rules      IN  NUMBER,
                          p_copy_uis        IN  NUMBER,
                          p_copy_root       IN  NUMBER,
                          x_devl_project_id OUT NOCOPY NUMBER,
                          x_run_id          OUT NOCOPY NUMBER,
                          x_status          OUT NOCOPY NUMBER) IS
l_api_name      CONSTANT VARCHAR2(30) := 'deep_model_copy';
l_api_version   CONSTANT NUMBER := 1.0;
l_status        VARCHAR2(3);
l_errbuf        VARCHAR2(2000);
l_found         NUMBER;
NOT_VALID_PROJECT_ID    EXCEPTION;

BEGIN
  SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  BEGIN
    SELECT 1
    INTO l_found
    FROM cz_rp_entries
    WHERE object_type = 'PRJ' AND object_id = p_devl_project_id AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NOT_VALID_PROJECT_ID;
  END;

cz_pb_mgr.deep_model_copy(p_devl_project_id, 0, p_folder, p_copy_rules, p_copy_uis,
                          p_copy_root, x_devl_project_id, x_run_id, l_status);

  IF l_status = 'OK' THEN
    x_status := G_STATUS_SUCCESS;
  ELSE
    x_status := G_STATUS_ERROR;
  END IF;

EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN NOT_VALID_PROJECT_ID THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_DEV_PRJ_ID_ERR', 'PROJID', p_devl_project_id);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN OTHERS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := SQLERRM;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_UNEXPECTED);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
END deep_model_copy;
------------------------------------------------------------------------------------------------
PROCEDURE deep_model_copy(p_api_version IN  NUMBER,
                          p_user_id     IN NUMBER,
                          p_resp_id     IN NUMBER,
                          p_appl_id     IN NUMBER,
                          p_devl_project_id IN  NUMBER,
                          p_folder          IN  NUMBER,
                          p_copy_rules      IN  NUMBER,
                          p_copy_uis        IN  NUMBER,
                          p_copy_root       IN  NUMBER,
                          x_devl_project_id OUT NOCOPY NUMBER,
                          x_run_id          OUT NOCOPY NUMBER,
                          x_status          OUT NOCOPY NUMBER) IS

 BEGIN
 fnd_global.apps_initialize(p_user_id,p_resp_id,p_appl_id);
 deep_model_copy(p_api_version,
                 p_devl_project_id,
                 p_folder,
                 p_copy_rules,
                 p_copy_uis,
                 p_copy_root,
                 x_devl_project_id,
                 x_run_id,
                 x_status);
END deep_model_copy;

-----------------------------------------------------------------
PROCEDURE execute_populator(p_api_version  IN     NUMBER,
                            p_populator_id IN     NUMBER,
                            p_imp_run_id   IN OUT NOCOPY VARCHAR2,
                            x_run_id       OUT NOCOPY    NUMBER,
                            x_status       OUT NOCOPY    NUMBER) IS
l_api_name      CONSTANT VARCHAR2(30) := 'execute_populator';
l_api_version   CONSTANT NUMBER := 1.0;
l_errbuf        VARCHAR2(2000);
l_found         NUMBER;
NOT_VALID_POPULATOR_ID  EXCEPTION;

BEGIN
  SAVEPOINT execute_populator_PUB;

  SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  BEGIN
    SELECT NULL
    INTO l_found
    FROM cz_populators
    WHERE populator_id = p_populator_id AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NOT_VALID_POPULATOR_ID;
  END;

  cz_populators_pkg.execute(p_populator_id, p_imp_run_id, x_run_id);
  IF x_run_id = 0 THEN
    x_status := G_STATUS_SUCCESS;
    COMMIT WORK;
  ELSE
    x_status := G_STATUS_ERROR;
    ROLLBACK TO execute_populator_PUB;
  END IF;

EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN NOT_VALID_POPULATOR_ID THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_POPULATOR_ID_ERR');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN OTHERS THEN
         x_status := G_STATUS_ERROR;
         ROLLBACK TO execute_populator_PUB;
         l_errbuf := SQLERRM;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_UNEXPECTED);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
END execute_populator;

------------------------------------------------------------------------------------------------
PROCEDURE execute_populator(p_api_version  IN     NUMBER,
                            p_user_id      IN     NUMBER,
                            p_resp_id      IN     NUMBER,
                            p_appl_id      IN     NUMBER,
                            p_populator_id IN     NUMBER,
                            p_imp_run_id   IN  OUT NOCOPY VARCHAR2,
                            x_run_id       OUT NOCOPY    NUMBER,
                            x_status       OUT NOCOPY    NUMBER) IS
 BEGIN
  fnd_global.apps_initialize(p_user_id,p_resp_id,p_appl_id);
     execute_populator(p_api_version,
                        p_populator_id,
                        p_imp_run_id,
                        x_run_id,
                        x_status);
END execute_populator;

-------------------------------------------------
PROCEDURE repopulate(p_api_version    IN  NUMBER,
                    p_devl_project_id IN  NUMBER,
                    p_regenerate_all  IN  VARCHAR2 , -- DEFAULT '1',
                    p_handle_invalid  IN  VARCHAR2 , -- DEFAULT '1',
                    p_handle_broken   IN  VARCHAR2 , -- DEFAULT '1',
                    x_run_id          OUT NOCOPY NUMBER,
                    x_status          OUT NOCOPY NUMBER) IS
l_api_name      CONSTANT VARCHAR2(30) := 'repopulate';
l_api_version   CONSTANT NUMBER := 1.0;
l_errbuf        VARCHAR2(2000);
l_found         NUMBER;
NOT_VALID_PROJECT_ID    EXCEPTION;

BEGIN
  SAVEPOINT repopulate_PUB;

  SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  BEGIN
    SELECT 1
    INTO l_found
    FROM cz_rp_entries
    WHERE object_type = 'PRJ' AND object_id = p_devl_project_id AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE NOT_VALID_PROJECT_ID;
  END;

  cz_populators_pkg.repopulate(p_devl_project_id, p_regenerate_all, p_handle_invalid, p_handle_broken, x_run_id);
  IF x_run_id = 0 THEN
    x_status := G_STATUS_SUCCESS;
    COMMIT WORK;
  ELSE
    x_status := G_STATUS_ERROR;
    ROLLBACK TO repopulate_PUB;
  END IF;

EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN NOT_VALID_PROJECT_ID THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_DEV_PRJ_ID_ERR', 'PROJID', p_devl_project_id);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN OTHERS THEN
         x_status := G_STATUS_ERROR;
         ROLLBACK TO repopulate_PUB;
         l_errbuf := SQLERRM;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_UNEXPECTED);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
END repopulate;
------------------------------------------------------------------------------------------------
PROCEDURE repopulate(p_api_version    IN  NUMBER,
                    p_devl_project_id IN  NUMBER,
                    p_user_id         IN NUMBER,
                    p_resp_id         IN NUMBER,
                    p_appl_id         IN NUMBER,
                    p_regenerate_all  IN  VARCHAR2 , -- DEFAULT '1',
                    p_handle_invalid  IN  VARCHAR2 , -- DEFAULT '1',
                    p_handle_broken   IN  VARCHAR2 , -- DEFAULT '1',
                    x_run_id          OUT NOCOPY NUMBER,
                    x_status          OUT NOCOPY NUMBER) IS
 BEGIN
    fnd_global.apps_initialize(p_user_id,p_resp_id,p_appl_id);
    repopulate(p_api_version,
               p_devl_project_id,
               p_user_id        ,
               p_resp_id        ,
               p_appl_id        ,
               p_regenerate_all ,
               p_handle_invalid ,
               p_handle_broken  ,
               x_run_id         ,
               x_status         );
 END repopulate;

---------------------------------------------------------
PROCEDURE republish_model(p_api_version    IN  NUMBER,
                          p_publication_id IN  NUMBER,
                          p_start_date     IN  DATE,
                          p_end_date       IN  DATE,
                          x_run_id         OUT NOCOPY NUMBER,
                          x_status         OUT NOCOPY NUMBER) IS
l_api_name      CONSTANT VARCHAR2(30) := 'republish_model';
l_api_version   CONSTANT NUMBER := 1.0;
l_status        VARCHAR2(3);
l_errbuf        VARCHAR2(2000);
l_start_date    DATE;
l_end_date      DATE;
l_publication_id NUMBER;
BEGIN
  SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  l_start_date     := p_start_date;
  l_end_date       := p_end_date;
  l_publication_id := p_publication_id;
  cz_pb_mgr.republish_model(l_publication_id,l_start_date,l_end_date,x_run_id,l_status);

  IF l_status = 'OK' THEN
    x_status := G_STATUS_SUCCESS;
  ELSE
    x_status := G_STATUS_ERROR;
  END IF;

EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
         COMMIT;
    WHEN OTHERS THEN
         x_status := G_STATUS_ERROR;
         l_errbuf := SQLERRM;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_UNEXPECTED);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
END republish_model;
---------------------------------------------------------
PROCEDURE republish_model(p_api_version     IN  NUMBER,
                          p_publication_id  IN  NUMBER,
                          p_user_id         IN NUMBER,
                          p_resp_id         IN NUMBER,
                          p_appl_id         IN NUMBER,
                          p_start_date      IN  DATE,
                          p_end_date        IN  DATE,
                          x_run_id          OUT NOCOPY NUMBER,
                          x_status          OUT NOCOPY NUMBER)
IS
 BEGIN
     fnd_global.apps_initialize(p_user_id,p_resp_id,p_appl_id);
     republish_model(p_api_version,
                  p_publication_id,
                  p_start_date,
                  p_end_date,
                  x_run_id,
                  x_status);
END republish_model;
------------------------------------------------------------------------------------------------
FUNCTION rp_folder_exists (p_api_version    IN NUMBER,
                           p_encl_folder_id IN NUMBER,
                           p_rp_folder_id   IN NUMBER) RETURN BOOLEAN IS

l_api_name           CONSTANT VARCHAR2(30) := 'rp_folder_exists';
l_api_version        CONSTANT NUMBER := 1.0;

-- cursor to check the enclosing folder when it is not null
CURSOR encl_folder_exits_csr IS
 SELECT 'X'
 FROM cz_rp_entries
 WHERE object_id = p_encl_folder_id
 AND object_type = 'FLD'
 AND deleted_flag = '0';

-- cursor to check the folder when encl folder is not null
CURSOR folder_exists_in_encl_csr IS
 SELECT 'X'
 FROM cz_rp_entries
 WHERE object_id = p_rp_folder_id
 AND enclosing_folder = p_encl_folder_id
 AND object_type = 'FLD'
 AND deleted_flag = '0';

-- cursor to check the folder when enclosing folder is null
CURSOR folder_exists_csr IS
 SELECT 'X'
 FROM cz_rp_entries
 WHERE object_id = p_rp_folder_id
 AND object_type = 'FLD'
 AND deleted_flag = '0';

 x_found        BOOLEAN:=FALSE;
 p_error_flag   CHAR(1):='';
 x_msg_data     VARCHAR2(2000);
 l_dummy_nbr    NUMBER;

BEGIN
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

    IF p_encl_folder_id IS NOT NULL THEN
      -- first check if enclosing folder exists
      OPEN encl_folder_exits_csr;
      FETCH encl_folder_exits_csr INTO p_error_flag;
      x_found:=encl_folder_exits_csr%FOUND;
      CLOSE encl_folder_exits_csr;

        IF NOT x_found THEN
           RETURN x_found;
        END IF;

      -- now check if the folder exists
     OPEN folder_exists_in_encl_csr;
     FETCH folder_exists_in_encl_csr INTO p_error_flag;
     x_found:=folder_exists_in_encl_csr%FOUND;
     CLOSE folder_exists_in_encl_csr;
    ELSE
      -- check if folder exists anywhere
      OPEN folder_exists_csr;
      FETCH folder_exists_csr INTO p_error_flag;
      x_found:=folder_exists_csr%FOUND;
      CLOSE folder_exists_csr;
    END IF;

    RETURN x_found;

EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         RAISE G_INCOMPATIBLE_API;
    WHEN OTHERS THEN
         RAISE FND_API.G_EXC_ERROR;
END rp_folder_exists;
---------------------------------------------------------
FUNCTION rp_folder_exists (
  p_api_version    IN NUMBER,
  p_encl_folder_id IN NUMBER,
  p_rp_folder_id   IN NUMBER,
  p_user_id        IN NUMBER,
  p_resp_id        IN NUMBER,
  p_appl_id        IN NUMBER
) RETURN BOOLEAN IS
BEGIN
  fnd_global.apps_initialize (
    p_user_id,
    p_resp_id,
    p_appl_id
  );
  return rp_folder_exists (
           p_api_version,
           p_encl_folder_id,
           p_rp_folder_id
         );
END rp_folder_exists;
---------------------------------------------------------
PROCEDURE create_rp_folder(p_api_version          IN  NUMBER
                          ,p_encl_folder_id       IN  CZ_RP_ENTRIES.OBJECT_ID%TYPE
                          ,p_new_folder_name      IN  CZ_RP_ENTRIES.NAME%TYPE
                          ,p_folder_desc          IN  CZ_RP_ENTRIES.DESCRIPTION%TYPE
                          ,p_folder_notes         IN  CZ_RP_ENTRIES.NOTES%TYPE
                          ,x_new_folder_id        OUT NOCOPY CZ_RP_ENTRIES.OBJECT_ID%TYPE
                          ,x_return_status        OUT NOCOPY  VARCHAR2
                          ,x_msg_count            OUT NOCOPY  NUMBER
                          ,x_msg_data             OUT NOCOPY  VARCHAR2
                          )
IS

  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'create_rp_folder';

  l_new_object_id           CZ_RP_ENTRIES.OBJECT_ID%TYPE;
  l_dummy_nbr               NUMBER;
  l_count                   NUMBER;

BEGIN
  -- standard call to check for call compatibility
  IF (NOT FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,G_PKG_NAME
                                     )) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BEGIN -- validate the encl_folder_id
    SELECT 1 INTO l_dummy_nbr
    FROM cz_rp_entries
    WHERE object_id = p_encl_folder_id
    AND object_type = 'FLD'
    AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_msg_data := CZ_UTILS.GET_TEXT('CZ_RP_FLDR_NO_ENCL_FLDR');
      RAISE FND_API.G_EXC_ERROR;
  END;

  BEGIN -- check if folder already exists, if so return its id
    SELECT object_id INTO x_new_folder_id
    FROM cz_rp_entries
    WHERE name = p_new_folder_name
    AND enclosing_folder = p_encl_folder_id
    AND object_type = 'FLD'
    AND deleted_flag = '0';

  EXCEPTION  -- it doesn't exists, so create it
    WHEN NO_DATA_FOUND THEN

         SELECT cz_rp_entries_s.NEXTVAL
         INTO l_new_object_id
         FROM DUAL;

        INSERT INTO cz_rp_entries
                    (object_id
                    ,name
                    ,object_type
                    ,enclosing_folder
                    ,description
                    ,notes
                    )
              VALUES
                   (l_new_object_id
                   ,p_new_folder_name
                   ,'FLD'
                   ,p_encl_folder_id
                   ,p_folder_desc
                   ,p_folder_notes
                   );
        COMMIT;
        x_new_folder_id := l_new_object_id;
  END;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
      fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END create_rp_folder;
---------------------------------------------------------
PROCEDURE create_rp_folder (
  p_api_version          IN  NUMBER,
  p_encl_folder_id       IN  CZ_RP_ENTRIES.OBJECT_ID%TYPE,
  p_new_folder_name      IN  CZ_RP_ENTRIES.NAME%TYPE,
  p_folder_desc          IN  CZ_RP_ENTRIES.DESCRIPTION%TYPE,
  p_folder_notes         IN  CZ_RP_ENTRIES.NOTES%TYPE,
  p_user_id              IN  NUMBER,
  p_resp_id              IN  NUMBER,
  p_appl_id              IN  NUMBER,
  x_new_folder_id        OUT NOCOPY CZ_RP_ENTRIES.OBJECT_ID%TYPE,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2
) IS
BEGIN
  fnd_global.apps_initialize (
    p_user_id,
    p_resp_id,
    p_appl_id
  );
  create_rp_folder (
    p_api_version,
    p_encl_folder_id,
    p_new_folder_name,
    p_folder_desc,
    p_folder_notes,
    x_new_folder_id,
    x_return_status,
    x_msg_count,
    x_msg_data
  );
END create_rp_folder;
---------------------------------------------------------
PROCEDURE import_generic(p_api_version      IN  NUMBER
                        ,p_run_id           IN  NUMBER
                        ,p_rp_folder_id     IN NUMBER
                        ,x_run_id           OUT NOCOPY NUMBER
                        ,x_status           OUT NOCOPY NUMBER)
IS
l_api_name           CONSTANT VARCHAR2(30) := 'import_generic';
l_api_version        CONSTANT NUMBER := 1.0;
TYPE boolean_t       IS TABLE OF BOOLEAN index by BINARY_INTEGER;
l_dummy_nbr          NUMBER;
l_msg_data       VARCHAR2(2000);
l_msg_count      NUMBER := 0;
l_return_status      VARCHAR2(1);
l_locked_models_tbl      cz_security_pvt.number_type_tbl;
l_model_id_tbl           cz_security_pvt.number_type_tbl;
l_devl_prj_id_tbl        cz_security_pvt.number_type_tbl;
l_all_locked_models_tbl  cz_security_pvt.number_type_tbl;

NO_PRIV_EXCP                 EXCEPTION;
PRIV_CHECK_ERR_EXP           EXCEPTION;
FAILED_TO_LOCK_MODEL_EXCP    EXCEPTION;
MODEL_NOT_EDITABLE           EXCEPTION;
MODEL_LOCKED_EXCP            EXCEPTION;
MODEL_UNLOCK_EXCP            EXCEPTION;
INVALID_ENCL_FLDR_EXCP       EXCEPTION;
SESS_NOT_INITIALIZED_EXCP    EXCEPTION;

xERROR           BOOLEAN:=FALSE;
l_user_name      varchar2(255);
l_user_id        NUMBER;
l_is_new_model   BOOLEAN;

-- model ids before calling generic import
CURSOR l_imp_devl_project_csr IS
SELECT nvl(model_id,0)
FROM CZ_IMP_DEVL_PROJECT
WHERE rec_status IS NULL AND Run_ID = p_run_id;

-- devl projects after after calling generic import
CURSOR l_imp_devl_project_csr_2 IS
SELECT nvl(model_id,0), nvl(devl_project_id,0)
FROM CZ_IMP_DEVL_PROJECT
WHERE rec_status IS NOT NULL AND Run_ID = x_run_id;

BEGIN

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE G_INCOMPATIBLE_API;
  END IF;

  l_user_id := FND_GLOBAL.user_id;
  l_user_name := FND_GLOBAL.user_name;
  IF (l_user_name IS NULL) THEN
      RAISE SESS_NOT_INITIALIZED_EXCP;
  END IF;

  BEGIN -- validate the encl_folder_id
    SELECT 1 INTO l_dummy_nbr
    FROM cz_rp_entries
    WHERE object_id = p_rp_folder_id
    AND object_type = 'FLD'
    AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_msg_count        := 1;
      l_msg_data         := cz_utils.get_text('CZ_IMPGEN_ENCL_FLDR');
      RAISE INVALID_ENCL_FLDR_EXCP;
  END;

    l_model_id_tbl.DELETE;
    l_all_locked_models_tbl.DELETE;
    OPEN l_imp_devl_project_csr;
    FETCH l_imp_devl_project_csr
    BULK COLLECT INTO l_model_id_tbl;
    CLOSE l_imp_devl_project_csr;

    -- shallow lock each model because we don't know model relationships

    IF (l_model_id_tbl.COUNT > 0) THEN
      FOR i IN l_model_id_tbl.FIRST..l_model_id_tbl.LAST LOOP
        IF (l_model_id_tbl(i) <> 0) THEN
            l_locked_models_tbl.DELETE;
            cz_security_pvt.lock_model(
              p_api_version          =>   1.0,
              p_model_id             =>   l_model_id_tbl(i),
              p_lock_child_models    =>   FND_API.G_FALSE,
              p_commit_flag          =>   FND_API.G_TRUE,
              x_locked_entities      =>   l_locked_models_tbl,
              x_return_status        =>   l_return_status,
              x_msg_count            =>   l_msg_count,
              x_msg_data             =>   l_msg_data);
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              FOR k IN 1..l_msg_count LOOP
                l_msg_data  := fnd_msg_pub.get(k,fnd_api.g_false);
                xERROR:=cz_utils.log_report(l_msg_data,1,'CZ_MODELOPERATIONS_PUB.IMPORT_GENERIC',20001,p_run_id);
                COMMIT;
              END LOOP;
              RAISE FAILED_TO_LOCK_MODEL_EXCP;
            END IF;
            IF ( l_locked_models_tbl.COUNT > 0 ) THEN
               FOR j IN l_locked_models_tbl.FIRST..l_locked_models_tbl.LAST LOOP
                  l_all_locked_models_tbl(l_all_locked_models_tbl.COUNT + 1) := l_locked_models_tbl(j);
               END LOOP;
            END IF;
        END IF;
      END LOOP;
    END IF;

  -- call go_generic

  CZ_IMP_ALL.go_generic(x_run_id, p_run_id, p_rp_folder_id);
  x_status := G_STATUS_SUCCESS;

  IF (l_all_locked_models_tbl.COUNT > 0) THEN
            cz_security_pvt.unlock_model(
              p_api_version          =>   1.0,
              p_commit_flag          =>   FND_API.G_TRUE,
              p_models_to_unlock     =>   l_all_locked_models_tbl,
              x_return_status        =>   l_return_status,
              x_msg_count            =>   l_msg_count,
              x_msg_data             =>   l_msg_data);
  END IF;

EXCEPTION
    WHEN G_INCOMPATIBLE_API THEN
         x_status := G_STATUS_ERROR;
         l_msg_data := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_msg_data, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_msg_data, 11276, G_PKG_NAME||'.'||l_api_name, 1, p_run_id, SYSDATE);
         COMMIT;
    WHEN SESS_NOT_INITIALIZED_EXCP THEN
         x_status := G_STATUS_ERROR;
         l_msg_data := CZ_UTILS.GET_TEXT('CZ_SESS_NOT_INITIALIZED');
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_msg_data, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_msg_data, 11276, G_PKG_NAME||'.'||l_api_name, 1, p_run_id, SYSDATE);
         COMMIT;
    WHEN INVALID_ENCL_FLDR_EXCP THEN
         x_status := G_STATUS_ERROR;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_msg_data, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_msg_data, 11276, G_PKG_NAME||'.'||l_api_name, 1, p_run_id, SYSDATE);
         COMMIT;
    WHEN NO_PRIV_EXCP THEN
         x_status := G_STATUS_ERROR;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_msg_data, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_msg_data, 11276, G_PKG_NAME||'.'||l_api_name, 1, p_run_id, SYSDATE);
         COMMIT;
    WHEN MODEL_LOCKED_EXCP THEN
         x_status := G_STATUS_ERROR;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_msg_data, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_msg_data, 11276, G_PKG_NAME||'.'||l_api_name, 1, p_run_id, SYSDATE);
         COMMIT;
    WHEN FAILED_TO_LOCK_MODEL_EXCP THEN
         x_status := G_STATUS_ERROR;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_msg_data, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_msg_data, 11276, G_PKG_NAME||'.'||l_api_name, 1, p_run_id, SYSDATE);
         COMMIT;
    WHEN MODEL_UNLOCK_EXCP THEN
         x_status := G_STATUS_ERROR;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_msg_data, fnd_log.LEVEL_ERROR);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_msg_data, 11276, G_PKG_NAME||'.'||l_api_name, 1, p_run_id, SYSDATE);
         COMMIT;
    WHEN OTHERS THEN
         x_status := G_STATUS_ERROR;
         l_msg_data := SQLERRM;
         -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_msg_data, fnd_log.LEVEL_UNEXPECTED);
         INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
         VALUES (l_msg_data, 11276, G_PKG_NAME||'.'||l_api_name, 1, p_run_id, SYSDATE);
         COMMIT;
         IF (l_all_locked_models_tbl.COUNT > 0) THEN
            cz_security_pvt.unlock_model(
              p_api_version          =>   1.0,
              p_commit_flag          =>   FND_API.G_TRUE,
              p_models_to_unlock     =>   l_all_locked_models_tbl,
              x_return_status        =>   l_return_status,
              x_msg_count            =>   l_msg_count,
              x_msg_data             =>   l_msg_data);
         END IF;
END import_generic;
-----------------------------------------------------------
PROCEDURE import_generic (
  p_api_version      IN  NUMBER,
  p_run_id           IN  NUMBER,
  p_rp_folder_id     IN  NUMBER,
  p_user_id          IN  NUMBER,
  p_resp_id          IN  NUMBER,
  p_appl_id          IN  NUMBER,
  x_run_id           OUT NOCOPY NUMBER,
  x_status           OUT NOCOPY NUMBER
) IS
BEGIN
  fnd_global.apps_initialize (
    p_user_id,
    p_resp_id,
    p_appl_id
  );
  import_generic (
    p_api_version,
    p_run_id,
    p_rp_folder_id,
    x_run_id,
    x_status
  );
END import_generic;
-----------------------------------------------------------
/*#
 * This is the public interface for force unlock operations on a model in Oracle Configurator
 * @param p_api_version   Current version of the API is 1.0
 * @param p_model_id      devl_project_id of the model from cz_devl_projects table
 * @param p_unlock_references   A value of FND_API.G_TRUE indicates that the child models if any should be
 *                              force unlocked. A value of FND_API.G_FALSE indicates that only the root model
 *                              will be unlocked
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with force unlock operations on a model
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_CONFIG_MODEL
 */

PROCEDURE force_unlock_model (p_api_version        IN NUMBER,
                              p_model_id           IN NUMBER,
                              p_unlock_references  IN VARCHAR2,
                              p_init_msg_list      IN VARCHAR2,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_msg_count         OUT NOCOPY NUMBER,
                              x_msg_data          OUT NOCOPY VARCHAR2)
IS

BEGIN
   cz_security_pvt.force_unlock_model (p_api_version,
                       p_model_id,
                       p_unlock_references,
                       p_init_msg_list,
                       x_return_status,
                       x_msg_count,
                       x_msg_data);
END force_unlock_model;
---------------------------------------------------
PROCEDURE force_unlock_model (
  p_api_version        IN NUMBER,
  p_model_id           IN NUMBER,
  p_unlock_references  IN VARCHAR2,
  p_init_msg_list      IN VARCHAR2,
  p_user_id            IN NUMBER,
  p_resp_id            IN NUMBER,
  p_appl_id            IN NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2
) IS
BEGIN
  fnd_global.apps_initialize (
    p_user_id,
    p_resp_id,
    p_appl_id
  );
  force_unlock_model (
    p_api_version,
    p_model_id,
    p_unlock_references,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data
  );
END force_unlock_model;
---------------------------------------------------
/*#
 * This is the public interface for force unlock operations on a UI content template in Oracle Configurator
 * @param p_api_version   Current version of the API is 1.0
 * @param p_template_id   Template_id of the template from cz_ui_templates table
 * @param p_init_msg_list FND_API.G_TRUE if the API should initialize the FND stack, FND_API.G_FALSE if not.
 * @param x_return_status standard FND status. (ex:FND_API.G_RET_STS_SUCCESS )
 * @param x_msg_count     number of messages on the stack.
 * @param x_msg_data      standard FND OUT parameter for message.  Messages are written to the FND error stack
 * @rep:scope public
 * @rep:product CZ
 * @rep:displayname API for working with force unlock operations on a UI content template
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CZ_USER_INTERFACE*/

PROCEDURE force_unlock_template (p_api_version    IN NUMBER,
                                 p_template_id    IN NUMBER,
                                 p_init_msg_list  IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2)
IS

BEGIN
   cz_security_pvt.force_unlock_template (p_api_version,
                                 p_template_id,
                                 p_init_msg_list,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data);
END force_unlock_template;
---------------------------------------------------
PROCEDURE force_unlock_template (
  p_api_version    IN NUMBER,
  p_template_id    IN NUMBER,
  p_init_msg_list  IN VARCHAR2,
  p_user_id        IN NUMBER,
  p_resp_id        IN NUMBER,
  p_appl_id        IN NUMBER,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2
) IS
BEGIN
  fnd_global.apps_initialize (
    p_user_id,
    p_resp_id,
    p_appl_id
  );
  force_unlock_template (
    p_api_version,
    p_template_id,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data
  );
END force_unlock_template;

FUNCTION usage_id_from_usage_name (p_api_version IN  NUMBER
                          ,p_usage_name IN VARCHAR2
                          ,x_return_status        OUT NOCOPY  VARCHAR2
                          ,x_msg_count            OUT NOCOPY  NUMBER
                          ,x_msg_data             OUT NOCOPY  VARCHAR2)
RETURN NUMBER
IS
  v_usage_id NUMBER;
  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'usage_id_from_usage_name';
BEGIN
  -- standard call to check for call compatibility
  IF (NOT FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,G_PKG_NAME
                                     )) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
    SELECT model_usage_id
    INTO  v_usage_id
    FROM  CZ_MODEL_USAGES
    WHERE  LTRIM(RTRIM(UPPER(CZ_MODEL_USAGES.name))) = LTRIM(RTRIM(UPPER(p_usage_name)))
    AND   cz_model_usages.in_use = '1';

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN v_usage_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
      x_return_status:=FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('CZ', 'CZ_USG_NO_USAGE_FOUND');
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
      p_data  => x_msg_data);
      RETURN NULL;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
     RETURN NULL;
END usage_id_from_usage_name;



Function usage_id_from_usage_name (
  p_api_version          IN  NUMBER,
  p_user_id              IN  NUMBER,
  p_resp_id              IN  NUMBER,
  p_appl_id              IN  NUMBER,
  p_usage_name           IN VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2
)
RETURN NUMBER
IS
  v_usage_id NUMBER;
BEGIN
  fnd_global.apps_initialize (
    p_user_id,
    p_resp_id,
    p_appl_id
  );
  v_usage_id:=usage_id_from_usage_name (p_api_version
                          ,p_usage_name
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data);
 RETURN v_usage_id;
END usage_id_from_usage_name;
------------------------------------------------------------------------------------------------
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

PROCEDURE migrate_models(p_api_version IN  NUMBER,
                         p_request_id  IN  NUMBER,
                         p_user_id     IN  NUMBER,
                         p_resp_id     IN  NUMBER,
                         p_appl_id     IN  NUMBER,
                         p_run_id      IN  NUMBER,
                         x_run_id      OUT NOCOPY NUMBER,
                         x_status      OUT NOCOPY VARCHAR2
                        ) IS

  l_api_name      CONSTANT VARCHAR2(30) := 'migrate_models';
  l_api_version   CONSTANT NUMBER := 1.0;
  l_errbuf        VARCHAR2(2000);
BEGIN

  IF(NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME))THEN

    RAISE G_INCOMPATIBLE_API;
  END IF;

  cz_model_migration_pvt.migrate_models(p_request_id, p_user_id, p_resp_id, p_appl_id, p_run_id, x_run_id, x_status);

EXCEPTION
  WHEN G_INCOMPATIBLE_API THEN
    x_status := G_STATUS_ERROR;
    l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
    -- cz_utils.log_report(G_PKG_NAME, l_api_name, null, l_errbuf, fnd_log.LEVEL_ERROR);
    INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime)
    VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, x_run_id, SYSDATE);
    COMMIT;
END;
---------------------------------------------------------------------------------------
-- added by jonatara:bug6375827
PROCEDURE create_publication_request (
   p_api_version       IN NUMBER,
   p_model_id          IN NUMBER,
   p_ui_def_id         IN NUMBER,
   p_publication_mode  IN VARCHAR2,              -- DEFAULT 'P'
   p_server_id         IN NUMBER,
   p_appl_id_tbl       IN CZ_PB_MGR.t_ref,
   p_usg_id_tbl        IN CZ_PB_MGR.t_ref,       -- DEFAULT -1 (ie., 'Any Usage')
   p_lang_tbl          IN CZ_PB_MGR.t_lang_code, -- DEFAULT 'US'
   p_start_date        IN DATE,                  -- DEFAULT CZ_UTILS.epoch_begin
   p_end_date          IN DATE,                  -- DEFAULT CZ_UTILS.CZ_UTILS.epoch_end
   x_publication_id    OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
 ) IS
   l_api_name    CONSTANT VARCHAR2(30) := 'create_publication_request';
   l_api_version CONSTANT NUMBER := 1.0;
   l_status      VARCHAR2(3);
   l_errbuf      VARCHAR2(2000);

 BEGIN

   IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
	 RAISE G_INCOMPATIBLE_API;
   END IF;
   cz_pb_mgr.create_publication_request(
	 p_model_id,
	 p_ui_def_id,
	 p_publication_mode,
	 p_server_id,
	 p_appl_id_tbl,
	 p_usg_id_tbl,
	 p_lang_tbl,
	 p_start_date,
	 p_end_date,
	 x_publication_id,
	 l_status,
	 x_msg_count,
	 x_msg_data
   );
   IF l_status = FND_API.G_RET_STS_SUCCESS THEN
	 x_return_status := G_STATUS_SUCCESS;
   ELSE
	 x_return_status := G_STATUS_ERROR;
   END IF;
 EXCEPTION
   WHEN G_INCOMPATIBLE_API THEN
	 x_return_status := G_STATUS_ERROR;
	 l_errbuf := CZ_UTILS.GET_TEXT('CZ_MOP_API_VERSION_ERR', 'CODE_VERSION', l_api_version, 'IN_VERSION', p_api_version);
	 INSERT INTO cz_db_logs (message, statuscode, caller, urgency, logtime)
	 VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, SYSDATE);
	 COMMIT;
   WHEN OTHERS THEN
	 x_return_status := G_STATUS_ERROR;
	 l_errbuf := SQLERRM;
	 INSERT INTO cz_db_logs (message, statuscode, caller, urgency, logtime)
	 VALUES (l_errbuf, 11276, G_PKG_NAME||'.'||l_api_name, 1, SYSDATE);
	 COMMIT;
 END create_publication_request;

 ------------------------------------------------------------------------------------------------
 PROCEDURE create_publication_request (
   p_api_version       IN NUMBER,
   p_model_id          IN NUMBER,
   p_ui_def_id         IN NUMBER,
   p_publication_mode  IN VARCHAR2,              -- DEFAULT 'P'
   p_server_id         IN NUMBER,
   p_appl_id_tbl       IN CZ_PB_MGR.t_ref,
   p_usg_id_tbl        IN CZ_PB_MGR.t_ref,       -- DEFAULT -1 (ie., 'Any Usage')
   p_lang_tbl          IN CZ_PB_MGR.t_lang_code, -- DEFAULT 'US'
   p_start_date        IN DATE,                  -- DEFAULT CZ_UTILS.epoch_begin
   p_end_date          IN DATE,                  -- DEFAULT CZ_UTILS.CZ_UTILS.epoch_end
   p_user_id           IN NUMBER,
   p_resp_id           IN NUMBER,
   p_appl_id           IN NUMBER,
   x_publication_id    OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
 ) IS
   l_api_name    CONSTANT VARCHAR2(30) := 'create_publication_request';
   l_api_version CONSTANT NUMBER := 1.0;
   l_status      VARCHAR2(3);
   l_errbuf      VARCHAR2(2000);
 BEGIN
   fnd_global.apps_initialize (p_user_id, p_resp_id, p_appl_id);
   create_publication_request (
	 p_api_version,
	 p_model_id,
	 p_ui_def_id,
	 p_publication_mode,
	 p_server_id,
	 p_appl_id_tbl,
	 p_usg_id_tbl,
	 p_lang_tbl,
	 p_start_date,
	 p_end_date,
	 x_publication_id,
	 x_return_status,
	 x_msg_count,
	 x_msg_data
   );
 END create_publication_request;
 ------------------------------------------------------------------------------------------------
END CZ_modelOperations_pub;

/
