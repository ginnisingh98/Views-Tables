--------------------------------------------------------
--  DDL for Package ENG_CHANGE_ROUTE_ASSOCS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_ROUTE_ASSOCS_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGURTAS.pls 115.0 2003/09/30 01:16:45 mkimizuk noship $ */

   --
   --  Constant Variables :
   --
   -- Here

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
* API Type      : Private Copy Associations API
* Purpose       : This api will copy instances for Route Associaitons
*********************************************************************/
PROCEDURE COPY_ASSOCIATIONS (
  P_FROM_PEOPLE_ID   IN NUMBER ,
  P_TO_PEOPLE_ID     IN NUMBER ,
  P_USER_ID          IN NUMBER   := NULL ,
  P_API_CALLER       IN VARCHAR2 := NULL
) ;



/********************************************************************
* API Type      : Private Table Hander APIs
* Purpose       : Those APIs are private
*                 Table Hander for Entity Object:
*                      ENG_CHANGE_ROUTE_ASSOCS
*                 PROCEDURE INSERT_ROW;
*                 -- Not Supproting PROCEDURE LOCK_ROW;
*                 -- Not Supproting PROCEDURE UPDATE_ROW;
*                 -- Not Supproting PROCEDURE DELETE_ROW;
*********************************************************************/
PROCEDURE INSERT_ROW (
  X_ROWID                     IN OUT NOCOPY VARCHAR2,
  X_ROUTE_ASSOCIATION_ID      IN NUMBER,
  X_ROUTE_PEOPLE_ID           IN NUMBER,
  X_ASSOC_OBJECT_NAME         IN VARCHAR2,
  X_ASSOC_OBJ_PK1_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK2_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK3_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK4_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK5_VALUE       IN VARCHAR2,
  X_OBJECT_NAME               IN VARCHAR2,
  X_OBJECT_ID1                IN NUMBER,
  X_OBJECT_ID2                IN NUMBER,
  X_OBJECT_ID3                IN NUMBER,
  X_OBJECT_ID4                IN NUMBER,
  X_OBJECT_ID5                IN NUMBER,
  X_REQUEST_ID                IN NUMBER,
  X_CREATION_DATE             IN DATE,
  X_CREATED_BY                IN NUMBER,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_ADHOC_ASSOC_FLAG          IN VARCHAR2
);

/********************************************
PROCEDURE LOCK_ROW (
  X_ROUTE_ASSOCIATION_ID      IN NUMBER,
  X_ROUTE_PEOPLE_ID           IN NUMBER,
  X_ASSOC_OBJECT_NAME         IN VARCHAR2,
  X_ASSOC_OBJ_PK1_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK2_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK3_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK4_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK5_VALUE       IN VARCHAR2,
  X_OBJECT_NAME               IN VARCHAR2,
  X_OBJECT_ID1                IN NUMBER,
  X_OBJECT_ID2                IN NUMBER,
  X_OBJECT_ID3                IN NUMBER,
  X_OBJECT_ID4                IN NUMBER,
  X_OBJECT_ID5                IN NUMBER,
  X_REQUEST_ID                IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_ADHOC_ASSOC_FLAG          IN VARCHAR2,
 );



PROCEDURE UPDATE_ROW (
  X_ROUTE_ASSOCIATION_ID      IN NUMBER,
  X_ROUTE_PEOPLE_ID           IN NUMBER,
  X_ASSOC_OBJECT_NAME         IN VARCHAR2,
  X_ASSOC_OBJ_PK1_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK2_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK3_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK4_VALUE       IN VARCHAR2,
  X_ASSOC_OBJ_PK5_VALUE       IN VARCHAR2,
  X_OBJECT_NAME               IN VARCHAR2,
  X_OBJECT_ID1                IN NUMBER,
  X_OBJECT_ID2                IN NUMBER,
  X_OBJECT_ID3                IN NUMBER,
  X_OBJECT_ID4                IN NUMBER,
  X_OBJECT_ID5                IN NUMBER,
  X_REQUEST_ID                IN NUMBER,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_ADHOC_ASSOC_FLAG          IN VARCHAR2,
) ;



PROCEDURE DELETE_ROW (
   X_ROUTE_ASSOCIATION_ID IN NUMBER
);
********************************************/

-- PROCEDURE ADD_LANGUAGE;


/********************************************************************
* API Type      : Public APIs
* Purpose       : Those APIs are public
*********************************************************************/


END Eng_Change_Route_Assocs_Util ;

 

/
