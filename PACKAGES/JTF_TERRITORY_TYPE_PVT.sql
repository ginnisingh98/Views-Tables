--------------------------------------------------------
--  DDL for Package JTF_TERRITORY_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERRITORY_TYPE_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvttys.pls 120.0 2005/06/02 18:23:09 appldev ship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_TYPE_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is a public API for inserting territory type
--      related information in to information into JTF tables.
--      It contains specification for pl/sql records and tables
--      and the Public territory related API's.
--
--    Procedures:
--
--
--    NOTES
--        This package is for private use only
--
--    HISTORY
--      06/09/99   VNEDUNGA         Created
--      11/20/99   VNEDUNGA         Commenting out FND_G_MISS
--      11/29/99   VNEDUNGA         Added a new procedure to validate
--                                  Territory Type( Is_TerrType_Deletable )
--      01/25/00   VNEDUNGA         Adding Copy terr Type procedure
--      02/17/00   VNEDUNGA         Adding ORG_ID to Record Defnitions
--
--    End of Comments

--*******************************************************
--    Start of Comments
---------------------------------------------------------
--        Territory Header Record: TerrType_rec_type
--    ---------------------------------------------------
--    Parameters:
--    Required:
--        NAME              -- Territory Type Name
--        LAST_UPDATE_DATE  -- Part of std who columns
--        LAST_UPDATED_BY   -- Part of std who columns
--        CREATION_DATE     -- Part of std who columns
--        CREATED_BY        -- Part of std who columns
--        LAST_UPDATE_LOGIN -- Part of std who columns
--        ENABLED_FLAG      -- Status fo territory type
--        NUM_QUALIFIERS    -- Number of qualifiers used
--
--    Defaults:
--    Note:
--
-- End of Comments

TYPE TerrType_rec_type          IS RECORD
    (
        TERR_TYPE_ID           NUMBER         ,    --  := FND_API.G_MISS_NUM,
        LAST_UPDATE_DATE       DATE           ,    --  := FND_API.G_MISS_DATE,
        LAST_UPDATED_BY        NUMBER         ,    --  := FND_API.G_MISS_NUM,
        CREATION_DATE          DATE           ,    --  := FND_API.G_MISS_DATE,
        CREATED_BY             NUMBER         ,    --  := FND_API.G_MISS_NUM,
        LAST_UPDATE_LOGIN      NUMBER         ,    --  := FND_API.G_MISS_NUM,
        APPLICATION_SHORT_NAME VARCHAR2(50)   ,    --  := FND_API.G_MISS_CHAR,
        NAME                   VARCHAR2(60)   ,    --  := FND_API.G_MISS_CHAR,
        ENABLED_FLAG           VARCHAR2(1)    ,    --  := FND_API.G_MISS_CHAR,
        START_DATE_ACTIVE      DATE           ,    --  := FND_API.G_MISS_DATE,
        END_DATE_ACTIVE        DATE           ,    --  := FND_API.G_MISS_DATE,
        DESCRIPTION            VARCHAR2(240)  ,    --  := FND_API.G_MISS_CHAR,
        ORG_ID                 NUMBER         ,    --  := FND_API.G_MISS_NUM,
        ATTRIBUTE_CATEGORY     VARCHAR2(30)   ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE1             VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE2             VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE3             VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE4             VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE5             VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE6             VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE7             VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE8             VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE9             VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE10            VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE11            VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE12            VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE13            VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE14            VARCHAR2(150)  ,    --  := FND_API.G_MISS_CHAR,
        ATTRIBUTE15            VARCHAR2(150)       --  := FND_API.G_MISS_CHAR
    );

G_MISS_TerrType_REC             TerrType_rec_type;

TYPE TerrType_tbl_type          IS TABLE OF    TerrType_rec_type
                               INDEX BY BINARY_INTEGER;

G_MISS_TerrType_TBL             TerrType_tbl_type;


--*******************************************************
--    Start of Comments
---------------------------------------------------------
--        Territory Header Out Record: TerrType_Out_rec_type
--    ---------------------------------------------------
--    Parameters:
--    Required:
--
--    Defaults:
--    Note:
--
-- End of Comments

TYPE TerrType_Out_rec_type          IS RECORD
    (
       TERR_TYPE_ID             NUMBER       , --:= FND_API.G_MISS_NUM,
       RETURN_STATUS            VARCHAR2(01)   --:= FND_API.G_MISS_CHAR
    );

G_MISS_TerrType_OUT_REC             TerrType_Out_rec_type;

TYPE TerrType_Out_tbl_type          IS TABLE OF    TerrType_Out_rec_type
                                       INDEX BY BINARY_INTEGER;

G_MISS_TerrType_OUT_TBL             TerrType_Out_tbl_type;


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Territory Type source Record: TerrTypeUsgs_rec_type
--    ---------------------------------------------------
--    Parameters:
--
--    Required:
--        TERR_TYPE_USG_ID      -- primary key sequence
--        SOURCE_ID             -- Source identifier
--        TERR_TYPE_ID          -- Territory identifier
--        LAST_UPDATE_DATE      -- Part of std who columns
--        LAST_UPDATED_BY       -- Part of std who columns
--        CREATION_DATE         -- Part of std who columns
--        CREATED_BY            -- Part of std who columns
--        LAST_UPDATE_LOGIN     -- Part of std who columns
--        ORG_ID                -- Oraganization Name
--
--    Defaults:
--    Note:
--
-- End of Comments

