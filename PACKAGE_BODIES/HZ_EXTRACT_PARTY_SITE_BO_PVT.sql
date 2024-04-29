--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_PARTY_SITE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_PARTY_SITE_BO_PVT" AS
/*$Header: ARHEPSVB.pls 120.5 2006/06/13 20:28:42 acng noship $ */
/*
 * This package contains the private APIs for logical party site.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname party site
 * @rep:category BUSINESS_ENTITY HZ_PARTIE_SITES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf party site Get APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_party_site_bo
  --
  -- DESCRIPTION
  --     Get a logical party site.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to  FND_API.G_TRUE. Default is FND_API.G_FALSE.
 --       p_party_id          party ID.
 --       p_party_site_id     party site ID. If this id is not passed in, multiple site objects will be returned.
  --     p_party_site_os          party site orig system.
  --     p_party_site_osr         party site orig system reference.
  --
  --   OUT:
  --     x_party_site_objs         Logical party site records.
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --
  --   1-JUNE-2005   AWU                Created.
  --

/*
The Get party site API Procedure is a retrieval service that returns a full party site business object.
The user identifies a particular party site business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full party site business object is returned. The object consists of all data included within
the party site business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the party site business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments
Phone			N	Y		get_phone_bos
Telex			N	Y		get_telex_bos
Email			N	Y		get_email_bos
Web			N	Y		get_web_bos

To retrieve the appropriate embedded entities within the party site business object,
the Get procedure returns all records for the particular party site from these TCA entity tables:

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Location		Y		N	HZ_LOCATIONS
Party Site		Y		N	HZ_PARTY_SITES
Party Site Use		N		Y	HZ_PARTY_SITE_USES
Contact Preference	N		Y	HZ_CONTACT_PREFERENCES
*/


 PROCEDURE get_party_site_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_party_id            IN NUMBER,
    p_party_site_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_party_site_objs          OUT NOCOPY    HZ_PARTY_SITE_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

