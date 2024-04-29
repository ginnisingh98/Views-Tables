--------------------------------------------------------
--  DDL for Package Body CN_SRP_ROLLOVER_QUOTA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SRP_ROLLOVER_QUOTA_PVT" AS
  /*$Header: cnvsrb.pls 115.1 2002/12/04 02:36:49 fting noship $*/

G_PKG_NAME                  CONSTANT VARCHAR2(30):='CN_SRP_ROLLOVER_QUOTA_PVT';

-- Start of comments
--      API name        : Update_Srp_Rollover_Quota
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
-- End of comments
PROCEDURE Update_Srp_Rollover_Quota
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_srp_rollover_quota          IN      srp_rollover_quota_rec_type,
   x_return_status               OUT NOCOPY    VARCHAR2,
   x_msg_count                   OUT NOCOPY    NUMBER,
   x_msg_data                    OUT NOCOPY    VARCHAR2
 ) IS

     l_api_name           CONSTANT VARCHAR2(30)  := 'Update_Srp_Rollover_Quota';
     l_api_version        CONSTANT NUMBER        := 1.0;

     CURSOR l_old_srp_rollover_quota_cr IS
	SELECT *
	  FROM cn_srp_rollover_quotas
	  WHERE srp_rollover_quota_id = p_srp_rollover_quota.srp_rollover_quota_id;

     l_old_srp_rollover_quota      l_old_srp_rollover_quota_cr%ROWTYPE;
     l_srp_rollover_quota          srp_rollover_quota_rec_type;
     l_temp_count            NUMBER;
     l_start_date            DATE;
     l_end_date              DATE;


     l_loading_status        varchar2(50);

     l_srp_rollover_quota_id         NUMBER := NULL;
     l_rollover         NUMBER := NULL;
     l_customized_flag               cn_srp_quota_assigns.customized_flag%type;


     l_attribute_category    cn_srp_rollover_quotas.attribute_category%TYPE;
     l_attribute1            cn_srp_rollover_quotas.attribute1%TYPE;
     l_attribute2            cn_srp_rollover_quotas.attribute2%TYPE;
     l_attribute3            cn_srp_rollover_quotas.attribute3%TYPE;
     l_attribute4            cn_srp_rollover_quotas.attribute4%TYPE;
     l_attribute5            cn_srp_rollover_quotas.attribute5%TYPE;
     l_attribute6            cn_srp_rollover_quotas.attribute6%TYPE;
     l_attribute7            cn_srp_rollover_quotas.attribute7%TYPE;
     l_attribute8            cn_srp_rollover_quotas.attribute8%TYPE;
     l_attribute9            cn_srp_rollover_quotas.attribute9%TYPE;
     l_attribute10            cn_srp_rollover_quotas.attribute10%TYPE;
     l_attribute11            cn_srp_rollover_quotas.attribute11%TYPE;
     l_attribute12            cn_srp_rollover_quotas.attribute12%TYPE;
     l_attribute13            cn_srp_rollover_quotas.attribute13%TYPE;
     l_attribute14            cn_srp_rollover_quotas.attribute14%TYPE;
     l_attribute15            cn_srp_rollover_quotas.attribute15%TYPE;




BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Srp_Rollover_Quota;
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


     -- srp_quota_assign_id cannot be NULL

   IF (p_srp_rollover_quota.srp_rollover_quota_id is NULL) OR
       (p_srp_rollover_quota.srp_rollover_quota_id = fnd_api.g_miss_num)
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
        FND_MESSAGE.SET_TOKEN('INPUT_NAME', 'srp_rollover_quota_id');
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

     -- srp_quota_assign_id cannot be NULL

   IF (p_srp_rollover_quota.srp_quota_assign_id is NULL) OR
       (p_srp_rollover_quota.srp_quota_assign_id = fnd_api.g_miss_num)
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
        FND_MESSAGE.SET_TOKEN('INPUT_NAME', 'srp_quota_assign_id');
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

    -- Quota_Id cannot be NULL

   IF (p_srp_rollover_quota.quota_id is NULL) OR
       (p_srp_rollover_quota.quota_id = fnd_api.g_miss_num)
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
        FND_MESSAGE.SET_TOKEN('INPUT_NAME', cn_api.get_lkup_meaning('PE', 'INPUT_TOKEN'));
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;


   -- Source_Quota_Id cannot be NULL

   IF (p_srp_rollover_quota.source_quota_id is NULL) OR
       (p_srp_rollover_quota.source_quota_id = fnd_api.g_miss_num)
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
        FND_MESSAGE.SET_TOKEN('INPUT_NAME', cn_api.get_lkup_meaning('SPE', 'INPUT_TOKEN'));
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- Rollover cannot be NULL

   IF (p_srp_rollover_quota.rollover is NULL) OR
       (p_srp_rollover_quota.rollover = fnd_api.g_miss_num)
   THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.SET_NAME ('CN' , 'CN_INPUT_CANT_NULL');
        FND_MESSAGE.SET_TOKEN('INPUT_NAME', cn_api.get_lkup_meaning('ROLLPERCENT', 'INPUT_TOKEN'));
	FND_MSG_PUB.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;



   OPEN l_old_srp_rollover_quota_cr;
   FETCH l_old_srp_rollover_quota_cr INTO l_old_srp_rollover_quota;
   CLOSE l_old_srp_rollover_quota_cr;




   -- 3. check object version number
   IF l_old_srp_rollover_quota.object_version_number <>
                     p_srp_rollover_quota.object_version_number THEN
     fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_error;
   END IF;





   SELECT


      Decode(p_srp_rollover_quota.rollover,
	    fnd_api.g_miss_num, l_old_srp_rollover_quota.rollover,
	    p_srp_rollover_quota.rollover),

      Decode(p_srp_rollover_quota.ATTRIBUTE_CATEGORY,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE_CATEGORY),
     Decode(p_srp_rollover_quota.ATTRIBUTE1,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE1),
     Decode(p_srp_rollover_quota.ATTRIBUTE2,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE2),
     Decode(p_srp_rollover_quota.ATTRIBUTE3,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE3),
     Decode(p_srp_rollover_quota.ATTRIBUTE4,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE4),
     Decode(p_srp_rollover_quota.ATTRIBUTE5,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE5),
     Decode(p_srp_rollover_quota.ATTRIBUTE6,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE6),
     Decode(p_srp_rollover_quota.ATTRIBUTE7,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE7),
     Decode(p_srp_rollover_quota.ATTRIBUTE8,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE8),
     Decode(p_srp_rollover_quota.ATTRIBUTE9,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE9),
     Decode(p_srp_rollover_quota.ATTRIBUTE10,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE10),
     Decode(p_srp_rollover_quota.ATTRIBUTE11,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE11),
     Decode(p_srp_rollover_quota.ATTRIBUTE12,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE12),
     Decode(p_srp_rollover_quota.ATTRIBUTE13,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE13),
     Decode(p_srp_rollover_quota.ATTRIBUTE14,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE14),
     Decode(p_srp_rollover_quota.ATTRIBUTE15,
	    fnd_api.g_miss_char, NULL,
	    p_srp_rollover_quota.ATTRIBUTE15)

   INTO
      l_rollover,
     l_attribute_category,
     l_attribute1,
     l_attribute2,
     l_attribute3,
     l_attribute4,
     l_attribute5,
     l_attribute6,
     l_attribute7,
     l_attribute8,
     l_attribute9,
     l_attribute10,
     l_attribute11,
     l_attribute12,
     l_attribute13,
     l_attribute14,
     l_attribute15
    FROM dual;


    IF l_rollover <> l_old_srp_rollover_quota.rollover THEN

     select customized_flag
     into l_customized_flag
     from cn_srp_quota_assigns
     where srp_quota_assign_id = p_srp_rollover_quota.srp_quota_assign_id;


     IF l_customized_flag = 'Y' THEN



   CN_SRP_ROLLOVER_QUOTAS_PKG.UPDATE_ROW (
   X_SRP_ROLLOVER_QUOTA_ID => p_srp_rollover_quota.srp_rollover_quota_id,
   X_SRP_QUOTA_ASSIGN_ID => p_srp_rollover_quota.srp_quota_assign_id,
   X_ROLLOVER_QUOTA_ID => p_srp_rollover_quota.rollover_quota_id,
   X_QUOTA_ID => p_srp_rollover_quota.quota_id,
   X_SOURCE_QUOTA_ID => p_srp_rollover_quota.source_quota_id,
   X_ROLLOVER => l_rollover,
   X_ATTRIBUTE_CATEGORY => l_attribute_category,
   X_ATTRIBUTE1 => l_attribute1,
   X_ATTRIBUTE2 => l_attribute2,
   X_ATTRIBUTE3 => l_attribute3,
   X_ATTRIBUTE4 => l_attribute4,
   X_ATTRIBUTE5 => l_attribute5,
   X_ATTRIBUTE6 => l_attribute6,
   X_ATTRIBUTE7 => l_attribute7,
   X_ATTRIBUTE8 => l_attribute8,
   X_ATTRIBUTE9 => l_attribute9,
   X_ATTRIBUTE10 => l_attribute10,
   X_ATTRIBUTE11 => l_attribute11,
   X_ATTRIBUTE12 => l_attribute12,
   X_ATTRIBUTE13 => l_attribute13,
   X_ATTRIBUTE14 => l_attribute14,
   X_ATTRIBUTE15 => l_attribute15,
   X_CREATED_BY => fnd_global.user_id,
   X_CREATION_DATE => sysdate,
   X_LAST_UPDATE_DATE => sysdate,
   X_LAST_UPDATED_BY => fnd_global.user_id,
   X_LAST_UPDATE_LOGIN => fnd_global.login_id
   );
   END IF; -- if customize_flag = 'Y'

 END IF; -- l_rollover is changed


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
     ROLLBACK TO Update_Srp_Rollover_Quota;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Srp_Rollover_Quota;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO Update_Srp_Rollover_Quota;
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
END Update_Srp_Rollover_Quota;




END CN_SRP_ROLLOVER_QUOTA_PVT;

/
