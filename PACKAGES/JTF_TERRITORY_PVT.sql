--------------------------------------------------------
--  DDL for Package JTF_TERRITORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERRITORY_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvters.pls 120.2.12010000.2 2009/09/07 06:30:39 vpalle ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager private api's.
--      This package is a public API for inserting territory
--      related information IN to information into JTF tables.
--      It contains specification for pl/sql records and tables
--      and the private territory related API's.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is for private use
--
--    HISTORY
--      06/09/99    VNEDUNGA         Created
--      07/15/99    JDOCHERT         Updated existing APIs and
--                                   added new APIs
--      06/09/99    VNEDUNGA         Commenting OUT NOCOPY FND_G_MISS for records def
--                                   because of the bug in forms PL/SQL
--      01/31/00    VNEDUNGA         Adding code for overlap check
--      03/15/00    VNEDUNGA         Changing the some validation routine specs
--	04/04/00    EIHSU	     Added Gen_Duplicate_Territory and relevant procs
--      06/14/00    VNEDUNGA         Changing the overlap exists function and
--                                   added rownum < 2 to function to return desc
--      07/08/00    JDOCHERT         Adding default values for flag, for data migration
--      09/09/00    jdochert         Added Unique validation for JTF_TERR_USGS_ALL + JTF_TERR_QTYPE_USGS_AL
--      09/17/00    JDOCHERT         BUG# 1408610 FIX: Added NUM_WINNERS to TERR_ALL_REC_TYPE
--      10/04/00    jdochert         Added validation for NUM_WINNERS
--      10/04/00    jdochert         Added NUM_QUAL to JTF_TERR_ALL_REC_TYPE record definition
--      10/04/01    arpatel          Added first_terr_node flag to Copy Territory
--      04/12/01    jdochert         Added PROCEDURE chk_num_copy_terr
--      04/20/01    arpatel          Added PROCEDURE Concurrent_Copy_Territory and Write_Log
--      04/28/01    arpatel          Added function conc_req_copy_terr returning number (concurrent request ID)
--      12/03/04    achanda          Added value4_id : bug # 3726007
--
--    End of Comments
--
--*******************************************************
--                     Composite Types
--*******************************************************
--
-- Start of Comments
---------------------------------------------------------

--        Winning Territory Record: WinningTerr_rec_type
--    ---------------------------------------------------
--    Parameters:
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

TYPE WinningTerr_rec_type         IS RECORD
    (
         TERR_ID                 NUMBER       := FND_API.G_MISS_NUM,
         RANK                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
         ORG_ID                  NUMBER       := FND_API.G_MISS_NUM,
         PARENT_TERRITORY_ID     NUMBER       := FND_API.G_MISS_NUM,
         TEMPLATE_TERRITORY_ID   NUMBER       := FND_API.G_MISS_NUM,
         ESCALATION_TERRITORY_ID NUMBER       := FND_API.G_MISS_NUM
    );

G_MISS_WINNINGTERR_REC            WinningTerr_rec_type;

TYPE WinningTerr_tbl_type         IS TABLE OF   WinningTerr_rec_type
                               INDEX BY BINARY_INTEGER;

G_MISS_WINNINGTERR_TBL            WinningTerr_tbl_type;


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Territory record type: Terr_All_Rec_Type
--    ---------------------------------------------------
--        Attributes:
--         TERR_ID
--         LAST_UPDATE_DATE
--         LAST_UPDATED_BY
--         CREATION_DATE
--         CREATED_BY
--         LAST_UPDATE_LOGIN
--         APPLICATION_SHORT_NAME
--         NAME
--         ENABLED_FLAG
--         REQUEST_ID
--         PROGRAM_APPLICATION_ID
--         PROGRAM_ID
--         PROGRAM_UPDATE_DATE
--         START_DATE_ACTIVE
--         RANK
--         END_DATE_ACTIVE
--         DESCRIPTION
--         ORG_ID
--         UPDATE_FLAG
--         AUTO_ASSIGN_MEMBERS_FLAG
--         PLANNED_FLAG
--         TERRITORY_TYPE_ID
--         PARENT_TERRITORY_ID
--         TEMPLATE_FLAG
--         TEMPLATE_TERRITORY_ID
--         ESCALATION_TERRITORY_FLAG
--         ESCALATION_TERRITORY_ID
--         OVERLAp_ALLOWED_FLAG
--         ATTRIBUTE_CATEGORY
--         ATTRIBUTE1
--         ATTRIBUTE2
--         ATTRIBUTE3
--         ATTRIBUTE4
--         ATTRIBUTE5
--         ATTRIBUTE6
--         ATTRIBUTE7
--         ATTRIBUTE8
--         ATTRIBUTE9
--         ATTRIBUTE10
--         ATTRIBUTE11
--         ATTRIBUTE12
--         ATTRIBUTE13
--         ATTRIBUTE14
--         ATTRIBUTE15
--         NUM_WINNERS
--         NUM_QUAL
--
--   Notes
--
--
-- End of Comments
--
TYPE Terr_All_Rec_Type  IS RECORD
  (TERR_ID                     NUMBER         ,   -- := FND_API.G_MISS_NUM,
   LAST_UPDATE_DATE            DATE           ,   -- := FND_API.G_MISS_DATE,
   LAST_UPDATED_BY             NUMBER         ,   -- := FND_API.G_MISS_NUM,
   CREATION_DATE               DATE           ,   -- := FND_API.G_MISS_DATE,
   CREATED_BY                  NUMBER         ,   -- := FND_API.G_MISS_NUM,
   LAST_UPDATE_LOGIN           NUMBER         ,   -- := FND_API.G_MISS_NUM,
   APPLICATION_SHORT_NAME      VARCHAR2(50)   ,   -- := FND_API.G_MISS_CHAR,
   NAME                        VARCHAR2(2000) ,   -- := FND_API.G_MISS_CHAR,
   ENABLED_FLAG                VARCHAR2(1)    ,   -- := FND_API.G_MISS_CHAR,
   REQUEST_ID                  NUMBER         ,   -- := FND_API.G_MISS_NUM,
   PROGRAM_APPLICATION_ID      NUMBER         ,   -- := FND_API.G_MISS_NUM,
   PROGRAM_ID                  NUMBER         ,   -- := FND_API.G_MISS_NUM,
   PROGRAM_UPDATE_DATE         DATE           ,   -- := FND_API.G_MISS_DATE,
   START_DATE_ACTIVE           DATE           ,   -- := FND_API.G_MISS_DATE,
   RANK                        NUMBER         ,   -- := FND_API.G_MISS_NUM,
   END_DATE_ACTIVE             DATE           ,   -- := FND_API.G_MISS_DATE,
   DESCRIPTION                 VARCHAR2(240)  ,   -- := FND_API.G_MISS_CHAR,
   UPDATE_FLAG                 VARCHAR2(1)    := 'Y',   -- := FND_API.G_MISS_CHAR,
   AUTO_ASSIGN_RESOURCES_FLAG  VARCHAR2(1)    ,   -- := FND_API.G_MISS_CHAR,
   PLANNED_FLAG                VARCHAR2(1)    ,   -- := FND_API.G_MISS_CHAR,
   TERRITORY_TYPE_ID           NUMBER         ,   -- := FND_API.G_MISS_NUM,
   PARENT_TERRITORY_ID         NUMBER         ,   -- := FND_API.G_MISS_NUM,
   TEMPLATE_FLAG               VARCHAR2(1)    := 'N',   -- := FND_API.G_MISS_CHAR,
   TEMPLATE_TERRITORY_ID       NUMBER         ,   -- := FND_API.G_MISS_NUM,
   ESCALATION_TERRITORY_FLAG   VARCHAR2(1)    := 'N',   -- := FND_API.G_MISS_CHAR,
   ESCALATION_TERRITORY_ID     NUMBER         ,   -- := FND_API.G_MISS_NUM,
   OVERLAp_ALLOWED_FLAG        VARCHAR2(1)    ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE_CATEGORY          VARCHAR2(30)   ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE1                  VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE2                  VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE3                  VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE4                  VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE5                  VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE6                  VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE7                  VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE8                  VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE9                  VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE10                 VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE11                 VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE12                 VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE13                 VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE14                 VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR,
   ATTRIBUTE15                 VARCHAR2(150)  ,   -- := FND_API.G_MISS_CHAR
   ORG_ID                      NUMBER ,            -- := FND_API.G_MISS_NUM,
   NUM_WINNERS                 NUMBER,
   NUM_QUAL                    NUMBER         := 0,
   TERR_CREATION_FLAG          VARCHAR2(1) := NULL,
   TERRITORY_GROUP_ID          NUMBER :=NULL
  );

