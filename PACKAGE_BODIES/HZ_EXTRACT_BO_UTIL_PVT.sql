--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_BO_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_BO_UTIL_PVT" AS
/*$Header: ARHEUTVB.pls 120.11.12010000.2 2009/06/25 06:04:58 vsegu ship $ */
/*
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Contact Point
 * @rep:category BUSINESS_ENTITY
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf Oracle Trading Community Architecture Technical Implementation Guide
 */

procedure validate_event_id(p_event_id in number,
			    p_party_id in number,
  			    p_event_type in varchar2,
			    p_bo_code in varchar2,
			    x_return_status  out nocopy varchar2) is

	cursor c1 is
	 SELECT 'Y'
	 FROM HZ_BUS_OBJ_TRACKING
	 WHERE parent_bo_code is null
	 and event_id = p_event_id
	 and  child_entity_name = 'HZ_PARTIES'
	 and child_id  = nvl(p_party_id, child_id)
	 and child_bo_code = p_bo_code
	 and nvl(parent_event_flag, p_event_type) = p_event_type
	 and rownum = 1;

l_valid_flag varchar2(1);
begin
	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

	open c1;
	fetch c1 into l_valid_flag;
	close c1;

	if NVL(l_valid_flag, 'N') <> 'Y'
	then
		if p_party_id is null
	    	then
			FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_EVENT_ID');
			FND_MSG_PUB.ADD;
			x_return_status := FND_API.G_RET_STS_ERROR;
			RAISE FND_API.G_EXC_ERROR;
      		else
	    		FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_EVENT_OBJ_ID');
			FND_MSG_PUB.ADD;
			x_return_status := FND_API.G_RET_STS_ERROR;
			RAISE FND_API.G_EXC_ERROR;
		end if;
	end if;


end;

FUNCTION get_parent_object_type(
    p_parent_table_name           IN     VARCHAR2,
    p_parent_id             IN     NUMBER
 ) RETURN VARCHAR2 IS

  l_party_type varchar2(30) := null;

    cursor c1 is
	select party_type
	from hz_parties
	where party_id = p_parent_id;

     cursor c2 is
	select party_type
	from hz_parties p, hz_cust_accounts ca
	where p.party_id = ca.party_id
        and ca.cust_account_id = p_parent_id;

    cursor c_cp is
        select contact_point_type
        from HZ_CONTACT_POINTS
        where contact_point_id = p_parent_id;

  BEGIN
	if p_parent_table_name = 'HZ_PARTIES'
	then
		open c1;
		fetch c1 into l_party_type;
		close c1;
        elsif p_parent_table_name = 'HZ_CONTACT_POINTS'
        then
                open c_cp;
                fetch c_cp into l_party_type;
                close c_cp;
	elsif p_parent_table_name = 'HZ_CUST_ACCOUNTS'
	then
		open c2;
		fetch c2 into l_party_type;
		close c2;
	end if;

    -- Base on owner_table_name to return HZ_BUSINESS_OBJECTS lookup code
    IF(p_parent_table_name = 'HZ_PARTY_SITES') THEN
      RETURN 'PARTY_SITE';
    ELSIF(p_parent_table_name = 'HZ_PARTIES') THEN
      IF(l_party_type = 'ORGANIZATION') THEN
        RETURN 'ORG';
      ELSIF(l_party_type = 'PERSON') THEN
        RETURN 'PERSON';
      ELSIF(l_party_type = 'PARTY_RELATIONSHIP') THEN
        RETURN 'ORG_CONTACT';
      END IF;
    ELSIF(p_parent_table_name = 'HZ_CONTACT_POINTS') THEN
      RETURN l_party_type;
    ELSIF(p_parent_table_name = 'HZ_CUST_ACCOUNTS') THEN
      IF(l_party_type = 'ORGANIZATION') THEN
        RETURN 'ORG_CUST';
      ELSIF(l_party_type = 'PERSON') THEN
        RETURN 'PERSON_CUST';
      ELSIF(l_party_type IS NULL) THEN
        RETURN 'CUST_ACCT';
      END IF;
    ELSIF(p_parent_table_name = 'HZ_CUST_ACCOUNT_ROLES') THEN
      RETURN 'CUST_ACCT_CONTACT';
    ELSIF(p_parent_table_name = 'HZ_CUST_ACCT_SITES_ALL') THEN
      RETURN 'CUST_ACCT_SITE';
    END IF;
    RETURN NULL;
END get_parent_object_type;

FUNCTION get_user_name(p_user_id in number) return varchar2 is
	cursor get_user_name_csr is
		select user_name
		from fnd_user
		where user_id = p_user_id;

l_name varchar2(100);
begin
      IF G_RETURN_USER_NAME = 'Y' THEN
	open  get_user_name_csr;
	fetch  get_user_name_csr into l_name;
	close  get_user_name_csr;
	return l_name;
      ELSE
	return p_user_id;
      END IF;