TYPE TerrTypeUsgs_rec_type        IS RECORD
    (
       TERR_TYPE_USG_ID         NUMBER    ,    --  := FND_API.G_MISS_NUM,
       SOURCE_ID                NUMBER    ,    --  := FND_API.G_MISS_NUM,
       TERR_TYPE_ID             NUMBER    ,    --  := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE         DATE      ,    --  := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY          NUMBER    ,    --  := FND_API.G_MISS_NUM,
       CREATION_DATE            DATE      ,    --  := FND_API.G_MISS_DATE,
       CREATED_BY               NUMBER    ,    --  := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN        NUMBER    ,    --  := FND_API.G_MISS_NUM,
       ORG_ID                   NUMBER         --  := FND_API.G_MISS_NUM
    );

G_MISS_TerrTypeUSGS_REC         TerrTypeusgs_rec_type;

TYPE TerrTypeusgs_tbl_type      IS TABLE OF   TerrTypeusgs_rec_type
                               INDEX BY BINARY_INTEGER;

G_MISS_TerrTypeUSGS_TBL         TerrTypeusgs_tbl_type;


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Territory Type source out Record:
--                           TerrTypeusgs_out_rec_type
--    ---------------------------------------------------
--    Parameters:
--
--    Required:
--
--    Defaults:
--    Note:
--
-- End of Comments

TYPE TerrTypeusgs_out_rec_type        IS RECORD
    (
       TERR_TYPE_USG_ID         NUMBER      , -- := FND_API.G_MISS_NUM,
       RETURN_STATUS            VARCHAR2(01)  -- := FND_API.G_MISS_CHAR
    );

G_MISS_TerrTypeUSGS_OUT_REC      TerrTypeusgs_out_rec_type;

TYPE TerrTypeusgs_out_tbl_type   IS TABLE OF   TerrTypeusgs_out_rec_type
                                INDEX BY BINARY_INTEGER;

G_MISS_TerrTypeUSGS_OUT_TBL      TerrTypeusgs_out_tbl_type;


--    *************************************************************
--    Start of Comments
--    -------------------------------------------------------------
--     Territory Type Qualifier Type Record: TypeQualTypeUsgs_rec_type
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
--        ORG_ID                   -- Oraganization Name
--
--    Defaults:
--    Note:
--
-- End of Comments

TYPE typequaltypeusgs_rec_type         IS RECORD
    (
       TYPE_QUAL_TYPE_USG_ID         NUMBER    ,    --  := FND_API.G_MISS_NUM,
       TERR_TYPE_ID                  NUMBER    ,    --  := FND_API.G_MISS_NUM,
       QUAL_TYPE_USG_ID              NUMBER    ,    --  := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE              DATE      ,    --  := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY               NUMBER    ,    --  := FND_API.G_MISS_NUM,
       CREATION_DATE                 DATE      ,    --  := FND_API.G_MISS_DATE,
       CREATED_BY                    NUMBER    ,    --  := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN             NUMBER    ,    --  := FND_API.G_MISS_NUM,
       ORG_ID                        NUMBER         --  := FND_API.G_MISS_NUM
    );

G_MISS_TYPEQUALTYPEUSGS_REC     typequaltypeusgs_rec_type;

TYPE typequaltypeusgs_tbl_type  IS TABLE OF   typequaltypeusgs_rec_type
                                INDEX BY BINARY_INTEGER;

G_MISS_TYPEQUALTYPEUSGS_TBL     TypeQualTypeUsgs_tbl_type;


--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory Type Source Type out Record:
--                                  TerrTypesrcType_out_rec_type
--    -----------------------------------------------------------
--    Parameters:
--
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

TYPE typequaltypeusgs_out_rec_type   IS RECORD
    (
       TYPE_QUAL_TYPE_USG_ID         NUMBER      , -- := FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  -- := FND_API.G_MISS_CHAR
    );

G_MISS_TYPEQUALTYPUSGS_OUT_REC       typequaltypeusgs_out_rec_type;


TYPE   Typequaltypeusgs_out_tbl_type IS TABLE OF   typequaltypeusgs_out_rec_type
                                     INDEX BY BINARY_INTEGER;

G_MISS_TYPEQUALTYPUSGS_OUT_TBL       Typequaltypeusgs_out_tbl_type;


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--     Territory Qualifier Record: TerrTypequal_rec_type
--    ---------------------------------------------------
--    Parameters:
--
--    Required:
--        SEEDED_QUAL_ID       -- Seeded qualifier id
--        TERR_TYPE_ID         -- Territory type identifier
--        LAST_UPDATE_DATE     -- Part of std who columns
--        LAST_UPDATED_BY      -- Part of std who columns
--        CREATION_DATE        -- Part of std who columns
--        CREATED_BY           -- Part of std who columns
--        LAST_UPDATE_LOGIN    -- Part of std who columns
--        ORG_ID               -- Oraganization Name
--
--    Defaults:
--    Note:
-- End of Comments

