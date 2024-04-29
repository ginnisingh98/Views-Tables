--------------------------------------------------------
--  DDL for Package CN_IMP_HEADERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_IMP_HEADERS_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvimhrs.pls 115.8 2002/11/21 21:13:31 hlchen ship $

-- * ------------------------------------------------------------------+
--   Record Type Definition
-- * ------------------------------------------------------------------+

TYPE IMP_HEADERS_REC_TYPE IS RECORD
  (
    IMP_HEADER_ID	NUMBER	:= FND_API.G_MISS_NUM,
    NAME	VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
    DESCRIPTION	VARCHAR2(80)	:= FND_API.G_MISS_CHAR,
    IMPORT_TYPE_CODE	VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
    OPERATION	VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
    SERVER_FLAG	VARCHAR2(1)	:= FND_API.G_MISS_CHAR,
    USER_FILENAME	VARCHAR2(2000)	:= FND_API.G_MISS_CHAR,
    DATA_FILENAME	VARCHAR2(2000)	:= FND_API.G_MISS_CHAR,
    TERMINATED_BY	VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
    ENCLOSED_BY	VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
    HEADINGS_FLAG	VARCHAR2(1)	:= FND_API.G_MISS_CHAR,
    STAGED_ROW	NUMBER	:= FND_API.G_MISS_NUM,
    PROCESSED_ROW	NUMBER	:= FND_API.G_MISS_NUM,
    FAILED_ROW	NUMBER	:= FND_API.G_MISS_NUM,
    STATUS_CODE	VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
    IMP_MAP_ID	NUMBER	:= FND_API.G_MISS_NUM,
    SOURCE_COLUMN_NUM	NUMBER	:= FND_API.G_MISS_NUM,
    OBJECT_VERSION_NUMBER	NUMBER	:= FND_API.G_MISS_NUM,
    ATTRIBUTE_CATEGORY	VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE1	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE2	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE3	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE4	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE5	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE6	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE7	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE8	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE9	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE10	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE11	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE12	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE13	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE14	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    ATTRIBUTE15	VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
    CREATION_DATE	DATE	:= FND_API.G_MISS_DATE,
    CREATED_BY	NUMBER	:= FND_API.G_MISS_NUM,
    LAST_UPDATE_DATE	DATE	:= FND_API.G_MISS_DATE,
    LAST_UPDATED_BY	NUMBER	:= FND_API.G_MISS_NUM,
    LAST_UPDATE_LOGIN	NUMBER	:= FND_API.G_MISS_NUM
  );

G_MISS_IMP_HEADERS_REC IMP_HEADERS_REC_TYPE;

-- Start of comments
--    API name        : Create_Imp_header
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_imp_header       IN   imp_header_rec_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--                      x_imp_header_id      OUT     NUMBER
--    Version :         Current version       1.0
--
--
--
--    Notes           : Note text
--
-- End of comments

PROCEDURE Create_Imp_header
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_imp_header           IN     imp_headers_rec_type,
   x_imp_header_id        OUT NOCOPY    NUMBER
   );

-- Start of comments
--    API name        : Update_Imp_header
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_imp_header       IN   imp_header_rec_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--
--
--
--    Notes           : Note text
--
-- End of comments

PROCEDURE Update_Imp_header
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_imp_header           IN     imp_headers_rec_type
   );

-- Start of comments
--    API name        : Delete_Imp_header
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_imp_header       IN   imp_header_rec_type
--                      p_map_obj_num             IN     NUMBER,
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--
--
--
--    Notes           : Note text
--
-- End of comments

PROCEDURE Delete_Imp_header
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_map_obj_num             IN     NUMBER,
   p_imp_header              IN     imp_headers_rec_type
   );

-- Start of comments
--    API name        : Get_Oerr_Msg
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              :
--                      p_errcode           IN VARCHAR2
--    OUT             :
--                      x_errmsg            OUT VARCHAR2(2000)
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments

PROCEDURE Get_Oerr_Msg
 ( p_errcode              IN     VARCHAR2 := FND_API.G_FALSE     ,
   x_errmsg               OUT NOCOPY    VARCHAR2
   );

END CN_IMP_HEADERS_PVT;

 

/
