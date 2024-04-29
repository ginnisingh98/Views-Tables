--------------------------------------------------------
--  DDL for Package PV_ENTYATTMAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENTYATTMAP_PUB" AUTHID CURRENT_USER as
/* $Header: pvrpeams.pls 120.0 2005/05/27 15:53:47 appldev noship $ */
-- Start of Comments
-- Package name     : PV_ENTYATTMAP_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_entyattmap
--   Type    :  Public
--   Pre-Req :
--
PROCEDURE Create_entyattmap(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_ENTYATTMAP_Rec           IN   PV_RULE_RECTYPE_PUB.ENTYATTMAP_Rec_Type
                                 := PV_RULE_RECTYPE_PUB.G_MISS_ENTYATTMAP_REC,
    X_MAPPING_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_entyattmap
--   Type    :  Public
--   Pre-Req :

PROCEDURE Update_entyattmap(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_ENTYATTMAP_Rec             IN   PV_RULE_RECTYPE_PUB.ENTYATTMAP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_entyattmap
--   Type    :  Public
--   Pre-Req :

PROCEDURE Delete_entyattmap(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_ENTYATTMAP_Rec             IN   PV_RULE_RECTYPE_PUB.ENTYATTMAP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


End PV_ENTYATTMAP_PUB;

 

/
