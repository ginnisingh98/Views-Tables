--------------------------------------------------------
--  DDL for Package PA_RBS_ELEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_ELEMENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: PARELEPS.pls 120.0 2005/05/30 21:46:52 appldev noship $*/


--Package constant used for package version validation
G_API_VERSION_NUMBER    CONSTANT NUMBER := 1;
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_RBS_ELEMENTS_PUB';

TYPE Rbs_Elements_Rec_Typ IS RECORD (
        Rbs_Element_Id              Pa_Rbs_Elements.Rbs_Element_Id%TYPE,
        Parent_Element_Id           Pa_Rbs_Elements.Parent_Element_Id%TYPE,
        Resource_Type_Id            Pa_Rbs_Elements.Resource_Type_Id%TYPE,
        Resource_Source_Id          Number(15),
	Resource_Source_Code        Varchar2(240),
        Order_Number                Pa_Rbs_Elements.Order_Number%TYPE,
        Process_Type     	    Varchar2(1));

TYPE Rbs_Elements_Tbl_Typ IS TABLE OF Rbs_Elements_Rec_Typ
     INDEX BY BINARY_INTEGER;


-- =======================================================================
-- Start of Comments
-- API Name      : Process_RBS_Elements
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This is the overall starting point to insert, update, and delete
--                 elements/nodes for a specific Resource Breakdown Structure Working Version.
--                 If cannot lock the Rbs Working Version then no processing will be done.
--                 The procedure is used by the Self Service client pages only.
--
--  Parameters:
--
--  IN
--      P_Calling_Page             - Varchar2(30)
--      P_Commit                   - Varchar2 Default 'F'
--      P_Init_Msg_List            - Varchar2 Default 'T'
--      P_API_Version_Number       - Number
--      P_RBS_Version_Id           - Number(15)
--	P_Rbs_Version_Rec_Num      - Number(15)
--      P_Parent_Element_Id_Tbl    - System.Pa_Num_Tbl_Type
--      P_Element_Id_Tbl           - System.Pa_Num_Tbl_Type
--      P_Resource_Type_Id_Tbl     - System.Pa_Num_Tbl_Type
--      P_Resource_Source_Id_Tbl   - System.Pa_Num_Tbl_Type
--      P_Resource_Source_Code_Tbl - System.Pa_Varchar2_240_Tbl_Type
--      P_Order_Number_Tbl         - System.Pa_Num_Tbl_Type
--      P_Process_Type_Tbl         - System.Pa_Varchar2_1_Tbl_Type
--  OUT
--      X_Return_Status            - Varchar2(1)
--      X_Msg_Count                - Number
--      X_Error_Msg_Data           - Varchar2(30)
--
/*-------------------------------------------------------------------------*/

Procedure Process_Rbs_Elements (
	P_Calling_Page		   IN	      Varchar2,
        P_Commit                   IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List            IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number       IN         Number,
        P_RBS_Version_Id           IN         Number,
	P_Rbs_Version_Rec_Num      IN         Number,
        P_Parent_Element_Id_Tbl    IN         System.Pa_Num_Tbl_Type,
        P_Element_Id_Tbl           IN         System.Pa_Num_Tbl_Type,
        P_Resource_Type_Id_Tbl     IN         System.Pa_Num_Tbl_Type,
        P_Resource_Source_Id_Tbl   IN         System.Pa_Num_Tbl_Type,
	P_Resource_Source_Code_Tbl IN	      System.Pa_Varchar2_240_Tbl_Type,
        P_Order_Number_Tbl         IN         System.Pa_Num_Tbl_Type,
        P_Process_Type_Tbl         IN         System.Pa_Varchar2_1_Tbl_Type,
        X_Return_Status            OUT NOCOPY Varchar2,
        X_Msg_Count                OUT NOCOPY Number,
        X_Error_Msg_Data           OUT NOCOPY Varchar2);

-- =======================================================================
-- Start of Comments
-- API Name      : Process_RBS_Elements
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This is the overall starting point to insert, update, and delete
--                 elements/nodes for a specific Resource Breakdown Structure Working Version.
--                 If cannot lock the Rbs Working Version then no processing will be done.
--                 The procedure is used by AMG only.
--
--  Parameters:
--
--  IN
--      P_Commit              - Varchar2 Default 'F'
--      P_Init_Msg_List       - Varchar2 Default 'T'
--      P_API_Version_Number  - Number
--      P_RBS_Version_Id      - Number(15)
--	P_Rbs_Version_Rec_Num - Number(15)
--      P_Rbs_Elements_Tbl    - Pa_Rbs_Elements_Pub.Rbs_Elements_Tbl_Typ
--  OUT
--      X_Return_Status       - Varchar2(1)
--      X_Msg_Count           - Number
--      X_Error_Msg_Data      - Varchar2(30)
--
/*-------------------------------------------------------------------------*/

Procedure Process_Rbs_Elements(
        P_Commit                IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List         IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number    IN         Number,
        P_RBS_Version_Id        IN         Number,
	P_Rbs_Version_Rec_Num   IN         Number,
        P_Rbs_Elements_Tbl      IN         Pa_Rbs_Elements_Pub.Rbs_Elements_Tbl_Typ,
        X_Return_Status         OUT NOCOPY Varchar2,
        X_Msg_Count             OUT NOCOPY Number,
        X_Error_Msg_Data        OUT NOCOPY Varchar2);


-- =======================================================================
-- Start of Comments
-- API Name      : PopulateErrorStack
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is used to build the error message.
--                 This means determining the token value that will
--                 will be passed in with the message.  The token
--                 value is dynamic and must consider translation.
--
--  Parameters:
--
--  IN
--    P_Calling_Page       - VARCHAR2(10) Values: VERSION_ELEMENTS or CHILD_ELEMENTS
--    P__Element_Id        - Number
--    P_Resource_Type_Id   - Number
--    P_Resource_Source_Id - Number
--    P_Error_Msg_Data     - VARCHAR2(30)
--
/*-------------------------------------------------------------------------*/

Procedure PopulateErrorStack(
	P_Calling_Page       IN Varchar2 Default 'VERSION_ELEMENTS',
	P_Element_Id         IN Number,
	P_Resource_Type_Id   IN Number,
	P_Resource_Source_Id IN Number,
	P_Error_Msg_Data     IN Varchar2);

END PA_RBS_ELEMENTS_PUB;

 

/
