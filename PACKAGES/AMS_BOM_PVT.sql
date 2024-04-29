--------------------------------------------------------
--  DDL for Package AMS_BOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_BOM_PVT" AUTHID CURRENT_USER as
/* $Header: amsvboms.pls 115.10 2002/11/15 21:02:03 abhola ship $ */
-- Start of Comments
-- Package name     : AMS_BOM_PVT
-- Purpose          : Wrapper on BOM APIs
-- History          : Created Sept 25 2000   ABHOLA
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call


    TYPE BOM_REC_TYPE IS RECORD
     (     Inventory_Item_Id            NUMBER := FND_API.G_MISS_NUM
         , Organization_Id              NUMBER := FND_API.G_MISS_NUM
	 , Alternate_Bom_Code		VARCHAR2(10)	:= FND_API.G_MISS_CHAR
	 , Assembly_Type		NUMBER		:= FND_API.G_MISS_NUM
	 , Transaction_Type		VARCHAR2(30)	:= FND_API.G_MISS_CHAR
	 , Return_Status		VARCHAR2(1)	:= FND_API.G_MISS_CHAR
	);

      G_MISS_BOM_REC_TYPE  BOM_REC_TYPE;

    TYPE BOM_COMP_REC_TYPE IS RECORD
	(  Start_Effective_Date		DATE		:= FND_API.G_MISS_DATE
	 , Disable_Date			DATE		:= FND_API.G_MISS_DATE
	 , Operation_Sequence_Number	NUMBER		:= FND_API.G_MISS_NUM
	 , Component_Item_Name		VARCHAR2(81)	:= FND_API.G_MISS_CHAR
         , Component_Item_Id            NUMBER          := FND_API.G_MISS_NUM
	 , Item_Sequence_Number		NUMBER		:= FND_API.G_MISS_NUM
	 , Quantity_Per_Assembly	NUMBER		:= FND_API.G_MISS_NUM
	 , Quantity_Related		NUMBER      	:= FND_API.G_MISS_NUM
	 , Return_Status     		VARCHAR2(1)    	:= FND_API.G_MISS_CHAR
    );

      G_MISS_BOM_COMP_REC_TYPE          BOM_COMP_REC_TYPE;

--      TYPE  BOM_COMP_Tbl_Type      IS TABLE OF BOM_COMP_REC_TYPE
--                                                INDEX BY BINARY_INTEGER;

--      G_MISS_BOM_COMP_Tbl_Type          BOM_COMP_Tbl_Type;

PROCEDURE Ams_Process_BOM(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_bom_rec_type               IN   BOM_REC_TYPE := G_MISS_BOM_REC_TYPE,

    P_bom_comp_rec_type          IN    BOM_COMP_REC_TYPE := G_MISS_BOM_COMP_REC_TYPE,

    P_Last_Update_Date           IN    DATE    := FND_API.G_MISS_DATE,
    P_Last_Update_By             IN    NUMBER  := FND_API.G_MISS_NUM
    );

End AMS_BOM_PVT;

 

/
