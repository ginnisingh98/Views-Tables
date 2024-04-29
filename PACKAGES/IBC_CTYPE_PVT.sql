--------------------------------------------------------
--  DDL for Package IBC_CTYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CTYPE_PVT" AUTHID CURRENT_USER AS
/* $Header: ibcvctys.pls 120.1 2005/06/01 23:25:05 appldev  $ */

-- Purpose: API to Populate Content Type.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for NOCOPY
-- Sri Rangarajan    01/06/2004      Added the Method get_sql_from_flex

-- Package name     : IBC_Ctype_Pvt
-- Purpose          :
-- History          : 05/18/2005 Sharma GSCC NOCOPY issue fixed
-- NOTE             :
-- End of Comments



-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
IBC_APPL_ID              NUMBER := 549;

G_NAME      VARCHAR2(4) := 'NAME';
G_DESCRIPTION     VARCHAR2(11) := 'DESCRIPTION';


TYPE Index_Link_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
G_MISS_Link_Tbl  Index_Link_Tbl_Type;

TYPE VARCHAR_Tbl_Type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;


TYPE Content_type_Rec_Type IS RECORD(
      CONTENT_TYPE_CODE       VARCHAR2(100)
     ,CONTENT_TYPE_NAME       VARCHAR2(240)
     ,CONTENT_TYPE_STATUS     VARCHAR2(30)
     ,DESCRIPTION             VARCHAR2(2000)
     ,APPLICATION_ID          NUMBER
     ,CREATED_BY              NUMBER
     ,CREATION_DATE           DATE
     ,LAST_UPDATED_BY         NUMBER
     ,LAST_UPDATE_DATE        DATE
     ,LAST_UPDATE_LOGIN       NUMBER
     ,REQUEST_ID              NUMBER
     ,PROGRAM_UPDATE_DATE     DATE
     ,PROGRAM_APPLICATION_ID  NUMBER
     ,PROGRAM_ID              NUMBER
     ,OBJECT_VERSION_NUMBER   NUMBER
);

G_MISS_Content_Type_REC          Content_Type_Rec_Type;

TYPE  Content_Type_Tbl_Type      IS TABLE OF Content_Type_Rec_Type
                                    INDEX BY BINARY_INTEGER;

G_MISS_Content_Type_Tbl    Content_Type_Tbl_Type;


TYPE Attribute_type_Rec_Type IS RECORD(
      OPERATION_CODE           VARCHAR2(30)
     ,ATTRIBUTE_TYPE_CODE      VARCHAR2(100)
     ,ATTRIBUTE_TYPE_NAME      VARCHAR2(240)
     ,DESCRIPTION              VARCHAR2(2000)
     ,CONTENT_TYPE_CODE        VARCHAR2(100)
     ,DATA_TYPE_CODE           VARCHAR2(30)
     ,DATA_LENGTH              NUMBER
     ,MIN_INSTANCES            NUMBER
     ,MAX_INSTANCES            NUMBER
     ,REFERENCE_CODE           VARCHAR2(100)
     ,DEFAULT_VALUE            VARCHAR2(240)
     ,UPDATEABLE_FLAG          VARCHAR2(1)
     ,CREATED_BY               NUMBER
     ,CREATION_DATE            DATE
     ,LAST_UPDATED_BY          NUMBER
     ,LAST_UPDATE_DATE         DATE
     ,LAST_UPDATE_LOGIN        NUMBER
     ,OBJECT_VERSION_NUMBER    NUMBER
);

G_MISS_Attribute_Type_REC        Attribute_Type_Rec_Type;

TYPE  Attribute_Type_Tbl_Type    IS TABLE OF Attribute_Type_Rec_Type
                                 INDEX BY BINARY_INTEGER;

