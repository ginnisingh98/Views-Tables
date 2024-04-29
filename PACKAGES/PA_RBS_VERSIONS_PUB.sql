--------------------------------------------------------
--  DDL for Package PA_RBS_VERSIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_VERSIONS_PUB" AUTHID CURRENT_USER AS
--$Header: PARBSVPS.pls 120.0 2005/05/30 16:42:04 appldev noship $

--Package constant used for package version validation
G_API_VERSION_NUMBER    CONSTANT Number := 1;
G_PKG_NAME		CONSTANT Varchar2(30) := 'PA_RBS_VERSIONS_PUB';


-- =======================================================================
-- Start of Comments
-- API Name      : Update_Working_Version
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure allows for the update of the current working version for a rbs header.
--
--  Parameters:
--
--  IN
--      P_Commit                - Varchar2 Default Fnd_Api.G_False
--      P_Init_Msg_List         - Varchar2 Default Fnd_Api.G_True
--      P_Api_Version_Number    - Number
--      P_RBS_Version_Id        - Number
--      P_Name                  - Varchar2(240)
--      P_Description           - Varchar2(2000)
--      P_Version_Start_Date    - Date
--      P_Job_Group_Id          - Number
--      P_Record_Version_Number - Number
--      P_Init_Debugging_Flag   - Varchar2 Default 'Y'
--  OUT
--      X_Record_Version_Number - Number
--      X_Return_Status         - Varchar2(1)
--      X_Msg_Count             - Number
--      X_Error_Msg_Data        - Varchar2(30)
/*-------------------------------------------------------------------------*/

Procedure Update_Working_Version(
        P_Commit                IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List         IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number    IN         Number,
        P_RBS_Version_Id        IN         Number,
        P_Name                  IN         Varchar2,
        P_Description           IN         Varchar2,
        P_Version_Start_Date    IN         Date,
        P_Job_Group_Id          IN         Number,
        P_Record_Version_Number IN         Number,
        P_Init_Debugging_Flag   IN         Varchar2 Default 'Y',
        X_Record_Version_Number OUT NOCOPY Number,
        X_Return_Status         OUT NOCOPY Varchar2,
        X_Msg_Count             OUT NOCOPY Number,
        X_Error_Msg_Data        OUT NOCOPY Varchar2);

-- =======================================================================
-- Start of Comments
-- API Name      : Delete_Working_Version
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure deletes the working rbs version as well as it elements/nodes.
--
--  Parameters:
--
--  IN
--      P_Commit                - Varchar2 Default Fnd_Api.G_False
--      P_Init_Msg_List         - Varchar2 Default Fnd_Api.G_True
--      P_Api_Version_Number    - Number
--      P_RBS_Version_Id        - Number(15)
--      P_Record_Version_Number - Number(15)
--  OUT
--      X_Return_Status         - Varchar2(1)
--      X_Msg_Count             - Number
--      X_Error_Msg_Data        - Varchar2(30)
--
/*-------------------------------------------------------------------------*/

Procedure Delete_Working_Version(
        P_Commit                IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List         IN         Varchar2 Default Fnd_Api.G_True,
        P_Api_Version_Number    IN         Number,
        P_RBS_Version_Id        IN         Number,
        P_Record_Version_Number IN         Number,
        X_Return_Status         OUT NOCOPY Varchar2,
        X_Msg_Count             OUT NOCOPY Number,
        X_Error_Msg_Data        OUT NOCOPY Varchar2);


-- =======================================================================
-- Start of Comments
-- API Name      : Create_Working_Version
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure create a new working rbs version based on a previously frozen rbs version.
--
--  Parameters:
--
--  IN
--      P_Commit                - Varchar2 Default Fnd_Api.G_False,
--      P_Init_Msg_List         - Varchar2 Default Fnd_Api.G_True,
--      P_Api_Version_Number    - Number
--      P_RBS_Version_Id        - Number(15) is the frozen version id to copy from(should not be null copying)
--      P_Rbs_Header_Id         - Number(15) is Header for the frozen and the working version
--      P_Rec_Version_Number    - Number(15) is from the current working version
-- OUT
--      X_Return_Status         - Varchar2(1)
--      X_Msg_Count             - Number
--      X_Error_Msg_Data        - Varchar2(30)
--
/*-------------------------------------------------------------------------*/

Procedure Create_Working_Version (
        P_Commit                IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List         IN         Varchar2 Default Fnd_Api.G_True,
        P_Api_Version_Number    IN         Number,
        P_RBS_Version_Id        IN         Number Default Null,
        P_Rbs_Header_Id         IN         Number,
        P_Rec_Version_Number    IN         Number Default Null,
        P_Init_Debugging_Flag   IN         Varchar2 Default 'Y',
        X_Return_Status         OUT NOCOPY Varchar2,
        X_Msg_Count             OUT NOCOPY Number,
        X_Error_Msg_Data        OUT NOCOPY Varchar2 );


-- =======================================================================
-- Start of Comments
-- API Name      : Freeze_Working_Version
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure freezes the working version and inturn creates a new working rbs version based on a this version.
--
--  Parameters:
--
--  IN
--      P_Commit                		- Varchar2 Default Fnd_Api.G_False,
--      P_Init_Msg_List         		- Varchar2 Default Fnd_Api.G_True,
--      P_rbs_Version_Id        		- Number(15) is the version id of the version to be freezed
--      P_rbs_version_record_ver_num         	- Number(15) is the record version number of the version to be freezed
--      P_Init_Debugging_Flag                   - Vachar2(1)
-- OUT
--      X_Return_Status         		- Varchar2(1)
--      X_Msg_Count             		- Number
--      X_Error_Msg_Data        		- Varchar2(30)
--
/*-------------------------------------------------------------------------*/
Procedure Freeze_Working_Version(
        P_Commit                     IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List              IN         Varchar2 Default Fnd_Api.G_True,
        P_Rbs_Version_Id             IN         Number,
        P_Rbs_Version_Record_Ver_Num IN         Number Default Null,
        P_Init_Debugging_Flag        IN         Varchar2 Default 'Y',
        X_Return_Status              OUT NOCOPY Varchar2,
        X_Msg_Count                  OUT NOCOPY Number,
        X_Error_Msg_Data             OUT NOCOPY Varchar2);

End Pa_Rbs_Versions_Pub;

 

/