TYPE TerrTypequal_rec_type IS RECORD
   (   TERR_TYPE_QUAL_ID    NUMBER       ,    --  := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE     DATE         ,    --  := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY      NUMBER       ,    --  := FND_API.G_MISS_NUM,
       CREATION_DATE        DATE         ,    --  := FND_API.G_MISS_DATE,
       CREATED_BY           NUMBER       ,    --  := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN    NUMBER       ,    --  := FND_API.G_MISS_NUM,
       QUAL_USG_ID          NUMBER       ,    --  := FND_API.G_MISS_NUM,
       TERR_TYPE_ID         NUMBER       ,    --  := FND_API.G_MISS_NUM,
       EXCLUSIVE_USE_FLAG   VARCHAR2(1)  ,    --  := FND_API.G_MISS_CHAR,
       OVERLAP_ALLOWED_FLAG VARCHAR2(1)  ,    --  := FND_API.G_MISS_CHAR,
       IN_USE_FLAG          VARCHAR2(1)  ,    --  := FND_API.G_MISS_CHAR,
       QUALIFIER_MODE       VARCHAR2(30) ,    --  := FND_API.G_MISS_CHAR,
       ORG_ID               NUMBER            --  := FND_API.G_MISS_NUM
    );

G_MISS_TerrTypeQUAL_REC    TerrTypequal_rec_type;

TYPE TerrTypequal_tbl_type IS TABLE OF    TerrTypequal_rec_type
                          INDEX BY BINARY_INTEGER;

G_MISS_TerrTypeQUAL_TBL    TerrTypequal_tbl_type;


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Territory Type Qualifier Record: TerrTypequal_out_rec_type
--    ---------------------------------------------------
--    Parameters:
--
--    Required:
--
--    Defaults:
--    Note:
-- End of Comments

TYPE TerrTypequal_out_rec_type IS RECORD
   (
       TERR_TYPE_QUAL_ID    NUMBER      , -- := FND_API.G_MISS_NUM,
       return_status        VARCHAR2(1)   -- := FND_API.G_MISS_CHAR
   );

G_MISS_TerrTypeQUAL_OUT_REC    TerrTypequal_out_rec_type;

TYPE TerrTypequal_out_tbl_type IS TABLE OF  TerrTypequal_out_rec_type
                              INDEX BY BINARY_INTEGER;

G_MISS_TerrTypeQUAL_OUT_TBL    TerrTypequal_out_tbl_type;

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : create_terrtype
--    type           : public.
--    function       : creates territory type defnitions
--    pre-reqs       : Territory qualifiers has to be enabled.
--    parameters     :

--    in:
--        p_api_version_number        in  number                    required
--        p_init_msg_list             in  varchar2                  optional --default = fnd_api.g_false
--        p_commit                    in  varchar2                  optional --default = fnd_api.g_false
--        p_TerrType_rec              in  TerrType_rec_type         required --default = g_miss_TerrType_rec,
--        p_TerrTypequal_tbl          in  TerrTypequal_tbl_type     required --default = g_miss_TerrTypequal_rec,
--        p_TerrTypeusgs_tbl          in  TerrTypeusgs_rec_type     required --default = g_miss_tersrc_rec
--        p_TypequalTypeusgs_tbl      in  TypeQualTypeUsgs_tbl_type required --default = g_miss_tersrc_tbl,
--
--    out:
--        p_return_status             out varchar2(1)
--        p_msg_count                 out number
--        p_msg_data                  out varchar2(2000)
--        p_TerrType_id               out number
--        p_TerrTypequal_out_tbl      out TerrTypequal_out_tbl_type
--        p_TerrTypeusgs_out_tbl      out TerrTypeusgs_out_tbl_type
--        p_TypeQualTypeUsgs_out_tbl  out TypeQualTypeUsgs_out_tbl_type
--
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:     api for creating territory types
--
-- end of comments

procedure create_terrtype
(   p_api_version_number        in    number,
    p_init_msg_list             in    varchar2                    := fnd_api.g_false,
    p_commit                    in    varchar2                    := fnd_api.g_false,
    p_validation_level          IN    NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
    p_TerrType_rec              in    TerrType_rec_type           := g_miss_TerrType_rec,
    p_TerrTypequal_tbl          in    TerrTypequal_tbl_type       := g_miss_TerrTypequal_tbl,
    p_TerrTypeusgs_tbl          in    TerrTypeusgs_tbl_type       := g_miss_TerrTypeusgs_tbl,
    p_TypeQualTypeUsgs_tbl      in    TypeQualTypeUsgs_tbl_type   := g_miss_typeQualTypeUsgs_tbl,
    x_return_status             OUT NOCOPY   varchar2,
    x_msg_count                 OUT NOCOPY   number,
    x_msg_data                  OUT NOCOPY   varchar2,
    x_TerrType_id               OUT NOCOPY   number,
    x_TerrTypequal_out_tbl      OUT NOCOPY   TerrTypequal_out_tbl_type,
    x_TerrTypeusgs_out_tbl      OUT NOCOPY   TerrTypeusgs_out_tbl_type,
    x_TypeQualTypeUsgs_out_tbl  OUT NOCOPY   TypeQualTypeUsgs_out_tbl_type
);


