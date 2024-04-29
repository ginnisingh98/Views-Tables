--------------------------------------------------------
--  DDL for Package Body CN_IMP_HEADERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_IMP_HEADERS_PVT" AS
-- $Header: cnvimhrb.pls 115.7 2002/11/21 21:13:29 hlchen ship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'CN_IMP_HEADERS_PVT';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvimhrb.pls';

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
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Create_Imp_header';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_imp_header   imp_headers_rec_type;
      l_temp         NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Imp_header;
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
        FROM cn_imp_headers
        WHERE name = p_imp_header.name
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

   -- Call API to create cn_imp_headers
   l_imp_header := p_imp_header ;
   l_imp_header.status_code := 'NEW';

   SELECT cn_imp_headers_s.nextval
     INTO x_imp_header_id
     FROM sys.dual ;
   l_imp_header.imp_header_id := x_imp_header_id ;

   cn_imp_headers_pkg.insert_row
   (p_imp_headers_rec  => l_imp_header);

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
      ROLLBACK TO Create_Imp_header  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Imp_header ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Create_Imp_header ;
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
END Create_Imp_header;

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
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Update_Imp_header';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_imp_header   imp_headers_rec_type;
      l_temp         NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Imp_header;
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
   l_imp_header := p_imp_header ;

   -- Check Name uniqueness
   BEGIN
      SELECT 1
        INTO l_temp
        FROM cn_imp_headers
        WHERE imp_header_id <> p_imp_header.imp_header_id
	AND name = p_imp_header.name
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

   -- Check if record exists
   BEGIN
      SELECT imp_header_id,object_version_number
        INTO l_imp_header.imp_header_id, l_imp_header.object_version_number
        FROM cn_imp_headers
        WHERE imp_header_id = p_imp_header.imp_header_id
        FOR UPDATE OF imp_header_id NOWAIT ;
   EXCEPTION
      WHEN no_data_found THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
            FND_MESSAGE.SET_NAME ('CN','CN_REC_NOT_EXISTS');
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_ERROR ;
   END ;

   -- check locking mechanism
   IF p_imp_header.object_version_number >
              p_imp_header.object_version_number THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                  FND_MESSAGE.SET_NAME ('CN' , 'CN_RECORD_CHANGED');
                  FND_MSG_PUB.Add;
           END IF;
       RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Call API to update cn_imp_headers
   cn_imp_headers_pkg.update_row
   (p_imp_headers_rec  => l_imp_header);

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
      ROLLBACK TO Update_Imp_header  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Imp_header ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Update_Imp_header ;
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
END Update_Imp_header;

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
--                      p_map_obj_num             IN     NUMBER,
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
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Delete_Imp_header';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_imp_header   imp_headers_rec_type;
      l_temp         NUMBER;
      l_imp_map      cn_imp_maps_pvt.imp_maps_rec_type :=
	cn_imp_maps_pvt.G_MISS_IMP_MAPS_REC;

      CURSOR c_pro_audit_csr(c_imp_header_id NUMBER) IS
	 SELECT process_audit_id
	   FROM cn_process_audits
	   WHERE parent_process_audit_id = c_imp_header_id
	   ;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Imp_header;
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
   l_imp_header := p_imp_header ;
   -- Check if record exist
   BEGIN
      SELECT imp_header_id,status_code,object_version_number,imp_map_id
        INTO l_imp_header.imp_header_id,l_imp_header.status_code,
	l_imp_header.object_version_number,l_imp_header.imp_map_id
        FROM cn_imp_headers
        WHERE imp_header_id = p_imp_header.imp_header_id
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
   IF l_imp_header.object_version_number >
     p_imp_header.object_version_number THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_RECORD_CHANGED');
	 FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- delete imp_maps and imp_map_fields
   IF (l_imp_header.imp_map_id IS NOT NULL) THEN
      -- get imp_map info
      l_imp_map.imp_map_id := l_imp_header.imp_map_id;
      -- if p_map_obj_num = null, called for DELETE ALL, skip checking
      -- for object_version_number
      SELECT Decode(p_map_obj_num,NULL,object_version_number,p_map_obj_num)
	INTO l_imp_map.object_version_number
	FROM cn_imp_maps
	WHERE imp_map_id = l_imp_header.imp_map_id;
      -- check if mapping used by other imp_headers
      BEGIN
	 l_temp := 0;
	 SELECT COUNT(1) INTO l_temp
	   FROM cn_imp_headers
	   WHERE imp_map_id = l_imp_header.imp_map_id
	   AND imp_header_id <> l_imp_header.imp_header_id
	   ;
      EXCEPTION
	 WHEN no_data_found THEN
	    NULL;
      END;

      -- delete imp_map if not used by other imp_headers
      IF l_temp = 0 THEN
	 cn_imp_maps_pvt.Delete_Imp_Map
	   ( p_api_version    => 1.0,
	     x_return_status  => x_return_status,
	     x_msg_count      => x_msg_count,
	     x_msg_data       => x_msg_data,
	     p_imp_map        => l_imp_map);
	 IF x_return_status <> FND_API.g_ret_sts_success THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;
   END IF;

   -- delete imp_lines,process_audits, process_audit_liness
   BEGIN
      -- delete process_audits, process_audit_liness
      FOR l_pro_audit_csr IN c_pro_audit_csr(l_imp_header.imp_header_id) LOOP
	 cn_message_pkg.purge
	   (x_process_audit_id => l_pro_audit_csr.process_audit_id,
	    x_creation_date => NULL);
      END LOOP;

      -- delete imp_lines
      DELETE FROM cn_imp_lines
	WHERE imp_header_id = l_imp_header.imp_header_id;

   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
   END;

   -- Call API to delete cn_imp_headers
   cn_imp_headers_pkg.delete_row
   (p_imp_header_id  => l_imp_header.imp_header_id);

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
      ROLLBACK TO Delete_Imp_header  ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Imp_header ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE
           );

   WHEN OTHERS THEN
      ROLLBACK TO Delete_Imp_header ;
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
END Delete_Imp_header;

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
   ) IS

BEGIN

   x_errmsg := SUBSTR (SQLERRM(p_errcode) , 1 , 2000);

EXCEPTION
   WHEN OTHERS THEN
     x_errmsg := 'ORA' || p_errcode;

END Get_Oerr_Msg;


END CN_IMP_HEADERS_PVT;

/
