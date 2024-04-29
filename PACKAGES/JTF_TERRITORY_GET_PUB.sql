--------------------------------------------------------
--  DDL for Package JTF_TERRITORY_GET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERRITORY_GET_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptrgs.pls 120.3.12010000.1 2009/05/04 11:21:38 ppillai ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_GET_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager private api's.
--      This package is a public API for retrieving
--      related information from JTF tables.
--      It contains specification for pl/sql records and tables
--      and the Public territory related API's.
--
--      Procedures:
--
--
--    NOTES
--      This package is available for private use only
--
--    HISTORY
--      07/15/99   JDOCHERT         Created
--      12/22/99   VNEDUNGA         Making changes to confirm
--                                  to JTF_TER_RSC_ALL
--      03/20/00   JDOCHERT         Added FULL_ACCESS_FLAG to
--                                  Territory Resource record definition
--
--
--    End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30):= 'JTF_TERRITORY_GET_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'jtfptrgs.pls';

G_USER_ID       NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


--*******************************************************
--                     Composite Types
--*******************************************************

TYPE order_by_rec_type IS RECORD
(
      -- Please define your own sort by record here.
       TERR_ID              NUMBER         := FND_API.G_MISS_NUM,
       TERR_NAME            VARCHAR2(2000) := FND_API.G_MISS_CHAR
);
TYPE order_by_Tbl_Type IS TABLE OF order_by_rec_type
                             INDEX BY BINARY_INTEGER;

G_MISS_ORDER_BY_REC           order_by_rec_type;

G_MISS_ORDER_BY_TBL           order_by_Tbl_Type;


---------------------------------------------------------
--    Start of Comments
---------------------------------------------------------
--     Territory Resource out Record: QualifyingRsc_Rec_Type
---------------------------------------------------------
--    Parameters:
--       TERR_RSC_ID                Territory resource id
--       TERR_ID                    Territory Id
--       TERR_NAME                  Territory Name
--       RESOURCE_ID                Resource Identifier
--       ACCESS_TYPE                Access Type
--       RESOURCE_TYPE              Resource Type Id
--       ROLE                       Resource sub type Id
--       PRIMARY_CONTACT_FLAG       Falg to identify a resource as primary
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments
TYPE QualifyingRsc_Out_Rec_Type   IS RECORD
    (
       TERR_RSC_ID                NUMBER         := FND_API.G_MISS_NUM,
       TERR_ID                    NUMBER         := FND_API.G_MISS_NUM,
       TERR_NAME                  VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       RESOURCE_ID                NUMBER         := FND_API.G_MISS_NUM,
       ACCESS_TYPE                VARCHAR2(30)   := FND_API.G_MISS_CHAR,
       RESOURCE_TYPE              VARCHAR2(60)   := FND_API.G_MISS_CHAR,
       ROLE                       VARCHAR2(60)   := FND_API.G_MISS_CHAR,
       PRIMARY_CONTACT_FLAG       VARCHAR2(1)    := FND_API.G_MISS_CHAR
    );

G_MISS_QUALIFYINGRSC_OUT_REC         QualifyingRsc_Out_rec_type;

TYPE   QualifyingRsc_out_tbl_type    IS TABLE OF   QualifyingRsc_out_rec_type
                                     INDEX BY BINARY_INTEGER;

G_MISS_QUALIFYINGRSC_OUT_TBL         QualifyingRsc_out_tbl_type;


