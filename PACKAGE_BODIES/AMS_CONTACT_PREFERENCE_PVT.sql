--------------------------------------------------------
--  DDL for Package Body AMS_CONTACT_PREFERENCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CONTACT_PREFERENCE_PVT" as
/* $Header: amsvcppb.pls 115.8 2002/12/23 22:11:09 vbhandar ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_CONTACT_PREFERENCE_PVT
-- Purpose
--
-- History
--
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_CONTACT_PREFERENCE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvcppb.pls';

/*
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
*/

-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_contact_preference(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ams_contact_pref_rec       IN   contact_preference_rec_type ,
    p_request_id                 IN   NUMBER,
    x_contact_preference_id      OUT NOCOPY  NUMBER
     )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'create_contact_preference';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER := 1;
   l_contact_preference_id                  NUMBER;
   l_return_status     VARCHAR2(1);
   l_msg_count         NUMBER;
   l_msg_data          VARCHAR2(2000);



    l_hz_contact_pref_rec HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Contact_Preference_PVT;


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

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message( 'Private API: Calling HZ create table PUB');
      END IF;


      l_hz_contact_pref_rec.contact_preference_id   :=  p_ams_contact_pref_rec.contact_preference_id;
      l_hz_contact_pref_rec.contact_level_table   :=  p_ams_contact_pref_rec.contact_level_table;
      l_hz_contact_pref_rec.contact_level_table_id   :=  p_ams_contact_pref_rec.contact_level_table_id;
      l_hz_contact_pref_rec.contact_type   :=  p_ams_contact_pref_rec.contact_type;
      l_hz_contact_pref_rec.preference_code   :=  p_ams_contact_pref_rec.preference_code;
      l_hz_contact_pref_rec.preference_topic_type   :=  p_ams_contact_pref_rec.preference_topic_type;
      l_hz_contact_pref_rec.preference_topic_type_id   :=  p_ams_contact_pref_rec.preference_topic_type_id;
      l_hz_contact_pref_rec.preference_topic_type_code   :=  p_ams_contact_pref_rec.preference_topic_type_code;
      l_hz_contact_pref_rec.preference_start_date   :=  p_ams_contact_pref_rec.preference_start_date;
      l_hz_contact_pref_rec.preference_end_date   :=  p_ams_contact_pref_rec.preference_end_date;
      l_hz_contact_pref_rec.preference_start_time_hr   :=  p_ams_contact_pref_rec.preference_start_time_hr;
      l_hz_contact_pref_rec.preference_end_time_hr   :=  p_ams_contact_pref_rec.preference_end_time_hr;
      l_hz_contact_pref_rec.preference_start_time_mi   :=  p_ams_contact_pref_rec.preference_start_time_mi;
      l_hz_contact_pref_rec.preference_end_time_mi   :=  p_ams_contact_pref_rec.preference_end_time_mi;
      l_hz_contact_pref_rec.max_no_of_interactions   :=  p_ams_contact_pref_rec.max_no_of_interactions;
      l_hz_contact_pref_rec.max_no_of_interact_uom_code   :=  p_ams_contact_pref_rec.max_no_of_interact_uom_code;
      l_hz_contact_pref_rec.requested_by   :=  p_ams_contact_pref_rec.requested_by;
      l_hz_contact_pref_rec.created_by_module   :=  p_ams_contact_pref_rec.created_by_module;
      -- Do not include the following columns. It will make update failed without any error message
      /*
      l_hz_contact_pref_rec.reason_code   :=  p_ams_contact_pref_rec.reason_code;
      l_hz_contact_pref_rec.status   :=  p_ams_contact_pref_rec.status;
      l_hz_contact_pref_rec.application_id   :=  p_ams_contact_pref_rec.application_id;
      */
      HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference
      (
        p_init_msg_list => p_init_msg_list,
        p_contact_preference_rec =>l_hz_contact_pref_rec ,
        x_contact_preference_id => l_contact_preference_id,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data
      );



      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      x_contact_preference_id:=l_contact_preference_id;


      IF (p_request_id IS NOT NULL) THEN
         JTF_FM_TRACK_PVT.UNSUBSCRIBE_USER(p_request_id,p_ams_contact_pref_rec.contact_level_table_id);

      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
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
     ROLLBACK TO Create_Contact_Preference_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Contact_Preference_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Contact_Preference_PVT;
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
End create_contact_preference;




