--------------------------------------------------------
--  DDL for Package Body IBE_PROD_RELATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_PROD_RELATION_PVT" AS
/* $Header: IBEVCRLB.pls 120.0.12010000.2 2013/01/09 06:12:03 amaheshw ship $ */


PROCEDURE Insert_Relationship(
   p_api_version       IN  NUMBER                     ,
   p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status     OUT NOCOPY VARCHAR2                   ,
   x_msg_count         OUT NOCOPY NUMBER                     ,
   x_msg_data          OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code     IN  VARCHAR2                   ,
   p_description       IN  VARCHAR2 := NULL           ,
   p_start_date_active IN  DATE     := NULL           ,
   p_end_date_active   IN  DATE     := NULL
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Insert_Relationship';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   L_USER_ID     CONSTANT NUMBER       := FND_GLOBAL.User_ID;
   l_rowid                VARCHAR2(30);
   l_debug VARCHAR2(1);

BEGIN
        l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   -- Standard Start of API savepoint
   SAVEPOINT Insert_Relationship_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
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

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_PVT.Insert_Relationship(+)');
   END IF;
   -- API body
   BEGIN

     fnd_lookup_values_pkg.insert_row
       (
       X_ROWID                       => l_rowid,
       X_LOOKUP_TYPE                 => 'IBE_RELATIONSHIP_TYPES',
       X_VIEW_APPLICATION_ID         => l_view_application_id,
       X_LOOKUP_CODE                 => p_rel_type_code,
       X_TAG                         => NULL,
       X_ATTRIBUTE_CATEGORY          => NULL,
       X_ATTRIBUTE1                  => NULL,
       X_ATTRIBUTE2                  => NULL,
       X_ATTRIBUTE3                  => NULL,
       X_ATTRIBUTE4                  => NULL,
       X_ENABLED_FLAG                => 'Y',
       X_START_DATE_ACTIVE           => p_start_date_active,
       X_END_DATE_ACTIVE             => p_end_date_active,
       X_TERRITORY_CODE              => NULL,
       X_ATTRIBUTE5                  => NULL,
       X_ATTRIBUTE6                  => NULL,
       X_ATTRIBUTE7                  => NULL,
       X_ATTRIBUTE8                  => NULL,
       X_ATTRIBUTE9                  => NULL,
       X_ATTRIBUTE10                 => NULL,
       X_ATTRIBUTE11                 => NULL,
       X_ATTRIBUTE12                 => NULL,
       X_ATTRIBUTE13                 => NULL,
       X_ATTRIBUTE14                 => NULL,
       X_ATTRIBUTE15                 => NULL,
       X_MEANING                     => p_rel_type_code,
       X_DESCRIPTION                 => p_description,
       X_CREATION_DATE               => sysdate,
       X_CREATED_BY                  => l_user_id,
       X_LAST_UPDATE_DATE            => sysdate,
       X_LAST_UPDATED_BY             => l_user_id,
       X_LAST_UPDATE_LOGIN           => FND_GLOBAL.login_id
       );

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 'Y') THEN
           IBE_UTIL.debug('Insert statement failed.');
        END IF;
        FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_CREATED');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
        IF (l_debug = 'Y') THEN
           IBE_UTIL.debug('Insert statement failed.');
        END IF;
        FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
        FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
        FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
        FND_MESSAGE.Set_Token('REASON', SQLERRM);
        FND_MSG_PUB.Add;

        FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_CREATED');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   -- End of API body.
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_PVT.Insert_Relationship(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Insert_Relationship_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Insert_Relationship_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN OTHERS THEN
      ROLLBACK TO Insert_Relationship_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  L_API_NAME );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Insert_Relationship;


PROCEDURE Update_Relationship(
   p_api_version   IN  NUMBER                     ,
   p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit        IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status OUT NOCOPY VARCHAR2                   ,
   x_msg_count     OUT NOCOPY NUMBER                     ,
   x_msg_data      OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code IN  VARCHAR2                   ,
   p_description   IN  VARCHAR2                   ,
   p_start_date    IN  DATE                       ,
   p_end_date      IN  DATE
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Update_Relationship';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   L_USER_ID     CONSTANT NUMBER       := FND_GLOBAL.User_ID;
   i                      PLS_INTEGER;
   l_debug VARCHAR2(1);

BEGIN
        l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   -- Standard Start of API savepoint
   SAVEPOINT Update_Relationship_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
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

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_PVT.Update_Relationship(+)');
   END IF;
   -- API body
   BEGIN
     fnd_lookup_values_pkg.update_row
       (
       X_LOOKUP_TYPE                 => 'IBE_RELATIONSHIP_TYPES',
       X_VIEW_APPLICATION_ID         => l_view_application_id,
       X_LOOKUP_CODE                 => p_rel_type_code,
       X_TAG                         => NULL,
       X_ATTRIBUTE_CATEGORY          => NULL,
       X_ATTRIBUTE1                  => NULL,
       X_ATTRIBUTE2                  => NULL,
       X_ATTRIBUTE3                  => NULL,
       X_ATTRIBUTE4                  => NULL,
       X_ENABLED_FLAG                => 'Y',
       X_START_DATE_ACTIVE           => p_start_date,
       X_END_DATE_ACTIVE             => p_end_date,
       X_TERRITORY_CODE              => NULL,
       X_ATTRIBUTE5                  => NULL,
       X_ATTRIBUTE6                  => NULL,
       X_ATTRIBUTE7                  => NULL,
       X_ATTRIBUTE8                  => NULL,
       X_ATTRIBUTE9                  => NULL,
       X_ATTRIBUTE10                 => NULL,
       X_ATTRIBUTE11                 => NULL,
       X_ATTRIBUTE12                 => NULL,
       X_ATTRIBUTE13                 => NULL,
       X_ATTRIBUTE14                 => NULL,
       X_ATTRIBUTE15                 => NULL,
       X_MEANING                     => p_rel_type_code,
       X_DESCRIPTION                 => p_description,
       X_LAST_UPDATE_DATE            => sysdate,
       X_LAST_UPDATED_BY             => l_user_id,
       X_LAST_UPDATE_LOGIN           => FND_GLOBAL.login_id
       );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 'Y') THEN
           IBE_UTIL.debug('Update statement failed.');
        END IF;
        FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_EXIST');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
        IF (l_debug = 'Y') THEN
           IBE_UTIL.debug('Update statement failed.');
        END IF;
        FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
        FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
        FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
        FND_MESSAGE.Set_Token('REASON', SQLERRM);
        FND_MSG_PUB.Add;

        FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_EXIST');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   -- End of API body.
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_PVT.Update_Relationship(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Relationship_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Relationship_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN OTHERS THEN
      ROLLBACK TO Update_Relationship_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  L_API_NAME );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Update_Relationship;


