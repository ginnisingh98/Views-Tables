--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_ACCT_CONT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_ACCT_CONT_BO_PVT" AS
/*$Header: ARHECCVB.pls 120.7 2006/11/08 22:44:03 awu noship $ */
/*
 * This package contains the private APIs for logical customer account contact.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname customer account contact
 * @rep:category BUSINESS_ENTITY
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf customer account contact Get APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_cust_acct_contact_bos
  --
  -- DESCRIPTION
  --     Get logical customer account contacts.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
 --      p_parent_id          parent id.
--       p_cust_acct_contact_id          customer account contact ID.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_contact_objs         Logical customer account contact records.
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
  --   8-JUN-2005   AWU                Created.
  --

/*

The Get customer account contact API Procedure is a retrieval service that returns a full customer account contact business object.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's Source System
information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels. This includes
 the set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments

Org Contact		Y		N	get_org_contact_bo


To retrieve the appropriate embedded entities within the 'Customer Account Contact' business object, the Get procedure returns
all records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer Account Role	N	N	HZ_CUST_ACCOUNT_ROLES
Role Responsibility	N	Y	HZ_ROLE_RESPONSIBILITY

*/



 PROCEDURE get_cust_acct_contact_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_parent_id           IN            NUMBER,
    p_cust_acct_contact_id           IN            NUMBER,
    p_action_type	  IN VARCHAR2 := NULL,
    x_cust_acct_contact_objs          OUT NOCOPY    HZ_CUST_ACCT_CONTACT_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