CURSOR C1 IS
	SELECT HZ_PARTY_SITE_BO(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		PS.PARTY_SITE_ID,
		NULL, --PS.ORIG_SYSTEM,
		NULL, --PS.ORIG_SYSTEM_REFERENCE,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_PARTIES',PS.PARTY_ID),
		PS.PARTY_ID,
		PS.PARTY_SITE_NUMBER,
		PS.MAILSTOP,
		PS.IDENTIFYING_ADDRESS_FLAG,
		PS.STATUS,
		PS.PARTY_SITE_NAME,
		PS.ATTRIBUTE_CATEGORY,
		PS.ATTRIBUTE1,
		PS.ATTRIBUTE2,
		PS.ATTRIBUTE3,
		PS.ATTRIBUTE4,
		PS.ATTRIBUTE5,
		PS.ATTRIBUTE6,
		PS.ATTRIBUTE7,
		PS.ATTRIBUTE8,
		PS.ATTRIBUTE9,
		PS.ATTRIBUTE10,
		PS.ATTRIBUTE11,
		PS.ATTRIBUTE12,
		PS.ATTRIBUTE13,
		PS.ATTRIBUTE14,
		PS.ATTRIBUTE15,
		PS.ATTRIBUTE16,
		PS.ATTRIBUTE17,
		PS.ATTRIBUTE18,
		PS.ATTRIBUTE19,
		PS.ATTRIBUTE20,
		PS.LANGUAGE,
		PS.ADDRESSEE,
		PS.PROGRAM_UPDATE_DATE,
		PS.CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(PS.CREATED_BY),
		PS.CREATION_DATE,
		PS.LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(PS.LAST_UPDATED_BY),
		PS.ACTUAL_CONTENT_SOURCE,
		PS.GLOBAL_LOCATION_NUMBER,
			 CAST(MULTISET (
		SELECT HZ_ORIG_SYS_REF_OBJ(
		NULL, --P_ACTION_TYPE,
		ORIG_SYSTEM_REF_ID,
		ORIG_SYSTEM,
		ORIG_SYSTEM_REFERENCE,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type(OWNER_TABLE_NAME,OWNER_TABLE_ID),
		OWNER_TABLE_ID,
		STATUS,
		REASON_CODE,
		OLD_ORIG_SYSTEM_REFERENCE,
		START_DATE_ACTIVE,
		END_DATE_ACTIVE,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		ATTRIBUTE16,
		ATTRIBUTE17,
		ATTRIBUTE18,
		ATTRIBUTE19,
		ATTRIBUTE20)
	FROM HZ_ORIG_SYS_REFERENCES OSR
	WHERE
	OSR.OWNER_TABLE_ID = PS.PARTY_SITE_ID
	AND OWNER_TABLE_NAME = 'HZ_PARTY_SITES'
	AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL),
	HZ_EXT_ATTRIBUTE_OBJ_TBL(),
	HZ_LOCATION_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		LOC.LOCATION_ID,
		NULL, --ORIG_SYSTEM,
		NULL, --ORIG_SYSTEM_REFERENCE,
		LOC.COUNTRY,
		LOC.ADDRESS1,
		LOC.ADDRESS2,
		LOC.ADDRESS3,
		LOC.ADDRESS4,
		LOC.CITY,
		LOC.POSTAL_CODE,
		LOC.STATE,
		LOC.PROVINCE,
		LOC.COUNTY,
		LOC.ADDRESS_KEY,
		LOC.ADDRESS_STYLE,
		LOC.VALIDATED_FLAG,
		LOC.ADDRESS_LINES_PHONETIC,
	/*	LOC.PO_BOX_NUMBER,
		LOC.HOUSE_NUMBER,
		LOC.STREET_SUFFIX,
		LOC.STREET,
		LOC.STREET_NUMBER,
		LOC.FLOOR,
		LOC.SUITE, */
		LOC.POSTAL_PLUS4_CODE,
		LOC.POSITION,
		LOC.LOCATION_DIRECTIONS,
		LOC.ADDRESS_EFFECTIVE_DATE,
		LOC.ADDRESS_EXPIRATION_DATE,
		LOC.CLLI_CODE,
		LOC.LANGUAGE,
		LOC.SHORT_DESCRIPTION,
		LOC.DESCRIPTION,
		LOC_HIERARCHY_ID,
		LOC.SALES_TAX_GEOCODE,
		LOC.SALES_TAX_INSIDE_CITY_LIMITS,
		LOC.FA_LOCATION_ID,
		LOC.TIMEZONE_ID,
		LOC.ATTRIBUTE_CATEGORY,
		LOC.ATTRIBUTE1,
		LOC.ATTRIBUTE2,
		LOC.ATTRIBUTE3,
		LOC.ATTRIBUTE4,
		LOC.ATTRIBUTE5,
		LOC.ATTRIBUTE6,
		LOC.ATTRIBUTE7,
		LOC.ATTRIBUTE8,
		LOC.ATTRIBUTE9,
		LOC.ATTRIBUTE10,
		LOC.ATTRIBUTE11,
		LOC.ATTRIBUTE12,
		LOC.ATTRIBUTE13,
		LOC.ATTRIBUTE14,
		LOC.ATTRIBUTE15,
		LOC.ATTRIBUTE16,
		LOC.ATTRIBUTE17,
		LOC.ATTRIBUTE18,
		LOC.ATTRIBUTE19,
		LOC.ATTRIBUTE20,
		LOC.PROGRAM_UPDATE_DATE,
		LOC.CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LOC.CREATED_BY),
		LOC.CREATION_DATE,
		LOC.LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LOC.LAST_UPDATED_BY),
		LOC.ACTUAL_CONTENT_SOURCE,
		LOC.DELIVERY_POINT_CODE,
		LOC.GEOMETRY_STATUS_CODE,
		LOC.GEOMETRY,
		HZ_ORIG_SYS_REF_OBJ_TBL(),
		HZ_EXT_ATTRIBUTE_OBJ_TBL()),
	 CAST(MULTISET (
		SELECT
		HZ_PARTY_SITE_USE_OBJ(
		 P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
                PARTY_SITE_USE_ID,
                COMMENTS,
                SITE_USE_TYPE,
                PARTY_SITE_ID,
                PRIMARY_PER_TYPE,
                STATUS,
		PROGRAM_UPDATE_DATE,
                CREATED_BY_MODULE,
                HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
                CREATION_DATE,
                LAST_UPDATE_DATE,
                HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
	FROM HZ_PARTY_SITE_USES
	WHERE PARTY_SITE_ID = PS.PARTY_SITE_ID) AS HZ_PARTY_SITE_USE_OBJ_TBL),
		HZ_PHONE_CP_BO_TBL(),
		HZ_TELEX_CP_BO_TBL(),
		HZ_EMAIL_CP_BO_TBL(),
		HZ_WEB_CP_BO_TBL(),
	CAST(MULTISET (
		SELECT HZ_CONTACT_PREF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_PREFERENCE_ID,
		'PARTY_SITE',
		CONTACT_LEVEL_TABLE_ID,
		CONTACT_TYPE,
		PREFERENCE_CODE,
		PREFERENCE_TOPIC_TYPE,
		PREFERENCE_TOPIC_TYPE_ID,
		PREFERENCE_TOPIC_TYPE_CODE,
		PREFERENCE_START_DATE,
		PREFERENCE_END_DATE,
		PREFERENCE_START_TIME_HR,
		PREFERENCE_END_TIME_HR,
		PREFERENCE_START_TIME_MI,
		PREFERENCE_END_TIME_MI,
		MAX_NO_OF_INTERACTIONS,
		MAX_NO_OF_INTERACT_UOM_CODE,
		REQUESTED_BY,
		REASON_CODE,
		STATUS,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
        FROM HZ_CONTACT_PREFERENCES CPREF
        WHERE CONTACT_LEVEL_TABLE = 'HZ_PARTY_SITES'
	AND CONTACT_LEVEL_TABLE_ID = PS.PARTY_SITE_ID) AS HZ_CONTACT_PREF_OBJ_TBL))
    FROM HZ_PARTY_SITES PS, HZ_LOCATIONS LOC WHERE PS.LOCATION_ID = LOC.LOCATION_ID
       AND ((P_PARTY_SITE_ID IS NULL AND PARTY_ID = P_PARTY_ID)
	OR (P_PARTY_SITE_ID IS NOT NULL AND PARTY_SITE_ID = P_PARTY_SITE_ID));



 l_debug_prefix              VARCHAR2(30) := '';
