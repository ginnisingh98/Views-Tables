--------------------------------------------------------
--  DDL for Package Body INV_CONSIGN_NOTIF_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CONSIGN_NOTIF_UTL" AS
-- $Header: INVCNTFB.pls 120.0 2005/05/25 05:05:56 appldev noship $ --
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCNTFB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Consigned Inventory Diagnostics Send Notification to Buyer API     |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Send_Notification                                                 |
--|                                                                       |
--| HISTORY                                                               |
--|     10/06/03 vma      Created                                         |
--|     01/26/04 vma      Bug 3396257: Added code to handled the case     |
--|                       where a buyer (agent) is not assigned to a      |
--|                       user.                                           |
--+========================================================================

--===================
-- CONSTANTS
--===================
G_MODULE_PREFIX   CONSTANT VARCHAR2(50) := 'inv.plsql.' || G_PKG_NAME || '.';
G_RET_STS_SUCCESS CONSTANT VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
G_USER_ID         CONSTANT NUMBER       := FND_GLOBAL.user_id;
G_LOGIN_ID        CONSTANT NUMBER       := FND_GLOBAL.login_id;

--=============================================
-- GLOBAL VARIABLES
--=============================================
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE  : Call_Workflow_Notification   PRIVATE
--
-- PARAMETERS :
--   p_item_type         IN
--   p_item_key          IN
--   p_activity_name     IN
--   p_user_name         IN
--   p_agent_id          IN
--   p_language          IN
--   x_notification_id   OUT
--   x_notification_date OUT
--   x_return_status     OUT
--
-- COMMENT    : Call Workflow to send Consigned Diagnostics notification
--              to a user.
--
-- CHANGE HISTORY :
--   10/06/03 vma      Created.
--=========================================================================
PROCEDURE Call_Workflow_Notification(
  p_user_name         IN  fnd_user.user_name%TYPE,
  p_agent_id          IN  mtl_consigned_diag_errors.agent_id%TYPE,
  p_lang_code         IN  fnd_languages.language_code%TYPE,
  x_notification_id   OUT NOCOPY mtl_consigned_diag_errors.notification_id%TYPE,
  x_notification_date OUT NOCOPY mtl_consigned_diag_errors.last_notification_date%TYPE,
  x_return_status     OUT NOCOPY VARCHAR2
)
IS

l_api_name        VARCHAR2(30) := 'Call_Workflow_Notification';
l_item_type       VARCHAR2(8)  := 'INVCDNTF';
l_process_name    VARCHAR2(25) := 'CONSIGN_DIAG_NOTIF_PROC';
l_activity_name   VARCHAR2(18) := 'CONSIGN_DIAG_NOTIF';
l_item_key_prefix VARCHAR2(17) := 'CONSIGN_DIAG_NTF_';
l_item_key_s      NUMBER;
l_item_key        VARCHAR2(240);
l_agent_name      per_all_people_f.full_name%TYPE;

BEGIN

  IF g_fnd_debug = 'Y' THEN
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     THEN
        FND_LOG.string( FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Entry');
     END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- send notification to the user
  SELECT mtl_consigned_diag_notif_s.NEXTVAL INTO l_item_key_s FROM DUAL;
  l_item_key := l_item_key_prefix || to_char(l_item_key_s);


  SELECT full_name
    INTO l_agent_name
    FROM per_all_people_f
   WHERE person_id = p_agent_id
     AND TRUNC(SYSDATE) BETWEEN effective_start_date AND effective_end_date;

  IF g_fnd_debug = 'Y' THEN
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Create workflow process');
     END IF;
  END IF;

  wf_engine.CreateProcess(itemtype  => l_item_type,
                          itemkey   => l_item_key,
                          process   => l_process_name);

  wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey  => l_item_key,
                            aname    => 'USER_NAME',
                            avalue   => p_user_name);

  wf_engine.SetItemAttrNumber(itemtype => l_item_type,
                            itemkey  => l_item_key,
                            aname    => 'AGENT_ID',
                            avalue   => p_agent_id);

  wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey  => l_item_key,
                            aname    => 'LANG_CODE',
                            avalue   => p_lang_code);

  wf_engine.SetItemAttrText(itemtype => l_item_type,
                            itemkey  => l_item_key,
                            aname    => 'BUYER',
                            avalue   => l_agent_name);

  wf_engine.StartProcess(itemtype  => l_item_type,
                         itemkey   => l_item_key);

  IF g_fnd_debug = 'Y' THEN
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Retrieve Notification ID and Sent date');
     END IF;
  END IF;

  -- get notification_id and last_notification_date
  SELECT wfn.notification_id, wfn.begin_date
    INTO x_notification_id, x_notification_date
    FROM wf_item_activity_statuses_v was, wf_notifications wfn
   WHERE was.item_type       = l_item_type
     AND was.activity_name   = l_activity_name
     AND was.item_key        = l_item_key
     AND wfn.notification_id = was.notification_id;

  IF g_fnd_debug = 'Y' THEN
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Exit');
     END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   IF g_fnd_debug = 'Y' THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Unexpected exception for user name ' || p_user_name ||
                    ' agent_id ' || p_agent_id || ' language ' || p_lang_code);
     END IF;
   END IF;

END Call_Workflow_Notification;


