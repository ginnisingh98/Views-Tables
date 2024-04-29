--------------------------------------------------------
--  DDL for Package IBC_LABELS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_LABELS_GRP" AUTHID CURRENT_USER AS
/* $Header: ibcglabs.pls 115.2 2002/11/13 23:45:39 vicho ship $ */

-- Purpose: API to Populate Content Type.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- vicho             11/08/2002    Removed Default GMiss in Type Record


-- Package name     : Ibc_Labels_GRP
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


TYPE Label_Rec_Type IS RECORD(
Label_CODE		   VARCHAR2(100),
Label_NAME		   VARCHAR2(240),
CREATED_BY		   NUMBER,
CREATION_DATE		   DATE,
DESCRIPTION		   VARCHAR2(2000),
LAST_UPDATED_BY		   NUMBER,
LAST_UPDATE_DATE	   DATE,
LAST_UPDATE_LOGIN	   NUMBER,
OBJECT_VERSION_NUMBER	   NUMBER);

G_MISS_Label_REC          Label_Rec_Type;

TYPE  Label_Tbl_Type      IS TABLE OF Label_Rec_Type
                                    INDEX BY BINARY_INTEGER;

G_MISS_Label_Tbl 	  Label_Tbl_Type;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Labels
--   Type    :  Group
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Content_Type_Rec        IN 	Content_Type_Rec_Type  	Required
--		 P_Label_Tbl    IN 	Label_Tbl_Type Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--
PROCEDURE Create_Labels(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Label_Tbl	 	 			 IN   Ibc_Labels_GRP.Label_Tbl_Type := Ibc_Labels_GRP.G_Miss_Label_Tbl,
    x_Label_Tbl	 	 			 OUT NOCOPY   Ibc_Labels_GRP.Label_Tbl_Type,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Labels
--   Type    :  Group
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--		 P_Label_Tbl    IN 	Label_Tbl_Type Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--


PROCEDURE Update_Labels(
    P_Api_Version_Number        IN   NUMBER,
    P_Init_Msg_List             IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                    IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 		IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Label_Tbl			IN   Ibc_Labels_GRP.Label_Tbl_Type := Ibc_Labels_GRP.G_Miss_Label_Tbl,
    x_Label_Tbl			OUT NOCOPY  Ibc_Labels_GRP.Label_Tbl_Type,
    X_Return_Status             OUT NOCOPY  VARCHAR2,
    X_Msg_Count                 OUT NOCOPY  NUMBER,
    X_Msg_Data                  OUT NOCOPY  VARCHAR2
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Label
--   Type    :  Group
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Label_Code       IN 	VARCHAR2   Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--

PROCEDURE delete_Label(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Label_Code		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

END Ibc_Labels_GRP;

 

/
