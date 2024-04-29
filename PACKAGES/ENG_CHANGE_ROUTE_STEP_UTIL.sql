--------------------------------------------------------
--  DDL for Package ENG_CHANGE_ROUTE_STEP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_ROUTE_STEP_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUSTPS.pls 115.3 2003/09/30 01:12:48 mkimizuk ship $ */

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
* API Type      : Private Copy Steps APIs
* Purpose       : Those APIs are private to Copy Steps
*********************************************************************/
PROCEDURE COPY_STEPS (
  P_FROM_ROUTE_ID  IN NUMBER ,
  P_TO_ROUTE_ID    IN NUMBER ,
  P_USER_ID        IN NUMBER   := NULL ,
  P_API_CALLER     IN VARCHAR2 := NULL
) ;



/********************************************************************
* API Type      : Private Table Hander APIs
* Purpose       : Those APIs are private
*                 Table Hander for TL Entity Object:
*                      ENG_CHANGE_ROUTE_STEPS_VL
*                 PROCEDURE INSERT_ROW;
*                 PROCEDURE LOCK_ROW;
*                 PROCEDURE UPDATE_ROW;
*                 PROCEDURE DELETE_ROW;
*********************************************************************/
procedure INSERT_ROW (
  X_ROWID                      IN OUT NOCOPY VARCHAR2,
  X_STEP_ID                    IN NUMBER,
  X_ROUTE_ID                   IN NUMBER,
  X_STEP_SEQ_NUM               IN NUMBER,
  X_ADHOC_STEP_FLAG            IN VARCHAR2,
  X_WF_ITEM_TYPE               IN VARCHAR2,
  X_WF_ITEM_KEY                IN VARCHAR2,
  X_WF_PROCESS_NAME            IN VARCHAR2,
  X_CONDITION_TYPE_CODE        IN VARCHAR2,
  X_TIMEOUT_OPTION             IN VARCHAR2,
  X_STEP_STATUS_CODE           IN VARCHAR2,
  X_STEP_START_DATE            IN DATE,
  X_STEP_END_DATE              IN DATE,
  X_REQUIRED_RELATIVE_DAYS     IN NUMBER,
  X_REQUIRED_DATE              IN DATE,
  X_ATTRIBUTE_CATEGORY         IN VARCHAR2,
  X_ATTRIBUTE1                 IN VARCHAR2,
  X_ATTRIBUTE2                 IN VARCHAR2,
  X_ATTRIBUTE3                 IN VARCHAR2,
  X_ATTRIBUTE4                 IN VARCHAR2,
  X_ATTRIBUTE5                 IN VARCHAR2,
  X_ATTRIBUTE6                 IN VARCHAR2,
  X_ATTRIBUTE7                 IN VARCHAR2,
  X_ATTRIBUTE8                 IN VARCHAR2,
  X_ATTRIBUTE9                 IN VARCHAR2,
  X_ATTRIBUTE10                IN VARCHAR2,
  X_ATTRIBUTE11                IN VARCHAR2,
  X_ATTRIBUTE12                IN VARCHAR2,
  X_ATTRIBUTE13                IN VARCHAR2,
  X_ATTRIBUTE14                IN VARCHAR2,
  X_ATTRIBUTE15                IN VARCHAR2,
  X_REQUEST_ID                 IN NUMBER,
  X_ORIGINAL_SYSTEM_REFERENCE  IN VARCHAR2,
  X_INSTRUCTION                IN VARCHAR2,
  X_CREATION_DATE              IN DATE,
  X_CREATED_BY                 IN NUMBER,
  X_LAST_UPDATE_DATE           IN DATE,
  X_LAST_UPDATED_BY            IN NUMBER,
  X_LAST_UPDATE_LOGIN          IN NUMBER,
  X_PROGRAM_ID                 IN NUMBER,
  X_PROGRAM_APPLICATION_ID     IN NUMBER,
  X_PROGRAM_UPDATE_DATE        IN DATE,
  X_ASSIGNMENT_CODE            IN VARCHAR2
);