PROCEDURE Update_Relationship_Detail(
   p_api_version   IN  NUMBER                     ,
   p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit        IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status OUT NOCOPY VARCHAR2                   ,
   x_msg_count     OUT NOCOPY NUMBER                     ,
   x_msg_data      OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code IN  VARCHAR2                   ,
   p_meaning       IN  VARCHAR2                   ,
   p_description   IN  VARCHAR2                   ,
   p_start_date    IN  DATE                       ,
   p_end_date      IN  DATE
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Update_Relationship_Detail';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   L_USER_ID     CONSTANT NUMBER       := FND_GLOBAL.User_ID;
   i                      PLS_INTEGER;
   l_debug VARCHAR2(1);

BEGIN
        l_debug := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   -- Standard Start of API savepoint
   SAVEPOINT Update_Relationship_Detail_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
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

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_PVT.Update_Relationship_Detail(+)');
   END IF;
   -- API body
   BEGIN
     fnd_lookup_values_pkg.update_row
       (
       X_LOOKUP_TYPE                 => 'IBE_RELATIONSHIP_TYPES',
       X_VIEW_APPLICATION_ID         => l_view_application_id,
       X_LOOKUP_CODE                 => p_rel_type_code,
       X_TAG                         => NULL,
       X_ATTRIBUTE_CATEGORY          => NULL,
       X_ATTRIBUTE1                  => NULL,
       X_ATTRIBUTE2                  => NULL,
       X_ATTRIBUTE3                  => NULL,
       X_ATTRIBUTE4                  => NULL,
       X_ENABLED_FLAG                => 'Y',
       X_START_DATE_ACTIVE           => p_start_date,
       X_END_DATE_ACTIVE             => p_end_date,
       X_TERRITORY_CODE              => NULL,
       X_ATTRIBUTE5                  => NULL,
       X_ATTRIBUTE6                  => NULL,
       X_ATTRIBUTE7                  => NULL,
       X_ATTRIBUTE8                  => NULL,
       X_ATTRIBUTE9                  => NULL,
       X_ATTRIBUTE10                 => NULL,
       X_ATTRIBUTE11                 => NULL,
       X_ATTRIBUTE12                 => NULL,
       X_ATTRIBUTE13                 => NULL,
       X_ATTRIBUTE14                 => NULL,
       X_ATTRIBUTE15                 => NULL,
       X_MEANING                     => p_meaning,
       X_DESCRIPTION                 => p_description,
       X_LAST_UPDATE_DATE            => sysdate,
       X_LAST_UPDATED_BY             => l_user_id,
       X_LAST_UPDATE_LOGIN           => FND_GLOBAL.login_id
       );
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 'Y') THEN
           IBE_UTIL.debug('Update statement failed.');
        END IF;
        FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_EXIST');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
        IF (l_debug = 'Y') THEN
           IBE_UTIL.debug('Update statement failed.');
        END IF;
        FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
        FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
        FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
        FND_MESSAGE.Set_Token('REASON', SQLERRM);
        FND_MSG_PUB.Add;

        FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_EXIST');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   -- End of API body.
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_PVT.Update_Relationship_Detail(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Relationship_Detail_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Relationship_Detail_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN OTHERS THEN
      ROLLBACK TO Update_Relationship_Detail_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  L_API_NAME );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Update_Relationship_Detail;


