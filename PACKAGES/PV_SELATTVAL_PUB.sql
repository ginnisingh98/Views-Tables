--------------------------------------------------------
--  DDL for Package PV_SELATTVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_SELATTVAL_PUB" AUTHID CURRENT_USER as
/* $Header: pvrpsavs.pls 120.0 2005/05/27 15:35:22 appldev noship $ */
-- Start of Comments
-- Package name     : PV_SELATTVAL_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_selattval
--   Type    :  Public
--   End of Comments
--
PROCEDURE Create_selattval(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_SELATTVAL_Rec            IN   PV_RULE_RECTYPE_PUB.SELATTVAL_Rec_Type
                                 := PV_RULE_RECTYPE_PUB.G_MISS_SELATTVAL_REC,
    X_ATTR_VALUE_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_selattval
--   Type    :  Public

PROCEDURE Update_selattval(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_SELATTVAL_Rec            IN   PV_RULE_RECTYPE_PUB.SELATTVAL_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_selattval
--   Type    :  Public

PROCEDURE Delete_selattval(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Resource_Id     IN   NUMBER,
    P_SELATTVAL_Rec            IN   PV_RULE_RECTYPE_PUB.SELATTVAL_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


End PV_SELATTVAL_PUB;

 

/
