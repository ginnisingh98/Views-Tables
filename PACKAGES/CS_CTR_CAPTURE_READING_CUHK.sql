--------------------------------------------------------
--  DDL for Package CS_CTR_CAPTURE_READING_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CTR_CAPTURE_READING_CUHK" AUTHID CURRENT_USER as
/* $Header: csxccrds.pls 120.1 2005/06/20 11:14:21 appldev ship $*/
-- Start of Comments
-- Package name     : CS_CTR_CAPTURE_READING_CUHK
-- Purpose          : Customer Hookup for Capture Reading of Counters
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE CAPTURE_COUNTER_READING_PRE(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_CTR_GRP_LOG_Rec            IN   CS_CTR_CAPTURE_READING_PUB.CTR_GRP_LOG_Rec_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_CTR_GRP_LOG_Rec,
    p_CTR_RDG_Tbl                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_CTR_RDG_TBL,
    p_PROP_RDG_Tbl               IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_PROP_RDG_TBL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE CAPTURE_COUNTER_READING_POST(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_CTR_GRP_LOG_Rec            IN   CS_CTR_CAPTURE_READING_PUB.CTR_GRP_LOG_Rec_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_CTR_GRP_LOG_Rec,
    p_CTR_RDG_Tbl                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_CTR_RDG_TBL,
    p_PROP_RDG_Tbl               IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_PROP_RDG_TBL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE UPDATE_COUNTER_READING_PRE(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_CTR_GRP_LOG_ID             IN   NUMBER,
    p_CTR_RDG_Tbl                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_CTR_RDG_TBL,
    p_PROP_RDG_Tbl               IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_PROP_RDG_TBL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
  );


PROCEDURE UPDATE_COUNTER_READING_POST(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_CTR_GRP_LOG_ID             IN   NUMBER,
    p_CTR_RDG_Tbl                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_CTR_RDG_TBL,
    p_PROP_RDG_Tbl               IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_PROP_RDG_TBL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
  );

PROCEDURE CAPTURE_COUNTER_READING_PRE (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_CTR_RDG_Rec                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
   );

PROCEDURE CAPTURE_COUNTER_READING_POST (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_CTR_RDG_Rec                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
   );

PROCEDURE UPDATE_COUNTER_READING_PRE (
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_CTR_RDG_Rec                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
   );

PROCEDURE UPDATE_COUNTER_READING_POST (
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_CTR_RDG_Rec                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
   );

PROCEDURE PRE_CAPTURE_CTR_READING_PRE(
     p_api_version_number        IN  NUMBER,
     p_init_msg_list             IN  VARCHAR2   := FND_API.G_FALSE,
     P_Commit                    IN  VARCHAR2   := FND_API.G_FALSE,
     p_validation_level          IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
     P_CTR_GRP_LOG_Rec           IN  CS_CTR_CAPTURE_READING_PUB.CTR_GRP_LOG_Rec_Type,
     X_COUNTER_GRP_LOG_ID        IN  NUMBER,
     X_Return_Status             OUT NOCOPY VARCHAR2,
     X_Msg_Count                 OUT NOCOPY NUMBER,
     X_Msg_Data                  OUT NOCOPY VARCHAR2
    );

PROCEDURE PRE_CAPTURE_CTR_READING_POST(
     p_api_version_number        IN  NUMBER,
     p_init_msg_list             IN  VARCHAR2   := FND_API.G_FALSE,
     P_Commit                    IN  VARCHAR2   := FND_API.G_FALSE,
     p_validation_level          IN  NUMBER     := FND_API.G_VALID_LEVEL_FULL,
     P_CTR_GRP_LOG_Rec           IN  CS_CTR_CAPTURE_READING_PUB.CTR_GRP_LOG_Rec_Type,
     X_COUNTER_GRP_LOG_ID        IN  NUMBER,
     X_Return_Status             OUT NOCOPY VARCHAR2,
     X_Msg_Count                 OUT NOCOPY NUMBER,
     X_Msg_Data                  OUT NOCOPY VARCHAR2
    );

PROCEDURE CAPTURE_CTR_PROP_READING_PRE(
     p_Api_version_number      IN   NUMBER,
     p_Init_Msg_List           IN   VARCHAR2     := FND_API.G_FALSE,
     P_Commit                  IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
     p_PROP_RDG_Rec            IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Rec_Type,
     p_COUNTER_GRP_LOG_ID      IN   NUMBER,
     X_Return_Status           OUT NOCOPY  VARCHAR2,
     X_Msg_Count               OUT NOCOPY  NUMBER,
     X_Msg_Data                OUT NOCOPY  VARCHAR2
     );

PROCEDURE CAPTURE_CTR_PROP_READING_POST(
     p_Api_version_number      IN   NUMBER,
     p_Init_Msg_List           IN   VARCHAR2     := FND_API.G_FALSE,
     P_Commit                  IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
     p_PROP_RDG_Rec            IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Rec_Type,
     p_COUNTER_GRP_LOG_ID      IN   NUMBER,
     X_Return_Status           OUT NOCOPY  VARCHAR2,
     X_Msg_Count               OUT NOCOPY  NUMBER,
     X_Msg_Data                OUT NOCOPY  VARCHAR2
     );

PROCEDURE POST_CAPTURE_CTR_READING_PRE (
      p_api_version_number      IN   NUMBER,
      p_init_msg_list           IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                  IN   VARCHAR2     := FND_API.G_FALSE,
      p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      p_COUNTER_GRP_LOG_ID      IN   NUMBER,
      p_READING_UPDATED         IN   VARCHAR2      := FND_API.G_FALSE,
      X_Return_Status           OUT NOCOPY  VARCHAR2,
      X_Msg_Count               OUT NOCOPY  NUMBER,
      X_Msg_Data                OUT NOCOPY  VARCHAR2
     );

PROCEDURE POST_CAPTURE_CTR_READING_POST (
      p_api_version_number      IN   NUMBER,
      p_init_msg_list           IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                  IN   VARCHAR2     := FND_API.G_FALSE,
      p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      p_COUNTER_GRP_LOG_ID      IN   NUMBER,
      p_READING_UPDATED         IN   VARCHAR2      := FND_API.G_FALSE,
      X_Return_Status           OUT NOCOPY  VARCHAR2,
      X_Msg_Count               OUT NOCOPY  NUMBER,
      X_Msg_Data                OUT NOCOPY  VARCHAR2
     );

PROCEDURE UPDATE_CTR_PROP_READING_PRE (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_PROP_RDG_Rec               IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE UPDATE_CTR_PROP_READING_POST (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_PROP_RDG_Rec               IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End CS_CTR_CAPTURE_READING_CUHK;

 

/
