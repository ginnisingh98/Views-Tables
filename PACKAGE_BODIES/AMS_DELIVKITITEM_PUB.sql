--------------------------------------------------------
--  DDL for Package Body AMS_DELIVKITITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DELIVKITITEM_PUB" as
/* $Header: amspkitb.pls 115.2 2002/11/14 00:21:17 musman noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--         AMS_DelivKitItem_PUB
-- Purpose
--
-- History
--  27-sep-2002  ABHOLA Created
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DelivKitItem_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amspkitb.pls';


PROCEDURE Create_DelivKitItem(

   p_api_version_number      IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_Deliv_Kit_Item_rec          IN  AMS_DelivKitItem_PVT.deliv_kit_item_rec_type,
   x_deliv_kit_item_id           OUT NOCOPY NUMBER

     )



 IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_DelivKitItem';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_return_status  VARCHAR2(1);
l_pvt_DelivKitItem_rec    AMS_DelivKitItem_PVT.deliv_kit_item_rec_type  := p_Deliv_Kit_Item_rec;

BEGIN

      SAVEPOINT CREATE_DelivKitItem_PUB;

       -- Standard call to check for call compatibility.
       IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                            p_api_version_number,
                                            l_api_name,
                                            G_PKG_NAME)
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


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       --
       -- API body
       --
     -- Calling Private package: Create_DelivKitItem
     -- Hint: Primary key needs to be returned

  -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_DelivKitItem_CUHK.create_DelivKitItem_pre(
         l_pvt_DelivKitItem_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_DelivKitItem_VUHK.create_DelivKitItem_pre(
         l_pvt_DelivKitItem_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   -------------------------------------------------------
       AMS_DelivKitItem_PVT.Create_Deliv_Kit_Item(
	      p_api_version                => 1.0,
	      p_init_msg_list              => FND_API.G_FALSE,
	      p_commit                     => FND_API.G_FALSE,
	      p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
	      x_return_status              => x_return_status,
	      x_msg_count                  => x_msg_count,
	      x_msg_data                   => x_msg_data,
	      p_Deliv_Kit_Item_rec         => l_pvt_DelivKitItem_rec,
	      x_Deliv_kit_item_id                   => x_Deliv_kit_item_id);


       -- Check return status from the above procedure call
       IF x_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- End of API body.
       --

	   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_DelivKitItem_CUHK.create_DelivKitItem_post(
         l_pvt_DelivKitItem_rec,
	     x_Deliv_kit_item_id,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;



   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_DelivKitItem_VUHK.create_DelivKitItem_post(
         l_pvt_DelivKitItem_rec,
	 x_Deliv_kit_item_id,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   ------------------------------------------

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
     ROLLBACK TO CREATE_DelivKitItem_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_DelivKitItem_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_DelivKitItem_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_DelivKitItem;


PROCEDURE Update_DelivKitItem(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_Deliv_Kit_Item_rec                  IN  AMS_DelivKitItem_PVT.deliv_kit_item_rec_type
    )

 IS

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_DelivKitItem';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number  NUMBER;
l_return_status  VARCHAR2(1);
l_pvt_DelivKitItem_rec  AMS_DelivKitItem_PVT.deliv_kit_item_rec_type := p_Deliv_Kit_Item_rec;

BEGIN

       -- Standard Start of API savepoint
       SAVEPOINT UPDATE_DelivKitItem_PUB;

       -- Standard call to check for call compatibility.
       IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                            p_api_version_number,
                                            l_api_name,
                                            G_PKG_NAME)
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


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_DelivKitItem_CUHK.update_DelivKitItem_pre(
         l_pvt_DelivKitItem_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_DelivKitItem_VUHK.update_DelivKitItem_pre(
         l_pvt_DelivKitItem_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   -------------------------------------------------------
       --
       -- API body
       --
   AMS_DelivKitItem_PVT.Update_Deliv_Kit_Item(
     p_api_version         => 1.0,
     p_init_msg_list              => FND_API.G_FALSE,
     p_commit                     => p_commit,
     p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_Deliv_Kit_Item_rec                  =>  l_pvt_DelivKitItem_rec);


       -- Check return status from the above procedure call
       IF x_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- End of API body
       --
       -- Standard check for p_commit
       IF FND_API.to_Boolean( p_commit )
       THEN
          COMMIT WORK;
       END IF;

   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_DelivKitItem_CUHK.update_DelivKitItem_post(
         l_pvt_DelivKitItem_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_DelivKitItem_VUHK.update_DelivKitItem_post(
         l_pvt_DelivKitItem_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   -------------------------------------------------------
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
  AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_DelivKitItem_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_DelivKitItem_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_DelivKitItem_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

End Update_DelivKitItem;


PROCEDURE Delete_DelivKitItem(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
	p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_deliv_kit_item_id                   IN   NUMBER,
    p_object_version_number      IN   NUMBER
    )



 IS

 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_DelivKitItem';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
 l_deliv_kit_item_id  NUMBER := p_deliv_kit_item_id;
 l_object_version_number  NUMBER := p_object_version_number;
 l_return_status          VARCHAR2(1);


  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT DELETE_DelivKitItem_PUB;

       -- Standard call to check for call compatibility.
       IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                            p_api_version_number,
                                            l_api_name,
                                            G_PKG_NAME)
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


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_DelivKitItem_CUHK.delete_DelivKitItem_pre(
         l_deliv_kit_item_id,
		 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_DelivKitItem_VUHK.delete_DelivKitItem_pre(
         l_deliv_kit_item_id,
		 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   -------------------------------------------------------

       --
       -- API body
       --
     AMS_DelivKitItem_PVT.Delete_Deliv_Kit_Item(
     p_api_version                => 1.0,
     p_init_msg_list              => FND_API.G_FALSE,
     p_commit                     => p_commit,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_deliv_kit_item_id          => l_deliv_kit_item_id,
     p_object_version             => l_object_version_number );



       -- Check return status from the above procedure call
       IF x_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- End of API body
       --

   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_DelivKitItem_CUHK.delete_DelivKitItem_post(
         l_deliv_kit_item_id,
		 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_DelivKitItem_VUHK.delete_DelivKitItem_post(
         l_deliv_kit_item_id,
	 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
   -------------------------------------------------------


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
      AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_DelivKitItem_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_DelivKitItem_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO DELETE_DelivKitItem_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
 End Delete_DelivKitItem;




PROCEDURE Validate_DelivKitItem(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_Deliv_Kit_Item_rec         IN  AMS_DelivKitItem_PVT.deliv_kit_item_rec_type
)


IS

   l_api_name       CONSTANT VARCHAR2(30) := 'Validate_DelivKitItem';
   l_return_status  VARCHAR2(1);
   l_pvt_DelivKitItem_rec  AMS_DelivKitItem_PVT.deliv_kit_item_rec_type := p_Deliv_Kit_Item_rec;


BEGIN

   SAVEPOINT validate_DelivKitItem_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

     -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_DelivKitItem_CUHK.validate_DelivKitItem_pre(
         l_pvt_DelivKitItem_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_DelivKitItem_VUHK.validate_DelivKitItem_pre(
         l_pvt_DelivKitItem_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- call business API

   AMS_DelivKitItem_PVT.Validate_Deliv_Kit_Item(
      p_api_version    => p_api_version_number,
      p_init_msg_list         => p_init_msg_list, --has done before
      p_validation_level      => p_validation_level,
      p_Deliv_Kit_Item_rec             => l_pvt_DelivKitItem_rec,
      x_return_status         => l_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data
        );


   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;





   -- vertical industry post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_DelivKitItem_VUHK.validate_DelivKitItem_post(
         l_pvt_DelivKitItem_rec,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- customer post-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_DelivKitItem_CUHK.validate_DelivKitItem_post(
         l_pvt_DelivKitItem_rec,
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
      ROLLBACK TO validate_DelivKitItem_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO validate_DelivKitItem_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO validate_DelivKitItem_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Validate_DelivKitItem;


PROCEDURE Lock_DelivKitItem(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_deliv_kit_item_id                   IN  NUMBER,
     p_object_version_number             IN  NUMBER
     )

  IS

 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_DelivKitItem';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

 l_deliv_kit_item_id      NUMBER := p_deliv_kit_item_id ;
 l_object_version_number          NUMBER := p_object_version_number;
 l_return_status    VARCHAR2(1);

  BEGIN

       -- Standard call to check for call compatibility.
       IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                            p_api_version_number,
                                            l_api_name,
                                            G_PKG_NAME)
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


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
   -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'C')
   THEN
      AMS_DelivKitItem_CUHK.lock_DelivKitItem_pre(
         l_deliv_kit_item_id,
		 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'B', 'V')
   THEN
      AMS_DelivKitItem_VUHK.lock_DelivKitItem_pre(
         l_deliv_kit_item_id,
		 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
       --
       -- API body
       --
     -- Calling Private package: Create_DelivKitItem
     -- Hint: Primary key needs to be returned

      AMS_DelivKitItem_PVT.Lock_Deliv_Kit_Item(
      p_api_version        => 1.0,
      p_init_msg_list              => FND_API.G_FALSE,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data,
      p_deliv_kit_item_id     => l_deliv_kit_item_id,
      p_object_version             => l_object_version_number);


       -- Check return status from the above procedure call
       IF x_return_status = FND_API.G_RET_STS_ERROR then
           RAISE FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- End of API body.
       --
	    -- customer pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'C')
   THEN
      AMS_DelivKitItem_CUHK.lock_DelivKitItem_post(
         l_deliv_kit_item_id,
		 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- vertical industry pre-processing
   IF JTF_USR_HKS.ok_to_execute(g_pkg_name, l_api_name, 'A', 'V')
   THEN
      AMS_DelivKitItem_VUHK.lock_DelivKitItem_post(
         l_deliv_kit_item_id,
		 l_object_version_number,
         l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
       --

       -- Debug Message
       AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

 EXCEPTION

    WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO LOCK_DelivKitItem_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO LOCK_DelivKitItem_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO LOCK_DelivKitItem_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
 End Lock_DelivKitItem;


END AMS_DelivKitItem_PUB;

/
