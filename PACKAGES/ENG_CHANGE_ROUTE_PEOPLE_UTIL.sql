--------------------------------------------------------
--  DDL for Package ENG_CHANGE_ROUTE_PEOPLE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_ROUTE_PEOPLE_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGURTPS.pls 120.0 2005/05/26 18:56:52 appldev noship $ */

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
* API Type      : Private APIs
* Purpose       : Those APIs are private
*********************************************************************/

-- Change Route Assignee Record
TYPE Assignee_Rec_Type IS RECORD
(
  assignee_id                NUMBER
 ,assignee_type_code         VARCHAR2(30)
 ,assignee_type              VARCHAR2(30)
 ,assignee_name              VARCHAR2(360)
 ,assignee_company           VARCHAR2(360)
 ,assignee_role_obj_name     VARCHAR2(240)
) ;


TYPE Assignee_Tbl_Type IS TABLE OF Assignee_Rec_Type
INDEX BY BINARY_INTEGER ;

G_ASSIGNEE_TBL           Eng_Change_Route_People_Util.Assignee_Tbl_Type ;

FUNCTION Get_Assignee_Name
( p_assignee_id        IN NUMBER
, p_assignee_type_code IN VARCHAR2
, p_current_flag       IN VARCHAR2 := NULL
)
RETURN VARCHAR2 ;



FUNCTION Get_Assignee_Company
( p_assignee_id        IN NUMBER
, p_assignee_type_code IN VARCHAR2
, p_current_flag       IN VARCHAR2 := NULL
)
RETURN VARCHAR2 ;


FUNCTION Get_Assignee_Type
( p_assignee_id        IN NUMBER
, p_assignee_type_code IN VARCHAR2
, p_current_flag       IN VARCHAR2 := NULL
)
RETURN VARCHAR2 ;





/********************************************************************
* API Type      : Private Copy People API
* Purpose       : This api will copy instances for Route People
*********************************************************************/
PROCEDURE COPY_PEOPLE (
  P_FROM_STEP_ID   IN NUMBER ,
  P_TO_STEP_ID     IN NUMBER ,
  P_USER_ID        IN NUMBER   := NULL ,
  P_API_CALLER     IN VARCHAR2 := NULL
) ;



/********************************************************************
* API Type      : Private Table Hander APIs
* Purpose       : Those APIs are private
*                 Table Hander for TL Entity Object:
*                      ENG_CHANGE_ROUTE_PEOPLE_VL
*                 PROCEDURE INSERT_ROW;
*                 PROCEDURE LOCK_ROW;
*                 PROCEDURE UPDATE_ROW;
*                 PROCEDURE DELETE_ROW;
*********************************************************************/
PROCEDURE INSERT_ROW (
  X_ROWID                     IN OUT NOCOPY VARCHAR2,
  X_ROUTE_PEOPLE_ID           IN NUMBER,
  X_STEP_ID                   IN NUMBER,
  X_ASSIGNEE_ID               IN NUMBER,
  X_ASSIGNEE_TYPE_CODE        IN VARCHAR2,
  X_ADHOC_PEOPLE_FLAG         IN VARCHAR2,
  X_WF_NOTIFICATION_ID        IN NUMBER,
  X_RESPONSE_CODE             IN VARCHAR2,
  X_RESPONSE_DATE             IN DATE,
  X_REQUEST_ID                IN NUMBER,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_RESPONSE_DESCRIPTION      IN VARCHAR2,
  X_CREATION_DATE             IN DATE,
  X_CREATED_BY                IN NUMBER,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_ASSIGNEE_ID        IN NUMBER,
  X_ORIGINAL_ASSIGNEE_TYPE_CODE IN VARCHAR2,
  X_RESPONSE_CONDITION_CODE   IN VARCHAR2,
  X_PARENT_ROUTE_PEOPLE_ID       IN NUMBER
);


PROCEDURE LOCK_ROW (
  X_ROUTE_PEOPLE_ID           IN NUMBER,
  X_STEP_ID                   IN NUMBER,
  X_ASSIGNEE_ID               IN NUMBER,
  X_ASSIGNEE_TYPE_CODE        IN VARCHAR2,
  X_ADHOC_PEOPLE_FLAG         IN VARCHAR2,
  X_WF_NOTIFICATION_ID        IN NUMBER,
  X_RESPONSE_CODE             IN VARCHAR2,
  X_RESPONSE_DATE             IN DATE,
  X_REQUEST_ID                IN NUMBER,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_RESPONSE_DESCRIPTION      IN VARCHAR2,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_ASSIGNEE_ID        IN NUMBER,
  X_ORIGINAL_ASSIGNEE_TYPE_CODE IN VARCHAR2,
  X_RESPONSE_CONDITION_CODE   IN VARCHAR2,
  X_PARENT_ROUTE_PEOPLE_ID       IN NUMBER
 );


PROCEDURE UPDATE_ROW (
  X_ROUTE_PEOPLE_ID           IN NUMBER,
  X_STEP_ID                   IN NUMBER,
  X_ASSIGNEE_ID               IN NUMBER,
  X_ASSIGNEE_TYPE_CODE        IN VARCHAR2,
  X_ADHOC_PEOPLE_FLAG         IN VARCHAR2,
  X_WF_NOTIFICATION_ID        IN NUMBER,
  X_RESPONSE_CODE             IN VARCHAR2,
  X_RESPONSE_DATE             IN DATE,
  X_REQUEST_ID                IN NUMBER,
  X_ORIGINAL_SYSTEM_REFERENCE IN VARCHAR2,
  X_RESPONSE_DESCRIPTION      IN VARCHAR2,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER,
  X_PROGRAM_ID                IN NUMBER,
  X_PROGRAM_APPLICATION_ID    IN NUMBER,
  X_PROGRAM_UPDATE_DATE       IN DATE,
  X_ORIGINAL_ASSIGNEE_ID        IN NUMBER,
  X_ORIGINAL_ASSIGNEE_TYPE_CODE IN VARCHAR2,
  X_RESPONSE_CONDITION_CODE   IN VARCHAR2,
  X_PARENT_ROUTE_PEOPLE_ID       IN NUMBER

);



PROCEDURE DELETE_ROW (
  X_ROUTE_PEOPLE_ID           IN NUMBER
);

PROCEDURE ADD_LANGUAGE;


/********************************************************************
* API Type      : Public APIs
* Purpose       : Those APIs are public
*********************************************************************/


END Eng_Change_Route_People_Util ;

 

/