procedure LOCK_ROW (
  X_STEP_ID                    IN NUMBER,
  X_ROUTE_ID                   IN NUMBER,
  X_STEP_SEQ_NUM               IN NUMBER,
  X_ADHOC_STEP_FLAG            IN VARCHAR2,
  X_WF_ITEM_TYPE               IN VARCHAR2,
  X_WF_ITEM_KEY                IN VARCHAR2,
  X_WF_PROCESS_NAME            IN VARCHAR2,
  X_CONDITION_TYPE_CODE        IN VARCHAR2,
  X_TIMEOUT_OPTION             IN VARCHAR2,
  X_STEP_STATUS_CODE           IN VARCHAR2,
  X_STEP_START_DATE            IN DATE,
  X_STEP_END_DATE              IN DATE,
  X_REQUIRED_RELATIVE_DAYS     IN NUMBER,
  X_REQUIRED_DATE              IN DATE,
  X_ATTRIBUTE_CATEGORY         IN VARCHAR2,
  X_ATTRIBUTE1                 IN VARCHAR2,
  X_ATTRIBUTE2                 IN VARCHAR2,
  X_ATTRIBUTE3                 IN VARCHAR2,
  X_ATTRIBUTE4                 IN VARCHAR2,
  X_ATTRIBUTE5                 IN VARCHAR2,
  X_ATTRIBUTE6                 IN VARCHAR2,
  X_ATTRIBUTE7                 IN VARCHAR2,
  X_ATTRIBUTE8                 IN VARCHAR2,
  X_ATTRIBUTE9                 IN VARCHAR2,
  X_ATTRIBUTE10                IN VARCHAR2,
  X_ATTRIBUTE11                IN VARCHAR2,
  X_ATTRIBUTE12                IN VARCHAR2,
  X_ATTRIBUTE13                IN VARCHAR2,
  X_ATTRIBUTE14                IN VARCHAR2,
  X_ATTRIBUTE15                IN VARCHAR2,
  X_REQUEST_ID                 IN NUMBER,
  X_ORIGINAL_SYSTEM_REFERENCE  IN VARCHAR2,
  X_INSTRUCTION                IN VARCHAR2,
  X_PROGRAM_ID                 IN NUMBER,
  X_PROGRAM_APPLICATION_ID     IN NUMBER,
  X_PROGRAM_UPDATE_DATE        IN DATE,
  X_ASSIGNMENT_CODE            IN VARCHAR2
);


procedure UPDATE_ROW (
  X_STEP_ID                    IN NUMBER,
  X_ROUTE_ID                   IN NUMBER,
  X_STEP_SEQ_NUM               IN NUMBER,
  X_ADHOC_STEP_FLAG            IN VARCHAR2,
  X_WF_ITEM_TYPE               IN VARCHAR2,
  X_WF_ITEM_KEY                IN VARCHAR2,
  X_WF_PROCESS_NAME            IN VARCHAR2,
  X_CONDITION_TYPE_CODE        IN VARCHAR2,
  X_TIMEOUT_OPTION             IN VARCHAR2,
  X_STEP_STATUS_CODE           IN VARCHAR2,
  X_STEP_START_DATE            IN DATE,
  X_STEP_END_DATE              IN DATE,
  X_REQUIRED_RELATIVE_DAYS     IN NUMBER,
  X_REQUIRED_DATE              IN DATE,
  X_ATTRIBUTE_CATEGORY         IN VARCHAR2,
  X_ATTRIBUTE1                 IN VARCHAR2,
  X_ATTRIBUTE2                 IN VARCHAR2,
  X_ATTRIBUTE3                 IN VARCHAR2,
  X_ATTRIBUTE4                 IN VARCHAR2,
  X_ATTRIBUTE5                 IN VARCHAR2,
  X_ATTRIBUTE6                 IN VARCHAR2,
  X_ATTRIBUTE7                 IN VARCHAR2,
  X_ATTRIBUTE8                 IN VARCHAR2,
  X_ATTRIBUTE9                 IN VARCHAR2,
  X_ATTRIBUTE10                IN VARCHAR2,
  X_ATTRIBUTE11                IN VARCHAR2,
  X_ATTRIBUTE12                IN VARCHAR2,
  X_ATTRIBUTE13                IN VARCHAR2,
  X_ATTRIBUTE14                IN VARCHAR2,
  X_ATTRIBUTE15                IN VARCHAR2,
  X_REQUEST_ID                 IN NUMBER,
  X_ORIGINAL_SYSTEM_REFERENCE  IN VARCHAR2,
  X_INSTRUCTION                IN VARCHAR2,
  X_LAST_UPDATE_DATE           IN DATE,
  X_LAST_UPDATED_BY            IN NUMBER,
  X_LAST_UPDATE_LOGIN          IN NUMBER,
  X_PROGRAM_ID                 IN NUMBER,
  X_PROGRAM_APPLICATION_ID     IN NUMBER,
  X_PROGRAM_UPDATE_DATE        IN DATE,
  X_ASSIGNMENT_CODE            IN VARCHAR2
);

procedure DELETE_ROW (
  X_STEP_ID                    IN NUMBER
);


PROCEDURE ADD_LANGUAGE;


/********************************************************************
* API Type      : Public APIs
* Purpose       : Those APIs are public
*********************************************************************/


END Eng_Change_Route_Step_Util ;

 

/
