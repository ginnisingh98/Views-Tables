--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_MERGE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_MERGE_EVENT_PKG" AS
/*$Header: ARHMEVTB.pls 120.3.12010000.10 2009/06/09 09:43:36 vsegu ship $ */

--5093366
FUNCTION get_object_type(
   p_table_name           IN     VARCHAR2,
   p_table_id             IN     NUMBER
) RETURN VARCHAR2 IS

object_type VARCHAR2(30);

CURSOR get_contact_point_type IS
        SELECT contact_point_type
	FROM hz_contact_points
	WHERE contact_point_id = p_table_id;
BEGIN
object_type := NULL;
object_type := HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type(p_table_name,p_table_id);

IF object_type IS null THEN
   IF p_table_name = 'HZ_CONTACT_POINTS' THEN
	OPEN get_contact_point_type;
	FETCH get_contact_point_type INTO object_type;
	CLOSE get_contact_point_type;
   ELSIF p_table_name = 'HZ_ORG_CONTACTS' THEN
	return 'ORG_CONTACT';
   ELSIF (p_table_name = 'HZ_FINANCIAL_REPORTS') THEN
	return 'FIN_REPORT';
   ELSIF (p_table_name = 'HZ_EMPLOYMENT_HISTORY') THEN
	return 'EMP_HIST';
   ELSIF (p_table_name = 'HZ_CUSTOMER_PROFILES') THEN
	return 'CUST_PROFILE';
   ELSE
	return p_table_name;
   END IF;
END IF;

return object_type;

END get_object_type;

--Function returns operating unit name
FUNCTION get_operating_unit( p_org_id NUMBER) RETURN VARCHAR2 IS
l_operating_unit VARCHAR2(240);
BEGIN
	SELECT name INTO l_operating_unit
	FROM hr_operating_units
	WHERE organization_id = p_org_id;

	return l_operating_unit;

END get_operating_unit;

  --------------------------------------
  --
  -- PROCEDURE get_account_merge_event_data
  --
  -- DESCRIPTION
  --     Get account merge details.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN: p_init_msg_list
  --       p_customer_merge_header_id
  --   OUT:x_account_merge_obj
  --       x_return_status
  --       x_msg_count
  --       x_msg_data
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --
  --   25-AUG-2005   S V Sowjanya                Created.


PROCEDURE get_account_merge_event_data(
    p_init_msg_list       	IN            VARCHAR2 := fnd_api.g_false,
    p_customer_merge_header_id  IN            NUMBER,
    x_account_merge_obj         OUT NOCOPY    HZ_ACCT_MERGE_OBJ,
    x_return_status       	OUT NOCOPY    VARCHAR2,
    x_msg_count           	OUT NOCOPY    NUMBER,
    x_msg_data            	OUT NOCOPY    VARCHAR2
  ) IS
l_debug_prefix              VARCHAR2(30) := '';
CURSOR  account_merge_details IS

    SELECT HZ_ACCT_MERGE_OBJ(
           p_customer_merge_header_id,
           mh.request_id,
           mh.created_by,
	   mh.creation_date,
	   mh.last_update_login,
	   mh.last_update_date,
	   mh.last_updated_by,
	   HZ_PARTY_ORIG_SYS_REF_OBJ(
           tp.party_id,
	   tp.party_number,
	   tp.party_name,
	   tp.party_type,
           HZ_ORIG_SYS_REF_OBJ_TBL()),
           HZ_PARTY_ORIG_SYS_REF_OBJ(
           fp.party_id,
           fp.party_number,
           fp.party_name,
           fp.party_type,
           HZ_ORIG_SYS_REF_OBJ_TBL()),
           HZ_ACCT_ORIG_SYS_REF_OBJ(
           ta.cust_account_id,
	   ta.account_name,
	   ta.account_number,
	   HZ_ORIG_SYS_REF_OBJ_TBL()),
	   CAST(MULTISET (
		SELECT HZ_ACCT_ORIG_SYS_REF_OBJ(
                     fa.cust_account_id,
                     fa.account_name,
		     fa.account_number,
                     HZ_ORIG_SYS_REF_OBJ_TBL())
		FROM hz_cust_accounts_m fa
                WHERE fa.cust_account_id = mh.duplicate_id
		) AS HZ_ACCT_ORIG_SYS_REF_OBJ_TBL)
   )
   FROM ra_customer_merge_headers mh, hz_cust_accounts ta, hz_parties tp, hz_cust_accounts_m fa, hz_parties fp
   WHERE mh.customer_merge_header_id = p_customer_merge_header_id
   AND   ta.cust_account_id = mh.customer_id
   AND   tp.party_id = ta.party_id
   AND   fa.cust_account_id = mh.duplicate_id
   AND   fp.party_id = fa.party_id
   AND   rownum = 1;


