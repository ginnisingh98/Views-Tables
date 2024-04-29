--------------------------------------------------------
--  DDL for Package JTF_QUALIFIER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_QUALIFIER_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptrqs.pls 120.0 2005/06/02 18:20:53 appldev ship $ */

--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_QUALIFIER_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is a public API for inserting, updating and deleting
--      qualifier related information into JTF tables.
--      It contains specification for pl/sql records and tables
--      and the Public territory related API's.
--
--      Procedures:
--
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      07/15/99   JDOCHERT         Created
--      10/05/99   VNEDUNGA         Changing the record group
--                                  to accomodate schema changes
--      03/28/00   VNEDUNGA         Adding new columns for eliminating
--                                  dependency to AS_INTERESTS in
--                                  JTF_QUAL_USGS table
--
--    End of Comments


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Seeded qualifier record type: Seed_Qual_Rec_Type
--    ---------------------------------------------------
--
--   Notes
--
--
-- End of Comments
--


TYPE Seed_Qual_Rec_Type  IS RECORD
  (SEEDED_QUAL_ID           NUMBER          ,-- := FND_API.G_MISS_NUM,
   QUAL_TYPE_ID             NUMBER          ,-- := FND_API.G_MISS_NUM,
   LAST_UPDATE_DATE         DATE            ,-- := FND_API.G_MISS_DATE,
   LAST_UPDATED_BY          NUMBER          ,-- := FND_API.G_MISS_NUM,
   CREATION_DATE            DATE            ,-- := FND_API.G_MISS_DATE,
   CREATED_BY               NUMBER          ,-- := FND_API.G_MISS_NUM,
   LAST_UPDATE_LOGIN        NUMBER          ,-- := FND_API.G_MISS_NUM,
   NAME                     VARCHAR2(60)    ,-- := FND_API.G_MISS_CHAR,
   DESCRIPTION              VARCHAR2(240)   ,-- := FND_API.G_MISS_CHAR
   ORG_ID                   NUMBER
   );


TYPE Seed_Qual_Tbl_Type IS TABLE OF Seed_Qual_Rec_Type
  INDEX BY BINARY_INTEGER;

G_MISS_SEED_QUAL_REC           Seed_Qual_Rec_Type;

G_MISS_SEED_QUAL_TBL           Seed_Qual_Tbl_Type;


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Qualifier Usages All record type: Qual_Usgs_All_Rec_Type
--    ---------------------------------------------------
--
--   Notes
--
--
-- End of Comments
--
TYPE Qual_Usgs_All_Rec_Type  IS RECORD
  (
   QUAL_USG_ID               NUMBER        ,---:= FND_API.G_MISS_NUM,
   LAST_UPDATE_DATE          DATE          ,-- := FND_API.G_MISS_DATE,
   LAST_UPDATED_BY           NUMBER        ,-- := FND_API.G_MISS_NUM,
   CREATION_DATE             DATE          ,-- := FND_API.G_MISS_DATE,
   CREATED_BY                NUMBER        ,-- := FND_API.G_MISS_NUM,
   LAST_UPDATE_LOGIN         NUMBER        ,-- := FND_API.G_MISS_NUM,
   APPLICATION_SHORT_NAME    VARCHAR2(50)  ,-- := FND_API.G_MISS_CHAR,
   SEEDED_QUAL_ID            NUMBER        ,-- := FND_API.G_MISS_NUM,
   QUAL_TYPE_USG_ID          NUMBER        ,-- := FND_API.G_MISS_NUM,
   ENABLED_FLAG              VARCHAR2(1)   ,-- := FND_API.G_MISS_CHAR,
   QUAL_COL1                 VARCHAR2(30)  ,-- := FND_API.G_MISS_CHAR,
   QUAL_COL1_ALIAS           VARCHAR2(60)  ,-- := FND_API.G_MISS_CHAR,
   QUAL_COL1_DATATYPE        VARCHAR2(30)  ,-- := FND_API.G_MISS_CHAR,
   QUAL_COL1_TABLE           VARCHAR2(30)  ,-- := FND_API.G_MISS_CHAR,
   QUAL_COL1_TABLE_ALIAS     VARCHAR2(30)  ,-- := FND_API.G_MISS_CHAR,
   PRIM_INT_CDE_COL          VARCHAR2(30)  ,-- := FND_API.G_MISS_CHAR,
   PRIM_INT_CDE_COL_DATATYPE VARCHAR2(30)  ,-- := FND_API.G_MISS_CHAR,
   PRIM_INT_CDE_COL_ALIAS    VARCHAR2(60)  ,-- := FND_API.G_MISS_CHAR,
   SEC_INT_CDE_COL           VARCHAR2(30)  ,-- := FND_API.G_MISS_CHAR,
   SEC_INT_CDE_COL_ALIAS     VARCHAR2(30)  ,-- := FND_API.G_MISS_CHAR,
   sec_int_cde_col_datatype  VARCHAR2(30)  ,-- := FND_API.G_MISS_CHAR,
   INT_CDE_COL_TABLE         VARCHAR2(30)  ,-- := FND_API.G_MISS_CHAR,
   INT_CDE_COL_TABLE_ALIAS   VARCHAR2(30)  ,-- := FND_API.G_MISS_CHAR,
   SEEDED_FLAG               VARCHAR2(1)   ,-- := FND_API.G_MISS_CHAR,
   DISPLAY_TYPE              VARCHAR2(40)  ,-- := FND_API.G_MISS_CHAR,
   LOV_SQL                   VARCHAR2(1000) ,-- := FND_API.G_MISS_CHAR,
   CONVERT_TO_ID_FLAG        VARCHAR2(01)   ,-- := FND_API.G_MISS_CHAR
   COLUMN_COUNT              NUMBER         ,-- := FND_API.G_MISS_NUM
   FORMATTING_FUNCTION_FLAG  VARCHAR2(01)   ,-- := FND_API.G_MISS_CHAR
   FORMATTING_FUNCTION_NAME  VARCHAR2(120)  ,-- := FND_API.G_MISS_CHAR
   SPECIAL_FUNCTION_FLAG     VARCHAR2(01)   ,-- := FND_API.G_MISS_CHAR
   SPECIAL_FUNCTION_NAME     VARCHAR2(120)  ,-- := FND_API.G_MISS_CHAR
   ENABLE_LOV_VALIDATION     VARCHAR2(01)   ,-- := FND_API.G_MISS_CHAR
   DISPLAY_SQL1              VARCHAR2(1000) ,-- := FND_API.G_MISS_CHAR
   LOV_SQL2                  VARCHAR2(1000) ,-- := FND_API.G_MISS_CHAR
   DISPLAY_SQL2              VARCHAR2(1000) ,-- := FND_API.G_MISS_CHAR
   LOV_SQL3                  VARCHAR2(1000) ,-- := FND_API.G_MISS_CHAR
   DISPLAY_SQL3              VARCHAR2(1000) ,-- := FND_API.G_MISS_CHAR
   ORG_ID                    NUMBER,
   RULE1                     varchar2(2000) ,
   RULE2                     varchar2(2000) ,
   DISPLAY_SEQUENCE          number,
   DISPLAY_LENGTH            number,
   JSP_LOV_SQL               varchar2(2000),
   use_in_lookup_flag         VARCHAR2(1)
   );

