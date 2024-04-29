--------------------------------------------------------
--  DDL for Package Body AMS_CONTACT_POINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CONTACT_POINT_PVT" as
/* $Header: amsvcptb.pls 115.4 2002/11/22 08:55:17 jieli ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_CONTACT_POINT_PVT
-- Purpose
--
-- History
--
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_CONTACT_POINT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvcptb.pls';

/*
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
*/

-- Hint: Primary key needs to be returned.
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_contact_POINT(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ams_contact_point_rec       IN     contact_POINT_rec_type ,
    p_ams_edi_rec                 IN     edi_rec_type := g_miss_edi_rec,
    p_ams_email_rec               IN     email_rec_type := g_miss_email_rec,
    p_ams_phone_rec               IN     phone_rec_type := g_miss_phone_rec,
    p_ams_telex_rec               IN     telex_rec_type := g_miss_telex_rec,
    p_ams_web_rec                 IN     web_rec_type := g_miss_web_rec,

    x_contact_POINT_id      OUT NOCOPY  NUMBER
     )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'create_contact_POINT';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_object_version_number     NUMBER := 1;
   l_contact_POINT_id                  NUMBER;
   l_return_status     VARCHAR2(1);
   l_msg_count         NUMBER;
   l_msg_data          VARCHAR2(2000);



    l_hz_contact_point_rec HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
    l_hz_edi_rec HZ_CONTACT_POINT_V2PUB.edi_rec_type;
    l_hz_email_rec HZ_CONTACT_POINT_V2PUB.email_rec_type;
    l_hz_phone_rec HZ_CONTACT_POINT_V2PUB.phone_rec_type;
    l_hz_telex_rec HZ_CONTACT_POINT_V2PUB.telex_rec_type;
    l_hz_web_rec HZ_CONTACT_POINT_V2PUB.web_rec_type;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Contact_POINT_PVT;


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


      l_hz_contact_point_rec.contact_POINT_id   :=  p_ams_contact_point_rec.contact_POINT_id;
      l_hz_contact_point_rec.contact_point_type   :=  p_ams_contact_point_rec.contact_point_type;
      l_hz_contact_point_rec.owner_table_name   :=  p_ams_contact_point_rec.owner_table_name;
      l_hz_contact_point_rec.owner_table_id  :=  p_ams_contact_point_rec.owner_table_id;
      l_hz_contact_point_rec.primary_flag   :=  p_ams_contact_point_rec.primary_flag;
      l_hz_contact_point_rec.orig_system_reference   :=  p_ams_contact_point_rec.orig_system_reference;
      l_hz_contact_point_rec.content_source_type   :=  p_ams_contact_point_rec.content_source_type;
      l_hz_contact_point_rec.attribute_category   :=  p_ams_contact_point_rec.attribute_category;
      l_hz_contact_point_rec.contact_point_purpose   :=  p_ams_contact_point_rec.contact_point_purpose;
      l_hz_contact_point_rec.primary_by_purpose   :=  p_ams_contact_point_rec.primary_by_purpose;
      --l_hz_contact_point_rec.actual_content_source :=  p_ams_contact_point_rec.actual_content_source;


      -- Do not include the following columns. It will make update failed without any error message
      /*
      l_hz_contact_point_rec.status   :=  p_ams_contact_point_rec.status;
      l_hz_contact_point_rec.created_by_module   :=  p_ams_contact_point_rec.created_by_module;
      l_hz_contact_point_rec.application_id   :=  p_ams_contact_point_rec.application_id;
      */

      l_hz_edi_rec.edi_transaction_handling := p_ams_edi_rec.edi_transaction_handling;
      l_hz_edi_rec.edi_id_number := p_ams_edi_rec.edi_id_number;
      l_hz_edi_rec.edi_payment_method := p_ams_edi_rec.edi_payment_method;
      l_hz_edi_rec.edi_payment_format := p_ams_edi_rec.edi_payment_format;
      l_hz_edi_rec.edi_remittance_method := p_ams_edi_rec.edi_remittance_method;
      l_hz_edi_rec.edi_remittance_instruction := p_ams_edi_rec.edi_remittance_instruction;
      l_hz_edi_rec.edi_tp_header_id := p_ams_edi_rec.edi_tp_header_id;
      l_hz_edi_rec.edi_ece_tp_location_code := p_ams_edi_rec.edi_ece_tp_location_code;

      l_hz_email_rec.email_format := p_ams_email_rec.email_format;
      l_hz_email_rec.email_address := p_ams_email_rec.email_address;

      l_hz_phone_rec.phone_calling_calendar := p_ams_phone_rec.phone_calling_calendar;
      l_hz_phone_rec.last_contact_dt_time := p_ams_phone_rec.last_contact_dt_time;
      l_hz_phone_rec.timezone_id := p_ams_phone_rec.timezone_id;
      l_hz_phone_rec.phone_area_code := p_ams_phone_rec.phone_area_code;
      l_hz_phone_rec.phone_country_code := p_ams_phone_rec.phone_country_code;
      l_hz_phone_rec.phone_number := p_ams_phone_rec.phone_number;
      l_hz_phone_rec.phone_extension := p_ams_phone_rec.phone_extension;
      l_hz_phone_rec.phone_line_type := p_ams_phone_rec.phone_line_type;
      l_hz_phone_rec.raw_phone_number := p_ams_phone_rec.raw_phone_number;

      l_hz_telex_rec.telex_number := p_ams_telex_rec.telex_number;

      l_hz_web_rec.web_type := p_ams_web_rec.web_type;
      l_hz_web_rec.url := p_ams_web_rec.url;


      HZ_CONTACT_POINT_V2PUB.create_contact_POINT
      (
	p_init_msg_list => p_init_msg_list,
	p_contact_POINT_rec => l_hz_contact_point_rec ,
        p_edi_rec => l_hz_edi_rec,
        p_email_rec => l_hz_email_rec,
        p_phone_rec => l_hz_phone_rec,
        p_telex_rec => l_hz_telex_rec,
        p_web_rec => l_hz_web_rec,

	x_contact_POINT_id => l_contact_POINT_id,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data
      );


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_msg_count := l_msg_count;
	  x_msg_data := l_msg_data;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      x_contact_POINT_id:=l_contact_POINT_id;

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
     ROLLBACK TO Create_Contact_POINT_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Contact_POINT_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Contact_POINT_PVT;
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
End create_contact_POINT;