CURSOR C1 IS
	SELECT HZ_CUST_ACCT_CONTACT_BO(
		P_ACTION_TYPE,
                NULL, --COMMON_OBJ_ID
		CAR.CUST_ACCOUNT_ROLE_ID, --CUST_ACCT_CONTACT_ID,
		NULL, --ORIG_SYSTEM,
		NULL, --ORIG_SYSTEM_REFERENCE,
		CAR.CUST_ACCOUNT_ID,
		CAR.CUST_ACCT_SITE_ID,
		CAR.PRIMARY_FLAG,
		CAR.ROLE_TYPE,
		CAR.SOURCE_CODE,
		CAR.ATTRIBUTE_CATEGORY,
		CAR.ATTRIBUTE1,
		CAR.ATTRIBUTE2,
		CAR.ATTRIBUTE3,
		CAR.ATTRIBUTE4,
		CAR.ATTRIBUTE5,
		CAR.ATTRIBUTE6,
		CAR.ATTRIBUTE7,
		CAR.ATTRIBUTE8,
		CAR.ATTRIBUTE9,
		CAR.ATTRIBUTE10,
		CAR.ATTRIBUTE11,
		CAR.ATTRIBUTE12,
		CAR.ATTRIBUTE13,
		CAR.ATTRIBUTE14,
		CAR.ATTRIBUTE15,
		CAR.ATTRIBUTE16,
		CAR.ATTRIBUTE17,
		CAR.ATTRIBUTE18,
		CAR.ATTRIBUTE19,
		CAR.ATTRIBUTE20,
		CAR.ATTRIBUTE21,
		CAR.ATTRIBUTE22,
		CAR.ATTRIBUTE23,
		CAR.ATTRIBUTE24,
		CAR.ATTRIBUTE25,
		CAR.STATUS,
		CAR.PROGRAM_UPDATE_DATE,
		CAR.CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CAR.CREATED_BY),
		CAR.CREATION_DATE,
		CAR.LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CAR.LAST_UPDATED_BY),
		R.SUBJECT_ID, --CONTACT_PERSON_ID,
		NULL, --CONTACT_PERSON_OS,
		NULL, --CONTACT_PERSON_OSR,
		R.RELATIONSHIP_ID,
		R.RELATIONSHIP_CODE,
		R.RELATIONSHIP_TYPE,
		R.START_DATE,
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
	OSR.OWNER_TABLE_ID = CAR.CUST_ACCOUNT_ROLE_ID
	AND OWNER_TABLE_NAME = 'HZ_CUST_ACCOUNT_ROLES'
	AND STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL),  -- acct contact ssm
	 CAST(MULTISET (
		SELECT HZ_ORIG_SYS_REF_OBJ(
		NULL, --P_ACTION_TYPE,
		OSR.ORIG_SYSTEM_REF_ID,
		OSR.ORIG_SYSTEM,
		OSR.ORIG_SYSTEM_REFERENCE,
		OSR.OWNER_TABLE_NAME,
		OSR.OWNER_TABLE_ID,
		OSR.STATUS,
		OSR.REASON_CODE,
		OSR.OLD_ORIG_SYSTEM_REFERENCE,
		OSR.START_DATE_ACTIVE,
		OSR.END_DATE_ACTIVE,
		OSR.PROGRAM_UPDATE_DATE,
		OSR.CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(OSR.CREATED_BY),
 		OSR.CREATION_DATE,
 		OSR.LAST_UPDATE_DATE,
 		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(OSR.LAST_UPDATED_BY),
		OSR.ATTRIBUTE_CATEGORY,
		OSR.ATTRIBUTE1,
		OSR.ATTRIBUTE2,
		OSR.ATTRIBUTE3,
		OSR.ATTRIBUTE4,
		OSR.ATTRIBUTE5,
		OSR.ATTRIBUTE6,
		OSR.ATTRIBUTE7,
		OSR.ATTRIBUTE8,
		OSR.ATTRIBUTE9,
		OSR.ATTRIBUTE10,
		OSR.ATTRIBUTE11,
		OSR.ATTRIBUTE12,
		OSR.ATTRIBUTE13,
		OSR.ATTRIBUTE14,
		OSR.ATTRIBUTE15,
		OSR.ATTRIBUTE16,
		OSR.ATTRIBUTE17,
		OSR.ATTRIBUTE18,
		OSR.ATTRIBUTE19,
		OSR.ATTRIBUTE20)
	FROM HZ_ORIG_SYS_REFERENCES OSR, HZ_RELATIONSHIPS R
	WHERE OSR.OWNER_TABLE_ID = R.SUBJECT_ID
	AND CAR.PARTY_ID = R.PARTY_ID
	AND R.SUBJECT_TYPE = 'PERSON'
	AND OSR.OWNER_TABLE_NAME = 'HZ_PARTIES'
	AND OSR.STATUS = 'A') AS HZ_ORIG_SYS_REF_OBJ_TBL), -- contact person ssm
	CAST(MULTISET (
		SELECT HZ_ROLE_RESPONSIBILITY_OBJ(
		P_ACTION_TYPE,
                NULL, --COMMON_OBJ_ID
		RESPONSIBILITY_ID,
		CUST_ACCOUNT_ROLE_ID,
		RESPONSIBILITY_TYPE,
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
		PROGRAM_UPDATE_DATE,
		CREATED_BY_MODULE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(CREATED_BY),
		CREATION_DATE,
		LAST_UPDATE_DATE,
		HZ_EXTRACT_BO_UTIL_PVT.GET_USER_NAME(LAST_UPDATED_BY))
	FROM HZ_ROLE_RESPONSIBILITY
	WHERE CUST_ACCOUNT_ROLE_ID = CAR.CUST_ACCOUNT_ROLE_ID) AS HZ_ROLE_RESPONSIBILITY_OBJ_TBL))
  FROM HZ_CUST_ACCOUNT_ROLES CAR, HZ_CUST_ACCOUNTS CA, HZ_RELATIONSHIPS R
  WHERE
   R.PARTY_ID = CAR.PARTY_ID
   AND CA.PARTY_ID = R.OBJECT_ID
   AND 	CAR.CUST_ACCOUNT_ID = CA.CUST_ACCOUNT_ID
   AND ((P_CUST_ACCT_CONTACT_ID IS NULL AND CAR.CUST_ACCOUNT_ID = P_PARENT_ID)
   OR (P_CUST_ACCT_CONTACT_ID IS NOT NULL
      AND CAR.CUST_ACCOUNT_ROLE_ID = P_CUST_ACCT_CONTACT_ID));


BEGIN


	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_cust_acct_contact_bos(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	x_cust_acct_contact_objs := HZ_CUST_ACCT_CONTACT_BO_TBL();
    	open c1;
	fetch c1 BULK COLLECT into x_cust_acct_contact_objs;
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
        	hz_utility_v2pub.debug(p_message=>'get_cust_acct_contact_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_contact_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_contact_bos (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_cust_acct_contact_bos (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;



END HZ_EXTRACT_ACCT_CONT_BO_PVT;

/
