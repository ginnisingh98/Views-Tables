--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_CONT_POINT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_CONT_POINT_BO_PVT" AS
/*$Header: ARHECPVB.pls 120.5 2006/06/13 20:28:01 acng noship $ */
/*
 * This package contains the private APIs for logical phone.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname phone
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf phone Get APIs
 */


/*
The Get Contact Point API Procedures are retrieval services that return a full Contact Point business object of the type specified.
The user identifies a particular Contact Point business object using the TCA identifier and/or the objects Source System information.
Upon proper validation of the object, the full Contact Point business object is returned. The object consists of all data included
within the Contact Point business object, at all embedded levels. This includes the set of all data stored in the TCA tables for
each embedded entity.

To retrieve the appropriate embedded entities within the Contact Point business objects, the Get procedure returns all records for
the particular object from these TCA entity tables.

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments

Contact Point		Y	N	HZ_CONTACT_POINTS
Contact Preference	N	Y	HZ_CONTACT_PREFERENCES

*/


  --------------------------------------
  --
  -- PROCEDURE get_phone_bos
  --
  -- DESCRIPTION
  --     Get logical phones.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to  FND_API.G_TRUE. Default is FND_API.G_FALSE.
--       p_phone_id          phone ID. If this id is passed in, return only one obj.
  --
 --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name
  --   OUT:
  --     x_phone_obj         Logical phone record.
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
  --   30-May-2005   AWU                Created.
  --


 PROCEDURE get_phone_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_phone_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_phone_objs          OUT NOCOPY    HZ_PHONE_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is


	cursor c1 is
  		SELECT HZ_PHONE_CP_BO(
    		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_POINT_ID,
		NULL, -- ORIG_SYSTEM,
		NULL, -- ORIG_SYSTEM_REFERENCE,
		STATUS,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type(OWNER_TABLE_NAME,OWNER_TABLE_ID),
		OWNER_TABLE_ID,
		PRIMARY_FLAG,
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
		ATTRIBUTE20,
		CONTACT_POINT_PURPOSE,
		PRIMARY_BY_PURPOSE,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ACTUAL_CONTENT_SOURCE,
		PHONE_CALLING_CALENDAR,
		LAST_CONTACT_DT_TIME,
		TIMEZONE_ID,
		PHONE_AREA_CODE,
		PHONE_COUNTRY_CODE,
		PHONE_NUMBER,
		PHONE_EXTENSION,
		PHONE_LINE_TYPE,
		RAW_PHONE_NUMBER,
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
	OSR.OWNER_TABLE_ID = CP.CONTACT_POINT_ID
	AND OWNER_TABLE_NAME = 'HZ_CONTACT_POINTS'
	AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL),
    CAST(MULTISET (
		SELECT HZ_CONTACT_PREF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_PREFERENCE_ID,
		'PHONE',
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
        WHERE CONTACT_LEVEL_TABLE = 'HZ_CONTACT_POINTS'
	AND CONTACT_LEVEL_TABLE_ID = CP.CONTACT_POINT_ID) AS HZ_CONTACT_PREF_OBJ_TBL))
    FROM HZ_CONTACT_POINTS CP WHERE CONTACT_POINT_TYPE = 'PHONE'
       AND ((P_PHONE_ID IS NULL AND OWNER_TABLE_NAME = P_PARENT_TABLE_NAME
       AND OWNER_TABLE_ID = P_PARENT_ID)
	OR (P_PHONE_ID IS NOT NULL AND CONTACT_POINT_ID = P_PHONE_ID));

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
        	hz_utility_v2pub.debug(p_message=>'get_phone_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	x_phone_objs := HZ_PHONE_CP_BO_TBL();
    	open c1;
	fetch c1 BULK COLLECT into x_phone_objs;
	close c1;

	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_phone_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_phone_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_phone_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_phone_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;




  --------------------------------------
  --
  -- PROCEDURE get_telex_bos
  --
  -- DESCRIPTION
  --     Get a logical telex.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_telex_id          telex ID. If this id is passed in, return only one obj.
--     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name

  --   OUT:
  --     x_telex_objs         Logical telex record.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_telex_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_telex_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_telex_objs          OUT NOCOPY    HZ_TELEX_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

	cursor c1 is
  		SELECT HZ_TELEX_CP_BO(
    		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_POINT_ID,
		NULL, -- ORIG_SYSTEM,
		NULL, -- ORIG_SYSTEM_REFERENCE,
		STATUS,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type(OWNER_TABLE_NAME,OWNER_TABLE_ID),
		OWNER_TABLE_ID,
		PRIMARY_FLAG,
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
		ATTRIBUTE20,
		CONTACT_POINT_PURPOSE,
		PRIMARY_BY_PURPOSE,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ACTUAL_CONTENT_SOURCE,
		TELEX_NUMBER,
	 CAST(MULTISET (
		SELECT HZ_ORIG_SYS_REF_OBJ(
		NULL, --P_ACTION_TYPE,
		ORIG_SYSTEM_REF_ID,
		ORIG_SYSTEM,
		ORIG_SYSTEM_REFERENCE,
		OWNER_TABLE_NAME,
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
	OSR.OWNER_TABLE_ID = CP.CONTACT_POINT_ID
	AND OWNER_TABLE_NAME = 'HZ_CONTACT_POINTS'
	AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL),
    CAST(MULTISET (
		SELECT HZ_CONTACT_PREF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_PREFERENCE_ID,
		'TLX',
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
        WHERE CONTACT_LEVEL_TABLE = 'HZ_CONTACT_POINTS'
	AND CONTACT_LEVEL_TABLE_ID = CP.CONTACT_POINT_ID) AS HZ_CONTACT_PREF_OBJ_TBL))
    FROM HZ_CONTACT_POINTS CP WHERE CONTACT_POINT_TYPE = 'TLX'
       AND ((P_TELEX_ID IS NULL AND OWNER_TABLE_NAME = P_PARENT_TABLE_NAME
       AND OWNER_TABLE_ID = P_PARENT_ID)
	OR (P_TELEX_ID IS NOT NULL AND CONTACT_POINT_ID = P_TELEX_ID));


 l_debug_prefix              VARCHAR2(30) := '';

begin

    	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_telex_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


        x_telex_objs := HZ_TELEX_CP_BO_TBL();

	open c1;
	fetch c1 BULK COLLECT into x_telex_objs;
	close c1;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_telex_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_telex_bos(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_telex_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_telex_bos(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;


 --------------------------------------
  --
  -- PROCEDURE get_email_bos
  --
  -- DESCRIPTION
  --     Get a logical email.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_email_id          email ID. If this id is passed in, return only one obj.
  --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name
  --   OUT:
  --     x_email_objs         Logical email record.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_email_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_email_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_email_objs          OUT NOCOPY    HZ_EMAIL_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

	cursor c1 is
  		SELECT HZ_EMAIL_CP_BO(
    		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_POINT_ID,
		NULL, -- ORIG_SYSTEM,
		NULL, -- ORIG_SYSTEM_REFERENCE,
		STATUS,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type(OWNER_TABLE_NAME,OWNER_TABLE_ID),
		OWNER_TABLE_ID,
		PRIMARY_FLAG,
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
		ATTRIBUTE20,
		CONTACT_POINT_PURPOSE,
		PRIMARY_BY_PURPOSE,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ACTUAL_CONTENT_SOURCE,
		EMAIL_FORMAT,
		EMAIL_ADDRESS,
	 CAST(MULTISET (
		SELECT HZ_ORIG_SYS_REF_OBJ(
		NULL, --P_ACTION_TYPE,
		ORIG_SYSTEM_REF_ID,
		ORIG_SYSTEM,
		ORIG_SYSTEM_REFERENCE,
		OWNER_TABLE_NAME,
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
	OSR.OWNER_TABLE_ID = CP.CONTACT_POINT_ID
	AND OWNER_TABLE_NAME = 'HZ_CONTACT_POINTS'
	AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL),
    CAST(MULTISET (
		SELECT HZ_CONTACT_PREF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_PREFERENCE_ID,
		'EMAIL',
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
        WHERE CONTACT_LEVEL_TABLE = 'HZ_CONTACT_POINTS'
	AND CONTACT_LEVEL_TABLE_ID = CP.CONTACT_POINT_ID) AS HZ_CONTACT_PREF_OBJ_TBL))
    FROM HZ_CONTACT_POINTS CP WHERE CONTACT_POINT_TYPE = 'EMAIL'
       AND ((P_EMAIL_ID IS NULL AND OWNER_TABLE_NAME = P_PARENT_TABLE_NAME
       AND OWNER_TABLE_ID = P_PARENT_ID)
	OR (P_EMAIL_ID IS NOT NULL AND CONTACT_POINT_ID = P_EMAIL_ID));


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
        	hz_utility_v2pub.debug(p_message=>'get_email_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;



        x_email_objs := HZ_EMAIL_CP_BO_TBL();
	open c1;
	fetch c1 BULK COLLECT into x_email_objs;
	close c1;

	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_email_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_email_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_email_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_email_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


end;



  --------------------------------------
  --
  -- PROCEDURE get_web_bos
  --
  -- DESCRIPTION
  --     Get a logical web business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
--       p_web_id          	web ID. If this id is passed in, return only one obj.
 --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name
  --
  --   OUT:
  --     x_web_objs         Logical web record.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_web_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_web_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_web_objs          OUT NOCOPY    HZ_WEB_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

	cursor c1 is
  		SELECT HZ_WEB_CP_BO(
    		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_POINT_ID,
		NULL, -- ORIG_SYSTEM,
		NULL, -- ORIG_SYSTEM_REFERENCE,
		STATUS,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type(OWNER_TABLE_NAME,OWNER_TABLE_ID),
		OWNER_TABLE_ID,
		PRIMARY_FLAG,
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
		ATTRIBUTE20,
		CONTACT_POINT_PURPOSE,
		PRIMARY_BY_PURPOSE,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ACTUAL_CONTENT_SOURCE,
	        WEB_TYPE,
		URL,
	 CAST(MULTISET (
		SELECT HZ_ORIG_SYS_REF_OBJ(
		NULL, --P_ACTION_TYPE,
		ORIG_SYSTEM_REF_ID,
		ORIG_SYSTEM,
		ORIG_SYSTEM_REFERENCE,
		OWNER_TABLE_NAME,
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
	OSR.OWNER_TABLE_ID = CP.CONTACT_POINT_ID
	AND OWNER_TABLE_NAME = 'HZ_CONTACT_POINTS'
	AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL),
    CAST(MULTISET (
		SELECT HZ_CONTACT_PREF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_PREFERENCE_ID,
		'WEB',
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
        WHERE CONTACT_LEVEL_TABLE = 'HZ_CONTACT_POINTS'
	AND CONTACT_LEVEL_TABLE_ID = CP.CONTACT_POINT_ID) AS HZ_CONTACT_PREF_OBJ_TBL))
    FROM HZ_CONTACT_POINTS CP WHERE CONTACT_POINT_TYPE = 'WEB'
       AND ((P_WEB_ID IS NULL AND OWNER_TABLE_NAME = P_PARENT_TABLE_NAME
       AND OWNER_TABLE_ID = P_PARENT_ID)
	OR (P_WEB_ID IS NOT NULL AND CONTACT_POINT_ID = P_WEB_ID));


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
        	hz_utility_v2pub.debug(p_message=>'get_web_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;




        x_web_objs := HZ_WEB_CP_BO_TBL();
	open c1;
	fetch c1 BULK COLLECT into x_web_objs;
	close c1;

	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_web_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_web_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_web_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_web_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


end;




 --------------------------------------
  --
  -- PROCEDURE get_edi_bos
  --
  -- DESCRIPTION
  --     Get a logical edi business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_edi_id          edi ID. If this id is passed in, return only one obj.
 --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name

  --   OUT:
  --     x_edi_objs         Logical edi record.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_edi_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_edi_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_edi_objs          OUT NOCOPY    HZ_EDI_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

	cursor c1 is
  		SELECT HZ_EDI_CP_BO(
    		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_POINT_ID,
		NULL, -- ORIG_SYSTEM,
		NULL, -- ORIG_SYSTEM_REFERENCE,
		STATUS,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type(OWNER_TABLE_NAME,OWNER_TABLE_ID),
		OWNER_TABLE_ID,
		PRIMARY_FLAG,
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
		ATTRIBUTE20,
		CONTACT_POINT_PURPOSE,
		PRIMARY_BY_PURPOSE,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ACTUAL_CONTENT_SOURCE,
		EDI_TRANSACTION_HANDLING,
  		EDI_ID_NUMBER,
  		EDI_PAYMENT_METHOD,
  		EDI_PAYMENT_FORMAT,
  		EDI_REMITTANCE_METHOD,
  		EDI_REMITTANCE_INSTRUCTION,
  		EDI_TP_HEADER_ID,
  		EDI_ECE_TP_LOCATION_CODE,
	 CAST(MULTISET (
		SELECT HZ_ORIG_SYS_REF_OBJ(
		NULL, --P_ACTION_TYPE,
		ORIG_SYSTEM_REF_ID,
		ORIG_SYSTEM,
		ORIG_SYSTEM_REFERENCE,
		OWNER_TABLE_NAME,
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
	OSR.OWNER_TABLE_ID = CP.CONTACT_POINT_ID
	AND OWNER_TABLE_NAME = 'HZ_CONTACT_POINTS'
	AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL),
    CAST(MULTISET (
		SELECT HZ_CONTACT_PREF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_PREFERENCE_ID,
		'EDI',
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
        WHERE CONTACT_LEVEL_TABLE = 'HZ_CONTACT_POINTS'
	AND CONTACT_LEVEL_TABLE_ID = CP.CONTACT_POINT_ID) AS HZ_CONTACT_PREF_OBJ_TBL))
    FROM HZ_CONTACT_POINTS CP WHERE CONTACT_POINT_TYPE = 'EDI'
       AND ((P_EDI_ID IS NULL AND OWNER_TABLE_NAME = P_PARENT_TABLE_NAME
       AND OWNER_TABLE_ID = P_PARENT_ID)
	OR (P_EDI_ID IS NOT NULL AND CONTACT_POINT_ID = P_EDI_ID));


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
        	hz_utility_v2pub.debug(p_message=>'get_edi_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    x_edi_objs := HZ_EDI_CP_BO_TBL();
	open c1;
	fetch c1 BULK COLLECT into x_edi_objs;
	close c1;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_edi_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_edi_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_edi_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_edi_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


end;



 --------------------------------------
  --
  -- PROCEDURE get_eft_bos
  --
  -- DESCRIPTION
  --     Get a logical eft.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_eft_id          eft ID. If this id is passed in, return only one obj.
 --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name

  --   OUT:
  --     x_eft_objs         Logical eft record.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_eft_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_eft_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_eft_objs          OUT NOCOPY    HZ_EFT_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

	cursor c1 is
  		SELECT HZ_EFT_CP_BO(
    		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_POINT_ID,
		NULL, -- ORIG_SYSTEM,
		NULL, -- ORIG_SYSTEM_REFERENCE,
		STATUS,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type(OWNER_TABLE_NAME,OWNER_TABLE_ID),
		OWNER_TABLE_ID,
		PRIMARY_FLAG,
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
		ATTRIBUTE20,
		CONTACT_POINT_PURPOSE,
		PRIMARY_BY_PURPOSE,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ACTUAL_CONTENT_SOURCE,
		EFT_TRANSMISSION_PROGRAM_ID,
  		EFT_PRINTING_PROGRAM_ID,
  		EFT_USER_NUMBER,
  		EFT_SWIFT_CODE,
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
	OSR.OWNER_TABLE_ID = CP.CONTACT_POINT_ID
	AND OWNER_TABLE_NAME = 'HZ_CONTACT_POINTS'
	AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL),
    CAST(MULTISET (
		SELECT HZ_CONTACT_PREF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_PREFERENCE_ID,
		'EFT',
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
        WHERE CONTACT_LEVEL_TABLE = 'HZ_CONTACT_POINTS'
	AND CONTACT_LEVEL_TABLE_ID = CP.CONTACT_POINT_ID) AS HZ_CONTACT_PREF_OBJ_TBL))
    FROM HZ_CONTACT_POINTS CP WHERE CONTACT_POINT_TYPE = 'EFT'
       AND ((P_EFT_ID IS NULL AND OWNER_TABLE_NAME = P_PARENT_TABLE_NAME
       AND OWNER_TABLE_ID = P_PARENT_ID)
	OR (P_EFT_ID IS NOT NULL AND CONTACT_POINT_ID = P_EFT_ID));


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
        	hz_utility_v2pub.debug(p_message=>'get_eft_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


        x_eft_objs := HZ_EFT_CP_BO_TBL();
	open c1;
	fetch c1 BULK COLLECT into x_eft_objs;
	close c1;

	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_eft_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_eft_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_eft_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_eft_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


end;



 --------------------------------------
  --
  -- PROCEDURE get_sms_bos
  --
  -- DESCRIPTION
  --     Get a logical sms.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_sms_id          sms ID. If this id is passed in, return only one obj.
 --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name

  --   OUT:
  --     x_sms_objs         Logical sms record.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_sms_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_sms_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_sms_objs          OUT NOCOPY    HZ_SMS_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

	cursor c1 is
  		SELECT HZ_SMS_CP_BO(
    		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_POINT_ID,
		NULL, -- ORIG_SYSTEM,
		NULL, -- ORIG_SYSTEM_REFERENCE,
		STATUS,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type(OWNER_TABLE_NAME,OWNER_TABLE_ID),
		OWNER_TABLE_ID,
		PRIMARY_FLAG,
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
		ATTRIBUTE20,
		CONTACT_POINT_PURPOSE,
		PRIMARY_BY_PURPOSE,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ACTUAL_CONTENT_SOURCE,
		PHONE_CALLING_CALENDAR,
		LAST_CONTACT_DT_TIME,
		TIMEZONE_ID,
		PHONE_AREA_CODE,
		PHONE_COUNTRY_CODE,
		PHONE_NUMBER,
		PHONE_EXTENSION,
		PHONE_LINE_TYPE,
		RAW_PHONE_NUMBER,
	 CAST(MULTISET (
		SELECT HZ_ORIG_SYS_REF_OBJ(
		NULL, --P_ACTION_TYPE,
		ORIG_SYSTEM_REF_ID,
		ORIG_SYSTEM,
		ORIG_SYSTEM_REFERENCE,
		OWNER_TABLE_NAME,
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
	OSR.OWNER_TABLE_ID = CP.CONTACT_POINT_ID
	AND OWNER_TABLE_NAME = 'HZ_CONTACT_POINTS'
	AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL),
    CAST(MULTISET (
		SELECT HZ_CONTACT_PREF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_PREFERENCE_ID,
		'SMS',
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
        WHERE CONTACT_LEVEL_TABLE = 'HZ_CONTACT_POINTS'
	AND CONTACT_LEVEL_TABLE_ID = CP.CONTACT_POINT_ID) AS HZ_CONTACT_PREF_OBJ_TBL))
    FROM HZ_CONTACT_POINTS CP WHERE CONTACT_POINT_TYPE = 'SMS'
       AND ((P_SMS_ID IS NULL AND OWNER_TABLE_NAME = P_PARENT_TABLE_NAME
       AND OWNER_TABLE_ID = P_PARENT_ID)
	OR (P_SMS_ID IS NOT NULL AND CONTACT_POINT_ID = P_SMS_ID));


BEGIN

    	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_sms_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;



        x_sms_objs := HZ_SMS_CP_BO_TBL();
	open c1;
	fetch c1 BULK COLLECT into x_sms_objs;
	close c1;

	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_sms_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_eft_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_sms_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_eft_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


end;

PROCEDURE get_cont_pref_objs(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_cont_level_table_id           IN            NUMBER,
    p_cont_level_table           IN            VARCHAR2,
    p_contact_type          IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_cont_pref_objs          OUT NOCOPY    HZ_CONTACT_PREF_OBJ_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
i BINARY_INTEGER := 1;
l_debug_prefix              VARCHAR2(30) := '';

cursor c1 is
	select HZ_CONTACT_PREF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CONTACT_PREFERENCE_ID,
                HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type(CONTACT_LEVEL_TABLE,CONTACT_LEVEL_TABLE_ID),
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
        from hz_contact_preferences
        where contact_level_table = p_cont_level_table
	and contact_level_table_id = p_cont_level_table_id
	and contact_type = nvl(p_contact_type, contact_type);

begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;

	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_cont_pref_objs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	x_cont_pref_objs := HZ_CONTACT_PREF_OBJ_TBL();

	open c1;
	fetch c1 BULK COLLECT into x_cont_pref_objs;
	close c1;

   	 -- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_cont_pref_objs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

EXCEPTION

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
        hz_utility_v2pub.debug(p_message=>'get_cont_pref_objs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;


END HZ_EXTRACT_CONT_POINT_BO_PVT;

/
