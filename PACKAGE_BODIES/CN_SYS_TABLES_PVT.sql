--------------------------------------------------------
--  DDL for Package Body CN_SYS_TABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SYS_TABLES_PVT" AS
  --$Header: cnvsytbb.pls 120.2.12010000.2 2009/02/23 22:18:07 rnagired ship $
--Changed g_pkg_name to cn_sys_tables_pvt
G_PKG_NAME         CONSTANT VARCHAR2(30):='CN_SYS_TABLES_PVT';

--{{{ check_table_rec
procedure check_table_rec(p_table_rec  IN  table_rec_type,
                          p_operation  IN  varchar2) IS
   CURSOR l_schema_csr IS
     SELECT username
       FROM all_users
       WHERE username NOT IN
       ('SYS','SYSTEM', 'APPLSYS', 'APPLSYSPUB', 'APPS_READ_ONLY')
       AND username = p_table_rec.schema;

    CURSOR l_table_csr IS
       SELECT object_name
         FROM all_objects
         WHERE owner = p_table_rec.schema
         AND object_type IN ('TABLE','VIEW')
         AND object_name NOT IN
         ( select name from cn_obj_tables_v
          where  org_id=p_table_rec.org_id)
         and object_name = p_table_rec.name;

       l_schema varchar2(30);
       l_table  varchar2(30);
BEGIN

   IF (p_operation = 'INSERT') THEN
      OPEN l_schema_csr;
      FETCH l_schema_csr INTO l_schema;
      CLOSE l_schema_csr;

      IF (l_schema is null) THEN
         fnd_message.set_name('CN', 'CN_TBL_NO_SUCH_SCH');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;


      OPEN l_table_csr;
      FETCH l_table_csr INTO l_table;
      CLOSE l_table_csr;

      IF (l_table is null) THEN
         fnd_message.set_name('CN', 'CN_TBL_NO_SUCH_TBL');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

   IF (p_table_rec.calc_eligible_flag <> 'Y' AND
     p_table_rec.calc_eligible_flag <> 'C' AND
     p_table_rec.calc_eligible_flag <> 'N') THEN
      fnd_message.set_name('CN', 'CN_TBL_INC_CALC_FLAG');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;
END check_table_rec;
--}}}

--{{{ Create_Table
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
  p_table_rec                   IN  OUT NOCOPY    table_rec_type                  ,
  x_return_status               OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                   OUT NOCOPY     NUMBER                          ,
  x_msg_data                    OUT NOCOPY     VARCHAR2                        ) IS
   l_api_name                      CONSTANT VARCHAR2(30)
     := 'Create_Table';
   l_api_version                   CONSTANT NUMBER                 := 1.0;

   l_repository_id  number := 0;
   l_alias          varchar2(80);
   l_count          number := 0;
   l_object_id      number := 0;

   G_LAST_UPDATE_DATE          DATE := Sysdate;
   G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
   G_CREATION_DATE             DATE := Sysdate;
   G_CREATED_BY                NUMBER := fnd_global.user_id;
   G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;

   CURSOR l_repository_csr IS
     SELECT repository_id
       FROM cn_repositories
       WHERE repository_id > 0
       AND org_id=p_table_rec.org_id
       AND application_type = 'CN';

   l_loading_status  varchar2(80);
   l_table_rec   cn_cnsytc_tables_pvt.table_rec_type;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   create_table_pvt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body
   OPEN l_repository_csr;
   FETCH l_repository_csr INTO l_repository_id;
   CLOSE l_repository_csr;

   check_table_rec(p_table_rec, 'INSERT');

   if (p_table_rec.name is not null) then
      l_alias := substr(p_table_rec.name, 1, 1);
      l_count := instr(p_table_rec.name, '_', 1, 1);

      while (l_count > 0) loop
         l_alias := l_alias || substr(p_table_rec.name, l_count + 1, 1);
         l_count := instr(p_table_rec.name, '_', l_count + 1, 1);
      end loop;

      select cn_objects_s1.nextval
        into l_count
        from dual;

      l_alias := l_alias || l_count;
   end if;

   SELECT nvl(p_table_rec.object_id,cn_objects_s.nextval)
     INTO l_object_id
     FROM dual;

   l_table_rec.object_id          := l_object_id                   ;
   l_table_rec.name               := p_table_rec.name              ;
   l_table_rec.description        := p_table_rec.description       ;
   l_table_rec.status             := 'A'                           ;
   l_table_rec.repository_id      := l_repository_id     ;
   l_table_rec.alias              := l_alias                       ;
   l_table_rec.table_level        := NULL                          ;
   l_table_rec.table_type         := 'T'                           ;
   l_table_rec.object_type        := 'TBL'                         ;
   l_table_rec.schema             := p_table_rec.schema            ;
   l_table_rec.calc_eligible_flag := p_table_rec.calc_eligible_flag;
   l_table_rec.user_name          := p_table_rec.user_name         ;
   l_table_rec.object_version_number := p_table_rec.object_version_number ;
   l_table_rec.org_id := p_table_rec.org_id ;

   p_table_rec.alias:=l_alias;
   cn_cnsytc_tables_pvt.create_tables
     ( x_return_status    => x_return_status
     , x_msg_count        => x_msg_count
     , x_msg_data         => x_msg_data
     , x_loading_status   => l_loading_status
     , p_api_version      => l_api_version
     , p_init_msg_list    => p_init_msg_list
     , p_commit           => p_commit
     , p_validation_level => p_validation_level
     , p_table_rec        => l_table_rec);

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_table_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_table_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO create_table_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Create_Table;
--}}}

