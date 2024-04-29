--------------------------------------------------------
--  DDL for Package IBC_CV_LABEL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CV_LABEL_GRP" AUTHID CURRENT_USER AS
/* $Header: ibcgcvls.pls 115.3 2002/11/15 00:48:06 svatsa ship $ */

-- Purpose: API to Populate Citem Version Labels.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for NOCOPY

-- Package name     : IBC_CV_LABEL_GRP
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

TYPE CV_Label_Rec_Type IS RECORD(
     CONTENT_ITEM_ID        NUMBER
    ,CITEM_VERSION_ID       NUMBER
    ,LABEL_CODE             VARCHAR2(30)
    ,CREATED_BY             NUMBER
    ,CREATION_DATE          DATE
    ,LAST_UPDATED_BY        NUMBER
    ,LAST_UPDATE_DATE       DATE
    ,LAST_UPDATE_LOGIN      NUMBER
    ,OBJECT_VERSION_NUMBER  NUMBER
);

G_MISS_CV_Label_Rec         CV_Label_Rec_Type;

TYPE CV_Label_TBL_Type IS TABLE OF CV_Label_Rec_Type;

G_MISS_CV_Label_TBL          CV_Label_TBL_Type;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_CV_Label
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_CV_Label_Rec      	   IN 	CV_Label_Rec_Type  	Required
--		 P_Sub_Directory_Tbl       IN 	Sub_Directory_Tbl_Type Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   End of Comments
--
	PROCEDURE Create_CV_Label(
    P_Api_Version_Number         IN   NUMBER
    ,P_Init_Msg_List             IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,P_Commit                    IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,P_Validation_Level 		 IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,P_CV_Label_Rec		 		 IN   Ibc_Cv_Label_Grp.CV_Label_Rec_Type := Ibc_Cv_Label_Grp.G_MISS_CV_Label_Rec
    ,x_CV_Label_Rec		 		 OUT NOCOPY  Ibc_Cv_Label_Grp.CV_Label_Rec_Type
    ,X_Return_Status             OUT NOCOPY  VARCHAR2
    ,X_Msg_Count                 OUT NOCOPY  NUMBER
    ,X_Msg_Data                  OUT NOCOPY  VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_CV_Label
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_CV_Label_Rec        IN 	CV_Label_Rec_Type  	Required
--		 P_Sub_Directory_Tbl      IN 	Sub_Directory_Tbl_Type Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   End of Comments
--


PROCEDURE Update_CV_Label(
    P_Api_Version_Number        IN   NUMBER
    ,P_Init_Msg_List            IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,P_Commit                   IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,P_Validation_Level 		IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,P_CV_Label_Rec		 		IN   Ibc_Cv_Label_Grp.CV_Label_Rec_Type := Ibc_Cv_Label_Grp.G_MISS_CV_Label_Rec
    ,x_CV_Label_Rec		 		OUT NOCOPY  Ibc_Cv_Label_Grp.CV_Label_Rec_Type
    ,X_Return_Status            OUT NOCOPY  VARCHAR2
    ,X_Msg_Count                OUT NOCOPY  NUMBER
    ,X_Msg_Data                 OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_CV_Label
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_CV_Label_Code     IN 	VARCHAR2   Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   End of Comments
--

PROCEDURE delete_CV_Label(
    P_Api_Version_Number         IN   NUMBER
    ,P_Init_Msg_List             IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,P_Commit                    IN   VARCHAR2     := Fnd_Api.G_FALSE
    ,P_Validation_Level 		 IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL
    ,P_Label_Code		 	 	 IN   VARCHAR2
    ,P_content_item_id	 	 	 IN   NUMBER
    ,X_Return_Status             OUT NOCOPY  VARCHAR2
    ,X_Msg_Count                 OUT NOCOPY  NUMBER
    ,X_Msg_Data                  OUT NOCOPY  VARCHAR2
    );

PROCEDURE Upsert_Cv_Labels(
	 p_label_code				IN VARCHAR2
    ,p_content_item_ids         IN JTF_NUMBER_TABLE
	,p_version_number        	IN JTF_NUMBER_TABLE
    ,p_commit                   IN 	VARCHAR2
    ,p_api_version_number       IN 	NUMBER
    ,p_init_msg_list            IN 	VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE Upsert_Cv_Labels(
	 p_label_code				IN VARCHAR2
    ,p_content_item_ids         IN JTF_NUMBER_TABLE
	,p_citem_version_ids        IN JTF_NUMBER_TABLE
    ,p_commit                   IN 	VARCHAR2
    ,p_api_version_number       IN 	NUMBER
    ,p_init_msg_list            IN 	VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Cv_Labels(
	 p_label_code				IN VARCHAR2
    ,p_content_item_ids         IN JTF_NUMBER_TABLE
    ,p_commit                   IN 	VARCHAR2
    ,p_api_version_number       IN 	NUMBER
    ,p_init_msg_list            IN 	VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
);
END Ibc_Cv_Label_Grp;

 

/
