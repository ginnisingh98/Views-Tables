--------------------------------------------------------
--  DDL for Package Body PV_PG_INVITE_HEADERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_INVITE_HEADERS_PVT" as
/* $Header: pvxvpihb.pls 120.3 2005/09/15 13:05:25 dgottlie ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          Pv_Pg_Invite_Headers_PVT
-- Purpose
--
-- History
--          08/26/03  ktsao  Update the Create_Invite_Headers, Update_Invite_Headers,
--                           check_Invite_Headers_Req_Items, and Complete_Invite_Headers_Rec
--                           with three new columns in pv_pg_invite_headers_b: partner_id,
--                           INVITE_END_DATE , and ORDER_HEADER_ID.
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'Pv_Pg_Invite_Headers_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvpihb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Invite_Headers_Items (
   p_invite_headers_rec IN  invite_headers_rec_type ,
   x_invite_headers_rec OUT NOCOPY invite_headers_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Invite_Headers
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_invite_headers_rec            IN   invite_headers_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Invite_Headers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_invite_headers_rec              IN   invite_headers_rec_type  := g_miss_invite_headers_rec,
    x_INVITE_HEADER_ID              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Invite_Headers';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_INVITE_HEADER_ID              NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT pv_pg_invite_headers_b_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_PG_INVITE_HEADERS_B
      WHERE INVITE_HEADER_ID = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_invite_headers_pvt;

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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;
      --DBMS_OUTPUT.PUT_LINE('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         PVX_UTility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

	--DBMS_OUTPUT.PUT_LINE('Control is before validation level');
/*
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Invite_Headers');
          END IF;

          -- Invoke validation procedures
          Validate_invite_headers(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_invite_headers_rec  =>  p_invite_headers_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;
*/
      --DBMS_OUTPUT.PUT_LINE('Control is after validation level :' || x_return_status);
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

   IF p_invite_headers_rec.INVITE_HEADER_ID IS NULL OR p_invite_headers_rec.INVITE_HEADER_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_INVITE_HEADER_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_INVITE_HEADER_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_INVITE_HEADER_ID := p_invite_headers_rec.INVITE_HEADER_ID;
   END IF;
   --DBMS_OUTPUT.PUT_LINE('l_INVITE_HEADER_ID :' || to_char(l_INVITE_HEADER_ID));

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

	--DBMS_OUTPUT.PUT_LINE('Private API: Calling create table handler');
      -- Invoke table handler(Pv_Pg_Invite_Headers_Pkg.Insert_Row)
      Pv_Pg_Invite_Headers_Pkg.Insert_Row(

	  -- p_invite_header_id  => p_invite_headers_rec.invite_header_id,
          px_invite_header_id  => l_INVITE_HEADER_ID,
          px_object_version_number  => l_object_version_number,
          p_qp_list_header_id  => p_invite_headers_rec.qp_list_header_id,
          p_invite_type_code  => p_invite_headers_rec.invite_type_code,
          p_invite_for_program_id  => p_invite_headers_rec.invite_for_program_id,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_partner_id  => p_invite_headers_rec.partner_id,
          p_invite_end_date  => p_invite_headers_rec.invite_end_date,
          p_order_header_id  => p_invite_headers_rec.order_header_id,
          p_invited_by_partner_id  => p_invite_headers_rec.invited_by_partner_id,
	  p_trxn_extension_id => p_invite_headers_rec.trxn_extension_id,
          p_EMAIL_CONTENT  => p_invite_headers_rec.EMAIL_CONTENT
);

          x_INVITE_HEADER_ID := l_INVITE_HEADER_ID;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       --     RAISE 'INVITE ID' || l_INVITE_HEADER_ID
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--
 --DBMS_OUTPUT.PUT_LINE('Private API: End of API body');
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_UTility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Invite_Headers_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Invite_Headers_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Invite_Headers_PVT;
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
End Create_Invite_Headers;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Invite_Headers
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_invite_headers_rec            IN   invite_headers_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Invite_Headers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_invite_headers_rec               IN    invite_headers_rec_type
    )

 IS


CURSOR c_get_invite_headers(invite_header_id NUMBER) IS
    SELECT *
    FROM  PV_PG_INVITE_HEADERS_B
    WHERE  invite_header_id = p_invite_headers_rec.invite_header_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Invite_Headers';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_INVITE_HEADER_ID    NUMBER;