---------------------------------------------------------
--    Start of Comments
---------------------------------------------------------
--     Territory Header out Record: Terr_Header_Rec_Type
---------------------------------------------------------
--    Parameters:
--       TERR_ID                    Territory Id
--       TERR_NAME                  Territory Name
--       TERR_USAGE                 Territory Usage
--       START_DATE                 Start Date Effective
--       END_DATE                   End Date Effective
--       TEMPLATE_FLAG              Template Flag
--       ESCALATION_TERRITORY_FLAG  Escalation Territory Flag
--       PARENT_TERR_NAME           Enabled Flag
--       TERR_TYPE_NAME             Territory Type name
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments
TYPE Terr_Header_Rec_Type IS RECORD (
 TERR_ID                        NUMBER         := FND_API.G_MISS_NUM,
 TERR_NAME                      VARCHAR2(2000) := FND_API.G_MISS_CHAR,
 TERR_USAGE                     VARCHAR2(30)   := FND_API.G_MISS_CHAR,
 START_DATE_ACTIVE              DATE           := FND_API.G_MISS_DATE,
 END_DATE_ACTIVE                DATE           := FND_API.G_MISS_DATE,
 TEMPLATE_FLAG                  VARCHAR2(1)    := FND_API.G_MISS_CHAR,
 ESCALATION_TERRITORY_FLAG      VARCHAR2(1)    := FND_API.G_MISS_CHAR,
 PARENT_TERR_NAME               VARCHAR2(2000) := FND_API.G_MISS_CHAR,
 TERR_TYPE_NAME                 VARCHAR2(60)   := FND_API.G_MISS_CHAR
 );

TYPE Terr_Header_Tbl_Type IS TABLE OF Terr_Header_Rec_Type
                             INDEX BY BINARY_INTEGER;

G_MISS_TERR_HEADER_REC           Terr_Header_Rec_Type;

G_MISS_TERR_HEADER_TBL           Terr_Header_Tbl_Type;

---------------------------------------------------------
--     Territory  Record: Terr_Rec_Type
---------------------------------------------------------
TYPE Terr_Rec_Type IS RECORD
(
TERR_ID                     NUMBER         := FND_API.G_MISS_NUM,
LAST_UPDATE_DATE            DATE           := FND_API.G_MISS_DATE,
LAST_UPDATED_BY             NUMBER         := FND_API.G_MISS_NUM,
CREATION_DATE               DATE           := FND_API.G_MISS_DATE,
CREATED_BY                  NUMBER         := FND_API.G_MISS_NUM,
LAST_UPDATE_LOGIN           NUMBER         := FND_API.G_MISS_NUM,
REQUEST_ID                  NUMBER         := FND_API.G_MISS_NUM,
PROGRAM_APPLICATION_ID      NUMBER         := FND_API.G_MISS_NUM,
PROGRAM_ID                  NUMBER         := FND_API.G_MISS_NUM,
PROGRAM_UPDATE_DATE         DATE           := FND_API.G_MISS_DATE,
APPLICATION_SHORT_NAME      VARCHAR2(50)   := FND_API.G_MISS_CHAR,
NAME                        VARCHAR2(2000) := FND_API.G_MISS_CHAR,
ENABLED_FLAG                VARCHAR2(1)    := FND_API.G_MISS_CHAR,
START_DATE_ACTIVE           DATE           := FND_API.G_MISS_DATE,
END_DATE_ACTIVE             DATE           := FND_API.G_MISS_DATE,
PLANNED_FLAG                VARCHAR2(1)    := FND_API.G_MISS_CHAR,
PARENT_TERRITORY_ID         NUMBER         := FND_API.G_MISS_NUM,
TERRITORY_TYPE_ID           NUMBER         := FND_API.G_MISS_NUM,
TEMPLATE_TERRITORY_ID       NUMBER         := FND_API.G_MISS_NUM,
TEMPLATE_FLAG               VARCHAR2(1)    := FND_API.G_MISS_CHAR,
ESCALATION_TERRITORY_ID     NUMBER         := FND_API.G_MISS_NUM,
ESCALATION_TERRITORY_FLAG   VARCHAR2(1)    := FND_API.G_MISS_CHAR,
OVERLAP_ALLOWED_FLAG        VARCHAR2(1)    := FND_API.G_MISS_CHAR,
RANK                        NUMBER         := FND_API.G_MISS_NUM,
DESCRIPTION                 VARCHAR2(240)  := FND_API.G_MISS_CHAR,
UPDATE_FLAG                 VARCHAR2(1)    := FND_API.G_MISS_CHAR,
AUTO_ASSIGN_RESOURCES_FLAG  VARCHAR2(1)    := FND_API.G_MISS_CHAR,
ATTRIBUTE_CATEGORY          VARCHAR2(30)   := FND_API.G_MISS_CHAR,
ATTRIBUTE1                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE2                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE3                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE4                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE5                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE6                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE7                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE8                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE9                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE10                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE11                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE12                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE13                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE14                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ATTRIBUTE15                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
ORG_ID                      NUMBER         := FND_API.G_MISS_NUM
, TERR_TYPE_NAME            VARCHAR2(60)   := FND_API.G_MISS_CHAR
, PARENT_TERR_NAME          VARCHAR2(2000) := FND_API.G_MISS_CHAR
, ESCALATION_TERR_NAME      VARCHAR2(2000) := FND_API.G_MISS_CHAR
, TEMPLATE_TERR_NAME        VARCHAR2(2000) := FND_API.G_MISS_CHAR
, TERR_USG_ID               NUMBER         := FND_API.G_MISS_NUM
, SOURCE_ID                 NUMBER         := FND_API.G_MISS_NUM
, TERR_USAGE                VARCHAR2(30)   := FND_API.G_MISS_CHAR
);



