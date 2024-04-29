--------------------------------------------------------
--  DDL for Package Body OZF_RELATED_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_RELATED_LINES_PVT" as
/* $Header: ozfvordb.pls 120.0 2005/06/01 03:09:46 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Related_Lines_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Related_Lines_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvordb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- ===============================================================
--   Complete_related_lines_rec
--
--      to replace g_miss values to column values
--
-- ===============================================================
PROCEDURE Complete_related_lines_Rec (
    P_related_lines_rec     IN    related_lines_rec_type,
     x_complete_rec        OUT NOCOPY    related_lines_rec_type
    )
    ;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Related_Lines(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_related_lines_rec               IN   related_lines_rec_type  := g_miss_related_lines_rec,
    x_related_deal_lines_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Related_Lines';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_RELATED_DEAL_LINES_ID                  NUMBER;
   l_dummy       NUMBER;

   l_related_lines_Rec  related_lines_rec_type := p_related_lines_rec;

   CURSOR c_id IS
      SELECT OZF_RELATED_DEAL_LINES_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_RELATED_DEAL_LINES
      WHERE RELATED_DEAL_LINES_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Related_Lines_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization
   IF p_related_lines_rec.RELATED_DEAL_LINES_ID IS NULL
   OR p_related_lines_rec.RELATED_DEAL_LINES_ID = FND_API.g_miss_num
   THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_RELATED_DEAL_LINES_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_RELATED_DEAL_LINES_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;

         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

   l_related_lines_rec.related_deal_lines_id := l_related_deal_lines_id;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Related_Lines');

          -- Invoke validation procedures
          Validate_related_lines(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
	    p_validation_mode   => JTF_PLSQL_API.g_create,
            p_related_lines_rec  =>  l_related_lines_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(OZF_RELATED_DEAL_LINES_PKG.Insert_Row)
      OZF_RELATED_DEAL_LINES_PKG.Insert_Row(
          px_related_deal_lines_id  => l_related_deal_lines_id,
          p_modifier_id  => p_related_lines_rec.modifier_id,
          p_related_modifier_id  => p_related_lines_rec.related_modifier_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          px_object_version_number  => l_object_version_number,
          --p_security_group_id  => p_related_lines_rec.security_group_id,
          p_estimated_qty_is_max  => p_related_lines_rec.estimated_qty_is_max,
          p_estimated_amount_is_max  => p_related_lines_rec.estimated_amount_is_max,
          p_estimated_qty  => p_related_lines_rec.estimated_qty,
          p_estimated_amount  => p_related_lines_rec.estimated_amount,
          p_qp_list_header_id  => p_related_lines_rec.qp_list_header_id,
          p_estimate_qty_uom   => p_related_lines_rec.estimate_qty_uom);
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Related_Lines_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Related_Lines_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Related_Lines_PVT;
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
End Create_Related_Lines;


PROCEDURE Update_Related_Lines(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_related_lines_rec               IN    related_lines_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
--/*
CURSOR c_get_related_lines(p_related_deal_lines_id NUMBER) IS
    SELECT *
    FROM  OZF_RELATED_DEAL_LINES
    WHERE related_deal_lines_id = p_related_deal_lines_id;


    -- Hint: Developer need to provide Where clause
--*/
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Related_Lines';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_RELATED_DEAL_LINES_ID    NUMBER;
l_ref_related_lines_rec  c_get_Related_Lines%ROWTYPE ;
l_tar_related_lines_rec  OZF_Related_Lines_PVT.related_lines_rec_type := P_related_lines_rec;

l_related_lines_rec   related_lines_rec_type := p_related_lines_rec;