--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : update_Terrtype
--    type           : public.
--    function       : Update territory type defnitions
--    pre-reqs       : Territory qualifiers has to be enabled.
--    parameters     :

--    in:
--        p_api_version_number    in  number                   required
--        p_init_msg_list         in  varchar2                 optional --default = fnd_api.g_false
--        p_commit                in  varchar2                 optional --default = fnd_api.g_false
--        p_TerrType_rec          in  TerrType_rec_type        required --default = g_miss_TerrType_rec,
--        p_TerrTypequal_tbl      in  TerrTypequal_tbl_type    required --default = g_miss_TerrTypequal_rec,
--        p_TerrTypesrc_tbl       in  TerrTypesrc_rec_type     required --default = g_miss_tersrc_rec
--        p_TerrTypeSrcType_tbl   in  TerrTypeSrcType_tbl_type required --default = g_miss_tersrc_tbl,
--    out:
--        p_return_status            OUT NOCOPY varchar2(1)
--        p_msg_count                OUT NOCOPY number
--        p_msg_data                 OUT NOCOPY varchar2(2000)
--        p_TerrTypequal_out_tbl     OUT NOCOPY TerrTypequal_out_tbl_type,
--        p_TerrTypesrc_out_tbl      OUT NOCOPY TerrTypeSrc_out_tbl_type,
--        p_TerrTypeSrcType_out_tbl  OUT NOCOPY TerrTypeSrcType_out_tbl_type
--
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              api for Updating territory types
--
-- end of comments

procedure Update_Terrtype
(   p_api_version_number        in    number,
    p_init_msg_list             in    varchar2                    := fnd_api.g_false,
    p_commit                    in    varchar2                    := fnd_api.g_false,
    p_validation_level          IN    NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
    p_TerrType_rec              in    TerrType_rec_type           := g_miss_TerrType_rec,
    p_TerrTypequal_tbl          in    TerrTypequal_tbl_type       := g_miss_TerrTypequal_tbl,
    p_TerrTypeUsgs_tbl          in    TerrTypeusgs_tbl_type       := g_miss_TerrTypeusgs_tbl,
    p_TypeQualTypeUsgs_tbl      in    TypeQualTypeUsgs_tbl_type   := g_miss_TypeQualTypeUsgs_tbl,
    x_return_status             OUT NOCOPY   varchar2,
    x_msg_count                 OUT NOCOPY   number,
    x_msg_data                  OUT NOCOPY   varchar2,
    x_TerrType_out_rec          OUT NOCOPY   TerrType_out_rec_type,
    x_TerrTypequal_out_tbl      OUT NOCOPY   TerrTypequal_out_tbl_type,
    x_TerrTypeUsgs_out_tbl      OUT NOCOPY   TerrTypeusgs_out_tbl_type,
    x_TypeQualTypeUsgs_out_tbl  OUT NOCOPY   TypeQualTypeUsgs_out_tbl_type
);

--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Delete_TerrType
--    type           : public.
--    function       : Delete territory type defnitions
--    pre-reqs       : Territory qualifiers has to be enabled.
--    parameters     :
--
--    in:
--        p_api_version_number   in  number               required
--        p_init_msg_list        in  varchar2             optional --default = fnd_api.g_false
--        p_commit               in  varchar2             optional --default = fnd_api.g_false
--        p_TerrType_id          in  number
--
--    out:
--        p_return_status        OUT NOCOPY varchar2(1)
--        p_msg_count            OUT NOCOPY number
--        p_msg_data             OUT NOCOPY varchar2(2000)
--
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              API for Deleting territory types
--
-- end of comments

procedure Delete_TerrType
(   p_api_version_number       in    number,
    p_init_msg_list            in    varchar2  := fnd_api.g_false,
    p_commit                   in    varchar2  := fnd_api.g_false,
    p_validation_level         IN    NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_TerrType_id              in    number,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2
);




--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Deactivate_TerrType
--    type           : public.
--    function       : Deactivate territory type defnitions
--    pre-reqs       : Territory qualifiers has to be enabled.
--    parameters     :
--
--    in:
--        p_api_version_number   in  number               required
--        p_init_msg_list        in  varchar2             optional --default = fnd_api.g_false
--        p_commit               in  varchar2             optional --default = fnd_api.g_false
--        p_TerrType_id          in  number
--
--    out:
--        p_return_status        OUT NOCOPY varchar2(1)
--        p_msg_count            OUT NOCOPY number
--        p_msg_data             OUT NOCOPY varchar2(2000)
--
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              API for Deleting territory types
--
-- end of comments