TYPE Terr_Tbl_Type IS TABLE OF Terr_Rec_Type
                           INDEX BY BINARY_INTEGER;

G_MISS_TERR_REC           Terr_Rec_Type;

G_MISS_TERR_TBL           Terr_Tbl_Type;


---------------------------------------------------------
--     Territory Type Record: Terr_Type_Rec_Type
---------------------------------------------------------
TYPE TERR_TYPE_REC_TYPE IS RECORD
(
TERR_TYPE_ID                NUMBER        := FND_API.G_MISS_NUM,
LAST_UPDATED_BY             NUMBER        := FND_API.G_MISS_NUM,
LAST_UPDATE_DATE            DATE          := FND_API.G_MISS_DATE,
CREATED_BY                  NUMBER        := FND_API.G_MISS_NUM,
CREATION_DATE               DATE          := FND_API.G_MISS_DATE,
LAST_UPDATE_LOGIN           NUMBER        := FND_API.G_MISS_NUM,
APPLICATION_SHORT_NAME      VARCHAR2(50)  := FND_API.G_MISS_CHAR,
NAME                        VARCHAR2(60)  := FND_API.G_MISS_CHAR,
ENABLED_FLAG                VARCHAR2(1)   := FND_API.G_MISS_CHAR,
DESCRIPTION                 VARCHAR2(240) := FND_API.G_MISS_CHAR,
START_DATE_ACTIVE           DATE          := FND_API.G_MISS_DATE,
END_DATE_ACTIVE             DATE          := FND_API.G_MISS_DATE,
ATTRIBUTE_CATEGORY          VARCHAR2(30)  := FND_API.G_MISS_CHAR,
ATTRIBUTE1                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE2                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE3                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE4                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE5                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE6                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE7                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE8                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE9                  VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE10                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE11                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE12                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE13                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE14                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
ATTRIBUTE15                 VARCHAR2(150) := FND_API.G_MISS_CHAR,
ORG_ID                      NUMBER        := FND_API.G_MISS_NUM
);

TYPE Terr_Type_Tbl_Type IS TABLE OF Terr_Type_Rec_Type
                           INDEX BY BINARY_INTEGER;

G_MISS_TERR_TYPE_REC           Terr_Type_Rec_Type;

G_MISS_TERR_TYPE_TBL           Terr_Type_Tbl_Type;

