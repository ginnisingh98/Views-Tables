--------------------------------------------------------
--  DDL for Package Body AMS_PS_CNDCLSES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PS_CNDCLSES_PUB" as
/* $Header: amspcclb.pls 120.0 2005/05/31 17:55:15 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Ps_Cndclses_PUB
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Ps_Cndclses_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amspcclb.pls';

AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Ps_Cndclses(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN   VARCHAR2  := FND_API.G_FALSE,

    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,

    p_ps_cndclses_rec     IN   ps_cndclses_rec_type  := g_miss_ps_cndclses_rec,
    x_cnd_clause_id       OUT NOCOPY  NUMBER
)

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ps_Cndclses';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_pvt_ps_cndclses_rec    AMS_Ps_Cndclses_PVT.ps_cndclses_rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Ps_Cndclses_PUB;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    -- Calling Private package: Create_Ps_Cndclses
    -- Hint: Primary key needs to be returned
     AMS_Ps_Cndclses_PVT.Create_Ps_Cndclses(
     p_api_version_number         => 1.0,
     p_init_msg_list              => FND_API.G_FALSE,
     p_commit                     => FND_API.G_FALSE,
     p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_ps_cndclses_rec  => l_pvt_ps_cndclses_rec,
     x_cnd_clause_id     => x_cnd_clause_id);


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO CREATE_Ps_Cndclses_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ps_Cndclses_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ps_Cndclses_PUB;
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
End Create_Ps_Cndclses;


PROCEDURE Update_Ps_Cndclses(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ps_cndclses_rec               IN    ps_cndclses_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ps_Cndclses';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number  NUMBER;
l_pvt_ps_cndclses_rec  AMS_Ps_Cndclses_PVT.ps_cndclses_rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Ps_Cndclses_PUB;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    AMS_Ps_Cndclses_PVT.Update_Ps_Cndclses(
    p_api_version_number         => 1.0,
    p_init_msg_list              => FND_API.G_FALSE,
    p_commit                     => p_commit,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_ps_cndclses_rec  =>  l_pvt_ps_cndclses_rec,
    x_object_version_number      => l_object_version_number );


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


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO UPDATE_Ps_Cndclses_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ps_Cndclses_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ps_Cndclses_PUB;
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
End Update_Ps_Cndclses;


PROCEDURE Delete_Ps_Cndclses(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_cnd_clause_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ps_Cndclses';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_CND_CLAUSE_ID  NUMBER := p_CND_CLAUSE_ID;
l_object_version_number  NUMBER := p_object_version_number;
l_pvt_ps_cndclses_rec  AMS_Ps_Cndclses_PVT.ps_cndclses_rec_type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Ps_Cndclses_PUB;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    AMS_Ps_Cndclses_PVT.Delete_Ps_Cndclses(
    p_api_version_number         => 1.0,
    p_init_msg_list              => FND_API.G_FALSE,
    p_commit                     => p_commit,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_cnd_clause_id     => l_cnd_clause_id,
    p_object_version_number      => l_object_version_number );


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


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

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
     ROLLBACK TO DELETE_Ps_Cndclses_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ps_Cndclses_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ps_Cndclses_PUB;
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
End Delete_Ps_Cndclses;


PROCEDURE Lock_Ps_Cndclses(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_cnd_clause_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ps_Cndclses';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_pvt_ps_cndclses_rec    AMS_Ps_Cndclses_PVT.ps_cndclses_rec_type;
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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --
    -- Calling Private package: Create_Ps_Cndclses
    -- Hint: Primary key needs to be returned
     AMS_Ps_Cndclses_PVT.Lock_Ps_Cndclses(
     p_api_version_number         => 1.0,
     p_init_msg_list              => FND_API.G_FALSE,
     x_return_status              => x_return_status,
     x_msg_count                  => x_msg_count,
     x_msg_data                   => x_msg_data,
     p_cnd_clause_id     => p_cnd_clause_id,
     p_object_version             => p_object_version);


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --
      -- End of API body.
      --

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');
      END IF;

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Ps_Cndclses_PUB;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ps_Cndclses_PUB;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ps_Cndclses_PUB;
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
End Lock_Ps_Cndclses;


END AMS_Ps_Cndclses_PUB;

/