TYPE Qual_Usgs_All_Tbl_Type IS TABLE OF Qual_Usgs_All_Rec_Type
  INDEX BY BINARY_INTEGER;

G_MISS_QUAL_USGS_ALL_REC           Qual_Usgs_All_Rec_Type;

G_MISS_QUAL_USGS_ALL_TBL           Qual_Usgs_All_Tbl_Type;


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Seeded Qualifier Out record type: Seed_Qual_Out_Rec_Type
--    ---------------------------------------------------
--       Attributes:
--       SEEDED_QUAL_ID
--       RETURN_STATUS
--
--   Notes
--
--
-- End of Comments
--
TYPE Seed_Qual_Out_Rec_Type  IS RECORD
  (SEEDED_QUAL_ID         NUMBER         , -- := FND_API.G_MISS_NUM_NUM,
   RETURN_STATUS          VARCHAR2(1)     -- := FND_API.G_MISS_NUM_CHAR
   );


TYPE Seed_Qual_Out_Tbl_Type IS TABLE OF Seed_Qual_Out_Rec_Type
  INDEX BY BINARY_INTEGER;

G_MISS_SEED_QUAL_OUT_REC           Seed_Qual_Out_Rec_Type;

G_MISS_SEED_QUAL_OUT_TBL_TYPE      Seed_Qual_Out_Tbl_Type;


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Qualifier Usages All Out record type: Qual_Usgs_All_Out_Rec_Type
--    ---------------------------------------------------
--
--   Notes
--
--
-- End of Comments
--
TYPE Qual_Usgs_All_Out_Rec_Type  IS RECORD
  (QUAL_USG_ID              NUMBER         , -- := FND_API.G_MISS_NUM,
   RETURN_STATUS            VARCHAR2(1)     -- := FND_API.G_MISS_CHAR
   );

TYPE Qual_Usgs_All_Out_Tbl_Type IS TABLE OF Qual_Usgs_All_Out_Rec_Type
  INDEX BY BINARY_INTEGER;

G_MISS_QUAL_USGS_ALL_OUT_REC           Qual_Usgs_All_Out_Rec_Type;

G_MISS_QUAL_USGS_ALL_OUT_TBL           Qual_Usgs_All_Out_Tbl_Type;