TYPE Terr_All_Tbl_Type IS TABLE OF Terr_All_Rec_Type
                          INDEX BY BINARY_INTEGER;

G_MISS_Terr_All_Rec       Terr_All_Rec_Type;

G_MISS_Terr_All_Tbl       Terr_All_Tbl_Type;

--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--
--   Terr_Qual_Rec_Type
--        Attributes:
--         TERR_QUAL_ID
--         TERR_ID
--         SEEDED_QUAL_ID
--         LAST_UPDATE_DATE
--         LAST_UPDATED_BY
--         CREATION_DATE
--         CREATED_BY
--         LAST_UPDATE_LOGIN
--         GENERATE_FLAG
--         NAME_FLAG
--         OVERLAp_ALLOWED_FLAG
--
--   Notes
--
--
-- End of Comments
--
TYPE Terr_Qual_Rec_Type  IS RECORD
  (  Rowid                         VARCHAR2(50) ,   -- := FND_API.G_MISS_CHAR,
     TERR_QUAL_ID                  NUMBER       ,   -- := FND_API.G_MISS_NUM,
     LAST_UPDATE_DATE              DATE         ,   -- := FND_API.G_MISS_DATE,
     LAST_UPDATED_BY               NUMBER       ,   -- := FND_API.G_MISS_NUM,
     CREATION_DATE                 DATE         ,   -- := FND_API.G_MISS_DATE,
     CREATED_BY                    NUMBER       ,   -- := FND_API.G_MISS_NUM,
     LAST_UPDATE_LOGIN             NUMBER       ,   -- := FND_API.G_MISS_NUM,
     TERR_ID                       NUMBER       ,   -- := FND_API.G_MISS_NUM,
     QUAL_USG_ID                   NUMBER       ,   -- := FND_API.G_MISS_NUM,
     USE_TO_NAME_FLAG              VARCHAR2(1)  ,   -- := FND_API.G_MISS_CHAR,
     GENERATE_FLAG                 VARCHAR2(1)  ,   -- := FND_API.G_MISS_CHAR,
     OVERLAP_ALLOWED_FLAG          VARCHAR2(1)  := 'Y',   -- := FND_API.G_MISS_CHAR,
     QUALIFIER_MODE                VARCHAR2(30) ,   -- := FND_API.G_MISS_CHAR,
     ORG_ID                        NUMBER           -- := FND_API.G_MISS_NUM
   );

TYPE Terr_Qual_Tbl_Type IS TABLE OF Terr_Qual_Rec_Type
                           INDEX BY BINARY_INTEGER;

G_MISS_Terr_Qual_Rec       Terr_Qual_Rec_Type;

G_MISS_Terr_Qual_Tbl       Terr_Qual_Tbl_Type;