end;


-- Central procedure for getting root event id.

procedure get_bo_root_ids(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_obj_root_ids        OUT NOCOPY    BO_ID_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
l_debug_prefix              VARCHAR2(30) := '';

cursor c1 is
	 SELECT child_id
	 FROM HZ_BUS_OBJ_TRACKING
	 WHERE parent_bo_code is null
	 and event_id = p_event_id
	 and  child_entity_name = 'HZ_PARTIES';

begin
	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'get_bo_root_ids(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


	open c1;
	fetch c1 bulk collect into x_obj_root_ids;
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
        	hz_utility_v2pub.debug(p_message=>'get_bo_root_ids (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_bo_root_ids(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_bo_root_ids(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_bo_root_ids(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

 FUNCTION is_ss_provided(
    p_os                  IN     VARCHAR2,
    p_osr                 IN     VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    IF((p_os is null or p_os = fnd_api.g_miss_char)
      and (p_osr is null or p_osr = fnd_api.g_miss_char))THEN
      RETURN 'N';
    ELSE
      RETURN 'Y';
    END IF;
  END is_ss_provided;

PROCEDURE validate_ssm_id(
    px_id                        IN OUT NOCOPY NUMBER,
    px_os                        IN OUT NOCOPY VARCHAR2,
    px_osr                       IN OUT NOCOPY VARCHAR2,
    p_org_id                     IN            NUMBER := NULL,
    p_obj_type                   IN            VARCHAR2,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2
  ) IS
    CURSOR is_cp_valid(l_cp_id NUMBER, l_cp_type VARCHAR2) IS
    SELECT 'X'
    FROM HZ_CONTACT_POINTS
    WHERE contact_point_id = l_cp_id
    AND contact_point_type = l_cp_type;

    CURSOR is_oc_valid(l_oc_id NUMBER) IS
    SELECT 'X'
    FROM HZ_ORG_CONTACTS
    WHERE org_contact_id = l_oc_id;

    CURSOR is_pty_valid(l_pty_id NUMBER, l_pty_type VARCHAR2) IS
    SELECT 'X'
    FROM HZ_PARTIES
    WHERE party_id = l_pty_id
    AND party_type = l_pty_type
    AND status in ('A', 'I');

    CURSOR is_ps_valid(l_ps_id NUMBER) IS
    SELECT 'X'
    FROM HZ_PARTY_SITES
    WHERE party_site_id = l_ps_id;

    CURSOR is_loc_valid(l_loc_id NUMBER) IS
    SELECT 'X'
    FROM HZ_LOCATIONS
    WHERE location_id = l_loc_id;

    CURSOR is_cr_valid(l_cr_id NUMBER) IS
    SELECT 'X'
    FROM HZ_CUST_ACCOUNT_ROLES
    WHERE cust_account_role_id = l_cr_id;

    CURSOR is_ca_valid(l_ca_id NUMBER) IS
    SELECT 'X'
    FROM HZ_CUST_ACCOUNTS
    WHERE cust_account_id = l_ca_id;

    CURSOR is_cas_valid(l_cas_id NUMBER, l_org_id NUMBER) IS
    SELECT 'X'
    FROM HZ_CUST_ACCT_SITES
    WHERE cust_acct_site_id = l_cas_id;

    CURSOR is_casu_valid(l_casu_id NUMBER, l_org_id NUMBER) IS
    SELECT 'X'
    FROM HZ_CUST_SITE_USES
    WHERE site_use_id = l_casu_id;

    l_owner_table_id            NUMBER;
    l_ss_flag                   VARCHAR2(1);
    l_debug_prefix              VARCHAR2(30);
    l_valid_id                  VARCHAR2(1);
    l_count                     NUMBER;
    l_org_id                    NUMBER;
    l_dummy                     VARCHAR2(1);
    l_obj_type                  VARCHAR2(30);
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_ssm_id(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_ss_flag := is_ss_provided(p_os  => px_os,
                                p_osr => px_osr);

    -- if px_id pass in, check if px_id is valid or not
    IF(px_id IS NOT NULL) THEN

      IF(p_obj_type in ('PHONE','TLX','EMAIL','WEB','EFT','EDI','SMS')) THEN
        OPEN is_cp_valid(px_id, p_obj_type);
        FETCH is_cp_valid INTO l_valid_id;
        CLOSE is_cp_valid;
      ELSIF(p_obj_type = 'HZ_ORG_CONTACTS') THEN
        OPEN is_oc_valid(px_id);
        FETCH is_oc_valid INTO l_valid_id;
        CLOSE is_oc_valid;
      ELSIF(p_obj_type in ('PERSON','ORGANIZATION','PARTY_RELATIONSHIP')) THEN
        OPEN is_pty_valid(px_id, p_obj_type);
        FETCH is_pty_valid INTO l_valid_id;
        CLOSE is_pty_valid;
      ELSIF(p_obj_type = 'HZ_CUST_ACCOUNT_ROLES') THEN
        OPEN is_cr_valid(px_id);
        FETCH is_cr_valid INTO l_valid_id;
        CLOSE is_cr_valid;
      ELSIF(p_obj_type = 'HZ_LOCATIONS') THEN
        OPEN is_loc_valid(px_id);
        FETCH is_loc_valid INTO l_valid_id;
        CLOSE is_loc_valid;
      ELSIF(p_obj_type = 'HZ_PARTY_SITES') THEN
        OPEN is_ps_valid(px_id);
        FETCH is_ps_valid INTO l_valid_id;
        CLOSE is_ps_valid;
      ELSIF(p_obj_type = 'HZ_CUST_ACCOUNTS') THEN
        OPEN is_ca_valid(px_id);
        FETCH is_ca_valid INTO l_valid_id;
        CLOSE is_ca_valid;
      ELSIF(p_obj_type = 'HZ_CUST_ACCT_SITES_ALL') THEN
        OPEN is_cas_valid(px_id, p_org_id);
        FETCH is_cas_valid INTO l_valid_id;
        CLOSE is_cas_valid;
      ELSIF(p_obj_type = 'HZ_CUST_SITE_USES_ALL') THEN
        OPEN is_casu_valid(px_id, p_org_id);
        FETCH is_casu_valid INTO l_valid_id;
        CLOSE is_casu_valid;
      END IF;
    END IF;


    -- if px_os/px_osr pass in, get owner_table_id and set l_ss_flag to 'Y'
    IF(l_ss_flag = 'Y')THEN
      IF(p_obj_type in ('PHONE','TLX','EMAIL','WEB','EFT','EDI','SMS')) THEN
        l_obj_type := 'HZ_CONTACT_POINTS';
      ELSIF(p_obj_type in ('PERSON','ORGANIZATION','PARTY_RELATIONSHIP')) THEN
        l_obj_type := 'HZ_PARTIES';
      ELSE
        l_obj_type := p_obj_type;
      END IF;


      -- Get how many rows return
      l_count := HZ_MOSR_VALIDATE_PKG.get_orig_system_ref_count(
                   p_orig_system           => px_os,
                   p_orig_system_reference => px_osr,
                   p_owner_table_name      => l_obj_type);

      IF(l_count = 1) THEN
        -- Get owner_table_id
        HZ_ORIG_SYSTEM_REF_PUB.get_owner_table_id(
          p_orig_system           => px_os,
          p_orig_system_reference => px_osr,
          p_owner_table_name      => l_obj_type,
          x_owner_table_id        => l_owner_table_id,
          x_return_status         => x_return_status);

        -- For contact point, check if the id and type is the same
        IF(p_obj_type in ('PHONE','TLX','EMAIL','WEB','EFT','EDI','SMS')) THEN
          OPEN is_cp_valid(l_owner_table_id, p_obj_type);
          FETCH is_cp_valid INTO l_dummy;
          CLOSE is_cp_valid;
          IF(l_dummy IS NULL) THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_TCA_ID');
            FND_MSG_PUB.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;
    END IF;

      -- if px_id pass in
      IF(px_id IS NOT NULL) THEN
        -- if px_id is invalid, raise error
        IF(l_valid_id IS NULL) THEN
          FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_TCA_ID');
          FND_MSG_PUB.ADD();
          RAISE fnd_api.g_exc_error;
        -- if px_id is valid
        ELSE
          -- check if px_os/px_osr is passed
          IF(l_ss_flag = 'Y') THEN
            IF(l_count = 0) THEN
              FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_SSM_ID');
              FND_MSG_PUB.ADD();
              RAISE fnd_api.g_exc_error;
            -- if px_os/px_osr is valid
            ELSE
              -- if px_os/px_osr is valid, but not same as px_id
              IF(l_owner_table_id <> px_id) OR (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_TCA_SSM_ID');
                FND_MSG_PUB.ADD();
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;
            -- if px_os/px_osr is valid and return value is same as px_id
            -- do nothing
          END IF;
        END IF;
      -- if px_id not pass in
      ELSE
        -- check if px_os/px_osr can find TCA identifier, owner_table_id
        -- if not found, raise error
        -- else, get owner_table_id and assign it to px_id
        IF(l_ss_flag = 'Y') AND (l_count = 1) AND (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          px_id := l_owner_table_id;
        ELSE
          FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_SSM_ID');
          FND_MSG_PUB.ADD();
          RAISE fnd_api.g_exc_error;
        END IF;
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
        hz_utility_v2pub.debug(p_message=>'validate_ssm_id(-)',
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
        hz_utility_v2pub.debug(p_message=>'validate_ssm_id(-)',
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
        hz_utility_v2pub.debug(p_message=>'validate_ssm_id(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END validate_ssm_id;


END HZ_EXTRACT_BO_UTIL_PVT;

/
