--------------------------------------------------------
--  DDL for Package Body CN_DIM_HIERARCHIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_DIM_HIERARCHIES_PVT" AS
-- $Header: cnvdimhb.pls 120.7 2006/09/18 22:59:36 jxsingh noship $

G_PKG_NAME                 CONSTANT VARCHAR2(30):= 'CN_DIM_HIERARCHIES_PVT';

-- Create a new hierarchy type
PROCEDURE Create_Hierarchy_Type
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_DIMENSIONS.NAME%TYPE,
   p_base_table_id              IN      CN_OBJ_TABLES_V.TABLE_ID%TYPE,
   p_primary_key_id             IN      CN_OBJ_COLUMNS_V.COLUMN_ID%TYPE,
   p_user_column_id             IN      CN_OBJ_COLUMNS_V.COLUMN_ID%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		CN_DIMENSIONS.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   p_description                IN      CN_DIMENSIONS.DESCRIPTION%TYPE, -- Added for R12
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_dimension_id               OUT NOCOPY     CN_DIMENSIONS.DIMENSION_ID%TYPE) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Create_Hierarchy_Type';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_rowid                   ROWID;
   l_count                   NUMBER;
   l_count_tl                NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Hierarchy_Type;
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
   -- call the original forms API (CNDIHY.fmb -> CNDIHY2s/b.pls)

   -- validate name is unique
   select count(1) into l_count from cn_dimensions where name = p_name and org_id = p_org_id; --R12 MOAC change
   if l_count > 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_NAME_NOT_UNIQUE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   select count(1) into l_count_tl
     from cn_dimensions_all_tl T, fnd_languages L
   where name = p_name
      and org_id = p_org_id
      and T.language = L.language_code
      and L.INSTALLED_FLAG in ('I', 'B');

   if l_count_tl > 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_NAME_NOT_UNIQUE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- get dimension ID
   x_dimension_id := CN_DIMENSIONS_PKG.New_Dimension;
   cn_dimensions_pkg.insert_row
     (
      X_DIMENSION_ID      => x_dimension_id,
      X_DESCRIPTION       => p_description,-- Added for R12
      X_SOURCE_TABLE_ID   => p_base_table_id,
      X_NAME              => p_name,
      X_CREATION_DATE     => sysdate,
      X_CREATED_BY        => fnd_global.user_id,
      X_LAST_UPDATE_DATE  => sysdate,
      X_LAST_UPDATED_BY   => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN => fnd_global.login_id,
      --R12 MOAC Changes--Start
      X_ORG_ID => p_org_id);
	--R12 MOAC Changes--End

   CN_DIHY_TWO_API_PKG.Insert_Dimension
     (x_dimension_id,
      p_name,
      p_base_table_id,
      p_primary_key_id,
      p_user_column_id,
      --R12 MOAC Changes--Start
      p_org_id);
      --R12 MOAC Changes--End

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Hierarchy_Type;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Hierarchy_Type;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Hierarchy_Type;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.add_exc_msg
           (G_PKG_NAME          ,
            l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
END Create_Hierarchy_Type;

-- Update hierarchy type (only name is updateable)
PROCEDURE Update_Hierarchy_Type
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dimension_id               IN      CN_DIMENSIONS.DIMENSION_ID%TYPE,
   p_name                       IN      CN_DIMENSIONS.NAME%TYPE,
   p_object_version_number      IN  OUT NOCOPY  CN_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		 CN_DIMENSIONS.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   p_description                IN      CN_DIMENSIONS.DESCRIPTION%TYPE, -- Added for R12
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Update_Hierarchy_Type';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_count                   NUMBER;

   cursor c is
   select source_table_id, object_version_number from cn_dimensions
    where dimension_id = p_dimension_id
		and org_id = p_org_id;         --R12 MOAC changes

   tlinfo c%rowtype ;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Hierarchy_Type;
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
   -- call the original forms API (CNDIHY.fmb -> CNDIHY2s/b.pls)
      -- START LOCK ROW --
   open  c;
   fetch c into tlinfo;
   if (c%notfound) then
      close c;
      fnd_message.set_name('CN', 'CN_RECORD_DELETED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
   end if;
   close c;

   -- validate name is unique
   select count(1) into l_count from cn_dimensions
    where name = p_name and dimension_id <> p_dimension_id and org_id = p_org_id;  --R12 MOAC changes
   if l_count > 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_NAME_NOT_UNIQUE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- we cannot update the base table... fetch existing source_table_id
   -- also do OBJECT_VERSION_NUMBER checking



   if (tlinfo.object_version_number <> p_object_version_number) then
      fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
   end if;
   -- END LOCK ROW --

   cn_dimensions_pkg.update_row
     (X_DIMENSION_ID      => p_dimension_id,
      X_DESCRIPTION       => p_description, --Added for R12
      X_SOURCE_TABLE_ID   => tlinfo.source_table_id,
      X_NAME              => p_name,
      X_LAST_UPDATE_DATE  => sysdate,
      X_LAST_UPDATED_BY   => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN => fnd_global.login_id,
      --R12 MOAC Changes--Star
      X_ORG_ID => p_org_id,
      X_OBJECT_VERSION_NUMBER => p_object_version_number);
      --R12 MOAC Changes--End



   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Hierarchy_Type;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Hierarchy_Type;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Hierarchy_Type;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.add_exc_msg
           (G_PKG_NAME          ,
            l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
END Update_Hierarchy_Type;

-- Delete hierarchy type
PROCEDURE Delete_Hierarchy_Type
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dimension_id               IN      CN_DIMENSIONS.DIMENSION_ID%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		 CN_DIMENSIONS.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Delete_Hierarchy_Type';
   l_api_version             CONSTANT NUMBER       := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Hierarchy_Type;
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
   -- call the original forms API (CNDIHY.fmb -> CNDIHY2s/b.pls)
   cn_dimensions_pkg.delete_row
     (X_DIMENSION_ID => p_dimension_id,
     --R12 MOAC Changes--Start
	X_ORG_ID => p_org_id);
	--R12 MOAC Changes--End

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Hierarchy_Type;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Hierarchy_Type;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Hierarchy_Type;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.add_exc_msg
           (G_PKG_NAME          ,
            l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
END Delete_Hierarchy_Type;

-- Create head hierarchy
PROCEDURE Create_Head_Hierarchy
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dimension_id               IN      CN_HEAD_HIERARCHIES.DIMENSION_ID%TYPE,
   p_name                       IN      CN_HEAD_HIERARCHIES.NAME%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		 CN_HEAD_HIERARCHIES.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_head_hierarchy_id          OUT NOCOPY     CN_HEAD_HIERARCHIES.HEAD_HIERARCHY_ID%TYPE) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Create_Head_Hierarchy';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_rowid                   ROWID;
   l_count                   NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Head_Hierarchy;
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

   -- validate name is unique
   select count(1) into l_count from cn_head_hierarchies
    where name = p_name and dimension_id = p_dimension_id
    --R12 MOAC Changes--Start
    and org_id = p_org_id ;
    --R12 MOAC Changes--End

   if l_count > 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_NAME_NOT_UNIQUE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   -- call the original forms API (CNDIHY.fmb -> CNDIHY2s/b.pls)
   x_head_hierarchy_id := CN_HEAD_HIERARCHIES_ALL_PKG.Default_Header;
   cn_head_hierarchies_all_pkg.insert_row
     (X_ROWID               => l_rowid,
      X_HEAD_HIERARCHY_ID   => x_head_hierarchy_id,
      X_DIMENSION_ID        => p_dimension_id,
      X_DESCRIPTION         => NULL, -- description not used
      X_NAME                => p_name,
      X_CREATION_DATE       => sysdate,
      X_CREATED_BY          => fnd_global.user_id,
      X_LAST_UPDATE_DATE    => sysdate,
      X_LAST_UPDATED_BY     => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN   => fnd_global.login_id,
      --R12 MOAC Changes--Start
      X_ORG_ID => p_org_id);
       --R12 MOAC Changes--End

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Head_Hierarchy;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Head_Hierarchy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Head_Hierarchy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.add_exc_msg
           (G_PKG_NAME          ,
            l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
END Create_Head_Hierarchy;

-- Update head hierarchy (only name is updateable)
PROCEDURE Update_Head_Hierarchy
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_head_hierarchy_id          IN      CN_HEAD_HIERARCHIES.HEAD_HIERARCHY_ID%TYPE,
   p_name                       IN      CN_HEAD_HIERARCHIES.NAME%TYPE,
   p_object_version_number      IN   OUT NOCOPY   CN_HEAD_HIERARCHIES.OBJECT_VERSION_NUMBER%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		 CN_HEAD_HIERARCHIES.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Update_Head_Hierarchy';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_count                   NUMBER;

   cursor c is
   select object_version_number, description, dimension_id
     from cn_head_hierarchies
    where head_hierarchy_id = p_head_hierarchy_id
    --R12 MOAC Changes--Start
    and org_id = p_org_id;
    --R12 MOAC Changes--End

   tlinfo c%rowtype ;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Head_Hierarchy;
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

   -- call the original forms API (CNDIHY.fmb -> CNDIHY2s/b.pls)

   -- START LOCK ROW --
   open  c;
   fetch c into tlinfo;
   if (c%notfound) then
      close c;
      fnd_message.set_name('CN', 'CN_RECORD_DELETED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
   end if;
   close c;

   if (tlinfo.object_version_number <> p_object_version_number) then
      fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
   end if;
   -- END LOCK ROW --

   -- validate name is unique
   select count(1) into l_count from cn_head_hierarchies
    where name = p_name and dimension_id = tlinfo.dimension_id
    --R12 MOAC Changes--Start
	and org_id = p_org_id
	--R12 MOAC Changes--End
      and head_hierarchy_id <> p_head_hierarchy_id;
   if l_count > 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_NAME_NOT_UNIQUE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   cn_head_hierarchies_all_pkg.update_row
     (X_HEAD_HIERARCHY_ID   => p_head_hierarchy_id,
      X_DIMENSION_ID        => tlinfo.dimension_id, -- leave unchanged
      X_DESCRIPTION         => tlinfo.description,  -- leave unchanged
      X_NAME                => p_name,
      X_LAST_UPDATE_DATE    => sysdate,
      X_LAST_UPDATED_BY     => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN   => fnd_global.login_id,
      --R12 MOAC Changes--Start
      X_ORG_ID => p_org_id,
      X_OBJECT_VERSION_NUMBER => p_object_version_number);
      --R12 MOAC Changes--End

      -- End of API body.

   -- Standard check of p_commit.

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Head_Hierarchy;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Head_Hierarchy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Head_Hierarchy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.add_exc_msg
           (G_PKG_NAME          ,
            l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
END Update_Head_Hierarchy;

-- Delete head hierarchy
PROCEDURE Delete_Head_Hierarchy
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_head_hierarchy_id          IN      CN_HEAD_HIERARCHIES.HEAD_HIERARCHY_ID%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		 CN_HEAD_HIERARCHIES.ORG_ID%TYPE,
 --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Delete_Head_Hierarchy';
   l_api_version             CONSTANT NUMBER       := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Head_Hierarchy;
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
   -- call the original forms API (CNDIHY.fmb -> CNDIHY2s/b.pls)
   cn_head_hierarchies_all_pkg.delete_row (p_head_hierarchy_id,
   --R12 MOAC Changes--Start
    p_org_id);
  --R12 MOAC Changes--End
   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Head_Hierarchy;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Head_Hierarchy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Head_Hierarchy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.add_exc_msg
           (G_PKG_NAME          ,
            l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
END Delete_Head_Hierarchy;


-- Function to identify if the hierarchy is a revenue class hierarchy
FUNCTION is_revenue_hier (p_head_hierarchy_id CN_DIM_HIERARCHIES.HEADER_DIM_HIERARCHY_ID%TYPE,
						p_org_id CN_DIM_HIERARCHIES.ORG_ID%TYPE)
  RETURN NUMBER IS
   l_count NUMBER := 0;
 BEGIN
   select count(*)
   into l_count
   from cn_repositories
   where rev_class_hierarchy_id = p_head_hierarchy_id
   --R12 MOAC Changes--Start
   and org_id = p_org_id;
   --R12 MOAC Changes--End

   RETURN l_count;
 END is_revenue_hier;

-- Create dimension hierarchy
PROCEDURE Create_Dim_Hierarchy
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_head_hierarchy_id          IN      CN_DIM_HIERARCHIES.HEADER_DIM_HIERARCHY_ID%TYPE,
   p_start_date                 IN      CN_DIM_HIERARCHIES.START_DATE%TYPE,
   p_end_date                   IN      CN_DIM_HIERARCHIES.END_DATE%TYPE,
   p_root_node                  IN      CN_DIM_HIERARCHIES.ROOT_NODE%TYPE,  -- not used
   --R12 MOAC Changes--Start
   p_org_id			IN		 CN_DIM_HIERARCHIES.ORG_ID%TYPE,
 --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_dim_hierarchy_id           OUT NOCOPY     CN_DIM_HIERARCHIES.DIM_HIERARCHY_ID%TYPE) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Create_Dim_Hierarchy';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_count                   NUMBER;
   l_name                    CN_HIERARCHY_NODES.NAME%TYPE;
   x_root_node               CN_DIM_HIERARCHIES.ROOT_NODE%TYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Dim_Hierarchy;
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

   -- validate dates don't overlap
   select count(1) into l_count
     from cn_dim_hierarchies
    where header_dim_hierarchy_id = p_head_hierarchy_id
    --R12 MOAC Changes--Start
    and org_id = p_org_id
    --R12 MOAC Changes--End
     and (                (start_date <= p_start_date  and
	    nvl(end_date,p_start_date) >= p_start_date) OR
			   (start_date >= p_start_date  and
			    start_date <= nvl(p_end_date, start_date)));
   if l_count > 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_DATE_OVERLAP');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   if p_end_date is not null and
      p_end_date < p_start_date then
      FND_MESSAGE.SET_NAME('CN', 'ALL_INVALID_PERIOD_RANGE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;


   -- call new TH (original form used forms built in TH)
   cn_dim_hierarchies_pkg.insert_row
     (x_header_dim_hierarchy_id   => p_head_hierarchy_id,
      x_start_date                => p_start_date,
      x_end_date                  => p_end_date,
      x_root_node                 => x_root_node,
      x_dim_hierarchy_id          => x_dim_hierarchy_id,
      --R12 MOAC Changes--Start
      x_org_id			=> p_org_id);
      --R12 MOAC Changes--End


    -- call to insert rows into notify log
    IF is_revenue_hier (p_head_hierarchy_id,p_org_id) = 1 THEN
     cn_mark_events_pkg.mark_event_rc_hier
     (p_event_name        => 'CHANGE_RC_HIER',
      p_object_name       => NULL,
      p_dim_hierarchy_id  => x_dim_hierarchy_id,
      p_head_hierarchy_id => p_head_hierarchy_id,
      p_start_date        => NULL,
      p_start_date_old    => p_start_date,
      p_end_date          => NULL,
      p_end_date_old      => p_end_date,
      p_org_id              => p_org_id);
    END IF;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Dim_Hierarchy;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Dim_Hierarchy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Dim_Hierarchy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.add_exc_msg
           (G_PKG_NAME          ,
            l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
END Create_Dim_Hierarchy;

-- Update dimension hierarchy (only dates are updateable)
PROCEDURE Update_Dim_Hierarchy
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dim_hierarchy_id           IN      CN_DIM_HIERARCHIES.DIM_HIERARCHY_ID%TYPE,
   p_start_date                 IN      CN_DIM_HIERARCHIES.START_DATE%TYPE,
   p_end_date                   IN      CN_DIM_HIERARCHIES.END_DATE%TYPE,
   p_object_version_number      IN OUT NOCOPY      CN_DIM_HIERARCHIES.OBJECT_VERSION_NUMBER%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		 CN_DIM_HIERARCHIES.ORG_ID%TYPE,
 --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Update_Dim_Hierarchy';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_count                   NUMBER;
   l_head_hierarchy_id       CN_DIM_HIERARCHIES.HEADER_DIM_HIERARCHY_ID%TYPE;
   l_root_node               CN_DIM_HIERARCHIES.ROOT_NODE%TYPE;
   l_old_start_date          CN_DIM_HIERARCHIES.START_DATE%TYPE;
   l_old_end_date            CN_DIM_HIERARCHIES.END_DATE%TYPE;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Dim_Hierarchy;
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
   -- validate dates don't overlap with another dim hierarchy under the
   -- same head hierarchy

   -- get head hierarchy ID and root node
   select header_dim_hierarchy_id, root_node
     into l_head_hierarchy_id, l_root_node
     from cn_dim_hierarchies
    where dim_hierarchy_id = p_dim_hierarchy_id
    --R12 MOAC Changes--Start
    and org_id = p_org_id;
    --R12 MOAC Changes--End

   if p_end_date is not null and
      p_end_date < p_start_date then
      FND_MESSAGE.SET_NAME('CN', 'ALL_INVALID_PERIOD_RANGE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;

   select count(1) into l_count
     from cn_dim_hierarchies
    where header_dim_hierarchy_id = l_head_hierarchy_id
    --R12 MOAC Changes--Start
	and org_id = p_org_id
	--R12 MOAC Changes--End
      and dim_hierarchy_id <> p_dim_hierarchy_id
      and (                (start_date <= p_start_date  and
	    nvl(end_date,p_start_date) >= p_start_date) OR
			   (start_date >= p_start_date  and
			    start_date <= nvl(p_end_date, start_date)));
   if l_count > 0 then
      FND_MESSAGE.SET_NAME('CN', 'CN_DATE_OVERLAP');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   end if;


   -- call to insert rows into notify log
   IF is_revenue_hier (l_head_hierarchy_id,p_org_id) = 1 THEN  -- R12 MOAC changes
    select start_date, end_date
    into l_old_start_date, l_old_end_date
    from cn_dim_hierarchies
    where dim_hierarchy_id = p_dim_hierarchy_id
    --R12 MOAC Changes--Start
    and org_id = p_org_id;
    --R12 MOAC Changes--End

    cn_mark_events_pkg.mark_event_rc_hier
     (p_event_name        => 'CHANGE_RC_HIER_PERIOD',
      p_object_name       => NULL,
      p_dim_hierarchy_id  => p_dim_hierarchy_id,
      p_head_hierarchy_id => l_head_hierarchy_id,
      p_start_date        => p_start_date,
      p_start_date_old    => l_old_start_date,
      p_end_date          => p_end_date,
      p_end_date_old      => l_old_end_date,
      p_org_id              => p_org_id);
   END IF;



   cn_dim_hierarchies_pkg.update_row
     (x_dim_hierarchy_id          => p_dim_hierarchy_id,
      x_header_dim_hierarchy_id   => l_head_hierarchy_id,
      x_start_date                => p_start_date,
      x_end_date                  => p_end_date,
      x_root_node                 => l_root_node,
      x_object_version_number     => p_object_version_number,
      --R12 MOAC Changes--Start
      x_org_id				=> p_org_id);
      --R12 MOAC Changes--End

   -- End of API body.

   --Increase version
   p_object_version_number := p_object_version_number + 1;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Dim_Hierarchy;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Dim_Hierarchy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Update_Dim_Hierarchy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.add_exc_msg
           (G_PKG_NAME          ,
            l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
END Update_Dim_Hierarchy;

-- Delete dimension hierarchy
PROCEDURE Delete_Dim_Hierarchy
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dim_hierarchy_id           IN      CN_DIM_HIERARCHIES.DIM_HIERARCHY_ID%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		 CN_DIM_HIERARCHIES.ORG_ID%TYPE,
 --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Delete_Dim_Hierarchy';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_head_hierarchy_id       CN_DIM_HIERARCHIES.HEADER_DIM_HIERARCHY_ID%TYPE;
   l_start_date              CN_DIM_HIERARCHIES.START_DATE%TYPE;
   l_end_date                CN_DIM_HIERARCHIES.END_DATE%TYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Dim_Hierarchy;
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

   -- get head hierarchy ID, start date and end date
    select header_dim_hierarchy_id, start_date, end_date
    into l_head_hierarchy_id, l_start_date, l_end_date
    from cn_dim_hierarchies
    where dim_hierarchy_id = p_dim_hierarchy_id
    --R12 MOAC Changes--Start
    and org_id = p_org_id;
    --R12 MOAC Changes--End

   -- call to insert rows into notify log
   IF is_revenue_hier (l_head_hierarchy_id,p_org_id) = 1 THEN
    cn_mark_events_pkg.mark_event_rc_hier
     (p_event_name        => 'CHANGE_RC_HIER',
      p_object_name       => NULL,
      p_dim_hierarchy_id  => p_dim_hierarchy_id,
      p_head_hierarchy_id => l_head_hierarchy_id,
      p_start_date        => NULL,
      p_start_date_old    => l_start_date,
      p_end_date          => NULL,
      p_end_date_old      => l_end_date,
      p_org_id          => p_org_id);
   END IF;


   -- call the original forms API (CNDIHY.fmb -> CNDIHY2s/b.pls)
   cn_dim_hierarchies_pkg.delete_row (p_dim_hierarchy_id);--,p_org_id);

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Dim_Hierarchy;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Dim_Hierarchy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Dim_Hierarchy;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.add_exc_msg
           (G_PKG_NAME          ,
            l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
END Delete_Dim_Hierarchy;

-- Create edge
PROCEDURE Create_Edge
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dim_hierarchy_id           IN      CN_HIERARCHY_EDGES.DIM_HIERARCHY_ID%TYPE,
   p_parent_value_id            IN      CN_HIERARCHY_EDGES.PARENT_VALUE_ID%TYPE,
   p_name                       IN      CN_HIERARCHY_NODES.NAME%TYPE,
   p_external_id                IN      CN_HIERARCHY_NODES.EXTERNAL_ID%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		 CN_HIERARCHY_EDGES.ORG_ID%TYPE,
 --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_value_id                   OUT NOCOPY     CN_HIERARCHY_EDGES.VALUE_ID%TYPE) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Create_Edge';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_max_date                CONSTANT DATE  := to_date('31-12-9999','DD-MM-YYYY');
   l_start_date              DATE;
   l_end_date                DATE;
   l_par_name                VARCHAR2(30);
   l_head_hier_id            CN_DIM_HIERARCHIES.HEADER_DIM_HIERARCHY_ID%TYPE;

   CURSOR dup_rev_classes is
      select h.start_date, h.end_date, r.name
	from cn_quota_rules r1, cn_quota_rules r2, cn_dim_explosion d,
	     cn_dim_hierarchies h, cn_quotas q, cn_revenue_classes r
	where r1.revenue_class_id = p_external_id
	  and r2.revenue_class_id = d.ancestor_external_id
	  AND r.revenue_class_id  = d.ancestor_external_id
	  and d.value_id = p_parent_value_id
	  and d.dim_hierarchy_id = h.dim_hierarchy_id
	  and h.dim_hierarchy_id = p_dim_hierarchy_id
	  and r1.quota_id = r2.quota_id
	  and r1.quota_id = q.quota_id
	  --R12 MOAC Changes--Start
	  and r1.org_id = r2.org_id
	  and r2.org_id = d.org_id
	  and d.org_id = h.org_id
	  and h.org_id = q.org_id
	  and q.org_id = r1.org_id
	  and r1.org_id =  p_org_id
	  and r.org_id = r1.org_id
	  --R12 MOAC Changes--End
	  and greatest(q.start_date, h.start_date) <=
	      least(nvl(q.end_date,l_max_date), nvl(h.end_date,l_max_date));

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Edge;
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
   -- call the original forms API (CNDIHY.fmb -> CNDIHY2s/b.pls)
   BEGIN
      -- see if we're dealing with the revenue classes
      SELECT header_dim_hierarchy_id INTO l_head_hier_id
	FROM cn_dim_hierarchies
       WHERE dim_hierarchy_id = p_dim_hierarchy_id
       --R12 MOAC Changes--Start
       and org_id = p_org_id;
       --R12 MOAC Changes--End

      IF cn_dim_hierarchies_pvt.is_revenue_hier(l_head_hier_id,p_org_id) > 0 THEN
	 OPEN  dup_rev_classes;
	 FETCH dup_rev_classes INTO l_start_date, l_end_date, l_par_name;

	 IF dup_rev_classes%found THEN
	    CLOSE dup_rev_classes;
	    FND_MESSAGE.SET_NAME('CN', 'REV_CLASS_HIER_CHECK');
	    fnd_message.set_token('REV_CLASS_NAME_PARENT', l_par_name);
	    fnd_message.set_token('REV_CLASS_NAME_CHILD', p_name);
	    fnd_message.set_token('PERIODS', l_start_date || ' - ' || l_end_date);
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
	 CLOSE dup_rev_classes;
      END IF;

      CN_DIHY_TWO_API_PKG.Insert_Edge
	(X_name                => p_name,
	 X_dim_hierarchy_id    => p_dim_hierarchy_id,
	 X_value_id            => x_value_id,
	 X_parent_value_id     => p_parent_value_id,
	 X_external_id	       => p_external_id,
	 X_hierarchy_api_id    => NULL, -- not used
	 --R12 MOAC Changes--Start
	 x_org_id			=> p_org_id);
	 --R12 MOAC Changes--End
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
	 FND_MESSAGE.SET_NAME('CN', 'HIER_NO_DIAMONDS');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
   END;

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Edge;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Edge;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Create_Edge;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.add_exc_msg
           (G_PKG_NAME          ,
            l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
END Create_Edge;

-- Delete edge
PROCEDURE Delete_Edge
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dim_hierarchy_id           IN      CN_HIERARCHY_EDGES.DIM_HIERARCHY_ID%TYPE,
   p_value_id                   IN      CN_HIERARCHY_EDGES.VALUE_ID%TYPE,
   p_parent_value_id            IN      CN_HIERARCHY_EDGES.PARENT_VALUE_ID%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		 CN_HIERARCHY_EDGES.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Delete_Edge';
   l_api_version             CONSTANT NUMBER       := 1.0;
   l_ext_id                  CN_HIERARCHY_NODES.EXTERNAL_ID%TYPE;
   l_count                   NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Edge;
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

   -- make sure the root is not being deleted
   if p_parent_value_id is null then
      -- see if parent value is a BASE NODE... if so it has no external ID
      select external_id into l_ext_id
	from cn_hierarchy_nodes
       where value_id = p_value_id
       --R12 MOAC Changes--Start
       and org_id = p_org_id;
       --R12 MOAC Changes--End

      if l_ext_id is null then
	 FND_MESSAGE.SET_NAME('CN', 'HIER_NO_DELETE_ROOT');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      end if;
   end if;

   -- make sure the edge still exists
   select count(1) into l_count
     from cn_hierarchy_edges
    where value_id = p_value_id
      and nvl(parent_value_id, -99) = nvl(p_parent_value_id, -99)
      and dim_hierarchy_id = p_dim_hierarchy_id
      --R12 MOAC Changes--Start
      and org_id = p_org_id;
      --R12 MOAC Changes--End

   if l_count = 0 then
      fnd_message.set_name('CN', 'CN_RECORD_DELETED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
   end if;

   CN_DIHY_TWO_API_PKG.Cascade_Delete
     (X_value_id              => p_value_id,
      X_parent_value_id       => p_parent_value_id,
      X_dim_hierarchy_id      => p_dim_hierarchy_id,
      X_org_id			=>   p_org_id);

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count                 =>      x_msg_count             ,
      p_data                  =>      x_msg_data              ,
      p_encoded               =>      FND_API.G_FALSE         );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Edge;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Edge;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
	 p_encoded               =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Edge;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF      FND_MSG_PUB.check_msg_level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.add_exc_msg
           (G_PKG_NAME          ,
            l_api_name           );
      END IF;
      FND_MSG_PUB.count_and_get
        (p_count                 =>      x_msg_count             ,
         p_data                  =>      x_msg_data              ,
         p_encoded               =>      FND_API.G_FALSE         );
END Delete_Edge;

-- export
PROCEDURE Export
  (errbuf                    OUT NOCOPY   VARCHAR2,
   retcode                   OUT NOCOPY   VARCHAR2,
   p_imp_header_id           IN    NUMBER,
   --R12 MOAC Changes--Start
   p_org_id IN NUMBER) IS
   --R12 MOAC Changes--End

   l_api_name         CONSTANT VARCHAR2(30) := 'Export';
   l_process_audit_id cn_process_audits.process_audit_id%TYPE;
   l_return_status    varchar2(1);
   l_msg_data         varchar2(2000);
   l_msg_count        number;
   l_col_names        CN_IMPORT_PVT.char_data_set_type;
   l_data             CN_IMPORT_PVT.char_data_set_type;
   l_rowcount         number := 0;
   l_rec_num          number := 0;
   l_message          VARCHAR2(2000);
   l_name             VARCHAR2(30);
   l_type             VARCHAR2(30);
   l_view_name        VARCHAR2(30);
   my_message         VARCHAR2(2000);
   err_num            NUMBER;

   -- this is a workaround since you cannot declare arrays of a
   -- type declared remotely
   type vt is table of varchar2(30);
   l_col_names_tmp vt := vt('RECORD_NUM', 'HIERARCHY_TYPE', 'BASE_TABLE_NAME',
			    'PRIMARY_KEY','HIERARCHY_VALUE','HIERARCHY_NAME',
			    'START_DATE', 'END_DATE',      'DEFAULT_NODE_FLAG',
			    'PARENT_NODE_NAME','NODE_NAME','LEVEL_NUM');

   cursor get_dim_hierarchies is
      select D.NAME       HIERARCHY_TYPE,
             O2.NAME      BASE_TABLE_NAME,
             O1.NAME      PRIMARY_KEY,
             O3.NAME      HIERARCHY_VALUE,
             H.NAME       HIERARCHY_NAME,
             M.START_DATE START_DATE,
             M.END_DATE   END_DATE,
             m.dim_hierarchy_id
	FROM cn_dimensions d, cn_objects o1, cn_objects o2, cn_objects o3,
	     cn_head_hierarchies h, cn_dim_hierarchies m
       WHERE o1.dimension_id = d.dimension_id
	 AND o1.table_id = d.source_table_id
	 AND o1.object_type = 'COL'
	 AND o1.primary_key = 'Y'
	 AND o2.object_id = o1.table_id
	 AND o3.table_id = o1.table_id
	 AND o3.object_type = 'COL'
	 AND o3.user_column_name = 'Y'
	 AND d.dimension_id = h.dimension_id
	 AND h.head_hierarchy_id = m.header_dim_hierarchy_id
	 AND	d.org_id = p_org_id
	 AND	o1.org_id = p_org_id
	 AND	o2.org_id = p_org_id
	 AND 	o3.org_id = p_org_id
	 AND 	h.org_id = p_org_id
	 AND	m.org_id = p_org_id
       ORDER BY 1, 5, 6;

   cursor traverse_tree (l_dim_hierarchy_id in number) is
      select decode(child.external_id, null, 'Y', 'N') DEFAULT_NODE_FLAG,
             parent.name                               PARENT_NODE_NAME,
             child.name                                NODE_NAME,
             e.depth                                   LEVEL_NUM
	from cn_hierarchy_nodes child, cn_hierarchy_nodes parent,
	(select value_id, parent_value_id, level depth, dim_hierarchy_id
	   from cn_hierarchy_edges
 	  start with (parent_value_id is null and
		      dim_hierarchy_id = l_dim_hierarchy_id)
	connect by parent_value_id = prior value_id
	    and dim_hierarchy_id = l_dim_hierarchy_id) e
       where child.value_id = e.value_id
         and child.dim_hierarchy_id = e.dim_hierarchy_id
         and parent.value_id(+) = e.parent_value_id
	 and parent.dim_hierarchy_id(+) = e.dim_hierarchy_id;

BEGIN
   retcode := 0 ;
   mo_global.init('CN');
   -- Get imp_header info
   SELECT h.name, h.import_type_code, t.view_name
     INTO l_name, l_type, l_view_name
     FROM cn_imp_headers h, cn_import_types t
    WHERE h.imp_header_id = p_imp_header_id
      AND t.import_type_code = h.import_type_code;

   -- open process audit batch
   cn_message_pkg.begin_batch
     ( x_process_type           => l_type,
       x_parent_proc_audit_id   => p_imp_header_id ,
       x_process_audit_id       => l_process_audit_id,
       x_request_id             => null,
       --R12 MOAC Changes--Start
       p_org_id		=>  p_org_id);
       --R12 MOAC Changes--End

   cn_message_pkg.write
     (p_message_text    => 'CN_EXP_HIERARCHY: Start Transfer Data. imp_header_id = ' || To_char(p_imp_header_id),
      p_message_type    => 'MILESTONE');

   -- API call here
   -- get column names
   for i in 1..l_col_names_tmp.count loop
      l_col_names(i) := l_col_names_tmp(i);
   end loop;

   -- we have to get the rowcount first - since the data must be applied
   -- sequentially by column... indexes are like
   -- 1 n+1 ... 11n+1  (there are 12 columns)
   -- 2 n+2 ... 11n+2
   -- n 2n  ... 12n
   for dim in get_dim_hierarchies loop
      for edge in traverse_tree(dim.dim_hierarchy_id) loop
	 l_rowcount := l_rowcount + 1;
      end loop;
   end loop;

   -- now populate the data
   for dim in get_dim_hierarchies loop
      cn_message_pkg.write
	(p_message_text    => 'Downloading dim hierarchy ' ||
	                      dim.dim_hierarchy_id,
	 p_message_type    => 'DEBUG');
      for edge in traverse_tree(dim.dim_hierarchy_id) loop
	 l_rec_num := l_rec_num + 1;
	 l_data(l_rowcount * 0  + l_rec_num) := l_rec_num;
	 l_data(l_rowcount * 1  + l_rec_num) := dim.hierarchy_type;
	 l_data(l_rowcount * 2  + l_rec_num) := dim.base_table_name;
	 l_data(l_rowcount * 3  + l_rec_num) := dim.primary_key;
	 l_data(l_rowcount * 4  + l_rec_num) := dim.hierarchy_value;
	 l_data(l_rowcount * 5  + l_rec_num) := dim.hierarchy_name;
	 l_data(l_rowcount * 6  + l_rec_num) := dim.start_date;
	 l_data(l_rowcount * 7  + l_rec_num) := dim.end_date;
	 l_data(l_rowcount * 8  + l_rec_num) := edge.default_node_flag;
	 l_data(l_rowcount * 9  + l_rec_num) := edge.parent_node_name;
	 l_data(l_rowcount * 10 + l_rec_num) := edge.node_name;
	 l_data(l_rowcount * 11 + l_rec_num) := edge.level_num;
      end loop;
   end loop;

   cn_import_client_pvt.Insert_Data
     (p_api_version                 => 1.0,
      p_imp_header_id               => p_imp_header_id,
      p_import_type_code            => l_type,
      p_table_name                  => l_view_name,
      p_col_names                   => l_col_names,
      p_data                        => l_data,
      p_row_count                   => l_rowcount,
      x_return_status               => l_return_status,
      x_msg_count                   => l_msg_count,
      x_msg_data                    => l_msg_data);

   IF l_return_status <> fnd_api.g_ret_sts_success THEN
      CN_IMPORT_PVT.update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'FAIL',
	 p_failed_row => l_rowcount);

      cn_message_pkg.write
	(p_message_text    => 'Export threw exception : rts sts ' ||
	 l_return_status,
	 p_message_type    => 'ERROR');

      my_message := fnd_msg_pub.get(p_encoded => FND_API.g_false);
      while (my_message is not null) loop
	 l_message := l_message || my_message || '; ';
	 my_message := fnd_msg_pub.get(p_encoded => FND_API.g_false);
      end loop;

      cn_message_pkg.write
	(p_message_text    => l_message,
	 p_message_type    => 'ERROR');

      retcode := 2;
      errbuf := l_message;
    ELSE
      -- normal completion
      CN_IMPORT_PVT.update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'COMPLETE',
	 p_processed_row => l_rowcount,
	 p_staged_row => l_rowcount,
	 p_failed_row => 0);

      -- set cn_imp_lines records status = 'COMPLETE'
      UPDATE cn_imp_lines
	SET status_code = 'COMPLETE'
	WHERE imp_header_id = p_imp_header_id
	;

      cn_message_pkg.write
	(p_message_text    => 'CN_EXP_HIERARCHY: End Transfer Data. imp_header_id = ' || To_char(p_imp_header_id),
	 p_message_type    => 'MILESTONE');

   END IF;

   -- close process batch
   cn_message_pkg.end_batch(l_process_audit_id);

   -- Commit all imports
   COMMIT;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      retcode := 2 ;
      cn_message_pkg.end_batch(l_process_audit_id);
      FND_MSG_PUB.count_and_get
	(p_count   =>  l_msg_count ,
	 p_data    =>  errbuf   ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN OTHERS THEN
      err_num :=  SQLCODE;
      IF err_num = -6501 THEN
	 retcode := 2 ;
	 errbuf := fnd_program.message;
       ELSE
	 retcode := 2 ;
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	 END IF;
	 FND_MSG_PUB.count_and_get
	   (p_count   =>  l_msg_count ,
	    p_data    =>  errbuf   ,
	    p_encoded => FND_API.G_FALSE
	    );
      END IF;

      cn_message_pkg.set_error(l_api_name,errbuf);
      cn_message_pkg.end_batch(l_process_audit_id);
END Export;


END CN_DIM_HIERARCHIES_PVT;

/