--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Territory values record type: Terr_Values_Rec_Type
--    ---------------------------------------------------
--        Attributes:
--            TERR_VALUE_ID
--            LAST_UPDATE_DATE
--            LAST_UPDATED_BY
--            CREATION_DATE
--            CREATED_BY
--            LAST_UPDATE_LOGIN
--            TERR_QUAL_ID
--            INCLUDE_FLAG
--            COMPARISON_OPERATOR
--            LOW_VALUE_CHAR
--            HIGH_VALUE_CHAR
--            LOW_VALUE_NUMBER
--            HIGH_VALUE_NUMBER
--            INTEREST_TYPE_ID
--            PRIMARY_INTEREST_CODE_ID
--            SECONDARY_INTEREST_CODE_ID
--            ORG_ID
--            CURRENCY_CODE
--            VALUE_SET
--
--
--   Notes
--
--
-- End of Comments
--
TYPE Terr_Values_Rec_Type  IS RECORD
 (TERR_VALUE_ID                    NUMBER       ,   -- := FND_API.G_MISS_NUM,
  LAST_UPDATE_DATE                 DATE         ,   -- := FND_API.G_MISS_DATE,
  LAST_UPDATED_BY                  NUMBER       ,   -- := FND_API.G_MISS_NUM,
  CREATION_DATE                    DATE         ,   -- := FND_API.G_MISS_DATE,
  CREATED_BY                       NUMBER       ,   -- := FND_API.G_MISS_NUM,
  LAST_UPDATE_LOGIN                NUMBER       ,   -- := FND_API.G_MISS_NUM,
  TERR_QUAL_ID                     NUMBER       ,   -- := FND_API.G_MISS_NUM,
  INCLUDE_FLAG                     VARCHAR2(15) ,   -- := FND_API.G_MISS_CHAR,
  COMPARISON_OPERATOR              VARCHAR2(30) ,   -- := FND_API.G_MISS_CHAR,
  LOW_VALUE_CHAR                   VARCHAR2(360) ,   -- := FND_API.G_MISS_CHAR,
  HIGH_VALUE_CHAR                  VARCHAR2(360) ,   -- := FND_API.G_MISS_CHAR,
  LOW_VALUE_NUMBER                 NUMBER       ,   -- := FND_API.G_MISS_NUM,
  HIGH_VALUE_NUMBER                NUMBER       ,   -- := FND_API.G_MISS_NUM,
  VALUE_SET                        NUMBER       ,   -- := FND_API.G_MISS_NUM,
  INTEREST_TYPE_ID                 NUMBER       ,   -- := FND_API.G_MISS_NUM,
  PRIMARY_INTEREST_CODE_ID         NUMBER       ,   -- := FND_API.G_MISS_NUM,
  SECONDARY_INTEREST_CODE_ID       NUMBER       ,   -- := FND_API.G_MISS_NUM,
  CURRENCY_CODE                    VARCHAR2(15) ,   -- := FND_API.G_MISS_CHAR,
  ID_USED_FLAG                     VARCHAR2(1)  ,   -- := FND_API.G_MISS_CHAR,
  LOW_VALUE_CHAR_ID                NUMBER       ,   -- := FND_API.G_MISS_NUM,
  QUALIFIER_TBL_INDEX              NUMBER       ,   -- := FND_API.G_MISS_NUM,
  ORG_ID                           NUMBER       ,    -- := FND_API.G_MISS_NUM
  CNR_GROUP_ID                     NUMBER       ,
  VALUE1_ID                        NUMBER       ,
  VALUE2_ID                        NUMBER       ,
  VALUE3_ID                        NUMBER       ,
  VALUE4_ID                        NUMBER
 );

TYPE Terr_Values_Tbl_Type IS TABLE OF Terr_Values_Rec_Type
                             INDEX BY BINARY_INTEGER;

G_MISS_Terr_Values_Rec       Terr_Values_Rec_Type;

G_MISS_Terr_Values_Tbl       Terr_Values_Tbl_Type;


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Territory source Record: terr_Usgs_rec_type
--    ---------------------------------------------------
--    Parameters:
--
--    Required:
--        TERR_USG_ID           -- primary key sequence
--        SOURCE_ID             -- Source identifier
--        TERR_ID               -- Territory identifier
--        LAST_UPDATE_DATE      -- Part of std who columns
--        LAST_UPDATED_BY       -- Part of std who columns
--        CREATION_DATE         -- Part of std who columns
--        CREATED_BY            -- Part of std who columns
--        LAST_UPDATE_LOGIN     -- Part of std who columns
--
--    Defaults:
--    Note:
--
-- End of Comments

TYPE terr_usgs_rec_type        IS RECORD
    (
       TERR_USG_ID              NUMBER    ,   -- := FND_API.G_MISS_NUM,
       SOURCE_ID                NUMBER    ,   -- := FND_API.G_MISS_NUM,
       TERR_ID                  NUMBER    ,   -- := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE         DATE      ,   -- := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY          NUMBER    ,   -- := FND_API.G_MISS_NUM,
       CREATION_DATE            DATE      ,   -- := FND_API.G_MISS_DATE,
       CREATED_BY               NUMBER    ,   -- := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN        NUMBER    ,   -- := FND_API.G_MISS_NUM,
       ORG_ID                   NUMBER        -- := FND_API.G_MISS_NUM

    );

G_MISS_TERR_USGS_REC            terr_usgs_rec_type;

TYPE terr_usgs_tbl_type         IS TABLE OF   terr_usgs_rec_type
                               INDEX BY BINARY_INTEGER;

G_MISS_TERR_USGS_TBL            terr_usgs_tbl_type;


--    *************************************************************
--    Start of Comments
--    -------------------------------------------------------------
--     Territory qualifier Type Record: TerrQualTypeUsgs_rec_type
--    -------------------------------------------------------------
--    Parameters:
--
--    Required:
--        TYPE_QUAL_TYPE_USG_ID    -- Primary Key sequence
--        TERR_TYPE_USG_ID         -- Source source id
--        QUAL_TYPE_USG_ID         -- Type identifier
--        LAST_UPDATE_DATE         -- Part of std who columns
--        LAST_UPDATED_BY          -- Part of std who columns
--        CREATION_DATE            -- Part of std who columns
--        CREATED_BY               -- Part of std who columns
--        LAST_UPDATE_LOGIN        -- Part of std who columns
--
--    Defaults:
--    Note:
--
-- End of Comments

TYPE terr_qualtypeusgs_rec_type         IS RECORD
    (
       TERR_QUAL_TYPE_USG_ID         NUMBER    ,   -- := FND_API.G_MISS_NUM,
       TERR_ID                       NUMBER    ,   -- := FND_API.G_MISS_NUM,
       QUAL_TYPE_USG_ID              NUMBER    ,   -- := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE              DATE      ,   -- := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY               NUMBER    ,   -- := FND_API.G_MISS_NUM,
       CREATION_DATE                 DATE      ,   -- := FND_API.G_MISS_DATE,
       CREATED_BY                    NUMBER    ,   -- := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN             NUMBER    ,   -- := FND_API.G_MISS_NUM,
       ORG_ID                        NUMBER        -- := FND_API.G_MISS_NUM
    );

