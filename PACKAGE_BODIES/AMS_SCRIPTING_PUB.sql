--------------------------------------------------------
--  DDL for Package Body AMS_SCRIPTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SCRIPTING_PUB" as
/* $Header: amspscrb.pls 115.5 2003/02/18 21:07:09 sodixit noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          ams_scripting_pub
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ams_scripting_pub';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amspscrb.pls';


PROCEDURE Create_Customer(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_party_id			 IN OUT NOCOPY NUMBER,
    p_b2b_flag			 IN   VARCHAR2,
    p_import_list_header_id      IN   NUMBER,

    p_ams_party_rec              IN   ams_party_rec_type  := g_miss_ams_party_rec,

    x_new_party			 OUT  NOCOPY VARCHAR2,
    p_component_name             OUT  NOCOPY VARCHAR2
)

IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Customer';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;



 partyRec       	hz_party_v2pub.party_rec_type;
 organisationRec       	hz_party_v2pub.organization_rec_type;
 personRec      	hz_party_v2pub.person_rec_type;
 locationRec    	hz_location_v2pub.location_rec_type;
 partySiteRec       	hz_party_site_v2pub.party_site_rec_type;
 partySiteUseRec   	hz_party_site_v2pub.party_site_use_rec_type;
 contactPointRec      	hz_contact_point_v2pub.contact_point_rec_type;
 emailRec       	hz_contact_point_v2pub.email_rec_type;
 phoneRec       	hz_contact_point_v2pub.phone_rec_type;
 orgContactRec        	hz_party_contact_v2pub.org_contact_rec_type;
 webRec			hz_contact_point_v2pub.web_rec_type;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Customer_Pub;

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

    -- Local variable initialization

      	--partyRec.party_id := p_party_id;


	organisationRec.organization_name := p_ams_party_rec.organization;

	--personRec.party_rec     	:= p_ams_party_recpartyRec;
	personRec.person_first_name     := p_ams_party_rec.firstname;
	personRec.person_middle_name	:= p_ams_party_rec.middlename;
	personRec.person_last_name      := p_ams_party_rec.lastname ;

	locationRec.country 		:= p_ams_party_rec.country;
	locationRec.address1		:= p_ams_party_rec.address1;
	locationRec.address2 		:= p_ams_party_rec.address2;
	locationRec.address3 		:= p_ams_party_rec.address3;
	locationRec.address4 		:= p_ams_party_rec.address4;
	locationRec.city 		:= p_ams_party_rec.city;
	locationRec.postal_code 	:= p_ams_party_rec.postal_code;
	locationRec.state 		:= p_ams_party_rec.state;
	locationRec.county 		:= p_ams_party_rec.county;

	emailRec.email_address 		:= p_ams_party_rec.email;

	phoneRec.phone_area_code 	:= p_ams_party_rec.dayareacode;
	phoneRec.phone_number 		:= p_ams_party_rec.daynumber;
	phoneRec.phone_extension 	:= p_ams_party_rec.dayextension;




      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Public API: Calling AMS_List_Import_PUB.Create_Customer');

	AMS_List_Import_PUB.Create_Customer (
	p_api_version              => p_api_version_number,
	p_init_msg_list            => p_init_msg_list,
	p_commit                   => p_commit,
	p_validation_level         => FND_API.g_valid_level_full,
	x_return_status            => x_return_status,
	x_msg_count                => x_msg_count,
	x_msg_data                 => x_msg_data,
	p_party_id                 => p_party_id,
	p_b2b_flag                 => p_b2b_flag,
	p_import_list_header_id    => p_import_list_header_id,
	p_party_rec                => partyRec,
	p_org_rec                  => organisationRec,
	p_person_rec               => personRec,
	p_location_rec             => locationRec,
	p_psite_rec                => partySiteRec,
	p_cpoint_rec               => contactPointRec,
	p_email_rec                => emailRec,
	p_phone_rec                => phoneRec,
	p_fax_rec                  => phoneRec,
	p_ocon_rec                 => orgContactRec,
	p_siteuse_rec		   => partySiteUseRec,
        p_web_rec                  => webRec,
	x_new_party                => x_new_party,
	p_component_name           => p_component_name);



      --subir
      IF x_return_status is NULL THEN
      	x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
      --end


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
     ROLLBACK TO Create_Customer_Pub;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Customer_Pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Customer_Pub;
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
End Create_Customer;









PROCEDURE Update_Person_Profile(
	p_api_version_number		IN  NUMBER,
	p_init_msg_list                 IN  VARCHAR2	 := FND_API.G_FALSE,
	p_commit			IN  VARCHAR2     := FND_API.G_FALSE,
	p_validation_level		IN  NUMBER       := FND_API.g_valid_level_full,
	x_return_status                 OUT NOCOPY VARCHAR2,
	x_msg_count                     OUT NOCOPY NUMBER,
	x_msg_data                      OUT NOCOPY VARCHAR2,

	p_party_id			IN      NUMBER,
	p_profile_id                    IN  OUT NOCOPY NUMBER,
	p_person_profile_rec            IN      ams_person_profile_rec_type := g_miss_ams_person_profile_rec,
	p_party_object_version_number   IN  OUT NOCOPY  NUMBER
)
IS

	L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Person_Profile';
	L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

	l_personRec      	hz_party_v2pub.person_rec_type;
	l_partyRec       	hz_party_v2pub.party_rec_type;


BEGIN
	-- Standard Start of API savepoint
	SAVEPOINT Create_Customer_Pub;

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

	-- Local variable initialization

	---------------------------------------------------------------------------------

	l_partyRec.party_id := p_party_id;

	l_personRec.date_of_birth := p_person_profile_rec.date_of_birth;
	l_personRec.place_of_birth := p_person_profile_rec.place_of_birth;
	l_personRec.gender := p_person_profile_rec.gender;
	l_personRec.marital_status := p_person_profile_rec.marital_status;
	l_personRec.marital_status_effective_date := p_person_profile_rec.marital_status_effective_date;
	l_personRec.personal_income := p_person_profile_rec.personal_income;
	l_personRec.head_of_household_flag := p_person_profile_rec.head_of_household_flag;
	l_personRec.household_income := p_person_profile_rec.household_income;
	l_personRec.household_size := p_person_profile_rec.household_size;
	l_personRec.rent_own_ind := p_person_profile_rec.rent_own_ind;

	l_personRec.party_rec := l_partyRec;

	---------------------------------------------------------------------------------


	-- =========================================================================
	-- Validate Environment
	-- =========================================================================

	IF FND_GLOBAL.USER_ID IS NULL
	THEN
		AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Debug Message
	AMS_UTILITY_PVT.debug_message( 'Public API: Calling HZ_PARTY_V2PUB.UPDATE_PERSON');
	---------------------------------------------------------------------------------

	hz_party_v2pub.update_person (
	    p_init_msg_list => p_init_msg_list,
	    p_person_rec => l_personRec,
	    p_party_object_version_number  => p_party_object_version_number,
	    x_profile_id => p_profile_id,
	    x_return_status => x_return_status,
	    x_msg_count => x_msg_count,
	    x_msg_data => x_msg_data
	);

	---------------------------------------------------------------------------------


	IF x_return_status is NULL THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;
	--end


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
		ROLLBACK TO Create_Customer_Pub;
		x_return_status := FND_API.G_RET_STS_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
		    p_encoded => FND_API.G_FALSE,
		    p_count   => x_msg_count,
		    p_data    => x_msg_data
		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Create_Customer_Pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
		    p_encoded => FND_API.G_FALSE,
		    p_count => x_msg_count,
		    p_data  => x_msg_data
		);

	WHEN OTHERS THEN
		ROLLBACK TO Create_Customer_Pub;
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

END Update_Person_Profile;

END ams_scripting_pub;

/