BEGIN

        -- initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'get_account_merge_event_data(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

	open account_merge_details;
        fetch account_merge_details  into x_account_merge_obj;
        close account_merge_details;

        	    -- SSM for merge-to acct party obj
        HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_owner_table_id => x_account_merge_obj.merge_to_acct_party_obj.party_id,
	         p_owner_table_name => 'HZ_PARTIES',
		 p_action_type => NULL,
		 x_orig_sys_ref_objs => x_account_merge_obj.merge_to_acct_party_obj.orig_sys_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
        END IF;

                    -- SSM for merge-from acct party obj
        HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                (p_init_msg_list => fnd_api.g_false,
                 p_owner_table_id => x_account_merge_obj.merge_from_acct_party_obj.party_id,
                 p_owner_table_name => 'HZ_PARTIES',
                 p_action_type => NULL,
                 x_orig_sys_ref_objs => x_account_merge_obj.merge_from_acct_party_obj.orig_sys_objs,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
       END IF;
                   -- SSM for merge to account obj
       HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                (p_init_msg_list => fnd_api.g_false,
                 p_owner_table_id => x_account_merge_obj.merge_to_account_obj.cust_acct_id,
                 p_owner_table_name => 'HZ_CUST_ACCOUNTS',
                 p_action_type => NULL,
                 x_orig_sys_ref_objs => x_account_merge_obj.merge_to_account_obj.orig_sys_objs,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
       END IF;

        FOR I in 1..x_account_merge_obj.merge_from_account_objs.count LOOP

                HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                (p_init_msg_list => fnd_api.g_false,
                 p_owner_table_id => x_account_merge_obj.merge_from_account_objs(I).cust_acct_id,
                 p_owner_table_name => 'HZ_CUST_ACCOUNTS',
                 p_action_type => NULL,
                 x_orig_sys_ref_objs => x_account_merge_obj.merge_from_account_objs(I).orig_sys_objs,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        END LOOP;

        -- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_account_merge_event_data(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_account_merge_event_data(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_account_merge_event_data(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_account_merge_event_data(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
END get_account_merge_event_data;

--------------------------------------
  --
  -- PROCEDURE get_account_merge_event_data
  --
  -- DESCRIPTION
  --     Get account merge details.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN: p_init_msg_list
  --       p_customer_merge_header_id
  --       p_get_merge_detail_flag
  --   OUT:x_account_merge_v2_obj
  --       x_return_status
  --       x_msg_count
  --       x_msg_data
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --
  --   6-Jan-2009   S V Sowjanya                Created.


PROCEDURE get_account_merge_event_data(
    p_init_msg_list       	IN            VARCHAR2 := fnd_api.g_false,
    p_customer_merge_header_id  IN            NUMBER,
    p_get_merge_detail_flag     IN            VARCHAR2 := 'N',
    x_account_merge_v2_obj         OUT NOCOPY    HZ_ACCOUNT_MERGE_V2_OBJ,
    x_return_status       	OUT NOCOPY    VARCHAR2,
    x_msg_count           	OUT NOCOPY    NUMBER,
    x_msg_data            	OUT NOCOPY    VARCHAR2
  ) IS
  l_debug_prefix              VARCHAR2(30) := '';
  CURSOR  account_merge_details IS

    SELECT HZ_ACCOUNT_MERGE_V2_OBJ(
           p_customer_merge_header_id,
	   mh.delete_duplicate_flag,
           mh.request_id,
           mh.created_by,
	   mh.creation_date,
	   mh.last_update_login,
	   mh.last_update_date,
	   mh.last_updated_by,
	   HZ_PARTY_ORIG_SYS_REF_OBJ(
           tp.party_id,
	   tp.party_number,
	   tp.party_name,
	   tp.party_type,
           HZ_ORIG_SYS_REF_OBJ_TBL()),
           HZ_PARTY_ORIG_SYS_REF_OBJ(
           fp.party_id,
           fp.party_number,
           fp.party_name,
           fp.party_type,
           HZ_ORIG_SYS_REF_OBJ_TBL()),
           HZ_ACCT_ORIG_SYS_REF_OBJ(
           ta.cust_account_id,
	   ta.account_name,
	   ta.account_number,
	   HZ_ORIG_SYS_REF_OBJ_TBL()),
	   CAST(MULTISET (
		SELECT HZ_ACCT_ORIG_SYS_REF_OBJ(
                     fa.cust_account_id,
                     fa.account_name,
		     fa.account_number,
                     HZ_ORIG_SYS_REF_OBJ_TBL())
		FROM hz_cust_accounts_m fa
                WHERE fa.cust_account_id = mh.duplicate_id
		) AS HZ_ACCT_ORIG_SYS_REF_OBJ_TBL),
    HZ_ACCT_MERGE_DETAIL_OBJ_TBL(),  --ACCT_SITE_OBJS
    HZ_ACCT_MERGE_DETAIL_OBJ_TBL(),  --ACCT_SITE_USES_OBJS
    HZ_ACCT_MERGE_DETAIL_OBJ_TBL(),  --ACCT_ROLE_OBJS
    HZ_ACCT_MERGE_DETAIL_OBJ_TBL(),  --CUSTOMER_PROFILE_OBJS
    HZ_ACCT_MERGE_DETAIL_OBJ_TBL(),  --CUST_PROFILE_AMT_OBJS
    HZ_ACCT_MERGE_DETAIL_OBJ_TBL()   --ACCT_REL_OBJS
   )
   FROM ra_customer_merge_headers mh, hz_cust_accounts ta, hz_parties tp, hz_cust_accounts_m fa, hz_parties fp
   WHERE mh.customer_merge_header_id = p_customer_merge_header_id
   AND   ta.cust_account_id = mh.customer_id
   AND   tp.party_id = ta.party_id
   AND   fa.cust_account_id = mh.duplicate_id
   AND   fp.party_id = fa.party_id
   AND   rownum = 1;

   CURSOR get_site_details IS

      SELECT HZ_ACCOUNT_MERGE_DETAIL_OBJ(
              get_object_type('HZ_CUST_ACCT_SITES', cm.duplicate_address_id),
              decode(cm.customer_createsame, 'N', 'Merge', 'Y', 'Transfer'),
	      cm.org_id,
	      get_operating_unit(cm.org_id),
              cm.duplicate_address_id,
              CAST(MULTISET(
			SELECT HZ_ORIG_SYS_REF_OBJ(
				NULL,
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
				ATTRIBUTE20
				)
			FROM HZ_ORIG_SYS_REFERENCES
			WHERE OWNER_TABLE_ID = 	cm.duplicate_address_id
			AND OWNER_TABLE_NAME =  'HZ_CUST_ACCT_SITES_ALL'
	     )AS HZ_ORIG_SYS_REF_OBJ_TBL),
              cm.customer_address_id,
               CAST(MULTISET(
			SELECT HZ_ORIG_SYS_REF_OBJ(
				NULL,
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
				ATTRIBUTE20
				)
			FROM HZ_ORIG_SYS_REFERENCES
			WHERE OWNER_TABLE_ID = 	cm.customer_address_id
			AND OWNER_TABLE_NAME =  'HZ_CUST_ACCT_SITES_ALL'
	     )AS HZ_ORIG_SYS_REF_OBJ_TBL),
              cm.duplicate_id,
               CAST(MULTISET(
			SELECT HZ_ORIG_SYS_REF_OBJ(
				NULL,
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
				ATTRIBUTE20
				)
			FROM HZ_ORIG_SYS_REFERENCES
			WHERE OWNER_TABLE_ID = 	cm.duplicate_id
			AND OWNER_TABLE_NAME =  'HZ_CUST_ACCOUNTS'
	     )AS HZ_ORIG_SYS_REF_OBJ_TBL),
              cm.customer_id,
               CAST(MULTISET(
			SELECT HZ_ORIG_SYS_REF_OBJ(
				NULL,
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
				ATTRIBUTE20
				)
			FROM HZ_ORIG_SYS_REFERENCES
			WHERE OWNER_TABLE_ID = 	cm.customer_id
			AND OWNER_TABLE_NAME =  'HZ_CUST_ACCOUNTS'
	     )AS HZ_ORIG_SYS_REF_OBJ_TBL)
             )
      FROM (SELECT distinct duplicate_address_id, customer_address_id,
                   duplicate_id, customer_id, org_id, customer_createsame
            FROM   ra_customer_merges cm
            WHERE customer_merge_header_id = p_customer_merge_header_id
	    AND   duplicate_id <> customer_id) cm;

   CURSOR get_site_use_details IS

       SELECT HZ_ACCOUNT_MERGE_DETAIL_OBJ(
              get_object_type('HZ_CUST_SITE_USES', cm.duplicate_site_id),
              decode(cm.customer_createsame, 'N', 'Merge', 'Y', 'Transfer'),
	      cm.org_id,
	      get_operating_unit(cm.org_id),
              cm.duplicate_site_id,
               CAST(MULTISET(
			SELECT HZ_ORIG_SYS_REF_OBJ(
				NULL,
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
				ATTRIBUTE20
				)
			FROM HZ_ORIG_SYS_REFERENCES
			WHERE OWNER_TABLE_ID = 	cm.duplicate_site_id
			AND OWNER_TABLE_NAME =  'HZ_CUST_SITE_USES_ALL'
	     )AS HZ_ORIG_SYS_REF_OBJ_TBL),
              cm.customer_site_id,
               CAST(MULTISET(
			SELECT HZ_ORIG_SYS_REF_OBJ(
				NULL,
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
				ATTRIBUTE20
				)
			FROM HZ_ORIG_SYS_REFERENCES
			WHERE OWNER_TABLE_ID = 	cm.customer_site_id
			AND OWNER_TABLE_NAME =  'HZ_CUST_SITE_USES_ALL'
	     )AS HZ_ORIG_SYS_REF_OBJ_TBL),
              cm.duplicate_address_id,
	       CAST(MULTISET(
			SELECT HZ_ORIG_SYS_REF_OBJ(
				NULL,
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
				ATTRIBUTE20
				)
			FROM HZ_ORIG_SYS_REFERENCES
			WHERE OWNER_TABLE_ID = 	cm.duplicate_address_id
			AND OWNER_TABLE_NAME =  'HZ_CUST_ACCT_SITES_ALL'
	     )AS HZ_ORIG_SYS_REF_OBJ_TBL),
              cm.customer_address_id,
	       CAST(MULTISET(
			SELECT HZ_ORIG_SYS_REF_OBJ(
				NULL,
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
				ATTRIBUTE20
				)
			FROM HZ_ORIG_SYS_REFERENCES
			WHERE OWNER_TABLE_ID = 	cm.customer_address_id
			AND OWNER_TABLE_NAME =  'HZ_CUST_ACCT_SITES_ALL'
	     )AS HZ_ORIG_SYS_REF_OBJ_TBL)
              )
       FROM ra_customer_merges cm
       WHERE customer_merge_header_id = p_customer_merge_header_id;

   CURSOR get_customer_profiles IS

       SELECT HZ_ACCOUNT_MERGE_DETAIL_OBJ(
              get_object_type('HZ_CUSTOMER_PROFILES', from_profile_id),
              operation,
	      NULL,
	      NULL,
              from_profile_id,
              HZ_ORIG_SYS_REF_OBJ_TBL(),
              to_profile_id,
	      HZ_ORIG_SYS_REF_OBJ_TBL(),
              from_parent_id,
              HZ_ORIG_SYS_REF_OBJ_TBL(),
              to_parent_id,
              HZ_ORIG_SYS_REF_OBJ_TBL()
              )
       FROM (SELECT 'Merge' operation, cpf.cust_account_profile_id from_profile_id,
                    cpt.cust_account_profile_id to_profile_id,
		    cmh.duplicate_id from_parent_id, cmh.customer_id to_parent_id
             FROM  ra_customer_merge_headers cmh, hz_customer_profiles_m cpf, hz_customer_profiles cpt
	     WHERE cmh.customer_merge_header_id = p_customer_merge_header_id
	     AND   cmh.duplicate_id <> cmh.customer_id
	     AND   cpf.cust_account_id = cmh.duplicate_id
	     AND   cpf.customer_merge_header_id = p_customer_merge_header_id
       	     AND   cpt.cust_account_id = cmh.customer_id
             AND   cpf.site_use_id IS NULL
             AND   cpt.site_use_id IS NULL

             UNION

	     SELECT decode(cm.customer_createsame, 'N', 'Merge', 'Y', 'Transfer') operation,
	             cpf.cust_account_profile_id from_profile_id,
                     cpt.cust_account_profile_id to_profile_id,
	             cm.duplicate_site_id from_parent_id,
	             cm.customer_site_id to_parent_id
             FROM ra_customer_merges cm, hz_customer_profiles_m cpf, hz_customer_profiles cpt
       	     WHERE cm.customer_merge_header_id = p_customer_merge_header_id
	     AND   cpf.customer_merge_header_id = p_customer_merge_header_id
             AND   cpf.cust_account_id = cm.duplicate_id
             AND   cpf.site_use_id = cm.duplicate_site_id
             AND   cpt.cust_account_id = cm.customer_id
             AND   cpt.site_use_id = cm.customer_site_id);

       CURSOR get_cust_profile_amts IS

       SELECT HZ_ACCOUNT_MERGE_DETAIL_OBJ(
              get_object_type('HZ_CUST_PROFILE_AMTS', from_profile_amt_id),
              operation,
	      NULL,
	      NULL,
              from_profile_amt_id,
              HZ_ORIG_SYS_REF_OBJ_TBL(),
              to_profile_amt_id,
	      HZ_ORIG_SYS_REF_OBJ_TBL(),
              from_parent_id,
              HZ_ORIG_SYS_REF_OBJ_TBL(),
              to_parent_id,
              HZ_ORIG_SYS_REF_OBJ_TBL()
              )
       FROM (SELECT 'Merge' operation, cpaf.cust_acct_profile_amt_id from_profile_amt_id,
                    cpat.cust_acct_profile_amt_id to_profile_amt_id,
		    cmh.duplicate_id from_parent_id, cmh.customer_id to_parent_id
             FROM  ra_customer_merge_headers cmh, hz_cust_profile_amts_m cpaf, hz_cust_profile_amts cpat
	     WHERE cmh.customer_merge_header_id = p_customer_merge_header_id
	     AND   cmh.duplicate_id <> cmh.customer_id
	     AND   cpaf.customer_merge_header_id = p_customer_merge_header_id
       	     AND   cpaf.cust_account_id = cmh.duplicate_id
       	     AND   cpat.cust_account_id = cmh.customer_id
	     AND   cpaf.currency_code = cpat.currency_code
             AND   cpaf.site_use_id IS NULL
             AND   cpat.site_use_id IS NULL

             UNION

	     SELECT  decode(cm.customer_createsame, 'N', 'Merge', 'Y', 'Transfer') operation,
	             cpaf.cust_acct_profile_amt_id from_profile_amt_id,
                     cpat.cust_acct_profile_amt_id to_profile_amt_id,
             	     cm.duplicate_site_id from_parent_id,
		     cm.customer_site_id to_parent_id
             FROM ra_customer_merges cm, hz_cust_profile_amts_m cpaf, hz_cust_profile_amts cpat
	     WHERE cm.customer_merge_header_id = p_customer_merge_header_id
	     AND   cpaf.customer_merge_header_id = p_customer_merge_header_id
	     AND   cpaf.cust_account_id = cm.duplicate_id
	     AND   cpaf.site_use_id = cm.duplicate_site_id
	     AND   cpat.cust_account_id = cm.customer_id
	     AND   cpat.site_use_id = cm.customer_site_id
	     AND   cpaf.currency_code = cpat.currency_code);

    CURSOR get_account_roles IS
       SELECT HZ_ACCOUNT_MERGE_DETAIL_OBJ(
              get_object_type('HZ_CUST_ACCOUNT_ROLES',from_role_id),
	      operation,
	      NULL,
	      NULL,
	      from_role_id,
	      HZ_ORIG_SYS_REF_OBJ_TBL(),
	      to_role_id,
	      HZ_ORIG_SYS_REF_OBJ_TBL(),
	      from_parent_id,
	      HZ_ORIG_SYS_REF_OBJ_TBL(),
	      to_parent_id,
	      HZ_ORIG_SYS_REF_OBJ_TBL()
	      )
	FROM (SELECT DISTINCT carf.cust_account_role_id from_role_id,
		     carf.cust_account_role_id to_role_id,
		     Nvl(carf.cust_acct_site_id,cm.duplicate_id) from_parent_id,
		     Decode(carf.cust_acct_site_id, NULL,cm.customer_id,cm.customer_address_id) to_parent_id, 'Transfer' operation
              FROM (SELECT DISTINCT duplicate_id, duplicate_address_id, customer_address_id, customer_id
              FROM ra_customer_merges cm
              WHERE cm.customer_merge_header_id = p_customer_merge_header_id
              AND cm.duplicate_id <> cm.customer_id) cm, hz_cust_account_roles_m carf
              WHERE carf.customer_merge_header_id = p_customer_merge_header_id
              AND  ((carf.cust_account_id = cm.duplicate_id AND carf.cust_acct_site_id = cm.duplicate_address_id)
		    OR (carf.cust_account_id = cm.duplicate_id AND   carf.cust_acct_site_id IS NULL))
	      AND  NOT EXISTS (SELECT 'Y'
	                       FROM hz_cust_account_roles
		               WHERE cust_account_role_id = carf.cust_account_role_id
		               AND   cust_account_id = cm.duplicate_id));

       CURSOR get_acct_rels(duplicate_id number, customer_id number) IS
	SELECT HZ_ACCOUNT_MERGE_DETAIL_OBJ(
              get_object_type('HZ_CUST_ACCT_RELATE_ALL',crelf.cust_acct_relate_id),
	      decode(crelt.created_by_module,'HZ_TCA_CUSTOMER_MERGE','Transfer','Merge'),
	      crelt.org_id,
	      get_operating_unit(crelt.org_id),
	      crelf.cust_acct_relate_id,
	      HZ_ORIG_SYS_REF_OBJ_TBL(),
	      crelt.cust_acct_relate_id,
	      HZ_ORIG_SYS_REF_OBJ_TBL(),
	      duplicate_id,
	       CAST(MULTISET(
			SELECT HZ_ORIG_SYS_REF_OBJ(
				NULL,
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
				ATTRIBUTE20
				)
			FROM HZ_ORIG_SYS_REFERENCES
			WHERE OWNER_TABLE_ID = 	duplicate_id
			AND OWNER_TABLE_NAME =  'HZ_CUST_ACCOUNTS'
	     )AS HZ_ORIG_SYS_REF_OBJ_TBL),
	      customer_id,
	       CAST(MULTISET(
			SELECT HZ_ORIG_SYS_REF_OBJ(
				NULL,
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
				ATTRIBUTE20
				)
			FROM HZ_ORIG_SYS_REFERENCES
			WHERE OWNER_TABLE_ID = 	customer_id
			AND OWNER_TABLE_NAME =  'HZ_CUST_ACCOUNTS'
	     )AS HZ_ORIG_SYS_REF_OBJ_TBL)
	      )
	FROM hz_cust_acct_relate_all_m crelf, hz_cust_acct_relate_all crelt
        WHERE ((crelf.cust_account_id = duplicate_id
		AND   crelt.cust_account_id = customer_id
		AND   crelt.related_cust_account_id = crelf.related_cust_account_id)
 	OR
	      (crelf.related_cust_account_id = duplicate_id
		AND   crelt.related_cust_account_id = customer_id
		AND   crelt.cust_account_id = crelf.cust_account_id))
	AND crelt.org_id IN (SELECT org_id FROM ra_customer_merges
	                     WHERE customer_merge_header_id = p_customer_merge_header_id)
	AND crelf.org_id = crelt.org_id;

l_site_use_id NUMBER;
l_header_id NUMBER;
BEGIN

-- initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'get_account_merge_event_data(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

	IF p_get_merge_detail_flag NOT IN ('Y','N') THEN
		FND_MESSAGE.SET_NAME('AR','HZ_API_VAL_DEP_FIELDS');
		FND_MESSAGE.SET_TOKEN('COLUMN1','getMergeDetailFlag');
		FND_MESSAGE.SET_TOKEN('VALUE1',p_get_merge_detail_flag);
		FND_MESSAGE.SET_TOKEN('COLUMN2','getMergeDetailFlag');
		FND_MESSAGE.SET_TOKEN('VALUE2','Y/N');
		FND_MSG_PUB.ADD();
		RAISE fnd_api.g_exc_error;
	END IF;

	BEGIN
	   SELECT customer_merge_header_id INTO l_header_id
	   FROM ra_customer_merge_headers
	   WHERE customer_merge_header_id = p_customer_merge_header_id;
        EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_TCA_ID');
		FND_MSG_PUB.ADD();
		RAISE fnd_api.g_exc_error;
	END;

	OPEN account_merge_details;
        FETCH account_merge_details  into x_account_merge_v2_obj;
        CLOSE account_merge_details;
	        	    -- SSM for merge-to acct party obj
        HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_owner_table_id => x_account_merge_v2_obj.merge_to_acct_party_obj.party_id,
	         p_owner_table_name => 'HZ_PARTIES',
		 p_action_type => NULL,
		 x_orig_sys_ref_objs => x_account_merge_v2_obj.merge_to_acct_party_obj.orig_sys_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
        END IF;

                    -- SSM for merge-from acct party obj
        HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                (p_init_msg_list => fnd_api.g_false,
                 p_owner_table_id => x_account_merge_v2_obj.merge_from_acct_party_obj.party_id,
                 p_owner_table_name => 'HZ_PARTIES',
                 p_action_type => NULL,
                 x_orig_sys_ref_objs => x_account_merge_v2_obj.merge_from_acct_party_obj.orig_sys_objs,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
       END IF;
                   -- SSM for merge to account obj
       HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                (p_init_msg_list => fnd_api.g_false,
                 p_owner_table_id => x_account_merge_v2_obj.merge_to_account_obj.cust_acct_id,
                 p_owner_table_name => 'HZ_CUST_ACCOUNTS',
                 p_action_type => NULL,
                 x_orig_sys_ref_objs => x_account_merge_v2_obj.merge_to_account_obj.orig_sys_objs,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
       END IF;

        FOR I in 1..x_account_merge_v2_obj.merge_from_account_objs.count LOOP

                HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                (p_init_msg_list => fnd_api.g_false,
                 p_owner_table_id => x_account_merge_v2_obj.merge_from_account_objs(I).cust_acct_id,
                 p_owner_table_name => 'HZ_CUST_ACCOUNTS',
                 p_action_type => NULL,
                 x_orig_sys_ref_objs => x_account_merge_v2_obj.merge_from_account_objs(I).orig_sys_objs,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        END LOOP;

	IF p_get_merge_detail_flag = 'N' THEN
	   Return;
	END IF;

       OPEN get_site_details;
       FETCH get_site_details BULK COLLECT INTO x_account_merge_v2_obj.acct_site_objs;
       CLOSE get_site_details;

       OPEN get_site_use_details;
       FETCH get_site_use_details BULK COLLECT INTO x_account_merge_v2_obj.acct_site_uses_objs;
       CLOSE get_site_use_details;


       OPEN get_customer_profiles;
       FETCH get_customer_profiles BULK COLLECT INTO x_account_merge_v2_obj.customer_profile_objs;
       CLOSE get_customer_profiles;

       FOR I IN 1..x_account_merge_v2_obj.customer_profile_objs.count LOOP
              l_site_use_id := null;
              SELECT site_use_id INTO l_site_use_id
	      FROM hz_customer_profiles_m
	      WHERE cust_account_profile_id = x_account_merge_v2_obj.customer_profile_objs(I).from_object_id;

	      IF l_site_use_id IS NOT NULL THEN

		    HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                    (p_init_msg_list => fnd_api.g_false,
                     p_owner_table_id => x_account_merge_v2_obj.customer_profile_objs(I).from_parent_object_id,
                     p_owner_table_name => 'HZ_CUST_SITE_USES_ALL',
                     p_action_type => NULL,
                     x_orig_sys_ref_objs => x_account_merge_v2_obj.customer_profile_objs(I).from_parent_obj_sys_ref_objs,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

		     HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                     (p_init_msg_list => fnd_api.g_false,
                     p_owner_table_id => x_account_merge_v2_obj.customer_profile_objs(I).to_parent_object_id,
                     p_owner_table_name => 'HZ_CUST_SITE_USES_ALL',
                     p_action_type => NULL,
                     x_orig_sys_ref_objs => x_account_merge_v2_obj.customer_profile_objs(I).to_parent_obj_sys_ref_objs,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

		ELSE
		     HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                     (p_init_msg_list => fnd_api.g_false,
                     p_owner_table_id => x_account_merge_v2_obj.customer_profile_objs(I).from_parent_object_id,
                     p_owner_table_name => 'HZ_CUST_ACCOUNTS',
                     p_action_type => NULL,
                     x_orig_sys_ref_objs => x_account_merge_v2_obj.customer_profile_objs(I).from_parent_obj_sys_ref_objs,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

		     HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                     (p_init_msg_list => fnd_api.g_false,
                     p_owner_table_id => x_account_merge_v2_obj.customer_profile_objs(I).to_parent_object_id,
                     p_owner_table_name => 'HZ_CUST_ACCOUNTS',
                     p_action_type => NULL,
                     x_orig_sys_ref_objs => x_account_merge_v2_obj.customer_profile_objs(I).to_parent_obj_sys_ref_objs,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

		END IF; --l_site_use_id
	END LOOP; --customer_profiles


       OPEN get_cust_profile_amts;
       FETCH get_cust_profile_amts BULK COLLECT INTO x_account_merge_v2_obj.cust_profile_amt_objs;
       CLOSE get_cust_profile_amts;

       FOR I IN 1..x_account_merge_v2_obj.cust_profile_amt_objs.count LOOP
              l_site_use_id := null;
              SELECT site_use_id INTO l_site_use_id
	      FROM hz_cust_profile_amts_m
	      WHERE cust_acct_profile_amt_id = x_account_merge_v2_obj.cust_profile_amt_objs(I).from_object_id;

	      IF l_site_use_id IS NOT NULL THEN

		    HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                    (p_init_msg_list => fnd_api.g_false,
                     p_owner_table_id => x_account_merge_v2_obj.cust_profile_amt_objs(I).from_parent_object_id,
                     p_owner_table_name => 'HZ_CUST_SITE_USES_ALL',
                     p_action_type => NULL,
                     x_orig_sys_ref_objs => x_account_merge_v2_obj.cust_profile_amt_objs(I).from_parent_obj_sys_ref_objs,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

		     HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                     (p_init_msg_list => fnd_api.g_false,
                     p_owner_table_id => x_account_merge_v2_obj.cust_profile_amt_objs(I).to_parent_object_id,
                     p_owner_table_name => 'HZ_CUST_SITE_USES_ALL',
                     p_action_type => NULL,
                     x_orig_sys_ref_objs => x_account_merge_v2_obj.cust_profile_amt_objs(I).to_parent_obj_sys_ref_objs,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

		ELSE
		     HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                     (p_init_msg_list => fnd_api.g_false,
                     p_owner_table_id => x_account_merge_v2_obj.cust_profile_amt_objs(I).from_parent_object_id,
                     p_owner_table_name => 'HZ_CUST_ACCOUNTS',
                     p_action_type => NULL,
                     x_orig_sys_ref_objs => x_account_merge_v2_obj.cust_profile_amt_objs(I).from_parent_obj_sys_ref_objs,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

		     HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                     (p_init_msg_list => fnd_api.g_false,
                     p_owner_table_id => x_account_merge_v2_obj.cust_profile_amt_objs(I).to_parent_object_id,
                     p_owner_table_name => 'HZ_CUST_ACCOUNTS',
                     p_action_type => NULL,
                     x_orig_sys_ref_objs => x_account_merge_v2_obj.cust_profile_amt_objs(I).to_parent_obj_sys_ref_objs,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

		END IF; --l_site_use_id
	END LOOP; --customer_profile_amts

       OPEN get_account_roles;
       FETCH get_account_roles BULK COLLECT INTO x_account_merge_v2_obj.acct_role_objs;
       CLOSE get_account_roles;

       FOR I in 1..x_account_merge_v2_obj.acct_role_objs.count LOOP

                HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                (p_init_msg_list => fnd_api.g_false,
                 p_owner_table_id => x_account_merge_v2_obj.acct_role_objs(I).from_object_id,
                 p_owner_table_name => 'HZ_CUST_ACCOUNT_ROLES',
                 p_action_type => NULL,
                 x_orig_sys_ref_objs => x_account_merge_v2_obj.acct_role_objs(I).from_object_sys_ref_objs,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

		HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                (p_init_msg_list => fnd_api.g_false,
                 p_owner_table_id => x_account_merge_v2_obj.acct_role_objs(I).to_object_id,
                 p_owner_table_name => 'HZ_CUST_ACCOUNT_ROLES',
                 p_action_type => NULL,
                 x_orig_sys_ref_objs => x_account_merge_v2_obj.acct_role_objs(I).to_object_sys_ref_objs,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

		l_site_use_id := null;

		SELECT cust_acct_site_id INTO l_site_use_id
		FROM hz_cust_account_roles_m
		WHERE cust_account_role_id = x_account_merge_v2_obj.acct_role_objs(I).from_object_id;

		IF l_site_use_id IS NOT NULL THEN

		    HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                    (p_init_msg_list => fnd_api.g_false,
                     p_owner_table_id => x_account_merge_v2_obj.acct_role_objs(I).from_parent_object_id,
                     p_owner_table_name => 'HZ_CUST_ACCT_SITES_ALL',
                     p_action_type => NULL,
                     x_orig_sys_ref_objs => x_account_merge_v2_obj.acct_role_objs(I).from_parent_obj_sys_ref_objs,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

		     HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                     (p_init_msg_list => fnd_api.g_false,
                     p_owner_table_id => x_account_merge_v2_obj.acct_role_objs(I).to_parent_object_id,
                     p_owner_table_name => 'HZ_CUST_ACCT_SITES_ALL',
                     p_action_type => NULL,
                     x_orig_sys_ref_objs => x_account_merge_v2_obj.acct_role_objs(I).to_parent_obj_sys_ref_objs,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

		ELSE
		     HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                     (p_init_msg_list => fnd_api.g_false,
                     p_owner_table_id => x_account_merge_v2_obj.acct_role_objs(I).from_parent_object_id,
                     p_owner_table_name => 'HZ_CUST_ACCOUNTS',
                     p_action_type => NULL,
                     x_orig_sys_ref_objs => x_account_merge_v2_obj.acct_role_objs(I).from_parent_obj_sys_ref_objs,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

		     HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                     (p_init_msg_list => fnd_api.g_false,
                     p_owner_table_id => x_account_merge_v2_obj.acct_role_objs(I).to_parent_object_id,
                     p_owner_table_name => 'HZ_CUST_ACCOUNTS',
                     p_action_type => NULL,
                     x_orig_sys_ref_objs => x_account_merge_v2_obj.acct_role_objs(I).to_parent_obj_sys_ref_objs,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data);

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

		END IF; --l_site_use_id
        END LOOP; --cust_account_roles

	OPEN get_acct_rels(x_account_merge_v2_obj.merge_from_account_objs(1).cust_acct_id,
			   x_account_merge_v2_obj.merge_to_account_obj.cust_acct_id);
	FETCH get_acct_rels BULK COLLECT INTO x_account_merge_v2_obj.acct_rel_objs;
	CLOSE get_acct_rels;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_account_merge_event_data(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_account_merge_event_data(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_account_merge_event_data(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_account_merge_event_data(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

  END get_account_merge_event_data;

 --------------------------------------
  --
  -- PROCEDURE get_party_merge_event_data
  --
  -- DESCRIPTION
  --     Get party merge details.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN: p_init_msg_list
  --       p_batch_id
  --       p_merge_to_party_id
  --   OUT:x_party_merge_obj
  --       x_return_status
  --       x_msg_count
  --       x_msg_data
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --
  --   25-AUG-2005   S V Sowjanya                Created.

PROCEDURE get_party_merge_event_data(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_batch_id            IN           	NUMBER,
    p_merge_to_party_id   IN		NUMBER,
    p_get_merge_detail_flag IN          VARCHAR2 := 'N',  --5093366
    x_party_merge_obj     OUT NOCOPY    HZ_PARTY_MERGE_OBJ,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) IS

l_debug_prefix              VARCHAR2(30) := '';
l_merge_to_party_id         NUMBER;
l_batch_id                  NUMBER;
l_merge_status		    VARCHAR2(30);
CURSOR  party_merge_details IS
	SELECT  HZ_PARTY_MERGE_OBJ(
		mb.batch_id,
		mb.batch_name,
		mp.merge_type,
		db.automerge_flag,
		mb.created_by,
		mb.creation_date,
		mb.last_update_login,
		mb.last_update_date,
		mb.last_updated_by,
		HZ_PARTY_ORIG_SYS_REF_OBJ(
			tp.party_id,
			tp.party_number,
			tp.party_name,
			tp.party_type,
			HZ_ORIG_SYS_REF_OBJ_TBL()),
		CAST(MULTISET(
			SELECT HZ_PARTY_ORIG_SYS_REF_OBJ(
					fp.party_id,
					fp.party_number,
					fp.party_name,
					fp.party_type,
					HZ_ORIG_SYS_REF_OBJ_TBL())
			FROM hz_parties fp, hz_merge_parties mp1
			WHERE mp1.batch_id = p_batch_id
			AND   mp1.to_party_id = l_merge_to_party_id
			AND   fp.party_id = mp1.from_party_id
		        AND   mp1.merge_type = mp.merge_type
			) AS HZ_PARTY_ORIG_SYS_REF_OBJ_TBL),
	       HZ_PARTY_MERGE_DETAIL_OBJ_TBL()             --5093366
	)
	FROM hz_merge_batch mb,
             (SELECT DISTINCT merge_type from hz_merge_parties where batch_id = p_batch_id and to_party_id = l_merge_to_party_id) mp,
             hz_dup_batch db,
	     hz_dup_sets dset,
	     hz_parties tp
	WHERE mb.batch_id = p_batch_id
	AND   tp.party_id = l_merge_to_party_id
	AND   mb.batch_id = dset.dup_set_id (+)
        AND   db.dup_batch_id (+)= dset.dup_batch_id
        ORDER BY mp.merge_type;
--5093366
CURSOR  party_merge_details1 IS
		       SELECT HZ_PARTY_MERGE_DETAIL_OBJ(
				get_object_type(md.entity_name, mph.from_entity_id),
		                mph.operation_type,
				mph.from_entity_id,
				CAST(MULTISET(
					SELECT HZ_ORIG_SYS_REF_OBJ(
						NULL,
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
						ATTRIBUTE20
					)
					FROM HZ_ORIG_SYS_REFERENCES
					WHERE OWNER_TABLE_ID = mph.from_entity_id
					AND OWNER_TABLE_NAME = md.entity_name

				     )AS HZ_ORIG_SYS_REF_OBJ_TBL),

				mph.to_entity_id,

			        CAST(MULTISET(
					SELECT HZ_ORIG_SYS_REF_OBJ(
						NULL,
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
						ATTRIBUTE20
					)
					FROM HZ_ORIG_SYS_REFERENCES
					WHERE OWNER_TABLE_ID = decode(mph.operation_type,'Copy',mph.from_entity_id,mph.to_entity_id)
					AND OWNER_TABLE_NAME = md.entity_name

				     )AS HZ_ORIG_SYS_REF_OBJ_TBL),

				mph.from_parent_entity_id,

				CAST(MULTISET(
					SELECT HZ_ORIG_SYS_REF_OBJ(
						NULL,
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
						ATTRIBUTE20
					)
					FROM HZ_ORIG_SYS_REFERENCES
					WHERE OWNER_TABLE_ID = 	mph.from_parent_entity_id
					AND OWNER_TABLE_NAME =  md.parent_entity_name

				     )AS HZ_ORIG_SYS_REF_OBJ_TBL),

				mph.to_parent_entity_id,


				CAST(MULTISET(
					SELECT HZ_ORIG_SYS_REF_OBJ(
						NULL,
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
						ATTRIBUTE20
					)
					FROM HZ_ORIG_SYS_REFERENCES
					WHERE OWNER_TABLE_ID = 	mph.to_parent_entity_id
					AND OWNER_TABLE_NAME =  md.parent_entity_name

				     )AS HZ_ORIG_SYS_REF_OBJ_TBL)

				)
		       FROM hz_merge_parties mp2,
			    hz_merge_party_history mph,
			    hz_merge_dictionary md
		       WHERE mp2.batch_id = p_batch_id
		       AND mp2.to_party_id = l_merge_to_party_id
		       AND mph.batch_party_id = mp2.batch_party_id
		       AND md.merge_dict_id = mph.merge_dict_id
		       AND md.dict_application_id = 222
		       and md.entity_name like 'HZ%';

BEGIN
      -- initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
               hz_utility_v2pub.debug(p_message=>'get_party_merge_event_data(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

	IF p_get_merge_detail_flag NOT IN ('Y','N') THEN
		FND_MESSAGE.SET_NAME('AR','HZ_API_VAL_DEP_FIELDS');
		FND_MESSAGE.SET_TOKEN('COLUMN1','getMergeDetailFlag');
		FND_MESSAGE.SET_TOKEN('VALUE1',p_get_merge_detail_flag);
		FND_MESSAGE.SET_TOKEN('COLUMN2','getMergeDetailFlag');
		FND_MESSAGE.SET_TOKEN('VALUE2','Y/N');
		FND_MSG_PUB.ADD();
		RAISE fnd_api.g_exc_error;
	END IF;

	BEGIN
	   SELECT batch_id, batch_status  INTO l_batch_id, l_merge_status
	   FROM hz_merge_batch
	   WHERE batch_id = p_batch_id;
        EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		FND_MESSAGE.SET_NAME('AR','HZ_INVALID_DUP_BATCH');
		FND_MSG_PUB.ADD();
		RAISE fnd_api.g_exc_error;
	END;
	IF p_merge_to_party_id IS NOT NULL THEN
            BEGIN
             SELECT to_party_id INTO l_merge_to_party_id
	     FROM hz_merge_parties
	     WHERE batch_id = p_batch_id
	     AND to_party_id = p_merge_to_party_id
	     AND rownum = 1;
            EXCEPTION
		WHEN NO_DATA_FOUND THEN
		   FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_TCA_ID');
	           FND_MSG_PUB.ADD();
		   RAISE fnd_api.g_exc_error;
	    END;
        ELSE
	    SELECT to_party_id INTO l_merge_to_party_id
	    FROM hz_merge_parties
	    WHERE batch_id = p_batch_id
	    AND NVL(merge_reason_code , 'DEDUPE') <> 'DUPLICATE_RELN_PARTY'
	    AND   rownum = 1;
	END IF;

	IF l_merge_status <> 'COMPLETE' THEN
     	    FND_MESSAGE.SET_NAME('AR','HZ_CANNOT_SUBMIT_PROCESSING');
	    FND_MSG_PUB.ADD();
	    RAISE fnd_api.g_exc_error;
	END IF;

	open party_merge_details;
        fetch party_merge_details into x_party_merge_obj;
        close party_merge_details;
--5093366
        IF p_get_merge_detail_flag = 'Y' THEN
		open party_merge_details1;
	        fetch party_merge_details1 BULK COLLECT into x_party_merge_obj.merge_detail_objs;
        	close party_merge_details1;
	END IF;

                    -- SSM for party obj
        HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                (p_init_msg_list => fnd_api.g_false,
                 p_owner_table_id => x_party_merge_obj.merge_to_party_obj.party_id,
                 p_owner_table_name => 'HZ_PARTIES',
                 p_action_type => NULL,
                 x_orig_sys_ref_objs => x_party_merge_obj.merge_to_party_obj.orig_sys_objs,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
        END IF;

        FOR I in 1..x_party_merge_obj.merge_from_party_objs.count LOOP

		HZ_EXTRACT_ORIG_SYS_REF_BO_PVT.get_orig_sys_ref_bos
                (p_init_msg_list => fnd_api.g_false,
                 p_owner_table_id => x_party_merge_obj.merge_from_party_objs(I).party_id,
                 p_owner_table_name => 'HZ_PARTIES',
                 p_action_type => NULL,
                 x_orig_sys_ref_objs => x_party_merge_obj.merge_from_party_objs(I).orig_sys_objs,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      			RAISE FND_API.G_EXC_ERROR;
    		END IF;
 	END LOOP;


        -- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message=>'get_party_merge_event_data(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_party_merge_event_data(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_party_merge_event_data(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_party_merge_event_data(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
END get_party_merge_event_data;

END HZ_EXTRACT_MERGE_EVENT_PKG;

/
