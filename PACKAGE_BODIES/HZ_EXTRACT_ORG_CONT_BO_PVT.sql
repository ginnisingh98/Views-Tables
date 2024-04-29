--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_ORG_CONT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_ORG_CONT_BO_PVT" AS
/*$Header: ARHEOCVB.pls 120.6 2006/10/24 23:38:31 awu noship $ */
/*
 * This package contains the private APIs for org contact information.
 * @rep:scope private
 * @rep:product HZ
 * @rep:display name org contact
 * @rep:category BUSINESS_ENTITY HZ_ORG_CONTACTS
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf Get APIs
 */

  -- Private procedure get_cont_per_profile_bo

function get_id(p_org_cont_id in number, p_type in varchar2 ) return number is

  cursor get_cont_info_csr is
	select r.subject_id, r.party_id
	from hz_relationships r, hz_org_contacts oc
	where r.relationship_id = oc.party_relationship_id
	and oc.org_contact_id = p_org_cont_id
	and r.subject_type = 'PERSON';

l_person_id number;
l_rel_party_id number;
begin
	open  get_cont_info_csr;
	fetch  get_cont_info_csr into l_person_id, l_rel_party_id;
	close  get_cont_info_csr;

	if p_type = 'PERSON'
	then
		return  l_person_id;
	elsif p_type = 'REL_PARTY'
	then
		return l_rel_party_id;
	end if;
end get_id;

 PROCEDURE get_cont_per_profile_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_id     IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_person_profile_obj    OUT NOCOPY    HZ_PERSON_PROFILE_OBJ,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