G_MISS_TERR_QUALTYPEUSGS_REC     terr_qualtypeusgs_rec_type;

TYPE terr_qualtypeusgs_tbl_type  IS TABLE OF   terr_qualtypeusgs_rec_type
                                 INDEX BY BINARY_INTEGER;

G_MISS_TERR_QUALTYPEUSGS_TBL     Terr_QualTypeUsgs_tbl_type;


--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory OUT NOCOPY Record:   terr_all_out_rec
--    -----------------------------------------------------------
--    Parameters:
--
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

TYPE terr_all_out_rec_type   IS RECORD
    (
       TERR_ID                       NUMBER        ,--:= FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  --:= FND_API.G_MISS_CHAR
    );

G_MISS_TERR_ALL_OUT_REC              terr_all_out_rec_type;


TYPE   Terr_All_out_tbl_type         IS TABLE OF   terr_all_out_rec_type
                                     INDEX BY BINARY_INTEGER;

G_MISS_TERR_ALL_OUT_TBL              Terr_All_out_tbl_type;


--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory usages OUT NOCOPY Record:   terr_usgs_out_rec_type
--    -----------------------------------------------------------
--    Parameters:
--
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

TYPE Terr_Usgs_out_rec_type   IS RECORD
    (
       TERR_USG_ID                   NUMBER        ,--:= FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  --:= FND_API.G_MISS_CHAR
    );

G_MISS_TERR_USGS_OUT_REC             terr_usgs_out_rec_type;

TYPE   Terr_Usgs_out_tbl_type        IS TABLE OF   terr_usgs_out_rec_type
                                     INDEX BY BINARY_INTEGER;
G_MISS_TERR_USGS_OUT_TBL             Terr_Usgs_out_tbl_type;


--    ****************************************************************
--    Start of Comments
--    ----------------------------------------------------------------
--     Territory qualifier type OUT NOCOPY Record: terr_QualTypeUsgs_out_rec
--    ----------------------------------------------------------------
--    Parameters:
--
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

TYPE terr_QualTypeUsgs_out_rec_type   IS RECORD
    (
       TERR_QUAL_TYPE_USG_ID         NUMBER        ,--:= FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  --:= FND_API.G_MISS_CHAR
    );

G_MISS_TERRQUALTYPUSGS_OUT_REC       terr_QualTypeUsgs_out_rec_type;

TYPE Terr_QualTypeUsgs_Out_Tbl_Type  IS TABLE OF   terr_QualTypeUsgs_out_rec_type
                                     INDEX BY BINARY_INTEGER;
G_MISS_TERRQUALTYPUSGS_OUT_TBL       Terr_QualTypeUsgs_Out_Tbl_Type;

--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory qualifiers OUT NOCOPY Record:   terr_Oual_out_rec_Type
--    -----------------------------------------------------------
--    Parameters:
--
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

TYPE Terr_Qual_out_rec_type   IS RECORD
    (
       TERR_QUAL_ID                  NUMBER        ,--:= FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  --:= FND_API.G_MISS_CHAR
    );

G_MISS_TERR_QUAL_OUT_REC             Terr_Qual_out_rec_type;

TYPE   Terr_Qual_out_tbl_type        IS TABLE OF   Terr_Qual_out_rec_type
                                     INDEX BY BINARY_INTEGER;
G_MISS_TERR_QUAL_OUT_TBL             Terr_Qual_Out_tbl_type;


--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory values OUT NOCOPY Record:   terr_values_out_rec_type
--    -----------------------------------------------------------
--    Parameters:
--
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

TYPE Terr_Values_out_rec_type   IS RECORD
    (
       TERR_VALUE_ID                 NUMBER        ,-- := FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  -- := FND_API.G_MISS_CHAR
    );

G_MISS_TERR_VALUES_OUT_REC           terr_values_out_rec_type;


TYPE   Terr_Values_out_tbl_type      IS TABLE OF   terr_values_out_rec_type
                                     INDEX BY BINARY_INTEGER;

G_MISS_TERR_VALUES_OUT_TBL           Terr_Values_out_tbl_type;


--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Territory
--    Type      : PUBLIC
--    Function  : To create Territories - which inludes the creation of following
--                Territory Header, Territory Qualifier, terr Usages, qualifier type usages
--                Territory Qualifier Values and Assign Resources
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_All_Rec                Terr_All_Rec_Type           := G_Miss_Terr_All_Rec
--      p_Terr_Usgs_Tbl               Terr_Usgs_Tbl_Type          := G_MISS_Terr_Usgs_Tbl
--      p_Terr_QualTypeUsgs_Tbl       Terr_QualTypeUsgs_Tbl_Type  := G_Miss_Terr_QualTypeUsgs_Tbl
--      p_Terr_Qual_Tbl               Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_Terr_Id                     NUMBER
--      x_Terr_Usgs_Out_Tbl           Terr_Usgs_Out_Tbl,
--      x_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl,
--      x_Terr_Qual_Out_Tbl           Terr_Qual_Out_Tbl,
--      x_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_Territory
 (p_Api_Version_Number          IN  NUMBER,
  p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
  p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
  x_Return_Status               OUT NOCOPY VARCHAR2,
  x_Msg_Count                   OUT NOCOPY NUMBER,
  x_Msg_Data                    OUT NOCOPY VARCHAR2,
  p_Terr_All_Rec                IN  Terr_All_Rec_Type           := G_Miss_Terr_All_Rec,
  p_Terr_Usgs_Tbl               IN  Terr_Usgs_Tbl_Type          := G_MISS_Terr_Usgs_Tbl,
  p_Terr_QualTypeUsgs_Tbl       IN  Terr_QualTypeUsgs_Tbl_Type  := G_Miss_Terr_QualTypeUsgs_Tbl,
  p_Terr_Qual_Tbl               IN  Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl,
  p_Terr_Values_Tbl             IN  Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl,
  x_Terr_Id                     OUT NOCOPY NUMBER,
  x_Terr_Usgs_Out_Tbl           OUT NOCOPY Terr_Usgs_Out_Tbl_Type,
  x_Terr_QualTypeUsgs_Out_Tbl   OUT NOCOPY Terr_QualTypeUsgs_Out_Tbl_Type,
  x_Terr_Qual_Out_Tbl           OUT NOCOPY Terr_Qual_Out_Tbl_Type,
  x_Terr_Values_Out_Tbl         OUT NOCOPY Terr_Values_Out_Tbl_Type);


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Territory
--    Type      : PUBLIC
--    Function  : To delete Territories - which would also delete
--                Territory Header, Territory Qualifier,
--                Territory Qualifier Values and Resources.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_Terr_Id                  NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name             Data Type
--      X_Return_Status            VARCHAR2(1)
--      X_Msg_Count                NUMBER
--      X_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--          Rules for deletion have to be very strict.
--
--    End of Comments
--
PROCEDURE Delete_Territory
 (p_Api_Version_Number      IN NUMBER,
  p_Init_Msg_List           IN VARCHAR2 := FND_API.G_FALSE,
  p_Commit                  IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
  X_Return_Status           OUT NOCOPY VARCHAR2,
  X_Msg_Count               OUT NOCOPY NUMBER,
  X_Msg_Data                OUT NOCOPY VARCHAR2,
  p_Terr_Id                 IN NUMBER);


