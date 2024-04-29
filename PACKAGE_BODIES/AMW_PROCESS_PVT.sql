--------------------------------------------------------
--  DDL for Package Body AMW_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PROCESS_PVT" as
/* $Header: amwvprlb.pls 115.6 2004/04/22 21:26:39 gakumar noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_Process_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_Process_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwvprlb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;



procedure Create_process(
  p_api_version_number in number,
  p_init_msg_list in varchar2 := FND_API.G_FALSE,
  p_commit in varchar2 := FND_API.G_FALSE,
  p_validation_level in number :=FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY varchar2,
  x_msg_count OUT NOCOPY number,
  x_msg_data OUT NOCOPY varchar2,
  p_process_tbl IN process_tbl_type  := g_miss_process_tbl
)
is
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Process';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_PROCESS_ID                  NUMBER;
begin
      SAVEPOINT CREATE_Process;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
     FOR i IN p_process_tbl.FIRST .. p_process_tbl.LAST LOOP

         Create_Process_rec(p_api_version_number,
                       p_init_msg_list,
                       p_commit,
                       p_validation_level,
                       x_return_status,
                       x_msg_count,
                       x_msg_data,
                       p_process_tbl(i),
                          l_PROCESS_ID                  );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     END LOOP;
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMW_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Process;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Process;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Process;
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
End Create_Process;


procedure update_process(
  p_api_version_number in number,
  p_init_msg_list in varchar2 := FND_API.G_FALSE,
  p_commit in varchar2 := FND_API.G_FALSE,
  p_validation_level in number :=FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY varchar2,
  x_msg_count OUT NOCOPY number,
  x_msg_data OUT NOCOPY varchar2,
  p_process_tbl IN process_tbl_type  := g_miss_process_tbl
)
is
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Process';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_PROCESS_ID                  NUMBER;

begin
      SAVEPOINT update_Process;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
     FOR i IN p_process_tbl.FIRST .. p_process_tbl.LAST LOOP

        Update_Process_rec(p_api_version_number,
                       p_init_msg_list,
                       p_commit,
                       p_validation_level,
                       x_return_status,
                       x_msg_count,
                       x_msg_data,
                       p_process_tbl(i),
                          l_object_version_number   );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     END LOOP;
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMW_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_Process;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_Process;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO update_Process;
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
End update_Process;



-- Hint: Primary key needs to be returned.
PROCEDURE Create_Process_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_process_rec               IN   process_rec_type  := g_miss_process_rec,
    x_process_id                   OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Process';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER ;
   l_PROCESS_ID                  NUMBER;
   l_PROCESS_rev_ID              NUMBER;
   l_dummy       NUMBER;

   CURSOR c_id IS
      SELECT AMW_PROCESS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMW_PROCESS
      WHERE PROCESS_ID = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Process_PVT;

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
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_process_rec.PROCESS_ID IS NULL OR p_process_rec.PROCESS_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_PROCESS_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_PROCESS_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;
/*
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMW_UTILITY_PVT.debug_message('Private API: Validate_Process');

          -- Invoke validation procedures
          Validate_process(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_process_rec  =>  p_process_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/

      -- Debug Message
      AMW_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(AMW_PROCESS_PKG.Insert_Row)
      AMW_PROCESS_PKG.Insert_Row(
	      p_significant_process_flag => p_process_rec.significant_process_flag,
	      p_standard_process_flag => fnd_profile.value('AMW_SET_STD_PROCESS'),
          p_approval_status => 'A',
          p_certification_status => p_process_rec.certification_status,
          p_process_owner_id => p_process_rec.process_owner_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_item_type  => p_process_rec.item_type,
          p_name  => p_process_rec.name,
          p_created_from  => p_process_rec.created_from,
          p_request_id  => p_process_rec.request_id,
          p_program_application_id  => p_process_rec.program_application_id,
          p_program_id  => p_process_rec.program_id,
          p_program_update_date  => p_process_rec.program_update_date,
          p_attribute_category  => p_process_rec.attribute_category,
          p_attribute1  => p_process_rec.attribute1,
          p_attribute2  => p_process_rec.attribute2,
          p_attribute3  => p_process_rec.attribute3,
          p_attribute4  => p_process_rec.attribute4,
          p_attribute5  => p_process_rec.attribute5,
          p_attribute6  => p_process_rec.attribute6,
          p_attribute7  => p_process_rec.attribute7,
          p_attribute8  => p_process_rec.attribute8,
          p_attribute9  => p_process_rec.attribute9,
          p_attribute10  => p_process_rec.attribute10,
          p_attribute11  => p_process_rec.attribute11,
          p_attribute12  => p_process_rec.attribute12,
          p_attribute13  => p_process_rec.attribute13,
          p_attribute14  => p_process_rec.attribute14,
          p_attribute15  => p_process_rec.attribute15,
          p_security_group_id  => p_process_rec.security_group_id,
          px_object_version_number  => l_object_version_number,
		  p_control_count => p_process_rec.control_count,
          p_risk_count => p_process_rec.risk_count,
          p_org_count => p_process_rec.org_count,
		  px_process_rev_id => l_process_id,
		  ---px_process_rev_id => p_process_rec.process_rev_id,
          px_process_id  => l_process_id);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
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
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMW_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Process_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Process_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Process_PVT;
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
End Create_Process_rec;


PROCEDURE Update_Process_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_process_rec               IN    process_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS
/*
CURSOR c_get_process(last_update_date NUMBER) IS
    SELECT *
    FROM  AMW_PROCESS
    -- Hint: Developer need to provide Where clause
*/
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Process';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_PROCESS_ID    NUMBER;
--l_ref_process_rec  c_get_Process%ROWTYPE ;
l_tar_process_rec  AMW_Process_PVT.process_rec_type := P_process_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Process_PVT;

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
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      AMW_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

