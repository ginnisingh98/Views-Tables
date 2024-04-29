--------------------------------------------------------
--  DDL for Package CSC_PLAN_LINES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PLAN_LINES_PUB" AUTHID CURRENT_USER as
/* $Header: cscpplns.pls 120.0 2005/05/30 15:46:42 appldev noship $ */
-- Start of Comments
-- Package name     : CSC_PLAN_LINES_PUB
-- Purpose          : Package contain procedures to perform inserts, updates and
--                    deletes on the plan details table CSC_PLAN_LINES.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-21-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 11-25-2002	bhroy		FND_API defaults removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK

-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

TYPE CSC_PLAN_LINES_Rec_Type IS RECORD
(
       ROW_ID                          ROWID ,
       LINE_ID                         NUMBER,
       PLAN_ID                         NUMBER,
       CONDITION_ID                    NUMBER,
       CREATION_DATE                   DATE ,
       LAST_UPDATE_DATE                DATE,
       CREATED_BY                      NUMBER,
       LAST_UPDATED_BY                 NUMBER,
       LAST_UPDATE_LOGIN               NUMBER,
       ATTRIBUTE1                      VARCHAR2(450),
       ATTRIBUTE2                      VARCHAR2(450),
       ATTRIBUTE3                      VARCHAR2(450),
       ATTRIBUTE4                      VARCHAR2(450),
       ATTRIBUTE5                      VARCHAR2(450),
       ATTRIBUTE6                      VARCHAR2(450),
       ATTRIBUTE7                      VARCHAR2(450),
       ATTRIBUTE8                      VARCHAR2(450),
       ATTRIBUTE9                      VARCHAR2(450),
       ATTRIBUTE10                     VARCHAR2(450),
       ATTRIBUTE11                     VARCHAR2(450),
       ATTRIBUTE12                     VARCHAR2(450),
       ATTRIBUTE13                     VARCHAR2(450),
       ATTRIBUTE14                     VARCHAR2(450),
       ATTRIBUTE15                     VARCHAR2(450),
       ATTRIBUTE_CATEGORY              VARCHAR2(90),
       OBJECT_VERSION_NUMBER           NUMBER
);

G_MISS_CSC_PLAN_LINES_REC          CSC_PLAN_LINES_Rec_Type;
TYPE  CSC_PLAN_LINES_Tbl_Type      IS TABLE OF CSC_PLAN_LINES_Rec_Type
                                   INDEX BY BINARY_INTEGER;
G_MISS_CSC_PLAN_LINES_TBL          CSC_PLAN_LINES_Tbl_Type;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Create_plan_lines
   --   Type    :  Public
   --   Pre-Req :  None.
   --   Function:  Inserts records into csc_plan_lines for a given plan_id.
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       P_CSC_PLAN_LINES_Rec      IN   CSC_PLAN_LINES_Rec_Type  Required
   --
   --   OUT  NOCOPY:
   --       x_line_id                 OUT NOCOPY  NUMBER
   --       x_object_version_number   OUT NOCOPY  NUMBER
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --   End of Comments
   --
PROCEDURE Create_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_CSC_PLAN_LINES_Rec         IN   CSC_PLAN_LINES_Rec_Type  := G_MISS_CSC_PLAN_LINES_REC,
    X_LINE_ID                    OUT NOCOPY  NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Create_plan_lines (procedure overloaded to accept a detailed parameter
   --                                 list )
   --   Type    :  Public
   --   Pre-Req :  None.
   --   Function:  Inserts records into csc_plan_lines for a given plan_id.
   --   Parameters:
   --   IN
   --     p_api_version_number     IN   NUMBER        Required
   --     p_init_msg_list          IN   VARCHAR2      Optional  Default = FND_API_G_FALSE
   --     p_commit                 IN   VARCHAR2      Optional  Default = FND_API.G_FALSE
   --     P_ROW_ID                 IN   ROWID         Optional  Default = FND_API.G_MISS_CHAR
   --     P_LINE_ID                IN   NUMBER        Optional  Default = FND_API.G_MISS_NUM
   --     P_PLAN_ID                IN   NUMBER        Required
   --     P_CONDITION_ID           IN   NUMBER        Required
   --     P_CREATION_DATE          IN   DATE          Required
   --     P_LAST_UPDATE_DATE       IN   DATE          Required
   --     P_CREATED_BY             IN   NUMBER        Required
   --     P_LAST_UPDATED_BY        IN   NUMBER        Required
   --     P_LAST_UPDATE_LOGIN      IN   NUMBER        Required
   --     P_ATTRIBUTE1             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE2             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE3             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE4             IN   VARCHAR2(450) Optional  Default  := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE5             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE6             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE7             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE8             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE9             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE10            IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE11            IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE12            IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE13            IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE14            IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE15            IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE_CATEGORY     IN   VARCHAR2(90)  Optional  Default := FND_API.G_MISS_CHAR,
   --     P_OBJECT_VERSION_NUMBER  IN   NUMBER        Required
   --
   --   OUT  NOCOPY:
   --     x_line_id                OUT NOCOPY  NUMBER
   --     x_object_version_number  OUT NOCOPY  NUMBER
   --     x_return_status          OUT NOCOPY  VARCHAR2
   --     x_msg_count              OUT NOCOPY  NUMBER
   --     x_msg_data               OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --   End of Comments
   --
