--------------------------------------------------------
--  DDL for Package PA_WORKPLAN_AMG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WORKPLAN_AMG_PUB" AUTHID DEFINER AS
/* $Header: PAPMWKPS.pls 115.1 2002/12/02 20:29:27 mwasowic noship $*/

-- ----------------------------------------------------------------------------------------
-- 	Standard Globals
-- ----------------------------------------------------------------------------------------

-- WHO Globals

   G_LAST_UPDATED_BY	NUMBER(15) 	:= FND_GLOBAL.USER_ID;
   G_LAST_UPDATE_DATE   DATE       	:= SYSDATE;
   G_CREATION_DATE      DATE       	:= SYSDATE;
   G_CREATED_BY         NUMBER(15) 	:= FND_GLOBAL.USER_ID;
   G_LAST_UPDATE_LOGIN  NUMBER(15) 	:= FND_GLOBAL.LOGIN_ID;

-- Local Package Globals

   G_PKG_NAME             CONSTANT  VARCHAR2(30) := ' PA_WORKPLAN_AMG_PUB';
   G_API_VERSION_NUMBER   CONSTANT  NUMBER 	 := 1.0;

   ROW_ALREADY_LOCKED	EXCEPTION;
   PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);


-- -----------------------------------------------------------------------------------------
--	Procedures
-- -----------------------------------------------------------------------------------------


PROCEDURE change_structure_status
(p_api_version_number           IN      NUMBER
, p_init_msg_list               IN      VARCHAR2        := 'F'
, p_commit                      IN      VARCHAR2        := 'F'
, p_return_status               OUT NOCOPY     VARCHAR2
, p_msg_count                   OUT NOCOPY     NUMBER
, p_msg_data                    OUT NOCOPY     VARCHAR2
, p_structure_version_id        IN      NUMBER
, p_pa_project_id               IN      NUMBER
, p_status_code                 IN      VARCHAR2
, p_published_struct_ver_id     OUT NOCOPY     NUMBER

);

PROCEDURE baseline_structure
(p_api_version_number           IN      NUMBER
, p_init_msg_list               IN      VARCHAR2        := 'F'
, p_commit                      IN      VARCHAR2        := 'F'
, p_return_status               OUT NOCOPY     VARCHAR2
, p_msg_count                   OUT NOCOPY     NUMBER
, p_msg_data                    OUT NOCOPY     VARCHAR2
, p_structure_version_id        IN      NUMBER
, p_pa_project_id               IN      NUMBER

);

END pa_workplan_amg_pub;

 

/