procedure Deactivate_TerrType
(   p_api_version_number       in    number,
    p_init_msg_list            in    varchar2  := fnd_api.g_false,
    p_commit                   in    varchar2  := fnd_api.g_false,
    p_validation_level         IN    NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_TerrType_id              in    number,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    x_msg_data                 OUT NOCOPY   varchar2
);



--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Copy_TerrType
--    type           : public.
--    function       : Copy_territory type defnitions
--    pre-reqs       : Territory qualifiers has to be enabled.
--    parameters     :
--
--    in:
--        p_api_version_number   in  number               required
--        p_init_msg_list        in  varchar2             optional --default = fnd_api.g_false
--        p_commit               in  varchar2             optional --default = fnd_api.g_false
--        p_TerrType_id          in  number
--        p_TerrType_Name        in  varchar2
--        p_TerrType_Description in  varchar2
--        p_Enabled_Flag         in  varchar2
--        p_Start_Date           in  date
--        p_End_Date             in  date
--
--    out:
--        p_return_status        OUT NOCOPY varchar2(1)
--        p_msg_count            OUT NOCOPY number
--        p_msg_data             OUT NOCOPY varchar2(2000)
--
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              API for Copying territory types
--
-- end of comments

procedure Copy_TerrType
(   p_api_version_number       in    number,
    p_init_msg_list            in    varchar2   := fnd_api.g_false,
    p_commit                   in    varchar2   := fnd_api.g_false,
    p_validation_level         IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_TerrType_id              in    number,
    p_TerrType_Name            in    varchar2,
    p_TerrType_Description     in    varchar2,
    p_Enabled_Flag             in    varchar2,
    p_Start_Date               in    date,
    p_End_Date                 in    date,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_TerrType_id              OUT NOCOPY   number
);



--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrType_Header
--    Type      : PUBLIC
--    Function  : To create Territories Types - which inludes the creation of following
--                Territory Type Header, Territory Type Usages, Territory Type qualifier
--                type usages table.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_Api_Version_Number          NUMBER
--      P_TerrType_Rec                TerrType_Rec_Type                := G_Miss_TerrType_Rec
--      P_TerrTypeUsgs_Tbl            TerrTypeusgs_Tbl_Type            := G_MISS_TerrTypeusgs_Tbl
--      P_TypeQualTypeUsgs_Tbl        TypeQualTypeUsgs_Tbl_Type        := G_Miss_TypeQualTypeUsgs_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      P_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      P_Commit                      VARCHAR2                         := FND_API.G_FALSE
--      p_validation_level            NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_Msg_Count                   NUMBER
--      X_Msg_Data                    VARCHAR2(2000)
--      X_TerrType_Out_Rec            TerrType_Out_Rec_Type
--      X_TerrTypeusgs_Out_Tbl        TerrTypeusgs_Out_Tbl_Type
--      X_TypeQualTypeUsgs_Out_Tbl    TypeQualTypeUsgs_Out_Tbl_Type
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_TerrType_Header
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_TerrType_Rec                IN  TerrType_Rec_Type                := G_Miss_TerrType_Rec,
  P_TerrTypeUsgs_Tbl            IN  TerrTypeusgs_Tbl_Type            := G_MISS_TerrTypeusgs_Tbl,
  P_TypeQualTypeUsgs_Tbl        IN  TypeQualTypeUsgs_Tbl_Type        := G_Miss_TypeQualTypeUsgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_TerrType_Out_Rec            OUT NOCOPY TerrType_Out_Rec_Type,
  X_TerrTypeusgs_Out_Tbl        OUT NOCOPY TerrTypeusgs_Out_Tbl_Type,
  X_TypeQualTypeUsgs_Out_Tbl    OUT NOCOPY TypeQualTypeUsgs_Out_Tbl_Type);

--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrType_record
--    Type      : PUBLIC
--    Function  : To create a records in jtf_Terr_Type_all table
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                         Default
--      X_TerrType_Rec                TerrType_Rec_Type		            := G_Miss_TerrType_Rec,
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_terr_id                     NUMBER;
--      X_Return_Status               VARCHAR2(1)
--      X_TerrType_Out_Rec            TerrType_Out_Rec_Type
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_TerrType_Record
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_TerrType_Rec                IN  TerrType_Rec_Type                := G_Miss_TerrType_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_TerrType_Id                 OUT NOCOPY NUMBER,
  X_TerrType_Out_Rec            OUT NOCOPY TerrType_Out_Rec_Type
);

--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrType_Usages
--    Type      : PUBLIC
--    Function  : To create Territories Type usages
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terr_id                     NUMBER;
--      P_TerrTypeUsgs_Tbl            TerrTypeUsgs_Tbl_Type            := G_MISS_TerrTypeUsgs_Tbl
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrTypeUsgs_Out_Tbl        TerrTypeUsgs_Out_Tbl,
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_TerrType_Usages
( P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_TerrType_Id                 IN  NUMBER,
  P_TerrTypeUsgs_Tbl            IN  TerrTypeUsgs_Tbl_Type          := G_MISS_TerrTypeUsgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_TerrTypeUsgs_Out_Tbl        OUT NOCOPY TerrTypeUsgs_Out_Tbl_Type
);

