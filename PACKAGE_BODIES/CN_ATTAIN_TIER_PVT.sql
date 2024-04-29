--------------------------------------------------------
--  DDL for Package Body CN_ATTAIN_TIER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ATTAIN_TIER_PVT" AS
  /*$Header: cnvattrb.pls 115.4 2002/11/21 21:11:39 hlchen ship $*/

G_PKG_NAME                  CONSTANT VARCHAR2(30):='CN_ATTAIN_TIER_PVT';

-- Start of comments
--    API name        : Create_Attain_Tier
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
--                      p_attain_tier	      IN  attain_tier_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
PROCEDURE Create_Attain_Tier
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_attain_tier                 IN      attain_tier_rec_type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2
 ) IS

     G_LAST_UPDATE_DATE          DATE := Sysdate;
     G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
     G_CREATION_DATE             DATE := Sysdate;
     G_CREATED_BY                NUMBER := fnd_global.user_id;
     G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;
     G_ROWID                     VARCHAR2(30);

     l_api_name         CONSTANT VARCHAR2(30) := 'Create_Attain_Tier';
     l_api_version      CONSTANT NUMBER       := 1.0;

     l_attain_tier_id    NUMBER;
     l_current_seq      NUMBER;
     l_assign_seq       NUMBER;
     l_temp_count       NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Create_Attain_Tier;
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

   IF ( p_attain_tier.attain_schedule_id is NULL ) OR
      ( p_attain_tier.percent is NULL )
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
	FND_MESSAGE.SET_TOKEN('INPUT_NAME',
              'Attain Schedule, Attain Tier or Percentage Amount');
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- same role quota category is not allowed to be
   -- assigned twice
   SELECT count(1)
     INTO l_temp_count
     FROM cn_attain_tiers
    WHERE attain_schedule_id = p_attain_tier.attain_schedule_id
      AND percent = p_attain_tier.percent
        ;

   IF l_temp_count > 0 THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_ASSIGN_CANT_SAME');
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF p_attain_tier.percent < 0 THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_INPUT');
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   select cn_role_quota_formulas_s.nextval
     into l_attain_tier_id
     from dual;

   CN_ATTAIN_TIERS_PKG.INSERT_ROW
   (
    X_ROWID => G_ROWID,
    X_ATTAIN_TIER_ID => l_attain_tier_id,
    X_ATTAIN_SCHEDULE_ID => p_attain_tier.ATTAIN_SCHEDULE_ID,
    X_PERCENT => p_attain_tier.PERCENT,
    X_ATTRIBUTE_CATEGORY => p_attain_tier.ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1 => p_attain_tier.ATTRIBUTE1,
    X_ATTRIBUTE2 => p_attain_tier.ATTRIBUTE2,
    X_ATTRIBUTE3 => p_attain_tier.ATTRIBUTE3,
    X_ATTRIBUTE4 => p_attain_tier.ATTRIBUTE4,
    X_ATTRIBUTE5 => p_attain_tier.ATTRIBUTE5,
    X_ATTRIBUTE6 => p_attain_tier.ATTRIBUTE6,
    X_ATTRIBUTE7 => p_attain_tier.ATTRIBUTE7,
    X_ATTRIBUTE8 => p_attain_tier.ATTRIBUTE8,
    X_ATTRIBUTE9 => p_attain_tier.ATTRIBUTE9,
    X_ATTRIBUTE10 => p_attain_tier.ATTRIBUTE10,
    X_ATTRIBUTE11 => p_attain_tier.ATTRIBUTE11,
    X_ATTRIBUTE12 => p_attain_tier.ATTRIBUTE12,
    X_ATTRIBUTE13 => p_attain_tier.ATTRIBUTE13,
    X_ATTRIBUTE14 => p_attain_tier.ATTRIBUTE14,
    X_ATTRIBUTE15 => p_attain_tier.ATTRIBUTE15,
    X_OBJECT_VERSION_NUMBER => 1,
    X_CREATION_DATE => G_CREATION_DATE,
    X_CREATED_BY => G_CREATED_BY,
    X_LAST_UPDATE_DATE => G_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY => G_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN => G_LAST_UPDATE_LOGIN
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
     ROLLBACK TO Create_Attain_Tier;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Attain_Tier;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Create_Attain_Tier;
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
END Create_Attain_Tier;


-- Start of comments
--      API name        : Update_Attain_Tier
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_attain_tier        IN  attain_tier_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Update_Attain_Tier
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_attain_tier                 IN      attain_tier_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2
 ) IS

     G_LAST_UPDATE_DATE          DATE := Sysdate;
     G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
     G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;
     G_ROWID                     VARCHAR2(30);

     l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Attain_Tier';
     l_api_version        CONSTANT NUMBER        := 1.0;

     l_temp_count         NUMBER;

     CURSOR l_old_attain_tier_cr IS
	SELECT *
	  FROM cn_attain_tiers
	  WHERE attain_tier_id = p_attain_tier.attain_tier_id;

     l_old_attain_tier         l_old_attain_tier_cr%ROWTYPE;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Attain_Tier;
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

   IF ( p_attain_tier.attain_tier_id is NULL ) OR
      ( p_attain_tier.attain_schedule_id is NULL ) OR
      ( p_attain_tier.percent is NULL )
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
	FND_MESSAGE.SET_TOKEN('INPUT_NAME',
              'Attain Schedule, Attain Tier or Percentage Amount');
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- same role quota category is not allowed to be
   -- assigned twice
   SELECT count(1)
     INTO l_temp_count
     FROM cn_attain_tiers
    WHERE attain_schedule_id = p_attain_tier.attain_schedule_id
      AND percent = p_attain_tier.percent
      AND attain_tier_id <> p_attain_tier.attain_tier_id;

   IF l_temp_count > 0 THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_ASSIGN_CANT_SAME');
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF p_attain_tier.percent < 0 THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_INPUT');
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   OPEN l_old_attain_tier_cr;
   FETCH l_old_attain_tier_cr INTO l_old_attain_tier;
   CLOSE l_old_attain_tier_cr;

   -- check object version number
   IF l_old_attain_tier.object_version_number <>
                     p_attain_tier.object_version_number THEN
     fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_error;
   END IF;

   CN_ATTAIN_TIERS_PKG.UPDATE_ROW
   (
    X_ATTAIN_TIER_ID => p_attain_tier.ATTAIN_TIER_ID,
    X_ATTAIN_SCHEDULE_ID => p_attain_tier.ATTAIN_SCHEDULE_ID,
    X_PERCENT => p_attain_tier.PERCENT,
    X_ATTRIBUTE_CATEGORY => p_attain_tier.ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1 => p_attain_tier.ATTRIBUTE1,
    X_ATTRIBUTE2 => p_attain_tier.ATTRIBUTE2,
    X_ATTRIBUTE3 => p_attain_tier.ATTRIBUTE3,
    X_ATTRIBUTE4 => p_attain_tier.ATTRIBUTE4,
    X_ATTRIBUTE5 => p_attain_tier.ATTRIBUTE5,
    X_ATTRIBUTE6 => p_attain_tier.ATTRIBUTE6,
    X_ATTRIBUTE7 => p_attain_tier.ATTRIBUTE7,
    X_ATTRIBUTE8 => p_attain_tier.ATTRIBUTE8,
    X_ATTRIBUTE9 => p_attain_tier.ATTRIBUTE9,
    X_ATTRIBUTE10 => p_attain_tier.ATTRIBUTE10,
    X_ATTRIBUTE11 => p_attain_tier.ATTRIBUTE11,
    X_ATTRIBUTE12 => p_attain_tier.ATTRIBUTE12,
    X_ATTRIBUTE13 => p_attain_tier.ATTRIBUTE13,
    X_ATTRIBUTE14 => p_attain_tier.ATTRIBUTE14,
    X_ATTRIBUTE15 => p_attain_tier.ATTRIBUTE15,
    X_OBJECT_VERSION_NUMBER => p_attain_tier.OBJECT_VERSION_NUMBER+1,
    X_LAST_UPDATE_DATE => G_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY => G_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN => G_LAST_UPDATE_LOGIN
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
     ROLLBACK TO Update_Attain_Tier;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Attain_Tier;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Update_Attain_Tier;
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
END Update_Attain_Tier;


-- Start of comments
--      API name        : Delete_Attain_Tier
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_attain_tier        IN attain_tier_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Delete_Attain_Tier
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_attain_tier                 IN      attain_tier_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2
 ) IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Delete_Attain_Tier';
     l_api_version        CONSTANT NUMBER       := 1.0;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Delete_Attain_Tier;
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

    CN_ATTAIN_TIERS_PKG.DELETE_ROW(
       X_ATTAIN_TIER_ID => p_attain_tier.ATTAIN_TIER_ID);

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
     ROLLBACK TO Delete_Attain_Tier;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Attain_Tier;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Delete_Attain_Tier;
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
END Delete_Attain_Tier;