l_ref_invite_headers_rec  c_get_Invite_Headers%ROWTYPE ;
l_tar_invite_headers_rec  invite_headers_rec_type := P_invite_headers_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_invite_headers_pvt;

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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

      OPEN c_get_Invite_Headers( l_tar_invite_headers_rec.invite_header_id);

      FETCH c_get_Invite_Headers INTO l_ref_invite_headers_rec  ;

       If ( c_get_Invite_Headers%NOTFOUND) THEN
  PVX_UTility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Invite_Headers') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Invite_Headers;


      If (l_tar_invite_headers_rec.object_version_number is NULL or
          l_tar_invite_headers_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  PVX_UTility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_invite_headers_rec.object_version_number <> l_ref_invite_headers_rec.object_version_number) Then
  PVX_UTility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Invite_Headers') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Invite_Headers');
          END IF;

          -- Invoke validation procedures
          Validate_invite_headers(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_invite_headers_rec  =>  p_invite_headers_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(Pv_Pg_Invite_Headers_Pkg.Update_Row)
      Pv_Pg_Invite_Headers_Pkg.Update_Row(
          p_invite_header_id  => p_invite_headers_rec.invite_header_id,
          p_object_version_number  => p_invite_headers_rec.object_version_number,
          p_qp_list_header_id  => p_invite_headers_rec.qp_list_header_id,
          p_invite_type_code  => p_invite_headers_rec.invite_type_code,
          p_invite_for_program_id  => p_invite_headers_rec.invite_for_program_id,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_partner_id  => p_invite_headers_rec.partner_id,
          p_invite_end_date  => p_invite_headers_rec.invite_end_date,
          p_order_header_id  => p_invite_headers_rec.order_header_id,
          p_invited_by_partner_id  => p_invite_headers_rec.invited_by_partner_id,
	  p_trxn_extension_id => p_invite_headers_rec.trxn_extension_id,
          p_EMAIL_CONTENT  => p_invite_headers_rec.EMAIL_CONTENT
);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_UTility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Invite_Headers_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Invite_Headers_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Invite_Headers_PVT;
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
End Update_Invite_Headers;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Invite_Headers
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_INVITE_HEADER_ID                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Invite_Headers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_INVITE_HEADER_ID                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Invite_Headers';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_invite_headers_pvt;

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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(Pv_Pg_Invite_Headers_Pkg.Delete_Row)
      Pv_Pg_Invite_Headers_Pkg.Delete_Row(
          p_INVITE_HEADER_ID  => p_INVITE_HEADER_ID,
          p_object_version_number => p_object_version_number     );
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_UTility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Invite_Headers_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Invite_Headers_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Invite_Headers_PVT;
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
End Delete_Invite_Headers;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Invite_Headers
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_invite_headers_rec            IN   invite_headers_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Lock_Invite_Headers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_INVITE_HEADER_ID                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Invite_Headers';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_INVITE_HEADER_ID                  NUMBER;

BEGIN

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


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
Pv_Pg_Invite_Headers_Pkg.Lock_Row(l_INVITE_HEADER_ID,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (PV_DEBUG_HIGH_ON) THEN

  PVX_UTility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN PVX_UTility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Invite_Headers_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Invite_Headers_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Invite_Headers_PVT;
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
End Lock_Invite_Headers;




PROCEDURE check_Invite_Headers_Uk_Items(
    p_invite_headers_rec               IN   invite_headers_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_invite_headers_rec.INVITE_HEADER_ID IS NOT NULL
      THEN
         l_valid_flag := PVX_UTility_PVT.check_uniqueness(
         'pv_pg_invite_headers_b',
         'INVITE_HEADER_ID = ''' || p_invite_headers_rec.INVITE_HEADER_ID ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         PVX_UTility_PVT.Error_Message(p_message_name => 'Pv_Pg_Invite_HEADER_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Invite_Headers_Uk_Items;



PROCEDURE check_Invite_Headers_Req_Items(
    p_invite_headers_rec               IN  invite_headers_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_invite_headers_rec.invite_header_id = FND_API.G_MISS_NUM OR p_invite_headers_rec.invite_header_id IS NULL THEN
               PVX_UTility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'INVITE_HEADER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_invite_headers_rec.object_version_number = FND_API.G_MISS_NUM OR p_invite_headers_rec.object_version_number IS NULL THEN
               PVX_UTility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_invite_headers_rec.invite_for_program_id = FND_API.G_MISS_NUM OR p_invite_headers_rec.invite_for_program_id IS NULL THEN
               PVX_UTility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'INVITE_FOR_PROGRAM_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_invite_headers_rec.partner_id = FND_API.G_MISS_NUM OR p_invite_headers_rec.partner_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PARTNER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

   ELSE


      IF p_invite_headers_rec.invite_header_id = FND_API.G_MISS_NUM THEN
               PVX_UTility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'INVITE_HEADER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_invite_headers_rec.object_version_number = FND_API.G_MISS_NUM THEN
               PVX_UTility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_invite_headers_rec.invite_for_program_id = FND_API.G_MISS_NUM THEN
               PVX_UTility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'INVITE_FOR_PROGRAM_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_invite_headers_rec.partner_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PARTNER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

   END IF;

END check_Invite_Headers_Req_Items;



PROCEDURE check_Invite_Headers_Fk_Items(
    p_invite_headers_rec IN invite_headers_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Invite_Headers_Fk_Items;



PROCEDURE check_Ihdrs_Lookup_Items(
    p_invite_headers_rec IN invite_headers_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Ihdrs_Lookup_Items;



PROCEDURE Check_Invite_Headers_Items (
    P_invite_headers_rec     IN    invite_headers_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Invite_headers_Uk_Items(
      p_invite_headers_rec => p_invite_headers_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_invite_headers_req_items(
      p_invite_headers_rec => p_invite_headers_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_invite_headers_FK_items(
      p_invite_headers_rec => p_invite_headers_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_Ihdrs_Lookup_Items(
      p_invite_headers_rec => p_invite_headers_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_invite_headers_Items;





PROCEDURE Complete_Invite_Headers_Rec (
   p_invite_headers_rec IN invite_headers_rec_type,
   x_complete_rec OUT NOCOPY invite_headers_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_pg_invite_headers_b
      WHERE INVITE_HEADER_ID = p_invite_headers_rec.INVITE_HEADER_ID;
   l_invite_headers_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_invite_headers_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_invite_headers_rec;
   CLOSE c_complete;

   -- invite_header_id
   IF p_invite_headers_rec.invite_header_id IS NULL THEN
      x_complete_rec.invite_header_id := l_invite_headers_rec.invite_header_id;
   END IF;

   -- object_version_number
   IF p_invite_headers_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_invite_headers_rec.object_version_number;
   END IF;

   -- qp_list_header_id
   IF p_invite_headers_rec.qp_list_header_id IS NULL THEN
      x_complete_rec.qp_list_header_id := l_invite_headers_rec.qp_list_header_id;
   END IF;

   -- invite_type_code
   IF p_invite_headers_rec.invite_type_code IS NULL THEN
      x_complete_rec.invite_type_code := l_invite_headers_rec.invite_type_code;
   END IF;

   -- invite_for_program_id
   IF p_invite_headers_rec.invite_for_program_id IS NULL THEN
      x_complete_rec.invite_for_program_id := l_invite_headers_rec.invite_for_program_id;
   END IF;

   -- created_by
   IF p_invite_headers_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_invite_headers_rec.created_by;
   END IF;

   -- creation_date
   IF p_invite_headers_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_invite_headers_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_invite_headers_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_invite_headers_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_invite_headers_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_invite_headers_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_invite_headers_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_invite_headers_rec.last_update_login;
   END IF;

   -- partner_id
   IF p_invite_headers_rec.partner_id IS NULL THEN
      x_complete_rec.partner_id := l_invite_headers_rec.partner_id;
   END IF;

   -- invite_end_date
   IF p_invite_headers_rec.invite_end_date IS NULL THEN
      x_complete_rec.invite_end_date := l_invite_headers_rec.invite_end_date;
   END IF;

   -- order_header_id
   IF p_invite_headers_rec.order_header_id IS NULL THEN
      x_complete_rec.order_header_id := l_invite_headers_rec.order_header_id;
   END IF;

     -- invited_by_partner_id
   IF p_invite_headers_rec.invited_by_partner_id IS NULL THEN
      x_complete_rec.invited_by_partner_id := l_invite_headers_rec.invited_by_partner_id;
   END IF;


   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Invite_Headers_Rec;




PROCEDURE Default_Invite_Headers_Items ( p_invite_headers_rec IN invite_headers_rec_type ,
                                x_invite_headers_rec OUT NOCOPY invite_headers_rec_type )
IS
   l_invite_headers_rec invite_headers_rec_type := p_invite_headers_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Invite_Headers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_invite_headers_rec               IN   invite_headers_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Invite_Headers';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_invite_headers_rec       invite_headers_rec_type;
l_invite_headers_rec_out   invite_headers_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_invite_headers_;

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
              Check_invite_headers_Items(
                 p_invite_headers_rec        => p_invite_headers_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Invite_Headers_Items (p_invite_headers_rec => p_invite_headers_rec ,
                                x_invite_headers_rec => l_invite_headers_rec) ;
      END IF ;


      Complete_invite_headers_Rec(
         p_invite_headers_rec        => l_invite_headers_rec,
         x_complete_rec              => l_invite_headers_rec_out
      );

      l_invite_headers_rec := l_invite_headers_rec_out;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_invite_headers_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_invite_headers_rec           =>    l_invite_headers_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_UTility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Invite_Headers_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Invite_Headers_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Invite_Headers_;
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
End Validate_Invite_Headers;


PROCEDURE Validate_Invite_Headers_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_invite_headers_rec               IN    invite_headers_rec_type
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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_invite_headers_Rec;

END Pv_Pg_Invite_Headers_PVT;

/