--{{{ Update_Table
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


 PROCEDURE Update_Table
  (p_api_version                  IN      NUMBER                          ,
   p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level              IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                              ,
  p_table_rec                     IN   OUT NOCOPY   table_rec_type                  ,
  x_return_status                 OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                     OUT NOCOPY     NUMBER                          ,
  x_msg_data                      OUT NOCOPY     VARCHAR2                        ) IS
   l_api_name                      CONSTANT VARCHAR2(30)
     := 'Update_Table';
   l_api_version                   CONSTANT NUMBER                 := 1.0;
   l_row  cn_obj_tables_v%ROWTYPE;
   l_repository_id  number;

   G_LAST_UPDATE_DATE          DATE := Sysdate;
   G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
   G_CREATION_DATE             DATE := Sysdate;
   G_CREATED_BY                NUMBER := fnd_global.user_id;
   G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;

   CURSOR l_old_row_csr IS
     SELECT *
       FROM cn_obj_tables_v
       WHERE table_id = p_table_rec.object_id
       and org_id=p_table_rec.ORG_ID;

   CURSOR l_repository_csr IS
     SELECT repository_id
       FROM cn_repositories
       WHERE repository_id > 0
       and org_id=p_table_rec.ORG_ID
       AND application_type = 'CN';
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   update_table_pvt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body
   /* seeded tables can be updated
   if (p_table_rec.object_id < 0) then
      fnd_message.set_name('CN', 'CN_SD_TBL_NO_UPD');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   end if;
   */



   OPEN l_old_row_csr;
   FETCH l_old_row_csr INTO l_row;
   CLOSE l_old_row_csr;

   check_table_rec(p_table_rec, 'UPDATE');

   if (l_row.schema <> p_table_rec.schema OR
     l_row.name <> p_table_rec.name OR
     l_row.ALIAS <> p_table_rec.ALIAS) then
      fnd_message.set_name('CN', 'CN_TBL_ATTR_NO_UPD');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   end if;

   OPEN l_repository_csr;
   FETCH l_repository_csr INTO l_repository_id;
   CLOSE l_repository_csr;

   cn_obj_tables_pkg.begin_record(
     P_OPERATION                   => 'UPDATE'
     , P_OBJECT_ID                 => p_table_rec.object_id
     , P_NAME                      => l_row.name
     , P_DESCRIPTION               => p_table_rec.description
     , P_DEPENDENCY_MAP_COMPLETE   => 'N'
     , P_STATUS                    => 'A'
     , P_REPOSITORY_ID             => l_repository_id
     , P_ALIAS                     => l_row.alias
     , P_TABLE_LEVEL               => NULL
     , P_TABLE_TYPE                => 'T'
     , P_OBJECT_TYPE               => 'TBL'
     , P_SCHEMA                    => l_row.schema
     , P_CALC_ELIGIBLE_FLAG        => p_table_rec.calc_eligible_flag
     , P_USER_NAME                 => p_table_rec.user_name
     , p_data_length               => NULL
     , p_data_type                 => NULL
     , p_calc_formula_flag         => NULL
     , p_table_id                  => NULL
     , p_column_datatype           => NULL
     , x_object_version_number     =>p_table_rec.object_version_number
     , p_org_id                    =>p_table_rec.ORG_ID
     );


   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_table_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_table_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO update_table_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Update_Table;
--}}}




