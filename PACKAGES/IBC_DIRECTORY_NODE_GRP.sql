--------------------------------------------------------
--  DDL for Package IBC_DIRECTORY_NODE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_DIRECTORY_NODE_GRP" AUTHID CURRENT_USER AS
/* $Header: ibcgdnds.pls 115.5 2003/08/14 18:29:42 enunez ship $ */

-- Purpose: API to Populate Content Type.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- vicho             11/08/2002    Removed Default GMiss in Type Record


-- Package name     : Ibc_Directory_Node_Grp
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
IBC_APPL_ID              NUMBER := 549;
G_ROOT_NODE_ID 			 NUMBER := 1;

TYPE Directory_Node_Rec_Type IS RECORD(
    	DIRECTORY_NODE_ID	 	NUMBER
    ,	NODE_TYPE			VARCHAR2(30)
    , NODE_STATUS VARCHAR2(30)
    , DIRECTORY_PATH VARCHAR2(4000)
    ,	DIRECTORY_NODE_CODE		VARCHAR2(100)
    ,	DIRECTORY_NODE_NAME		VARCHAR2(240)
    ,	DESCRIPTION			VARCHAR2(2000)
    ,	CREATED_BY			NUMBER
    ,	CREATION_DATE			DATE
    ,	LAST_UPDATED_BY			NUMBER
    ,	LAST_UPDATE_DATE		DATE
    ,	LAST_UPDATE_LOGIN		NUMBER
    ,	OBJECT_VERSION_NUMBER		NUMBER
);

G_MISS_Directory_Node_REC          Directory_Node_Rec_Type;

TYPE Directory_Node_TBL_Type IS TABLE OF Directory_Node_Rec_Type;

G_MISS_Directory_Node_TBL          Directory_Node_TBL_Type;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Directory_Node
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Directory_Node_Rec      IN 	Directory_Node_Rec_Type  	Required
--		 P_Sub_Directory_Tbl      IN 	Sub_Directory_Tbl_Type Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--
	PROCEDURE Create_Directory_Node(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Directory_Node_Rec		 IN   Ibc_Directory_Node_Grp.Directory_Node_Rec_Type := Ibc_Directory_Node_Grp.G_MISS_Directory_Node_Rec,
	p_parent_dir_node_id		 IN   NUMBER DEFAULT 0,
    x_Directory_Node_Rec		 OUT NOCOPY  Ibc_Directory_Node_Grp.Directory_Node_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Directory_Node
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Directory_Node_Rec        IN 	Directory_Node_Rec_Type  	Required
--		 P_Sub_Directory_Tbl      IN 	Sub_Directory_Tbl_Type Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--


PROCEDURE Update_Directory_Node(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Directory_Node_Rec		 IN   Ibc_Directory_Node_Grp.Directory_Node_Rec_Type := Ibc_Directory_Node_Grp.G_MISS_Directory_Node_Rec,
	p_parent_dir_node_id		 IN   NUMBER,
    x_Directory_Node_Rec		 OUT NOCOPY  Ibc_Directory_Node_Grp.Directory_Node_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Directory_Node
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Directory_Node_Code     IN 	VARCHAR2   Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   End of Comments
--

PROCEDURE delete_Directory_Node(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Directory_Node_ID			 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

FUNCTION  get_directory_node_rec	RETURN  Ibc_Directory_Node_Grp.Directory_Node_rec_type;

PROCEDURE Move_Directory_Node(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
	p_Current_parent_node_id	 IN   NUMBER,
	p_New_parent_node_id	 	 IN   NUMBER,
	p_Directory_node_id	 	 	 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

END Ibc_Directory_Node_Grp;

 

/