/*
      OPEN c_get_Process( l_tar_process_rec.last_update_date);

      FETCH c_get_Process INTO l_ref_process_rec  ;

       If ( c_get_Process%NOTFOUND) THEN
  AMW_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Process') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       AMW_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Process;
*/


      If (l_tar_process_rec.object_version_number is NULL or
          l_tar_process_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMW_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_process_rec.object_version_number <> p_process_rec.object_version_number) Then
  AMW_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Process') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMW_UTILITY_PVT.debug_message('Private API: Validate_Process');

          -- Invoke validation procedures
          Validate_process(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_process_rec  =>  p_process_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMW_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(AMW_PROCESS_PKG.Update_Row)
      AMW_PROCESS_PKG.Update_Row(
	      p_significant_process_flag => p_process_rec.significant_process_flag,
          p_standard_process_flag => p_process_rec.standard_process_flag,
          p_approval_status => p_process_rec.approval_status,
          p_certification_status => p_process_rec.certification_status,
          p_process_owner_id => p_process_rec.process_owner_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => G_USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => G_USER_ID,
          p_last_update_login  => G_LOGIN_ID,
          p_item_type  => p_process_rec.item_type,
          p_name  => p_process_rec.name,
          p_created_from  => p_process_rec.created_from,
          p_request_id  => p_process_rec.request_id,
          p_program_application_id  => p_process_rec.program_application_id,
          p_program_id  => p_process_rec.program_id,
          p_program_update_date  => p_process_rec.program_update_date,
          p_attribute_category  => p_process_rec.attribute_category,
          p_attribute1  => p_process_rec.attribute1,
          p_attribute2  => p_process_rec.attribute2,
          p_attribute3  => p_process_rec.attribute3,
          p_attribute4  => p_process_rec.attribute4,
          p_attribute5  => p_process_rec.attribute5,
          p_attribute6  => p_process_rec.attribute6,
          p_attribute7  => p_process_rec.attribute7,
          p_attribute8  => p_process_rec.attribute8,
          p_attribute9  => p_process_rec.attribute9,
          p_attribute10  => p_process_rec.attribute10,
          p_attribute11  => p_process_rec.attribute11,
          p_attribute12  => p_process_rec.attribute12,
          p_attribute13  => p_process_rec.attribute13,
          p_attribute14  => p_process_rec.attribute14,
          p_attribute15  => p_process_rec.attribute15,
          p_security_group_id  => p_process_rec.security_group_id,
		  p_control_count => p_process_rec.control_count,
          p_risk_count => p_process_rec.risk_count,
          p_org_count => p_process_rec.org_count,
          p_object_version_number  => p_process_rec.object_version_number,
		  p_process_rev_id => p_process_rec.process_rev_id,
          p_process_id  => p_process_rec.process_id);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMW_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Process_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Process_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Process_PVT;
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
End Update_Process_rec;


PROCEDURE Delete_Process(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_process_rev_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Process';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Process_PVT;

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
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      AMW_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(AMW_PROCESS_PKG.Delete_Row)
      AMW_PROCESS_PKG.Delete_Row(
          p_PROCESS_rev_ID  => p_PROCESS_rev_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMW_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Process_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Process_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Process_PVT;
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
End Delete_Process;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Process(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_process_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Process';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_PROCESS_ID                  NUMBER;

CURSOR c_Process IS
   SELECT PROCESS_ID
   FROM AMW_PROCESS
   WHERE PROCESS_ID = p_PROCESS_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

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

  AMW_Utility_PVT.debug_message(l_full_name||': start');
  OPEN c_Process;

  FETCH c_Process INTO l_PROCESS_ID;

  IF (c_Process%NOTFOUND) THEN
    CLOSE c_Process;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMW', 'AMW_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Process;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  AMW_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN AMW_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Process_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Process_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Process_PVT;
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
End Lock_Process;


PROCEDURE check_process_uk_items(
    p_process_rec               IN   process_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMW_Utility_PVT.check_uniqueness(
         'AMW_PROCESS',
         'PROCESS_ID = ''' || p_process_rec.PROCESS_ID ||''''
         );
      ELSE
         l_valid_flag := AMW_Utility_PVT.check_uniqueness(
         'AMW_PROCESS',
         'PROCESS_ID = ''' || p_process_rec.PROCESS_ID ||
         ''' AND PROCESS_ID <> ' || p_process_rec.PROCESS_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_PROCESS_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_process_uk_items;

PROCEDURE check_process_req_items(
    p_process_rec               IN  process_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_process_rec.last_update_date = FND_API.g_miss_date OR p_process_rec.last_update_date IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_process_rec.last_updated_by = FND_API.g_miss_num OR p_process_rec.last_updated_by IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_process_rec.creation_date = FND_API.g_miss_date OR p_process_rec.creation_date IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_process_rec.created_by = FND_API.g_miss_num OR p_process_rec.created_by IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_process_rec.item_type = FND_API.g_miss_char OR p_process_rec.item_type IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_item_type');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_process_rec.name = FND_API.g_miss_char OR p_process_rec.name IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_name');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_process_rec.process_id = FND_API.g_miss_num OR p_process_rec.process_id IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_process_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_process_rec.last_update_date IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_last_update_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_process_rec.last_updated_by IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_last_updated_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_process_rec.creation_date IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_creation_date');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_process_rec.created_by IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_created_by');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_process_rec.item_type IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_item_type');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_process_rec.name IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_name');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_process_rec.process_id IS NULL THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_process_NO_process_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_process_req_items;

PROCEDURE check_process_FK_items(
    p_process_rec IN process_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_process_FK_items;

PROCEDURE check_process_Lookup_items(
    p_process_rec IN process_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_process_Lookup_items;

PROCEDURE Check_process_Items (
    P_process_rec     IN    process_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_process_uk_items(
      p_process_rec => p_process_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_process_req_items(
      p_process_rec => p_process_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls

   check_process_FK_items(
      p_process_rec => p_process_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_process_Lookup_items(
      p_process_rec => p_process_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_process_Items;


PROCEDURE Complete_process_Rec (
    P_process_rec     IN    process_rec_type,
     x_complete_rec        OUT NOCOPY    process_rec_type
    );

PROCEDURE Complete_process_Rec (
   p_process_rec IN process_rec_type,
   x_complete_rec OUT NOCOPY process_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM amw_process
      WHERE process_id = p_process_rec.process_id;
   l_process_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_process_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_process_rec;
   CLOSE c_complete;

   -- last_update_date
   IF p_process_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_process_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_process_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_process_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_process_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_process_rec.creation_date;
   END IF;

   -- created_by
   IF p_process_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_process_rec.created_by;
   END IF;

   -- last_update_login
   IF p_process_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_process_rec.last_update_login;
   END IF;

   -- item_type
   IF p_process_rec.item_type = FND_API.g_miss_char THEN
      x_complete_rec.item_type := l_process_rec.item_type;
   END IF;

   -- name
   IF p_process_rec.name = FND_API.g_miss_char THEN
      x_complete_rec.name := l_process_rec.name;
   END IF;

   -- created_from
   IF p_process_rec.created_from = FND_API.g_miss_char THEN
      x_complete_rec.created_from := l_process_rec.created_from;
   END IF;

   -- request_id
   IF p_process_rec.request_id = FND_API.g_miss_num THEN
      x_complete_rec.request_id := l_process_rec.request_id;
   END IF;

   -- program_application_id
   IF p_process_rec.program_application_id = FND_API.g_miss_num THEN
      x_complete_rec.program_application_id := l_process_rec.program_application_id;
   END IF;

   -- program_id
   IF p_process_rec.program_id = FND_API.g_miss_num THEN
      x_complete_rec.program_id := l_process_rec.program_id;
   END IF;

   -- program_update_date
   IF p_process_rec.program_update_date = FND_API.g_miss_date THEN
      x_complete_rec.program_update_date := l_process_rec.program_update_date;
   END IF;

   -- attribute_category
   IF p_process_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_process_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_process_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_process_rec.attribute1;
   END IF;

   -- attribute2
   IF p_process_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_process_rec.attribute2;
   END IF;

   -- attribute3
   IF p_process_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_process_rec.attribute3;
   END IF;

   -- attribute4
   IF p_process_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_process_rec.attribute4;
   END IF;

   -- attribute5
   IF p_process_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_process_rec.attribute5;
   END IF;

   -- attribute6
   IF p_process_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_process_rec.attribute6;
   END IF;

   -- attribute7
   IF p_process_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_process_rec.attribute7;
   END IF;

   -- attribute8
   IF p_process_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_process_rec.attribute8;
   END IF;

   -- attribute9
   IF p_process_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_process_rec.attribute9;
   END IF;

   -- attribute10
   IF p_process_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_process_rec.attribute10;
   END IF;

   -- attribute11
   IF p_process_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_process_rec.attribute11;
   END IF;

   -- attribute12
   IF p_process_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_process_rec.attribute12;
   END IF;

   -- attribute13
   IF p_process_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_process_rec.attribute13;
   END IF;

   -- attribute14
   IF p_process_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_process_rec.attribute14;
   END IF;

   -- attribute15
   IF p_process_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_process_rec.attribute15;
   END IF;

   -- security_group_id
   IF p_process_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := l_process_rec.security_group_id;
   END IF;

   -- object_version_number
   IF p_process_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_process_rec.object_version_number;
   END IF;

   -- process_id
   IF p_process_rec.process_id = FND_API.g_miss_num THEN
      x_complete_rec.process_id := l_process_rec.process_id;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_process_Rec;
PROCEDURE Validate_process(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_process_rec               IN   process_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Process';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_process_rec  AMW_Process_PVT.process_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Process_;

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
              Check_process_Items(
                 p_process_rec        => p_process_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_process_Rec(
         p_process_rec        => p_process_rec,
         x_complete_rec        => l_process_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_process_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_process_rec           =>    l_process_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMW_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Process_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Process_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Process_;
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
End Validate_Process;


PROCEDURE Validate_process_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_process_rec               IN    process_rec_type
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
      AMW_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_process_Rec;

END AMW_Process_PVT;

/
