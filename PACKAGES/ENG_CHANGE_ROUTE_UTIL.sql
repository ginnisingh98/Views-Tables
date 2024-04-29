--------------------------------------------------------
--  DDL for Package ENG_CHANGE_ROUTE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_ROUTE_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGURTES.pls 115.6 2003/10/14 23:09:46 mkimizuk ship $ */

--
--  Constant Variables :
--


/********************************************************************
* Debug APIs    : Open_Debug_Session, Close_Debug_Session,
*                 Write_Debug
* Parameters IN :
* Parameters OUT:
* Purpose       : These PROCEDUREs are for test and debug
*********************************************************************/
-- Open_Debug_Session
PROCEDURE Open_Debug_Session
(  p_output_dir IN VARCHAR2 := NULL
,  p_file_name  IN VARCHAR2 := NULL
);

-- Close Debug_Session
PROCEDURE Close_Debug_Session ;

-- Write Debug Message
PROCEDURE Write_Debug
(  p_debug_message      IN  VARCHAR2 ) ;


/********************************************************************
* API Type      : Refresh Route API
* Scope         : Oracle (for Oracle Applications development use only)
* Purpose       : This api will create another instance of Route specified
*                 as param and set original Route as History
*********************************************************************/
PROCEDURE REFRESH_ROUTE(
  X_NEW_ROUTE_ID   OUT NOCOPY NUMBER,
  P_ROUTE_ID       IN NUMBER,
  P_USER_ID        IN NUMBER   := NULL ,
  P_API_CALLER     IN VARCHAR2 := NULL
) ;

/********************************************************************
* API Type      : Private APIs
* Purpose       : Those APIs are private
*********************************************************************/
PROCEDURE COPY_ROUTE (
  X_TO_ROUTE_ID    IN OUT NOCOPY NUMBER ,
  P_FROM_ROUTE_ID  IN NUMBER ,
  P_USER_ID        IN NUMBER   := NULL ,
  P_API_CALLER     IN VARCHAR2 := NULL
) ;



/********************************************************************
* API Type      : Private Table Hander APIs
* Purpose       : Those APIs are private
*                 Table Hander for TL Entity Object: ENG_CHANGE_ROUTES_VL
*                 PROCEDURE INSERT_ROW;
*                 PROCEDURE LOCK_ROW;
*                 PROCEDURE UPDATE_ROW;
*                 PROCEDURE DELETE_ROW;
*********************************************************************/
PROCEDURE INSERT_ROW (
  X_ROWID                     IN OUT NOCOPY VARCHAR2,
  X_ROUTE_ID                  IN NUMBER,
  X_ROUTE_NAME                IN VARCHAR2,
  X_ROUTE_DESCRIPTION         IN VARCHAR2,
  X_TEMPLATE_FLAG             IN VARCHAR2,
  X_OWNER_ID                  IN NUMBER,
  X_FIXED_FLAG                IN VARCHAR2,
  X_OBJECT_NAME               IN VARCHAR2,
  X_OBJECT_ID1                IN NUMBER,
  X_OBJECT_ID2                IN NUMBER,
  X_OBJECT_ID3                IN NUMBER,
  X_OBJECT_ID4                IN NUMBER,
  X_OBJECT_ID5                IN NUMBER,
  X_APPLIED_TEMPLATE_ID       IN NUMBER,
  X_WF_ITEM_TYPE              IN VARCHAR2,
  X_WF_ITEM_KEY               IN VARCHAR2,
  X_WF_PROCESS_NAME           IN VARCHAR2,
  X_STATUS_CODE               IN VARCHAR2,
  X_ROUTE_START_DATE          IN DATE,
  X_ROUTE_END_DATE            IN DATE,
  X_CHANGE_REVISION           IN VARCHAR2,
  X_CREATION_DATE             IN DATE,
  X_CREATED_BY                IN NUMBER,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER,
  X_ATTRIBUTE_CATEGORY        IN VARCHAR2,
  X_ATTRIBUTE1                IN VARCHAR2,
  X_ATTRIBUTE2                IN VARCHAR2,
  X_ATTRIBUTE3                IN VARCHAR2,
  X_ATTRIBUTE4                IN VARCHAR2,
  X_ATTRIBUTE5                IN VARCHAR2,
  X_ATTRIBUTE6                IN VARCHAR2,
  X_ATTRIBUTE7                IN VARCHAR2,
  X_ATTRIBUTE8                IN VARCHAR2,
  X_ATTRIBUTE9                IN VARCHAR2,
  X_ATTRIBUTE10               IN VARCHAR2,
  X_ATTRIBUTE11               IN VARCHAR2,
  X_ATTRIBUTE12               IN VARCHAR2,
  X_ATTRIBUTE13               IN VARCHAR2,
  X_ATTRIBUTE14               IN VARCHAR2,
  X_ATTRIBUTE15               IN VARCHAR2,
  X_REQUEST_ID                IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_CLASSIFICATION_CODE       IN VARCHAR2,
  X_ROUTE_TYPE_CODE           IN VARCHAR2
);