PROCEDURE Create_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2  := NULL,
    P_Commit                     IN   VARCHAR2  := NULL,
    P_ROW_ID                     IN   ROWID := NULL,
    P_LINE_ID                    IN   NUMBER,
    P_PLAN_ID                    IN   NUMBER,
    P_CONDITION_ID               IN   NUMBER,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_LOGIN          IN   NUMBER := NULL,
    P_ATTRIBUTE1                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE2                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE3                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE4                 IN   VARCHAR2 :=NULL,
    P_ATTRIBUTE5                 IN   VARCHAR2 :=NULL,
    P_ATTRIBUTE6                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE7                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE8                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE9                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE10                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE11                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE12                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE13                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE14                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE15                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2 := NULL,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_LINE_ID                    OUT NOCOPY  NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Update_plan_lines
   --   Type    :  Public
   --   Pre-Req :
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       P_CSC_PLAN_LINES_Rec      IN   CSC_PLAN_LINES_Rec_Type  Required
   --
   --   OUT  NOCOPY:
   --       x_object_version_number   OUT NOCOPY  NUMBER
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --   Note: This automatic generated procedure definition, it includes standard IN/OUT NOCOPY parameters
   --         and basic operation, developer must manually add parameters and business logic as necessary.
   --
   --   End of Comments
   --
PROCEDURE Update_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_CSC_PLAN_LINES_Rec         IN   CSC_PLAN_LINES_Rec_Type,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Update_plan_lines (procedure overloaded to accept a detailed parameter
   --                                 list )
   --   Type    :  Public
   --   Pre-Req :
   --   Parameters:
   --   IN
   --     p_api_version_number     IN   NUMBER     Required
   --     p_init_msg_list          IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --     p_commit                 IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --     P_CSC_PLAN_LINES_Rec     IN   CSC_PLAN_LINES_Rec_Type  Required
   --     P_ROW_ID                 IN   ROWID         Optional  Default = FND_API.G_MISS_CHAR
   --     P_LINE_ID                IN   NUMBER        Optional  Default = FND_API.G_MISS_NUM
   --     P_PLAN_ID                IN   NUMBER        Required
   --     P_CONDITION_ID           IN   NUMBER        Required
   --     P_CREATION_DATE          IN   DATE          Required
   --     P_LAST_UPDATE_DATE       IN   DATE          Required
   --     P_CREATED_BY             IN   NUMBER        Required
   --     P_LAST_UPDATED_BY        IN   NUMBER        Required
   --     P_LAST_UPDATE_LOGIN      IN   NUMBER        Required
   --     P_ATTRIBUTE1             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE2             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE3             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE4             IN   VARCHAR2(450) Optional  Default  := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE5             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE6             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE7             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE8             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE9             IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE10            IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE11            IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE12            IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE13            IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE14            IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE15            IN   VARCHAR2(450) Optional  Default := FND_API.G_MISS_CHAR,
   --     P_ATTRIBUTE_CATEGORY     IN   VARCHAR2(90)  Optional  Default := FND_API.G_MISS_CHAR,
   --     P_OBJECT_VERSION_NUMBER  IN   NUMBER        Optional  Default := FND_API.G_MISS_NUM
   --
   --   OUT  NOCOPY:
   --     x_object_version_number  OUT NOCOPY  NUMBER
   --     x_return_status          OUT NOCOPY  VARCHAR2
   --     x_msg_count              OUT NOCOPY  NUMBER
   --     x_msg_data               OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Update_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_ROW_ID                     IN   ROWID := NULL,
    P_LINE_ID                    IN   NUMBER,
    P_PLAN_ID                    IN   NUMBER,
    P_CONDITION_ID               IN   NUMBER,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_LOGIN          IN   NUMBER :=NULL,
    P_ATTRIBUTE1                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE2                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE3                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE4                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE5                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE6                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE7                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE8                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE9                 IN   VARCHAR2 := NULL,
    P_ATTRIBUTE10                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE11                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE12                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE13                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE14                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE15                IN   VARCHAR2 := NULL,
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2 := NULL,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name:  Delete_plan_lines
   --   Type    :  Public
   --   Pre-Req :
   --   Parameters:
   --   IN
   --       p_api_version_number      IN   NUMBER     Required
   --       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
   --       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
   --       p_plan_id                 IN   NUMBER     Optional  Default = FND_API.G_FALSE
   --       p_line_id                 IN   NUMBER     Optional  Default = FND_API.G_FALSE
   --
   --   OUT  NOCOPY:
   --       x_return_status           OUT NOCOPY  VARCHAR2
   --       x_msg_count               OUT NOCOPY  NUMBER
   --       x_msg_data                OUT NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE Delete_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := NULL,
    P_Commit                     IN   VARCHAR2     := NULL,
    P_Plan_Id                    IN   NUMBER       := NULL,
    P_Line_Id                    IN   NUMBER       := NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

End CSC_PLAN_LINES_PUB;

 

/