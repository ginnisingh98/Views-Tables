--------------------------------------------------------
--  DDL for Package FEM_LEDGERS_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_LEDGERS_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_ledger_utl.pls 120.0 2006/05/09 14:42:10 rflippo noship $ */

------------------------
--  Package Constants --
------------------------
pc_pkg_name            CONSTANT VARCHAR2(30) := 'fem_ledger_util_pkg';

pc_api_version         CONSTANT  NUMBER       := 1.0;
pc_ret_sts_success        CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_success;
pc_ret_sts_error          CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_error;
pc_ret_sts_unexp_error    CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_unexp_error;

pc_resp_app_id            CONSTANT NUMBER := FND_GLOBAL.RESP_APPL_ID;
pc_last_update_login      CONSTANT NUMBER := FND_GLOBAL.Login_Id;
pc_user_id                CONSTANT NUMBER := FND_GLOBAL.USER_ID;

pc_object_version_number  CONSTANT NUMBER := 1;

pc_log_level_statement    CONSTANT  NUMBER  := fnd_log.level_statement;
pc_log_level_procedure    CONSTANT  NUMBER  := fnd_log.level_procedure;
pc_log_level_event        CONSTANT  NUMBER  := fnd_log.level_event;
pc_log_level_exception    CONSTANT  NUMBER  := fnd_log.level_exception;
pc_log_level_error        CONSTANT  NUMBER  := fnd_log.level_error;
pc_log_level_unexpected   CONSTANT  NUMBER  := fnd_log.level_unexpected;

pc_false            CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
pc_true             CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;

------------------
--  Subprograms --
------------------

PROCEDURE Get_Calendar (
   p_api_version                 IN  NUMBER DEFAULT 1.0,
   p_init_msg_list               IN  VARCHAR2 DEFAULT pc_false,
   p_commit                      IN  VARCHAR2 DEFAULT pc_false,
   p_encoded                     IN  VARCHAR2 DEFAULT pc_true,
   p_ledger_id                   IN  NUMBER,
   x_calendar_id                 OUT NOCOPY NUMBER,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);


PROCEDURE Validate_OA_Params (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_encoded         IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);

END FEM_LEDGERS_UTIL_PKG;

 

/
