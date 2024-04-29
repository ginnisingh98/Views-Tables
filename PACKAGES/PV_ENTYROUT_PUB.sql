--------------------------------------------------------
--  DDL for Package PV_ENTYROUT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENTYROUT_PUB" AUTHID CURRENT_USER as
/* $Header: pvrperts.pls 120.0 2005/05/27 16:17:31 appldev noship $ */
-- Start of Comments
-- Package name     : PV_ENTYROUT_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_entyrout
--   Type    :  Public
--   Pre-Req :
--
PROCEDURE Create_entyrout(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_ENTYROUT_Rec             IN   PV_RULE_RECTYPE_PUB.ENTYROUT_Rec_Type
                                :=  PV_RULE_RECTYPE_PUB.G_MISS_ENTYROUT_REC,
    X_ENTITY_ROUTING_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_entyrout
--   Type    :  Public
--   Pre-Req :

PROCEDURE Update_entyrout(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_ENTYROUT_Rec             IN   PV_RULE_RECTYPE_PUB.ENTYROUT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_entyrout
--   Type    :  Public
--   Pre-Req :

PROCEDURE Delete_entyrout(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_ENTYROUT_Rec             IN  PV_RULE_RECTYPE_PUB.ENTYROUT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End PV_ENTYROUT_PUB;

 

/