G_MISS_Attribute_Type_Tbl          Attribute_Type_Tbl_Type;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Content_Type
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Content_Type_Rec        IN  Content_Type_Rec_Type   Required
--   P_Attribute_Type_Tbl      IN  Attribute_Type_Tbl_Type Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   End of Comments
--
 PROCEDURE Create_Content_Type(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2   := Fnd_Api.G_FALSE,
    P_Commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,
    P_Validation_Level     IN  NUMBER := Fnd_Api.G_VALID_LEVEL_FULL,
    P_Content_Type_Rec  IN  Ibc_Ctype_Pvt.Content_Type_Rec_Type := Ibc_Ctype_Pvt.G_MISS_Content_Type_Rec,
    P_Attribute_Type_Tbl IN  Ibc_Ctype_Pvt.Attribute_Type_Tbl_Type := Ibc_Ctype_Pvt.G_Miss_Attribute_Type_Tbl,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Content_Type
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Content_Type_Rec        IN  Content_Type_Rec_Type   Required
--   P_Attribute_Type_Tbl      IN  Attribute_Type_Tbl_Type Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   End of Comments
--


PROCEDURE Update_Content_Type(
    P_Api_Version_Number         IN     NUMBER,
    P_Init_Msg_List              IN     VARCHAR2     := Fnd_Api.G_FALSE,
    P_Commit                     IN     VARCHAR2     := Fnd_Api.G_FALSE,
    P_Validation_Level IN     NUMBER  := Fnd_Api.G_VALID_LEVEL_FULL,
    P_Content_Type_Rec IN     Ibc_Ctype_Pvt.Content_Type_Rec_Type   := Ibc_Ctype_Pvt.G_MISS_Content_Type_Rec,
    P_Attribute_Type_Tbl IN     Ibc_Ctype_Pvt.Attribute_Type_Tbl_Type := Ibc_Ctype_Pvt.G_Miss_Attribute_Type_Tbl,
    x_Content_Type_Rec     OUT NOCOPY  Ibc_Ctype_Pvt.Content_Type_Rec_Type,
    x_Attribute_Type_Tbl    OUT NOCOPY  Ibc_Ctype_Pvt.Attribute_Type_Tbl_Type,
    X_Return_Status    OUT NOCOPY  VARCHAR2,
    X_Msg_Count        OUT NOCOPY  NUMBER,
    X_Msg_Data         OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Content_Type
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Content_Type_Code       IN  VARCHAR2   Required
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   End of Comments
--

PROCEDURE delete_Content_Type(
    P_Api_Version_Number         IN     NUMBER,
    P_Init_Msg_List              IN    VARCHAR2     := Fnd_Api.G_FALSE,
    P_Commit                     IN     VARCHAR2     := Fnd_Api.G_FALSE,
    P_Validation_Level     IN     NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,
    P_Content_Type_Code     IN     VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_Content_type
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       P_Content_Type_Rec        IN  Content_Type_Rec_Type   Required
--       p_rec_requested           IN   NUMBER     Optional  Default = 30
--       p_start_rec_ptr           IN   NUMBER     Optional  Default = 1
--
--       Return Total Records Count Flag. This flag controls whether the total record count
--       and total record amount is returned.
--
--       p_return_tot_count        IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--
--   OUT:
--       X_Content_Type_Tbl        OUT NOCOPY  Content_Type_Tbl_Type
--       x_returned_rec_count      OUT NOCOPY  NUMBER
--       x_next_rec_ptr            OUT NOCOPY  NUMBER
--       x_tot_rec_count           OUT NOCOPY  NUMBER
--       x_tot_rec_amount          OUT NOCOPY   NUMBER
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2



-- PROCEDURE Get_Content_type(
--     P_Api_Version_Number         IN   NUMBER,
--     P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
--     P_Content_Type_Rec     IN   Content_Type_Rec_Type,
--     p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
--     p_start_rec_prt              IN   NUMBER  := 1,
--     p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
--     X_Content_Type_Tbl     OUT NOCOPY  Content_Type_Tbl_Type,
--     x_returned_rec_count         OUT NOCOPY  NUMBER,
--     x_next_rec_ptr               OUT NOCOPY  NUMBER,
--     x_tot_rec_count              OUT NOCOPY  NUMBER,
--     x_return_status              OUT NOCOPY  VARCHAR2,
--     x_msg_count                  OUT NOCOPY  NUMBER,
--     x_msg_data                   OUT NOCOPY  VARCHAR2
--     );

FUNCTION  get_ctype_rec RETURN  Ibc_Ctype_Pvt.content_type_rec_type;


PROCEDURE Create_Attribute_Type(
    P_Api_Version_Number		IN     NUMBER,
    P_Init_Msg_List			IN      VARCHAR2    := Fnd_Api.G_FALSE,
    P_Commit				IN     VARCHAR2     := Fnd_Api.G_FALSE,
    P_Validation_Level			IN     NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,
    P_Attribute_Type_Rec		IN     Ibc_Ctype_Pvt.Attribute_Type_Rec_Type,
    X_Return_Status			OUT NOCOPY  VARCHAR2,
    X_Msg_Count				OUT NOCOPY  NUMBER,
    X_Msg_Data				OUT NOCOPY  VARCHAR2
    );

PROCEDURE get_Attribute_Type_LOV(
	P_Api_Version_Number		IN     NUMBER
	,P_Init_Msg_List		IN     VARCHAR2     := Fnd_Api.G_FALSE
	,p_content_type_code		IN     VARCHAR2 --1
	,p_attribute_type_code		IN     VARCHAR2  --2
	,x_code				OUT NOCOPY JTF_VARCHAR2_TABLE_100 --4
	,x_name				OUT NOCOPY JTF_VARCHAR2_TABLE_300 -- 5
	,x_description			OUT NOCOPY JTF_VARCHAR2_TABLE_2000 --3
	,X_Return_Status		OUT NOCOPY  VARCHAR2 --6
	,X_Msg_Count			OUT NOCOPY  NUMBER -- 7
	,X_Msg_Data			OUT NOCOPY  VARCHAR2 -- 8
    );

PROCEDURE get_Content_Type(
	p_api_version_number		IN   NUMBER DEFAULT 1.0
	,p_init_msg_list		IN   VARCHAR2 DEFAULT Fnd_Api.g_false
	,p_content_type_code		IN   VARCHAR2 -- 1
	,x_content_type_name		OUT NOCOPY VARCHAR2 -- 2
	,x_content_type_description	OUT NOCOPY VARCHAR2 -- 3
	,x_content_type_status		OUT NOCOPY VARCHAR2 -- 4
	,X_ATTRIBUTE_TYPE_CODE		OUT NOCOPY JTF_VARCHAR2_TABLE_100 -- 5
	,x_ATTRIBUTE_TYPE_NAME		OUT NOCOPY JTF_VARCHAR2_TABLE_300  -- 6
	,x_DESCRIPTION			OUT NOCOPY JTF_VARCHAR2_TABLE_2000 -- 7
	,x_CONTENT_TYPE_CODE		OUT NOCOPY JTF_VARCHAR2_TABLE_100 -- 8
	,x_DATA_TYPE_CODE		OUT NOCOPY JTF_VARCHAR2_TABLE_100 -- 9
	,x_DATA_LENGTH			OUT NOCOPY JTF_NUMBER_TABLE -- 10
	,x_MIN_INSTANCES		OUT NOCOPY JTF_NUMBER_TABLE -- 11
	,x_MAX_INSTANCES		OUT NOCOPY JTF_NUMBER_TABLE -- 12
	,x_Flex_value_set_id		OUT NOCOPY JTF_NUMBER_TABLE -- 13
	,x_REFERENCE_CODE		OUT NOCOPY JTF_VARCHAR2_TABLE_100 -- 14
	,x_DEFAULT_VALUE		OUT NOCOPY JTF_VARCHAR2_TABLE_300 -- 15
	,x_UPDATEABLE_FLAG		OUT NOCOPY JTF_VARCHAR2_TABLE_100 -- 16 Varchar2(1)
	,x_CREATED_BY			OUT NOCOPY JTF_NUMBER_TABLE -- 17
	,x_CREATION_DATE		OUT NOCOPY JTF_DATE_TABLE -- 18
	,x_LAST_UPDATED_BY		OUT NOCOPY JTF_NUMBER_TABLE --19
	,x_LAST_UPDATE_DATE		OUT NOCOPY JTF_DATE_TABLE -- 20
	,x_LAST_UPDATE_LOGIN		OUT NOCOPY JTF_NUMBER_TABLE --21
	,x_OBJECT_VERSION_NUMBER	OUT NOCOPY JTF_NUMBER_TABLE --22
	,x_return_status		OUT NOCOPY VARCHAR2 -- 23
	,x_msg_count			OUT NOCOPY INTEGER --24
	,x_msg_data			OUT NOCOPY VARCHAR2 --25
	,p_language			IN VARCHAR2	 DEFAULT USERENV('LANG')--26
);


PROCEDURE Is_Valid_Flex_Value(
	P_Api_Version_Number		IN     NUMBER
	,P_Init_Msg_List		IN     VARCHAR2
	,p_flex_value_set_id		IN     NUMBER
	,p_flex_value_code		IN     VARCHAR2
	,x_exists			OUT  NOCOPY VARCHAR2
	,X_Return_Status		OUT  NOCOPY VARCHAR2
	,X_Msg_Count			OUT  NOCOPY NUMBER
	,X_Msg_Data			OUT  NOCOPY VARCHAR2
);


-- Uses the Flex_value_set_id defined for the attributes and returns
-- the SQL corresponding to Flex Value set
--
PROCEDURE get_sql_from_flex(
	p_api_version_number		IN   NUMBER DEFAULT 1.0
	,p_init_msg_list		IN   VARCHAR2 DEFAULT Fnd_Api.g_false
	,p_flex_value_set_id     	IN   NUMBER --1
	,x_select        		OUT  NOCOPY VARCHAR2 --4
	,X_Return_Status		OUT NOCOPY  VARCHAR2 --6
	,X_Msg_Count			OUT NOCOPY  NUMBER -- 7
	,X_Msg_Data			OUT NOCOPY  VARCHAR2 -- 8
  );

END Ibc_Ctype_Pvt;

 

/