PROCEDURE update_contact_preference(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ams_contact_pref_rec       IN   contact_preference_rec_type ,
    p_request_id                 IN   NUMBER,
    px_object_version_number     IN OUT NOCOPY  NUMBER
    )

 IS
        L_API_NAME                  CONSTANT VARCHAR2(30) := 'update_contact_preference';
        L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
        l_object_version_number     NUMBER;
        l_contact_preference_id     NUMBER;
        l_commit                    VARCHAR2(1) := FND_API.g_true;
        l_return_status             VARCHAR2(1);
        l_msg_count                 NUMBER;
        l_msg_data                  VARCHAR2(2000);
    l_hz_contact_pref_rec HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CONTACT_PREFERENCE_PVT;

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

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: Calling HZ update table PUB');
      END IF;


      l_hz_contact_pref_rec.contact_preference_id   :=  p_ams_contact_pref_rec.contact_preference_id;
      l_hz_contact_pref_rec.contact_level_table   :=  p_ams_contact_pref_rec.contact_level_table;
      l_hz_contact_pref_rec.contact_level_table_id   :=  p_ams_contact_pref_rec.contact_level_table_id;
      l_hz_contact_pref_rec.contact_type   :=  p_ams_contact_pref_rec.contact_type;
      l_hz_contact_pref_rec.preference_code   :=  p_ams_contact_pref_rec.preference_code;
      l_hz_contact_pref_rec.preference_topic_type   :=  p_ams_contact_pref_rec.preference_topic_type;
      l_hz_contact_pref_rec.preference_topic_type_id   :=  p_ams_contact_pref_rec.preference_topic_type_id;
      l_hz_contact_pref_rec.preference_topic_type_code   :=  p_ams_contact_pref_rec.preference_topic_type_code;
      l_hz_contact_pref_rec.preference_start_date   :=  p_ams_contact_pref_rec.preference_start_date;
      l_hz_contact_pref_rec.preference_end_date   :=  p_ams_contact_pref_rec.preference_end_date;
      l_hz_contact_pref_rec.preference_start_time_hr   :=  p_ams_contact_pref_rec.preference_start_time_hr;
      l_hz_contact_pref_rec.preference_end_time_hr   :=  p_ams_contact_pref_rec.preference_end_time_hr;
      l_hz_contact_pref_rec.preference_start_time_mi   :=  p_ams_contact_pref_rec.preference_start_time_mi;
      l_hz_contact_pref_rec.preference_end_time_mi   :=  p_ams_contact_pref_rec.preference_end_time_mi;
      l_hz_contact_pref_rec.max_no_of_interactions   :=  p_ams_contact_pref_rec.max_no_of_interactions;
      l_hz_contact_pref_rec.max_no_of_interact_uom_code   :=  p_ams_contact_pref_rec.max_no_of_interact_uom_code;
         /*
      l_hz_contact_pref_rec.requested_by   :=  p_ams_contact_pref_rec.requested_by;
      l_hz_contact_pref_rec.reason_code   :=  p_ams_contact_pref_rec.reason_code;
      l_hz_contact_pref_rec.status   :=  p_ams_contact_pref_rec.status;
      l_hz_contact_pref_rec.created_by_module   :=  p_ams_contact_pref_rec.created_by_module;
      l_hz_contact_pref_rec.application_id   :=  p_ams_contact_pref_rec.application_id;
         */
      HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference
      (
        p_init_msg_list => p_init_msg_list,
        p_contact_preference_rec => l_hz_contact_pref_rec,
        p_object_version_number => px_object_version_number,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data
      );

       IF (p_request_id IS NOT NULL) THEN
         JTF_FM_TRACK_PVT.UNSUBSCRIBE_USER(p_request_id,p_ams_contact_pref_rec.contact_level_table_id);

      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
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
     ROLLBACK TO UPDATE_CONTACT_PREFERENCE_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_CONTACT_PREFERENCE_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_CONTACT_PREFERENCE_PVT;
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
End update_contact_preference;



END AMS_CONTACT_PREFERENCE_PVT;

/