---------------------------------------------------------
--     Territory  Usages Record: Terr_Usgs_Rec_Type
---------------------------------------------------------
TYPE Terr_Usgs_Rec_Type IS RECORD
(
TERR_USG_ID         NUMBER       := FND_API.G_MISS_NUM,
LAST_UPDATE_DATE    DATE         := FND_API.G_MISS_DATE,
LAST_UPDATED_BY     NUMBER       := FND_API.G_MISS_NUM,
CREATION_DATE       DATE         := FND_API.G_MISS_DATE,
CREATED_BY          NUMBER       := FND_API.G_MISS_NUM,
LAST_UPDATE_LOGIN   NUMBER       := FND_API.G_MISS_NUM,
TERR_ID             NUMBER       := FND_API.G_MISS_NUM,
SOURCE_ID           NUMBER       := FND_API.G_MISS_NUM,
ORG_ID              NUMBER       := FND_API.G_MISS_NUM
, USAGE             VARCHAR2(30) := FND_API.G_MISS_CHAR
);

TYPE Terr_Usgs_Tbl_Type IS TABLE OF Terr_Usgs_Rec_Type
                           INDEX BY BINARY_INTEGER;

G_MISS_TERR_USGS_REC           Terr_Usgs_Rec_Type;

G_MISS_TERR_USGS_TBL           Terr_Usgs_Tbl_Type;


-----------------------------------------------------------------------
--     Territory Qualifier Type Usages Record: Terr_QType_Usgs_Rec_Type
-----------------------------------------------------------------------
TYPE Terr_QType_Usgs_Rec_Type IS RECORD
(
TERR_QTYPE_USG_ID            NUMBER        := FND_API.G_MISS_NUM,
LAST_UPDATED_BY              NUMBER        := FND_API.G_MISS_NUM,
LAST_UPDATE_DATE             DATE          := FND_API.G_MISS_DATE,
CREATED_BY                   NUMBER        := FND_API.G_MISS_NUM,
CREATION_DATE                DATE          := FND_API.G_MISS_DATE,
LAST_UPDATE_LOGIN            NUMBER        := FND_API.G_MISS_NUM,
TERR_ID                      NUMBER        := FND_API.G_MISS_NUM,
QUAL_TYPE_USG_ID             NUMBER        := FND_API.G_MISS_NUM,
ORG_ID                       NUMBER        := FND_API.G_MISS_NUM
, SOURCE_ID                    NUMBER        := FND_API.G_MISS_NUM
, QUAL_TYPE_ID                 NUMBER        := FND_API.G_MISS_NUM
, QUALIFIER_TYPE_NAME          VARCHAR2(40)  := FND_API.G_MISS_CHAR
, QUALIFIER_TYPE_DESCRIPTION   VARCHAR2(240) := FND_API.G_MISS_CHAR
);

TYPE Terr_QType_Usgs_Tbl_Type IS TABLE OF Terr_QType_Usgs_Rec_Type
                           INDEX BY BINARY_INTEGER;

G_MISS_TERR_QTYPE_USGS_REC           Terr_QType_Usgs_Rec_Type;

G_MISS_TERR_QTYPE_USGS_TBL           Terr_QType_Usgs_Tbl_Type;


-----------------------------------------------------------------------
--     Territory Qualifier Record: Terr_Qual_Rec_Type
-----------------------------------------------------------------------
TYPE Terr_Qual_Rec_Type IS RECORD
(
TERR_QUAL_ID                   NUMBER         := FND_API.G_MISS_NUM,
LAST_UPDATE_DATE               DATE           := FND_API.G_MISS_DATE,
LAST_UPDATED_BY                NUMBER         := FND_API.G_MISS_NUM,
CREATION_DATE                  DATE           := FND_API.G_MISS_DATE,
CREATED_BY                     NUMBER         := FND_API.G_MISS_NUM,
LAST_UPDATE_LOGIN              NUMBER         := FND_API.G_MISS_NUM,
TERR_ID                        NUMBER         := FND_API.G_MISS_NUM,
QUAL_USG_ID                    NUMBER         := FND_API.G_MISS_NUM,
USE_TO_NAME_FLAG               VARCHAR2(1)    := FND_API.G_MISS_CHAR,
GENERATE_FLAG                  VARCHAR2(1)    := FND_API.G_MISS_CHAR,
OVERLAP_ALLOWED_FLAG           VARCHAR2(1)    := FND_API.G_MISS_CHAR,
QUALIFIER_MODE                 VARCHAR(30)    := FND_API.G_MISS_CHAR,
ORG_ID                         NUMBER         := FND_API.G_MISS_NUM
, DISPLAY_TYPE                 VARCHAR2(40)   := FND_API.G_MISS_CHAR
, LOV_SQL                      VARCHAR2(1000) := FND_API.G_MISS_CHAR
, CONVERT_TO_ID_FLAG           VARCHAR2(1)    := FND_API.G_MISS_CHAR
, QUAL_TYPE_ID                 NUMBER         := FND_API.G_MISS_NUM
, QUALIFIER_TYPE_NAME          VARCHAR2(40)   := FND_API.G_MISS_CHAR
, QUALIFIER_TYPE_DESCRIPTION   VARCHAR2(240)  := FND_API.G_MISS_CHAR
, QUALIFIER_NAME               VARCHAR2(60)   := FND_API.G_MISS_CHAR
);

