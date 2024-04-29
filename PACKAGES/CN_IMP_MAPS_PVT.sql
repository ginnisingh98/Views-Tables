--------------------------------------------------------
--  DDL for Package CN_IMP_MAPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_IMP_MAPS_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvimmps.pls 120.2 2005/08/07 23:03:40 vensrini noship $

-- * ------------------------------------------------------------------+
--   Record Type Definition
-- * ------------------------------------------------------------------+
TYPE v_Tbl_Type IS TABLE OF VARCHAR2(120) INDEX BY BINARY_INTEGER;

G_MISS_V_TBL v_Tbl_Type;

TYPE IMP_MAPS_REC_TYPE IS RECORD
  (
    IMP_MAP_ID	NUMBER	:= FND_API.G_MISS_NUM,
    NAME	VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
    IMPORT_TYPE_CODE	VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
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

G_MISS_IMP_MAPS_REC IMP_MAPS_REC_TYPE;

TYPE MAP_FIELD_REC_TYPE IS RECORD
  (value VARCHAR2(120)	:= FND_API.G_MISS_CHAR,
   text  VARCHAR2(120)	:= FND_API.G_MISS_CHAR,
   colname VARCHAR2(120)  := FND_API.G_MISS_CHAR
   );

G_MISS_MAP_FIELD_REC MAP_FIELD_REC_TYPE;

TYPE MAP_FIELD_TBL_TYPE IS TABLE OF MAP_FIELD_REC_TYPE INDEX BY BINARY_INTEGER ;

G_MISS_MAP_FIELD_TBL MAP_FIELD_TBL_TYPE;

-- Start of comments
--    API name        : Create_Mapping
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
--                      p_imp_header_id     IN     NUMBER,
--                      p_src_column_num       IN     NUMBER,
--                      p_imp_map       IN   imp_maps_rec_type
--                      p_source_fields        IN     v_Tbl_Type ,
--                      p_target_fields     IN     v_Tbl_Type ,
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--                      x_imp_map_id      OUT     NUMBER
--    Version :         Current version       1.0
--
--
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Create_Mapping
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_imp_header_id     IN     NUMBER,
   p_src_column_num    IN     NUMBER,
   p_imp_map           IN     imp_maps_rec_type,
   p_source_fields     IN     MAP_FIELD_TBL_TYPE ,
   p_target_fields     IN     v_Tbl_Type ,
   x_imp_map_id        OUT NOCOPY    NUMBER,
   p_org_id		IN	NUMBER
   );

-- Start of comments
--    API name        : retrieve_Fields
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_imp_header_id     IN     NUMBER,
--                      p_imp_map       IN   imp_maps_rec_type
--                      p_source_fields        IN    MAP_FIELD_TBL_TYPE
--                      p_target_fields     IN     MAP_FIELD_TBL_TYPE
--                      p_mapped_fields     IN     MAP_FIELD_TBL_TYPE
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--                      x_imp_map_id      OUT     NUMBER
--                      x_map_obj_num       OUT  NUMBER
--    Version :         Current version       1.0
--
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE retrieve_Fields
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_imp_map_id        IN    NUMBER ,
   p_import_type_code  IN    VARCHAR2 ,
   x_source_fields     OUT NOCOPY   MAP_FIELD_TBL_TYPE,
   x_target_fields     OUT NOCOPY   MAP_FIELD_TBL_TYPE,
   x_mapped_fields     OUT NOCOPY   MAP_FIELD_TBL_TYPE,
   x_map_obj_num       OUT NOCOPY  NUMBER,
   p_org_id		IN	NUMBER
   );


-- Start of comments
--    API name        : Create_Imp_Map
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
--                      p_imp_map       IN   imp_maps_rec_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--                      x_imp_map_id      OUT     NUMBER
--    Version :         Current version       1.0
--
--
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Create_Imp_Map
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_imp_map           IN     imp_maps_rec_type,
   x_imp_map_id        OUT NOCOPY    NUMBER
   );

-- Start of comments
--    API name        : Delete_Imp_map
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
--                      p_imp_map       IN   imp_maps_rec_type
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

PROCEDURE Delete_Imp_Map
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_imp_map              IN     imp_maps_rec_type
   );

END CN_IMP_MAPS_PVT;

 

/
