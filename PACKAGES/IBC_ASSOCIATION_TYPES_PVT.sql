--------------------------------------------------------
--  DDL for Package IBC_ASSOCIATION_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_ASSOCIATION_TYPES_PVT" AUTHID CURRENT_USER AS
/* $Header: ibcvatys.pls 115.3 2002/11/17 16:05:55 srrangar ship $ */

-- Purpose: API to Populate Content Type.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated the record from FND_API.G_MISS_XXX
--                                   to no defaults.
--                                   Changed the OUT to OUT NOCOPY

-- Package name     : Ibc_Association_Types_Pvt
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
IBC_APPL_ID              NUMBER := 549;


TYPE Index_Link_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
G_MISS_Link_Tbl	 Index_Link_Tbl_Type;

TYPE VARCHAR_Tbl_Type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

TYPE Association_type_Rec_Type IS RECORD(
 ASSOCIATION_TYPE_CODE     VARCHAR2(100)
,ASSOCIATION_TYPE_NAME     VARCHAR2(240)
,CALL_BACK_PKG             VARCHAR2(50)
,CREATED_BY                NUMBER
,CREATION_DATE             DATE
,DESCRIPTION               VARCHAR2(2000)
,LAST_UPDATED_BY           NUMBER
,LAST_UPDATE_DATE          DATE
,LAST_UPDATE_LOGIN         NUMBER
,OBJECT_VERSION_NUMBER     NUMBER
,SEARCH_PAGE               VARCHAR2(2000)
);


G_MISS_Association_Type_REC          Association_Type_Rec_Type;

TYPE  Association_Type_Tbl_Type      IS TABLE OF Association_Type_Rec_Type
                                    INDEX BY BINARY_INTEGER;

G_MISS_Association_Type_Tbl 			Association_Type_Tbl_Type;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Association_Types
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Content_Type_Rec        IN 	Content_Type_Rec_Type  	Required
--		 P_Association_Type_Tbl    IN 	Association_Type_Tbl_Type Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   End of Comments
--
	PROCEDURE Create_Association_Types(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Association_Type_Tbl	 	 IN   Ibc_Association_Types_Pvt.Association_Type_Tbl_Type := Ibc_Association_Types_Pvt.G_Miss_Association_Type_Tbl,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Association_Types
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--		 P_Association_Type_Tbl    IN 	Association_Type_Tbl_Type Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   End of Comments
--


PROCEDURE Update_Association_Types(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Association_Type_Tbl	 	 IN   Ibc_Association_Types_Pvt.Association_Type_Tbl_Type := Ibc_Association_Types_Pvt.G_Miss_Association_Type_Tbl,
    x_Association_Type_Tbl	 	 OUT NOCOPY  Ibc_Association_Types_Pvt.Association_Type_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Association_Type
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Association_Type_Code       IN 	VARCHAR2   Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   End of Comments
--

PROCEDURE delete_Association_Type(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Association_Type_Code		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

END Ibc_Association_Types_Pvt;

 

/
