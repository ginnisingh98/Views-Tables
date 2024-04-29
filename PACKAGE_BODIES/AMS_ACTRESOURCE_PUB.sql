--------------------------------------------------------
--  DDL for Package Body AMS_ACTRESOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTRESOURCE_PUB" as
 /*$Header: amsprscb.pls 115.4 2002/12/11 03:42:02 ptendulk ship $*/

/*****************************************************************************************/
-- NAME
--   AMS_ActResource_PUB
--
-- HISTORY
-- 04/02/2002    gmadana    CREATED
/*****************************************************************************************/

G_PACKAGE_NAME   CONSTANT   VARCHAR2(30)   :='AMS_ActResource_PUB';
G_FILE_NAME      CONSTANT   VARCHAR2(12)   :='amsprscb.pls';

-- Debug mode
g_debug boolean := FALSE;
g_debug boolean := TRUE;
--

PROCEDURE Convert_PubRec_To_PvtRec(
   p_act_Resource_rec_pub      IN   Act_Resource_rec_type,
   x_act_Resource_rec_pvt      OUT NOCOPY  AMS_ActResource_PVT.Act_Resource_rec_type

)

IS
   l_act_Resource_rec_pub      Act_Resource_rec_type := p_act_Resource_rec_pub;

BEGIN

       x_act_resource_rec_pvt.activity_resource_id           :=  l_act_resource_rec_pub.activity_resource_id;
       x_act_resource_rec_pvt.last_update_date               :=  l_act_resource_rec_pub.last_update_date;
       x_act_resource_rec_pvt.last_updated_by                :=  l_act_resource_rec_pub.last_updated_by ;
       x_act_resource_rec_pvt.creation_date                  :=  l_act_resource_rec_pub.creation_date;
       x_act_resource_rec_pvt.created_by                     :=  l_act_resource_rec_pub.created_by;
       x_act_resource_rec_pvt.last_update_login              :=  l_act_resource_rec_pub.last_update_login;
       x_act_resource_rec_pvt.object_version_number          :=  l_act_resource_rec_pub.object_version_number;
       x_act_resource_rec_pvt.act_resource_used_by_id        :=  l_act_resource_rec_pub.act_resource_used_by_id;
       x_act_resource_rec_pvt.arc_act_resource_used_by       :=  l_act_resource_rec_pub.arc_act_resource_used_by;
       x_act_resource_rec_pvt.resource_id                    :=  l_act_resource_rec_pub.resource_id;
       x_act_resource_rec_pvt.role_cd                        :=  l_act_resource_rec_pub.role_cd;
       x_act_resource_rec_pvt.user_status_id                 :=  l_act_resource_rec_pub.user_status_id;
       x_act_resource_rec_pvt.system_status_code             :=  l_act_resource_rec_pub.system_status_code;
       x_act_resource_rec_pvt.start_date_time                :=  l_act_resource_rec_pub.start_date_time;
       x_act_resource_rec_pvt.end_date_time                  :=  l_act_resource_rec_pub.end_date_time;
       x_act_resource_rec_pvt.primary_flag                   :=  l_act_resource_rec_pub.primary_flag;
       x_act_resource_rec_pvt.description                    :=  l_act_resource_rec_pub.description;
       x_act_resource_rec_pvt.attribute_category             :=  l_act_resource_rec_pub.attribute_category;
       x_act_resource_rec_pvt.attribute1                     :=  l_act_resource_rec_pub.attribute1;
       x_act_resource_rec_pvt.attribute2                     :=  l_act_resource_rec_pub.attribute2;
       x_act_resource_rec_pvt.attribute3                     :=  l_act_resource_rec_pub.attribute3;
       x_act_resource_rec_pvt.attribute4                     :=  l_act_resource_rec_pub.attribute4;
       x_act_resource_rec_pvt.attribute5                     :=  l_act_resource_rec_pub.attribute5;
       x_act_resource_rec_pvt.attribute6                     :=  l_act_resource_rec_pub.attribute6;
       x_act_resource_rec_pvt.attribute7                     :=  l_act_resource_rec_pub.attribute7;
       x_act_resource_rec_pvt.attribute8                     :=  l_act_resource_rec_pub.attribute8;
       x_act_resource_rec_pvt.attribute9                     :=  l_act_resource_rec_pub.attribute9;
       x_act_resource_rec_pvt.attribute10                    :=  l_act_resource_rec_pub.attribute10;
       x_act_resource_rec_pvt.attribute11                    :=  l_act_resource_rec_pub.attribute11;
       x_act_resource_rec_pvt.attribute12                    :=  l_act_resource_rec_pub.attribute12;
       x_act_resource_rec_pvt.attribute13                    :=  l_act_resource_rec_pub.attribute13;
       x_act_resource_rec_pvt.attribute14                    :=  l_act_resource_rec_pub.attribute14;
       x_act_resource_rec_pvt.attribute15                    :=  l_act_resource_rec_pub.attribute15;

