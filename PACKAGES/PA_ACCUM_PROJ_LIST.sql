--------------------------------------------------------
--  DDL for Package PA_ACCUM_PROJ_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACCUM_PROJ_LIST" AUTHID CURRENT_USER AS
--$Header: PAPRJACS.pls 120.1 2005/08/19 16:44:24 mwasowic noship $

--  Package Globals ----------------------------

   G_LAST_UPDATED_BY	        NUMBER(15) 	:= FND_GLOBAL.USER_ID;
   G_LAST_UPDATE_DATE        	DATE       	:= SYSDATE;
   G_CREATION_DATE           	DATE       	:= SYSDATE;
   G_CREATED_BY              	NUMBER(15) 	:= FND_GLOBAL.USER_ID;
   G_LAST_UPDATE_LOGIN       	NUMBER(15) 	:= FND_GLOBAL.LOGIN_ID;
   G_REQUEST_ID                 NUMBER(15)      := FND_GLOBAL.CONC_REQUEST_ID;

   G_PKG_NAME                   CONSTANT  VARCHAR2(30) := ' PA_ACCUM_PROJ_LIST';


--  Procedures --------------------------------

PROCEDURE Insert_Accum
(p_project_id			IN	NUMBER
, x_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, x_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Upgrade_Accum
(p_project_id			IN	NUMBER
, x_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, x_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


END pa_accum_proj_list;
 

/