--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Create_Qualifier
--    Type      : PUBLIC
--    Function  : To create qualifiers
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name         Data Type                Default
--      p_api_version          NUMBER
--      p_Seed_Qual_Rec        Seed_Qual_Rec_Type       G_MISS_SEED_QUAL_REC
--      p_Qual_Usgs_Rec        Qual_Usgs_All_Rec_Type   G_MISS_QUAL_USGS_ALL_REC
--
--      Optional
--      Parameter Name         Data Type                Default
--      P_Init_Msg_List        VARCHAR2                 FND_API.G_FALSE
--      P_Commit               VARCHAR2                 FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name         Data Type                Default
--      x_Return_Status        VARCHAR2(1)
--      x_Msg_Count            NUMBER
--      x_Msg_Data             VARCHAR2(2000)
--      x_Seeded_Qual_Id       NUMBER
--      x_Qual_Usgs_Id         NUMBER
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_Qualifier
  (p_api_version         IN    NUMBER,
   --                                                   commented out eihsu 11/04
   p_Init_Msg_List       IN    VARCHAR2 ,-- := FND_API.G_FALSE,
   p_Commit              IN    VARCHAR2 ,-- := FND_API.G_FALSE,
   x_Return_Status       OUT NOCOPY   VARCHAR2,
   x_Msg_Count           OUT NOCOPY   NUMBER,
   x_Msg_Data            OUT NOCOPY   VARCHAR2,
   --                                                   commented out eihsu 11/04
   p_Seed_Qual_Rec       IN    Seed_Qual_Rec_Type     ,--:= G_MISS_SEED_QUAL_REC,
   p_Qual_Usgs_Rec       IN    Qual_Usgs_All_Rec_Type ,--:= G_MISS_QUAL_USGS_ALL_REC,
   x_Seed_Qual_Rec       OUT NOCOPY   Seed_Qual_Out_Rec_Type,
   x_Qual_Usgs_Rec       OUT NOCOPY   Qual_Usgs_All_Out_Rec_Type);


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Update_Qualifier
--    Type      : PUBLIC
--    Function  : To update existing qualifiers
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name         Data Type                Default
--      p_api_version          NUMBER
--      p_Seed_Qual_Rec        Seed_Qual_Rec_Type       G_MISS_SEED_QUAL_REC,
--      p_Qual_Usgs_Rec        Qual_Usgs_All_Rec_Type   G_MISS_QUAL_USGS_ALL_REC,
--
--      Optional
--      Parameter Name         Data Type                Default
--      P_Init_Msg_List        VARCHAR2                 FND_API.G_FALSE
--      P_Commit               VARCHAR2                 FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name         Data Type                Default
--      x_Return_Status        VARCHAR2(1)
--      x_Msg_Count            NUMBER
--      x_Msg_Data             VARCHAR2(2000)
--      x_Seed_Qual_Rec        Seed_Qual_Out_Rec_Type,
--      x_Qual_Usgs_Rec        Qual_Usgs_All_Out_Rec_Type);
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Update_Qualifier
  (p_api_version         IN    NUMBER,   --                                                   commented out eihsu 11/04
   p_Init_Msg_List       IN    VARCHAR2 ,-- := FND_API.G_FALSE,
   p_Commit              IN    VARCHAR2 ,-- := FND_API.G_FALSE,
   x_Return_Status       OUT NOCOPY   VARCHAR2,
   x_Msg_Count           OUT NOCOPY   NUMBER,
   x_Msg_Data            OUT NOCOPY   VARCHAR2,
   p_Seed_Qual_Rec       IN    Seed_Qual_Rec_Type         ,-- := G_MISS_SEED_QUAL_REC,
   p_Qual_Usgs_Rec       IN    Qual_Usgs_All_Rec_Type     ,-- := G_MISS_QUAL_USGS_ALL_REC,
   x_Seed_Qual_Rec       OUT NOCOPY   Seed_Qual_Out_Rec_Type,
   x_Qual_Usgs_Rec       OUT NOCOPY   Qual_Usgs_All_Out_Rec_Type);




--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Qualifier
--    Type      : PUBLIC
--    Function  : To delete an existing qualifiers
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name         Data Type            Default
--      p_api_version          NUMBER
--      p_Seeded_Qual_Id       NUMBER               FND_API.G_MISS_NUM,
--      p_Qual_Usgs_Id         NUMBER               FND_API.G_MISS_NUM);
--
--      Optional
--      Parameter Name         Data Type            Default
--      P_Init_Msg_List        VARCHAR2             FND_API.G_FALSE
--      P_Commit               VARCHAR2             FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name         Data Type            Default
--      x_Return_Status        VARCHAR2(1)
--      x_Msg_Count            NUMBER
--      x_Msg_Data             VARCHAR2(2000)
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Delete_Qualifier
  (p_api_version         IN    NUMBER,
   p_Init_Msg_List       IN    VARCHAR2 ,-- := FND_API.G_FALSE,
   p_Commit              IN    VARCHAR2 ,-- := FND_API.G_FALSE,
   x_Return_Status       OUT NOCOPY   VARCHAR2,
   x_Msg_Count           OUT NOCOPY   NUMBER,
   x_Msg_Data            OUT NOCOPY   VARCHAR2,
   p_Seeded_Qual_Id      IN    NUMBER   ,-- := FND_API.G_MISS_NUM,
   p_Qual_Usg_Id         IN    NUMBER   -- := FND_API.G_MISS_NUM
   );



END;  -- Package Specification JTF_QUALIFIER_PUB

 

/