BEGIN


	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_party_site_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


	x_party_site_objs := HZ_PARTY_SITE_BO_TBL();
    	open c1;
	fetch c1 BULK COLLECT into x_party_site_objs;
	close c1;

	for i in 1..x_party_site_objs.count loop

		hz_extract_cont_point_bo_pvt.get_phone_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_phone_id => null,
		 p_parent_id => x_party_site_objs(i).party_site_id,
	         p_parent_table_name => 'HZ_PARTY_SITES',
		 p_action_type => p_action_type,
		 x_phone_objs  => x_party_site_objs(i).phone_objs,
 		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;

		hz_extract_ext_attri_bo_pvt.get_ext_attribute_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_ext_object_id => x_party_site_objs(i).party_site_id,
    		 p_ext_object_name => 'HZ_PARTY_SITES',
		 p_action_type => p_action_type,
		 x_ext_attribute_objs => x_party_site_objs(i).ext_attributes_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;

		hz_extract_cont_point_bo_pvt.get_telex_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_telex_id => null,
		 p_parent_id => x_party_site_objs(i).party_site_id,
	         p_parent_table_name => 'HZ_PARTY_SITES',
		 p_action_type => p_action_type,
		 x_telex_objs  => x_party_site_objs(i).telex_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;


		hz_extract_cont_point_bo_pvt.get_email_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_email_id => null,
		 p_parent_id => x_party_site_objs(i).party_site_id,
	         p_parent_table_name => 'HZ_PARTY_SITES',
		 p_action_type => p_action_type,
		 x_email_objs  => x_party_site_objs(i).email_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;


		hz_extract_cont_point_bo_pvt.get_web_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_web_id => null,
		 p_parent_id => x_party_site_objs(i).party_site_id,
	         p_parent_table_name => 'HZ_PARTY_SITES',
		 p_action_type => p_action_type,
		 x_web_objs  => x_party_site_objs(i).web_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;

	    -- SSM for location obj
	    HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_owner_table_id => x_party_site_objs(i).location_obj.location_id,
	         p_owner_table_name => 'HZ_LOCATIONS',
		 p_action_type => NULL, --p_action_type,
		 x_orig_sys_ref_objs => x_party_site_objs(i).location_obj.orig_sys_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    	    END IF;

            -- Ext attributes for location obj

	    	hz_extract_ext_attri_bo_pvt.get_ext_attribute_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_ext_object_id => x_party_site_objs(i).location_obj.location_id,
    		 p_ext_object_name => 'HZ_LOCATIONS',
		 p_action_type => p_action_type,
		 x_ext_attribute_objs => x_party_site_objs(i).location_obj.ext_attributes_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;

	end loop;

	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_party_site_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_party_site_bos(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_party_site_bos(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'get_party_site_bos(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;


END HZ_EXTRACT_PARTY_SITE_BO_PVT;

/