CURSOR C1 IS
	SELECT HZ_PERSON_PROFILE_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		P.PARTY_ID,
		NULL, --ORIG_SYSTEM,
		NULL, --ORIG_SYSTEM_REFERENCE,
		P.PARTY_NUMBER,
		P.VALIDATED_FLAG,
		P.STATUS,
		P.CATEGORY_CODE,
		P.SALUTATION,
		P.ATTRIBUTE_CATEGORY,
		P.ATTRIBUTE1,
		P.ATTRIBUTE2,
		P.ATTRIBUTE3,
		P.ATTRIBUTE4,
		P.ATTRIBUTE5,
		P.ATTRIBUTE6,
		P.ATTRIBUTE7,
		P.ATTRIBUTE8,
		P.ATTRIBUTE9,
		P.ATTRIBUTE10,
		P.ATTRIBUTE11,
		P.ATTRIBUTE12,
		P.ATTRIBUTE13,
		P.ATTRIBUTE14,
		P.ATTRIBUTE15,
		P.ATTRIBUTE16,
		P.ATTRIBUTE17,
		P.ATTRIBUTE18,
		P.ATTRIBUTE19,
		P.ATTRIBUTE20,
		P.ATTRIBUTE21,
		P.ATTRIBUTE22,
		P.ATTRIBUTE23,
		P.ATTRIBUTE24,
		PRO.PERSON_PRE_NAME_ADJUNCT,
		PRO.PERSON_FIRST_NAME,
		PRO.PERSON_MIDDLE_NAME,
		PRO.PERSON_LAST_NAME,
		PRO.PERSON_NAME_SUFFIX,
		PRO.PERSON_TITLE,
		PRO.PERSON_ACADEMIC_TITLE,
		PRO.PERSON_PREVIOUS_LAST_NAME,
		PRO.PERSON_INITIALS,
		PRO.KNOWN_AS,
		PRO.KNOWN_AS2,
		PRO.KNOWN_AS3,
		PRO.KNOWN_AS4,
		PRO.KNOWN_AS5,
		PRO.PERSON_NAME_PHONETIC,
		PRO.PERSON_FIRST_NAME_PHONETIC,
		PRO.PERSON_LAST_NAME_PHONETIC,
		PRO.MIDDLE_NAME_PHONETIC,
		PRO.TAX_REFERENCE,
		PRO.JGZZ_FISCAL_CODE,
		PRO.PERSON_IDEN_TYPE,
		PRO.PERSON_IDENTIFIER,
		PRO.DATE_OF_BIRTH,
		PRO.PLACE_OF_BIRTH,
		PRO.DATE_OF_DEATH,
		PRO.DECEASED_FLAG,
		PRO.GENDER,
		PRO.DECLARED_ETHNICITY,
		PRO.MARITAL_STATUS,
		MARITAL_STATUS_EFFECTIVE_DATE,
		PRO.PERSONAL_INCOME,
		PRO.HEAD_OF_HOUSEHOLD_FLAG,
		PRO.HOUSEHOLD_INCOME,
		PRO.HOUSEHOLD_SIZE,
		PRO.RENT_OWN_IND,
		PRO.LAST_KNOWN_GPS,
		PRO.INTERNAL_FLAG,
	        PRO.PROGRAM_UPDATE_DATE,
		PRO.CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(PRO.CREATED_BY),
		PRO.CREATION_DATE,
		PRO.LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(PRO.LAST_UPDATED_BY),
		PRO.ACTUAL_CONTENT_SOURCE,
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
	OSR.OWNER_TABLE_ID = PRO.PARTY_ID
	AND OWNER_TABLE_NAME = 'HZ_PARTIES'
	AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL),
	HZ_EXT_ATTRIBUTE_OBJ_TBL())
     FROM HZ_PERSON_PROFILES PRO, HZ_PARTIES P
     WHERE PRO.PARTY_ID = P.PARTY_ID AND  P.PARTY_ID = P_PERSON_ID
	AND SYSDATE BETWEEN EFFECTIVE_START_DATE AND NVL(EFFECTIVE_END_DATE,SYSDATE);

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
        	hz_utility_v2pub.debug(p_message=>'get_cont_per_profile_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	open c1;
	fetch c1 into x_person_profile_obj;
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
        	hz_utility_v2pub.debug(p_message=>'get_cont_per_profile_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cont_per_profile_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cont_per_profile_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cont_per_profile_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

 PROCEDURE get_org_contact_role_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_org_cont_id     IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_org_cont_role_objs    OUT NOCOPY  HZ_ORG_CONTACT_ROLE_OBJ_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

CURSOR C1 IS
	SELECT HZ_ORG_CONTACT_ROLE_OBJ(
	P_ACTION_TYPE,
        NULL, -- COMMON_OBJ_ID
 	ORG_CONTACT_ROLE_ID,
 	NULL, --ORIG_SYSTEM,
 	NULL, --ORIG_SYSTEM_REFERENCE,
 	ROLE_TYPE,
 	PRIMARY_FLAG,
 	ORG_CONTACT_ID,
 	ROLE_LEVEL,
 	PRIMARY_CONTACT_PER_ROLE_TYPE,
 	STATUS,
 	PROGRAM_UPDATE_DATE,
 	CREATED_BY_MODULE,
 	HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
 	CREATION_DATE,
 	LAST_UPDATE_DATE,
 	HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
 	CAST(MULTISET (
		SELECT HZ_ORIG_SYS_REF_OBJ(
		NULL, --P_ACTION_TYPE,
		ORIG_SYSTEM_REF_ID,
		ORIG_SYSTEM,
		ORIG_SYSTEM_REFERENCE,
		'ORG_CONTACT', -- parent_object_type
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
	OSR.OWNER_TABLE_ID = OCR.ORG_CONTACT_ROLE_ID
	AND OWNER_TABLE_NAME = 'HZ_ORG_CONTACT_ROLES'
	AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL))
    FROM HZ_ORG_CONTACT_ROLES OCR
    WHERE ORG_CONTACT_ID = P_ORG_CONT_ID;

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
        	hz_utility_v2pub.debug(p_message=>'get_org_contact_role_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	x_org_cont_role_objs := HZ_ORG_CONTACT_ROLE_OBJ_TBL();
    	open c1;
	fetch c1 BULK COLLECT into x_org_cont_role_objs;
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
        	hz_utility_v2pub.debug(p_message=>'get_org_contact_role_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_org_contact_role_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_org_contact_role_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_org_contact_role_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;



  --------------------------------------
  --
  -- PROCEDURE get_org_contact_bos
  --
  -- DESCRIPTION
  --     Get org contact information.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --       p_organization_id       Org Contact Org id.
  --
  --   OUT:
  --     x_org contact_objs  Table of org contact objects.
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
  --   15-June-2005   AWU                Created.
  --



 PROCEDURE get_org_contact_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_id     IN            NUMBER,
    p_org_contact_id	  IN            NUMBER := NULL,
    p_action_type	  IN VARCHAR2 := NULL,
    x_org_contact_objs    OUT NOCOPY    HZ_ORG_CONTACT_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

CURSOR C1 IS
	SELECT HZ_ORG_CONTACT_BO(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		OC.ORG_CONTACT_ID,
		P.PARTY_ID,
		NULL, --ORIG_SYSTEM,
		NULL, --ORIG_SYSTEM_REFERENCE,
		OC.COMMENTS,
		OC.CONTACT_NUMBER,
		OC.DEPARTMENT_CODE,
		OC.DEPARTMENT,
		OC.TITLE,
		OC.JOB_TITLE,
		OC.DECISION_MAKER_FLAG,
		OC.JOB_TITLE_CODE,
		OC.REFERENCE_USE_FLAG,
		OC.RANK,
		OC.PARTY_SITE_ID,
		OC.ATTRIBUTE_CATEGORY,
		OC.ATTRIBUTE1,
		OC.ATTRIBUTE2,
		OC.ATTRIBUTE3,
		OC.ATTRIBUTE4,
		OC.ATTRIBUTE5,
		OC.ATTRIBUTE6,
		OC.ATTRIBUTE7,
		OC.ATTRIBUTE8,
		OC.ATTRIBUTE9,
		OC.ATTRIBUTE10,
		OC.ATTRIBUTE11,
		OC.ATTRIBUTE12,
		OC.ATTRIBUTE13,
		OC.ATTRIBUTE14,
		OC.ATTRIBUTE15,
		OC.ATTRIBUTE16,
		OC.ATTRIBUTE17,
		OC.ATTRIBUTE18,
		OC.ATTRIBUTE19,
		OC.ATTRIBUTE20,
		OC.ATTRIBUTE21,
		OC.ATTRIBUTE22,
		OC.ATTRIBUTE23,
		OC.ATTRIBUTE24,
 		OC.PROGRAM_UPDATE_DATE,
		OC.CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(OC.CREATED_BY),
		OC.CREATION_DATE,
		OC.LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(OC.LAST_UPDATED_BY),
		R.RELATIONSHIP_CODE,
		R.RELATIONSHIP_TYPE,
		R.COMMENTS,
		R.START_DATE,
		R.END_DATE,
		R.STATUS,
		HZ_ORIG_SYS_REF_OBJ_TBL(),
		NULL, --PERSON_PROFILE_OBJ,
		HZ_ORG_CONTACT_ROLE_OBJ_TBL(),
		HZ_PARTY_SITE_BO_TBL(),
		HZ_PHONE_CP_BO_TBL(),
		HZ_TELEX_CP_BO_TBL(),
		HZ_EMAIL_CP_BO_TBL(),
		HZ_WEB_CP_BO_TBL(),
		HZ_SMS_CP_BO_TBL(),
		HZ_CONTACT_PREF_OBJ_TBL())
	FROM HZ_ORG_CONTACTS OC, HZ_PARTIES P, HZ_RELATIONSHIPS R
	WHERE OC.PARTY_RELATIONSHIP_ID = R.RELATIONSHIP_ID
	AND R.SUBJECT_ID = P.PARTY_ID
	AND R.OBJECT_TYPE = 'PERSON'
	AND ((P_ORG_CONTACT_ID IS NULL AND P.PARTY_ID = P_ORGANIZATION_ID)
	OR (P_ORG_CONTACT_ID IS NOT NULL AND OC.ORG_CONTACT_ID = P_ORG_CONTACT_ID));

 l_debug_prefix              VARCHAR2(30) := '';
l_rel_party_id number;

BEGIN


	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_org_contact_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	x_org_contact_objs := HZ_ORG_CONTACT_BO_TBL();
    	open c1;
	fetch c1 BULK COLLECT into x_org_contact_objs;
	close c1;


	for i in 1..x_org_contact_objs.count loop

		get_cont_per_profile_bo(
   		p_init_msg_list => fnd_api.g_false,
    		p_person_id => get_id(x_org_contact_objs(i).org_contact_id,'PERSON'),
    		p_action_type => p_action_type,
    		x_person_profile_obj  => x_org_contact_objs(i).person_profile_obj,
   	 	x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    		END IF;

		get_org_contact_role_bos(
   		p_init_msg_list => fnd_api.g_false,
    		p_org_cont_id => x_org_contact_objs(i).org_contact_id,
    		p_action_type => p_action_type,
    		x_org_cont_role_objs  => x_org_contact_objs(i).org_contact_role_objs,
   	 	x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    		END IF;

		HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_owner_table_id => x_org_contact_objs(i).org_contact_id,
	         p_owner_table_name => 'HZ_ORG_CONTACTS',
		p_action_type => NULL, --p_action_type,
		 x_orig_sys_ref_objs => x_org_contact_objs(i).orig_sys_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    		END IF;

	l_rel_party_id :=  get_id(x_org_contact_objs(i).org_contact_id,'REL_PARTY');

	HZ_EXTRACT_PARTY_SITE_BO_PVT.get_party_site_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_party_id => l_rel_party_id,
	         p_party_site_id => NULL,
		 p_action_type => p_action_type,
		 x_party_site_objs => x_org_contact_objs(i).party_site_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    		END IF;


	hz_extract_cont_point_bo_pvt.get_phone_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_phone_id => null,
		 p_parent_id => l_rel_party_id,
	         p_parent_table_name => 'HZ_PARTIES',
 		 p_action_type => p_action_type,
		 x_phone_objs  => x_org_contact_objs(i).phone_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    		END IF;


	hz_extract_cont_point_bo_pvt.get_email_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_email_id => null,
		 p_parent_id => l_rel_party_id,
	         p_parent_table_name => 'HZ_PARTIES',
 		 p_action_type => p_action_type,
		 x_email_objs  => x_org_contact_objs(i).email_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    		END IF;


		hz_extract_cont_point_bo_pvt.get_telex_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_telex_id => null,
		 p_parent_id => l_rel_party_id,
	         p_parent_table_name => 'HZ_PARTIES',
		 x_telex_objs  => x_org_contact_objs(i).telex_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    		END IF;


		hz_extract_cont_point_bo_pvt.get_web_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_web_id => null,
		 p_parent_id => l_rel_party_id,
	         p_parent_table_name => 'HZ_PARTIES',
 		 p_action_type => p_action_type,
		 x_web_objs  => x_org_contact_objs(i).web_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    		END IF;


		hz_extract_cont_point_bo_pvt.get_sms_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_sms_id => null,
		 p_parent_id => l_rel_party_id,
	         p_parent_table_name => 'HZ_PARTIES',
 		 p_action_type => p_action_type,
		 x_sms_objs  => x_org_contact_objs(i).sms_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    		END IF;


		hz_extract_cont_point_bo_pvt.get_cont_pref_objs
		(p_init_msg_list => fnd_api.g_false,
		 p_cont_level_table_id  => l_rel_party_id,
	         p_cont_level_table  => 'HZ_PARTIES',
		 p_contact_type   => NULL,
 		 p_action_type => p_action_type,
		 x_cont_pref_objs => x_org_contact_objs(i).contact_pref_objs,
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
        	hz_utility_v2pub.debug(p_message=>'get_org_contact_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_org_contact_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_org_contact_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_org_contact_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;




END HZ_EXTRACT_ORG_CONT_BO_PVT;

/