--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Territory
--    Type      : PUBLIC
--    Function  : To update existINg Territories - which includes updates to the following tables
--                Territory Header, Territory Qualifier, terr Usages, qualifier type usages
--                Territory Qualifier Values and Assign Resources
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_All_Rec                Terr_All_Rec_Type           := G_Miss_Terr_All_Rec
--      p_Terr_Usgs_Tbl               Terr_Usgs_Tbl_Type          := G_MISS_Terr_Usgs_Tbl
--      p_Terr_QualTypeUsgs_Tbl       Terr_QualTypeUsgs_Tbl_Type  := G_Miss_Terr_QualTypeUsgs_Tbl
--      p_Terr_Qual_Tbl               Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_Msg_Count                   NUMBER
--      X_Msg_Data                    VARCHAR2(2000)
--      X_Terr_All_Out_Rec            Terr_All_Out_Rec
--      X_Terr_Usgs_Out_Tbl           Terr_Usgs_Out_Tbl,
--      X_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl,
--      X_Terr_Qual_Out_Tbl           Terr_Qual_Out_Tbl,
--      X_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Update_Territory
 (p_Api_Version_Number          IN  NUMBER,
  p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
  p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  p_Terr_All_Rec                IN  Terr_All_Rec_Type           := G_Miss_Terr_All_Rec,
--  p_Terr_Usgs_Tbl               IN  Terr_Usgs_Tbl_Type          := G_MISS_Terr_Usgs_Tbl,
--  p_Terr_QualTypeUsgs_Tbl       IN  Terr_QualTypeUsgs_Tbl_Type  := G_Miss_Terr_QualTypeUsgs_Tbl,
--  p_Terr_Qual_Tbl               IN  Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl,
--  p_Terr_Values_Tbl             IN  Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl,
  X_Terr_All_Out_Rec            OUT NOCOPY Terr_All_Out_Rec_Type
--  X_Terr_Usgs_Out_Tbl           OUT NOCOPY Terr_Usgs_Out_Tbl_Type,
--  X_Terr_QualTypeUsgs_Out_Tbl   OUT NOCOPY Terr_QualTypeUsgs_Out_Tbl_Type,
--  X_Terr_Qual_Out_Tbl           OUT NOCOPY Terr_Qual_Out_Tbl_Type,
--  X_Terr_Values_Out_Tbl         OUT NOCOPY Terr_Values_Out_Tbl_Type
);


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Deactivate_Territory
--    Type      : PUBLIC
--    Function  : To deactivate Territories - this API also deactivates
--                any sub-territories of this territory.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_Terr_Id                  NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name             Data Type
--      x_Return_Status            VARCHAR2(1)
--      x_Msg_Count                NUMBER
--      x_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Deactivate_Territory
 (p_api_version_number      IN NUMBER,
  p_INit_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN  NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  P_terr_id                 IN NUMBER);

--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_Header
--    Type      : PUBLIC
--    Function  : To create Territories - which inludes the creation of following
--                Territory Header, Territory Usages, Territory qualifier type usages
--                table.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_Api_Version_Number          NUMBER
--      P_Terr_All_Rec                Terr_All_Rec_Type                := G_Miss_Terr_All_Rec
--      P_Terr_Usgs_Tbl               Terr_Usgs_Tbl_Type               := G_MISS_Terr_Usgs_Tbl
--      P_Terr_QualTypeUsgs_Tbl       Terr_QualTypeUsgs_Tbl_Type       := G_Miss_Terr_QualTypeUsgs_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      P_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      P_Commit                      VARCHAR2                         := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_Msg_Count                   NUMBER
--      X_Msg_Data                    VARCHAR2(2000)
--      X_Terr_All_Out_Rec            Terr_All_Out_Rec
--      X_Terr_Usgs_Out_Tbl           Terr_Usgs_Out_Tbl,
--      X_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl,
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_Territory_Header
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_All_Rec                IN  Terr_All_Rec_Type                := G_Miss_Terr_All_Rec,
  P_Terr_Usgs_Tbl               IN  Terr_Usgs_Tbl_Type               := G_MISS_Terr_Usgs_Tbl,
--  P_Terr_QualTypeUsgs_Tbl       IN  Terr_QualTypeUsgs_Tbl_Type       := G_Miss_Terr_QualTypeUsgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_All_Out_Rec            OUT NOCOPY Terr_All_Out_Rec_Type,
  X_Terr_Usgs_Out_Tbl           OUT NOCOPY Terr_Usgs_Out_Tbl_Type,
  X_Terr_QualTypeUsgs_Out_Tbl   OUT NOCOPY Terr_QualTypeUsgs_Out_Tbl_Type);

PROCEDURE Create_Territory_Record
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_All_Rec                IN  Terr_All_Rec_Type                := G_Miss_Terr_All_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Id                     OUT NOCOPY NUMBER,
  X_Terr_All_Out_Rec            OUT NOCOPY Terr_All_Out_Rec_Type
);


PROCEDURE Create_Territory_Usages
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  P_Terr_Usgs_Tbl               IN  Terr_Usgs_Tbl_Type               := G_MISS_Terr_Usgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Usgs_Out_Tbl           OUT NOCOPY Terr_Usgs_Out_Tbl_Type
);