--==========================================================================
--  PROCEDURE NAME:  Send_Notification
--
--  DESCRIPTION:     Send Workflow Notification to buyers that have Consigned
--                   Inventory Diagnostics errors to resolve.
--
--  PARAMETERS:
--     p_api_version    REQUIRED  API version
--     p_init_msg_list  REQUIRED  FND_API.G_TRUE to reset the message list
--                                FND_API.G_FALSE to not reset it.
--                                If pass NULL, it means FND_API.G_FALSE.
--     p_commit         REQUIRED  FND_API.G_TRUE to have API commit the change
--                                FND_API.G_FALSE to not commit the change.
--                                If pass NULL, it means FND_API.G_FALSE.
--     x_return_status  REQUIRED  Value can be
--                                  FND_API.G_RET_STS_SUCCESS
--                                  FND_API.G_RET_STS_ERROR
--                                  FND_API.G_RET_STS_UNEXP_ERROR
--     x_msg_count      REQUIRED  Number of messages on the message list
--     x_msg_data       REQUIRED  Return message data if message count is 1
--     p_notification_resend_days
--                      REQUIRED  Number of days elapsed before resending
--                                notification to a buyer
--
-- COMMENT    : Call Workflow to send Consigned Diagnostics notification
--              to buyers.
--
-- CHANGE HISTORY :
--   10/06/03 vma      Created.
--=========================================================================
PROCEDURE Send_Notification
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2
, p_commit                   IN  VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_notification_resend_days IN  NUMBER
)
IS

l_api_name    CONSTANT VARCHAR2(30) := 'Send_Notification';
l_api_version CONSTANT NUMBER := 1.0;

l_agent_id  mtl_consigned_diag_errors.agent_id%TYPE;
l_user_name fnd_user.user_name%TYPE;
l_language  fnd_languages.nls_language%TYPE;
l_lang_code fnd_languages.language_code%TYPE;

TYPE notif_id_tbl_type IS TABLE OF
  mtl_consigned_diag_errors.notification_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE notif_date_tbl_type IS TABLE OF
  mtl_consigned_diag_errors.last_notification_date%TYPE
  INDEX BY BINARY_INTEGER;

TYPE notif_status_tbl_type IS TABLE OF VARCHAR2(20)
  INDEX BY BINARY_INTEGER;

TYPE agent_id_tbl_type IS TABLE OF
  MTL_CONSIGNED_DIAG_ERRORS.agent_id%TYPE
  INDEX BY BINARY_INTEGER;

agent_id_tbl     agent_id_tbl_type;
notif_id_tbl     notif_id_tbl_type;
notif_date_tbl   notif_date_tbl_type;
notif_status_tbl notif_status_tbl_type;

BEGIN

  SAVEPOINT Send_Notification_PUB;

  IF g_fnd_debug = 'Y' THEN
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                   , G_MODULE_PREFIX || l_api_name || '.invoked'
                   , 'Entry');
     END IF;
  END IF;

  IF FND_API.To_Boolean(NVL(p_init_msg_list, FND_API.G_FALSE)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT DISTINCT agent_id BULK COLLECT INTO agent_id_tbl
    FROM mtl_consigned_diag_errors
   WHERE agent_id IS NOT NULL
     AND (notification_id IS NULL
      OR last_notification_date + p_notification_resend_days <= SYSDATE);

  -- send notification to the buyer
  FOR i IN agent_id_tbl.FIRST..agent_id_tbl.LAST
  LOOP
    l_agent_id := agent_id_tbl(i);

    -- Bug #3396257: Initialize tbl for when an agent is not
    -- assigned to any user.
    notif_status_tbl(i) := NULL;
    notif_id_tbl(i)     := NULL;
    notif_date_tbl(i)   := NULL;

    FOR rec IN (SELECT user_name, user_id
                  FROM fnd_user
                 WHERE employee_id = l_agent_id)
    LOOP
      -- get user's preferred lanaguage
      l_language := FND_PROFILE.Value_Specific('ICX_LANGUAGE', rec.user_id);

      IF l_language IS NOT NULL THEN

        SELECT language_code
          INTO l_lang_code
          FROM FND_LANGUAGES
         WHERE nls_language = l_language;

        Call_Workflow_Notification(
           p_user_name          => rec.user_name
         , p_agent_id           => l_agent_id
         , p_lang_code          => l_lang_code
         , x_notification_id    => notif_id_tbl(i)
         , x_notification_date  => notif_date_tbl(i)
         , x_return_status      => notif_status_tbl(i));

      ELSE
        IF g_fnd_debug = 'Y' THEN
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
           THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                       , G_MODULE_PREFIX || l_api_name || '.invoked'
                       , 'Preferred language for user ' || rec.user_name ||
		         ', user_id ' || rec.user_id || ' not found.');
           END IF;
        END IF;
      END IF;

    END LOOP;

  END LOOP;

  -- update last_notification_date and notification_id
  FORALL j IN agent_id_tbl.FIRST..agent_id_tbl.LAST
    UPDATE mtl_consigned_diag_errors
       SET notification_id        = notif_id_tbl(j),
           last_notification_date = notif_date_tbl(j),
           last_update_date       = SYSDATE,
           last_updated_by        = G_USER_ID,
           last_update_login      = G_LOGIN_ID
     WHERE notif_status_tbl(j)    = G_RET_STS_SUCCESS
       AND agent_id               = agent_id_tbl(j);

  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data);
  IF g_fnd_debug = 'Y' THEN
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.invoked'
                  , 'Exit');
     END IF;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK TO Send_Notification_PUB;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data);

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_fnd_debug = 'Y') THEN
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
     THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '.others_exception'
                    , 'Exception');
      END IF;
    END IF;

END Send_Notification;

END INV_CONSIGN_NOTIF_UTL;

/