PROCEDURE Delete_Relationships(
   p_api_version       IN  NUMBER                     ,
   p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status     OUT NOCOPY VARCHAR2                   ,
   x_msg_count         OUT NOCOPY NUMBER                     ,
   x_msg_data          OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code_tbl IN  JTF_Varchar2_Table_100
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Delete_Relationships';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   i                      PLS_INTEGER;
   l_debug VARCHAR2(1);

BEGIN
        l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   -- Standard Start of API savepoint
   SAVEPOINT Delete_Relationship_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
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

   IF (p_rel_type_code_tbl IS NULL OR p_rel_type_code_tbl.COUNT <= 0) THEN
     RETURN;
   END IF;

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_PVT.Delete_Relationship(+)');
   END IF;
   -- API body
   FOR i IN 1..p_rel_type_code_tbl.COUNT LOOP

     BEGIN
       fnd_lookup_values_pkg.delete_row
         (
         X_LOOKUP_TYPE             => 'IBE_RELATIONSHIP_TYPES',
         X_VIEW_APPLICATION_ID     => l_view_application_id,
         X_LOOKUP_CODE             => p_rel_type_code_tbl(i)
         );

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (l_debug = 'Y') THEN
             IBE_UTIL.debug('Delete statement failed.');
          END IF;
          FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_EXIST');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
             IBE_UTIL.debug('Delete statement failed.');
          END IF;
          FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
          FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
          FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
          FND_MESSAGE.Set_Token('REASON', SQLERRM);
          FND_MSG_PUB.Add;

          FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_EXIST');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;

   END LOOP;

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Deleting rows in IBE_CT_RELATION_RULES.');
   END IF;
   FORALL i IN p_rel_type_code_tbl.FIRST..p_rel_type_code_tbl.LAST
      DELETE
        FROM ibe_ct_relation_rules
       WHERE relation_type_code = p_rel_type_code_tbl(i);

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Deleting rows in IBE_CT_RELATED_ITEMS.');
   END IF;
   FORALL i IN p_rel_type_code_tbl.FIRST..p_rel_type_code_tbl.LAST
      DELETE
        FROM ibe_ct_related_items
       WHERE relation_type_code = p_rel_type_code_tbl(i);

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Deleting rows in IBE_CT_REL_EXCLUSIONS.');
   END IF;
   FORALL i IN p_rel_type_code_tbl.FIRST..p_rel_type_code_tbl.LAST
      DELETE
        FROM ibe_ct_rel_exclusions
       WHERE relation_type_code = p_rel_type_code_tbl(i);
   -- End of API body.
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_PVT.Delete_Relationship(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Relationship_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Relationship_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN OTHERS THEN
      ROLLBACK TO Delete_Relationship_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  L_API_NAME );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Delete_Relationships;


PROCEDURE Exclude_Related_Items(
   p_api_version           IN  NUMBER                     ,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status         OUT NOCOPY VARCHAR2                   ,
   x_msg_count             OUT NOCOPY NUMBER                     ,
   x_msg_data              OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code         IN  VARCHAR2                   ,
   p_inventory_item_id_tbl IN  JTF_Number_Table           ,
   p_related_item_id_tbl   IN  JTF_Number_Table
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Exclude_Related_Items';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   L_USER_ID     CONSTANT NUMBER       := FND_GLOBAL.User_ID;
   l_debug VARCHAR2(1);

BEGIN
        l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   -- Standard Start of API savepoint
   SAVEPOINT Exclude_Related_Items_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
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

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_PVT.Exclude_Related_Items(+)');
   END IF;
   -- API body
   FORALL i IN p_inventory_item_id_tbl.FIRST..p_inventory_item_id_tbl.LAST
      INSERT INTO IBE_CT_REL_EXCLUSIONS(
         organization_id, relation_type_code, inventory_item_id,
         related_item_id, object_version_number, created_by,
         creation_date, last_updated_by, last_update_date
      )
      VALUES(
         L_ORGANIZATION_ID, p_rel_type_code, p_inventory_item_id_tbl(i),
         p_related_item_id_tbl(i), 1, L_USER_ID,
         SYSDATE, L_USER_ID, SYSDATE
      );
   -- End of API body.
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_PVT.Exclude_Related_Items(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Exclude_Related_Items_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Exclude_Related_Items_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN OTHERS THEN
      ROLLBACK TO Exclude_Related_Items_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  L_API_NAME );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Exclude_Related_Items;


PROCEDURE Include_Related_Items(
   p_api_version           IN  NUMBER                     ,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status         OUT NOCOPY VARCHAR2                   ,
   x_msg_count             OUT NOCOPY NUMBER                     ,
   x_msg_data              OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code         IN  VARCHAR2                   ,
   p_inventory_item_id_tbl IN  JTF_Number_Table           ,
   p_related_item_id_tbl   IN  JTF_Number_Table
)
IS
   L_API_NAME    CONSTANT VARCHAR2(30) := 'Include_Related_Items';
   L_API_VERSION CONSTANT NUMBER       := 1.0;
   L_USER_ID     CONSTANT NUMBER       := FND_GLOBAL.User_ID;
   l_debug VARCHAR2(1);

BEGIN
        l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   -- Standard Start of API savepoint
   SAVEPOINT Include_Related_Items_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                      p_api_version,
                                      L_API_NAME   ,
                                      G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_PVT.Include_Related_Items(+)');
   END IF;
   -- API body
   FORALL i IN p_inventory_item_id_tbl.FIRST..p_inventory_item_id_tbl.LAST
      DELETE
      FROM IBE_CT_REL_EXCLUSIONS
      WHERE relation_type_code = p_rel_type_code
        AND inventory_item_id  = p_inventory_item_id_tbl(i)
        AND related_item_id    = p_related_item_id_tbl(i)
	   AND organization_id    = L_ORGANIZATION_ID;  --Bug 2922902
   -- End of API body.
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_PVT.Include_Related_Items(-)');
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Include_Related_Items_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Include_Related_Items_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

   WHEN OTHERS THEN
      ROLLBACK TO Include_Related_Items_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  L_API_NAME );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Include_Related_Items;


--changes for bug 2922902
PROCEDURE Insert_Related_Items_Rows(
   p_rel_type_code      IN VARCHAR2,
   p_rel_rule_id        IN NUMBER  ,
   p_origin_object_type IN VARCHAR2,
   p_dest_object_type   IN VARCHAR2,
   p_origin_object_id   IN NUMBER  ,
   p_dest_object_id     IN NUMBER
) IS
BEGIN
  Insert_Related_Items_Rows(
    p_rel_type_code,
    p_rel_rule_id,
    p_origin_object_type,
    p_dest_object_type,
    p_origin_object_id,
    p_dest_object_id,
    L_ORGANIZATION_ID
   );

END Insert_Related_Items_Rows;



PROCEDURE Insert_Related_Items_Rows(
   p_rel_type_code      IN VARCHAR2,
   p_rel_rule_id        IN NUMBER  ,
   p_origin_object_type IN VARCHAR2,
   p_dest_object_type   IN VARCHAR2,
   p_origin_object_id   IN NUMBER  ,
   p_dest_object_id     IN NUMBER  ,
   p_organization_id    IN NUMBER
)
IS
   L_USER_ID CONSTANT NUMBER := FND_GLOBAL.User_ID;
   l_category_set_id_str VARCHAR2(30);
   l_debug VARCHAR2(1);

BEGIN
        l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');

   l_category_set_id_str := FND_PROFILE.VALUE_SPECIFIC('IBE_CATEGORY_SET', null, null, 671);
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Category set id from the profile = '||l_category_set_id_str);
   END IF;

   IF p_origin_object_type = 'N' AND p_dest_object_type = 'N' THEN
      NULL;
   ELSIF p_origin_object_type = 'S' AND p_dest_object_type = 'S' THEN
      INSERT INTO IBE_CT_RELATED_ITEMS(
         organization_id, relation_type_code, relation_rule_id, inventory_item_id,
         related_item_id, object_version_number, created_by, creation_date,
         last_updated_by, last_update_date
      )
      SELECT JDSI1.organization_id, p_rel_type_code, p_rel_rule_id, JDSI1.inventory_item_id,
             JDSI2.inventory_item_id, 1, L_USER_ID, SYSDATE,
             L_USER_ID, SYSDATE
      FROM IBE_DSP_SECTION_ITEMS JDSI1,
           IBE_DSP_SECTION_ITEMS JDSI2
      WHERE JDSI1.section_id = p_origin_object_id
        AND JDSI2.section_id = p_dest_object_id
	   AND JDSI1.organization_id = JDSI2.organization_id; --Bug 2922902

   ELSIF p_origin_object_type = 'S' AND p_dest_object_type = 'C' THEN
      INSERT INTO IBE_CT_RELATED_ITEMS(
         organization_id, relation_type_code, relation_rule_id, inventory_item_id,
         related_item_id, object_version_number, created_by, creation_date,
         last_updated_by, last_update_date
      )
      SELECT DISTINCT MIC.organization_id, p_rel_type_code, p_rel_rule_id,
                      JDSI.inventory_item_id, MIC.inventory_item_id, 1,
                      L_USER_ID, SYSDATE, L_USER_ID, SYSDATE
      FROM IBE_DSP_SECTION_ITEMS JDSI,
           MTL_ITEM_CATEGORIES MIC
      WHERE JDSI.section_id     = p_origin_object_id
        AND MIC.organization_id = JDSI.organization_id  --Bug 2922902
        AND MIC.category_id     = p_dest_object_id
	   AND MIC.category_set_id = l_category_set_id_str;  --Bug 2630696

   ELSIF p_origin_object_type = 'S' AND p_dest_object_type = 'I' THEN
      INSERT INTO IBE_CT_RELATED_ITEMS(
         organization_id, relation_type_code, relation_rule_id, inventory_item_id,
         related_item_id, object_version_number, created_by, creation_date,
         last_updated_by, last_update_date
      )
      SELECT p_organization_id, p_rel_type_code, p_rel_rule_id, JDSI.inventory_item_id,
             p_dest_object_id, 1, L_USER_ID, SYSDATE,
             L_USER_ID, SYSDATE
      FROM IBE_DSP_SECTION_ITEMS JDSI
      WHERE JDSI.section_id = p_origin_object_id
        AND JDSI.organization_id = p_organization_id;  --Bug 2922902

   ELSIF p_origin_object_type = 'C' AND p_dest_object_type = 'S' THEN
      INSERT INTO IBE_CT_RELATED_ITEMS(
         organization_id, relation_type_code, relation_rule_id, inventory_item_id,
         related_item_id, object_version_number, created_by, creation_date,
         last_updated_by, last_update_date
      )
      SELECT DISTINCT MIC.organization_id, p_rel_type_code, p_rel_rule_id, MIC.inventory_item_id,
             JDSI.inventory_item_id, 1, L_USER_ID, SYSDATE,
             L_USER_ID, SYSDATE
      FROM MTL_ITEM_CATEGORIES MIC,
           IBE_DSP_SECTION_ITEMS JDSI
      WHERE MIC.organization_id  = JDSI.organization_id  --Bug 2922902
        AND MIC.category_id      = p_origin_object_id
        AND JDSI.section_id      = p_dest_object_id
	   AND MIC.category_set_id  = l_category_set_id_str; --Bug 2630696

   ELSIF p_origin_object_type = 'C' AND p_dest_object_type = 'C' THEN
      INSERT INTO IBE_CT_RELATED_ITEMS(
         organization_id, relation_type_code, relation_rule_id, inventory_item_id,
         related_item_id, object_version_number, created_by, creation_date,
         last_updated_by, last_update_date
      )
      SELECT DISTINCT MIC1.organization_id, p_rel_type_code, p_rel_rule_id, MIC1.inventory_item_id,
             MIC2.inventory_item_id, 1, L_USER_ID, SYSDATE,
             L_USER_ID, SYSDATE
      FROM MTL_ITEM_CATEGORIES MIC1,
           MTL_ITEM_CATEGORIES MIC2
      WHERE MIC1.organization_id = MIC2.organization_id  --Bug 2922902
        AND MIC1.category_id     = p_origin_object_id
        AND MIC2.category_id     = p_dest_object_id
	   AND MIC1.organization_id = MIC2.organization_id   --Bug 2630696
	   AND MIC1.category_set_id = MIC2.category_set_id   --Bug 2630696
	   AND MIC1.category_set_id = l_category_set_id_str; --bug 2630696

   ELSIF p_origin_object_type = 'C' AND p_dest_object_type = 'I' THEN
      INSERT INTO IBE_CT_RELATED_ITEMS(
         organization_id, relation_type_code, relation_rule_id, inventory_item_id,
         related_item_id, object_version_number, created_by, creation_date,
         last_updated_by, last_update_date
      )
      SELECT DISTINCT p_organization_id, p_rel_type_code, p_rel_rule_id, MIC.inventory_item_id,
             p_dest_object_id, 1, L_USER_ID, SYSDATE,
             L_USER_ID, SYSDATE
      FROM MTL_ITEM_CATEGORIES MIC
      WHERE MIC.organization_id = p_organization_id
        AND MIC.category_id     = p_origin_object_id
	   AND MIC.category_set_id = l_category_set_id_str; --Bug 2630696

   ELSIF p_origin_object_type = 'I' AND p_dest_object_type = 'S' THEN
      INSERT INTO IBE_CT_RELATED_ITEMS(
         organization_id, relation_type_code, relation_rule_id, inventory_item_id,
         related_item_id, object_version_number, created_by, creation_date,
         last_updated_by, last_update_date
      )
      SELECT p_organization_id, p_rel_type_code, p_rel_rule_id, p_origin_object_id,
             JDSI.inventory_item_id, 1, L_USER_ID, SYSDATE,
             L_USER_ID, SYSDATE
      FROM IBE_DSP_SECTION_ITEMS JDSI
      WHERE JDSI.section_id      = p_dest_object_id
	   AND JDSI.organization_id = p_organization_id;  --Bug 2922902

   ELSIF p_origin_object_type = 'I' AND p_dest_object_type = 'C' THEN
      INSERT INTO IBE_CT_RELATED_ITEMS(
         organization_id, relation_type_code, relation_rule_id, inventory_item_id,
         related_item_id, object_version_number, created_by, creation_date,
         last_updated_by, last_update_date
      )
      SELECT DISTINCT p_organization_id, p_rel_type_code, p_rel_rule_id, p_origin_object_id,
             MIC.inventory_item_id, 1, L_USER_ID, SYSDATE,
             L_USER_ID, SYSDATE
      FROM MTL_ITEM_CATEGORIES MIC
      WHERE MIC.organization_id = p_organization_id
        AND MIC.category_id     = p_dest_object_id
	   AND MIC.category_set_id = l_category_set_id_str; --Bug 2630696

   ELSIF p_origin_object_type = 'I' AND p_dest_object_type = 'I' THEN
      INSERT INTO IBE_CT_RELATED_ITEMS(
         organization_id, relation_type_code, relation_rule_id, inventory_item_id,
         related_item_id, object_version_number, created_by, creation_date,
         last_updated_by, last_update_date
      )
      VALUES(
         p_organization_id, p_rel_type_code, p_rel_rule_id, p_origin_object_id,
         p_dest_object_id, 1, L_USER_ID, SYSDATE,
         L_USER_ID, SYSDATE
      );
   END IF;
END Insert_Related_Items_Rows;


PROCEDURE Remove_Invalid_Exclusions
IS
BEGIN
   DELETE
   FROM IBE_CT_REL_EXCLUSIONS ICRE
   WHERE NOT EXISTS( SELECT NULL
                     FROM IBE_CT_RELATED_ITEMS ICRI
                     WHERE ICRI.relation_type_code = ICRE.relation_type_code
                       AND ICRI.inventory_item_id  = ICRE.inventory_item_id
				   AND ICRI.organization_id = ICRE.organization_id --Bug 2922902
                       AND ICRI.related_item_id    = ICRE.related_item_id );
END Remove_Invalid_Exclusions;


PROCEDURE Item_Category_Inserted(
   p_category_id       IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_organization_id   IN NUMBER DEFAULT NULL) --Bug 2922902,3001591
IS
   TYPE rel_rule_csr_type IS REF CURSOR;
   l_rel_rule_csr           rel_rule_csr_type;
   l_rel_rule_id            NUMBER(15);
   l_rel_type_code          VARCHAR2(30);
   l_object_type            VARCHAR2(30);
   l_object_id              NUMBER(15);
   L_USER_ID       CONSTANT NUMBER := FND_GLOBAL.User_ID;
BEGIN
   -- 1. Where Category p_category_id is origin
   --09/01/12   AMAHESHW   Bug 16078175 Ignore AUTOPLACEMENT relationship during Item_Category_Inserted proc
   OPEN l_rel_rule_csr FOR 'SELECT relation_type_code, relation_rule_id, dest_object_type, dest_object_id ' ||
                           'FROM ibe_ct_relation_rules ' ||
                           'WHERE origin_object_type = ''C'' ' ||
                             'AND origin_object_id = :category_id ' ||
                             'AND relation_type_code <> ''AUTOPLACEMENT'' '
                       USING p_category_id;

   LOOP
      FETCH l_rel_rule_csr INTO l_rel_type_code, l_rel_rule_id, l_object_type, l_object_id;
      EXIT WHEN l_rel_rule_csr%NOTFOUND;

	 IF (p_organization_id is NULL) THEN
      Insert_Related_Items_Rows( p_rel_type_code      => l_rel_type_code    ,
                                 p_rel_rule_id        => l_rel_rule_id      ,
                                 p_origin_object_type => 'I'                ,
                                 p_dest_object_type   => l_object_type      ,
                                 p_origin_object_id   => p_inventory_item_id,
                                 p_dest_object_id     => l_object_id        ,
         /*Bug 3001591*/         p_organization_id    => L_ORGANIZATION_ID);
	 ELSE
      Insert_Related_Items_Rows( p_rel_type_code      => l_rel_type_code    ,
                                 p_rel_rule_id        => l_rel_rule_id      ,
                                 p_origin_object_type => 'I'                ,
                                 p_dest_object_type   => l_object_type      ,
                                 p_origin_object_id   => p_inventory_item_id,
                                 p_dest_object_id     => l_object_id        ,
         /*Bug 2922902*/         p_organization_id    => p_organization_id);
	 END IF;
   END LOOP;
   CLOSE l_rel_rule_csr;

   -- 2. Where Category p_category_id is destination
   --09/01/12   AMAHESHW   Bug 16078175 Ignore AUTOPLACEMENT relationship during Item_Category_Inserted proc
   OPEN l_rel_rule_csr FOR 'SELECT relation_type_code, relation_rule_id, origin_object_type, origin_object_id ' ||
                           'FROM ibe_ct_relation_rules ' ||
                           'WHERE dest_object_type = ''C'' ' ||
                             'AND dest_object_id = :category_id '  ||
                             'AND relation_type_code <> ''AUTOPLACEMENT'' '
                       USING p_category_id;

   LOOP
      FETCH l_rel_rule_csr INTO l_rel_type_code, l_rel_rule_id, l_object_type, l_object_id;
      EXIT WHEN l_rel_rule_csr%NOTFOUND;

	 IF (p_organization_id is NULL) THEN
      Insert_Related_Items_Rows( p_rel_type_code      => l_rel_type_code    ,
                                 p_rel_rule_id        => l_rel_rule_id      ,
                                 p_origin_object_type => l_object_type      ,
                                 p_dest_object_type   => 'I'                ,
                                 p_origin_object_id   => l_object_id        ,
                                 p_dest_object_id     => p_inventory_item_id ,
         /*Bug 3001591*/         p_organization_id    => L_ORGANIZATION_ID);
      ELSE
      Insert_Related_Items_Rows( p_rel_type_code      => l_rel_type_code    ,
                                 p_rel_rule_id        => l_rel_rule_id      ,
                                 p_origin_object_type => l_object_type      ,
                                 p_dest_object_type   => 'I'                ,
                                 p_origin_object_id   => l_object_id        ,
                                 p_dest_object_id     => p_inventory_item_id ,
         /*Bug 2922902*/         p_organization_id    => p_organization_id);
	 END IF;
   END LOOP;
   CLOSE l_rel_rule_csr;

END Item_Category_Inserted;


PROCEDURE Item_Section_Inserted(
   p_section_id        IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_organization_id   IN NUMBER DEFAULT NULL)  --Bug 2922902,3001591
IS
   TYPE rel_rule_csr_type IS REF CURSOR;
   l_rel_rule_csr           rel_rule_csr_type;
   l_rel_rule_id            NUMBER(15);
   l_rel_type_code          VARCHAR2(30);
   l_object_type            VARCHAR2(30);
   l_object_id              NUMBER(15);
   L_USER_ID       CONSTANT NUMBER := FND_GLOBAL.User_ID;
BEGIN
   -- 1. Where Section p_section_id is origin
   OPEN l_rel_rule_csr FOR 'SELECT relation_type_code, relation_rule_id, dest_object_type, dest_object_id ' ||
                           'FROM ibe_ct_relation_rules ' ||
                           'WHERE origin_object_type = ''S'' ' ||
                             'AND origin_object_id = :section_id ' ||
                             'AND relation_type_code <> ''AUTOPLACEMENT'' '
                       USING p_section_id;

   LOOP
      FETCH l_rel_rule_csr INTO l_rel_type_code, l_rel_rule_id, l_object_type, l_object_id;
      EXIT WHEN l_rel_rule_csr%NOTFOUND;

	 IF (p_organization_id IS NULL) THEN
      Insert_Related_Items_Rows( p_rel_type_code      => l_rel_type_code    ,
                                 p_rel_rule_id        => l_rel_rule_id      ,
                                 p_origin_object_type => 'I'                ,
                                 p_dest_object_type   => l_object_type      ,
                                 p_origin_object_id   => p_inventory_item_id,
                                 p_dest_object_id     => l_object_id        ,
       /*Bug 3001591*/           p_organization_id    => L_ORGANIZATION_ID);
      ELSE
      Insert_Related_Items_Rows( p_rel_type_code      => l_rel_type_code    ,
                                 p_rel_rule_id        => l_rel_rule_id      ,
                                 p_origin_object_type => 'I'                ,
                                 p_dest_object_type   => l_object_type      ,
                                 p_origin_object_id   => p_inventory_item_id,
                                 p_dest_object_id     => l_object_id        ,
       /*Bug 2922902*/           p_organization_id    => p_organization_id);
	  END IF;
   END LOOP;
   CLOSE l_rel_rule_csr;

   -- 2. Where Section p_section_id is destination
   OPEN l_rel_rule_csr FOR 'SELECT relation_type_code, relation_rule_id, origin_object_type, origin_object_id ' ||
                           'FROM ibe_ct_relation_rules ' ||
                           'WHERE dest_object_type = ''S'' ' ||
                             'AND dest_object_id = :section_id '
                       USING p_section_id;

   LOOP
      FETCH l_rel_rule_csr INTO l_rel_type_code, l_rel_rule_id, l_object_type, l_object_id;
      EXIT WHEN l_rel_rule_csr%NOTFOUND;

	 IF (p_organization_id IS NULL) THEN
      Insert_Related_Items_Rows( p_rel_type_code      => l_rel_type_code    ,
                                 p_rel_rule_id        => l_rel_rule_id      ,
                                 p_origin_object_type => l_object_type      ,
                                 p_dest_object_type   => 'I'                ,
                                 p_origin_object_id   => l_object_id        ,
                                 p_dest_object_id     => p_inventory_item_id,
      /*Bug 3001591*/            p_organization_id    => L_ORGANIZATION_ID);
      ELSE
      Insert_Related_Items_Rows( p_rel_type_code      => l_rel_type_code    ,
                                 p_rel_rule_id        => l_rel_rule_id      ,
                                 p_origin_object_type => l_object_type      ,
                                 p_dest_object_type   => 'I'                ,
                                 p_origin_object_id   => l_object_id        ,
                                 p_dest_object_id     => p_inventory_item_id,
      /*Bug 2922902*/            p_organization_id    => p_organization_id);
	 END IF;
   END LOOP;
   CLOSE l_rel_rule_csr;

END Item_Section_Inserted;


PROCEDURE Item_Category_Deleted(
   p_category_id       IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_organization_id   IN NUMBER DEFAULT NULL) --Bug 2922902,3001591
IS
   TYPE rel_rule_csr_type IS REF CURSOR;
   l_rel_rule_csr         rel_rule_csr_type;
   l_relation_type_code   VARCHAR2(30);
   l_rel_rule_id          NUMBER(15);
BEGIN
   -- 1. Work on the rules where origin_type is Category
   --    origin_object_id is p_category_id
   OPEN l_rel_rule_csr FOR 'SELECT relation_type_code, ' ||
                                  'relation_rule_id ' ||
                           'FROM ibe_ct_relation_rules ' ||
                           'WHERE origin_object_type = ''C'' ' ||
                             'AND origin_object_id = :category_id '
                       USING p_category_id;
   LOOP
      FETCH l_rel_rule_csr INTO l_relation_type_code,
                                l_rel_rule_id;
      EXIT WHEN l_rel_rule_csr%NOTFOUND;

      -- Delete all the related items created by the rule
      -- affected by the given category and deleted item
	 IF (p_organization_id IS NULL) THEN
        DELETE IBE_CT_RELATED_ITEMS
        WHERE relation_type_code = l_relation_type_code
          AND relation_rule_id   = l_rel_rule_id
          AND inventory_item_id  = p_inventory_item_id
	     AND organization_id = L_ORGANIZATION_ID; --Bug 3001591
      ELSE
        DELETE IBE_CT_RELATED_ITEMS
        WHERE relation_type_code = l_relation_type_code
          AND relation_rule_id   = l_rel_rule_id
          AND inventory_item_id  = p_inventory_item_id
	     AND organization_id = p_organization_id; --Bug 2922902
	 END IF;
   END LOOP;

   CLOSE l_rel_rule_csr;

   -- 2. Work on the rules where dest_type is Category
   --    dest_object_id is p_category_id
   OPEN l_rel_rule_csr FOR 'SELECT relation_type_code, ' ||
                                  'relation_rule_id ' ||
                           'FROM ibe_ct_relation_rules ' ||
                           'WHERE dest_object_type = ''C'' ' ||
                             'AND dest_object_id = :category_id '
                       USING p_category_id;

   LOOP
      FETCH l_rel_rule_csr INTO l_relation_type_code,
                                l_rel_rule_id;
      EXIT WHEN l_rel_rule_csr%NOTFOUND;

      -- Delete all the related items created by the rule
      -- affected by the given category and deleted item
	 IF (p_organization_id IS NULL) THEN
        DELETE IBE_CT_RELATED_ITEMS
        WHERE relation_type_code = l_relation_type_code
          AND relation_rule_id   = l_rel_rule_id
          AND related_item_id    = p_inventory_item_id
	     AND organization_id    = L_ORGANIZATION_ID; --Bug 3001591
      ELSE
        DELETE IBE_CT_RELATED_ITEMS
        WHERE relation_type_code = l_relation_type_code
          AND relation_rule_id   = l_rel_rule_id
          AND related_item_id    = p_inventory_item_id
	     AND organization_id    = p_organization_id; --Bug 2922902
	 END IF;
   END LOOP;

   CLOSE l_rel_rule_csr;

   Remove_Invalid_Exclusions();
END Item_Category_Deleted;


PROCEDURE Item_Section_Deleted(
   p_section_id        IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_organization_id   IN NUMBER DEFAULT NULL)  --Bug 2922902,3001591
IS
   TYPE rel_rule_csr_type IS REF CURSOR;
   l_rel_rule_csr       rel_rule_csr_type;
   l_relation_type_code VARCHAR2(30);
   l_rel_rule_id        NUMBER(15);
BEGIN
   -- 1. Work on the rules where origin_type is Section
   --    origin_object_id is p_section_id
   OPEN l_rel_rule_csr FOR 'SELECT relation_type_code, '||
                                  'relation_rule_id ' ||
                           'FROM ibe_ct_relation_rules ' ||
                           'WHERE origin_object_type = ''S'' ' ||
                             'AND origin_object_id = :section_id ' ||
                             'AND relation_type_code <> ''AUTOPLACEMENT'' '
                       USING p_section_id;

   LOOP
      FETCH l_rel_rule_csr INTO l_relation_type_code,
                                l_rel_rule_id;
      EXIT WHEN l_rel_rule_csr%NOTFOUND;

      -- Delete all the related items created by the rule
      -- affected by the given section and deleted item
	 IF (p_organization_id IS NULL) THEN
        DELETE IBE_CT_RELATED_ITEMS
        WHERE relation_type_code = l_relation_type_code
          AND relation_rule_id  = l_rel_rule_id
          AND inventory_item_id = p_inventory_item_id
	     AND organization_id  = L_ORGANIZATION_ID; --Bug 3001591
      ELSE
        DELETE IBE_CT_RELATED_ITEMS
        WHERE relation_type_code = l_relation_type_code
          AND relation_rule_id  = l_rel_rule_id
          AND inventory_item_id = p_inventory_item_id
	     AND organization_id  = p_organization_id; --Bug 2922902
	 END IF;
   END LOOP;
   CLOSE l_rel_rule_csr;

   -- 2. Work on the rules where dest_type is Section
   --    dest_object_id is p_section_id
   OPEN l_rel_rule_csr FOR 'SELECT relation_type_code, ' ||
                                  'relation_rule_id ' ||
                           'FROM ibe_ct_relation_rules ' ||
                           'WHERE dest_object_type = ''S'' ' ||
                             'AND dest_object_id = :section_id '
                       USING p_section_id;

   LOOP
      FETCH l_rel_rule_csr INTO l_relation_type_code,
                                l_rel_rule_id;
      EXIT WHEN l_rel_rule_csr%NOTFOUND;

      -- Delete all the related items created by the rule
      -- affected by the given category and deleted item
	 IF (p_organization_id IS NULL) THEN
        DELETE IBE_CT_RELATED_ITEMS
        WHERE relation_type_code = l_relation_type_code
          AND relation_rule_id = l_rel_rule_id
          AND related_item_id  = p_inventory_item_id
	     AND organization_id  = L_ORGANIZATION_ID; --Bug 3001591
      ELSE
        DELETE IBE_CT_RELATED_ITEMS
        WHERE relation_type_code = l_relation_type_code
          AND relation_rule_id = l_rel_rule_id
          AND related_item_id  = p_inventory_item_id
	     AND organization_id  = p_organization_id; --Bug 2922902
	 END IF;
   END LOOP;

   CLOSE l_rel_rule_csr;

   Remove_Invalid_Exclusions();
END Item_Section_Deleted;


PROCEDURE Category_Deleted(
   p_category_id IN NUMBER)
IS
BEGIN
   -- 1. Delete all the rules where origin_object_type is Category
   --    and origin_object_id is p_section_id
   DELETE IBE_CT_RELATION_RULES
    WHERE origin_object_type = 'C'
      AND origin_object_id  = p_category_id;

   -- 2. Delete all the rules where dest_object_type is Category
   --    and dest_object_id is p_section_id
   DELETE IBE_CT_RELATION_RULES
    WHERE dest_object_type = 'C'
      AND dest_object_id  = p_category_id;
END Category_Deleted;


PROCEDURE Section_Deleted(p_section_id IN NUMBER)
IS
BEGIN
   -- 1. Delete all the rules where origin_object_type is Section
   --    and origin_object_id is p_section_id
   DELETE IBE_CT_RELATION_RULES
    WHERE origin_object_type = 'S'
      AND origin_object_id  = p_section_id;

   -- 2. Delete all the rules where dest_object_type is Section
   --    and dest_object_id is p_section_id
   DELETE IBE_CT_RELATION_RULES
    WHERE dest_object_type = 'S'
      AND dest_object_id  = p_section_id;
END Section_Deleted;


PROCEDURE Item_Inserted(p_inventory_item_id IN NUMBER)
IS
BEGIN
   NULL;
END Item_Inserted;


PROCEDURE Item_Deleted(
   p_organization_id   IN NUMBER,
   p_inventory_item_id IN NUMBER
)
IS
BEGIN
   -- 1. Remove all the rules that have the deleted item
   --    as an origin object
   DELETE
   FROM ibe_ct_relation_rules
   WHERE origin_object_type = 'I'
     AND origin_object_id   = p_inventory_item_id;

   -- 2. Remove all the rules that have the deleted item
   --    as a destination object
   DELETE
   FROM ibe_ct_relation_rules
   WHERE dest_object_type = 'I'
     AND dest_object_id   = p_inventory_item_id;

   -- 3. Remove all the rows in Related Items table
   --    that have the deleted item as inventory item
   DELETE
   FROM IBE_CT_RELATED_ITEMS
   WHERE inventory_item_id = p_inventory_item_id
     AND organization_id   = p_organization_id;

   -- 4. Remove all the rows in Related Items table
   --    that have the deleted item as related item
   DELETE
   FROM IBE_CT_RELATED_ITEMS
   WHERE related_item_id = p_inventory_item_id
     AND organization_id = p_organization_id;

   Remove_Invalid_Exclusions();
END Item_Deleted;

END IBE_Prod_Relation_PVT;

/