--{{{ Delete_Table
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
  x_msg_data                      OUT NOCOPY     VARCHAR2                        ) IS
      l_api_name                      CONSTANT VARCHAR2(30)
     := 'Delete_Table';
   l_api_version                   CONSTANT NUMBER                 := 1.0;
   G_LAST_UPDATE_DATE          DATE := Sysdate;
   G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
   G_CREATION_DATE             DATE := Sysdate;
   G_CREATED_BY                NUMBER := fnd_global.user_id;
   G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;

  -- By Hithanki For Bug Fix : 2698989
  -------
   l_dest_count		       NUMBER := 0;
   l_sorc_count		       NUMBER := 0;
  -------

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   delete_table_pvt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body
   if (p_table_rec.object_id < 0) then
      fnd_message.set_name('CN', 'CN_SD_TBL_NO_DEL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   end if;

  -- By Hithanki For Bug Fix : 2698989
  -------
   --
   -- Check IF Table is used as a Part Of Transaction Source.
   --
   SELECT 	COUNT(*)
   INTO 	l_dest_count
   FROM		cn_table_maps_all
   WHERE	source_table_id = p_table_rec.object_id
   and org_id=p_table_rec.org_id;

   SELECT 	COUNT(*)
   INTO 	l_sorc_count
   FROM		cn_table_maps_all
   WHERE	destination_table_id = p_table_rec.object_id
   and org_id=p_table_rec.org_id;
   --
   -- IF Yes, Do Not Allow User To Delete That Table
   --
   IF 	( l_dest_count > 0 OR l_sorc_count > 0 )
   THEN	fnd_message.set_name('CN','CN_TBL_MAP_EXIST');
   	fnd_msg_pub.ADD;
   	RAISE fnd_api.g_exc_error;
   END IF;
   -------

   --no table handler exists
   --add delete table handler later

   --first delete all columns
   DELETE FROM cn_obj_columns_v
     WHERE table_id = p_table_rec.object_id;

   --then delete the table itself
   DELETE FROM cn_obj_tables_v
     WHERE table_id = p_table_rec.object_id;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO delete_table_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO delete_table_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO delete_table_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Delete_Table;
--}}}




