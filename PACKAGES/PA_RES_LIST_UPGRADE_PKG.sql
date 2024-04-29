--------------------------------------------------------
--  DDL for Package PA_RES_LIST_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RES_LIST_UPGRADE_PKG" AUTHID CURRENT_USER as
/* $Header: PARTPLRS.pls 120.0 2005/05/30 22:29:46 appldev noship $ */


procedure RES_LIST_TO_PLAN_RES_LIST(
  P_RESOURCE_LIST_ID          IN pa_resource_lists_all_bg.resource_list_id%type,
  p_commit                    IN    VARCHAR2          := FND_API.G_FALSE,
  p_init_msg_list             IN    VARCHAR2          := FND_API.G_FALSE,
  X_RETURN_STATUS             OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                 OUT  NOCOPY NUMBER,
  X_MSG_DATA                  OUT  NOCOPY VARCHAR2);
end PA_RES_LIST_UPGRADE_PKG;

 

/