PROCEDURE update_contact_POINT(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ams_contact_point_rec       IN   contact_POINT_rec_type ,
    p_ams_edi_rec                 IN     edi_rec_type := g_miss_edi_rec,
    p_ams_email_rec               IN     email_rec_type := g_miss_email_rec,
    p_ams_phone_rec               IN     phone_rec_type := g_miss_phone_rec,
    p_ams_telex_rec               IN     telex_rec_type := g_miss_telex_rec,
    p_ams_web_rec                 IN     web_rec_type := g_miss_web_rec,

    px_object_version_number     IN OUT NOCOPY  NUMBER
    )

 IS
	L_API_NAME                  CONSTANT VARCHAR2(30) := 'update_contact_POINT';
	L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
	l_object_version_number     NUMBER;
	l_contact_POINT_id     NUMBER;
        l_commit                    VARCHAR2(1) := FND_API.g_true;
	l_return_status		    VARCHAR2(1);
        l_msg_count                 NUMBER;
        l_msg_data                  VARCHAR2(2000);

        l_hz_contact_point_rec HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
        l_hz_edi_rec HZ_CONTACT_POINT_V2PUB.edi_rec_type;
        l_hz_email_rec HZ_CONTACT_POINT_V2PUB.email_rec_type;
        l_hz_phone_rec HZ_CONTACT_POINT_V2PUB.phone_rec_type;
        l_hz_telex_rec HZ_CONTACT_POINT_V2PUB.telex_rec_type;
        l_hz_web_rec HZ_CONTACT_POINT_V2PUB.web_rec_type;



 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CONTACT_POINT_PVT;

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


      l_hz_contact_point_rec.contact_POINT_id   :=  p_ams_contact_point_rec.contact_POINT_id;
      l_hz_contact_point_rec.primary_flag   :=  p_ams_contact_point_rec.primary_flag;
   -- Do not include the following columns. It will make update failed without any error message

