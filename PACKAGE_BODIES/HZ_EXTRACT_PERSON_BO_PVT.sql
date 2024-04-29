--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_PERSON_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_PERSON_BO_PVT" AS
/*$Header: ARHEPPVB.pls 120.11.12000000.2 2007/02/23 20:56:00 awu ship $ */
/*
 * This package contains the private APIs for logical person.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname Person
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf Person Get APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_person_bo
  --
  -- DESCRIPTION
  --     Get a logical person.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_person_id          Person ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_obj         Logical person record.
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
  --   20-MAY-2005   AWU                Created.
  --

-- Private procedure get_employ_hist_bos

 PROCEDURE get_employ_hist_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_employ_hist_objs    OUT NOCOPY    HZ_EMPLOY_HIST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

CURSOR C1 IS
	SELECT HZ_EMPLOY_HIST_BO(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		EMPLOYMENT_HISTORY_ID,
		PARTY_ID,
		BEGIN_DATE,
		END_DATE,
		EMPLOYMENT_TYPE_CODE,
		EMPLOYED_AS_TITLE_CODE,
		EMPLOYED_AS_TITLE,
		EMPLOYED_BY_NAME_COMPANY,
		EMPLOYED_BY_PARTY_ID,
		EMPLOYED_BY_DIVISION_NAME,
		SUPERVISOR_NAME,
		BRANCH,
		MILITARY_RANK,
		SERVED,
		STATION,
		RESPONSIBILITY,
		WEEKLY_WORK_HOURS,
		REASON_FOR_LEAVING,
		FACULTY_POSITION_FLAG,
		TENURE_CODE,
		FRACTION_OF_TENURE,
		COMMENTS,
		STATUS,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		CAST(MULTISET (
		SELECT HZ_WORK_CLASS_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		WORK_CLASS_ID,
		LEVEL_OF_EXPERIENCE,
		WORK_CLASS_NAME,
		EMPLOYMENT_HISTORY_ID,
		STATUS,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
		FROM HZ_WORK_CLASS
		WHERE WORK_CLASS_ID = P_PERSON_ID
		AND WORK_CLASS_NAME = 'HZ_PARTIES') AS HZ_WORK_CLASS_OBJ_TBL))
	FROM HZ_EMPLOYMENT_HISTORY
	WHERE PARTY_ID = P_PERSON_ID;

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
        	hz_utility_v2pub.debug(p_message=>'get_employ_hist_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	x_employ_hist_objs := HZ_EMPLOY_HIST_BO_TBL();
    	open c1;
	fetch c1 BULK COLLECT into x_employ_hist_objs;
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
        	hz_utility_v2pub.debug(p_message=>'get_employ_hist_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_employ_hist_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_employ_hist_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_employ_hist_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;


/*
The Get Person API Procedure is a retrieval service that returns a full Person business object.
The user identifies a particular Person business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Person business object is returned. The object consists of all data included within
the Person business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Person business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments
Party Site		N	Y		get_party_site_bo
Phone			N	Y		get_phone_bo
Email			N	Y		get_email_bo
Web			N	Y		get_web_bo
SMS			N	Y		get_sms_bo
Employment History	N	Y	Business Structure. Included entities:HZ_EMPLOYMENT_HISTORY, HZ_WORK_CLASS


To retrieve the appropriate embedded entities within the Person business object,
the Get procedure returns all records for the particular person from these TCA entity tables:

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Party,Person Profile	Y		N	HZ_PARTIES, HZ_PERSON_PROFILES
Person Preference	N		Y	HZ_PARTY_PREFERENCES
Relationship		N		Y	HZ_RELATIONSHIPS
Classification		N		Y	HZ_CODE_ASSIGNMENTS
Language		N		Y	HZ_PERSON_LANGUAGE
Education		N		Y	HZ_EDUCATION
Citizenship		N		Y	HZ_CITIZENSHIP
Interest		N		Y	HZ_PERSON_INTEREST
Certification		N		Y	HZ_CERTIFICATIONS
Financial Profile	N		Y	HZ_FINANCIAL_PROFILE
*/



 PROCEDURE get_person_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_person_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

