--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_RELATIONSHIP_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_RELATIONSHIP_BO_PVT" AS
/*$Header: ARHEREVB.pls 120.4.12000000.2 2007/02/22 20:14:59 awu ship $ */
/*
 * This package contains the private APIs for ssm information.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf cGet APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_relationship_bos
  --
  -- DESCRIPTION
  --     Get relationship information.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --       p_subject_id       relationship subject ID.
  --
  --   OUT:
  --     x_relationship_objs  Table of relationship objects.
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
  --   15-May-2005   AWU                Created.
  --



 PROCEDURE get_relationship_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_subject_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_relationship_objs          OUT NOCOPY    HZ_RELATIONSHIP_OBJ_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

CURSOR C1 IS
	SELECT HZ_RELATIONSHIP_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		RELATIONSHIP_ID,
		DECODE(SUBJECT_TYPE, 'ORGANIZATION', 'ORG', SUBJECT_TYPE),
		P_SUBJECT_ID,
		OBJECT_ID,
		DECODE(OBJECT_TYPE, 'ORGANIZATION', 'ORG', OBJECT_TYPE),
		NULL, --OBJECT_ORIG_SYSTEM_REFERENCE,
		NULL, --OBJECT_ORIG_SYSTEM,
		RELATIONSHIP_CODE,
		RELATIONSHIP_TYPE,
		COMMENTS,
		START_DATE,
		END_DATE,
		STATUS,
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
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 		CREATION_DATE,
 		LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		ADDITIONAL_INFORMATION1,
		ADDITIONAL_INFORMATION2,
		ADDITIONAL_INFORMATION3,
		ADDITIONAL_INFORMATION4,
		ADDITIONAL_INFORMATION5,
		ADDITIONAL_INFORMATION6,
		ADDITIONAL_INFORMATION7,
		ADDITIONAL_INFORMATION8,
		ADDITIONAL_INFORMATION9,
		ADDITIONAL_INFORMATION10,
		ADDITIONAL_INFORMATION11,
		ADDITIONAL_INFORMATION12,
		ADDITIONAL_INFORMATION13,
		ADDITIONAL_INFORMATION14,
		ADDITIONAL_INFORMATION15,
		ADDITIONAL_INFORMATION16,
		ADDITIONAL_INFORMATION17,
		ADDITIONAL_INFORMATION18,
		ADDITIONAL_INFORMATION19,
		ADDITIONAL_INFORMATION20,
		ADDITIONAL_INFORMATION21,
		ADDITIONAL_INFORMATION22,
		ADDITIONAL_INFORMATION23,
		ADDITIONAL_INFORMATION24,
		ADDITIONAL_INFORMATION25,
		ADDITIONAL_INFORMATION26,
		ADDITIONAL_INFORMATION27,
		ADDITIONAL_INFORMATION28,
		ADDITIONAL_INFORMATION29,
		ADDITIONAL_INFORMATION30,
		PERCENTAGE_OWNERSHIP,
		ACTUAL_CONTENT_SOURCE,
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
	OSR.OWNER_TABLE_ID = REL.OBJECT_ID
	AND OWNER_TABLE_NAME = 'HZ_PARTIES'
	AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL))
    FROM HZ_RELATIONSHIPS REL
    WHERE SUBJECT_ID = P_SUBJECT_ID;


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
        	hz_utility_v2pub.debug(p_message=>'get_relationship_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	x_relationship_objs := HZ_RELATIONSHIP_OBJ_TBL();
    	open c1;
	fetch c1 BULK COLLECT into x_relationship_objs;
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
        	hz_utility_v2pub.debug(p_message=>'get_relationship_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_relationship_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_relationship_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_relationship_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;




END HZ_EXTRACT_RELATIONSHIP_BO_PVT;

/
