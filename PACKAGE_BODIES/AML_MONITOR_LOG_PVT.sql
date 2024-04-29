--------------------------------------------------------
--  DDL for Package Body AML_MONITOR_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_MONITOR_LOG_PVT" as
 /* $Header: amlvlmlb.pls 115.1 2003/01/20 18:37:37 swkhanna ship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name  AML_Monitor_Log_PVT
 -- History
 -- 11-27-2002 sujrama created
 -- ===============================================================
 G_PKG_NAME CONSTANT VARCHAR2(30):= 'AML_Monitor_Log_PVT';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'amlvlmlb.pls';


AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE Create_Monitor_Log(
      p_api_version_number         IN   NUMBER
     ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
     ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
     ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
     ,p_monitor_log_rec            IN   monitor_log_rec_type  := g_miss_monitor_log_rec
     ,x_monitor_log_id             OUT NOCOPY  NUMBER
     ,x_return_status              OUT NOCOPY  VARCHAR2
     ,x_msg_count                  OUT NOCOPY  NUMBER
     ,x_msg_data                   OUT NOCOPY  VARCHAR2
      )
  IS
 L_API_NAME                     CONSTANT VARCHAR2(30) := 'Create_Monitor_Log';
 L_API_VERSION_NUMBER           CONSTANT NUMBER   := 2.0;
    l_return_status_full        VARCHAR2(1);
    l_object_version_number     NUMBER := 1;
    l_org_id                    NUMBER ; --:= FND_API.G_MISS_NUM;
    l_monitor_log_id            NUMBER;
    l_dummy                     NUMBER;
    CURSOR c_id IS
       SELECT aml_monitor_log_s.NEXTVAL
       FROM dual;
    CURSOR c_id_exists (l_id IN NUMBER) IS
       SELECT 1
       FROM AML_MONITOR_LOG
       WHERE monitor_log_id = l_id;
 BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT create_monitor_log_pvt;
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
       IF (AS_DEBUG_LOW_ON) THEN
           AS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
       END IF;


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF FND_GLOBAL.User_Id IS NULL  THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
			FND_MESSAGE.Set_Name('AMS', 'UT_CANNOT_GET_PROFILE_VALUE');
			FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Debug Message
       IF (AS_DEBUG_LOW_ON) THEN
		AS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,  'Private API: Calling create table handler');
       END IF;

	-- Invoke table handler(As_Monitor_Log_Pkg.Insert_Row)
       Aml_Monitor_Log_Pkg.Insert_Row(
           px_monitor_log_id  => l_monitor_log_id,
          -- p_monitor_execution_id  => p_monitor_log_rec.monitor_execution_id,
           p_last_update_date  => SYSDATE,
           p_last_updated_by  => FND_GLOBAL.USER_ID,
           p_creation_date  => SYSDATE,
           p_created_by  => FND_GLOBAL.USER_ID,
           p_last_update_login  => FND_GLOBAL.conc_login_id,
           p_object_version_number  => l_object_version_number,
           p_request_id  => p_monitor_log_rec.request_id,
           p_program_application_id  => p_monitor_log_rec.program_application_id,
           p_program_id  => p_monitor_log_rec.program_id,
           p_program_update_date  => p_monitor_log_rec.program_update_date,
           p_monitor_condition_id  => p_monitor_log_rec.monitor_condition_id,
           p_recipient_role  => p_monitor_log_rec.recipient_role,
           p_monitor_action => p_monitor_log_rec.monitor_action,
           p_recipient_resource_id  => p_monitor_log_rec.recipient_resource_id,
           p_sales_lead_id  => p_monitor_log_rec.sales_lead_id,
           p_attribute_category  => p_monitor_log_rec.attribute_category,
           p_attribute1  => p_monitor_log_rec.attribute1,
           p_attribute2  => p_monitor_log_rec.attribute2,
           p_attribute3  => p_monitor_log_rec.attribute3,
           p_attribute4  => p_monitor_log_rec.attribute4,
           p_attribute5  => p_monitor_log_rec.attribute5,
           p_attribute6  => p_monitor_log_rec.attribute6,
           p_attribute7  => p_monitor_log_rec.attribute7,
           p_attribute8  => p_monitor_log_rec.attribute8,
           p_attribute9  => p_monitor_log_rec.attribute9,
           p_attribute10  => p_monitor_log_rec.attribute10,
           p_attribute11  => p_monitor_log_rec.attribute11,
           p_attribute12  => p_monitor_log_rec.attribute12,
           p_attribute13  => p_monitor_log_rec.attribute13,
           p_attribute14  => p_monitor_log_rec.attribute14,
           p_attribute15  => p_monitor_log_rec.attribute15
       );

          x_monitor_log_id := l_monitor_log_id;
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
       IF (AS_DEBUG_LOW_ON) THEN
		AS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
       END IF;

       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_Monitor_Log_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_Monitor_Log_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_Monitor_Log_PVT;
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
 End Create_Monitor_Log;


 PROCEDURE Update_Monitor_Log(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      p_monitor_log_rec               IN    monitor_log_rec_type ,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2
    )
  IS
 CURSOR c_get_monitor_log(monitor_log_id NUMBER) IS
     SELECT *
     FROM  AML_MONITOR_LOG
     WHERE  monitor_log_id = p_monitor_log_rec.monitor_log_id;
 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Monitor_Log';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 2.0;
 -- Local Variables
 l_object_version_number     NUMBER;
 l_monitor_log_id    NUMBER;
 l_ref_monitor_log_rec  c_get_Monitor_Log%ROWTYPE ;
 l_tar_monitor_log_rec  monitor_log_rec_type := P_monitor_log_rec;
 l_rowid  ROWID;
  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT update_monitor_log_pvt;
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
       IF (AS_DEBUG_LOW_ON) THEN
	   AS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
       END IF;


       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Debug Message
       IF (AS_DEBUG_LOW_ON) THEN
           AS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: - Open Cursor to Select');
       END IF;

       OPEN c_get_Monitor_Log( l_tar_monitor_log_rec.monitor_log_id);
         FETCH c_get_Monitor_Log INTO l_ref_monitor_log_rec  ;
           If ( c_get_Monitor_Log%NOTFOUND) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		FND_MESSAGE.Set_Name('AMS', 'API_MISSING_UPDATE_TARGET');
		FND_MESSAGE.Set_Token ('INFO', 'Monitor_log', FALSE);
		FND_MSG_PUB.Add;
            END IF;
		RAISE FND_API.G_EXC_ERROR;
           END IF;
        -- Debug Message
           IF (AS_DEBUG_LOW_ON) THEN
                 AS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: - Close Cursor');
           END IF;
       CLOSE     c_get_Monitor_Log;

       If (l_tar_monitor_log_rec.last_update_date is NULL or
           l_tar_monitor_log_rec.last_update_date = FND_API.G_MISS_DATE ) Then
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
			FND_MESSAGE.Set_Name('AMS', 'API_MISSING_ID');
			FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
			FND_MSG_PUB.ADD;
  		END IF;
           raise FND_API.G_EXC_ERROR;
       End if;

       If (to_char(l_tar_monitor_log_rec.last_update_date,'DD-MON-RRRR') <> TO_CHAR(l_ref_monitor_log_rec.last_update_date,'DD-MON-RRRR')) Then
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)  THEN
			FND_MESSAGE.Set_Name('AMS', 'API_RECORD_CHANGED');
			FND_MESSAGE.Set_Token('INFO', 'Monitor_Log', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
           raise FND_API.G_EXC_ERROR;
       End if;

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;
        -- Debug Message
       IF (AS_DEBUG_LOW_ON) THEN
		AS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
       END IF;
       -- Invoke table handler(As_Monitor_Log_Pkg.Update_Row)
       AML_Monitor_Log_Pkg.Update_Row(
           p_monitor_log_id  => p_monitor_log_rec.monitor_log_id,
          -- p_monitor_execution_id  => p_monitor_log_rec.monitor_execution_id,
           p_last_update_date  => SYSDATE,
           p_last_updated_by  => FND_GLOBAL.USER_ID,
	   p_CREATION_DATE => SYSDATE,
           p_CREATED_BY => FND_GLOBAL.USER_ID,
           p_last_update_login  => FND_GLOBAL.conc_login_id,
           p_object_version_number  => p_monitor_log_rec.object_version_number,
           p_request_id  => p_monitor_log_rec.request_id,
           p_program_application_id  => p_monitor_log_rec.program_application_id,
           p_program_id  => p_monitor_log_rec.program_id,
           p_program_update_date  => p_monitor_log_rec.program_update_date,
           p_monitor_condition_id  => p_monitor_log_rec.monitor_condition_id,
           p_recipient_role  => p_monitor_log_rec.recipient_role,
           p_monitor_action => p_monitor_log_rec.monitor_action,
           p_recipient_resource_id  => p_monitor_log_rec.recipient_resource_id,
           p_sales_lead_id  => p_monitor_log_rec.sales_lead_id,
           p_attribute_category  => p_monitor_log_rec.attribute_category,
           p_attribute1  => p_monitor_log_rec.attribute1,
           p_attribute2  => p_monitor_log_rec.attribute2,
           p_attribute3  => p_monitor_log_rec.attribute3,
           p_attribute4  => p_monitor_log_rec.attribute4,
           p_attribute5  => p_monitor_log_rec.attribute5,
           p_attribute6  => p_monitor_log_rec.attribute6,
           p_attribute7  => p_monitor_log_rec.attribute7,
           p_attribute8  => p_monitor_log_rec.attribute8,
           p_attribute9  => p_monitor_log_rec.attribute9,
           p_attribute10  => p_monitor_log_rec.attribute10,
           p_attribute11  => p_monitor_log_rec.attribute11,
           p_attribute12  => p_monitor_log_rec.attribute12,
           p_attribute13  => p_monitor_log_rec.attribute13,
           p_attribute14  => p_monitor_log_rec.attribute14,
           p_attribute15  => p_monitor_log_rec.attribute15
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
       IF (AS_DEBUG_LOW_ON) THEN
           AS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
       END IF;
       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_Monitor_Log_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_Monitor_Log_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_Monitor_Log_PVT;
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
 End Update_Monitor_Log;

 PROCEDURE Delete_Monitor_Log(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_monitor_log_id                   IN  NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2
    )
  IS
 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Monitor_Log';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 2.0;
 l_object_version_number     NUMBER;
  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT delete_monitor_log_pvt;
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
       IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
       END IF;

       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- Api body
       --
       -- Debug Message
       IF (AS_DEBUG_LOW_ON) THEN
           AS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,  'Private API: Calling delete table handler');
       END IF;

       -- Invoke table handler(As_Monitor_Log_Pkg.Delete_Row)
       AMl_Monitor_Log_Pkg.Delete_Row(
           p_monitor_log_id  => p_monitor_log_id
      --,          p_object_version_number => p_object_version_number
      );
       --
       -- End of API body
       --
       -- Standard check for p_commit
       IF FND_API.to_Boolean( p_commit )
       THEN
          COMMIT WORK;
       END IF;
       -- Debug Message
       IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
       END IF;
       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_Monitor_Log_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_Monitor_Log_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );
    WHEN OTHERS THEN
      ROLLBACK TO DELETE_Monitor_Log_PVT;
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
 End Delete_Monitor_Log;
 END AML_Monitor_Log_PVT;

/
