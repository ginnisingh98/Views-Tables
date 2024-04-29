--------------------------------------------------------
--  DDL for Package BIS_RESPONSIBILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RESPONSIBILITY_PUB" AUTHID CURRENT_USER as
/* $Header: BISPRSPS.pls 120.0 2005/06/01 15:36:39 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPRSPS.pls                                                      |
REM | PACKAGE                                                               |
REM |     BIS_RESPONSIBILITY_PUB                                            |
REM | DESCRIPTION                                                           |
REM |     Module: Private package that calls the FND packages to            |
REM |      insert records in the FND Responsibility table                   |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 07-MAR-2005 KRISHNA  Created.                                         |
REM | 25-MAR-2005 ANKAGARW bug#4392370 - Removed SECURITY_GROUP_ID          |                                          |
REM +=======================================================================+
*/
TYPE Responsibility_Rec_Type IS RECORD
(
    Application_Id                  FND_RESPONSIBILITY.APPLICATION_ID%TYPE
,   Responsibility_Id               FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE
,   Responsibility_Key              FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE
,   Menu_Id                         FND_RESPONSIBILITY.MENU_ID%TYPE
,   Responsibility_Name             FND_RESPONSIBILITY_TL.RESPONSIBILITY_NAME%TYPE
,   Description                     FND_RESPONSIBILITY_TL.DESCRIPTION%TYPE
,   Start_Date                      FND_RESPONSIBILITY.START_DATE%TYPE
,   End_Date                        FND_RESPONSIBILITY.END_DATE%TYPE
,   Version                         FND_RESPONSIBILITY.VERSION%TYPE
,   Web_Host_Name                   FND_RESPONSIBILITY.WEB_HOST_NAME%TYPE
,   Web_Agent_Name                  FND_RESPONSIBILITY.WEB_AGENT_NAME%TYPE
,   Data_Group_Application_Id       FND_RESPONSIBILITY.DATA_GROUP_APPLICATION_ID%TYPE
,   Data_Group_Id                   FND_RESPONSIBILITY.DATA_GROUP_ID%TYPE
,   Group_Application_Id            FND_RESPONSIBILITY.GROUP_APPLICATION_ID%TYPE
,   Request_Group_Id                FND_RESPONSIBILITY.REQUEST_GROUP_ID%TYPE
,   Last_Update_Date                FND_RESPONSIBILITY.LAST_UPDATE_DATE%TYPE
,   Last_Updated_By                 FND_RESPONSIBILITY.LAST_UPDATED_BY%TYPE
,   Creation_Date                   FND_RESPONSIBILITY.CREATION_DATE%TYPE
,   Created_By                      FND_RESPONSIBILITY.CREATED_BY%TYPE
,   Last_Update_Login               FND_RESPONSIBILITY.LAST_UPDATE_LOGIN%TYPE
);

PROCEDURE UPDATE_ROW(
               p_application_id         IN NUMBER
             , p_responsibility_id      IN NUMBER
             , p_menu_id                IN NUMBER
             , x_return_status          OUT NOCOPY VARCHAR2
             , x_msg_count              OUT NOCOPY NUMBER
             , x_msg_data               OUT NOCOPY VARCHAR2
            );

PROCEDURE LOCK_ROW(
           p_application_id         IN      NUMBER
         , p_responsibility_id      IN      NUMBER
         , p_last_update_date       IN      DATE
         ) ;

END BIS_RESPONSIBILITY_PUB;

 

/