--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrTypeQualType_Usage
--    Type      : PUBLIC
--    Function  : To create Territory type qualifier type
--                usages
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terr_id                     NUMBER
--      p_terr_usg_id                 NUMBER;
--      P_Terr_QualTypeUsgs_Rec       Terr_QualTypeUsgs_Rec_Type       := G_Miss_Terr_QualTypeUsgs_Rec
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl,
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_TerrTypeQualType_Usage
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_TerrType_Id                 IN  NUMBER,
  P_TerrTypeUsg_Id              IN  NUMBER,
  P_TypeQualTypeUsgs_Rec        IN  TypeQualTypeUsgs_Rec_Type       := G_Miss_TypeQualTypeUsgs_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_TypeQualTypeUsgs_Id         OUT NOCOPY NUMBER,
  X_TypeQualTypeUsgs_Out_Rec    OUT NOCOPY TypeQualTypeUsgs_Out_Rec_Type
 );


--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrTypeQualType_Usage
--    Type      : PUBLIC
--    Function  : To create Territories type qualifier usages
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrType_Id                 NUMBER
--      P_TerrTypeUsg_Id              NUMBER;
--      P_TypeQualTypeUsgs_Tbl        TypeQualTypeUsgs_Tbl_Type       := G_Miss_TypeQualTypeUsgs_Tbl
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TypeQualTypeUsgs_Out_Tbl    TypeQualTypeUsgs_Out_Tbl,
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_TerrTypeQualType_Usage
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_TerrType_Id                 IN  NUMBER,
  P_TerrTypeUsg_Id              IN  NUMBER,
  P_TypeQualTypeUsgs_Tbl        IN  TypeQualTypeUsgs_Tbl_Type       := G_Miss_TypeQualTypeUsgs_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_TypeQualTypeUsgs_Out_Tbl    OUT NOCOPY TypeQualTypeUsgs_Out_Tbl_Type);

--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrType_QualIfier
--    Type      : PUBLIC
--    Function  : To create Territories qualifier
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terrType_id                 NUMBER
--      P_TerrTypeQual_Rec            TerrTypeQual_Rec_Type               := G_Miss_TerrTypeQual_Rec
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_TerrTypeQual_Id             NUMBER
--      X_Return_Status               VARCHAR2(1)
--      X_TerrTypeQual_Out_Rec        TerrTypeQual_Out_Rec
--
--    Notes:    This is a an overloaded procedure
--
--
--    End of Comments
--
PROCEDURE Create_TerrType_Qualifier
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_TerrType_Id                 IN  NUMBER,
  P_TerrTypeQual_Rec            IN  TerrTypeQual_Rec_Type     := G_Miss_TerrTypeQual_Rec,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_TerrTypeQual_Id             OUT NOCOPY NUMBER,
  X_TerrTypeQual_Out_Rec        OUT NOCOPY TerrTypeQual_Out_Rec_Type);


--
--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrType_Qualifier
--    Type      : PUBLIC
--    Function  : To create Territories type qualifier
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_terrType_id                 NUMBER
--      P_TerrTypeQual_Tbl            TerrTypeQual_Tbl_Type               := G_Miss_TerrTypeQual_Tbl
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2(1)
--      X_TerrTypeQual_Out_Tbl        TerrTypeQual_Out_Tbl
--
--    Notes:    This is a an overloaded procedure. This one
--              will call the overloade procedure for records
--              creation
--
--
--    End of Comments
--
PROCEDURE Create_TerrType_Qualifier
 (P_Api_Version_Number          IN  NUMBER,
  P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
  P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
  p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
  P_TerrType_Id                 IN  NUMBER,
  P_TerrTypeQual_Tbl            IN  TerrTypeQual_Tbl_Type       := G_Miss_TerrTypeQual_Tbl,
  X_Return_Status               OUT NOCOPY VARCHAR2,
  X_Msg_Count                   OUT NOCOPY NUMBER,
  X_Msg_Data                    OUT NOCOPY VARCHAR2,
  X_TerrTypeQual_Out_Tbl        OUT NOCOPY TerrTypeQual_Out_Tbl_Type);

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrType_Record
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_TerrType_Rec              TerrType_Rec_Type  := G_MISS_TERRTYPE_REC
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--     X_TerrType_Out_rec          TerrType_Out_Rec_Type
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_TerrType_Record
  (P_Api_Version_Number          IN  NUMBER,
   P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
   P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
   p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
   P_TerrType_Rec                IN   TerrType_Rec_Type  := G_MISS_TERRTYPE_REC,
   X_Return_Status               OUT NOCOPY  VARCHAR2,
   X_Msg_Count                   OUT NOCOPY NUMBER,
   X_Msg_Data                    OUT NOCOPY VARCHAR2,
   X_TerrType_Out_rec            OUT NOCOPY  TerrType_Out_Rec_Type);

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrType_Usages
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type               Default
--     P_TerrTypeUsgs_Rec          TerrTypeUsgs_Rec_Type   := G_MISS_TERRTYPEUSGS_REC
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type               Default
--     X_Return_Status             VARCHAR2
--     X_TerrTypeUsgs_Out_Rec      TerrTypeUsgs_Out_Rec_Type
--
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_TerrType_Usages
  (P_Api_Version_Number          IN  NUMBER,
   P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
   P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
   p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
   P_TerrTypeUsgs_Rec            IN  TerrTypeUsgs_Rec_Type            := G_MISS_TERRTYPEUSGS_REC,
   X_Return_Status               OUT NOCOPY VARCHAR2,
   X_Msg_Count                   OUT NOCOPY NUMBER,
   X_Msg_Data                    OUT NOCOPY VARCHAR2,
   X_TerrTypeUsgs_Out_Rec        OUT NOCOPY TerrTypeUsgs_Out_Rec_Type
  );


