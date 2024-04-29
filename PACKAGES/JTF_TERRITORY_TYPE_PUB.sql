--------------------------------------------------------
--  DDL for Package JTF_TERRITORY_TYPE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERRITORY_TYPE_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfpttys.pls 120.0 2005/06/02 18:21:04 appldev ship $ */
--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_TYPE_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is a public API for inserting territory type
--      related information in to information into JTF tables.
--      It contains specification for pl/sql records and tables
--      and the Public territory related API's.
--
--      Procedures:
--         Create_Opportunity (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/09/99   VNEDUNGA         Created
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
        TERR_TYPE_ID           NUMBER         := FND_API.G_MISS_NUM,
        LAST_UPDATE_DATE       DATE           := FND_API.G_MISS_DATE,
        LAST_UPDATED_BY        NUMBER         := FND_API.G_MISS_NUM,
        CREATION_DATE          DATE           := FND_API.G_MISS_DATE,
        CREATED_BY             NUMBER         := FND_API.G_MISS_NUM,
        LAST_UPDATE_LOGIN      NUMBER         := FND_API.G_MISS_NUM,
        APPLICATION_SHORT_NAME VARCHAR2(50)   := FND_API.G_MISS_CHAR,
        NAME                   VARCHAR2(60)   := FND_API.G_MISS_CHAR,
        ENABLED_FLAG           VARCHAR2(1)    := FND_API.G_MISS_CHAR,
        START_DATE_ACTIVE      DATE           := FND_API.G_MISS_DATE,
        END_DATE_ACTIVE        DATE           := FND_API.G_MISS_DATE,
        DESCRIPTION            VARCHAR2(240)  := FND_API.G_MISS_CHAR,
        ORG_ID                 NUMBER         := FND_API.G_MISS_NUM,
        ATTRIBUTE_CATEGORY     VARCHAR2(30)   := FND_API.G_MISS_CHAR,
        ATTRIBUTE1             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE2             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE3             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE4             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE5             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE6             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE7             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE8             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE9             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE10            VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE11            VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE12            VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE13            VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE14            VARCHAR2(150)  := FND_API.G_MISS_CHAR,
        ATTRIBUTE15            VARCHAR2(150)  := FND_API.G_MISS_CHAR
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
       TERR_TYPE_ID             NUMBER       := FND_API.G_MISS_NUM,
       RETURN_STATUS            VARCHAR2(01) := FND_API.G_MISS_CHAR
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
--
--    Defaults:
--    Note:
--
-- End of Comments

TYPE TerrTypeUsgs_rec_type        IS RECORD
    (
       TERR_TYPE_USG_ID         NUMBER    := FND_API.G_MISS_NUM,
       SOURCE_ID                NUMBER    := FND_API.G_MISS_NUM,
       TERR_TYPE_ID             NUMBER    := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE         DATE      := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY          NUMBER    := FND_API.G_MISS_NUM,
       CREATION_DATE            DATE      := FND_API.G_MISS_DATE,
       CREATED_BY               NUMBER    := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN        NUMBER    := FND_API.G_MISS_NUM,
       ORG_ID                   NUMBER    := FND_API.G_MISS_NUM
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
       TERR_TYPE_USG_ID         NUMBER       := FND_API.G_MISS_NUM,
       RETURN_STATUS            VARCHAR2(01) := FND_API.G_MISS_CHAR
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
--
--    Defaults:
--    Note:
--
-- End of Comments

TYPE typequaltypeusgs_rec_type         IS RECORD
    (
       TYPE_QUAL_TYPE_USG_ID         NUMBER    := FND_API.G_MISS_NUM,
       TERR_TYPE_ID                  NUMBER    := FND_API.G_MISS_NUM,
       QUAL_TYPE_USG_ID              NUMBER    := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE              DATE      := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY               NUMBER    := FND_API.G_MISS_NUM,
       CREATION_DATE                 DATE      := FND_API.G_MISS_DATE,
       CREATED_BY                    NUMBER    := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN             NUMBER    := FND_API.G_MISS_NUM,
       ORG_ID                        NUMBER    := FND_API.G_MISS_NUM
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
       TYPE_QUAL_TYPE_USG_ID         NUMBER        := FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  := FND_API.G_MISS_CHAR
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
--
--    Defaults:
--    Note:
-- End of Comments

TYPE TerrTypequal_rec_type IS RECORD
   (
       TERR_TYPE_QUAL_ID    NUMBER       := FND_API.G_MISS_NUM,
       QUAL_USG_ID          NUMBER       := FND_API.G_MISS_NUM,
       TERR_TYPE_ID         NUMBER       := FND_API.G_MISS_NUM,
       EXCLUSIVE_USE_FLAG   VARCHAR2(1)  := FND_API.G_MISS_CHAR,
       LAST_UPDATE_DATE     DATE         := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY      NUMBER       := FND_API.G_MISS_NUM,
       CREATION_DATE        DATE         := FND_API.G_MISS_DATE,
       CREATED_BY           NUMBER       := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN    NUMBER       := FND_API.G_MISS_NUM,
       OVERLAP_ALLOWED_FLAG VARCHAR2(1)  := FND_API.G_MISS_CHAR,
       IN_USE_FLAG          VARCHAR2(1)  := FND_API.G_MISS_CHAR,
       QUALIFIER_MODE       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ORG_ID               NUMBER       := FND_API.G_MISS_NUM
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
       TERR_TYPE_QUAL_ID    NUMBER       := FND_API.G_MISS_NUM,
       return_status        VARCHAR2(1)  := FND_API.G_MISS_CHAR
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
--        p_TerrType_rec               in  TerrType_rec_type          required --default = g_miss_TerrType_rec,
--        p_TerrTypequal_tbl           in  TerrTypequal_tbl_type      required --default = g_miss_TerrTypequal_rec,
--        p_TerrTypeusgs_tbl           in  TerrTypeusgs_rec_type      required --default = g_miss_tersrc_rec
--        p_TypequalTypeusgs_tbl      in  TypeQualTypeUsgs_tbl_type required --default = g_miss_tersrc_tbl,
--
--    out:
--        p_return_status             out varchar2(1)
--        p_msg_count                 out number
--        p_msg_data                  out varchar2(2000)
--        p_TerrType_id               out number
--        p_TerrTypequal_out_tbl       out TerrTypequal_out_tbl_type
--        p_TerrTypeusgs_out_tbl       out TerrTypeusgs_out_tbl_type
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
    p_TerrType_rec               in    TerrType_rec_type            := g_miss_TerrType_rec,
    p_TerrTypequal_tbl           in    TerrTypequal_tbl_type        := g_miss_TerrTypequal_tbl,
    p_TerrTypeusgs_tbl           in    TerrTypeusgs_tbl_type        := g_miss_TerrTypeusgs_tbl,
    p_TypeQualTypeUsgs_tbl      in    TypeQualTypeUsgs_tbl_type   := g_miss_typeQualTypeUsgs_tbl,
    x_return_status             OUT NOCOPY   varchar2,
    x_msg_count                 OUT NOCOPY   number,
    x_msg_data                  OUT NOCOPY   varchar2,
    x_TerrType_id               OUT NOCOPY   number,
    x_TerrTypequal_out_tbl       OUT NOCOPY   TerrTypequal_out_tbl_type,
    x_TerrTypeusgs_out_tbl       OUT NOCOPY   TerrTypeusgs_out_tbl_type,
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
--        p_api_version_number   in  number                  required
--        p_init_msg_list        in  varchar2                optional --default = fnd_api.g_false
--        p_commit               in  varchar2                optional --default = fnd_api.g_false
--        p_TerrType_rec          in  TerrType_rec_type        required --default = g_miss_TerrType_rec,
--        p_TerrTypequal_tbl      in  TerrTypequal_tbl_type    required --default = g_miss_TerrTypequal_rec,
--        p_TerrTypesrc_tbl       in  TerrTypesrc_rec_type     required --default = g_miss_tersrc_rec
--        p_TerrTypeSrcType_tbl   in  TerrTypeSrcType_tbl_type required --default = g_miss_tersrc_tbl,
--    out:
--        p_return_status            out varchar2(1)
--        p_msg_count                out number
--        p_msg_data                 out varchar2(2000)
--        p_TerrTypequal_out_tbl      out   TerrTypequal_out_tbl_type,
--        p_TerrTypesrc_out_tbl       out   TerrTypeSrc_out_tbl_type,
--        p_TerrTypeSrcType_out_tbl   out   TerrTypeSrcType_out_tbl_type
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
(   p_api_version_number       in    number,
    p_init_msg_list            in    varchar2                    := fnd_api.g_false,
    p_commit                   in    varchar2                    := fnd_api.g_false,
    p_TerrType_rec              in    TerrType_rec_type            := g_miss_TerrType_rec,
    p_TerrTypequal_tbl          in    TerrTypequal_tbl_type        := g_miss_TerrTypequal_tbl,
    p_TerrTypeUsgs_tbl           in    TerrTypeusgs_tbl_type        := g_miss_TerrTypeusgs_tbl,
    p_TypeQualTypeUsgs_tbl     in    TypeQualTypeUsgs_tbl_type   := g_miss_TypeQualTypeUsgs_tbl,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    x_msg_data                 OUT NOCOPY   varchar2,
    x_TerrType_out_rec          OUT NOCOPY   TerrType_out_rec_type,
    x_TerrTypequal_out_tbl      OUT NOCOPY   TerrTypequal_out_tbl_type,
    x_TerrTypeUsgs_out_tbl       OUT NOCOPY   TerrTypeusgs_out_tbl_type,
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
--        p_return_status        out varchar2(1)
--        p_msg_count            out number
--        p_msg_data             out varchar2(2000)
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
    p_TerrType_id              in    number,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    x_msg_data                 OUT NOCOPY   varchar2
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
--        p_return_status        out varchar2(1)
--        p_msg_count            out number
--        p_msg_data             out varchar2(2000)
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
    p_TerrType_id              in    number,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    x_msg_data                 OUT NOCOPY   varchar2
);
--
END JTF_TERRITORY_TYPE_PUB; -- Package spec

 

/