--{{{ Update_Column
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
  x_msg_data                    OUT NOCOPY     VARCHAR2                        ) IS
   l_api_name                      CONSTANT VARCHAR2(30)
     := 'Update_Column';
   l_api_version                   CONSTANT NUMBER                 := 1.0;

   l_dimension_id  number := 0;
   l_table_id  number := 0;
   l_table_name  varchar2(30);
   l_dim_value_ctr  number := 0;

   G_LAST_UPDATE_DATE          DATE := Sysdate;
   G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
   G_CREATION_DATE             DATE := Sysdate;
   G_CREATED_BY                NUMBER := fnd_global.user_id;
   G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;

   CURSOR l_table_csr IS
     SELECT cotv.table_id, cotv.name
       FROM cn_obj_columns_v cocv, cn_obj_tables_v cotv
       WHERE cocv.column_id= p_column_rec.object_id
       AND cocv.table_id = cotv.table_id
       AND cocv.org_id=p_column_rec.org_id AND
       cocv.org_id=cotv.org_id;

   CURSOR l_dim_value_csr IS
     SELECT count(user_column_name)
       FROM cn_obj_columns_v
       WHERE table_id = l_table_id
       AND user_column_name = 'Y'
       AND org_id=p_column_rec.org_id
       AND column_id <> p_column_rec.object_id;

   CURSOR l_dim_csr IS
     SELECT d.dimension_id
       FROM cn_dimensions d, cn_dimension_tables_v dt
       WHERE d.dimension_id = dt.dimension_id
       AND org_id=p_column_rec.org_id
       AND upper(dt.table_name) = l_table_name;

   CURSOR l_rule_csr( p_object_id NUMBER)   IS
   SELECT distinct ruleset_id
    FROM cn_attribute_rules
   WHERE column_id = p_object_id
     AND org_id=p_column_rec.org_id
     and dimension_hierarchy_id is null;

   CURSOR l_col_csr ( p_object_id number )   IS
   SELECT object_id, column_datatype,org_id
      FROM cn_objects
     WHERE object_id = p_object_id
       AND org_id=p_column_rec.org_id
       AND table_id = -11803;

   l_col_rec  l_col_csr%ROWTYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   update_column_pvt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body
   -- first check if both pk and fk are Y
   if (p_column_rec.primary_key = 'Y' and p_column_rec.foreign_key = 'Y') then
      fnd_message.set_name('CN', 'CN_TBL_PK_FK_ERR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   end if;

   --next check if dim is correct
   OPEN l_table_csr;
   FETCH l_table_csr INTO l_table_id, l_table_name;
   CLOSE l_table_csr;

   if (p_column_rec.primary_key = 'Y' and
     p_column_rec.dimension_id is not null) THEN
      OPEN l_dim_csr;
      FETCH l_dim_csr INTO l_dimension_id;
      CLOSE l_dim_csr;

      if (l_dimension_id = 0 OR
        l_dimension_id <> p_column_rec.dimension_id) then
         fnd_message.set_name('CN', 'DIM_PK_ALERT');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      end if;
   end if;

   /* Not Enforced ???
   if (p_column_rec.foreign_key = 'Y' and
     p_column_rec.dimension_id is null) then
      fnd_message.set_name('CN', 'CN_TBL_DIM_FK_ERR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   end if;
   */


   OPEN l_dim_value_csr;
   FETCH l_dim_value_csr INTO l_dim_value_ctr;
   CLOSE l_dim_value_csr;

   if (l_dim_value_ctr = 1 AND p_column_rec.user_column_name = 'Y') then
      fnd_message.set_name('CN', 'CN_TBL_DIM_VAL_ERR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   end if;

   --
   --  Added by Kumar Sivasankaran
   --  Date: 02/14/2002
   open  l_col_csr(  p_column_rec.object_id );
   fetch l_col_csr into l_col_rec;
   close l_col_csr;

   if l_col_rec.column_datatype <>  p_column_rec.column_datatype and
      l_col_rec.object_id  IS NOT NULL and
      p_column_rec.column_datatype <> 'ALPN' THEN

      FOR rec IN l_rule_csr( p_column_rec.object_id)  LOOP

         cn_syin_rules_pkg.unsync_ruleset(rec.ruleset_id,p_column_rec.org_id);

      END LOOP;

   end if;


   -- we are ok now proceed with update.
   UPDATE cn_obj_columns_v
     SET calc_formula_flag = p_column_rec.usage,
     user_name = p_column_rec.user_name,
     foreign_key = p_column_rec.foreign_key,
     dimension_id = p_column_rec.dimension_id,
     user_column_name = p_column_rec.user_column_name,
     classification_column = p_column_rec.classification_column,
     column_datatype = p_column_rec.column_datatype,
     value_set_id = p_column_rec.value_set_id,
     primary_key = p_column_rec.primary_key,
     position = p_column_rec.position,
     custom_call = p_column_rec.custom_call
     WHERE column_id = p_column_rec.object_id
     AND org_id=p_column_rec.org_id;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_column_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_column_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO update_column_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Update_Column;
--}}}





--{{{ Insert_Column
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
  x_msg_data                    OUT NOCOPY     VARCHAR2                        ) IS
   l_api_name                      CONSTANT VARCHAR2(30)
     := 'Insert_Column';
   l_api_version                   CONSTANT NUMBER                 := 1.0;

   G_LAST_UPDATE_DATE          DATE := Sysdate;
   G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
   G_CREATION_DATE             DATE := Sysdate;
   G_CREATED_BY                NUMBER := fnd_global.user_id;
   G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;

   l_table_id  number := 0;
   l_col_count  number := 0;
   l_data_type       VARCHAR2(9);
   l_data_len        NUMBER(15);
   l_column_data_type  VARCHAR2(30);
   l_table_rec  cn_objects%ROWTYPE;
   l_column_id  number;
   l_object_version_number number;

   l_return_status  varchar2(1);
   l_msg_count  number;
   l_msg_data  varchar2(2000);

   CURSOR l_tbl_csr IS
     SELECT *
       FROM cn_objects
       WHERE name = p_table_name
       AND schema = p_schema_name
       AND org_id=p_column_rec.org_id
       AND object_type = 'TBL';

   CURSOR l_valid_col_csr(p_table_id number) IS
     SELECT count(*)
       FROM all_tab_columns
       WHERE owner = p_schema_name
       AND table_name = p_table_name
       AND column_name = p_column_name
       AND NOT EXISTS
       (SELECT name
       FROM cn_objects
       WHERE table_id = p_table_id
       AND name = p_column_name
       AND org_id=p_column_rec.org_id
       AND object_type = 'COL');

   CURSOR l_col_data_csr  IS
     SELECT  data_type, data_length
       FROM  all_tab_columns
       WHERE owner = p_schema_name
       AND table_name  = p_table_name
       AND column_name = p_column_name
       AND data_type IN
       ('CHAR','NCHAR','VARCHAR2','VARCHAR','NVARCHAR2','LONG','NUMBER','DATE');

BEGIN
   -- Standard Start of API savepoint
   l_object_version_number:=1;
   SAVEPOINT   insert_column_pvt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body
   --first get the table data so that we can use it FOR comparison/insert later
   OPEN l_tbl_csr;
   FETCH l_tbl_csr INTO l_table_rec;
   CLOSE l_tbl_csr;

   --check IF the column is a valid column FOR the given table
   --and IF it already exists
   OPEN l_valid_col_csr(l_table_rec.object_id);
   FETCH l_valid_col_csr INTO l_col_count;
   CLOSE l_valid_col_csr;

   IF (l_col_count = 0) THEN
      fnd_message.set_name('CN', 'CN_TBL_NO_SUCH_DUP_COL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   OPEN l_col_data_csr;
   FETCH l_col_data_csr INTO l_data_type, l_data_len;

   --+
   -- Set Column_Datatype to what ever is the data type of
   -- the native column
   --+
   IF l_data_type = 'NUMBER' THEN
      l_column_data_type := 'NUMB';
   ELSIF l_data_type = 'DATE' THEN
      l_column_data_type := 'DATE';
   ELSE
      l_column_data_type := 'ALPN';
   END IF;

   SELECT cn_objects_s.nextval
     INTO l_column_id
     FROM dual;

   cn_obj_tables_pkg.begin_record(
     P_OPERATION                 => 'INSERT',
     P_OBJECT_ID                 => l_column_id,
     P_NAME                      => p_column_name,
     P_DESCRIPTION               => l_table_rec.description,
     P_DEPENDENCY_MAP_COMPLETE   => 'N',
     P_STATUS                    => 'A',
     P_REPOSITORY_ID             => l_table_rec.repository_id,
     P_ALIAS                     => l_table_rec.ALIAS,
     P_TABLE_LEVEL               => NULL,
     P_TABLE_TYPE                => NULL,
     P_OBJECT_TYPE               => 'COL',
     P_SCHEMA                    => l_table_rec.schema,
     P_CALC_ELIGIBLE_FLAG        => l_table_rec.calc_eligible_flag,
     P_USER_NAME                 => p_column_name,
     p_data_type                 => l_data_type,
     p_data_length               => l_data_len,
     p_calc_formula_flag         => 'N',
     p_table_id                  => l_table_rec.object_id,
     p_column_datatype           => l_column_data_type,
     x_object_version_number     => l_object_version_number,
     p_org_id                      => p_column_rec.org_id);

   --after we insert the essential data we will call update to ensure that
   --the rest of the column data is correct and IF yes, perform an update
   update_column
     (p_api_version  => 1.0,
     p_init_msg_list  => FND_API.G_FALSE,
     p_commit => FND_API.G_FALSE,
     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
     p_column_rec => insert_column.p_column_rec,
     x_return_status => l_return_status,
     x_msg_count => l_msg_count,
     x_msg_data => l_msg_data);

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   CLOSE l_col_data_csr;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO insert_column_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO insert_column_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO insert_column_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Insert_Column;
--}}}




--{{{ Delete_Column

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

PROCEDURE Delete_Column
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level            IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                            ,
  p_column_id                   IN      number                          ,
  x_return_status               OUT NOCOPY     VARCHAR2                        ,
  x_msg_count                   OUT NOCOPY     NUMBER                          ,
  x_msg_data                    OUT NOCOPY     VARCHAR2                        ) IS
   l_api_name                      CONSTANT VARCHAR2(30)
     := 'Delete_Column';
   l_api_version                   CONSTANT NUMBER                 := 1.0;

   l_table_id  number := 0;

   G_LAST_UPDATE_DATE          DATE := Sysdate;
   G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
   G_CREATION_DATE             DATE := Sysdate;
   G_CREATED_BY                NUMBER := fnd_global.user_id;
   G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;

   CURSOR l_delete_csr ( p_column_id number )   IS
     SELECT table_id
       FROM cn_obj_columns_v
       WHERE column_id = p_column_id
       AND object_type = 'COL';

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   delete_column_pvt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
     (l_api_version           ,
     p_api_version           ,
     l_api_name              ,
     G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body
   open  l_delete_csr(  p_column_id );
   fetch l_delete_csr into l_table_id;
   close l_delete_csr;

   if (l_table_id < 0) then
      fnd_message.set_name('CN', 'CN_SD_TBL_COL_NO_DEL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   end if;

   DELETE FROM cn_obj_columns_v
     WHERE column_id = p_column_id
     AND object_type = 'COL';

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
     p_data                   =>      x_msg_data              ,
     p_encoded                =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO delete_column_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO delete_column_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO delete_column_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF      FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME          ,
          l_api_name           );
     END IF;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
END Delete_Column;

--}}}
END CN_SYS_TABLES_PVT;

/