-- Start of comments
--      API name        : Get_Attain_Tier
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_attain_schedule_id  IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_attain_tier       OUT     attain_tier_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Attain_Tier
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_attain_schedule_id          IN      NUMBER,
   x_attain_tier                 OUT NOCOPY     attain_tier_tbl_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2
 ) IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Get_Attain_Tier';
     l_api_version        CONSTANT NUMBER                 := 1.0;
     l_counter      NUMBER;

     CURSOR l_attain_tier_cr IS
        SELECT *
          FROM cn_attain_tiers
         WHERE attain_schedule_id = p_attain_schedule_id
      ORDER BY percent
             ;

     l_attain_tier  l_attain_tier_cr%ROWTYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Get_Attain_Tier;
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

   l_counter := 1;

   OPEN l_attain_tier_cr;
   LOOP
      FETCH l_attain_tier_cr INTO l_attain_tier;
      EXIT WHEN l_attain_tier_cr%NOTFOUND ;

      x_attain_tier(l_counter).attain_tier_id :=
                                l_attain_tier.attain_tier_id;
      x_attain_tier(l_counter).percent := l_attain_tier.percent;
      x_attain_tier(l_counter).object_version_number :=
                                l_attain_tier.object_version_number;

      l_counter := l_counter +1;

   END LOOP;

   IF l_attain_tier_cr%ROWCOUNT = 0 THEN
      x_attain_tier := G_MISS_ATTAIN_TIER_REC_TB ;
   END IF;

   CLOSE l_attain_tier_cr;

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
     ROLLBACK TO Get_Attain_Tier;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_Attain_Tier;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Get_Attain_Tier;
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
END Get_Attain_Tier;

END CN_ATTAIN_TIER_PVT;

/