--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrType_Usages
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type               Default
--     P_TerrTypeUsgs_Tbl          TerrTypeUsgs_Tbl_Type   := G_MISS_TERRTYPEUSGS_TBL
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type               Default
--     X_Return_Status             VARCHAR2
--     X_TerrTypeUsgs_Out_Tbl      TerrTypeUsgs_Out_Tbl_Type
--
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_TerrType_Usages
  (P_Api_Version_Number          IN  NUMBER,
   P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
   P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
   p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
   P_TerrTypeUsgs_Tbl            IN  TerrTypeUsgs_Tbl_Type  := G_MISS_TERRTYPEUSGS_TBL,
   X_Return_Status               OUT NOCOPY VARCHAR2,
   X_Msg_Count                   OUT NOCOPY NUMBER,
   X_Msg_Data                    OUT NOCOPY VARCHAR2,
   X_TerrTypeUsgs_Out_Tbl        OUT NOCOPY TerrTypeUsgs_Out_Tbl_Type);


--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrTypeQualType_Usage
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_TerrTypeQualType_Usage
  (P_Api_Version_Number          IN  NUMBER,
   P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
   P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
   p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
   P_TypeQualTypeUsgs_Rec        IN  TypeQualTypeUsgs_Rec_Type        := G_Miss_TypeQualTypeUsgs_Rec,
   X_Return_Status               OUT NOCOPY VARCHAR2,
   X_Msg_Count                   OUT NOCOPY NUMBER,
   X_Msg_Data                    OUT NOCOPY VARCHAR2,
   X_TypeQualTypeUsgs_Out_Rec    OUT NOCOPY TypeQualTypeUsgs_Out_Rec_Type);


--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrTypeQualType_Usage
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_TerrTypeQualType_Usage
  (P_Api_Version_Number          IN  NUMBER,
   P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
   P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
   p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
   P_TypeQualTypeUsgs_Tbl        IN  TypeQualTypeUsgs_Tbl_Type        := G_Miss_TypeQualTypeUsgs_Tbl,
   X_Return_Status               OUT NOCOPY VARCHAR2,
   X_Msg_Count                   OUT NOCOPY NUMBER,
   X_Msg_Data                    OUT NOCOPY VARCHAR2,
   X_TypeQualTypeUsgs_Out_Tbl    OUT NOCOPY TypeQualTypeUsgs_Out_Tbl_Type);

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrType_Qualifier
--   Type    :
--   Pre-Req :
--   Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrTypeQual_Rec            TerrTypeQual_Rec_Type            := G_Miss_TerrTypeQual_Rec
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2
--      X_Terr_Qual_Out_Rec           Terr_Qual_Out_Rec_Type
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_TerrType_Qualifier
  (P_Api_Version_Number          IN  NUMBER,
   P_Init_Msg_List               IN  VARCHAR2                  := FND_API.G_FALSE,
   P_Commit                      IN  VARCHAR2                  := FND_API.G_FALSE,
   p_validation_level            IN  NUMBER                    := FND_API.G_VALID_LEVEL_FULL,
   P_TerrTypeQual_Rec            IN  TerrTypeQual_Rec_Type     := G_Miss_TerrTypeQual_Rec,
   X_Return_Status               OUT NOCOPY VARCHAR2,
   X_Msg_Count                   OUT NOCOPY NUMBER,
   X_Msg_Data                    OUT NOCOPY VARCHAR2,
   X_TerrTypeQual_Out_Rec        OUT NOCOPY TerrTypeQual_Out_Rec_Type);

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_TerrType_Qualifier
--   Type    :
--   Pre-Req :
--   Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      P_TerrTypeQual_Tbl            TerrTypeQual_Tbl_Type            := G_Miss_TerrTypeQual_Tbl
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      X_Return_Status               VARCHAR2
--      X_TerrTypeQual_Out_Tbl        TerrTypeQual_Out_Tbl_Type
--
--   Note:
--
--   End of Comments
--
PROCEDURE Update_TerrType_Qualifier
  (P_Api_Version_Number          IN  NUMBER,
   P_Init_Msg_List               IN  VARCHAR2                         := FND_API.G_FALSE,
   P_Commit                      IN  VARCHAR2                         := FND_API.G_FALSE,
   p_validation_level            IN  NUMBER                           := FND_API.G_VALID_LEVEL_FULL,
   P_TerrTypeQual_Tbl            IN  TerrTypeQual_Tbl_Type            := G_Miss_TerrTypeQual_Tbl,
   X_Return_Status               OUT NOCOPY VARCHAR2,
   X_Msg_Count                   OUT NOCOPY NUMBER,
   X_Msg_Data                    OUT NOCOPY VARCHAR2,
   X_TerrTypeQual_Out_Tbl        OUT NOCOPY TerrTypeQual_Out_Tbl_Type);

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_TerrType_Qualifier
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Api_Version_Number        NUMBER,
--     P_Init_Msg_List             VARCHAR2           FND_API.G_FALSE
--     P_Commit                    VARCHAR2
--     P_TerrTypeQual_Id           NUMBER
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--
--   Note:
--
--   End of Comments
--
PROCEDURE  Delete_TerrType_Qualifier
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_TerrTypeQual_Id            IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2);

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_TerrTypeQualType_Usage
--   Type    :
--   Pre-Req :
--   Parameters
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Api_Version_Number        NUMBER,
--     P_Init_Msg_List             VARCHAR2           := FND_API.G_FALSE
--     P_Commit                    VARCHAR2           := FND_API.G_FALSE
--     P_Terr_Qual_Type_Usg_Id     NUMBER
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--
--   Note:
--
--   End of Comments
--
PROCEDURE Delete_TerrTypeQualType_Usage
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_TerrTypeQualType_Usg_Id    IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2);

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_TerrType_Usages
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Api_Version_Number        NUMBER,
--     P_Init_Msg_List             VARCHAR2           FND_API.G_FALSE
--     P_Commit                    VARCHAR2
--     P_TerrTypeUsg_Id            NUMBER
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--
--   Note:
--
--   End of Comments
--
PROCEDURE Delete_TerrType_Usages
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_TerrTypeUsg_Id             IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2);

