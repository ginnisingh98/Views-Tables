--------------------------------------------------------
--  DDL for Package CN_SYS_TABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SYS_TABLES_PVT" AUTHID CURRENT_USER AS
  --$Header: cnvsytbs.pls 120.2 2005/08/08 04:45:32 rramakri noship $

  TYPE table_rec_type IS RECORD (
    object_id          cn_objects.object_id%TYPE
    , name               cn_objects.name%TYPE
    , description        cn_objects.description%TYPE
    , status             cn_objects.object_status%TYPE
    , repository_id      cn_objects.repository_id%TYPE
    , alias              cn_objects.alias%TYPE
    , table_level        cn_objects.table_level%TYPE
    , table_type         cn_objects.table_level%TYPE
    , object_type        cn_objects.object_type%TYPE
    , schema             cn_objects.schema%TYPE
    , calc_eligible_flag cn_objects.calc_eligible_flag%TYPE
    , user_name          cn_objects.user_name%TYPE
    , org_id             cn_objects.org_id%TYPE
    , object_version_number             cn_objects.object_version_number%TYPE
    );

  TYPE column_rec_type IS RECORD (
    object_id          cn_objects.object_id%TYPE
    , user_name        cn_objects.user_name%TYPE
    , usage            cn_objects.calc_formula_flag%TYPE
    , foreign_key      cn_objects.foreign_key%TYPE
    , dimension_id     cn_objects.dimension_id%TYPE
    , user_column_name cn_objects.user_column_name%TYPE
    , classification_column cn_objects.classification_column%TYPE
    , column_datatype  cn_objects.column_datatype%TYPE
    , value_set_id     cn_objects.value_set_id%TYPE
    , primary_key      cn_objects.primary_key%TYPE
    , position         cn_objects.position%TYPE
    , custom_call    cn_objects.custom_call%TYPE
    , org_id             cn_objects.org_id%TYPE
    , object_version_number cn_objects.object_version_number%TYPE
    );

-- Start of comments
--    API name        : Create_Table
--    Type            : Private.
--    Function        : Create the information for the table in cn_objects
--                      Also create the columns associated with the table
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_table_rec           IN table_rec_type Required
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count                     OUT     NUMBER
--                      x_msg_data                      OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                            Changed....
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Create_Table
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level            IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                            ,
  p_table_rec                   IN  OUT NOCOPY    table_rec_type        ,
  x_return_status               OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                   OUT NOCOPY     NUMBER                          ,
  x_msg_data                    OUT NOCOPY     VARCHAR2                        );

-- Start of comments
--      API name        : Update_Table
--      Type            : Private.
--      Function        : Update table information
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_old_table_rec     IN table_rec_type Required
--                        p_new_table_rec     IN table_rec_type Required
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version       1.0
--                        Initial version       1.0
--
--      Notes           : Note text
--
-- End of comments
PROCEDURE Update_Table
  (p_api_version                  IN      NUMBER                          ,
   p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level              IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                              ,
  p_table_rec                     IN  OUT NOCOPY    table_rec_type                  ,
  x_return_status                 OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                     OUT NOCOPY     NUMBER                          ,
  x_msg_data                      OUT NOCOPY     VARCHAR2                        );

-- Start of comments
--      API name        : Delete_Table
--      Type            : Private.
--      Function        : Delete table information
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_table_rec         IN table_rec_type Required
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version       1.0
--                        Initial version       1.0
--
--      Notes           : Note text
--
-- End of comments


PROCEDURE Delete_Table
  (p_api_version                  IN      NUMBER                          ,
   p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level              IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                              ,
  p_table_rec                     IN      table_rec_type                  ,
  x_return_status                 OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                     OUT NOCOPY     NUMBER                          ,
  x_msg_data                      OUT NOCOPY     VARCHAR2                        );

-- Start of comments
--    API name        : Update_Column
--    Type            : Private.
--    Function        : Update column information
--
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_column_rec          IN column_rec_type Required
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                            Changed....
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments

PROCEDURE Update_Column
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level            IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                            ,
  p_column_rec                  IN      column_rec_type                 ,
  x_return_status               OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                   OUT NOCOPY     NUMBER                          ,
  x_msg_data                    OUT NOCOPY     VARCHAR2                        );

-- Start of comments
--    API name        : Insert_Column
--    Type            : Private.
--    Function        : Insert column information
--
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_column_rec          IN column_rec_type Required
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                            Changed....
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments

PROCEDURE Insert_Column
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level            IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                            ,
  p_schema_name                 IN      varchar2                        ,
  p_table_name                  IN      varchar2                        ,
  p_column_name                 IN      varchar2                        ,
  p_column_rec                  IN      column_rec_type                 ,
  x_return_status               OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                   OUT NOCOPY     NUMBER                          ,
  x_msg_data                    OUT NOCOPY     VARCHAR2                        );

-- Start of comments
--    API name        : Delete_Column
--    Type            : Private.
--    Function        : Delete column information
--
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_column_id           IN NUMBER       Required
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                            Changed....
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments


PROCEDURE Delete_Column
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level            IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                            ,
  p_column_id                   IN      number                          ,
  x_return_status               OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                   OUT NOCOPY     NUMBER                          ,
  x_msg_data                    OUT NOCOPY     VARCHAR2                        );

END CN_SYS_TABLES_PVT;

 

/
