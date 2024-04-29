--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_ASSIGN_PVT" AUTHID CURRENT_USER as
/* $Header: asxvslas.pls 115.15 2004/05/07 02:02:12 solin ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_ASSIGN_PVT
-- Purpose          : Sales Leads Assignment
-- NOTE             :
-- History          :
--      04/09/2001 FFANG  Created.
--      04/30/2001 SOLIN  Change for real time assignment and sales lead
--                        sales team.
--      09/06/2001 SOLIN  Enhancement bug 1963262.
--                        Owner can decline sales lead.
--      12/10/2001 SOLIN  Bug 2102901.
--                        Add salesgroup_id for current user in
--                        Build_Lead_Sales_Team and Rebuild_Lead_Sales_Team
--      11/22/2002 SOLIN  Change for NOCOPY.
--      03/14/2003 SOLIN  Bug 2852597
--                        Port 11.5.8 fix to 11.5.9.
--      04/23/2003 SOLIN  Bug 2921105
--                        Add channel_code in lead trigger.
--
-- End of Comments


PROCEDURE Assign_Sales_Lead (
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN  AS_UTILITY_PUB.Profile_Tbl_Type
                                      := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_resource_type              IN  VARCHAR2    DEFAULT NULL,
    P_role                       IN  VARCHAR2    DEFAULT NULL,
    P_no_of_resources            IN  NUMBER      DEFAULT 1,
    P_auto_select_flag           IN  VARCHAR2    DEFAULT NULL,
    P_effort_duration            IN  NUMBER      DEFAULT NULL,
    P_effort_uom                 IN  VARCHAR2    DEFAULT NULL,
    P_start_date                 IN  DATE        DEFAULT NULL,
    P_end_date                   IN  DATE        DEFAULT NULL,
    P_territory_flag             IN  VARCHAR2    DEFAULT 'Y',
    P_calendar_flag              IN  VARCHAR2    DEFAULT 'Y',
    P_Sales_Lead_Id              IN  NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    X_Assign_Id_Tbl              OUT NOCOPY AS_SALES_LEADS_PUB.Assign_Id_Tbl_Type
    );


PROCEDURE CALL_WF_TO_ASSIGN (
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2    := FND_API.G_FALSE,
    P_Sales_Lead_Id              IN  NUMBER,
    P_assigned_resource_id       IN  NUMBER      DEFAULT NULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );


PROCEDURE Build_Lead_Sales_Team (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Request_Id              OUT NOCOPY NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );


PROCEDURE Rebuild_Lead_Sales_Team (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Request_Id              OUT NOCOPY NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

-- The following are private API without conuterpart public API.

PROCEDURE Sales_Leads_Trigger_Handler(
    P_Customer_Id                 IN  NUMBER,
    P_Sales_Lead_Id               IN  NUMBER,
    P_Old_Address_Id              IN  NUMBER,
    P_Old_Budget_Amount           IN  NUMBER,
    P_Old_Currency_Code           IN  VARCHAR2,
    P_Old_Source_Promotion_Id     IN  NUMBER,
    P_Old_Channel_Code            IN  VARCHAR2,
    P_New_Address_Id              IN  NUMBER,
    P_New_Budget_Amount           IN  NUMBER,
    P_New_Currency_Code           IN  VARCHAR2,
    P_New_Source_Promotion_Id     IN  NUMBER,
    P_New_Channel_Code            IN  VARCHAR2,
    P_New_Assign_To_Salesforce_Id IN  NUMBER,
    P_New_Reject_Reason_Code      IN  VARCHAR2,
    P_Trigger_Mode                IN  VARCHAR2);

PROCEDURE Sales_Lead_Lines_Handler(
    P_Sales_Lead_Id                  IN  NUMBER,
    P_Old_category_Id		     IN  NUMBER,
    P_Old_category_set_Id            IN  NUMBER,
    P_Old_Inventory_Item_Id          IN  NUMBER,
    P_Old_Purchase_Amount            IN  NUMBER,
    P_New_category_Id                IN  NUMBER,
    P_New_category_set_Id            IN  NUMBER,
    P_New_Inventory_Item_Id          IN  NUMBER,
    P_New_Purchase_Amount            IN  NUMBER,
    P_Trigger_Mode                   IN  VARCHAR2);

PROCEDURE Set_Default_Lead_Owner(
    p_sales_lead_id                  IN  NUMBER,
    p_salesgroup_id                  IN  NUMBER,
    p_request_id                     IN  NUMBER,
    X_Return_Status                  OUT NOCOPY VARCHAR2,
    X_Msg_Count                      OUT NOCOPY NUMBER,
    X_Msg_Data                       OUT NOCOPY VARCHAR2);

PROCEDURE Find_Lead_Owner(
    P_Sales_Lead_Id                  IN  NUMBER,
    P_Salesgroup_Id                  IN  NUMBER,
    P_Request_Id                     IN  NUMBER,
    X_Return_Status                  OUT NOCOPY VARCHAR2,
    X_Msg_Count                      OUT NOCOPY NUMBER,
    X_Msg_Data                       OUT NOCOPY VARCHAR2);

PROCEDURE Process_Access_Record(
    P_Sales_Lead_Id                  IN  NUMBER,
    P_Request_Id                     IN  NUMBER);

End AS_SALES_LEAD_ASSIGN_PVT;

 

/