TYPE Terr_Qual_Tbl_Type IS TABLE OF Terr_Qual_Rec_Type
                           INDEX BY BINARY_INTEGER;

G_MISS_TERR_QUAL_REC           Terr_Qual_Rec_Type;

G_MISS_TERR_QUAL_TBL           Terr_Qual_Tbl_Type;



-----------------------------------------------------------------------
--     Territory Values Record: Terr_Values_Rec_Type
-----------------------------------------------------------------------
TYPE Terr_Values_Rec_Type IS RECORD
(
TERR_VALUE_ID               NUMBER := FND_API.G_MISS_NUM,
LAST_UPDATED_BY             NUMBER := FND_API.G_MISS_NUM,
LAST_UPDATE_DATE            DATE := FND_API.G_MISS_DATE,
CREATED_BY                  NUMBER := FND_API.G_MISS_NUM,
CREATION_DATE               DATE := FND_API.G_MISS_DATE,
LAST_UPDATE_LOGIN           NUMBER := FND_API.G_MISS_NUM,
TERR_QUAL_ID                NUMBER := FND_API.G_MISS_NUM,
INCLUDE_FLAG                VARCHAR2(15) := FND_API.G_MISS_CHAR,
COMPARISON_OPERATOR         VARCHAR2(30) := FND_API.G_MISS_CHAR,
ID_USED_FLAG                VARCHAR2(1) := FND_API.G_MISS_CHAR,
LOW_VALUE_CHAR_ID           NUMBER := FND_API.G_MISS_NUM,
LOW_VALUE_CHAR              VARCHAR2(60) := FND_API.G_MISS_CHAR,
HIGH_VALUE_CHAR             VARCHAR2(60) := FND_API.G_MISS_CHAR,
LOW_VALUE_NUMBER            NUMBER := FND_API.G_MISS_NUM,
HIGH_VALUE_NUMBER           NUMBER := FND_API.G_MISS_NUM,
VALUE_SET                   NUMBER := FND_API.G_MISS_NUM,
INTEREST_TYPE_ID            NUMBER := FND_API.G_MISS_NUM,
PRIMARY_INTEREST_CODE_ID    NUMBER := FND_API.G_MISS_NUM,
SECONDARY_INTEREST_CODE_ID  NUMBER := FND_API.G_MISS_NUM,
CURRENCY_CODE               VARCHAR2(15) := FND_API.G_MISS_CHAR,
ORG_ID                      NUMBER := FND_API.G_MISS_NUM
);

TYPE Terr_Values_Tbl_Type IS TABLE OF Terr_Values_Rec_Type
                           INDEX BY BINARY_INTEGER;

G_MISS_TERR_VALUES_REC           Terr_Values_Rec_Type;

G_MISS_TERR_VALUES_TBL           Terr_Values_Tbl_Type;


