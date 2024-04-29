--------------------------------------------------------
--  DDL for Package AS_SALES_LEAD_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEAD_ENGINE_PVT" AUTHID CURRENT_USER as
/* $Header: asxvsles.pls 115.8 2003/11/17 19:39:48 chchandr ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_ENGINE_PVT
-- Purpose          : Sales Leads Engines
-- NOTE             :
-- History          :
--      02/04/2002 SOLIN  Created.
--                        AS provides package spec, PV provides package body
--                        for this package.
--      01/16/2003 SOLIN  Remove Start_Partner_Matching.
--                        It's moved to PV_BG_PARTNER_MATCHING_PUB.
--
-- End of Comments

PROCEDURE Run_Lead_Engines (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    -- ckapoor Phase 2 filtering project 11.5.10
    -- P_Is_Create_Mode	      IN  VARCHAR2,
    X_Lead_Engines_Out_Rec    OUT NOCOPY AS_SALES_LEADS_PUB.Lead_Engines_Out_Rec_Type,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );



PROCEDURE Rate_Select_Lead(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    P_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_id           IN  NUMBER,
    P_Process_Type            IN  VARCHAR2,
    -- ckapoor Phase 2 filtering project 11.5.10
    -- P_Is_Create_Mode	      IN  VARCHAR2,
    X_Action_Value            OUT NOCOPY VARCHAR2,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

PROCEDURE Lead_Process_After_Create (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    p_Admin_Flag              IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

PROCEDURE Lead_Process_After_Update (
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    p_Admin_Flag              IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

End AS_SALES_LEAD_ENGINE_PVT;

 

/