l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Related_Lines_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

      --/*
      OPEN c_get_Related_Lines( l_tar_related_lines_rec.related_deal_lines_id);
      FETCH c_get_Related_Lines INTO l_ref_related_lines_rec  ;
        If ( c_get_Related_Lines%NOTFOUND) THEN
	   OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
	                                 p_token_name   => 'INFO',
					 p_token_value  => 'Related_Lines') ;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Debug Message
        OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
      CLOSE     c_get_Related_Lines;
      --*/


      If (l_tar_related_lines_rec.object_version_number is NULL or
          l_tar_related_lines_rec.object_version_number = FND_API.G_MISS_NUM ) Then
         OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
                                       p_token_name   => 'COLUMN',
				       p_token_value  => 'Last_Update_Date') ;
         raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_related_lines_rec.object_version_number <> l_ref_related_lines_rec.object_version_number) Then
         OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
	                              p_token_name   => 'INFO',
				      p_token_value  => 'Related_Lines') ;
         raise FND_API.G_EXC_ERROR;
      End if;

     -- replace g_miss_char/num/date with current column values
     Complete_related_lines_Rec(p_related_lines_rec, l_related_lines_rec);

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Related_Lines');

          -- Invoke validation procedures
          Validate_related_lines(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
   	    p_validation_mode   => JTF_PLSQL_API.g_update,
            p_related_lines_rec  =>  p_related_lines_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
 OZF_UTILITY_PVT.debug_message('Private API: Validate_Related_Lines ended successfully');

      -- Debug Message
  --    OZF_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(OZF_RELATED_DEAL_LINES_PKG.Update_Row)
       OZF_UTILITY_PVT.debug_message('callin update row');
      OZF_RELATED_DEAL_LINES_PKG.Update_Row(
          p_related_deal_lines_id  => p_related_lines_rec.related_deal_lines_id,
          p_modifier_id  => p_related_lines_rec.modifier_id,
          p_related_modifier_id  => p_related_lines_rec.related_modifier_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_object_version_number  => p_related_lines_rec.object_version_number,
          --p_security_group_id  => p_related_lines_rec.security_group_id,
          p_estimated_qty_is_max  => p_related_lines_rec.estimated_qty_is_max,
          p_estimated_amount_is_max  => p_related_lines_rec.estimated_amount_is_max,
          p_estimated_qty  => p_related_lines_rec.estimated_qty,
          p_estimated_amount  => p_related_lines_rec.estimated_amount,
          p_qp_list_header_id  => p_related_lines_rec.qp_list_header_id,
          p_estimate_qty_uom   => p_related_lines_rec.estimate_qty_uom);
      --
      -- End of API body.
      --
       OZF_UTILITY_PVT.debug_message('end update row');
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Related_Lines_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Related_Lines_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Related_Lines_PVT;
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
End Update_Related_Lines;


PROCEDURE Delete_Related_Lines(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_related_deal_lines_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Related_Lines';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Related_Lines_PVT;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(OZF_RELATED_DEAL_LINES_PKG.Delete_Row)
      OZF_RELATED_DEAL_LINES_PKG.Delete_Row(
          p_RELATED_DEAL_LINES_ID  => p_RELATED_DEAL_LINES_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Related_Lines_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Related_Lines_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Related_Lines_PVT;
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
End Delete_Related_Lines;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Related_Lines(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_related_deal_lines_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Related_Lines';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_RELATED_DEAL_LINES_ID                  NUMBER;

CURSOR c_Related_Lines IS
   SELECT RELATED_DEAL_LINES_ID
   FROM OZF_RELATED_DEAL_LINES
   WHERE RELATED_DEAL_LINES_ID = p_RELATED_DEAL_LINES_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------

  OZF_Utility_PVT.debug_message(l_full_name||': start');
  OPEN c_Related_Lines;

  FETCH c_Related_Lines INTO l_RELATED_DEAL_LINES_ID;

  IF (c_Related_Lines%NOTFOUND) THEN
    CLOSE c_Related_Lines;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Related_Lines;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  OZF_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Related_Lines_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Related_Lines_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Related_Lines_PVT;
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
End Lock_Related_Lines;


PROCEDURE check_related_lines_uk_items(
    p_related_lines_rec               IN   related_lines_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'OZF_RELATED_DEAL_LINES',
         'RELATED_DEAL_LINES_ID = ''' || p_related_lines_rec.RELATED_DEAL_LINES_ID ||''''
         );
      ELSE
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'OZF_RELATED_DEAL_LINES',
         'RELATED_DEAL_LINES_ID = ''' || p_related_lines_rec.RELATED_DEAL_LINES_ID ||
         ''' AND RELATED_DEAL_LINES_ID <> ' || p_related_lines_rec.RELATED_DEAL_LINES_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_RLTD_DEAL_LINES_ID_DUP');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_related_lines_uk_items;

PROCEDURE check_related_lines_req_items(
    p_related_lines_rec          IN  related_lines_rec_type,
    p_validation_mode            IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS

   l_api_name VARCHAR2(50) := 'check_related_lines_req_items';

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      OZF_UTILITY_PVT.debug_message(l_api_name||' - Start  and related_deal_lines id is '||p_related_lines_rec.related_deal_lines_id);

      IF p_related_lines_rec.related_deal_lines_id = FND_API.g_miss_num
      OR p_related_lines_rec.related_deal_lines_id IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_RLTD_LINES_NO_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      OZF_UTILITY_PVT.debug_message(l_api_name||' - related_deal_lines_id  ');

      IF p_related_lines_rec.modifier_id = FND_API.g_miss_num OR p_related_lines_rec.modifier_id IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_RLTD_LINES_NO_MODIFIER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
/* commented by julou 09/07/2001 related_modifier_id are optional
      OZF_UTILITY_PVT.debug_message(l_api_name||' - modifier_id ');
      IF p_related_lines_rec.related_modifier_id = FND_API.g_miss_num OR p_related_lines_rec.related_modifier_id IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_related_lines_NO_related_modifier_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      OZF_UTILITY_PVT.debug_message(l_api_name||' -related modifier_id ');
      */
/*
      IF p_related_lines_rec.last_update_date = FND_API.g_miss_date OR p_related_lines_rec.last_update_date IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_related_lines_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_related_lines_rec.last_updated_by = FND_API.g_miss_num OR p_related_lines_rec.last_updated_by IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_related_lines_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_related_lines_rec.creation_date = FND_API.g_miss_date OR p_related_lines_rec.creation_date IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_related_lines_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_related_lines_rec.created_by = FND_API.g_miss_num OR p_related_lines_rec.created_by IS NULL THEN
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_related_lines_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      */
   ELSE


      IF p_related_lines_rec.related_deal_lines_id IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_RLTD_LINES_NO_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

/* comment julou 09/07/2001 modifier_id and related_modifier_id are optional now
      IF p_related_lines_rec.modifier_id IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_related_lines_NO_modifier_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_related_lines_rec.related_modifier_id IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_related_lines_NO_related_modifier_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
*/
/*
      IF p_related_lines_rec.last_update_date IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_related_lines_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_related_lines_rec.last_updated_by IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_related_lines_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_related_lines_rec.creation_date IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_related_lines_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_related_lines_rec.created_by IS NULL THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_related_lines_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;  */
   END IF;

END check_related_lines_req_items;

PROCEDURE check_related_lines_FK_items(
    p_related_lines_rec IN related_lines_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   OZF_UTILITY_PVT.debug_message('Check_RELATED_LINES_fk_item -  qp_list_header return status '||x_return_status);
   ---  checking the qp_list_header_id
   IF p_related_lines_rec.qp_list_header_id <> FND_API.G_MISS_NUM
   AND p_related_lines_rec.qp_list_header_id IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_fk_exists(
                      'qp_list_headers_b'
                      ,'list_header_id'
                      ,p_related_lines_rec.qp_list_header_id) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFFR_BAD_QP_LIST_HEADER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

---  checking the modifier_id
   OZF_UTILITY_PVT.debug_message('Check_RELATED_LINES_fk_item - modifier_id return status '||x_return_status);
   IF p_related_lines_rec.modifier_id <> FND_API.G_MISS_NUM
   AND  p_related_lines_rec.modifier_id IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_fk_exists(
                      'qp_list_lines'
                      ,'list_line_id '
                      ,p_related_lines_rec.modifier_id) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFFR_BAD_MODIFIER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

---  checking the related_modifier_id
   OZF_UTILITY_PVT.debug_message('Check_RELATED_LINES_fk_item -reld modifier_id return status '||x_return_status);
   IF p_related_lines_rec.related_modifier_id <> FND_API.G_MISS_NUM
   AND p_related_lines_rec.related_modifier_id IS NOT NULL
   THEN
      IF OZF_Utility_PVT.check_fk_exists(
                      'qp_list_lines'
                      ,'list_line_id '
                      ,p_related_lines_rec.related_modifier_id) = FND_API.g_false
      THEN
         OZF_Utility_PVT.Error_Message('OZF_OFFR_BAD_RLTD_MODIFIER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_related_lines_FK_items;

PROCEDURE check_related_lines_Lkup_items(
    p_related_lines_rec IN related_lines_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_related_lines_Lkup_items;

PROCEDURE Check_related_lines_Items (
    P_related_lines_rec     IN    related_lines_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls
   OZF_UTILITY_PVT.debug_message('Check_RELATED_LINES_ _uk_Items - is first the return status '||x_return_status);

   check_related_lines_uk_items(
      p_related_lines_rec => p_related_lines_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls
   OZF_UTILITY_PVT.debug_message('Check_RELATED_LINES_req_Items - is the return status '||x_return_status);

   check_related_lines_req_items(
      p_related_lines_rec => p_related_lines_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   OZF_UTILITY_PVT.debug_message('Check_RELATED_LINES_fk_Items - is first the return status '||x_return_status);

   check_related_lines_FK_items(
      p_related_lines_rec => p_related_lines_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups
   OZF_UTILITY_PVT.debug_message('Check_RELATED_LINES_lkup items - is first the return status '||x_return_status);
   check_related_lines_Lkup_items(
      p_related_lines_rec => p_related_lines_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   OZF_UTILITY_PVT.debug_message('Check_RELATED_LINES_ finally return status '||x_return_status);

END Check_related_lines_Items;



PROCEDURE Complete_related_lines_Rec (
   p_related_lines_rec IN related_lines_rec_type,
   x_complete_rec OUT NOCOPY related_lines_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM OZF_related_deal_lines
      WHERE related_deal_lines_id = p_related_lines_rec.related_deal_lines_id;
   l_related_lines_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_related_lines_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_related_lines_rec;
   CLOSE c_complete;

   -- related_deal_lines_id
   IF p_related_lines_rec.related_deal_lines_id = FND_API.g_miss_num THEN
      x_complete_rec.related_deal_lines_id := NULL;
   END IF;
   IF p_related_lines_rec.related_deal_lines_id IS NULL THEN
      x_complete_rec.related_deal_lines_id := l_related_lines_rec.related_deal_lines_id;
   END IF;

   -- modifier_id
   IF p_related_lines_rec.modifier_id = FND_API.g_miss_num THEN
      x_complete_rec.modifier_id := NULL;
   END IF;
   IF p_related_lines_rec.modifier_id IS NULL THEN
      x_complete_rec.modifier_id := l_related_lines_rec.modifier_id;
   END IF;

   -- related_modifier_id
   IF p_related_lines_rec.related_modifier_id = FND_API.g_miss_num THEN
      x_complete_rec.related_modifier_id := NULL;
   END IF;
   IF p_related_lines_rec.related_modifier_id IS NULL THEN
      x_complete_rec.related_modifier_id := l_related_lines_rec.related_modifier_id;
   END IF;

   -- last_update_date
   IF p_related_lines_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := NULL;
   END IF;
   IF p_related_lines_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_related_lines_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_related_lines_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := NULL;
   END IF;
   IF p_related_lines_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_related_lines_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_related_lines_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := NULL;
   END IF;
   IF p_related_lines_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_related_lines_rec.creation_date;
   END IF;

   -- created_by
   IF p_related_lines_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := NULL;
   END IF;
   IF p_related_lines_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_related_lines_rec.created_by;
   END IF;

   -- last_update_login
   IF p_related_lines_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := NULL;
   END IF;
   IF p_related_lines_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_related_lines_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_related_lines_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := NULL;
   END IF;
   IF p_related_lines_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_related_lines_rec.object_version_number;
   END IF;

   -- security_group_id
   /*
   IF p_related_lines_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := NULL;
   END IF;
   IF p_related_lines_rec.security_group_id IS NULL THEN
      x_complete_rec.security_group_id := l_related_lines_rec.security_group_id;
   END IF;
   */
   -- estimated_qty_is_max
   IF p_related_lines_rec.estimated_qty_is_max = FND_API.g_miss_char THEN
      x_complete_rec.estimated_qty_is_max := NULL;
   END IF;
   IF p_related_lines_rec.estimated_qty_is_max IS NULL THEN
      x_complete_rec.estimated_qty_is_max := l_related_lines_rec.estimated_qty_is_max;
   END IF;

   -- estimated_amount_is_max
   IF p_related_lines_rec.estimated_amount_is_max = FND_API.g_miss_char THEN
      x_complete_rec.estimated_amount_is_max := NULL;
   END IF;
   IF p_related_lines_rec.estimated_amount_is_max IS NULL THEN
      x_complete_rec.estimated_amount_is_max := l_related_lines_rec.estimated_amount_is_max;
   END IF;

   -- estimated_qty
   IF p_related_lines_rec.estimated_qty = FND_API.g_miss_num THEN
      x_complete_rec.estimated_qty := NULL;
   END IF;
   IF p_related_lines_rec.estimated_qty IS NULL THEN
      x_complete_rec.estimated_qty := l_related_lines_rec.estimated_qty;
   END IF;

   -- estimated_amount
   IF p_related_lines_rec.estimated_amount = FND_API.g_miss_num THEN
      x_complete_rec.estimated_amount := NULL;
   END IF;
   IF p_related_lines_rec.estimated_amount IS NULL THEN
      x_complete_rec.estimated_amount := l_related_lines_rec.estimated_amount;
   END IF;

   -- qp_list_header_id
   IF p_related_lines_rec.qp_list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.qp_list_header_id := NULL;
   END IF;
   IF p_related_lines_rec.qp_list_header_id IS NULL THEN
      x_complete_rec.qp_list_header_id := l_related_lines_rec.qp_list_header_id;
   END IF;

   -- estimate_qty_uom
   IF p_related_lines_rec.estimate_qty_uom = FND_API.g_miss_char THEN
      x_complete_rec.estimate_qty_uom := NULL;
   END IF;
   IF p_related_lines_rec.estimate_qty_uom IS NULL THEN
      x_complete_rec.estimate_qty_uom := l_related_lines_rec.estimate_qty_uom;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_related_lines_Rec;

PROCEDURE Validate_related_lines(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN   VARCHAR2 := JTF_PLSQL_API.g_update,
    p_related_lines_rec          IN   related_lines_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Related_Lines';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_related_lines_rec  OZF_Related_Lines_PVT.related_lines_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Related_Lines_;

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




      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_related_lines_Items(
                 p_related_lines_rec        => p_related_lines_rec,
                 p_validation_mode   => p_validation_mode,            --JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_related_lines_Rec(
         p_related_lines_rec        => p_related_lines_rec,
         x_complete_rec        => l_related_lines_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_related_lines_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_related_lines_rec           =>    l_related_lines_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Related_Lines_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Related_Lines_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Related_Lines_;
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
End Validate_Related_Lines;


PROCEDURE Validate_related_lines_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_related_lines_rec               IN    related_lines_rec_type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: Validate_related_lines_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_related_lines_Rec;

END OZF_Related_Lines_PVT;

/