PROCEDURE Create_Terr_QualType_Usage
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  P_Terr_QualTypeUsgs_Rec       IN  Terr_QualTypeUsgs_Rec_Type       := G_Miss_Terr_QualTypeUsgs_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_QualTypeUsgs_Id        OUT NOCOPY NUMBER,
  X_Terr_QualTypeUsgs_Out_Rec   OUT NOCOPY Terr_QualTypeUsgs_Out_Rec_Type);


PROCEDURE Create_Terr_QualType_Usage
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  P_Terr_QualTypeUsgs_Tbl       IN  Terr_QualTypeUsgs_Tbl_Type       := G_Miss_Terr_QualTypeUsgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_QualTypeUsgs_Out_Tbl   OUT NOCOPY Terr_QualTypeUsgs_Out_Tbl_Type);


PROCEDURE Create_Terr_Qualifier
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  P_Terr_Qual_Rec               IN  Terr_Qual_Rec_Type     := G_Miss_Terr_Qual_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Qual_Id                OUT NOCOPY NUMBER,
  X_Terr_Qual_Out_Rec           OUT NOCOPY Terr_Qual_Out_Rec_Type);

PROCEDURE Create_Terr_Qualifier
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  P_Terr_Qual_Tbl               IN  Terr_Qual_Tbl_Type               := G_Miss_Terr_Qual_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Qual_Out_Tbl           OUT NOCOPY Terr_Qual_Out_Tbl_Type);

PROCEDURE Create_Terr_qualifier
  (
    p_Api_Version_Number  IN  NUMBER,
    p_Init_Msg_List       IN  VARCHAR2 := FND_API.G_FALSE,
    p_Commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_Return_Status       OUT NOCOPY VARCHAR2,
    x_Msg_Count           OUT NOCOPY NUMBER,
    x_Msg_Data            OUT NOCOPY VARCHAR2,
    P_Terr_Qual_Rec       IN  Terr_Qual_Rec_Type := G_Miss_Terr_Qual_Rec,
    p_Terr_Values_Tbl     IN  Terr_Values_Tbl_Type := G_Miss_Terr_Values_Tbl,
    X_Terr_Qual_Out_Rec   OUT NOCOPY Terr_Qual_Out_Rec_Type,
    x_Terr_Values_Out_Tbl OUT NOCOPY Terr_Values_Out_Tbl_Type  );

PROCEDURE Create_Terr_Value
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  p_terr_qual_id                IN  NUMBER,
  P_Terr_Value_Rec              IN  Terr_Values_Rec_Type     := G_Miss_Terr_Values_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Value_Id               OUT NOCOPY NUMBER,
  X_Terr_Value_Out_Rec          OUT NOCOPY Terr_Values_Out_Rec_Type);


PROCEDURE Create_Terr_Value
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Id                     IN  NUMBER,
  p_terr_qual_id                IN  NUMBER,
  P_Terr_Value_Tbl              IN  Terr_Values_Tbl_Type             := G_Miss_Terr_Values_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Value_Out_Tbl          OUT NOCOPY Terr_Values_Out_Tbl_Type);


PROCEDURE Update_Territory_Record
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_All_Rec                IN  Terr_All_Rec_Type                := G_Miss_Terr_All_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_All_Out_Rec            OUT NOCOPY Terr_All_Out_Rec_Type
);

PROCEDURE Update_Territory_Usages
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Usgs_Rec               IN  Terr_Usgs_Rec_Type  := G_MISS_TERR_USGS_REC,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Usgs_Out_Rec           OUT NOCOPY Terr_Usgs_Out_Rec_Type);

PROCEDURE Update_Territory_Usages
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Usgs_Tbl               IN  Terr_Usgs_Tbl_Type               := G_MISS_Terr_Usgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Usgs_Out_Tbl           OUT NOCOPY Terr_Usgs_Out_Tbl_Type
);

PROCEDURE Update_Terr_QualType_Usage
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_QualTypeUsgs_Rec       IN  Terr_QualTypeUsgs_Rec_Type       := G_Miss_Terr_QualTypeUsgs_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_QualTypeUsgs_Out_Rec   OUT NOCOPY Terr_QualTypeUsgs_Out_Rec_Type
);

PROCEDURE Update_Terr_QualType_Usage
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_QualTypeUsgs_Tbl       IN  Terr_QualTypeUsgs_Tbl_Type       := G_Miss_Terr_QualTypeUsgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_QualTypeUsgs_Out_Tbl   OUT NOCOPY Terr_QualTypeUsgs_Out_Tbl_Type
);

PROCEDURE Update_Terr_Qualifier
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Qual_Rec               IN  Terr_Qual_Rec_Type               := G_Miss_Terr_Qual_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Qual_Out_Rec           OUT NOCOPY Terr_Qual_Out_Rec_Type
);

PROCEDURE Update_Terr_Qualifier
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Qual_Tbl               IN  Terr_Qual_Tbl_Type               := G_Miss_Terr_Qual_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Qual_Out_Tbl           OUT NOCOPY Terr_Qual_Out_Tbl_Type
);

PROCEDURE Update_Terr_Value
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Value_Rec              IN  Terr_Values_Rec_Type             := G_Miss_Terr_Values_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Value_Out_Rec          OUT NOCOPY Terr_Values_Out_Rec_Type
);


--Overloaded to take table type input parameter
PROCEDURE Update_Terr_Value
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_Terr_Value_Tbl              IN  Terr_Values_Tbl_Type             := G_Miss_Terr_Values_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_Terr_Value_Out_Tbl          OUT NOCOPY Terr_Values_Out_Tbl_Type
);


PROCEDURE Delete_territory_Record
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_Terr_Id                    IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2);

PROCEDURE Delete_Territory_Usages
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_Terr_usg_Id                IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2);

PROCEDURE Delete_Terr_QualType_Usage
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_Terr_Qual_Type_Usg_Id      IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2);

PROCEDURE Delete_Terr_Qualifier
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_Terr_Qual_Id               IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2);


