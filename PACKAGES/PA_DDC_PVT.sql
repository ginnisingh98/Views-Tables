--------------------------------------------------------
--  DDL for Package PA_DDC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DDC_PVT" AUTHID CURRENT_USER AS
--$Header: PAXUDDCS.pls 120.1 2005/08/19 17:22:01 mwasowic noship $

--  Package Globals ----------------------------

   G_LAST_UPDATED_BY	        NUMBER(15) 	:= FND_GLOBAL.USER_ID;
   G_LAST_UPDATE_DATE        	DATE       	:= SYSDATE;
   G_CREATION_DATE           	DATE       	:= SYSDATE;
   G_CREATED_BY              	NUMBER(15) 	:= FND_GLOBAL.USER_ID;
   G_LAST_UPDATE_LOGIN       	NUMBER(15) 	:= FND_GLOBAL.LOGIN_ID;
   G_REQUEST_ID                 NUMBER(15)      := FND_GLOBAL.CONC_REQUEST_ID;

   G_PKG_NAME                   CONSTANT  VARCHAR2(30) := ' PA_DDC_PVT';


--  Procedures --------------------------------

PROCEDURE Create_View_DDL
(p_view_name    		IN	VARCHAR2
, x_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, x_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Update_Ak_Item_Long_Label
(x_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, x_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);



END pa_ddc_pvt;
 

/
