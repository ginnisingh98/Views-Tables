--------------------------------------------------------
--  DDL for Package ASN_SALES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASN_SALES_PVT" AUTHID CURRENT_USER AS
/* $Header: asnvslss.pls 120.1 2005/08/25 12:39:48 ujayaram noship $ */

   PROCEDURE Lead_Process_After_Create (
     P_Api_Version_Number     IN  NUMBER,
     P_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
     p_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
     p_Validation_Level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
     P_Identity_Salesforce_Id IN  NUMBER,
     P_Salesgroup_id          IN  NUMBER,
     P_Sales_Lead_Id          IN  NUMBER,
     X_Return_Status          OUT NOCOPY VARCHAR2,
     X_Msg_Count              OUT NOCOPY NUMBER,
     X_Msg_Data               OUT NOCOPY VARCHAR2
   );

   PROCEDURE Lead_Process_After_Update (
     P_Api_Version_Number     IN  NUMBER,
     P_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
     p_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
     p_Validation_Level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
     P_Identity_Salesforce_Id IN  NUMBER,
     P_Salesgroup_id          IN  NUMBER,
     P_Sales_Lead_Id          IN  NUMBER,
     X_Return_Status          OUT NOCOPY VARCHAR2,
     X_Msg_Count              OUT NOCOPY NUMBER,
     X_Msg_Data               OUT NOCOPY VARCHAR2
   );

   PROCEDURE Opp_Terr_Assignment (
     P_Api_Version_Number     IN   NUMBER,
     P_Init_Msg_List          IN   VARCHAR2    := FND_API.G_FALSE,
     p_Commit                 IN   VARCHAR2    := FND_API.G_FALSE,
     P_Lead_Id                IN   NUMBER,
     X_Return_Status          OUT  NOCOPY VARCHAR2,
     X_Msg_Count              OUT  NOCOPY NUMBER,
     X_Msg_Data               OUT  NOCOPY VARCHAR2
   );

END ASN_SALES_PVT;

 

/