PROCEDURE Delete_Terr_Value
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_Terr_Value_Id              IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2);
----------------------------------------------------------------------
-- A generic routine to validate foreign keys
----------------------------------------------------------------------
PROCEDURE Validate_Foreign_Key
  (p_Terr_All_Rec                IN  Terr_All_Rec_Type      := G_Miss_Terr_All_Rec,
   p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2 );

----------------------------------------------------------------------
-- This procedure will check whether the qualifiers passed are
-- valid.
----------------------------------------------------------------------
PROCEDURE Validate_Qualifier
  (p_Terr_Id                     IN  NUMBER,
   P_Terr_Qual_Rec               IN  Terr_Qual_Rec_Type     := G_Miss_Terr_Qual_Rec,
   p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2 );

---------------------------------------------------------------------
--                Validae the Territory record
---------------------------------------------------------------------
-- Columns Validated
--         Validate the foreign key if specified
--         Validate to make sure the territory name is specified and is not duplicate
--         Validate start date , end date , org_id , parent terr_id and Rank.
---------------------------------------------------------------------
PROCEDURE Validate_Territory_Record
  (p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_Terr_All_Rec                IN  Terr_All_Rec_Type      := G_Miss_Terr_All_Rec);

---------------------------------------------------------------------
--                Validae the Territory record while updation
---------------------------------------------------------------------
-- Columns Validated
--         Validate the foreign key if specified
--         Validate to make sure the territory name is specified and is not duplicate
--         Validate start date and end date
---------------------------------------------------------------------
PROCEDURE Validate_TerrRec_Update
  (p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_Terr_All_Rec                IN  Terr_All_Rec_Type      := G_Miss_Terr_All_Rec);


---------------------------------------------------------------------
--                Validae the Territory Usage
---------------------------------------------------------------------
-- Columns Validated
--         Make sure a Territory Usage is specified
--         Make sure the Territory Id is valid
--         Make sure the territory usage Id is Valid
---------------------------------------------------------------------
PROCEDURE Validate_Territory_Usage
  (p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_Terr_Usgs_Rec               IN  Terr_Usgs_Rec_Type     := G_MISS_Terr_Usgs_Rec,
   p_Terr_Id                     IN  NUMBER);


---------------------------------------------------------------------
--             Validate the Territory Qualifer Type Usage
---------------------------------------------------------------------
-- Columns Validated
--         Make sure a Territory Qual Type Usage is specified
--         Make sure the Territory Id is valid
--         Make sure the QUAL_TYPE_USG_ID is valid
---------------------------------------------------------------------
PROCEDURE Validate_Terr_Qtype_Usage
  (p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_Terr_QualTypeUsgs_Rec       IN  Terr_QualTypeUsgs_Rec_Type  := G_Miss_Terr_QualTypeUsgs_Rec,
   p_Terr_Id                     IN  NUMBER);

---------------------------------------------------------------------
--          Validate the Territory Qualifer Values passed in
---------------------------------------------------------------------
-- Columns Validated
--         Make sure the values are in the right columns as per the
--         qualifer setup
--         Eg:
--               If the qualifer, diplay_type    = 'CHAR' and
--                                col1_data_type =  'NUMBER'
--               then make sure the ID is passed in LOW_VALUE_CHAR_ID
--
--
---------------------------------------------------------------------
PROCEDURE Validate_terr_Value_Rec
  (p_init_msg_list               IN  VARCHAR2              := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_terr_qual_id                IN  NUMBER,
   p_Terr_Value_Rec              IN  Terr_Values_Rec_Type  := G_Miss_Terr_Values_Rec);



   -- CHECK FOR DUPLICATES VALUES
   --
PROCEDURE Check_duplicate_Value
  (p_init_msg_list               IN  VARCHAR2              := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_Terr_Qual_Id                IN  NUMBER,
   p_Terr_Value_Rec              IN  Terr_Values_Rec_Type  := G_Miss_Terr_Values_Rec) ;

   -- CHECK FOR DUPLICATES VALUES
   --
PROCEDURE Check_duplicate_Value_update
  (p_init_msg_list               IN  VARCHAR2              := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_Terr_Qual_Id                IN  NUMBER,
   p_Terr_Value_Rec              IN  Terr_Values_Rec_Type  := G_Miss_Terr_Values_Rec) ;

---------------------------------------------------------------------
--             Get_Max_Rank
---------------------------------------------------------------------
--
--         Gets the maximum rank of a particular Level
---------------------------------------------------------------------
PROCEDURE Get_Max_Rank
  (p_Parent_Terr_Id              IN  NUMBER,
   p_Source_Id                   IN  NUMBER,
   X_Rank                        OUT NOCOPY NUMBER);


---------------------------------------------------------------------
  -- Procedure
  --    Gen_Template_Territories
  --
  -- Purpose
  --   Generates territories for a template.
  --
  --   Argument: p_terr_template_id
  --   If the template id is passed, all territories which have been previously
  --   generated from this template and not updated manually will be deleted
  --   first.
   PROCEDURE Gen_Template_Territories (
    p_Api_Version_Number          IN  NUMBER,
    p_Init_Msg_List               IN  VARCHAR2     := FND_API.G_FALSE,
    p_Commit                      IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level            IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_Template_Terr_Id            IN  NUMBER,
    x_Return_Status               OUT NOCOPY VARCHAR2,
    x_Msg_Count                   OUT NOCOPY NUMBER,
    x_Msg_Data                    OUT NOCOPY VARCHAR2,
    x_num_gen_terr                OUT NOCOPY NUMBER
   );
---------------------------------------------------------------------
  -- Procedure
  --    Copy_Territory
  --
  -- Purpose
  --   Makes a copy of a territory.
  --
  --   Argument: p_copy_source_terr_id - terr_id of territory to be copied
  --             p_new_terr_name - name of the new copied territory
  --             p_copy_rsc_flag - indicates whether resources assigned
  --                               to territory are to be copied
  --             p_copy_hierarchy_flag - indicates whether the territory hierarchy
  --                                     below this territory are to be copied
  --             p_first_terr_node_flag - indicates whether this is the first node to be copied

   PROCEDURE Copy_Territory (
    p_Api_Version_Number          IN  NUMBER,
    p_Init_Msg_List               IN  VARCHAR2     := FND_API.G_FALSE,
    p_Commit                      IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level            IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_copy_source_terr_Id         IN  NUMBER,
    p_new_terr_rec                IN  Terr_All_Rec_Type,
    p_copy_rsc_flag               IN VARCHAR2 := 'N',
    p_copy_hierarchy_flag         IN VARCHAR2 := 'N',
    p_first_terr_node_flag        IN VARCHAR2 := 'N',
    x_Return_Status               OUT NOCOPY VARCHAR2,
    x_Msg_Count                   OUT NOCOPY NUMBER,
    x_Msg_Data                    OUT NOCOPY VARCHAR2,
    x_Terr_Id                     OUT NOCOPY NUMBER
   );


