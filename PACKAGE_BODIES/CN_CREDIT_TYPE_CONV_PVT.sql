--------------------------------------------------------
--  DDL for Package Body CN_CREDIT_TYPE_CONV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CREDIT_TYPE_CONV_PVT" AS
  /*$Header: cnvctcnb.pls 115.4 2001/10/29 17:19:24 pkm ship      $*/

G_PKG_NAME         CONSTANT VARCHAR2(30):='CN_CREDIT_TYPE_CONV_PVT';

--{{{ create conversion

-- Start of comments
--    API name        : Create_Conversion
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
--                      p_from_credit_type    IN NUMBER       Required
--                      p_to_credit_type      IN NUMBER       Required
--                      p_conv_factor         IN NUMBER       Required
--                      p_start_date          IN DATE         Required
--                      p_end_date            IN DATE         Required
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count                     OUT     NUMBER
--                      x_msg_data                      OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Create_Conversion
(p_api_version        IN  number,
 p_init_msg_list      IN  varchar2 := FND_API.G_FALSE,
p_commit              IN  varchar2 := FND_API.G_FALSE,
p_validation_level    IN  number  := FND_API.G_VALID_LEVEL_FULL,
p_from_credit_type    IN  number,
p_to_credit_type      IN  number,
p_conv_factor         IN  number,
p_start_date          IN  date,
p_end_date            IN  date,
x_return_status       OUT varchar2,
x_msg_count           OUT number,
x_msg_data            OUT varchar2) is
   G_LAST_UPDATE_DATE          DATE := Sysdate;
   G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
   G_CREATION_DATE             DATE := Sysdate;
   G_CREATED_BY                NUMBER := fnd_global.user_id;
   G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;
   l_api_name  CONSTANT VARCHAR2(30) := 'Create_Conversion';
   l_api_version  CONSTANT NUMBER                 := 1.0;

   l_conv_id  number;
   l_loading_status  varchar2(80);
   CURSOR l_similar_conv_csr IS
     SELECT from_credit_type_id, to_credit_type_id, start_date, end_date
       FROM cn_credit_conv_fcts
       WHERE from_credit_type_id = p_from_credit_type
       AND to_credit_type_id = p_to_credit_type;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   create_conversion_pvt;
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
   IF (cn_api.invalid_date_range(p_start_date, p_end_date,
     FND_API.G_TRUE, l_loading_status, l_loading_status,  FND_API.G_TRUE)
     <> FND_API.G_FALSE) THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   FOR eachrow in l_similar_conv_csr LOOP
      IF (cn_api.date_range_overlap(p_start_date, p_end_date,
        eachrow.start_date, eachrow.end_date)) THEN
         fnd_message.set_name('CN', 'CN_CTC_DATE_OVERLAP');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;
   END LOOP;

   if (p_from_credit_type = p_to_credit_type) then
      fnd_message.set_name('CN', 'CN_CTC_SAME_ERR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   end if;

   IF (p_conv_factor < 0) THEN
      fnd_message.set_name('CN', 'CN_CTC_NEG_CONV_ERR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   SELECT cn_credit_conv_fcts_s.nextval
     INTO l_conv_id
     FROM dual;

   CN_CREDIT_CONV_FCTS_PKG.Insert_Row(
     x_credit_conv_fct_id  =>  l_conv_id,
     x_from_credit_type_id =>  p_from_credit_type,
     x_to_credit_type_id   =>  p_to_credit_type,
     x_conversion_factor   =>  p_conv_factor,
     x_start_date          =>  p_start_date,
     x_end_date            =>  p_end_date,
     x_created_by          =>  g_created_by,
     x_creation_date       =>  g_creation_date,
     x_last_update_login   =>  g_last_update_login,
     x_last_update_date    =>  g_last_update_date,
     x_last_updated_by     =>  g_last_updated_by);

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
     ROLLBACK TO create_conversion_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_conversion_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO create_conversion_pvt;
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
END Create_Conversion;

--}}}

--{{{ update conversion

-- Start of comments
--      API name        : Update_Conversion
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
--                        p_object_version      IN NUMBER       Required
--                        p_conv_id             IN NUMBER       Required
--                        p_from_credit_type    IN NUMBER       Required
--                        p_to_credit_type      IN NUMBER       Required
--                        p_conv_factor         IN NUMBER       Required
--                        p_start_date          IN DATE         Required
--                        p_end_date            IN DATE         Required
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version       x.x
--                              Changed....
--                        Previous version      y.y
--                              Changed....
--                        .
--                        .
--                        Previous version      2.0
--                              Changed....
--                        Initial version       1.0
--
--      Notes           : Note text
--
-- End of comments
PROCEDURE Update_Conversion
(p_api_version        IN  number,
 p_init_msg_list      IN  varchar2 := FND_API.G_FALSE,
p_commit              IN  varchar2 := FND_API.G_FALSE,
p_validation_level    IN  number  := FND_API.G_VALID_LEVEL_FULL,
p_object_version      IN  number,
p_conv_id             IN  number,
p_from_credit_type    IN  number,
p_to_credit_type      IN  number,
p_conv_factor         IN  number,
p_start_date          IN  date,
p_end_date            IN  date,
x_return_status       OUT varchar2,
x_msg_count           OUT number,
x_msg_data            OUT varchar2) is
   G_LAST_UPDATE_DATE          DATE := Sysdate;
   G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
   G_CREATION_DATE             DATE := Sysdate;
   G_CREATED_BY                NUMBER := fnd_global.user_id;
   G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;
   l_api_name                      CONSTANT VARCHAR2(30)
     := 'Update_Conversion';
   l_api_version                   CONSTANT NUMBER                 := 1.0;
   l_object_version  number := 0;
   l_loading_status  varchar2(80);

   CURSOR l_ovn_csr IS
     SELECT object_version_number
       FROM cn_credit_conv_fcts
       WHERE credit_conv_fct_id = p_conv_id;

   CURSOR l_similar_conv_csr IS
     SELECT from_credit_type_id, to_credit_type_id, start_date, end_date
       FROM cn_credit_conv_fcts
       WHERE from_credit_type_id = p_from_credit_type
       AND to_credit_type_id = p_to_credit_type
       AND credit_conv_fct_id <> p_conv_id;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   update_conversion_pvt;
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
   OPEN l_ovn_csr;
   FETCH l_ovn_csr INTO l_object_version;
   close l_ovn_csr;

   IF (l_object_version <> p_object_version) THEN
      fnd_message.set_name('CN', 'CN_INVALID_OBJECT_VERSION');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   IF (cn_api.invalid_date_range(p_start_date, p_end_date,
     FND_API.G_TRUE, l_loading_status, l_loading_status,  FND_API.G_TRUE)
     <> FND_API.G_FALSE) THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   FOR eachrow in l_similar_conv_csr LOOP
      IF (cn_api.date_range_overlap(p_start_date, p_end_date,
        eachrow.start_date, eachrow.end_date)) THEN
         fnd_message.set_name('CN', 'CN_CTC_DATE_OVERLAP');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;
   END LOOP;

   if (p_from_credit_type = p_to_credit_type) then
      fnd_message.set_name('CN', 'CN_CTC_SAME_ERR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   end if;

   IF (p_conv_factor < 0) THEN
      fnd_message.set_name('CN', 'CN_CTC_NEG_CONV_ERR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   CN_CREDIT_CONV_FCTS_PKG.Update_Row(
     x_credit_conv_fct_id  =>  p_conv_id,
     x_object_version       =>  p_object_version,
     x_from_credit_type_id =>  p_from_credit_type,
     x_to_credit_type_id   =>  p_to_credit_type,
     x_conversion_factor   =>  p_conv_factor,
     x_start_date          =>  p_start_date,
     x_end_date            =>  p_end_date,
     x_created_by          =>  g_created_by,
     x_creation_date       =>  g_creation_date,
     x_last_update_login   =>  g_last_update_login,
     x_last_update_date    =>  g_last_update_date,
     x_last_updated_by     =>  g_last_updated_by);
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
     ROLLBACK TO update_conversion_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_conversion_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO update_conversion_pvt;
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
END Update_Conversion;

--}}}

--{{{ delete conversion

-- Start of comments
--      API name        : Delete_Conversion
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
--                        p_object_version    IN NUMBER       Required
--                        p_conv_id           IN NUMBER       Required
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version       x.x
--                              Changed....
--                        Previous version      y.y
--                              Changed....
--                        .
--                        .
--                        Previous version      2.0
--                              Changed....
--                        Initial version       1.0
--
--      Notes           : Note text
--
-- End of comments
PROCEDURE Delete_Conversion
(p_api_version        IN  number,
 p_init_msg_list      IN  varchar2 := FND_API.G_FALSE,
p_commit              IN  varchar2 := FND_API.G_FALSE,
p_validation_level    IN  number  := FND_API.G_VALID_LEVEL_FULL,
p_object_version      IN  number,
p_conv_id             IN  number,
x_return_status       OUT varchar2,
x_msg_count           OUT number,
x_msg_data            OUT varchar2) is
   G_LAST_UPDATE_DATE          DATE := Sysdate;
   G_LAST_UPDATED_BY           NUMBER := fnd_global.user_id;
   G_CREATION_DATE             DATE := Sysdate;
   G_CREATED_BY                NUMBER := fnd_global.user_id;
   G_LAST_UPDATE_LOGIN         NUMBER := fnd_global.login_id;
   l_api_name                      CONSTANT VARCHAR2(30)
     := 'Delete_Conversion';
   l_api_version                   CONSTANT NUMBER                 := 1.0;
   l_object_version  number := 0;
   CURSOR l_ovn_csr IS
     SELECT object_version_number
       FROM cn_credit_conv_fcts
       WHERE credit_conv_fct_id = p_conv_id;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   delete_conversion_pvt;
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
   OPEN l_ovn_csr;
   FETCH l_ovn_csr INTO l_object_version;
   close l_ovn_csr;

   IF (l_object_version <> p_object_version) THEN
      fnd_message.set_name('CN', 'CN_INVALID_OBJECT_VERSION');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   CN_CREDIT_CONV_FCTS_PKG.Delete_Row(x_credit_conv_fct_id  =>  p_conv_id);

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
     ROLLBACK TO delete_conversion_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO delete_conversion_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get
       (p_count                 =>      x_msg_count             ,
       p_data                   =>      x_msg_data              ,
       p_encoded                =>      FND_API.G_FALSE         );
   WHEN OTHERS THEN
     ROLLBACK TO delete_conversion_pvt;
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
END Delete_Conversion;

--}}}

END CN_CREDIT_TYPE_CONV_PVT;

/
