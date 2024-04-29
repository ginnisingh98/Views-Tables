--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_PARTY_USAGE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_PARTY_USAGE_BO_PVT" AS
/*$Header: ARHEPUVB.pls 120.2 2006/10/12 17:17:02 awu noship $ */
/*
 * This package contains the private APIs for ssm information.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname customer account site
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf cGet APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_party_usage_bo
  --
  -- DESCRIPTION
  --     Get ssm information.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
--       p_owner_table_id          party id
  --     p_owner_table_name        hz_parties
  --
  --   OUT:
  --     x_party_usage_objs  Table of party usage objects.
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



 PROCEDURE get_party_usage_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_owner_table_id           IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_party_usage_objs          OUT NOCOPY    HZ_PARTY_USAGE_OBJ_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

i BINARY_INTEGER := 1;
l_debug_prefix              VARCHAR2(30) := '';

cursor c1 is
	SELECT
		HZ_PARTY_USAGE_OBJ(
  		PARTY_USG_ASSIGNMENT_ID,
  		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_PARTIES',PARTY_ID),
  		PARTY_ID,
  		PARTY_USAGE_CODE,
  		EFFECTIVE_START_DATE,
  		EFFECTIVE_END_DATE,
  		COMMENTS,
  		STATUS_FLAG,
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
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
  		CREATION_DATE,
  		LAST_UPDATE_DATE,
  		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
	FROM HZ_PARTY_USG_ASSIGNMENTS
	WHERE PARTY_ID = P_OWNER_TABLE_ID;


begin
	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;

	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_party_usage_objs(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


        x_party_usage_objs := HZ_PARTY_USAGE_OBJ_TBL();

	open c1;
	fetch c1 BULK COLLECT into x_party_usage_objs;
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
        	hz_utility_v2pub.debug(p_message=>'get_party_usage_objs(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_party_usage_objs(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;




END HZ_EXTRACT_PARTY_USAGE_BO_PVT;

/
