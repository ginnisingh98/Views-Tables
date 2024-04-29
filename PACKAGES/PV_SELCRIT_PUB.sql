--------------------------------------------------------
--  DDL for Package PV_SELCRIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_SELCRIT_PUB" AUTHID CURRENT_USER as
/* $Header: pvrpescs.pls 120.0 2005/05/27 16:23:55 appldev noship $ */
-- Start of Comments
-- Package name     : PV_SELCRIT_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_selcrit
--   Type    :  Public
--   Pre-Req :
--
PROCEDURE Create_selcrit(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_SELCRIT_Rec                IN   PV_RULE_RECTYPE_PUB.SELCRIT_Rec_Type  := PV_RULE_RECTYPE_PUB.G_MISS_SELCRIT_REC,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_SELECTION_CRITERIA_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_selcrit
--   Type    :  Public
--   Pre-Req :

PROCEDURE Update_selcrit(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_SELCRIT_Rec                IN   PV_RULE_RECTYPE_PUB.SELCRIT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_selcrit
--   Type    :  Public
--   Pre-Req :

PROCEDURE Delete_selcrit(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_SELCRIT_Rec                IN   PV_RULE_RECTYPE_PUB.SELCRIT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End PV_SELCRIT_PUB;

 

/
