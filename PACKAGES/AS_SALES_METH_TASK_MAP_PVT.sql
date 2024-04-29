--------------------------------------------------------
--  DDL for Package AS_SALES_METH_TASK_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_METH_TASK_MAP_PVT" AUTHID CURRENT_USER AS
/* $Header: asxsmtks.pls 120.1 2005/06/05 22:52:59 appldev  $ */
---------------------------------------------------------------------------
--Define Global Variables--
---------------------------------------------------------------------------
G_PKG_NAME      CONSTANT        VARCHAR2(30):='AS_SALES_METH_TASK_PVT';
---------------------------------------------------------------------------
--Procedure to Create a Sales Meth Task Mapping
Procedure  CREATE_SALES_METH_TASK_MAP
  (
  P_API_VERSION             	IN  NUMBER,
    P_INIT_MSG_LIST           	IN  VARCHAR2    DEFAULT fnd_api.g_false,
    P_COMMIT                  	IN  VARCHAR2    DEFAULT fnd_api.g_false,
    P_VALIDATE_LEVEL          	IN  VARCHAR2    DEFAULT fnd_api.g_valid_level_full,
    P_SALES_STAGE_ID  	    	IN  NUMBER,
    P_SALES_METHODOLOGY_ID    	IN  NUMBER ,
    P_SOURCE_OBJECT_ID        	IN  NUMBER ,
     P_SOURCE_OBJECT_TYPE_CODE  IN  VARCHAR2 ,
     P_SOURCE_OBJECT_NAME       IN  VARCHAR2 ,
    P_TASK_ID              	IN  NUMBER ,
    P_TASK_TEMPLATE_ID          IN  NUMBER ,
    P_TASK_TEMPLATE_GROUP_ID	IN  NUMBER,
    X_RETURN_STATUS            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_MSG_COUNT                OUT NOCOPY /* file.sql.39 change */ NUMBER,
    X_MSG_DATA                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2);
--Procedure to Upate Sales Methodology
Procedure  UPDATE_SALES_METH_TASK_MAP
  (
  P_API_VERSION             	IN  NUMBER,
    P_INIT_MSG_LIST           	IN  VARCHAR2    DEFAULT fnd_api.g_false,
    P_COMMIT                  	IN  VARCHAR2    DEFAULT fnd_api.g_false,
    P_VALIDATE_LEVEL          	IN  VARCHAR2    DEFAULT fnd_api.g_valid_level_full,
    P_SALES_STAGE_ID  	    	IN  NUMBER,
    P_SALES_METHODOLOGY_ID    	IN  NUMBER ,
    P_SOURCE_OBJECT_ID        	IN  NUMBER ,
    P_SOURCE_OBJECT_TYPE_CODE  IN  VARCHAR2 ,
    P_SOURCE_OBJECT_NAME       IN  VARCHAR2 ,
    P_TASK_ID              	IN  NUMBER ,
    P_TASK_TEMPLATE_ID          IN  NUMBER ,
    P_TASK_TEMPLATE_GROUP_ID	IN  NUMBER,
    X_RETURN_STATUS            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_MSG_COUNT                OUT NOCOPY /* file.sql.39 change */ NUMBER,
    X_MSG_DATA                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2);
--Procedure to Delete Sales Methodology
Procedure  DELETE_SALES_METH_TASK_MAP
 (
 P_API_VERSION             IN  NUMBER,
 P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
 P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
 P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
 P_SALES_METHODOLOGY_ID    IN  NUMBER,
  P_SOURCE_OBJECT_ID        	IN  NUMBER ,
  P_SOURCE_OBJECT_TYPE_CODE  IN  VARCHAR2 ,
     P_SOURCE_OBJECT_NAME       IN  VARCHAR2 ,
   P_SALES_STAGE_ID  	    	IN  NUMBER,
P_TASK_TEMPLATE_ID	IN  NUMBER,
P_TASK_TEMPLATE_GROUP_ID	IN  NUMBER,
 X_RETURN_STATUS           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 X_MSG_COUNT               OUT NOCOPY /* file.sql.39 change */ NUMBER,
 X_MSG_DATA                OUT NOCOPY /* file.sql.39 change */ VARCHAR2);
END AS_SALES_METH_TASK_MAP_PVT;


 

/