/*
      l_hz_contact_point_rec.contact_point_type   :=  p_ams_contact_point_rec.contact_point_type;
      l_hz_contact_point_rec.owner_table_name   :=  p_ams_contact_point_rec.owner_table_name;
      l_hz_contact_point_rec.owner_table_id  :=  p_ams_contact_point_rec.owner_table_id;
      l_hz_contact_point_rec.orig_system_reference   :=  p_ams_contact_point_rec.orig_system_reference;
      l_hz_contact_point_rec.content_source_type   :=  p_ams_contact_point_rec.content_source_type;
      l_hz_contact_point_rec.attribute_category   :=  p_ams_contact_point_rec.attribute_category;
      l_hz_contact_point_rec.contact_point_purpose   :=  p_ams_contact_point_rec.contact_point_purpose;
      l_hz_contact_point_rec.primary_by_purpose   :=  p_ams_contact_point_rec.primary_by_purpose;
*/
--      l_hz_contact_point_rec.actual_content_source   :=  p_ams_contact_point_rec.actual_content_source;


      /*
      l_hz_contact_point_rec.status   :=  p_ams_contact_point_rec.status;
      l_hz_contact_point_rec.created_by_module   :=  p_ams_contact_point_rec.created_by_module;
      l_hz_contact_point_rec.application_id   :=  p_ams_contact_point_rec.application_id;
      */
/*
      l_hz_edi_rec.edi_transaction_handling := p_ams_edi_rec.edi_transaction_handling;
      l_hz_edi_rec.edi_id_number := p_ams_edi_rec.edi_id_number;
      l_hz_edi_rec.edi_payment_method := p_ams_edi_rec.edi_payment_method;
      l_hz_edi_rec.edi_payment_format := p_ams_edi_rec.edi_payment_format;
      l_hz_edi_rec.edi_remittance_method := p_ams_edi_rec.edi_remittance_method;
      l_hz_edi_rec.edi_remittance_instruction := p_ams_edi_rec.edi_remittance_instruction;
      l_hz_edi_rec.edi_tp_header_id := p_ams_edi_rec.edi_tp_header_id;
      l_hz_edi_rec.edi_ece_tp_location_code := p_ams_edi_rec.edi_ece_tp_location_code;

      l_hz_email_rec.email_format := p_ams_email_rec.email_format;
      l_hz_email_rec.email_address := p_ams_email_rec.email_address;

      l_hz_phone_rec.phone_calling_calendar := p_ams_phone_rec.phone_calling_calendar;
      l_hz_phone_rec.last_contact_dt_time := p_ams_phone_rec.last_contact_dt_time;
      l_hz_phone_rec.timezone_id := p_ams_phone_rec.timezone_id;
      l_hz_phone_rec.phone_area_code := p_ams_phone_rec.phone_area_code;
      l_hz_phone_rec.phone_country_code := p_ams_phone_rec.phone_country_code;
      l_hz_phone_rec.phone_number := p_ams_phone_rec.phone_number;
      l_hz_phone_rec.phone_extension := p_ams_phone_rec.phone_extension;
      l_hz_phone_rec.phone_line_type := p_ams_phone_rec.phone_line_type;
      l_hz_phone_rec.raw_phone_number := p_ams_phone_rec.raw_phone_number;

      l_hz_telex_rec.telex_number := p_ams_telex_rec.telex_number;

      l_hz_web_rec.web_type := p_ams_web_rec.web_type;
      l_hz_web_rec.url := p_ams_web_rec.url;
*/

      HZ_CONTACT_POINT_V2PUB.update_contact_POINT
      (
	p_init_msg_list => p_init_msg_list,
	p_contact_POINT_rec => l_hz_contact_point_rec,
        p_edi_rec => l_hz_edi_rec,
        p_email_rec => l_hz_email_rec,
        p_phone_rec => l_hz_phone_rec,
        p_telex_rec => l_hz_telex_rec,
        p_web_rec => l_hz_web_rec,

        p_object_version_number => px_object_version_number,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data
      );


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
     ROLLBACK TO UPDATE_CONTACT_POINT_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_CONTACT_POINT_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_CONTACT_POINT_PVT;
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
End update_contact_POINT;



END AMS_CONTACT_POINT_PVT;

/