--
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_TerrType_Record
--   Type    :
--   Pre-Req :
--   Parameters:
--    IN
--     Required:
--     Parameter Name              Data Type          Default
--     P_Api_Version_Number        NUMBER,
--     P_Init_Msg_List             VARCHAR2           FND_API.G_FALSE
--     P_Commit                    VARCHAR2
--     P_TerrType_Id               NUMBER
--
--     Optional:
--    OUT:
--     Parameter Name              Data Type          Default
--     X_Return_Status             VARCHAR2
--
--   Note:
--
--   End of Comments
--
PROCEDURE Delete_TerrType_Record
  (P_Api_Version_Number         IN   NUMBER,
   P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
   P_TerrType_Id                IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  VARCHAR2,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2);

--
-- Validate the Territory Type RECORD
-- Validate Territory Type Name and other not null columns
  PROCEDURE Validate_TerrType_Record
  (p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
   p_Terr_Type_Rec               IN  TerrType_Rec_Type           := G_Miss_TerrType_Rec,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2 );

--
-- This procedure will check whether the qualifiers passed are
-- valid.
--
  PROCEDURE Validate_Qualifier
  (P_TerrTypequal_Rec            IN  TerrTypeQual_Rec_Type  := G_Miss_TerrTypequal_Rec,
   p_Terr_Type_Id                IN  NUMBER,
   p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2 );

---------------------------------------------------------------------
--                Validate the Territory Type Usage
---------------------------------------------------------------------
-- Columns Validated
--         Make sure a Territory Type Usage is specified
--         Make sure the Territory Type Id is valid
--         Make sure the territory Type usage Id is Valid
---------------------------------------------------------------------
   PROCEDURE Validate_TerrType_Usage
   (p_init_msg_list               IN  VARCHAR2               := FND_API.G_FALSE,
    x_Return_Status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2,
    p_TerrTypeusgs_Rec            IN  TerrTypeusgs_Rec_Type     := G_MISS_TerrTypeusgs_Rec,
    p_Terr_Type_Id                IN  NUMBER);

---------------------------------------------------------------------
--             Validate the Territory Qualifer Type Usage
---------------------------------------------------------------------
-- Columns Validated
--         Make sure a Territory Qual Type Usage is specified
--         Make sure the Territory Id is valid
--         Make sure the QUAL_TYPE_USG_ID is valid
---------------------------------------------------------------------
PROCEDURE Validate_Type_Qtype_Usage
  (p_init_msg_list               IN  VARCHAR2                    := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_Type_QualTypeUsgs_Rec       IN  TypeQualTypeUsgs_Rec_Type  := G_MISS_TYPEQUALTYPEUSGS_REC,
   p_Terr_Type_Id                IN  NUMBER);

--
-- Checks whether a Terr Type is used by any territories
--
   PROCEDURE Is_TerrType_Deletable
   (P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_TerrType_Id                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  VARCHAR2,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2 );

-- Package spec
END JTF_TERRITORY_TYPE_PVT;

 

/