---------------------------------------------------------------------
--             Overlap Exists
---------------------------------------------------------------------
--
--         Check whether any OVERLAP exists for a particular
--         qualifier usage value passed of a particular parent
--         territory. This si because we only check for overlap
--         under a single parent
---------------------------------------------------------------------
FUNCTION Overlap_Exists(p_Parent_Terr_Id              IN  NUMBER,
                        p_Qual_Usg_Id                 IN  NUMBER,
                        p_terr_value_record           IN  jtf_terr_values%ROWTYPE )
RETURN VARCHAR2;


  -- jdochert 09/09
  -- check for Unique Key constraint violation on JTF_TERR_USGS table
  PROCEDURE validate_terr_usgs_UK(
               p_Terr_Id          IN  NUMBER,
               p_Source_Id        IN  NUMBER,
               p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
               x_Return_Status    OUT NOCOPY VARCHAR2,
               x_msg_count        OUT NOCOPY NUMBER,
               x_msg_data         OUT NOCOPY VARCHAR2 );

  -- jdochert 09/09
  -- check for Unique Key constraint violation on JTF_TERR_QTYPE_USGS table
  PROCEDURE validate_terr_qtype_usgs_UK(
               p_Terr_Id                 IN  NUMBER,
               p_Qual_Type_Usg_Id        IN  NUMBER,
               p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
               x_Return_Status           OUT NOCOPY VARCHAR2,
               x_msg_count               OUT NOCOPY NUMBER,
               x_msg_data                OUT NOCOPY VARCHAR2 );

  -- jdochert 10/04
  -- check that Number of Winners is valid for this territory
  PROCEDURE validate_num_winners(
               p_Terr_All_Rec     IN  Terr_All_Rec_Type  := G_Miss_Terr_All_Rec,
               p_init_msg_list    IN  VARCHAR2           := FND_API.G_FALSE,
               x_Return_Status    OUT NOCOPY VARCHAR2,
               x_msg_count        OUT NOCOPY NUMBER,
               x_msg_data         OUT NOCOPY VARCHAR2,
               x_reason           OUT NOCOPY VARCHAR2 );

  -- jdochert 06/08/01
  -- check that parent is not already a
  -- child of this territory: circular reference check
  PROCEDURE validate_parent(
               p_Terr_All_Rec     IN  Terr_All_Rec_Type  := G_Miss_Terr_All_Rec,
               p_init_msg_list    IN  VARCHAR2           := FND_API.G_FALSE,
               x_Return_Status    OUT NOCOPY VARCHAR2,
               x_msg_count        OUT NOCOPY NUMBER,
               x_msg_data         OUT NOCOPY VARCHAR2 );

/* JDOCHERT - 041201 */
PROCEDURE chk_num_copy_terr( p_node_terr_id     IN  NUMBER,
                             p_limit_num        IN  NUMBER := 10,
                             x_Return_Status    OUT NOCOPY VARCHAR2,
                             x_msg_count        OUT NOCOPY NUMBER,
                             x_msg_data         OUT NOCOPY VARCHAR2,
                             x_terr_num         OUT NOCOPY NUMBER,
                             x_copy_status      OUT NOCOPY VARCHAR2 );
-- Package spec

/* ARPATEL - 041701 */
PROCEDURE Concurrent_Copy_Territory (
                           errbuf                        OUT NOCOPY VARCHAR2,
                           retcode                       OUT NOCOPY VARCHAR2,
                           p_copy_source_terr_Id         IN  NUMBER,
                           p_name                        IN  VARCHAR2,
                           p_description                 IN  VARCHAR2     := FND_API.G_MISS_CHAR,
                           p_rank                        IN  NUMBER       := FND_API.G_MISS_NUM,
                           p_start_date                  IN  DATE,
                           p_end_date                    IN  DATE         := FND_API.G_MISS_DATE,
                           p_copy_rsc_flag               IN  VARCHAR2     := 'N',
                           p_copy_hierarchy_flag         IN  VARCHAR2     := 'N',
                           p_first_terr_node_flag        IN  VARCHAR2     := 'N',
                           p_debug_flag                  IN  VARCHAR2     := 'N',
                           p_sql_trace                   IN  VARCHAR2     := 'N'   );

PROCEDURE Write_Log(which number, mssg  varchar2 );

FUNCTION conc_req_copy_terr (
                           p_copy_source_terr_Id         IN  NUMBER,
                           p_name                        IN  VARCHAR2,
                           p_description                 IN  VARCHAR2     := FND_API.G_MISS_CHAR,
                           p_rank                        IN  NUMBER       := FND_API.G_MISS_NUM,
                           p_start_date                  IN  DATE,
                           p_end_date                    IN  DATE         := FND_API.G_MISS_DATE,
                           p_copy_rsc_flag               IN  VARCHAR2     := 'N',
                           p_copy_hierarchy_flag         IN  VARCHAR2     := 'N',
                           p_first_terr_node_flag        IN  VARCHAR2     := 'N'
                            )
 RETURN NUMBER;

/* Function used in JTF_TERR_VALUES_DESC_V to return
** descriptive values for ids and lookup_codes
*/
FUNCTION get_terr_value_desc (
                           p_convert_to_id_flag  VARCHAR2
                         , p_display_type        VARCHAR2
                         , p_column_count        NUMBER   := FND_API.G_MISS_NUM
                         , p_display_sql         VARCHAR2 := FND_API.G_MISS_CHAR
                         , p_terr_value1         VARCHAR2
                         , p_terr_value2         VARCHAR2 :=  FND_API.G_MISS_CHAR
                         )
RETURN VARCHAR2;


END JTF_TERRITORY_PVT;

/