-----------------------------------------------------------------------
--     Territory Resources Record: Terr_Resources_Rec_Type
-----------------------------------------------------------------------
TYPE Terr_Rsc_Rec_Type IS RECORD
(
TERR_RSC_ID             NUMBER        := FND_API.G_MISS_NUM,
LAST_UPDATE_DATE        DATE          := FND_API.G_MISS_DATE,
LAST_UPDATED_BY         NUMBER        := FND_API.G_MISS_NUM,
CREATION_DATE           DATE          := FND_API.G_MISS_DATE,
CREATED_BY              NUMBER        := FND_API.G_MISS_NUM,
LAST_UPDATE_LOGIN       NUMBER        := FND_API.G_MISS_NUM,
TERR_ID                 NUMBER        := FND_API.G_MISS_NUM,
RESOURCE_ID             NUMBER        := FND_API.G_MISS_NUM,
RESOURCE_TYPE           VARCHAR2(60)  := FND_API.G_MISS_CHAR,
ROLE                    VARCHAR2(60)  := FND_API.G_MISS_CHAR,
PRIMARY_CONTACT_FLAG    VARCHAR2(1)   := FND_API.G_MISS_CHAR,
START_DATE_ACTIVE       DATE          := FND_API.G_MISS_DATE,
END_DATE_ACTIVE         DATE          := FND_API.G_MISS_DATE,
FULL_ACCESS_FLAG        VARCHAR2(1)   := FND_API.G_MISS_CHAR,
ORG_ID                  NUMBER        := FND_API.G_MISS_NUM
, RESOURCE_NAME         VARCHAR2(573) := FND_API.G_MISS_CHAR
);

TYPE Terr_Rsc_Tbl_Type IS TABLE OF Terr_Rsc_Rec_Type
                           INDEX BY BINARY_INTEGER;

G_MISS_TERR_RSC_REC           Terr_Rsc_Rec_Type;

G_MISS_TERR_RSC_TBL           Terr_Rsc_Tbl_Type;



