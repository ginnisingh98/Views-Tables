--------------------------------------------------------
--  DDL for Package PV_ENTYRLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENTYRLS_PUB" AUTHID CURRENT_USER as
/* $Header: pvrperas.pls 120.0 2005/05/27 16:00:09 appldev noship $ */
-- Start of Comments
-- Package name     : PV_ENTYRLS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_entyrls
--   Type    :  Public
--   Pre-Req :
--
PROCEDURE Create_entyrls(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_ENTYRLS_Rec              IN   PV_RULE_RECTYPE_PUB.ENTYRLS_Rec_Type
                                 := PV_RULE_RECTYPE_PUB.G_MISS_ENTYRLS_REC,
    X_ENTITY_RULE_APPLIED_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_entyrls
--   Type    :  Public
--   Pre-Req :

PROCEDURE Update_entyrls(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_ENTYRLS_Rec              IN   PV_RULE_RECTYPE_PUB.ENTYRLS_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_entyrls
--   Type    :  Public
--   Pre-Req :

PROCEDURE Delete_entyrls(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_ENTYRLS_Rec              IN   PV_RULE_RECTYPE_PUB.ENTYRLS_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End PV_ENTYRLS_PUB;

 

/
