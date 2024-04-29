--------------------------------------------------------
--  DDL for Package Body CN_IMP_MAPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_IMP_MAPS_PVT" AS
-- $Header: cnvimmpb.pls 120.2 2005/08/07 23:03:33 vensrini noship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'CN_IMP_MAPS_PVT';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvimmpb.pls';

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
   p_source_fields     IN     map_field_tbl_type,
   p_target_fields     IN     v_Tbl_Type ,
   x_imp_map_id        OUT NOCOPY    NUMBER,
   p_org_id		IN	NUMBER
   ) IS


      l_api_name     CONSTANT VARCHAR2(30) := 'Create_Mapping';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_imp_map   imp_maps_rec_type;
      l_temp         NUMBER;
      l_target_fields v_tbl_type;
      l_imp_map_field   CN_IMP_MAP_FIELDS_PKG.imp_map_fields_rec_type;
      l_nullable cn_objects.nullable%TYPE := 'N';
      l_obj_type cn_objects.object_type%TYPE := 'COL';

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Mapping;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body
   -- ----------------------
   -- CREATE IMP_MAP
   -- ----------------------
   l_imp_map := p_imp_map;
   IF p_imp_map.imp_map_id IS NULL THEN
      -- create imp_map since not exist
      create_imp_map
        (p_api_version => 1.0,
         x_return_status =>  x_return_status,
         x_msg_count  =>   x_msg_count  ,
         x_msg_data  =>   x_msg_data   ,
         p_imp_map => p_imp_map,
	 x_imp_map_id => x_imp_map_id);
      l_imp_map.imp_map_id := x_imp_map_id;
      IF x_return_status <> FND_API.g_ret_sts_success THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      -- check locking mechanism
      BEGIN
	 SELECT imp_map_id,object_version_number
	   INTO l_imp_map.imp_map_id,
	   l_imp_map.object_version_number
	   FROM cn_imp_maps
	   WHERE imp_map_id = p_imp_map.imp_map_id
	   ;
      EXCEPTION
	 WHEN no_data_found THEN
	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN
	       FND_MESSAGE.SET_NAME ('CN','CN_REC_NOT_EXISTS');
	       FND_MSG_PUB.Add;
	    END IF;
	    RAISE FND_API.G_EXC_ERROR ;
      END;
      IF l_imp_map.object_version_number >
	p_imp_map.object_version_number THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_RECORD_CHANGED');
	    FND_MSG_PUB.Add;
	 END IF;
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;
      -- update cn_imp_maps object_version_number for new mapping
      UPDATE cn_imp_maps
	SET object_version_number = l_imp_map.object_version_number + 1
	WHERE imp_map_id = p_imp_map.imp_map_id
	;
      x_imp_map_id := p_imp_map.imp_map_id;
      -- delete map_fields of old mapping
      DELETE FROM cn_imp_map_fields
	WHERE imp_map_id = p_imp_map.imp_map_id;
   END IF;
   -- ----------------------
   -- CREATE MAPPING FIELDS
   -- ----------------------
   l_imp_map_field.imp_map_id := l_imp_map.imp_map_id;

   -- get target_table_id,target_table_name
   SELECT t.table_id,t.view_name
     INTO l_imp_map_field.target_table_id,l_imp_map_field.target_table_name
     FROM cn_imp_maps m, cn_import_types t
     WHERE m.imp_map_id = l_imp_map.imp_map_id
     AND m.import_type_code = t.import_type_code
     ;

   FOR i IN p_target_fields.first .. p_target_fields.last LOOP
      -- get imp_map_field_id
      SELECT cn_imp_map_fields_s.nextval
	INTO l_imp_map_field.imp_map_field_id
	FROM sys.dual ;

      -- get target_object_id
      SELECT object_id,name
	INTO l_imp_map_field.target_object_id,
	l_imp_map_field.target_column_name
	FROM cn_objects
	WHERE table_id = l_imp_map_field.target_table_id
	AND object_id = p_target_fields(i)
	AND object_type = 'COL' AND ORG_ID = p_org_id
	;
      -- get source_column_name
      l_imp_map_field.source_column := p_source_fields(i).value;
      -- BUG 2399467
      IF Length(p_source_fields(i).text) > 30 THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_IMP_MAP_HEADER_TOO_LARGE');
	     FND_MESSAGE.SET_TOKEN('COLUMN_HEADER',p_source_fields(i).text);
	    FND_MSG_PUB.Add;
	 END IF;
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;

      l_imp_map_field.source_user_column := p_source_fields(i).text;

      -- insert into cn_imp_map_fields
      cn_imp_map_fields_pkg.insert_row
	(p_imp_map_fields_rec  => l_imp_map_field);

   END LOOP;
   -- ----------------------
   -- CHECK REQUIRED FIELD
   -- ----------------------
   BEGIN
      l_temp := 0 ;
      SELECT COUNT(1)
	INTO l_temp
	FROM cn_objects o
	WHERE o.table_id = l_imp_map_field.target_table_id
	AND o.nullable = l_nullable
	AND object_type = l_obj_type
	AND o.name  NOT IN ('IMP_LINE_ID','LAST_UPDATE_DATE','LAST_UPDATED_BY','CREATION_DATE','CREATED_BY','LAST_UPDATE_LOGIN','OBJECT_VERSION_NUMBER','IMP_HEADER_ID','STATUS_CODE','ERROR_CODE','ERROR_MSG','RECORD_NUM','IMPORT_TYPE_CODE')
	AND NOT exists (SELECT  'X' FROM cn_imp_map_fields i
			WHERE i.imp_map_id = l_imp_map.imp_map_id
			AND i.target_object_id = o.object_id
			)
	AND o.ORG_ID = p_org_id
	;
      IF l_temp > 0 THEN
	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN','CN_IMP_REQFLD_NOT_MAP');
	    FND_MSG_PUB.Add;
	 END IF;
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;
   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
   END;

   -- update cn_imp_headers with this mapping imp_map_id
   UPDATE cn_imp_headers
     SET imp_map_id = l_imp_map.imp_map_id,
     source_column_num = p_src_column_num
     WHERE imp_header_id = p_imp_header_id
     ;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Mapping  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Mapping ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Create_Mapping ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
          END IF;
      FND_MSG_PUB.Count_And_Get
          (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
END Create_Mapping;


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
   x_target_fields     OUT NOCOPY   MAP_FIELD_TBL_TYPE ,
   x_mapped_fields     OUT NOCOPY   MAP_FIELD_TBL_TYPE ,
   x_map_obj_num       OUT NOCOPY  NUMBER,
   p_org_id		IN	NUMBER
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'retrieve_Fields';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_temp      NUMBER;
      l_table_id  NUMBER;
      l_index     NUMBER;

      CURSOR c_def_target_csr (c_table_id NUMBER) IS
	 SELECT object_id value,name colname,nullable,
	   Decode(Nvl(nullable,'Y'),'N','* ','') || user_name text
	   FROM cn_objects
	   WHERE table_id = c_table_id
	   AND object_type = 'COL'
	   AND name NOT IN ('IMP_LINE_ID','LAST_UPDATE_DATE','LAST_UPDATED_BY','CREATION_DATE','CREATED_BY','LAST_UPDATE_LOGIN','OBJECT_VERSION_NUMBER','IMP_HEADER_ID','STATUS_CODE','ERROR_CODE','ERROR_MSG','RECORD_NUM','IMPORT_TYPE_CODE')
	   AND ORG_ID = p_org_id
	   ORDER BY nullable,user_name
	   ;
      l_def_target_csr c_def_target_csr%ROWTYPE;

      CURSOR c_mapped_csr (c_imp_map_id NUMBER) IS
	 SELECT i.source_column || ' : ' || o.object_id m_value,
	   i.source_column || ' : ' || o.name m_colname,
	   i.source_user_column || ' : ' ||
	   Decode(Nvl(o.nullable,'Y'),'N','* ','') || o.user_name m_text,
	   i.source_user_column s_text, i.source_column s_value
	   FROM cn_imp_map_fields i, cn_objects o
	   WHERE i.imp_map_id = c_imp_map_id
	   AND i.target_object_id = o.object_id
	   AND o.ORG_ID = p_org_id
	   ;
      l_mapped_csr c_mapped_csr%ROWTYPE;

      CURSOR c_unmap_target_csr (c_table_id NUMBER,c_imp_map_id NUMBER) IS
 	 SELECT o.object_id value,o.name colname,o.nullable,
	   Decode(Nvl(o.nullable,'Y'),'N','* ','') || o.user_name text
	   FROM cn_objects o
	   WHERE o.table_id = c_table_id
	   AND o.object_type = 'COL'
	   AND o.name NOT IN ('IMP_LINE_ID','LAST_UPDATE_DATE','LAST_UPDATED_BY','CREATION_DATE','CREATED_BY','LAST_UPDATE_LOGIN','OBJECT_VERSION_NUMBER','IMP_HEADER_ID','STATUS_CODE','ERROR_CODE','ERROR_MSG','RECORD_NUM','IMPORT_TYPE_CODE')
	   AND NOT exists
	   (SELECT 'X' FROM cn_imp_map_fields i
	    WHERE i.imp_map_id = c_imp_map_id
	    AND i.target_object_id = o.object_id)
	    AND o.ORG_ID = p_org_id
	   ORDER BY o.nullable, o.user_name
	   ;
      l_unmap_target_csr c_unmap_target_csr%ROWTYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   retrieve_Fields;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body
   x_source_fields :=  G_MISS_MAP_FIELD_TBL;
   x_target_fields :=  G_MISS_MAP_FIELD_TBL;
   x_mapped_fields :=  G_MISS_MAP_FIELD_TBL;
   -- get table_id
   SELECT table_id INTO l_table_id
     FROM cn_import_types
     WHERE import_type_code = p_import_type_code
     ;

   -- if p_imp_map_id is null, get default source/target/mapped field
   IF p_imp_map_id IS NULL THEN
      -- get default target field
      l_index := 1 ;
      OPEN c_def_target_csr(l_table_id);
      LOOP
	 FETCH c_def_target_csr INTO l_def_target_csr;
	 EXIT WHEN c_def_target_csr%notfound;
	 x_target_fields(l_index).colname  := l_def_target_csr.colname;
	 x_target_fields(l_index).text  := l_def_target_csr.text;
	 x_target_fields(l_index).value  := l_def_target_csr.value;
	 l_index := l_index + 1;

      END LOOP;
      IF c_def_target_csr%ROWCOUNT = 0 THEN
	 x_target_fields :=  G_MISS_MAP_FIELD_TBL;
      END IF;
      CLOSE c_def_target_csr;
      -- get mapped fields
      x_mapped_fields := G_MISS_MAP_FIELD_TBL;
      -- get source fields
      x_source_fields := G_MISS_MAP_FIELD_TBL;
      -- get imp_map obj version number : used by impHeaderEO.delete()
      x_map_obj_num := 0;
    ELSE
      -- mapped existes, retrieved from db
      l_index := 1 ;
      OPEN c_unmap_target_csr(l_table_id,p_imp_map_id);
      LOOP
	 FETCH c_unmap_target_csr INTO l_unmap_target_csr;
	 EXIT WHEN c_unmap_target_csr%notfound;
	 x_target_fields(l_index).colname  := l_unmap_target_csr.colname;
	 x_target_fields(l_index).value  := l_unmap_target_csr.value;
	 x_target_fields(l_index).text  := l_unmap_target_csr.text;
	 l_index := l_index + 1;

      END LOOP;
      IF c_unmap_target_csr%ROWCOUNT = 0 THEN
	 x_target_fields :=  G_MISS_MAP_FIELD_TBL;
      END IF;
      CLOSE c_unmap_target_csr;
      -- get mapped fields
      l_index := 1 ;
      OPEN c_mapped_csr(p_imp_map_id);
      LOOP
	 FETCH c_mapped_csr INTO l_mapped_csr;
	 EXIT WHEN c_mapped_csr%notfound;
	 x_mapped_fields(l_index).colname  := l_mapped_csr.m_colname;
	 x_mapped_fields(l_index).text  := l_mapped_csr.m_text;
	 x_mapped_fields(l_index).value  := l_mapped_csr.m_value;
	 x_source_fields(l_index).text  := l_mapped_csr.s_text;
	 x_source_fields(l_index).value  := l_mapped_csr.s_value;
	 l_index := l_index + 1;

      END LOOP;
      IF c_mapped_csr%ROWCOUNT = 0 THEN
	 x_mapped_fields :=  G_MISS_MAP_FIELD_TBL;
	 x_source_fields := G_MISS_MAP_FIELD_TBL;
      END IF;
      CLOSE c_mapped_csr;
      -- get imp_map obj version number : used by impHeaderEO.delete()
      BEGIN
	 SELECT object_version_number INTO x_map_obj_num
	   FROM cn_imp_maps
	   WHERE imp_map_id = p_imp_map_id;
      EXCEPTION
	 WHEN no_data_found THEN
	    x_map_obj_num := 0 ;
      END;
   END IF;
   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO retrieve_Fields  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO retrieve_Fields ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO retrieve_Fields ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
          END IF;
      FND_MSG_PUB.Count_And_Get
          (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
END retrieve_Fields;


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
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Create_Imp_map';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_imp_map   imp_maps_rec_type;
      l_temp         NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Imp_map;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body
   -- Check Name uniqueness
   BEGIN
      SELECT 1
        INTO l_temp
        FROM cn_imp_maps
        WHERE name = p_imp_map.name
        ;
   EXCEPTION
      WHEN no_data_found THEN
        NULL;
   END;
   IF l_temp = 1 THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
            FND_MESSAGE.SET_NAME ('CN','CN_ALREADY_EXISTS');
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Call API to create cn_imp_maps
   l_imp_map := p_imp_map ;

   SELECT cn_imp_maps_s.nextval
     INTO x_imp_map_id
     FROM sys.dual ;
   l_imp_map.imp_map_id := x_imp_map_id ;

   cn_imp_maps_pkg.insert_row
   (p_imp_maps_rec  => l_imp_map);

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Imp_map  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Imp_map ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Create_Imp_map ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
          END IF;
      FND_MSG_PUB.Count_And_Get
          (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
END Create_Imp_map;


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
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Delete_Imp_map';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_imp_map   imp_maps_rec_type;
      l_temp         NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Imp_map;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   -- API body
   l_imp_map := p_imp_map ;
   -- Check if record exist
   BEGIN
      SELECT imp_map_id,object_version_number
        INTO l_imp_map.imp_map_id,
        l_imp_map.object_version_number
        FROM cn_imp_maps
        WHERE imp_map_id = p_imp_map.imp_map_id
        ;
   EXCEPTION
      WHEN no_data_found THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
              FND_MESSAGE.SET_NAME ('CN','CN_REC_NOT_EXISTS');
              FND_MSG_PUB.Add;
           END IF;
           RAISE FND_API.G_EXC_ERROR ;
   END;
   -- check locking mechanism
   IF l_imp_map.object_version_number >
     p_imp_map.object_version_number THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         FND_MESSAGE.SET_NAME ('CN' , 'CN_RECORD_CHANGED');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- delete imp_map_fields
   DELETE FROM cn_imp_map_fields
     WHERE imp_map_id = l_imp_map.imp_map_id;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Call API to delete cn_imp_maps
   cn_imp_maps_pkg.delete_row
   (p_imp_map_id  => l_imp_map.imp_map_id);
   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Imp_map  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Imp_map ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Delete_Imp_map ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
          END IF;
      FND_MSG_PUB.Count_And_Get
          (
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
END Delete_Imp_map;


END CN_IMP_MAPS_PVT;

/