--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Get_Territory_Header
--    Type      : PUBLIC
--    Function  : To get a list of territory headers
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_terr_rec                 Terr_Rec_Type                    G_MISS_TERR_REC
--      p_terr_type_rec            Terr_Type_Rec_Type               G_MISS_TERR_TYPE_REC
--      p_terr_usg_rec             Terr_Usgs_Rec_Type               G_MISS_TERR_USGS_REC
--      p_terr_rsc_rec             Terr_Rsc_Rec_Type                G_MISS_TERR_RSC_REC
--      p_terr_qual_tbl            Terr_Qual_Tbl_Type               G_MISS_TERR_QUAL_TBL
--      p_terr_values_tbl          Terr_Values_Tbl_Type             G_MISS_TERR_VALUES_TBL
--      p_order_by_rec             order_by_rec_type                G_MISS_ORDER_BY_REC
--      p_return_all_rec           VARCHAR2                         FND_API.G_FALSE
--      p_num_rec_requested        NUMBER                           30
--      p_start_rec_num            NUMBER                           1
--
--     OUT     :
--      Parameter Name             Data Type
--      x_Return_Status            VARCHAR2(1)
--      x_Msg_Count                NUMBER
--      x_Msg_Data                 VARCHAR2(2000)
--      x_terr_header_tbl          Terr_Header_Tbl_Type
--      x_num_rec_returned         NUMBER
--      x_next_rec_num             NUMBER
--      x_total_num_rec            NUMBER
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Get_Territory_Header (
    p_Api_Version                IN   NUMBER,
    p_Init_Msg_List              IN   VARCHAR2              := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_terr_rec                   IN   Terr_Rec_Type         := G_MISS_TERR_REC,
    p_terr_type_rec              IN   Terr_Type_Rec_Type    := G_MISS_TERR_TYPE_REC,
    p_terr_usg_rec               IN   Terr_Usgs_Rec_Type    := G_MISS_TERR_USGS_REC,
    p_terr_rsc_rec               IN   Terr_Rsc_Rec_Type     := G_MISS_TERR_RSC_REC,
    p_terr_qual_tbl              IN   Terr_Qual_Tbl_Type    := G_MISS_TERR_QUAL_TBL,
    p_terr_values_tbl            IN   Terr_Values_Tbl_Type  := G_MISS_TERR_VALUES_TBL,
    p_order_by_rec               IN   order_by_rec_type     := G_MISS_ORDER_BY_REC,
    p_return_all_rec             IN   VARCHAR2              := FND_API.G_FALSE,
    p_num_rec_requested          IN   NUMBER                := 30,
    p_start_rec_num              IN   NUMBER                := 1,
    x_terr_header_tbl            OUT NOCOPY Terr_Header_Tbl_Type,
    x_num_rec_returned           OUT NOCOPY NUMBER,
    x_next_rec_num               OUT NOCOPY NUMBER,
    x_total_num_rec              OUT NOCOPY NUMBER
);


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Get_Territory_Details
--    Type      : PUBLIC
--    Function  : To get a territory's details
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_terr_id                  NUMBER                           FND_API.G_MISS_NUM
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name             Data Type
--      x_Return_Status            VARCHAR2(1)
--      x_Msg_Count                NUMBER
--      x_Msg_Data                 VARCHAR2(2000)
--      x_terr_rec                 Terr_Rec_Type
--      x_terr_type_rec            Terr_Type_Rec_Type
--      x_terr_sub_terr_tbl        Terr_Tbl_Type
--      x_terr_usgs_tbl            Terr_Usgs_Tbl_Type
--      x_terr_qtype_usgs_tbl      Terr_QType_Usgs_Tbl_Type
--      x_terr_qual_tbl            Terr_Qual_Tbl_Type
--      x_terr_values_tbl          Terr_Values_Tbl_Type
--      x_terr_rsc_tbl             Terr_Rsc_Tbl_Type
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Get_Territory_Details (
    p_Api_Version                IN   NUMBER,
    p_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_terr_id                    IN   NUMBER     := FND_API.G_MISS_NUM,
    x_terr_rec                   OUT NOCOPY Terr_Rec_Type,
    x_terr_type_rec              OUT NOCOPY Terr_Type_Rec_Type,
    x_terr_sub_terr_tbl          OUT NOCOPY Terr_Tbl_Type,
    x_terr_usgs_tbl              OUT NOCOPY Terr_Usgs_Tbl_Type,
    x_terr_qtype_usgs_tbl        OUT NOCOPY Terr_QType_Usgs_Tbl_Type,
    x_terr_qual_tbl              OUT NOCOPY Terr_Qual_Tbl_Type,
    x_terr_values_tbl            OUT NOCOPY Terr_Values_Tbl_Type,
    x_terr_rsc_tbl               OUT NOCOPY Terr_Rsc_Tbl_Type
);

--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Get_Escalation_Territory
--    Type      : PUBLIC
--    Function  : To get a territory's escalation territory
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_Escalation_Terr_Id       NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
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
PROCEDURE Get_Escalation_Territory (
    p_Api_Version                IN   NUMBER,
    p_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_terr_id                    IN   NUMBER := FND_API.G_MISS_NUM,
    x_escalation_terr_id         OUT NOCOPY NUMBER
);


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Get_Parent_Territory
--    Type      : PUBLIC
--    Function  : To get a territory's parent territory
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_Parent_Terr_Id           NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
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
PROCEDURE Get_Parent_Territory (
    p_Api_Version                IN   NUMBER,
    p_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_terr_id                    IN   NUMBER := FND_API.G_MISS_NUM,
    x_parent_terr_id             OUT NOCOPY NUMBER
);


--
--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Get_Escalation_TerrMembers
--    Type      : PUBLIC
--    Function  : To get reosurces attached with a escalation
--                territory
--
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
--     OUT     :
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
PROCEDURE Get_Escalation_TerrMembers
 (p_api_version_number      IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  p_terr_id                 IN  NUMBER,
  x_QualifyingRsc_out_tbl   OUT NOCOPY QualifyingRsc_out_tbl_type,
  p_access_type 			IN VARCHAR2 DEFAULT NULL);

End JTF_TERRITORY_GET_PUB; -- end package specification

/