END;

-- Procedure and function declarations.
/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Create_Act_Resource
--
-- PURPOSE
--   This procedure is to create a Resource record that satisfy caller needs
--
-- HISTORY
--   04/02/2002       gmadana            created
--
/*****************************************************************************************/

PROCEDURE Create_Act_Resource
( p_api_version      IN     NUMBER,
  p_init_msg_list    IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit           IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY    VARCHAR2,
  x_msg_count        OUT NOCOPY    NUMBER,
  x_msg_data         OUT NOCOPY    VARCHAR2,
  p_act_Resource_rec IN     act_Resource_rec_type,
  x_act_resource_id  OUT NOCOPY    NUMBER
) IS

   l_api_name      CONSTANT VARCHAR2(30)     := 'Create_Act_Resource';
   l_api_version   CONSTANT NUMBER           := 1.0;
   l_full_name     CONSTANT VARCHAR2(60)     := G_PACKAGE_NAME || '.' || l_api_name;
   l_return_status VARCHAR2(1);

   --l_msg_count          NUMBER;
   --l_msg_data           VARCHAR2(60);


   l_pvt_resource_rec    AMS_ActResource_PVT.Act_Resource_rec_type ;
   l_pub_resource_rec     Act_Resource_rec_type := p_act_Resource_rec;

    BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Act_Resource_PUB;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- convert public parameter to private-type
      Convert_PubRec_To_PvtRec(l_pub_resource_rec,l_pvt_resource_rec);

      -- customer pre-processing
      IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'B', 'C')
         THEN
            AMS_ActResource_CUHK.create_resource_pre(
            l_pub_resource_rec,
            l_return_status
           );

         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'B', 'V')
   THEN
      AMS_ActResource_VUHK.create_resource_pre(
         l_pub_resource_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;


   -- call business API
   -- Calling Private package: Create_Act_Resource
   -- Hint: Primary key needs to be returned
     AMS_ActResource_PVT.Create_Act_Resource(
         p_api_version                => 1.0,
         p_init_msg_list              => p_init_msg_list,
         p_commit                     => p_commit,
         p_validation_level           => p_validation_level,
         x_return_status              => x_return_status,
         x_msg_count                  => x_msg_count,
         x_msg_data                   => x_msg_data,
         p_act_Resource_rec           => l_pvt_resource_rec,
         x_act_resource_id            => x_act_resource_id
         );


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body.
      --
 -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'A', 'C')
   THEN
      AMS_ActResource_CUHK.create_resource_post(
         l_pub_resource_rec,
         x_act_resource_id,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'A', 'V')
   THEN
      AMS_ActResource_VUHK.create_resource_post(
         l_pub_resource_rec,
         x_act_resource_id,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;


   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;


   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

EXCEPTION
   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Create_Act_Resource_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Act_Resource_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Act_Resource_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_Act_Resource;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Update_Act_Resource
--
-- PURPOSE
--   This procedure is to update a Resource record that satisfy caller needs
--
-- HISTORY
--   02/20/2002        gmadana            created
--
/*****************************************************************************************/

PROCEDURE Update_Act_Resource
( p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit           IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  p_act_Resource_rec IN  act_Resource_rec_type
) IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Act_Resource';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number  NUMBER;
l_return_status  VARCHAR2(1);

l_pvt_resource_rec    AMS_ActResource_PVT.Act_Resource_rec_type ;
l_pub_resource_rec     Act_Resource_rec_type := p_act_Resource_rec;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Update_Act_Resource_PUB;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- convert public parameter to private-type
      Convert_PubRec_To_PvtRec(l_pub_resource_rec,l_pvt_resource_rec);

    -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'B', 'C')
   THEN
      AMS_ActResource_CUHK.update_resource_pre(
         l_pub_resource_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'B', 'V')
   THEN
      AMS_ActResource_VUHK.update_resource_pre(
         l_pub_resource_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
    AMS_ActResource_PVT.Update_Act_Resource(
       p_api_version                => 1.0,
       p_init_msg_list              => p_init_msg_list,
       p_commit                     => p_commit,
       p_validation_level           => p_validation_level,
       x_return_status              => x_return_status,
       x_msg_count                  => x_msg_count,
       x_msg_data                   => x_msg_data,
       p_Act_Resource_rec           => l_pvt_resource_rec
    );


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body
      --

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'A', 'V')
   THEN
      AMS_ActResource_VUHK.update_resource_post(
         l_pub_resource_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'A', 'C')
   THEN
      AMS_ActResource_CUHK.update_resource_post(
         l_pub_resource_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;


   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Act_Resource_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Act_Resource_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Act_Resource_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Update_Act_Resource;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Delete_Act_Resource
--
-- PURPOSE
--   This procedure is to delete a resource record that satisfy caller needs
--
-- HISTORY
--   02/20/2002        gmadana            created
--
/*****************************************************************************************/

PROCEDURE Delete_Act_Resource
( p_api_version      IN     NUMBER,
  p_init_msg_list    IN     VARCHAR2   := FND_API.G_FALSE,
  p_commit           IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY    VARCHAR2,
  x_msg_count        OUT NOCOPY    NUMBER,
  x_msg_data         OUT NOCOPY    VARCHAR2,
  p_act_Resource_id  IN     NUMBER,
  p_object_version   IN     NUMBER
) IS

l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Act_Resource';
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_resource_id               NUMBER                := p_act_Resource_id;
l_object_version            NUMBER                := p_object_version;
l_return_status             VARCHAR2(1);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_Act_Resource_PUB;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'B', 'C')
   THEN
      AMS_ActResource_CUHK.delete_resource_pre(
         l_resource_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'B', 'V')
   THEN
      AMS_ActResource_VUHK.delete_resource_pre(
         l_resource_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

  -- call business API
    AMS_ActResource_PVT.Delete_Act_Resource(
       p_api_version                => 1.0,
       p_init_msg_list              => p_init_msg_list,
       p_commit                     => p_commit,
       p_validation_level           => p_validation_level,
       x_return_status              => x_return_status,
       x_msg_count                  => x_msg_count,
       x_msg_data                   => x_msg_data,
       p_Act_Resource_id            => l_resource_id,
       p_object_version             => l_object_version
       );


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body
      --

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'A', 'V')
   THEN
      AMS_ActResource_VUHK.delete_resource_post(
         l_resource_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'A', 'C')
   THEN
      AMS_ActResource_CUHK.delete_resource_post(
         l_resource_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;


   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Delete_Act_Resource_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Act_Resource_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Act_Resource_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END Delete_Act_Resource;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Lock_Act_Resource
--
-- PURPOSE
--   This procedure is to lock a delivery method record that satisfy caller needs
--
-- HISTORY
--   04/02/2002        gmadana            created
--
/*****************************************************************************************/

PROCEDURE Lock_Act_Resource
( p_api_version      IN     NUMBER,
  p_init_msg_list    IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,

  x_return_status    OUT NOCOPY    VARCHAR2,
  x_msg_count        OUT NOCOPY    NUMBER,
  x_msg_data         OUT NOCOPY    VARCHAR2,

  p_act_resource_id  IN     NUMBER,
  p_object_version   IN     NUMBER
)
IS

l_api_name            CONSTANT VARCHAR2(30) := 'Lock_Act_Resource';
l_api_version_number  CONSTANT NUMBER       := 1.0;
l_object_version      NUMBER                := p_object_version;
l_resource_id         NUMBER                := p_act_resource_id;
l_return_status       VARCHAR2(1);

 BEGIN

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PACKAGE_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

   -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');

      SAVEPOINT lock_act_resource_pub;

   -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'B', 'C')
   THEN
      AMS_ActResource_CUHK.lock_resource_pre(
         l_resource_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'B', 'V')
   THEN
      AMS_ActResource_VUHK.lock_resource_pre(
         l_resource_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
     AMS_ActResource_PVT.Lock_Act_Resource(
        p_api_version                => 1.0,
        p_init_msg_list              => p_init_msg_list,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        p_Act_Resource_id            => p_Act_Resource_id,
        p_object_version             => p_object_version
        );


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body.
      --

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'A', 'V')
   THEN
      AMS_ActResource_VUHK.lock_resource_post(
         l_resource_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'A', 'C')
   THEN
      AMS_ActResource_CUHK.lock_resource_post(
         l_resource_id,
         l_object_version,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
        FND_MSG_PUB.add;
     END IF;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Act_Resource_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Act_Resource_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Act_Resource_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PACKAGE_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Lock_Act_Resource;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Validate_Act_Resource
--
-- PURPOSE
--   This procedure is to validate an activity resource record
--
-- HISTORY
--   02/20/2002        gmadana            created
--
/*****************************************************************************************/

PROCEDURE Validate_Act_Resource
( p_api_version       IN     NUMBER,
  p_init_msg_list     IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level  IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  x_return_status     OUT NOCOPY    VARCHAR2,
  x_msg_count         OUT NOCOPY    NUMBER,
  x_msg_data          OUT NOCOPY    VARCHAR2,
  p_act_Resource_rec  IN     act_Resource_rec_type
) IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Validate_Act_Resource';
   l_return_status  VARCHAR2(1);
   l_pvt_resource_rec  AMS_ActResource_PVT.Act_Resource_rec_type;
   l_pub_resource_rec  Act_Resource_rec_type := p_act_resource_rec;

BEGIN

   SAVEPOINT validate_act_resource_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   Convert_PubRec_To_PvtRec(l_pub_resource_rec,l_pvt_resource_rec);

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'B', 'C')
   THEN
      AMS_ActResource_CUHK.validate_resource_pre(
         l_pub_resource_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'B', 'V')
   THEN
      AMS_ActResource_VUHK.validate_resource_pre(
         l_pub_resource_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API
   AMS_ActResource_PVT.Validate_Act_Resource(
      p_api_version          => p_api_version,
      p_init_msg_list         => p_init_msg_list,
      p_validation_level      => p_validation_level,
      x_return_status         => l_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data,
      p_Act_Resource_rec      => l_pvt_resource_rec
        );

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'A', 'V')
   THEN
      AMS_ActResource_VUHK.validate_resource_post(
         l_pub_resource_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(G_PACKAGE_NAME, l_api_name, 'A', 'C')
   THEN
      AMS_ActResource_CUHK.validate_resource_post(
         l_pub_resource_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO validate_act_resource_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO validate_act_resource_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO validate_act_resource_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(G_PACKAGE_NAME, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Validate_Act_Resource;


END AMS_ActResource_PUB;

/