PROCEDURE LOCK_ROW (
  X_ROUTE_ID                  IN NUMBER,
  X_ROUTE_NAME                IN VARCHAR2,
  X_ROUTE_DESCRIPTION         IN VARCHAR2,
  X_TEMPLATE_FLAG             IN VARCHAR2,
  X_OWNER_ID                  IN NUMBER,
  X_FIXED_FLAG                IN VARCHAR2,
  X_OBJECT_NAME               IN VARCHAR2,
  X_OBJECT_ID1                IN NUMBER,
  X_OBJECT_ID2                IN NUMBER,
  X_OBJECT_ID3                IN NUMBER,
  X_OBJECT_ID4                IN NUMBER,
  X_OBJECT_ID5                IN NUMBER,
  X_APPLIED_TEMPLATE_ID       IN NUMBER,
  X_WF_ITEM_TYPE              IN VARCHAR2,
  X_WF_ITEM_KEY               IN VARCHAR2,
  X_WF_PROCESS_NAME           IN VARCHAR2,
  X_STATUS_CODE               IN VARCHAR2,
  X_ROUTE_START_DATE          IN DATE,
  X_ROUTE_END_DATE            IN DATE,
  X_CHANGE_REVISION           IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY        IN VARCHAR2,
  X_ATTRIBUTE1                IN VARCHAR2,
  X_ATTRIBUTE2                IN VARCHAR2,
  X_ATTRIBUTE3                IN VARCHAR2,
  X_ATTRIBUTE4                IN VARCHAR2,
  X_ATTRIBUTE5                IN VARCHAR2,
  X_ATTRIBUTE6                IN VARCHAR2,
  X_ATTRIBUTE7                IN VARCHAR2,
  X_ATTRIBUTE8                IN VARCHAR2,
  X_ATTRIBUTE9                IN VARCHAR2,
  X_ATTRIBUTE10               IN VARCHAR2,
  X_ATTRIBUTE11               IN VARCHAR2,
  X_ATTRIBUTE12               IN VARCHAR2,
  X_ATTRIBUTE13               IN VARCHAR2,
  X_ATTRIBUTE14               IN VARCHAR2,
  X_ATTRIBUTE15               IN VARCHAR2,
  X_REQUEST_ID                IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_CLASSIFICATION_CODE       IN VARCHAR2,
  X_ROUTE_TYPE_CODE           IN VARCHAR2
  ) ;


PROCEDURE UPDATE_ROW (
  X_ROUTE_ID                  IN NUMBER,
  X_ROUTE_NAME                IN VARCHAR2,
  X_ROUTE_DESCRIPTION         IN VARCHAR2,
  X_TEMPLATE_FLAG             IN VARCHAR2,
  X_OWNER_ID                  IN NUMBER,
  X_FIXED_FLAG                IN VARCHAR2,
  X_OBJECT_NAME               IN VARCHAR2,
  X_OBJECT_ID1                IN NUMBER,
  X_OBJECT_ID2                IN NUMBER,
  X_OBJECT_ID3                IN NUMBER,
  X_OBJECT_ID4                IN NUMBER,
  X_OBJECT_ID5                IN NUMBER,
  X_APPLIED_TEMPLATE_ID       IN NUMBER,
  X_WF_ITEM_TYPE              IN VARCHAR2,
  X_WF_ITEM_KEY               IN VARCHAR2,
  X_WF_PROCESS_NAME           IN VARCHAR2,
  X_STATUS_CODE               IN VARCHAR2,
  X_ROUTE_START_DATE          IN DATE,
  X_ROUTE_END_DATE            IN DATE,
  X_CHANGE_REVISION           IN VARCHAR2,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER,
  X_ATTRIBUTE_CATEGORY        IN VARCHAR2,
  X_ATTRIBUTE1                IN VARCHAR2,
  X_ATTRIBUTE2                IN VARCHAR2,
  X_ATTRIBUTE3                IN VARCHAR2,
  X_ATTRIBUTE4                IN VARCHAR2,
  X_ATTRIBUTE5                IN VARCHAR2,
  X_ATTRIBUTE6                IN VARCHAR2,
  X_ATTRIBUTE7                IN VARCHAR2,
  X_ATTRIBUTE8                IN VARCHAR2,
  X_ATTRIBUTE9                IN VARCHAR2,
  X_ATTRIBUTE10               IN VARCHAR2,
  X_ATTRIBUTE11               IN VARCHAR2,
  X_ATTRIBUTE12               IN VARCHAR2,
  X_ATTRIBUTE13               IN VARCHAR2,
  X_ATTRIBUTE14               IN VARCHAR2,
  X_ATTRIBUTE15               IN VARCHAR2,
  X_REQUEST_ID                IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_CLASSIFICATION_CODE       IN VARCHAR2,
  X_ROUTE_TYPE_CODE           IN VARCHAR2
) ;

PROCEDURE DELETE_ROW (
  X_ROUTE_ID                  IN NUMBER
);

PROCEDURE ADD_LANGUAGE;

PROCEDURE CLOSE_LOB(lob_loc IN OUT NOCOPY CLOB) ;

PROCEDURE CREATE_INSTANCE_SET_SQL
(
 p_Object_Values          IN VARCHAR2,
 x_User_Group_Flag        IN VARCHAR2,
 x_Complete_query         OUT NOCOPY CLOB
);



/********************************************************************
* API Type      : Public APIs
* Purpose       : APIS to create Instance set query
*********************************************************************/





END Eng_Change_Route_Util ;

 

/
