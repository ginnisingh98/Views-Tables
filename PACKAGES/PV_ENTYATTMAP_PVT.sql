--------------------------------------------------------
--  DDL for Package PV_ENTYATTMAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENTYATTMAP_PVT" AUTHID CURRENT_USER as
/* $Header: pvrveams.pls 115.2 2002/12/10 20:56:30 ryellapu ship $ */
-- Start of Comments
-- Package name     : PV_ENTYATTMAP_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_entyattmap
--   Type    :  Private
--   Pre-Req :
--
PROCEDURE Create_entyattmap(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id       IN   NUMBER,
    P_ENTYATTMAP_Rec             IN   PV_RULE_RECTYPE_PUB.ENTYATTMAP_Rec_Type
                                   := PV_RULE_RECTYPE_PUB.G_MISS_ENTYATTMAP_REC,
    X_MAPPING_ID                 OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_entyattmap
--   Type    :  Private
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
--   Type    :  Private
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


-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_MAPPING_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MAPPING_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


-- Start of Comments
--
-- Item level validation procedures
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--
-- End of Comments

PROCEDURE Validate_MAPPING_OPERATOR (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ATTRIBUTE_ID               IN   NUMBER,
    P_OPERATOR                   IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_entyattmap(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_ENTYATTMAP_Rec             IN   PV_RULE_RECTYPE_PUB.ENTYATTMAP_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End PV_ENTYATTMAP_PVT;

 

/