CURSOR C1 IS
	SELECT HZ_PERSON_BO(
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
		HZ_ORIG_SYS_REF_OBJ_TBL(),
 		HZ_EXT_ATTRIBUTE_OBJ_TBL(),
		HZ_PARTY_SITE_BO_TBL(),
		CAST(MULTISET (
		SELECT HZ_PARTY_PREF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		PARTY_PREFERENCE_ID,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_PARTIES',PARTY_ID),
		PARTY_ID,
		CATEGORY,
		PREFERENCE_CODE,
		VALUE_VARCHAR2,
		VALUE_NUMBER,
		VALUE_DATE,
		VALUE_NAME,
		MODULE,
		ADDITIONAL_VALUE1,
		ADDITIONAL_VALUE2,
		ADDITIONAL_VALUE3,
		ADDITIONAL_VALUE4,
		ADDITIONAL_VALUE5,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
		FROM HZ_PARTY_PREFERENCES
		WHERE PARTY_ID = P_PERSON_ID) AS HZ_PARTY_PREF_OBJ_TBL),
		HZ_RELATIONSHIP_OBJ_TBL(),
		HZ_PHONE_CP_BO_TBL(),
		HZ_EMAIL_CP_BO_TBL(),
		HZ_WEB_CP_BO_TBL(),
		HZ_SMS_CP_BO_TBL(),
		CAST(MULTISET (
		SELECT HZ_CODE_ASSIGNMENT_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CODE_ASSIGNMENT_ID,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_PARTIES',OWNER_TABLE_ID),
		OWNER_TABLE_ID,
		CLASS_CATEGORY,
		CLASS_CODE,
		PRIMARY_FLAG,
		ACTUAL_CONTENT_SOURCE,
		START_DATE_ACTIVE,
		END_DATE_ACTIVE,
		STATUS,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY),
		RANK)
	FROM HZ_CODE_ASSIGNMENTS
	WHERE OWNER_TABLE_NAME = 'HZ_PARTIES'
	AND OWNER_TABLE_ID = P_PERSON_ID) AS HZ_CODE_ASSIGNMENT_OBJ_TBL),
	CAST(MULTISET (
	SELECT HZ_PERSON_LANG_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		LANGUAGE_USE_REFERENCE_ID,
		LANGUAGE_NAME,
		PARTY_ID,
		NATIVE_LANGUAGE,
		PRIMARY_LANGUAGE_INDICATOR,
		READS_LEVEL,
		SPEAKS_LEVEL,
		WRITES_LEVEL,
		SPOKEN_COMPREHENSION_LEVEL,
		STATUS,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
	FROM HZ_PERSON_LANGUAGE
	WHERE PARTY_ID = P_PERSON_ID) AS HZ_PERSON_LANG_OBJ_TBL),
	CAST(MULTISET (
	SELECT HZ_EDUCATION_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		EDUCATION_ID,
		PARTY_ID,
		COURSE_MAJOR,
		DEGREE_RECEIVED,
		START_DATE_ATTENDED,
		LAST_DATE_ATTENDED,
		SCHOOL_ATTENDED_NAME,
		SCHOOL_PARTY_ID,
		TYPE_OF_SCHOOL,
		STATUS,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
			HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
		FROM HZ_EDUCATION
		WHERE PARTY_ID = P_PERSON_ID) AS HZ_EDUCATION_OBJ_TBL),
		CAST(MULTISET (
		SELECT HZ_CITIZENSHIP_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CITIZENSHIP_ID,
		PARTY_ID,
		BIRTH_OR_SELECTED,
		COUNTRY_CODE,
		DATE_RECOGNIZED,
		DATE_DISOWNED,
		END_DATE,
		DOCUMENT_TYPE,
		DOCUMENT_REFERENCE,
		STATUS,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
		FROM HZ_CITIZENSHIP
		WHERE PARTY_ID = P_PERSON_ID) AS HZ_CITIZENSHIP_OBJ_TBL),
		HZ_EMPLOY_HIST_BO_TBL(),
		CAST(MULTISET (
		SELECT HZ_PERSON_INTEREST_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		PERSON_INTEREST_ID,
		LEVEL_OF_INTEREST,
		PARTY_ID,
		LEVEL_OF_PARTICIPATION,
		INTEREST_TYPE_CODE,
		COMMENTS,
		SPORT_INDICATOR,
		SUB_INTEREST_TYPE_CODE,
		INTEREST_NAME,
		TEAM,
		SINCE,
		STATUS,
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
			HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
		FROM HZ_PERSON_INTEREST
		WHERE PARTY_ID = P_PERSON_ID) AS HZ_PERSON_INTEREST_OBJ_TBL),
	CAST(MULTISET (
	SELECT HZ_CERTIFICATION_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		CERTIFICATION_ID,
		CERTIFICATION_NAME,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_PARTIES',PARTY_ID),
		PARTY_ID,
		CURRENT_STATUS,
		EXPIRES_ON_DATE,
		GRADE,
		ISSUED_BY_AUTHORITY,
		ISSUED_ON_DATE,
		--WH_UPDATE_DATE,
		STATUS,
		PROGRAM_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
		FROM HZ_CERTIFICATIONS
		WHERE PARTY_ID = P_PERSON_ID) AS HZ_CERTIFICATION_OBJ_TBL),
		CAST(MULTISET (
		SELECT HZ_FINANCIAL_PROF_OBJ(
		P_ACTION_TYPE,
                NULL, -- COMMON_OBJ_ID
		FINANCIAL_PROFILE_ID,
		ACCESS_AUTHORITY_DATE,
		ACCESS_AUTHORITY_GRANTED,
		BALANCE_AMOUNT,
		BALANCE_VERIFIED_ON_DATE,
		FINANCIAL_ACCOUNT_NUMBER,
		FINANCIAL_ACCOUNT_TYPE,
		FINANCIAL_ORG_TYPE,
		FINANCIAL_ORGANIZATION_NAME,
		HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_PARTIES',PARTY_ID),
		PARTY_ID,
		--WH_UPDATE_DATE,
		STATUS,
		PROGRAM_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
		FROM HZ_FINANCIAL_PROFILE
		WHERE PARTY_ID = P_PERSON_ID) AS HZ_FINANCIAL_PROF_OBJ_TBL),
		HZ_CONTACT_PREF_OBJ_TBL(),
		HZ_PARTY_USAGE_OBJ_TBL())
	FROM HZ_PERSON_PROFILES PRO, HZ_PARTIES P
	WHERE PRO.PARTY_ID = P.PARTY_ID
	AND PRO.PARTY_ID = P_PERSON_ID
	AND SYSDATE BETWEEN EFFECTIVE_START_DATE AND NVL(EFFECTIVE_END_DATE,SYSDATE);

 cursor get_profile_id_csr is
	select person_profile_id
	from HZ_PERSON_PROFILES
	where party_id = p_person_id
	AND sysdate between effective_start_date and nvl(effective_end_date,sysdate);
 l_debug_prefix              VARCHAR2(30) := '';
 l_prof_id number;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_person_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	open c1;
	fetch c1 into x_person_obj;
	close c1;

	HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_owner_table_id => p_person_id,
	         p_owner_table_name => 'HZ_PARTIES',
		 p_action_type => NULL, --p_action_type,
		 x_orig_sys_ref_objs => x_person_obj.orig_sys_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_PARTY_USAGE_BO_PVT.get_party_usage_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_owner_table_id => p_person_id,
	         p_owner_table_name => 'HZ_PARTIES',
		 p_action_type => p_action_type,
		 x_party_usage_objs => x_person_obj.party_usage_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	open get_profile_id_csr;
	fetch  get_profile_id_csr into l_prof_id;
	close  get_profile_id_csr;

	hz_extract_ext_attri_bo_pvt.get_ext_attribute_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_ext_object_id => l_prof_id,
    		 p_ext_object_name => 'HZ_PERSON_PROFILES',
		 p_action_type => p_action_type,
		 x_ext_attribute_objs => x_person_obj.ext_attributes_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;



	HZ_EXTRACT_PARTY_SITE_BO_PVT.get_party_site_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_party_id => p_person_id,
	         p_party_site_id => NULL,
		 p_action_type => p_action_type,
		 x_party_site_objs => x_person_obj.party_site_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_RELATIONSHIP_BO_PVT.get_relationship_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_subject_id => p_person_id,
 		 p_action_type => p_action_type,
		 x_relationship_objs => x_person_obj.relationship_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	hz_extract_cont_point_bo_pvt.get_phone_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_phone_id => null,
		 p_parent_id => p_person_id,
	         p_parent_table_name => 'HZ_PARTIES',
		 p_action_type => p_action_type,
		 x_phone_objs  => x_person_obj.phone_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	hz_extract_cont_point_bo_pvt.get_email_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_email_id => null,
		 p_parent_id => p_person_id,
	         p_parent_table_name => 'HZ_PARTIES',
		 p_action_type => p_action_type,
		 x_email_objs  => x_person_obj.email_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	hz_extract_cont_point_bo_pvt.get_web_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_web_id => null,
		 p_parent_id => p_person_id,
	         p_parent_table_name => 'HZ_PARTIES',
		 p_action_type => p_action_type,
		 x_web_objs  => x_person_obj.web_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	hz_extract_cont_point_bo_pvt.get_sms_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_sms_id => null,
		 p_parent_id => p_person_id,
	         p_parent_table_name => 'HZ_PARTIES',
   		 p_action_type => p_action_type,
		 x_sms_objs  => x_person_obj.sms_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	get_employ_hist_bos(p_init_msg_list => fnd_api.g_false,
		 p_person_id => p_person_id,
		 p_action_type => p_action_type,
		 x_employ_hist_objs => x_person_obj.employ_hist_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);


	hz_extract_cont_point_bo_pvt.get_cont_pref_objs
		(p_init_msg_list => fnd_api.g_false,
		 p_cont_level_table_id  => p_person_id,
	         p_cont_level_table  => 'HZ_PARTIES',
		 p_contact_type   => NULL,
		 p_action_type => p_action_type,
		 x_cont_pref_objs => x_person_obj.contact_pref_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_person_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_person_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_person_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_person_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;



 --------------------------------------
  --
  -- PROCEDURE get_persons_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Persons created business event and
  --the procedure returns database objects of the type HZ_PERSON_BO for all of
  --the Person business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_objs        One or more created logical person.
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
  --   20-MAY-2005    AWU                Created.
  --



/*
The Get Persons Created procedure is a service to retrieve all of the Person business objects
whose creations have been captured by a logical business event. Each Persons Created
business event signifies that one or more Person business objects have been created.
The caller provides an identifier for the Persons Created business event and the procedure
returns all of the Person business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_PERSON_BO_PVT.get_person_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_persons_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_objs         OUT NOCOPY    HZ_PERSON_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

l_obj_root_ids HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL;
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
        	hz_utility_v2pub.debug(p_message=>'get_person_created(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => l_obj_root_ids,
   	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

   	x_person_objs := HZ_PERSON_BO_TBL();

	for i in 1..l_obj_root_ids.count loop

		x_person_objs.extend;
		get_person_bo(
    		p_init_msg_list => fnd_api.g_false,
    		p_person_id  => l_obj_root_ids(i),
    		p_action_type => 'CREATED',
    		x_person_obj  => x_person_objs(i),
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
        	hz_utility_v2pub.debug(p_message=>'get_person_created (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_person_created(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_person_created(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_person_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;



--------------------------------------
  --
  -- PROCEDURE get_persons_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Persons update business event and
  --the procedure returns database objects of the type HZ_PERSON_BO for all of
  --the Person business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_objs        One or more created logical person.
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
  --   20-MAY-2005     AWU                Created.
  --



/*
The Get Persons Updated procedure is a service to retrieve all of the Person business objects whose updates have been
captured by the logical business event. Each Persons Updated business event signifies that one or more Person business
objects have been updated.
The caller provides an identifier for the Persons Update business event and the procedure returns database objects of
the type HZ_PERSON_BO for all of the Person business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure
and returns them to the caller.
*/

 PROCEDURE get_persons_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_objs         OUT NOCOPY    HZ_PERSON_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

l_obj_root_ids HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL;
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
        	hz_utility_v2pub.debug(p_message=>'get_persons_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => l_obj_root_ids,
   	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- call event API get_organization_updated for each id.

   	x_person_objs := HZ_PERSON_BO_TBL();

	for i in 1..l_obj_root_ids.count loop

		x_person_objs.extend;
		get_person_updated(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
    		p_person_id  => l_obj_root_ids(i),
    		x_person_obj  => x_person_objs(i),
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
        	hz_utility_v2pub.debug(p_message=>'get_persons_updated (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_persons_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_persons_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_persons_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

-- Based on BOT, for updated branch, set action_type = 'UPDATED'/'CREATED'
procedure set_person_bo_action_type(p_event_id		  IN           	NUMBER,
				    p_root_id  IN NUMBER,
				    px_person_obj IN OUT NOCOPY HZ_PERSON_BO,
				    x_return_status       OUT NOCOPY    VARCHAR2) is
	cursor c1 is

	   SELECT
  		sys_connect_by_path(CHILD_BO_CODE, '/') node_path,
  		CHILD_OPERATION_FLAG,
  		CHILD_BO_CODE,
  		CHILD_ENTITY_NAME,
  		CHILD_ID,
  		populated_flag
	 FROM HZ_BUS_OBJ_TRACKING
         where event_id = p_event_id
	 START WITH child_id = p_root_id
   		AND child_entity_name = 'HZ_PARTIES'
   		AND  PARENT_BO_CODE IS NULL
   		AND event_id = p_event_id
   		AND CHILD_BO_CODE = 'PERSON' --(or ORG, PERSON_CUST, ORG_CUST).
		and event_id = p_event_id
	CONNECT BY PARENT_ENTITY_NAME = PRIOR CHILD_ENTITY_NAME
    	AND PARENT_ID = PRIOR CHILD_ID
    	AND parent_bo_code = PRIOR child_bo_code
	and event_id = PRIOR event_id;

	cursor c2 is
    	   select CHILD_ENTITY_NAME
	    FROM HZ_BUS_OBJ_TRACKING
	    where event_id = p_event_id
	    and populated_flag = 'N'
	    and CHILD_ENTITY_NAME = 'HZ_PERSON_PROFILES';

L_CHILD_OPERATION_FLAG VARCHAR2(1);
L_CHILD_BO_CODE VARCHAR2(30);
L_CHILD_ENTITY_NAME  VARCHAR2(30);
L_CHILD_ID NUMBER;
l_action_type varchar2(30);
l_node_path varchar2(2000);
l_populated_flag varchar2(1);
l_child_upd_flag varchar2(1);

begin
	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Solve populate_flag is not in sync in hz_parties and hz_org_profiles.
        -- c1 can't return profile entity.

	open c2;
        fetch c2 into L_CHILD_ENTITY_NAME;
	close c2;

	if l_child_entity_name =  'HZ_PERSON_PROFILES'
	then
		px_person_obj.action_type := 'UPDATED';
	else px_person_obj.action_type := 'CHILD_UPDATED';
	end if;

	open c1;
	loop
		fetch c1 into L_NODE_PATH, L_CHILD_OPERATION_FLAG,L_CHILD_BO_CODE,
			L_CHILD_ENTITY_NAME, L_CHILD_ID, l_populated_flag;
		exit when c1%NOTFOUND;
	   if l_populated_flag = 'N'
	   then
		if L_CHILD_OPERATION_FLAG = 'I'
		then l_action_type := 'CREATED';
		elsif  L_CHILD_OPERATION_FLAG = 'U'
		then l_action_type := 'UPDATED';
		end if;

		-- check first level entity objects

	        if l_child_entity_name = 'HZ_EDUCATION' then
			for i in 1..PX_PERSON_OBJ.EDUCATION_OBJS .COUNT
			loop
				if PX_PERSON_OBJ.EDUCATION_OBJS(i).education_id = l_child_id
				then PX_PERSON_OBJ.EDUCATION_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;
		elsif l_child_entity_name = 'HZ_PARTY_USG_ASSIGNMENTS' then
			for i in 1..PX_PERSON_OBJ.PARTY_USAGE_OBJS .COUNT
			loop
				if PX_PERSON_OBJ.PARTY_USAGE_OBJS(i).party_usg_assignment_id = l_child_id
				then PX_PERSON_OBJ.PARTY_USAGE_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;
       		elsif l_child_entity_name = 'HZ_CITIZENSHIP' then
			for i in 1..PX_PERSON_OBJ.CITIZENSHIP_OBJS .COUNT
			loop
				if PX_PERSON_OBJ.CITIZENSHIP_OBJS(i).citizenship_id = l_child_id
				then PX_PERSON_OBJ.CITIZENSHIP_OBJS(i).action_type := l_action_type;
				end if;
			end loop;
       		elsif l_child_entity_name = 'HZ_RELATIONSHIPS' then
			for i in 1..PX_PERSON_OBJ.RELATIONSHIP_OBJS .COUNT
			loop
				if PX_PERSON_OBJ.RELATIONSHIP_OBJS(i).relationship_id = l_child_id
				then PX_PERSON_OBJ.RELATIONSHIP_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;
       		elsif l_child_entity_name = 'HZ_CERTIFICATIONS' then
			for i in 1..PX_PERSON_OBJ.CERTIFICATION_OBJS .COUNT
			loop
				if PX_PERSON_OBJ.CERTIFICATION_OBJS(i).certification_id = l_child_id
				then PX_PERSON_OBJ.CERTIFICATION_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;

			end loop;
       		elsif l_child_entity_name = 'HZ_PERSON_INTEREST' then
			for i in 1..PX_PERSON_OBJ.INTEREST_OBJS .COUNT
			loop
				if PX_PERSON_OBJ.INTEREST_OBJS(i).person_interest_id = l_child_id
				then PX_PERSON_OBJ.INTEREST_OBJS(i).action_type := l_action_type;
				end if;
				l_child_upd_flag := 'Y';
			end loop;
       		elsif l_child_entity_name = 'HZ_PERSON_LANGUAGE' then
			for i in 1..PX_PERSON_OBJ.LANGUAGE_OBJS .COUNT
			loop
				if PX_PERSON_OBJ.LANGUAGE_OBJS(i).LANGUAGE_USE_REFERENCE_ID = l_child_id
				then PX_PERSON_OBJ.LANGUAGE_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;
       		elsif l_child_entity_name = 'HZ_CODE_ASSIGNMENTS' then
			for i in 1..PX_PERSON_OBJ.CLASS_OBJS .COUNT
			loop
				if PX_PERSON_OBJ.CLASS_OBJS(i).code_assignment_id = l_child_id
				then PX_PERSON_OBJ.CLASS_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;
       		elsif l_child_entity_name = 'HZ_FINANCIAL_PROFILE' then
			for i in 1..PX_PERSON_OBJ.FINANCIAL_PROF_OBJS .COUNT
			loop
				if PX_PERSON_OBJ.FINANCIAL_PROF_OBJS(i).financial_profile_id = l_child_id
				then PX_PERSON_OBJ.FINANCIAL_PROF_OBJS(i).action_type := l_action_type;
				l_child_upd_flag := 'Y';
				end if;
			end loop;
       		elsif l_child_entity_name = 'HZ_PARTY_PREFERENCES' then
			for i in 1..PX_PERSON_OBJ.PREFERENCE_OBJS .COUNT
			loop
				if PX_PERSON_OBJ.PREFERENCE_OBJS(i).party_preference_id = l_child_id
				then PX_PERSON_OBJ.PREFERENCE_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;
		elsif l_child_entity_name = 'HZ_PER_PROFILES_EXT_VL' then
			for i in 1..PX_PERSON_OBJ.EXT_ATTRIBUTES_OBJS .COUNT
			loop
				if PX_PERSON_OBJ.EXT_ATTRIBUTES_OBJS(i).extension_id = l_child_id
				then PX_PERSON_OBJ.EXT_ATTRIBUTES_OBJS(i).action_type := l_action_type;
					l_child_upd_flag := 'Y';
				end if;
			end loop;

		-- contact preference might have multiple parents, but one id will not belong to
                -- more than one parents
       		elsif l_child_entity_name = 'HZ_CONTACT_PREFERENCES'  then

			for i in 1..PX_PERSON_OBJ.CONTACT_PREF_OBJS .COUNT
			loop
				if PX_PERSON_OBJ.CONTACT_PREF_OBJS(i).contact_preference_id = l_child_id
				then PX_PERSON_OBJ.CONTACT_PREF_OBJS(i).action_type := l_action_type;
						l_child_upd_flag := 'Y';
				end if;
			end loop;

			if instr(l_node_path, 'PERSON/PHONE') > 0 then
		        	for i in 1..PX_PERSON_OBJ.PHONE_OBJS.COUNT
				loop
					for j in 1..PX_PERSON_OBJ.PHONE_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if px_person_obj.phone_objs(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then px_person_obj.phone_objs(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;
						end if;
					end loop;
				end loop;
			end if;
			if instr(l_node_path, 'PERSON/EMAIL') > 0 then
				for i in 1..PX_PERSON_OBJ.EMAIL_OBJS.COUNT
				loop
					for j in 1..PX_PERSON_OBJ.EMAIL_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if px_person_obj.email_objs(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then px_person_obj.email_objs(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;

						end if;
					end loop;
				end loop;
			end if;
			if instr(l_node_path, 'PERSON/WEB') > 0 then
				for i in 1..PX_PERSON_OBJ.WEB_OBJS.COUNT
				loop
					for j in 1..PX_PERSON_OBJ.WEB_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if px_person_obj.web_objs(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then px_person_obj.web_objs(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;

						end if;
					end loop;
				end loop;
			end if;
			if instr(l_node_path, 'PERSON/SMS') > 0 then
				for i in 1..PX_PERSON_OBJ.SMS_OBJS.COUNT
				loop
					for j in 1..PX_PERSON_OBJ.SMS_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if px_person_obj.sms_objs(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then px_person_obj.sms_objs(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;
						l_child_upd_flag := 'Y';
						end if;
					end loop;
				end loop;
			end if;

		elsif l_child_entity_name = 'HZ_CONTACT_POINTS'  then
			if l_child_bo_code = 'EMAIL'
			then
				for i in 1..PX_PERSON_OBJ.EMAIL_OBJS.COUNT
				loop
					if PX_PERSON_OBJ.EMAIL_OBJS(i).email_id = l_child_id
					then PX_PERSON_OBJ.EMAIL_OBJS(i).action_type := l_action_type;
						l_child_upd_flag := 'Y';
					end if;
				end loop;
			elsif l_child_bo_code = 'PHONE'
			then
				for i in 1..PX_PERSON_OBJ.PHONE_OBJS.COUNT
				loop
					if PX_PERSON_OBJ.PHONE_OBJS(i).phone_id = l_child_id
					then PX_PERSON_OBJ.PHONE_OBJS(i).action_type := l_action_type;
						l_child_upd_flag := 'Y';
					end if;
				end loop;
			elsif l_child_bo_code = 'WEB'
			then
				for i in 1..PX_PERSON_OBJ.WEB_OBJS.COUNT
				loop
					if PX_PERSON_OBJ.WEB_OBJS(i).web_id = l_child_id
					then PX_PERSON_OBJ.WEB_OBJS(i).action_type := l_action_type;
						l_child_upd_flag := 'Y';
					end if;
				end loop;
			elsif l_child_bo_code = 'SMS'
			then
				for i in 1..PX_PERSON_OBJ.SMS_OBJS.COUNT
				loop
					if PX_PERSON_OBJ.SMS_OBJS(i).sms_id = l_child_id
					then PX_PERSON_OBJ.SMS_OBJS(i).action_type := l_action_type;
						l_child_upd_flag := 'Y';
					end if;
				end loop;
			end if;
		end if;

		-- check party site object

		if instr(l_node_path, 'PERSON/PARTY_SITE') > 0
		then
			for i in 1..PX_PERSON_OBJ.PARTY_SITE_OBJS.COUNT
			loop
				-- check root level
				if l_child_entity_name = 'HZ_PARTY_SITES'
				then
				   if px_person_obj.party_site_objs(i).party_site_id = l_child_id
				   then
				     px_person_obj.party_site_objs(i).action_type := l_action_type;
				     l_child_upd_flag := 'N';
				      if l_action_type = 'CREATED'
				     then
				        px_person_obj.party_site_objs(i).location_obj.action_type :='CREATED';
					l_child_upd_flag := 'Y';
	                 	     end if;

				   end if;
				end if;

				-- check second level

				if l_child_entity_name = 'HZ_LOCATIONS'
				then
					if px_person_obj.party_site_objs(i).location_obj.location_id = l_child_id and l_action_type = 'UPDATED'
					then px_person_obj.party_site_objs(i).location_obj.action_type := l_action_type;
					     l_child_upd_flag := 'Y';
					end if;
				end if;
				if l_child_entity_name = 'HZ_CONTACT_POINTS'
				then
				  if l_child_bo_code = 'EMAIL'
				  then
					for j in 1..PX_PERSON_OBJ.PARTY_SITE_OBJS(i).EMAIL_OBJS.COUNT
					loop
						if PX_PERSON_OBJ.PARTY_SITE_OBJS(i).EMAIL_OBJS(j).email_id = l_child_id
						then PX_PERSON_OBJ.PARTY_SITE_OBJS(i).EMAIL_OBJS(j).action_type := l_action_type;
					             l_child_upd_flag := 'Y';
						end if;
					end loop;
				  elsif l_child_bo_code = 'PHONE'
				  then
					for j in 1..PX_PERSON_OBJ.PARTY_SITE_OBJS(i).PHONE_OBJS.COUNT
					loop
						if PX_PERSON_OBJ.PARTY_SITE_OBJS(i).PHONE_OBJS(j).phone_id = l_child_id
						then PX_PERSON_OBJ.PARTY_SITE_OBJS(i).PHONE_OBJS(j).action_type := l_action_type;
					             l_child_upd_flag := 'Y';
						end if;
					end loop;
				  elsif l_child_bo_code = 'WEB'
				  then
					for j in 1..PX_PERSON_OBJ.PARTY_SITE_OBJS(i).WEB_OBJS.COUNT
					loop
						if PX_PERSON_OBJ.PARTY_SITE_OBJS(i).WEB_OBJS(j).web_id = l_child_id
						then PX_PERSON_OBJ.PARTY_SITE_OBJS(i).WEB_OBJS(j).action_type := l_action_type;
					             l_child_upd_flag := 'Y';
						end if;
					end loop;
				elsif l_child_bo_code = 'TLX'
				then
					for j in 1..PX_PERSON_OBJ.PARTY_SITE_OBJS(i).TELEX_OBJS.COUNT
					loop
						if PX_PERSON_OBJ.PARTY_SITE_OBJS(i).TELEX_OBJS(j).telex_id = l_child_id
						then PX_PERSON_OBJ.PARTY_SITE_OBJS(i).TELEX_OBJS(j).action_type := l_action_type;
					             l_child_upd_flag := 'Y';
						end if;
					end loop;
				end if;
			end if;	--'HZ_CONTACT_POINTS'
			if l_child_entity_name = 'HZ_CONTACT_PREFERENCES' then
					for j in 1..PX_PERSON_OBJ.PARTY_SITE_OBJS(i).CONTACT_PREF_OBJS.count
					loop
						if PX_PERSON_OBJ.PARTY_SITE_OBJS(i).CONTACT_PREF_OBJS(j).contact_preference_id = l_child_id
						then PX_PERSON_OBJ.PARTY_SITE_OBJS(i).CONTACT_PREF_OBJS(j).action_type := l_action_type;

					             l_child_upd_flag := 'Y';						end if;
					end loop;
			end if;

				if  px_person_obj.party_site_objs(i).action_type =  'UNCHANGED'
				    and l_child_upd_flag = 'Y'
				then
				    px_person_obj.party_site_objs(i).action_type := 'CHILD_UPDATED';
			        end if;
			end loop; -- party_site_obj
		end if;  -- party_site_obj

		-- check emp history object

		if instr(l_node_path, 'PERSON/EMP_HIST') > 0
		then
			for i in 1..PX_PERSON_OBJ.EMPLOY_HIST_OBJS.COUNT
			loop
				-- check root level
				if l_child_entity_name = 'HZ_EMPLOYMENT_HISTORY'
				then
				   if px_person_obj.EMPLOY_HIST_OBJS(i).EMPLOYMENT_HISTORY_ID = l_child_id
				   then
				     px_person_obj.EMPLOY_HIST_OBJS(i).action_type := l_action_type;
				     l_child_upd_flag := 'N';
				   end if;
				end if;

				-- check second level

				if l_child_entity_name = 'HZ_WORK_CLASS'
				then
					for j in 1..PX_PERSON_OBJ.EMPLOY_HIST_OBJS(i).WORK_CLASS_OBJS.COUNT
					loop
						if PX_PERSON_OBJ.EMPLOY_HIST_OBJS(i).WORK_CLASS_OBJS(j).work_class_id = l_child_id
						then PX_PERSON_OBJ.EMPLOY_HIST_OBJS(i).WORK_CLASS_OBJS(j).action_type := l_action_type;
						     l_child_upd_flag := 'Y';
						end if;
					end loop;
				end if;
				if  px_person_obj.employ_hist_objs(i).action_type =  'UNCHANGED'
				    and l_child_upd_flag = 'Y'
				then
				    px_person_obj.employ_hist_objs(i).action_type := 'CHILD_UPDATED';
			        end if;
			end loop; -- emp history
		end if; -- emp history
          end if;  -- populated_flag = 'N'
	end loop;
	close c1;

EXCEPTION


    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;


WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

end set_person_bo_action_type;

--------------------------------------
  --
  -- PROCEDURE get_person_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Persons update business event and person_id
  --the procedure returns one database object of the type HZ_PERSON_BO

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --     p_person_id          Person identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_objs        One or more created logical person.
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
  --   10-JUN-2005     AWU                Created.
  --



-- Get only one person object based on p_person_id and event_id

PROCEDURE get_person_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id		  IN           	NUMBER,
    p_person_id           IN           NUMBER,
    x_person_obj          OUT NOCOPY    HZ_PERSON_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
l_obj_root_ids HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL;
l_debug_prefix              VARCHAR2(30) := '';
l_person_obj   HZ_PERSON_BO;

begin

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_person_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;
/*   moved to public api
	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => p_person_id,
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;
*/

	-- Set  action type to 'UNCHANGED' by default

	get_person_bo(
    		p_init_msg_list => fnd_api.g_false,
    		p_person_id  => p_person_id,
    		p_action_type => 'UNCHANGED',
    		x_person_obj  => x_person_obj,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	-- Based on BOT, for updated branch, set action_type = 'UPDATED'/'CREATED'


	l_person_obj := x_person_obj;
	set_person_bo_action_type(p_event_id  => p_event_id,
				p_root_id     => p_person_id,
				px_person_obj => l_person_obj,
				x_return_status => x_return_status
				);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	x_person_obj := l_person_obj;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_person_updated (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_person_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_person_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_person_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;




END HZ_EXTRACT_PERSON_BO_PVT;

/
