--------------------------------------------------------
--  DDL for Package Body HZ_REGISTRY_VALIDATE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_REGISTRY_VALIDATE_BO_PVT" AS
/*$Header: ARHBRGVB.pls 120.26.12010000.3 2009/06/25 22:11:35 awu ship $ */

-- PRIVATE PROCEDURE get_ps_from_rec
--
-- DESCRIPTION
--     Extract business object structure of party site.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_bus_object             Business object structure.
--   OUT:
--     x_bus_object             Business object structure of party site.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE get_ps_from_rec(
    p_bus_object              IN         COMPLETENESS_REC_TYPE,
    x_bus_object              OUT NOCOPY COMPLETENESS_REC_TYPE
  );

-- PRIVATE PROCEDURE get_cp_from_rec
--
-- DESCRIPTION
--     Extract business object structure of contact point.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_phone_code             'PHONE'.
--     p_email_code             'EMAIL'.
--     p_telex_code             'TLX'.
--     p_web_code               'WEB'.
--     p_edi_code               'EDI'.
--     p_eft_code               'EFT'.
--     p_sms_code               'SMS'.
--   OUT:
--     x_bus_object             Business object structure of contact point.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE get_cp_from_rec(
    p_phone_code              IN         VARCHAR2,
    p_email_code              IN         VARCHAR2,
    p_telex_code              IN         VARCHAR2,
    p_web_code                IN         VARCHAR2,
    p_edi_code                IN         VARCHAR2,
    p_eft_code                IN         VARCHAR2,
    p_sms_code                IN         VARCHAR2,
    p_bus_object              IN         COMPLETENESS_REC_TYPE,
    x_bus_object              OUT NOCOPY COMPLETENESS_REC_TYPE
  );

-- PRIVATE FUNCTION is_ss_provided
--
-- DESCRIPTION
--     Return a flag to indicate that original system and original system reference
--     are provided.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_os                     Original system.
--     p_osr                    Original system reference.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION is_ss_provided(
    p_os                      IN     VARCHAR2,
    p_osr                     IN     VARCHAR2
  ) RETURN VARCHAR2;

-- PROCEDURE validate_parent_id
--
-- DESCRIPTION
--     Validates parent id of business object.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     px_parent_id             Parent Id.
--     px_parent_os             Parent original system.
--     px_parent_osr            Parent original system reference.
--     p_person_obj_type        Parent object type.
--   OUT:
--     x_return_status          Return status after the call. The status can
--                              be FND_API.G_RET_STS_SUCCESS (success),
--                              FND_API.G_RET_STS_ERROR (error),
--                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
--     x_msg_count              Return total number of message.
--     x_msg_data               Return message content.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE validate_parent_id(
    px_parent_id                 IN OUT NOCOPY NUMBER,
    px_parent_os                 IN OUT NOCOPY VARCHAR2,
    px_parent_osr                IN OUT NOCOPY VARCHAR2,
    p_parent_obj_type            IN VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  ) IS
    CURSOR is_p_parent_valid(l_party_id NUMBER, l_party_type VARCHAR2) IS
    select 'Y'
    from HZ_PARTIES
    where party_id = l_party_id
    and party_type = l_party_type;

    CURSOR is_ps_parent_valid(l_party_site_id NUMBER) IS
    select 'Y'
    from HZ_PARTY_SITES
    where party_site_id = l_party_site_id;

    CURSOR is_acct_parent_valid(l_acct_id NUMBER) IS
    select 'Y'
    from HZ_CUST_ACCOUNTS
    where cust_account_id = l_acct_id;

    CURSOR is_acct_site_parent_valid(l_acct_site_id NUMBER) IS
    select 'Y'
    from HZ_CUST_ACCT_SITES_ALL
    where cust_acct_site_id = l_acct_site_id;

    l_party_type                VARCHAR2(30);
    l_valid_parent              VARCHAR2(1);
    l_owner_table_id            NUMBER;
    l_owner_table_name          VARCHAR2(30);
    l_parent_ss_flag            VARCHAR2(1);
    l_debug_prefix              VARCHAR2(30);
    l_count                     NUMBER;
  BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_parent_id(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_parent_ss_flag := is_ss_provided(p_os  => px_parent_os,
                                       p_osr => px_parent_osr);

    l_owner_table_name := get_owner_table_name(p_obj_type => p_parent_obj_type);

    -- if px_id pass in, check if px_id is valid or not
    l_valid_parent := 'N';

    -- if px_parent_id is not null, check if px_parent_id is valid or not
    IF(px_parent_id IS NOT NULL) THEN
      IF(l_owner_table_name = 'HZ_PARTIES') THEN
        IF(p_parent_obj_type = 'PERSON') THEN
          l_party_type := 'PERSON';
        ELSIF(p_parent_obj_type = 'ORG') THEN
          l_party_type := 'ORGANIZATION';
        ELSE
          l_party_type := 'PARTY_RELATIONSHIP';
        END IF;
        OPEN is_p_parent_valid(px_parent_id, l_party_type);
        FETCH is_p_parent_valid INTO l_valid_parent;
        CLOSE is_p_parent_valid;
      ELSIF(l_owner_table_name = 'HZ_PARTY_SITES') THEN
        OPEN is_ps_parent_valid(px_parent_id);
        FETCH is_ps_parent_valid INTO l_valid_parent;
        CLOSE is_ps_parent_valid;
      ELSIF(l_owner_table_name = 'HZ_CUST_ACCOUNTS') THEN
        OPEN is_acct_parent_valid(px_parent_id);
        FETCH is_acct_parent_valid INTO l_valid_parent;
        CLOSE is_acct_parent_valid;
      ELSIF(l_owner_table_name = 'HZ_CUST_ACCT_SITES_ALL') THEN
        OPEN is_acct_site_parent_valid(px_parent_id);
        FETCH is_acct_site_parent_valid INTO l_valid_parent;
        CLOSE is_acct_site_parent_valid;
      END IF;
      -- if px_parent_id is invalid, raise error
      IF(l_valid_parent = 'N') THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- if px_parent_os/px_parent_osr is not null, get owner_table_id and
    -- set local parent_ss_flag to 'Y'
    IF(l_parent_ss_flag = 'Y') THEN
      -- Get how many rows return
      l_count := HZ_MOSR_VALIDATE_PKG.get_orig_system_ref_count(
                   p_orig_system           => px_parent_os,
                   p_orig_system_reference => px_parent_osr,
                   p_owner_table_name      => l_owner_table_name);

      IF(l_count > 0) THEN
        -- Get owner_table_id
        HZ_ORIG_SYSTEM_REF_PUB.get_owner_table_id(
          p_orig_system           => px_parent_os,
          p_orig_system_reference => px_parent_osr,
          p_owner_table_name      => l_owner_table_name,
          x_owner_table_id        => l_owner_table_id,
          x_return_status         => x_return_status);
      END IF;
    END IF;

    -- if px_parent_id is passed in
    IF(px_parent_id IS NOT NULL) THEN
      -- check if px_parent_os/px_parent_osr is passed
      IF(l_parent_ss_flag = 'Y') THEN
        -- if px_parent_os/px_parent_osr is not valid, raise error
        IF(l_count = 0) OR (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE fnd_api.g_exc_error;
        END IF;
        -- if px_parent_os/px_parent_osr is valid, but not same as px_parent_id
        IF(l_owner_table_id <> px_parent_id) THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    -- if px_parent_id is not passed in
    ELSE
      -- check if px_parent_os/px_parent_osr can find TCA identifier, owner_table_id
      -- if not found, raise error
      -- else, get owner_table_id and assign it to px_parent_id
      IF(l_parent_ss_flag = 'Y') THEN
        IF(l_count = 0) OR (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE fnd_api.g_exc_error;
        ELSE
          px_parent_id := l_owner_table_id;
        END IF;
      ELSE
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      -- put error message "Error: Invalid Identifier";
      FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_PARENT_ID');
      FND_MSG_PUB.ADD();

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
        hz_utility_v2pub.debug(p_message=>'validate_parent_id(-)',
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
        hz_utility_v2pub.debug(p_message=>'validate_parent_id(-)',
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
        hz_utility_v2pub.debug(p_message=>'validate_parent_id(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END validate_parent_id;

-- PROCEDURE validate_ssm_id
--
-- DESCRIPTION
--     Validates Id, original system and original system reference of business object.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     px_id                    Id.
--     px_os                    Original system.
--     px_osr                   Original system reference.
--     p_org_id                 Org_Id for customer account site, customer account
--                              site use and customer account relationship.
--     p_obj_type               Business object type.
--     p_create_or_update       Flag to indicate create or update.
--   OUT:
--     x_return_status          Return status after the call. The status can
--                              be FND_API.G_RET_STS_SUCCESS (success),
--                              FND_API.G_RET_STS_ERROR (error),
--                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
--     x_msg_count              Return total number of message.
--     x_msg_data               Return message content.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE validate_ssm_id(
    px_id                        IN OUT NOCOPY NUMBER,
    px_os                        IN OUT NOCOPY VARCHAR2,
    px_osr                       IN OUT NOCOPY VARCHAR2,
    p_org_id                     IN            NUMBER := NULL,
    p_obj_type                   IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2,
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
    WHERE cust_acct_site_id = l_cas_id
    AND org_id = l_org_id;

    CURSOR is_casu_valid(l_casu_id NUMBER, l_org_id NUMBER) IS
    SELECT 'X'
    FROM HZ_CUST_SITE_USES
    WHERE site_use_id = l_casu_id
    AND org_id = l_org_id;

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

    -- check if os+osr are provided
    l_ss_flag := is_ss_provided(p_os  => px_os,
                                p_osr => px_osr);

    -- if px_id pass in, check if px_id is valid or not
    IF(px_id IS NOT NULL) THEN
      -- user must not pass TCA id when create, if passed in create,
      -- return error
      IF(p_create_or_update = 'C') THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_CANNOT_PASS_PK');
        FND_MSG_PUB.ADD();
        RAISE FND_API.G_EXC_ERROR;
      END IF;
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
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
            FND_MSG_PUB.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;
    END IF;

    -- for update
    IF(p_create_or_update = 'U') THEN
      -- if px_id pass in
      IF(px_id IS NOT NULL) THEN
        -- if px_id is invalid, raise error
        IF(l_valid_id IS NULL) THEN
          FND_MESSAGE.SET_NAME('AR','HZ_API_UPDATE_NOT_EXIST');
          FND_MSG_PUB.ADD();
          RAISE fnd_api.g_exc_error;
        -- if px_id is valid
        ELSE
          -- check if px_os/px_osr is passed
          IF(l_ss_flag = 'Y') THEN
            -- if px_os/px_osr is not valid, means that this is new os+osr
            -- we should not create ssm mapping, error out
            IF(l_count = 0) THEN
              FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_ID');
              FND_MSG_PUB.ADD();
              RAISE fnd_api.g_exc_error;
            -- if px_os/px_osr is valid
            ELSE
              -- if px_os/px_osr is valid, but not same as px_id
              IF(l_owner_table_id <> px_id) OR (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_ID');
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
          FND_MESSAGE.SET_NAME('AR','HZ_API_INVALID_ID');
          FND_MSG_PUB.ADD();
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    -- for create
    ELSIF(p_create_or_update = 'C') THEN
      -- if os+osr is valid, raise error
      IF(l_ss_flag = 'Y') AND (l_count > 0) AND (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_CREATE_ALREADY_EXISTS');
        FND_MSG_PUB.ADD();
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;  -- if p_create_or_update

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

-- PROCEDURE check_contact_pref_op
--
-- DESCRIPTION
--     Check the operation of contact preference based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_contact_level_table_id Contact level table Id.
--     p_contact_level_table    Contact level table.
--     p_contact_type           Contact preference type.
--     p_preference_code        Contact preference code.
--     p_preference_start_date  Contact preference start date.
--     p_preference_end_date    Contact preference end date.
--   IN/OUT:
--     px_contact_pref_id       Contact preference Id.
--   OUT:
--     x_object_version_number  Object version number of contact preference.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_contact_pref_op(
    p_contact_level_table_id     IN     NUMBER,
    p_contact_level_table        IN     VARCHAR2,
    px_contact_pref_id           IN OUT NOCOPY NUMBER,
    p_contact_type               IN     VARCHAR2,
    p_preference_code            IN     VARCHAR2,
    p_preference_start_date      IN     DATE,
    p_preference_end_date        IN     DATE,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_contact_pref_id_exist(l_contact_pref_id NUMBER)IS
    SELECT nvl(object_version_number,1), contact_level_table_id, contact_level_table
    FROM HZ_CONTACT_PREFERENCES
    WHERE contact_preference_id = l_contact_pref_id
    AND rownum = 1;

    CURSOR is_contact_pref_exist(l_contact_level_table_id NUMBER,
                                 l_contact_level_table VARCHAR2,
                                 l_contact_type VARCHAR2,
                                 l_preference_code  VARCHAR2, l_preference_start_date DATE,
                                 l_preference_end_date DATE)IS
    SELECT nvl(object_version_number,1), contact_preference_id
    FROM HZ_CONTACT_PREFERENCES
    WHERE contact_level_table_id = l_contact_level_table_id
    AND contact_level_table = l_contact_level_table
    AND contact_type = l_contact_type
  --  AND preference_code = l_preference_code
    AND trunc(preference_start_date) = trunc(l_preference_start_date)
    AND trunc(nvl(preference_end_date,sysdate)) = trunc(nvl(l_preference_end_date,sysdate))
    AND status in ('A','I')
    AND rownum = 1;

    l_clt_id     NUMBER;
    l_clt        VARCHAR2(30);
  BEGIN
    IF(px_contact_pref_id IS NULL) THEN
      OPEN is_contact_pref_exist(p_contact_level_table_id, p_contact_level_table,
                                 p_contact_type, p_preference_code,
                                 p_preference_start_date, p_preference_end_date);
      FETCH is_contact_pref_exist INTO x_object_version_number, px_contact_pref_id;
      CLOSE is_contact_pref_exist;
    ELSE
      OPEN is_contact_pref_id_exist(px_contact_pref_id);
      FETCH is_contact_pref_id_exist INTO x_object_version_number, l_clt_id, l_clt;
      CLOSE is_contact_pref_id_exist;
      IF((l_clt_id <> p_contact_level_table_id) OR (l_clt <> p_contact_level_table)) OR
         (l_clt_id IS NULL AND (p_contact_level_table_id IS NOT NULL OR p_contact_level_table IS NOT NULL)) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_contact_pref_op;

-- PROCEDURE check_language_op
--
-- DESCRIPTION
--     Check the operation of person language based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_language_name          Language name.
--   IN/OUT:
--     px_language_use_ref_id   Language use reference Id.
--   OUT:
--     x_object_version_number  Object version number of person language.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_language_op(
    p_party_id                   IN     NUMBER,
    px_language_use_ref_id       IN OUT NOCOPY NUMBER,
    p_language_name              IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_lang_id_exist(l_lang_id NUMBER)IS
    SELECT nvl(object_version_number,1), party_id
    FROM HZ_PERSON_LANGUAGE
    WHERE language_use_reference_id = l_lang_id
    AND rownum = 1;

    CURSOR is_language_exist(l_party_id NUMBER, l_language_name VARCHAR2)IS
    SELECT nvl(object_version_number,1), language_use_reference_id
    FROM HZ_PERSON_LANGUAGE
    WHERE party_id = l_party_id
    AND language_name = l_language_name
    AND status in ('A','I')
    AND rownum = 1;

    l_party_id     NUMBER;
  BEGIN
    IF(px_language_use_ref_id IS NULL) THEN
      OPEN is_language_exist(p_party_id, p_language_name);
      FETCH is_language_exist INTO x_object_version_number, px_language_use_ref_id;
      CLOSE is_language_exist;
    ELSE
      OPEN is_lang_id_exist(px_language_use_ref_id);
      FETCH is_lang_id_exist INTO x_object_version_number, l_party_id;
      CLOSE is_lang_id_exist;
      IF(l_party_id <> p_party_id) OR (l_party_id IS NULL AND p_party_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_language_op;

-- PROCEDURE check_education_op
--
-- DESCRIPTION
--     Check the operation of education based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_course_major           Course major.
--     p_school_attended_name   Name of attended school.
--     p_degree_received        Received degree.
--   IN/OUT:
--     px_education_id          Education Id.
--   OUT:
--     x_object_version_number  Object version number of education.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_education_op(
    p_party_id                   IN     NUMBER,
    px_education_id              IN OUT NOCOPY NUMBER,
    p_course_major               IN     VARCHAR2,
    p_school_attended_name       IN     VARCHAR2,
    p_degree_received            IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_edu_id_exist(l_edu_id NUMBER) IS
    SELECT nvl(object_version_number,1), party_id
    FROM HZ_EDUCATION
    WHERE education_id = l_edu_id
    AND rownum = 1;

    CURSOR is_education_exist(l_party_id NUMBER, l_course_major VARCHAR2,
                              l_school_attended_name VARCHAR2,
                              l_degree_received VARCHAR2)IS
    SELECT nvl(object_version_number,1), education_id
    FROM HZ_EDUCATION
    WHERE party_id = l_party_id
    AND UPPER(ltrim(rtrim(course_major))) = UPPER(ltrim(rtrim(l_course_major)))
    AND UPPER(ltrim(rtrim(degree_received))) = UPPER(ltrim(rtrim(l_degree_received)))
    AND UPPER(ltrim(rtrim(school_attended_name))) = UPPER(ltrim(rtrim(l_school_attended_name)))
    AND status in ('A','I')
    AND rownum = 1;

    l_party_id     NUMBER;
  BEGIN
    IF(px_education_id IS NULL) THEN
      OPEN is_education_exist(p_party_id, p_course_major, p_school_attended_name, p_degree_received);
      FETCH is_education_exist INTO x_object_version_number, px_education_id;
      CLOSE is_education_exist;
    ELSE
      OPEN is_edu_id_exist(px_education_id);
      FETCH is_edu_id_exist INTO x_object_version_number, l_party_id;
      CLOSE is_edu_id_exist;
      IF(l_party_id <> p_party_id) OR (l_party_id IS NULL AND p_party_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_education_op;

-- PROCEDURE check_citizenship_op
--
-- DESCRIPTION
--     Check the operation of citizenship based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_country_code           Country code.
--   IN/OUT:
--     px_citizenship_id        Citizenship Id.
--   OUT:
--     x_object_version_number  Object version number of citizenship.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_citizenship_op(
    p_party_id                   IN     NUMBER,
    px_citizenship_id            IN OUT NOCOPY NUMBER,
    p_country_code               IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_citizen_id_exist(l_citizen_id NUMBER)IS
    SELECT nvl(object_version_number,1), party_id
    FROM HZ_CITIZENSHIP
    WHERE citizenship_id = l_citizen_id
    AND rownum = 1;

    CURSOR is_citizenship_exist(l_party_id NUMBER, l_country_code VARCHAR2)IS
    SELECT nvl(object_version_number,1), citizenship_id
    FROM HZ_CITIZENSHIP
    WHERE party_id = l_party_id
    AND country_code = l_country_code
    AND status in ('A','I')
    AND rownum = 1;

    l_party_id        NUMBER;
  BEGIN
    IF(px_citizenship_id IS NULL) THEN
      OPEN is_citizenship_exist(p_party_id, p_country_code);
      FETCH is_citizenship_exist INTO x_object_version_number, px_citizenship_id;
      CLOSE is_citizenship_exist;
    ELSE
      OPEN is_citizen_id_exist(px_citizenship_id);
      FETCH is_citizen_id_exist INTO x_object_version_number, l_party_id;
      CLOSE is_citizen_id_exist;
      IF(l_party_id <> p_party_id) OR (l_party_id IS NULL AND p_party_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_citizenship_op;

-- PROCEDURE check_employ_hist_op
--
-- DESCRIPTION
--     Check the operation of employment history based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_employed_by_name_company   Name of company.
--     p_employed_as_title      Job title.
--     p_begin_date             Begin date.
--   IN/OUT:
--     px_emp_hist_id           Employment history Id.
--   OUT:
--     x_object_version_number  Object version number of employment history.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_employ_hist_op(
    p_party_id                   IN     NUMBER,
    px_emp_hist_id               IN OUT NOCOPY NUMBER,
    p_employed_by_name_company   IN     VARCHAR2,
    p_employed_as_title          IN     VARCHAR2,
    p_begin_date                 IN     DATE,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_employ_hist_id_exist(l_emp_hist_id NUMBER)IS
    SELECT nvl(object_version_number,1), party_id
    FROM HZ_EMPLOYMENT_HISTORY
    WHERE employment_history_id = l_emp_hist_id
    AND rownum = 1;

    CURSOR is_employ_hist_exist(l_party_id NUMBER, l_company VARCHAR2,
                                l_title VARCHAR2, l_begin_date  DATE)IS
    SELECT nvl(object_version_number,1), employment_history_id
    FROM HZ_EMPLOYMENT_HISTORY
    WHERE party_id = l_party_id
    AND nvl(UPPER(ltrim(rtrim(employed_by_name_company))),-99) = nvl(UPPER(ltrim(rtrim(l_company))),-99)
    AND nvl(UPPER(ltrim(rtrim(employed_as_title))),-99) = nvl(UPPER(ltrim(rtrim(l_title))), -99)
    AND nvl(trunc(begin_date),sysdate) = nvl(trunc(l_begin_date),sysdate)
    AND status in ('A','I')
    AND rownum = 1;

    l_party_id        NUMBER;
  BEGIN
    IF(px_emp_hist_id IS NULL) THEN
      OPEN is_employ_hist_exist(p_party_id, p_employed_by_name_company, p_employed_as_title, p_begin_date);
      FETCH is_employ_hist_exist INTO x_object_version_number, px_emp_hist_id;
      CLOSE is_employ_hist_exist;
    ELSE
      OPEN is_employ_hist_id_exist(px_emp_hist_id);
      FETCH is_employ_hist_id_exist INTO x_object_version_number, l_party_id;
      CLOSE is_employ_hist_id_exist;
      IF(l_party_id <> p_party_id) OR (l_party_id IS NULL AND p_party_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_employ_hist_op;

-- PROCEDURE check_work_class_op
--
-- DESCRIPTION
--     Check the operation of work class based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_work_class_name        Name of work class.
--   IN/OUT:
--     px_work_class_id         Work class Id.
--   OUT:
--     x_object_version_number  Object version number of work class.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_work_class_op(
    p_employ_hist_id             IN     NUMBER,
    px_work_class_id             IN OUT NOCOPY NUMBER,
    p_work_class_name            IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_work_class_id_exist(l_work_class_id NUMBER)IS
    SELECT nvl(object_version_number,1), employment_history_id
    FROM HZ_WORK_CLASS
    WHERE work_class_id = l_work_class_id
    AND rownum = 1;

    CURSOR is_work_class_exist(l_employ_hist_id NUMBER, l_work_class_name VARCHAR2)IS
    SELECT nvl(object_version_number,1), work_class_id
    FROM HZ_WORK_CLASS
    WHERE employment_history_id = l_employ_hist_id
    AND UPPER(ltrim(rtrim(WORK_CLASS_NAME))) = UPPER(ltrim(rtrim(l_work_class_name)))
    AND status in ('A','I')
    AND rownum = 1;

    l_eh_id       NUMBER;
  BEGIN
    IF(px_work_class_id IS NULL) THEN
      OPEN is_work_class_exist(p_employ_hist_id, p_work_class_name);
      FETCH is_work_class_exist INTO x_object_version_number, px_work_class_id;
      CLOSE is_work_class_exist;
    ELSE
      OPEN is_work_class_id_exist(px_work_class_id);
      FETCH is_work_class_id_exist INTO x_object_version_number, l_eh_id;
      CLOSE is_work_class_id_exist;
      IF(l_eh_id <> p_employ_hist_id) OR (l_eh_id IS NULL AND p_employ_hist_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_work_class_op;

-- PROCEDURE check_interest_op
--
-- DESCRIPTION
--     Check the operation of person interest based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_interest_type_code     Interest type code.
--     p_sub_interest_type_code Sub-interest type code.
--     p_interest_name          Name of interest.
--   IN/OUT:
--     px_interest_id           Person interest Id.
--   OUT:
--     x_object_version_number  Object version number of person interest.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_interest_op(
    p_party_id                   IN     NUMBER,
    px_interest_id               IN OUT NOCOPY NUMBER,
    p_interest_type_code         IN     VARCHAR2,
    p_sub_interest_type_code     IN     VARCHAR2,
    p_interest_name              IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_interest_id_exist(l_interest_id NUMBER)IS
    SELECT nvl(object_version_number,1), party_id
    FROM HZ_PERSON_INTEREST
    WHERE person_interest_id = l_interest_id
    AND rownum = 1;

    CURSOR is_interest_exist(l_party_id NUMBER, l_interest_type_code VARCHAR2,
                             l_sub_interest_type_code VARCHAR2,
                             l_interest_name VARCHAR2)IS
    SELECT nvl(object_version_number,1), person_interest_id
    FROM HZ_PERSON_INTEREST
    WHERE party_id = l_party_id
    AND (
         (nvl(INTEREST_TYPE_CODE,'X') = nvl(l_interest_type_code,'X') AND
          nvl(SUB_INTEREST_TYPE_CODE,'X') = nvl(l_sub_interest_type_code,'X'))
         OR
         UPPER(ltrim(rtrim(INTEREST_NAME))) = UPPER(ltrim(rtrim(l_interest_name)))
        )
    AND status in ('A','I')
    AND rownum = 1;

    l_party_id        NUMBER;
  BEGIN
    IF(px_interest_id IS NULL) THEN
      OPEN is_interest_exist(p_party_id, p_interest_type_code, p_sub_interest_type_code, p_interest_name);
      FETCH is_interest_exist INTO x_object_version_number, px_interest_id;
      CLOSE is_interest_exist;
    ELSE
      OPEN is_interest_id_exist(px_interest_id);
      FETCH is_interest_id_exist INTO x_object_version_number, l_party_id;
      CLOSE is_interest_id_exist;
      IF(l_party_id <> p_party_id) OR (l_party_id IS NULL AND p_party_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_interest_op;

-- PROCEDURE check_party_site_use_op
--
-- DESCRIPTION
--     Check the operation of party site use based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_site_id          Party site Id.
--     p_site_use_type          Site use type.
--   IN/OUT:
--     px_party_site_use_id     Party site use Id.
--   OUT:
--     x_object_version_number  Object version number of party site use.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_party_site_use_op(
    p_party_site_id              IN     NUMBER,
    px_party_site_use_id         IN OUT NOCOPY NUMBER,
    p_site_use_type              IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_party_site_use_id_exist(l_site_use_id NUMBER)IS
    SELECT nvl(object_version_number,1), party_site_id
    FROM HZ_PARTY_SITE_USES
    WHERE party_site_use_id = l_site_use_id
    AND rownum = 1;

    CURSOR is_party_site_use_exist(l_party_site_id NUMBER, l_site_use_type VARCHAR2)IS
	SELECT nvl(object_version_number,1), party_site_use_id
   	FROM (SELECT object_version_number, party_site_use_id,
    		RANK() OVER (ORDER BY status asc ) rank
    	  	FROM HZ_PARTY_SITE_USES
          	WHERE party_site_id = l_party_site_id
          	AND site_use_type = l_site_use_type )
    	where rank = 1
    	AND ROWNUM = 1;


    l_ps_id       NUMBER;
  BEGIN
    IF(px_party_site_use_id IS NULL) THEN
      OPEN is_party_site_use_exist(p_party_site_id, p_site_use_type);
      FETCH is_party_site_use_exist INTO x_object_version_number, px_party_site_use_id;
      CLOSE is_party_site_use_exist;
    ELSE
      OPEN is_party_site_use_id_exist(px_party_site_use_id);
      FETCH is_party_site_use_id_exist INTO x_object_version_number, l_ps_id;
      CLOSE is_party_site_use_id_exist;
      IF(l_ps_id <> p_party_site_id) OR (l_ps_id IS NULL AND p_party_site_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_party_site_use_op;

-- PROCEDURE check_relationship_op
--
-- DESCRIPTION
--     Check the operation of relationship based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_subject_id             Subject Id.
--     p_object_id              Object Id.
--     p_relationship_type      Relationship type.
--     p_relationship_code      Relationship code.
--   IN/OUT:
--     px_relationship_id       Relationship Id.
--   OUT:
--     x_object_version_number  Object version number of relationship.
--     x_party_object_version_number  Object version number of relationship party.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_relationship_op(
    p_subject_id                 IN     NUMBER,
    p_object_id                  IN     NUMBER,
    px_relationship_id           IN OUT NOCOPY NUMBER,
    p_relationship_type          IN     VARCHAR2,
    p_relationship_code          IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER,
    x_party_obj_version_number   OUT NOCOPY NUMBER
  ) IS
    CURSOR is_relationship_id_exist(l_subject_id NUMBER, l_object_id NUMBER, l_rel_id NUMBER) IS
    SELECT rel.object_version_number, p.object_version_number
    FROM HZ_RELATIONSHIPS rel, HZ_PARTIES p
    WHERE rel.subject_id = l_subject_id
    AND rel.object_id = l_object_id
    AND rel.relationship_id = l_rel_id
    AND rel.party_id = p.party_id
    AND rel.status in ('A','I')
    AND rownum = 1;

    CURSOR is_relationship_exist(l_subject_id NUMBER, l_object_id NUMBER,
                                 l_relationship_type VARCHAR2, l_relationship_code VARCHAR2)IS
    SELECT rel.object_version_number, p.object_version_number, rel.relationship_id
    FROM HZ_RELATIONSHIPS rel, HZ_PARTIES p
    WHERE rel.subject_id = l_subject_id
    AND rel.object_id = l_object_id
    AND rel.relationship_type = l_relationship_type
    AND rel.relationship_code = l_relationship_code
    AND sysdate between rel.start_date and nvl(rel.end_date, sysdate)
    AND rel.party_id = p.party_id
    AND rel.status in ('A','I')
    AND rownum = 1;
  BEGIN
    IF(px_relationship_id IS NULL) THEN
      OPEN is_relationship_exist(p_subject_id, p_object_id, p_relationship_type, p_relationship_code);
      FETCH is_relationship_exist INTO x_object_version_number, x_party_obj_version_number, px_relationship_id;
      CLOSE is_relationship_exist;
    ELSE
      OPEN is_relationship_id_exist(p_subject_id, p_object_id, px_relationship_id);
      FETCH is_relationship_id_exist INTO x_object_version_number, x_party_obj_version_number;
      CLOSE is_relationship_id_exist;
    END IF;
  END check_relationship_op;

-- PROCEDURE check_org_contact_role_op
--
-- DESCRIPTION
--     Check the operation of org contact role based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_org_contact_id         Org contact Id.
--     p_role_type              Role type.
--   IN/OUT:
--     px_org_contact_role_id   Org contact role Id.
--   OUT:
--     x_object_version_number  Object version number of org contact role.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_org_contact_role_op(
    p_org_contact_id             IN     NUMBER,
    px_org_contact_role_id       IN OUT NOCOPY NUMBER,
    p_role_type                  IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_org_contact_role_id_exist(l_role_id NUMBER)IS
    SELECT nvl(object_version_number,1), org_contact_id
    FROM HZ_ORG_CONTACT_ROLES
    WHERE org_contact_role_id = l_role_id
    AND rownum = 1;

    CURSOR is_org_contact_role_exist(l_org_contact_id NUMBER, l_role_type VARCHAR2)IS
    SELECT nvl(object_version_number,1), org_contact_role_id
    FROM HZ_ORG_CONTACT_ROLES
    WHERE org_contact_id = l_org_contact_id
    AND role_type = l_role_type
    AND status in ('A','I')
    AND rownum = 1;

    l_oc_id       NUMBER;
  BEGIN
    IF(px_org_contact_role_id IS NULL) THEN
      OPEN is_org_contact_role_exist(p_org_contact_id, p_role_type);
      FETCH is_org_contact_role_exist INTO x_object_version_number, px_org_contact_role_id;
      CLOSE is_org_contact_role_exist;
    ELSE
      OPEN is_org_contact_role_id_exist(px_org_contact_role_id);
      FETCH is_org_contact_role_id_exist INTO x_object_version_number, l_oc_id;
      CLOSE is_org_contact_role_id_exist;
      IF(l_oc_id <> p_org_contact_id) OR (l_oc_id IS NULL AND p_org_contact_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_org_contact_role_op;

-- PROCEDURE check_certification_op
--
-- DESCRIPTION
--     Check the operation of certification based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_certification_name     Name of certification.
--   IN/OUT:
--     px_certification_id      Certification Id.
--   OUT:
--     x_last_update_date       Last update date of certification.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_certification_op(
    p_party_id                   IN     NUMBER,
    px_certification_id          IN OUT NOCOPY NUMBER,
    p_certification_name         IN     VARCHAR2,
    x_last_update_date           OUT NOCOPY DATE,
    x_return_status              OUT NOCOPY VARCHAR2
  ) IS
    CURSOR is_cert_id_exist(l_cert_id NUMBER) IS
    SELECT last_update_date, party_id
    FROM HZ_CERTIFICATIONS
    WHERE certification_id = l_cert_id
    AND rownum = 1;

    CURSOR is_cert_exist(l_party_id NUMBER, l_cert_name VARCHAR2) IS
    SELECT last_update_date, certification_id
    FROM HZ_CERTIFICATIONS
    WHERE party_id = l_party_id
    AND certification_name = l_cert_name
    AND status in ('A','I')
    AND rownum = 1;

    l_party_id    NUMBER;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF(px_certification_id IS NULL) THEN
      OPEN is_cert_exist(p_party_id, p_certification_name);
      FETCH is_cert_exist INTO x_last_update_date, px_certification_id;
      CLOSE is_cert_exist;
    ELSE
      OPEN is_cert_id_exist(px_certification_id);
      FETCH is_cert_id_exist INTO x_last_update_date, l_party_id;
      CLOSE is_cert_id_exist;
      IF(l_party_id <> p_party_id) OR (l_party_id IS NULL AND p_party_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  END check_certification_op;

-- PROCEDURE check_financial_prof_op
--
-- DESCRIPTION
--     Check the operation of financial profile based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_financial_profile_id   Financial profile Id.
--   OUT:
--     x_last_update_date       Last update date of financial profile.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_financial_prof_op(
    p_party_id                   IN     NUMBER,
    p_financial_profile_id       IN     NUMBER,
    x_last_update_date           OUT NOCOPY DATE,
    x_return_status              OUT NOCOPY VARCHAR2
  ) IS
    CURSOR is_fin_exist(l_fin_prof_id NUMBER) IS
    SELECT last_update_date, party_id
    FROM HZ_FINANCIAL_PROFILE
    WHERE financial_profile_id = l_fin_prof_id
    AND rownum = 1;

    l_party_id    NUMBER;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF(p_financial_profile_id IS NULL) THEN
      x_last_update_date := NULL;
    ELSE
      OPEN is_fin_exist(p_financial_profile_id);
      FETCH is_fin_exist INTO x_last_update_date, l_party_id;
      CLOSE is_fin_exist;
      IF(l_party_id <> p_party_id) OR (l_party_id IS NULL AND p_party_id IS NOT NULL) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  END check_financial_prof_op;

-- PROCEDURE check_code_assign_op
--
-- DESCRIPTION
--     Check the operation of classification based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_owner_table_name       Owner table name.
--     p_owner_table_id         Owner table Id.
--     p_class_category         Class category.
--     p_class_code             Class code.
--   IN/OUT:
--     px_code_assignment_id    Code assignment Id.
--   OUT:
--     x_object_version_number  Object version number of classification.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_code_assign_op(
    p_owner_table_name           IN     VARCHAR2,
    p_owner_table_id             IN     NUMBER,
    px_code_assignment_id        IN OUT NOCOPY NUMBER,
    p_class_category             IN     VARCHAR2,
    p_class_code                 IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_code_assign_id_exist(l_code_assignment_id NUMBER)IS
    SELECT nvl(object_version_number,1), owner_table_name, owner_table_id
    FROM HZ_CODE_ASSIGNMENTS
    WHERE code_assignment_id = l_code_assignment_id
    AND rownum = 1;

    CURSOR is_code_assign_exist(l_owner_table_name VARCHAR2, l_owner_table_id   NUMBER,
                                l_class_category   VARCHAR2, l_class_code       VARCHAR2)IS
    SELECT nvl(object_version_number,1), code_assignment_id
    FROM HZ_CODE_ASSIGNMENTS
    WHERE owner_table_name = l_owner_table_name
    AND owner_table_id = l_owner_table_id
    AND class_category = l_class_category
    AND class_code = l_class_code
    AND sysdate between start_date_active and nvl(end_date_active, sysdate)
    AND status in ('A','I')
    AND rownum = 1;

    l_ot_name     VARCHAR2(30);
    l_ot_id       NUMBER;
  BEGIN
    IF(px_code_assignment_id IS NULL) THEN
      OPEN is_code_assign_exist(p_owner_table_name, p_owner_table_id, p_class_category, p_class_code);
      FETCH is_code_assign_exist INTO x_object_version_number, px_code_assignment_id;
      CLOSE is_code_assign_exist;
    ELSE
      OPEN is_code_assign_id_exist(px_code_assignment_id);
      FETCH is_code_assign_id_exist INTO x_object_version_number, l_ot_name, l_ot_id;
      CLOSE is_code_assign_id_exist;
      IF(l_ot_name <> p_owner_table_name OR l_ot_id <> p_owner_table_id) OR
        (l_ot_id IS NULL OR (p_owner_table_name IS NOT NULL OR p_owner_table_id IS NOT NULL)) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_code_assign_op;

-- PROCEDURE check_party_pref_op
--
-- DESCRIPTION
--     Check the operation of party preference based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_module                 Module.
--     p_category               Category.
--     p_preference_code        Preference code.
--   OUT:
--     x_object_version_number  Object version number of party preference.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_party_pref_op(
    p_party_id                   IN     NUMBER,
    p_module                     IN     VARCHAR2,
    p_category                   IN     VARCHAR2,
    p_preference_code            IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_party_pref_exist(l_party_id NUMBER, l_module VARCHAR2,
                               l_category VARCHAR2, l_preference_code VARCHAR2) IS
    SELECT nvl(object_version_number,1)
    FROM HZ_PARTY_PREFERENCES
    WHERE party_id = l_party_id
    AND module = l_module
    AND category = l_category
    AND preference_code = l_preference_code
    AND rownum = 1;
  BEGIN
    OPEN is_party_pref_exist(p_party_id, p_module, p_category, p_preference_code);
    FETCH is_party_pref_exist INTO x_object_version_number;
    CLOSE is_party_pref_exist;
  END check_party_pref_op;

-- PROCEDURE check_credit_rating_op
--
-- DESCRIPTION
--     Check the operation of credit rating based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_rating_organization    Rating organization.
--     p_rated_as_of_date       Rated date.
--   IN/OUT:
--     px_credit_rating_id      Credit rating Id.
--   OUT:
--     x_object_version_number  Object version number of credit rating.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_credit_rating_op(
    p_party_id                   IN     NUMBER,
    px_credit_rating_id          IN OUT NOCOPY NUMBER,
    p_rating_organization        IN     VARCHAR2,
    p_rated_as_of_date           IN     DATE,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_credit_rating_id_exist(l_credit_rating_id NUMBER)IS
    SELECT nvl(object_version_number,1), party_id
    FROM HZ_CREDIT_RATINGS
    WHERE credit_rating_id = l_credit_rating_id
    AND rownum = 1;

    CURSOR is_credit_rating_exist(l_party_id NUMBER, l_rating_organization VARCHAR2,
                     l_rated_as_of_date DATE)IS
    SELECT nvl(object_version_number,1), credit_rating_id
    FROM HZ_CREDIT_RATINGS
    WHERE party_id = l_party_id
    AND nvl(rating_organization,'A') = nvl(l_rating_organization,'A')
    AND trunc(nvl(rated_as_of_date,sysdate)) = trunc(nvl(l_rated_as_of_date,sysdate))
    AND status in ('A','I')
    AND rownum = 1;

    l_party_id    NUMBER;
  BEGIN
    IF(px_credit_rating_id IS NULL) THEN
      OPEN is_credit_rating_exist(p_party_id, p_rating_organization, p_rated_as_of_date);
      FETCH is_credit_rating_exist INTO x_object_version_number, px_credit_rating_id;
      CLOSE is_credit_rating_exist;
    ELSE
      OPEN is_credit_rating_id_exist(px_credit_rating_id);
      FETCH is_credit_rating_id_exist INTO x_object_version_number, l_party_id;
      CLOSE is_credit_rating_id_exist;
      IF(l_party_id <> p_party_id) OR (l_party_id IS NULL AND p_party_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_credit_rating_op;

-- PROCEDURE check_fin_report_op
--
-- DESCRIPTION
--     Check the operation of financial report based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_party_id               Party Id.
--     p_type_of_financial_report  Type of financial report.
--     p_document_reference     Document reference.
--     p_date_report_issued     Report issued date.
--     p_issued_period          Issued period.
--   IN/OUT:
--     px_fin_report_id         Financial report Id.
--   OUT:
--     x_object_version_number  Object version number of financial report.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_fin_report_op(
    p_party_id                   IN     NUMBER,
    px_fin_report_id             IN OUT NOCOPY NUMBER,
    p_type_of_financial_report   IN     VARCHAR2,
    p_document_reference         IN     VARCHAR2,
    p_date_report_issued         IN     DATE,
    p_issued_period              IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_fin_report_id_exist(l_fin_report_id NUMBER)IS
    SELECT nvl(object_version_number,1), party_id
    FROM HZ_FINANCIAL_REPORTS
    WHERE financial_report_id = l_fin_report_id
    AND rownum = 1;

    CURSOR is_fin_report_exist(l_party_id NUMBER, l_type_of_fin_report VARCHAR2,
                               l_doc_reference VARCHAR2, l_date_report_issued DATE,
                               l_issued_period VARCHAR2 )IS
    SELECT nvl(object_version_number,1), financial_report_id
    FROM HZ_FINANCIAL_REPORTS
    WHERE party_id = l_party_id
    AND type_of_financial_report = l_type_of_fin_report
    AND document_reference = l_doc_reference
    AND (trunc(date_report_issued) = trunc(l_date_report_issued) OR
         issued_period = l_issued_period OR
         sysdate between nvl(report_start_date,sysdate) and nvl(report_end_date, sysdate))
    AND status in ('A','I')
    AND rownum = 1;

    l_party_id    NUMBER;
  BEGIN
    IF(px_fin_report_id IS NULL) THEN
      OPEN is_fin_report_exist(p_party_id, p_type_of_financial_report, p_document_reference,
                               p_date_report_issued, p_issued_period);
      FETCH is_fin_report_exist INTO x_object_version_number, px_fin_report_id;
      CLOSE is_fin_report_exist;
    ELSE
      OPEN is_fin_report_id_exist(px_fin_report_id);
      FETCH is_fin_report_id_exist INTO x_object_version_number, l_party_id;
      CLOSE is_fin_report_id_exist;
      IF(l_party_id <> p_party_id) OR (l_party_id IS NULL AND p_party_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_fin_report_op;

-- PROCEDURE check_fin_number_op
--
-- DESCRIPTION
--     Check the operation of financial number based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_fin_report_id          Financial report Id.
--     p_financial_number_name  Name of financial number.
--   IN/OUT:
--     px_fin_number_id         Financial number Id.
--   OUT:
--     x_object_version_number  Object version number of financial number.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_fin_number_op(
    p_fin_report_id              IN     NUMBER,
    px_fin_number_id             IN OUT NOCOPY NUMBER,
    p_financial_number_name      IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_fin_number_id_exist(l_fin_number_id NUMBER) IS
    SELECT nvl(object_version_number,1), financial_report_id
    FROM HZ_FINANCIAL_NUMBERS
    WHERE financial_number_id = l_fin_number_id
    AND rownum = 1;

    CURSOR is_fin_number_exist(l_fin_report_id NUMBER, l_fin_number_name VARCHAR2) IS
    SELECT nvl(object_version_number,1), financial_number_id
    FROM HZ_FINANCIAL_NUMBERS
    WHERE financial_report_id = l_fin_report_id
    AND financial_number_name = l_fin_number_name
    AND status in ('A','I')
    AND rownum = 1;

    l_fr_id       NUMBER;
  BEGIN
    IF(px_fin_number_id IS NULL) THEN
      OPEN is_fin_number_exist(p_fin_report_id, p_financial_number_name);
      FETCH is_fin_number_exist INTO x_object_version_number, px_fin_number_id;
      CLOSE is_fin_number_exist;
    ELSE
      OPEN is_fin_number_id_exist(px_fin_number_id);
      FETCH is_fin_number_id_exist INTO x_object_version_number, l_fr_id;
      CLOSE is_fin_number_id_exist;
      IF(l_fr_id <> p_fin_report_id) OR (l_fr_id IS NULL AND p_fin_report_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_fin_number_op;

-- PROCEDURE check_role_resp_op
--
-- DESCRIPTION
--     Check the operation of role responsibility based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cust_acct_contact_id   Customer account contact Id.
--     p_responsibility_type    Role responsibility type.
--   IN/OUT:
--     px_responsibility_id     Role responsibility Id.
--   OUT:
--     x_object_version_number  Object version number of role responsibility.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_role_resp_op(
    p_cust_acct_contact_id       IN     NUMBER,
    px_responsibility_id         IN OUT NOCOPY NUMBER,
    p_responsibility_type        IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_role_resp_id_exist(l_resp_id NUMBER) IS
    SELECT nvl(object_version_number,1), cust_account_role_id
    FROM HZ_ROLE_RESPONSIBILITY
    WHERE responsibility_id = l_resp_id
    AND rownum = 1;

    CURSOR is_role_resp_exist(l_cac_id NUMBER, l_resp_type VARCHAR2) IS
    SELECT nvl(object_version_number,1), responsibility_id
    FROM HZ_ROLE_RESPONSIBILITY
    WHERE cust_account_role_id = l_cac_id
    AND responsibility_type = l_resp_type
    AND rownum = 1;

    l_cac_id      NUMBER;
  BEGIN
    IF(px_responsibility_id IS NULL) THEN
      OPEN is_role_resp_exist(p_cust_acct_contact_id, p_responsibility_type);
      FETCH is_role_resp_exist INTO x_object_version_number, px_responsibility_id;
      CLOSE is_role_resp_exist;
    ELSE
      OPEN is_role_resp_id_exist(px_responsibility_id);
      FETCH is_role_resp_id_exist INTO x_object_version_number, l_cac_id;
      CLOSE is_role_resp_id_exist;
      IF(l_cac_id <> p_cust_acct_contact_id) OR (l_cac_id IS NULL AND p_cust_acct_contact_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_role_resp_op;

-- PROCEDURE check_cust_profile_op
--
-- DESCRIPTION
--     Check the operation of customer profile based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cust_acct_id           Customer account Id.
--     p_site_use_id            Customer site use Id.
--     p_profile_class_id       Profile class Id.
--   IN/OUT:
--     px_cust_acct_profile_id  Customer profile Id.
--   OUT:
--     x_object_version_number  Object version number of customer profile.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_cust_profile_op(
    p_cust_acct_id               IN     NUMBER,
    px_cust_acct_profile_id      IN OUT NOCOPY NUMBER,
    p_site_use_id                IN     NUMBER,
    p_profile_class_id           IN     NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_cust_profile_id_exist(l_cust_acct_prof_id NUMBER) IS
    SELECT nvl(object_version_number,1), cust_account_id, site_use_id
    FROM HZ_CUSTOMER_PROFILES
    WHERE cust_account_profile_id = l_cust_acct_prof_id
    AND rownum = 1;

    CURSOR is_cust_profile_exist(l_ca_id NUMBER, l_site_use_id NUMBER, l_profile_class_id NUMBER) IS
    SELECT nvl(object_version_number,1), cust_account_profile_id
    FROM HZ_CUSTOMER_PROFILES
    WHERE cust_account_id = l_ca_id
    AND nvl(site_use_id, -99) = nvl(l_site_use_id, -99)
    AND profile_class_id = l_profile_class_id
    AND status in ('A','I')
    AND rownum = 1;

    l_ca_id       NUMBER;
    l_casu_id     NUMBER;
  BEGIN
    IF(px_cust_acct_profile_id IS NULL) THEN
      OPEN is_cust_profile_exist(p_cust_acct_id, p_site_use_id, p_profile_class_id);
      FETCH is_cust_profile_exist INTO x_object_version_number, px_cust_acct_profile_id;
      CLOSE is_cust_profile_exist;
    ELSE
      OPEN is_cust_profile_id_exist(px_cust_acct_profile_id);
      FETCH is_cust_profile_id_exist INTO x_object_version_number, l_ca_id, l_casu_id;
      CLOSE is_cust_profile_id_exist;
      IF((l_ca_id <> p_cust_acct_id) OR (nvl(l_casu_id,-99) <> nvl(p_site_use_id,-99))) OR
        ((l_ca_id IS NULL AND p_cust_acct_id IS NOT NULL) OR (l_casu_id IS NULL AND p_site_use_id IS NOT NULL)) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_cust_profile_op;

-- PROCEDURE check_cust_profile_amt_op
--
-- DESCRIPTION
--     Check the operation of customer profile amount based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cust_profile_id        Customer profile Id.
--     p_currency_code          Currency code.
--   IN/OUT:
--     px_cust_acct_prof_amt_id Customer profile amount Id.
--   OUT:
--     x_object_version_number  Object version number of customer profile amount.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_cust_profile_amt_op(
    p_cust_profile_id            IN     NUMBER,
    px_cust_acct_prof_amt_id     IN OUT NOCOPY NUMBER,
    p_currency_code              IN     VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_cust_profile_amt_id_exist(l_cust_prof_amt_id NUMBER) IS
    SELECT nvl(object_version_number,1), cust_account_profile_id
    FROM HZ_CUST_PROFILE_AMTS
    WHERE cust_acct_profile_amt_id = l_cust_prof_amt_id
    AND rownum = 1;

    CURSOR is_cust_profile_amt_exist(l_cap_id NUMBER, l_currency_code VARCHAR2) IS
    SELECT nvl(object_version_number,1), cust_acct_profile_amt_id
    FROM HZ_CUST_PROFILE_AMTS
    WHERE cust_account_profile_id = l_cap_id
    AND currency_code = l_currency_code
    AND rownum = 1;

    l_cap_id      NUMBER;
  BEGIN
    IF(px_cust_acct_prof_amt_id IS NULL) THEN
      OPEN is_cust_profile_amt_exist(p_cust_profile_id, p_currency_code);
      FETCH is_cust_profile_amt_exist INTO x_object_version_number, px_cust_acct_prof_amt_id;
      CLOSE is_cust_profile_amt_exist;
    ELSE
      OPEN is_cust_profile_amt_id_exist(px_cust_acct_prof_amt_id);
      FETCH is_cust_profile_amt_id_exist INTO x_object_version_number, l_cap_id;
      CLOSE is_cust_profile_amt_id_exist;
      IF(l_cap_id <> p_cust_profile_id) OR (l_cap_id IS NULL AND p_cust_profile_id IS NOT NULL) THEN
        -- return -1 to indicate that the combination of parent and object id do not match
        x_object_version_number := -1;
      END IF;
    END IF;
  END check_cust_profile_amt_op;

-- PROCEDURE check_cust_acct_relate_op
--
-- DESCRIPTION
--     Check the operation of customer account relationship based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cust_acct_id           Customer account Id.
--     p_related_cust_acct_id   Related customer account Id.
--   OUT:
--     x_object_version_number  Object version number of customer account relationship.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_cust_acct_relate_op(
    p_cust_acct_id               IN     NUMBER,
    p_related_cust_acct_id       IN     NUMBER,
    p_org_id                     IN     NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
  ) IS
    CURSOR is_cust_acct_relate_exist(l_ca_id NUMBER, l_rca_id NUMBER) IS
    SELECT nvl(object_version_number,1)
    FROM HZ_CUST_ACCT_RELATE
    WHERE cust_account_id = l_ca_id
    AND related_cust_account_id = l_rca_id
    AND status in ('A','I')
    AND ORG_ID = NVL(p_org_id, ORG_ID) -- bug 8549266
    AND rownum = 1;
  BEGIN
    OPEN is_cust_acct_relate_exist(p_cust_acct_id, p_related_cust_acct_id);
    FETCH is_cust_acct_relate_exist INTO x_object_version_number;
    CLOSE is_cust_acct_relate_exist;
  END check_cust_acct_relate_op;

-- PROCEDURE check_payment_method_op
--
-- DESCRIPTION
--     Check the operation of payment method based on pass in parameter.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cust_receipt_method_id Payment method Id.
--   OUT:
--     x_last_update_date       Last update date of payment method.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE check_payment_method_op(
    p_cust_receipt_method_id     IN     NUMBER,
    x_last_update_date           OUT NOCOPY DATE
  ) IS
    CURSOR is_payment_method_exist(l_pm_id NUMBER) IS
    SELECT last_update_date
    FROM RA_CUST_RECEIPT_METHODS
    WHERE cust_receipt_method_id = l_pm_id
    AND rownum = 1;
  BEGIN
    OPEN is_payment_method_exist(p_cust_receipt_method_id);
    FETCH is_payment_method_exist INTO x_last_update_date;
    CLOSE is_payment_method_exist;
  END check_payment_method_op;

-- FUNCTION check_bo_op
--
-- DESCRIPTION
--     Return the operation of business object based on pass in parameter.
--     Return value can be 'C' (create) or 'U' (update)
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_entity_id              Business object Id.
--     p_entity_os              Business object original system.
--     p_entity_osr             Business object original system reference.
--     p_entity_type            Business object type.
--     p_cp_type                Contact point type.
--     p_parent_id              Parent Id,
--     p_parent_table           Parent table
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION check_bo_op(
    p_entity_id                  IN     NUMBER,
    p_entity_os                  IN     VARCHAR2,
    p_entity_osr                 IN     VARCHAR2,
    p_entity_type                IN     VARCHAR2,
    p_cp_type                    IN     VARCHAR2 := NULL,
    p_parent_id                  IN     NUMBER,
    p_parent_obj_type            IN     VARCHAR2
  ) RETURN VARCHAR2 IS
    CURSOR is_contact_point_exist(l_contact_point_id NUMBER, l_contact_point_type VARCHAR2) IS
    SELECT owner_table_id, owner_table_name
    FROM HZ_CONTACT_POINTS
    WHERE contact_point_id = l_contact_point_id
    AND contact_point_type = l_contact_point_type;

    CURSOR is_party_site_exist(l_ps_id NUMBER) IS
    SELECT party_id
    FROM HZ_PARTY_SITES
    WHERE party_site_id = l_ps_id;

    CURSOR is_location_exist(l_loc_id NUMBER) IS
    SELECT 'X'
    FROM HZ_LOCATIONS
    WHERE location_id = l_loc_id;

    CURSOR is_party_exist(l_party_id NUMBER) IS
    SELECT 'X'
    FROM HZ_PARTIES
    WHERE party_id = l_party_id;

    CURSOR is_org_contact_exist(l_org_contact_id NUMBER) IS
    SELECT r.object_id
    FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS r
    WHERE oc.org_contact_id = l_org_contact_id
    AND oc.party_relationship_id = r.relationship_id
    AND r.object_type = 'ORGANIZATION'
    AND r.subject_type = 'PERSON'
    AND rownum = 1;

    CURSOR is_cust_account_exist(l_cust_acct_id NUMBER) IS
    SELECT party_id
    FROM HZ_CUST_ACCOUNTS
    WHERE cust_account_id = l_cust_acct_id;

    CURSOR is_cust_acct_site_exist(l_cust_acct_site_id NUMBER) IS
    SELECT cust_account_id
    FROM HZ_CUST_ACCT_SITES_ALL
    WHERE cust_acct_site_id = l_cust_acct_site_id;

    CURSOR is_cust_site_use_exist(l_site_use_id NUMBER) IS
    SELECT cust_acct_site_id
    FROM HZ_CUST_SITE_USES
    WHERE site_use_id = l_site_use_id;

    CURSOR is_cust_acct_role_exist(l_cust_acct_role_id NUMBER) IS
    SELECT cust_account_id, nvl(cust_acct_site_id, -99)
    FROM HZ_CUST_ACCOUNT_ROLES
    WHERE cust_account_role_id = l_cust_acct_role_id;

    l_create_update_flag       VARCHAR2(1);
    l_dummy                    VARCHAR2(1);
    l_ss_flag                  VARCHAR2(1);
    l_owner_table_id           NUMBER;
    l_debug_prefix             VARCHAR2(30);
    l_return_status            VARCHAR2(30);
    l_count                    NUMBER;
    l_parent_id                NUMBER;
    l_acct_site_id             NUMBER;
    l_input_parent_table       VARCHAR2(30);
    l_parent_table             VARCHAR2(30);
  BEGIN
    l_dummy := NULL;

    l_ss_flag := is_ss_provided(p_os  => p_entity_os,
                                p_osr => p_entity_osr);

    -- Return as 'Create' if no TCA id and no os+osr pass in
    -- Fix bug 4748851
    IF(p_entity_id IS NULL) AND (l_ss_flag = 'N') THEN
      RETURN 'C';
    END IF;

    -- if TCA id pass in, check if it is valid or not
    IF(p_entity_id IS NOT NULL) THEN
      l_input_parent_table := get_owner_table_name(p_parent_obj_type);

      IF(p_entity_type = 'HZ_CONTACT_POINTS') THEN
        OPEN is_contact_point_exist(p_entity_id, p_cp_type);
        FETCH is_contact_point_exist INTO l_parent_id, l_parent_table;
        CLOSE is_contact_point_exist;
        IF(l_parent_id IS NULL OR l_parent_id <> p_parent_id OR l_parent_table <> l_input_parent_table) THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
          FND_MSG_PUB.ADD;
          RETURN 'E';
        END IF;
        l_dummy := 'X';
      ELSIF(p_entity_type = 'HZ_PARTY_SITES') THEN
        OPEN is_party_site_exist(p_entity_id);
        FETCH is_party_site_exist INTO l_parent_id;
        CLOSE is_party_site_exist;
        IF(l_parent_id IS NULL OR l_parent_id <> p_parent_id) THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
          FND_MSG_PUB.ADD;
          RETURN 'E';
        END IF;
        l_dummy := 'X';
      ELSIF(p_entity_type = 'HZ_LOCATIONS') THEN
        OPEN is_location_exist(p_entity_id);
        FETCH is_location_exist INTO l_dummy;
        CLOSE is_location_exist;
      ELSIF(p_entity_type = 'HZ_PARTIES') THEN
        OPEN is_party_exist(p_entity_id);
        FETCH is_party_exist INTO l_dummy;
        CLOSE is_party_exist;
      ELSIF(p_entity_type = 'HZ_ORG_CONTACTS') THEN
        OPEN is_org_contact_exist(p_entity_id);
        FETCH is_org_contact_exist INTO l_parent_id;
        CLOSE is_org_contact_exist;
        IF(l_parent_id IS NULL OR l_parent_id <> p_parent_id) THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
          FND_MSG_PUB.ADD;
          RETURN 'E';
        END IF;
        l_dummy := 'X';
      ELSIF(p_entity_type = 'HZ_CUST_ACCOUNTS') THEN
        OPEN is_cust_account_exist(p_entity_id);
        FETCH is_cust_account_exist INTO l_parent_id;
        CLOSE is_cust_account_exist;
        IF(l_parent_id IS NULL OR l_parent_id <> p_parent_id) THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
          FND_MSG_PUB.ADD;
          RETURN 'E';
        END IF;
        l_dummy := 'X';
      ELSIF(p_entity_type = 'HZ_CUST_ACCT_SITES_ALL') THEN
        OPEN is_cust_acct_site_exist(p_entity_id);
        FETCH is_cust_acct_site_exist INTO l_parent_id;
        CLOSE is_cust_acct_site_exist;
        IF(l_parent_id IS NULL OR l_parent_id <> p_parent_id) THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
          FND_MSG_PUB.ADD;
          RETURN 'E';
        END IF;
        l_dummy := 'X';
      ELSIF(p_entity_type = 'HZ_CUST_SITE_USES_ALL') THEN
        OPEN is_cust_site_use_exist(p_entity_id);
        FETCH is_cust_site_use_exist INTO l_parent_id;
        CLOSE is_cust_site_use_exist;
        IF(l_parent_id IS NULL OR l_parent_id <> p_parent_id) THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
          FND_MSG_PUB.ADD;
          RETURN 'E';
        END IF;
        l_dummy := 'X';
      ELSIF(p_entity_type = 'HZ_CUST_ACCOUNT_ROLES') THEN
        OPEN is_cust_acct_role_exist(p_entity_id);
        FETCH is_cust_acct_role_exist INTO l_parent_id, l_acct_site_id;
        CLOSE is_cust_acct_role_exist;
        IF(p_parent_obj_type = 'CUST_ACCT_SITE') THEN
          IF(l_parent_id IS NULL OR l_acct_site_id <> p_parent_id) THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
            FND_MSG_PUB.ADD;
            RETURN 'E';
          END IF;
        ELSIF(p_parent_obj_type = 'CUST_ACCT') THEN
          IF(l_parent_id IS NULL OR l_parent_id <> p_parent_id) THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
            FND_MSG_PUB.ADD;
            RETURN 'E';
          END IF;
        END IF;
        l_dummy := 'X';
      END IF;
    END IF;

    IF(l_ss_flag = 'Y') THEN
      -- Get how many rows return
      l_count := HZ_MOSR_VALIDATE_PKG.get_orig_system_ref_count(
                   p_orig_system           => p_entity_os,
                   p_orig_system_reference => p_entity_osr,
                   p_owner_table_name      => p_entity_type);

      IF(l_count > 0) THEN
        HZ_ORIG_SYSTEM_REF_PUB.get_owner_table_id(
          p_orig_system           => p_entity_os,
          p_orig_system_reference => p_entity_osr,
          p_owner_table_name      => p_entity_type,
          x_owner_table_id        => l_owner_table_id,
          x_return_status         => l_return_status);

        -- For contact point, check if the id and type is the same
        IF(p_entity_type = 'HZ_CONTACT_POINTS') THEN
          OPEN is_contact_point_exist(l_owner_table_id, p_cp_type);
          FETCH is_contact_point_exist INTO l_parent_id, l_parent_table;
          CLOSE is_contact_point_exist;
          IF(l_parent_id IS NULL OR l_parent_id <> p_parent_id OR l_parent_table <> l_input_parent_table) THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
            FND_MSG_PUB.ADD;
            RETURN 'E';
          END IF;
        END IF;
      END IF;
    END IF;

    -- no TCA id
    IF(p_entity_id IS NULL) THEN
      -- ssm is invalid
      IF(l_ss_flag = 'Y') AND (l_count = 0) THEN
        RETURN 'C';
      END IF;
      -- ssm is valid
      IF(l_ss_flag = 'Y') AND (l_count > 0) AND (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        RETURN 'U';
      ELSE
        RETURN 'E';
      END IF;
    ELSE
      -- invalid TCA id
      IF(l_dummy IS NULL) THEN
        -- ssm is valid
        IF(l_ss_flag = 'Y') AND (l_count > 0) AND (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          RETURN 'E';
        END IF;
        RETURN 'C';
      -- valid TCA id
      ELSE
        RETURN 'U';
      END IF;
    END IF;
  END check_bo_op;

-- PROCEDURE check_party_usage_op
--
-- DESCRIPTION
--     Checks if a row exists in  party_usg_assigments table for agiven
--      party_id and party_usages_code.
--     If exists Return last_update_date value. otherwise null.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--    p_party_id              id of a party for whicch party_usage was created.
--    p_party_usage_code         seeded usage code.

--   OUT:
--    x_last_update_date       last_update_date column,
--    x_return_status              status of the call
-- NOTES
--
-- MODIFICATION HISTORY
--
--   01-Mar-2006    Hadi Alatasi   o Created.

  PROCEDURE check_party_usage_op(
    p_party_id                   IN     NUMBER,
    p_party_usage_code          IN     VARCHAR2,
    x_last_update_date          OUT NOCOPY DATE,
    x_return_status              OUT NOCOPY VARCHAR2
  ) IS
    CURSOR is_usg_exist(l_party_id NUMBER, l_party_usage_code VARCHAR2 ) IS
    SELECT last_update_date
    FROM HZ_PARTY_USG_ASSIGNMENTS
    WHERE PARTY_USAGE_CODE = l_party_usage_code
	AND PARTY_ID= l_party_id
    AND rownum = 1;

    l_party_id    NUMBER;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF(p_party_usage_code IS NULL OR p_party_id IS NULL) THEN
      x_last_update_date := NULL;
    ELSE
      OPEN is_usg_exist(p_party_id,p_party_usage_code);
      FETCH is_usg_exist INTO x_last_update_date;
      CLOSE is_usg_exist;
    END IF;
  EXCEPTION
   when NO_DATA_FOUND then
     x_last_update_date := NULL;
   when OTHERS then
     x_return_status := FND_API.G_RET_STS_ERROR;

  END check_party_usage_op;


-- PRIVATE FUNCTION is_ss_provided
--
-- DESCRIPTION
--     Return a flag to indicate that original system and original system reference
--     are provided.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_os                     Original system.
--     p_osr                    Original system reference.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

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

-- FUNCTION get_owner_table_name
--
-- DESCRIPTION
--     Return the owner table name based on object type.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_obj_type               Object type.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION get_owner_table_name(
    p_obj_type            IN     VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    -- Base on HZ_BUSINESS_OBJECTS lookup code
    IF(p_obj_type = 'PARTY_SITE') THEN
      RETURN 'HZ_PARTY_SITES';
    ELSIF((p_obj_type = 'ORG') OR (p_obj_type = 'PERSON') OR (p_obj_type = 'ORG_CONTACT')) THEN
      RETURN 'HZ_PARTIES';
    ELSIF((p_obj_type = 'ORG_CUST') OR (p_obj_type = 'PERSON_CUST') OR (p_obj_type = 'CUST_ACCT')) THEN
      RETURN 'HZ_CUST_ACCOUNTS';
    ELSIF(p_obj_type = 'CUST_ACCT_CONTACT') THEN
      RETURN 'HZ_CUST_ACCOUNT_ROLES';
    ELSIF(p_obj_type = 'CUST_ACCT_SITE') THEN
      RETURN 'HZ_CUST_ACCT_SITES_ALL';
    ELSIF(p_obj_type in ('PHONE', 'EMAIL', 'TLX', 'WEB', 'EDI', 'EFT', 'SMS')) THEN
      RETURN 'HZ_CONTACT_POINTS';
    ELSIF(p_obj_type = 'LOCATION') THEN
      RETURN 'HZ_LOCATIONS';
    ELSIF(p_obj_type = 'CUST_ACCT_SITE_USE') THEN
      RETURN 'HZ_CUST_SITE_USES_ALL';
    END IF;
    RETURN NULL;
  END get_owner_table_name;

-- FUNCTION get_parent_object_type
--
-- DESCRIPTION
--     Return the object type based on parent table and Id.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_parent_table_name      Parent table name.
--     p_parent_id              Parent Id.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION get_parent_object_type(
    p_parent_table_name         IN     VARCHAR2,
    p_parent_id                 IN     NUMBER
  ) RETURN VARCHAR2 IS

    l_party_type VARCHAR2(30) := null;

    CURSOR c1 IS
      SELECT party_type FROM hz_parties
      WHERE party_id = p_parent_id;

    CURSOR c2 IS
      SELECT party_type
      FROM hz_parties p, hz_cust_accounts ca
      WHERE p.party_id = ca.party_id
      AND ca.cust_account_id = p_parent_id;

  BEGIN
    -- Base on owner_table_name to return HZ_BUSINESS_OBJECTS lookup code
    IF p_parent_table_name = 'HZ_PARTIES' THEN
      OPEN c1;
      FETCH c1 INTO l_party_type;
      CLOSE c1;
    ELSIF p_parent_table_name = 'HZ_CUST_ACCOUNTS' THEN
      OPEN c2;
      FETCH c2 INTO l_party_type;
      CLOSE c2;
    END IF;

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

-- FUNCTION is_cp_bo_comp
--
-- DESCRIPTION
--     Return true if contact point object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_phone_objs             List of phone business objects.
--     p_email_objs             List of email business objects.
--     p_telex_objs             List of telex business objects.
--     p_web_objs               List of web business objects.
--     p_edi_objs               List of edi business objects.
--     p_eft_objs               List of eft business objects.
--     p_sms_objs               List of sms business objects.
--     p_bus_object             Business object structure for contact point.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION is_cp_bo_comp(
    p_phone_objs              IN     HZ_PHONE_CP_BO_TBL,
    p_email_objs              IN     HZ_EMAIL_CP_BO_TBL,
    p_telex_objs              IN     HZ_TELEX_CP_BO_TBL,
    p_web_objs                IN     HZ_WEB_CP_BO_TBL,
    p_edi_objs                IN     HZ_EDI_CP_BO_TBL,
    p_eft_objs                IN     HZ_EFT_CP_BO_TBL,
    p_sms_objs                IN     HZ_SMS_CP_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
  ) RETURN BOOLEAN IS

    l_phone_cpref             BOOLEAN;
    l_email_cpref             BOOLEAN;
    l_telex_cpref             BOOLEAN;
    l_web_cpref               BOOLEAN;
    l_edi_cpref               BOOLEAN;
    l_eft_cpref               BOOLEAN;
    l_sms_cpref               BOOLEAN;
    l_bus_object              COMPLETENESS_REC_TYPE;
    l_bo_num                  NUMBER;
  BEGIN
    -- Contact point only has contact preference entity, use boolean to
    -- indicate whether it must be present or not
    l_bo_num       := 0;
    l_phone_cpref  := FALSE;
    l_email_cpref  := FALSE;
    l_telex_cpref  := FALSE;
    l_web_cpref    := FALSE;
    l_edi_cpref    := FALSE;
    l_eft_cpref    := FALSE;
    l_sms_cpref    := FALSE;
    l_bus_object.business_object_code := boc_tbl();
    l_bus_object.child_bo_code := cbc_tbl();
    l_bus_object.tca_mandated_flag := tmf_tbl();
    l_bus_object.user_mandated_flag := umf_tbl();
    l_bus_object.root_node_flag := rnf_tbl();
    l_bus_object.entity_name := ent_tbl();

    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      -- get all entity of contact point, for contact point, the only possible
      -- entity is HZ_CONTACT_PREFERENCES
      IF(p_bus_object.tca_mandated_flag(i) = 'N' AND
         p_bus_object.user_mandated_flag(i) = 'Y' AND
         p_bus_object.root_node_flag(i) = 'N') THEN
        CASE
          WHEN p_bus_object.business_object_code(i) = 'PHONE' THEN
            l_phone_cpref := TRUE;
          WHEN p_bus_object.business_object_code(i) = 'EMAIL' THEN
            l_email_cpref := TRUE;
          WHEN p_bus_object.business_object_code(i) = 'TELEX' THEN
            l_telex_cpref := TRUE;
          WHEN p_bus_object.business_object_code(i) = 'WEB' THEN
            l_web_cpref := TRUE;
          WHEN p_bus_object.business_object_code(i) = 'EDI' THEN
            l_edi_cpref := TRUE;
          WHEN p_bus_object.business_object_code(i) = 'EFT' THEN
            l_eft_cpref := TRUE;
          WHEN p_bus_object.business_object_code(i) = 'SMS' THEN
            l_sms_cpref := TRUE;
          ELSE
            null;
        END CASE;
      ELSIF(p_bus_object.tca_mandated_flag(i) = 'Y' AND
            p_bus_object.user_mandated_flag(i) = 'Y' AND
            p_bus_object.root_node_flag(i) = 'Y') THEN
        l_bo_num := l_bo_num + 1;
        l_bus_object.business_object_code.EXTEND;
        l_bus_object.child_bo_code.EXTEND;
        l_bus_object.tca_mandated_flag.EXTEND;
        l_bus_object.user_mandated_flag.EXTEND;
        l_bus_object.root_node_flag.EXTEND;
        l_bus_object.entity_name.EXTEND;
        l_bus_object.business_object_code(l_bo_num) := p_bus_object.business_object_code(i);
        l_bus_object.child_bo_code(l_bo_num) := p_bus_object.child_bo_code(i);
        l_bus_object.tca_mandated_flag(l_bo_num) := p_bus_object.tca_mandated_flag(i);
        l_bus_object.user_mandated_flag(l_bo_num) := p_bus_object.user_mandated_flag(i);
        l_bus_object.root_node_flag(l_bo_num) := p_bus_object.root_node_flag(i);
        l_bus_object.entity_name(l_bo_num) := p_bus_object.entity_name(i);
      END IF;
    END LOOP;

    -- loop through l_bus_object to find out which contact point must be present
    FOR i IN 1..l_bo_num LOOP
      CASE
        WHEN l_bus_object.business_object_code(i) = 'PHONE' THEN
          IF(p_phone_objs IS NULL OR p_phone_objs.COUNT < 1) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
            fnd_message.set_token('OBJECT' ,'PHONE');
            fnd_msg_pub.add;
            RETURN FALSE;
          ELSE
            FOR j IN 1..p_phone_objs.COUNT LOOP
              IF(l_phone_cpref AND
                 (p_phone_objs(j).contact_pref_objs IS NULL OR
                  p_phone_objs(j).contact_pref_objs.COUNT < 1)) THEN
                fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
                fnd_message.set_token('ENTITY' ,'PHONE-CONTACT_PREFERENCE');
                fnd_msg_pub.add;
                RETURN FALSE;
              END IF;
            END LOOP;
          END IF;
        WHEN l_bus_object.business_object_code(i) = 'EMAIL' THEN
          IF(p_email_objs IS NULL OR p_email_objs.COUNT < 1) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
            fnd_message.set_token('OBJECT' ,'EMAIL');
            fnd_msg_pub.add;
            RETURN FALSE;
          ELSE
            FOR j IN 1..p_email_objs.COUNT LOOP
              IF(l_email_cpref AND
                 (p_email_objs(j).contact_pref_objs IS NULL OR
                  p_email_objs(j).contact_pref_objs.COUNT < 1)) THEN
                fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
                fnd_message.set_token('ENTITY' ,'EMAIL-CONTACT_PREFERENCE');
                fnd_msg_pub.add;
                RETURN FALSE;
              END IF;
            END LOOP;
          END IF;
        WHEN l_bus_object.business_object_code(i) = 'TLX' THEN
          IF(p_telex_objs IS NULL OR p_telex_objs.COUNT < 1) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
            fnd_message.set_token('OBJECT' ,'TELEX');
            fnd_msg_pub.add;
            RETURN FALSE;
          ELSE
            FOR j IN 1..p_telex_objs.COUNT LOOP
              IF(l_telex_cpref AND
                 (p_telex_objs(j).contact_pref_objs IS NULL OR
                  p_telex_objs(j).contact_pref_objs.COUNT < 1)) THEN
                fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
                fnd_message.set_token('ENTITY' ,'TLX-CONTACT_PREFERENCE');
                fnd_msg_pub.add;
                RETURN FALSE;
              END IF;
            END LOOP;
          END IF;
        WHEN l_bus_object.business_object_code(i) = 'WEB' THEN
          IF(p_web_objs IS NULL OR p_web_objs.COUNT < 1) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
            fnd_message.set_token('OBJECT' ,'WEB');
            fnd_msg_pub.add;
            RETURN FALSE;
          ELSE
            FOR j IN 1..p_web_objs.COUNT LOOP
              IF(l_web_cpref AND
                 (p_web_objs(j).contact_pref_objs IS NULL OR
                  p_web_objs(j).contact_pref_objs.COUNT < 1)) THEN
                fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
                fnd_message.set_token('ENTITY' ,'WEB-CONTACT_PREFERENCE');
                fnd_msg_pub.add;
                RETURN FALSE;
              END IF;
            END LOOP;
          END IF;
        WHEN l_bus_object.business_object_code(i) = 'EDI' THEN
          IF(p_edi_objs IS NULL OR p_edi_objs.COUNT < 1) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
            fnd_message.set_token('OBJECT' ,'EDI');
            fnd_msg_pub.add;
            RETURN FALSE;
          ELSE
            FOR j IN 1..p_edi_objs.COUNT LOOP
              IF(l_edi_cpref AND
                 (p_edi_objs(j).contact_pref_objs IS NULL OR
                  p_edi_objs(j).contact_pref_objs.COUNT < 1)) THEN
                fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
                fnd_message.set_token('ENTITY' ,'EDI-CONTACT_PREFERENCE');
                fnd_msg_pub.add;
                RETURN FALSE;
              END IF;
            END LOOP;
          END IF;
        WHEN l_bus_object.business_object_code(i) = 'EFT' THEN
          IF(p_eft_objs IS NULL OR p_eft_objs.COUNT < 1) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
            fnd_message.set_token('OBJECT' ,'EFT');
            fnd_msg_pub.add;
            RETURN FALSE;
          ELSE
            FOR j IN 1..p_eft_objs.COUNT LOOP
              IF(l_eft_cpref AND
                 (p_eft_objs(j).contact_pref_objs IS NULL OR
                  p_eft_objs(j).contact_pref_objs.COUNT < 1)) THEN
                fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
                fnd_message.set_token('ENTITY' ,'EFT-CONTACT_PREFERENCE');
                fnd_msg_pub.add;
                RETURN FALSE;
              END IF;
            END LOOP;
          END IF;
        WHEN l_bus_object.business_object_code(i) = 'SMS' THEN
          IF(p_sms_objs IS NULL OR p_sms_objs.COUNT < 1) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
            fnd_message.set_token('OBJECT' ,'SMS');
            fnd_msg_pub.add;
            RETURN FALSE;
          ELSE
            FOR j IN 1..p_sms_objs.COUNT LOOP
              IF(l_sms_cpref AND
                 (p_sms_objs(j).contact_pref_objs IS NULL OR
                  p_sms_objs(j).contact_pref_objs.COUNT < 1)) THEN
                fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
                fnd_message.set_token('ENTITY' ,'SMS-CONTACT_PREFERENCE');
                fnd_msg_pub.add;
                RETURN FALSE;
              END IF;
            END LOOP;
          END IF;
        ELSE
          null;
        END CASE;
    END LOOP;

    RETURN TRUE;
  END is_cp_bo_comp;

-- FUNCTION is_ps_bo_comp
--
-- DESCRIPTION
--     Return true if party site object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_ps_objs                List of party site business objects.
--     p_bus_object             Business object structure for party site.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION is_ps_bo_comp(
    p_ps_objs                 IN     HZ_PARTY_SITE_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
  ) RETURN BOOLEAN IS

    l_bus_object              COMPLETENESS_REC_TYPE;
    l_cp_bus_object           COMPLETENESS_REC_TYPE;
    l_valid_obj               BOOLEAN;
    l_psu                     BOOLEAN;
    l_cpref                   BOOLEAN;
    l_ps_ext                  BOOLEAN;
    l_loc_ext                 BOOLEAN;
    l_phone_code              VARCHAR2(30);
    l_telex_code              VARCHAR2(30);
    l_email_code              VARCHAR2(30);
    l_web_code                VARCHAR2(30);
  BEGIN
    l_psu          := FALSE;
    l_cpref        := FALSE;
    l_ps_ext       := FALSE;
    l_loc_ext      := FALSE;
    l_phone_code   := NULL;
    l_telex_code   := NULL;
    l_email_code   := NULL;
    l_web_code     := NULL;

    IF(p_ps_objs IS NULL OR p_ps_objs.COUNT < 1) THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
      fnd_message.set_token('OBJECT' ,'PARTY_SITE');
      fnd_msg_pub.add;
      RETURN FALSE;
    END IF;

    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      -- get all entities of party site, for party site, the only possible
      -- entites are HZ_PARTY_SITE_USES, HZ_CONTACT_PREFERENCES
      IF(p_bus_object.tca_mandated_flag(i) = 'N' AND
         p_bus_object.user_mandated_flag(i) = 'Y' AND
         p_bus_object.business_object_code(i) = 'PARTY_SITE' AND
         p_bus_object.child_bo_code(i) IS NULL) THEN
        CASE
          WHEN p_bus_object.entity_name(i) = 'HZ_PARTY_SITE_USES' THEN
            l_psu := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_CONTACT_PREFERENCES' THEN
            l_cpref := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_PARTY_SITES_EXT_VL' THEN
            l_ps_ext := TRUE;
        END CASE;
      -- Get contact point business object
      ELSIF(p_bus_object.child_bo_code(i) IS NOT NULL AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        CASE
          WHEN p_bus_object.child_bo_code(i) = 'PHONE' THEN
            l_phone_code := 'PHONE';
          WHEN p_bus_object.child_bo_code(i) = 'TLX' THEN
            l_telex_code := 'TLX';
          WHEN p_bus_object.child_bo_code(i) = 'EMAIL' THEN
            l_email_code := 'EMAIL';
          WHEN p_bus_object.child_bo_code(i) = 'WEB' THEN
            l_web_code := 'WEB';
          ELSE
            null;
        END CASE;
      -- Get location object
      ELSIF(p_bus_object.business_object_code(i) = 'LOCATION' AND
            p_bus_object.user_mandated_flag(i) = 'Y' AND
            p_bus_object.tca_mandated_flag(i) = 'N' AND
            p_bus_object.child_bo_code(i) IS NULL) THEN
        IF p_bus_object.entity_name(i) = 'HZ_LOCATIONS_EXT_VL' THEN
          l_loc_ext := TRUE;
        END IF;
      END IF;
    END LOOP;

    IF(l_phone_code IS NOT NULL OR l_telex_code IS NOT NULL OR
       l_email_code IS NOT NULL OR l_web_code IS NOT NULL) THEN
      get_cp_from_rec(
        p_phone_code         => l_phone_code,
        p_email_code         => l_email_code,
        p_telex_code         => l_telex_code,
        p_web_code           => l_web_code,
        p_edi_code           => NULL,
        p_eft_code           => NULL,
        p_sms_code           => NULL,
        p_bus_object         => p_bus_object,
        x_bus_object         => l_cp_bus_object
      );
    END IF;

    FOR i IN 1..p_ps_objs.COUNT LOOP
      IF(p_ps_objs(i).location_obj IS NULL) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
        fnd_message.set_token('OBJECT' ,'LOCATION');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_psu AND
        (p_ps_objs(i).party_site_use_objs IS NULL OR
         p_ps_objs(i).party_site_use_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'PARTY_SITE_USE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_cpref AND
         (p_ps_objs(i).contact_pref_objs IS NULL OR
          p_ps_objs(i).contact_pref_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'PARTY_SITE: CONTACT_PREFERENCE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_ps_ext AND
         (p_ps_objs(i).ext_attributes_objs IS NULL OR
          p_ps_objs(i).ext_attributes_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'PARTY_SITE: EXTENSIBILITY');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_loc_ext AND
         (p_ps_objs(i).location_obj.ext_attributes_objs IS NULL OR
          p_ps_objs(i).location_obj.ext_attributes_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'LOCATION: EXTENSIBILITY');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_phone_code IS NOT NULL OR l_telex_code IS NOT NULL OR
         l_email_code IS NOT NULL OR l_web_code IS NOT NULL) THEN
        -- check contact point business object for party site
        l_valid_obj := is_cp_bo_comp(
                         p_phone_objs             => p_ps_objs(i).phone_objs,
                         p_email_objs             => p_ps_objs(i).email_objs,
                         p_telex_objs             => p_ps_objs(i).telex_objs,
                         p_web_objs               => p_ps_objs(i).web_objs,
                         p_edi_objs               => NULL,
                         p_eft_objs               => NULL,
                         p_sms_objs               => NULL,
                         p_bus_object             => l_cp_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;
    END LOOP;

    RETURN TRUE;
  END is_ps_bo_comp;

-- FUNCTION is_person_bo_comp
--
-- DESCRIPTION
--     Return true if person object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_person_obj             Person business objects.
--     p_bus_object             Business object structure for person.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION is_person_bo_comp(
    p_person_obj              IN     HZ_PERSON_BO,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
  ) RETURN BOOLEAN IS
    l_bus_object              COMPLETENESS_REC_TYPE;
    l_cp_bus_object           COMPLETENESS_REC_TYPE;
    l_ps_bus_object           COMPLETENESS_REC_TYPE;
    l_valid_obj               BOOLEAN;

    l_pref                    BOOLEAN;
    l_rel                     BOOLEAN;
    l_class                   BOOLEAN;
    l_lang                    BOOLEAN;
    l_edu                     BOOLEAN;
    l_citiz                   BOOLEAN;
    l_emp_hist                BOOLEAN;
    l_work_class              BOOLEAN;
    l_int                     BOOLEAN;
    l_cert                    BOOLEAN;
    l_fin_prof                BOOLEAN;
    l_cpref                   BOOLEAN;
    l_ps                      BOOLEAN;
    l_ext                     BOOLEAN;

    l_phone_code              VARCHAR2(30);
    l_email_code              VARCHAR2(30);
    l_web_code                VARCHAR2(30);
    l_sms_code                VARCHAR2(30);
  BEGIN
    l_pref         := FALSE;
    l_rel          := FALSE;
    l_class        := FALSE;
    l_lang         := FALSE;
    l_edu          := FALSE;
    l_citiz        := FALSE;
    l_emp_hist     := FALSE;
    l_work_class   := FALSE;
    l_int          := FALSE;
    l_cert         := FALSE;
    l_fin_prof     := FALSE;
    l_cpref        := FALSE;
    l_ps           := FALSE;
    l_ext          := FALSE;

    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      -- get all entities of person, for person, the possible entites are
      -- HZ_PARTY_PREFERENCES, HZ_RELATIONSHIPS, HZ_CODE_ASSIGNMENTS,
      -- HZ_PERSON_LANGUAGE, HZ_EDUCATION, HZ_CITIZENSHIP, HZ_EMPLOYMENT_HISTORY
      -- HZ_PERSON_INTEREST, HZ_CERTIFICATIONS, HZ_FINANCIAL_PROFILE,
      -- HZ_CONTACT_PREFERENCES
      IF(p_bus_object.tca_mandated_flag(i) = 'N' AND
         p_bus_object.user_mandated_flag(i) = 'Y' AND
         p_bus_object.business_object_code(i) = 'PERSON' AND
         p_bus_object.child_bo_code(i) IS NULL) THEN
        CASE
          WHEN p_bus_object.entity_name(i) = 'HZ_PARTY_PREFERENCES' THEN
            l_pref := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_RELATIONSHIPS' THEN
            l_rel := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_CODE_ASSIGNMENTS' THEN
            l_class := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_PERSON_LANGUAGE' THEN
            l_lang := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_EDUCATION' THEN
            l_edu := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_CITIZENSHIP' THEN
            l_citiz := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_PERSON_INTEREST' THEN
            l_int := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_CERTIFICATIONS' THEN
            l_cert := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_FINANCIAL_PROFILE' THEN
            l_fin_prof := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_CONTACT_PREFERENCES' THEN
            l_cpref := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_PER_PROFILES_EXT_VL' THEN
            l_ext := TRUE;
        END CASE;
      ELSIF(p_bus_object.child_bo_code(i) IS NOT NULL AND
            p_bus_object.business_object_code(i) = 'PERSON' AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        CASE
          WHEN p_bus_object.child_bo_code(i) = 'PHONE' THEN
            l_phone_code := 'PHONE';
          WHEN p_bus_object.child_bo_code(i) = 'EMAIL' THEN
            l_email_code := 'EMAIL';
          WHEN p_bus_object.child_bo_code(i) = 'WEB' THEN
            l_web_code := 'WEB';
          WHEN p_bus_object.child_bo_code(i) = 'SMS' THEN
            l_sms_code := 'SMS';
          WHEN p_bus_object.child_bo_code(i) = 'PARTY_SITE' THEN
            l_ps := TRUE;
          WHEN p_bus_object.child_bo_code(i) = 'EMP_HIST' THEN
            l_emp_hist := TRUE;
        END CASE;
      ELSIF(p_bus_object.business_object_code(i) = 'EMP_HIST' AND
            p_bus_object.entity_name(i) = 'HZ_WORK_CLASS' AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        l_work_class := TRUE;
      END IF;
    END LOOP;

    IF(l_phone_code IS NOT NULL OR l_email_code IS NOT NULL OR
       l_web_code IS NOT NULL OR l_sms_code IS NOT NULL) THEN
      get_cp_from_rec(
        p_phone_code         => l_phone_code,
        p_email_code         => l_email_code,
        p_telex_code         => NULL,
        p_web_code           => l_web_code,
        p_edi_code           => NULL,
        p_eft_code           => NULL,
        p_sms_code           => l_sms_code,
        p_bus_object         => p_bus_object,
        x_bus_object         => l_cp_bus_object
      );
    END IF;

    IF(l_ps) THEN
      get_ps_from_rec(
        p_bus_object         => p_bus_object,
        x_bus_object         => l_ps_bus_object
      );
    END IF;

      IF(l_pref AND
        (p_person_obj.preference_objs IS NULL OR
         p_person_obj.preference_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'PARTY_PREFERENCE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_class AND
        (p_person_obj.class_objs IS NULL OR
         p_person_obj.class_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'CLASSIFICATION');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_lang AND
        (p_person_obj.language_objs IS NULL OR
         p_person_obj.language_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'LANGUAGE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_edu AND
        (p_person_obj.education_objs IS NULL OR
         p_person_obj.education_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'EDUCATION');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_citiz AND
        (p_person_obj.citizenship_objs IS NULL OR
         p_person_obj.citizenship_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'CITIZENSHIP');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_emp_hist AND
        (p_person_obj.employ_hist_objs IS NULL OR
         p_person_obj.employ_hist_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'EMPLOYMENT_HISTORY');
        fnd_msg_pub.add;
        RETURN FALSE;
        FOR j IN 1..p_person_obj.employ_hist_objs.COUNT LOOP
          IF(l_work_class AND
            (p_person_obj.employ_hist_objs(j).work_class_objs IS NULL OR
             p_person_obj.employ_hist_objs(j).work_class_objs.COUNT < 1)) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
            fnd_message.set_token('OBJECT' ,'WORK_CLASS');
            fnd_msg_pub.add;
            RETURN FALSE;
          END IF;
        END LOOP;
      END IF;
      IF(l_int AND
        (p_person_obj.interest_objs IS NULL OR
         p_person_obj.interest_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'PERSON_INTEREST');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_cert AND
        (p_person_obj.certification_objs IS NULL OR
         p_person_obj.certification_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'CERTIFICATION');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_fin_prof AND
        (p_person_obj.financial_prof_objs IS NULL OR
         p_person_obj.financial_prof_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'FINANCIAL_PROFILE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_rel AND
        (p_person_obj.relationship_objs IS NULL OR
         p_person_obj.relationship_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'RELATIONSHIP');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_cpref AND
        (p_person_obj.contact_pref_objs IS NULL OR
         p_person_obj.contact_pref_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'PERSON: CONTACT_PREFERENCE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_ext AND
        (p_person_obj.ext_attributes_objs IS NULL OR
         p_person_obj.ext_attributes_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'PERSON: EXTENSIBILITY');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_phone_code IS NOT NULL OR l_email_code IS NOT NULL OR
         l_web_code IS NOT NULL OR l_sms_code IS NOT NULL) THEN
        -- check contact point business object for person
        l_valid_obj := is_cp_bo_comp(
                         p_phone_objs             => p_person_obj.phone_objs,
                         p_email_objs             => p_person_obj.email_objs,
                         p_telex_objs             => NULL,
                         p_web_objs               => p_person_obj.web_objs,
                         p_edi_objs               => NULL,
                         p_eft_objs               => NULL,
                         p_sms_objs               => p_person_obj.sms_objs,
                         p_bus_object             => l_cp_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;
      IF(l_ps) THEN
        -- check contact point business object for person
        l_valid_obj := is_ps_bo_comp(
                         p_ps_objs                => p_person_obj.party_site_objs,
                         p_bus_object             => l_ps_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;

    RETURN TRUE;
  END is_person_bo_comp;

-- FUNCTION is_oc_bo_comp
--
-- DESCRIPTION
--     Return true if org contact object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_oc_objs                List of organization contact business objects.
--     p_bus_object             Business object structure for organization contact.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION is_oc_bo_comp(
    p_oc_objs                 IN     HZ_ORG_CONTACT_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
  ) RETURN BOOLEAN IS
    l_bus_object              COMPLETENESS_REC_TYPE;
    l_cp_bus_object           COMPLETENESS_REC_TYPE;
    l_ps_bus_object           COMPLETENESS_REC_TYPE;
    l_per_bus_object          COMPLETENESS_REC_TYPE;
    l_valid_obj               BOOLEAN;

    l_ocr                     BOOLEAN;
    l_cpref                   BOOLEAN;
    l_ps                      BOOLEAN;

    l_phone_code              VARCHAR2(30);
    l_telex_code              VARCHAR2(30);
    l_email_code              VARCHAR2(30);
    l_web_code                VARCHAR2(30);
    l_sms_code                VARCHAR2(30);
  BEGIN
    -- For org contact, person bo is a must and person only has one
    -- object, not a list of object
    l_ocr    := FALSE;
    l_cpref  := FALSE;
    l_ps     := FALSE;

    IF(p_oc_objs IS NULL OR p_oc_objs.COUNT < 1) THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
      fnd_message.set_token('OBJECT' ,'ORG_CONTACT');
      fnd_msg_pub.add;
      RETURN FALSE;
    END IF;

    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      -- get all entities of org contact, for org contact, the possible entites are
      -- HZ_ORG_CONTACT_ROLES
      IF(p_bus_object.tca_mandated_flag(i) = 'N' AND
         p_bus_object.user_mandated_flag(i) = 'Y' AND
         p_bus_object.business_object_code(i) = 'ORG_CONTACT' AND
         p_bus_object.child_bo_code(i) IS NULL) THEN
        IF(p_bus_object.entity_name(i) = 'HZ_ORG_CONTACT_ROLES') THEN
          l_ocr := TRUE;
        ELSIF(p_bus_object.entity_name(i) = 'HZ_CONTACT_PREFERENCES') THEN
          l_cpref := TRUE;
        END IF;
      -- Get contact point business object
      ELSIF(p_bus_object.child_bo_code(i) IS NOT NULL AND
            p_bus_object.business_object_code(i) = 'ORG_CONTACT' AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        CASE
          WHEN p_bus_object.child_bo_code(i) = 'PHONE' THEN
            l_phone_code := 'PHONE';
          WHEN p_bus_object.child_bo_code(i) = 'TLX' THEN
            l_telex_code := 'TLX';
          WHEN p_bus_object.child_bo_code(i) = 'EMAIL' THEN
            l_email_code := 'EMAIL';
          WHEN p_bus_object.child_bo_code(i) = 'WEB' THEN
            l_web_code := 'WEB';
          WHEN p_bus_object.child_bo_code(i) = 'SMS' THEN
            l_sms_code := 'SMS';
          WHEN p_bus_object.child_bo_code(i) = 'PARTY_SITE' THEN
            l_ps := TRUE;
          ELSE
            null;
        END CASE;
      END IF;
    END LOOP;

    IF(l_phone_code IS NOT NULL OR l_telex_code IS NOT NULL OR
       l_email_code IS NOT NULL OR l_web_code IS NOT NULL OR
       l_sms_code IS NOT NULL) THEN
      get_cp_from_rec(
        p_phone_code         => l_phone_code,
        p_email_code         => l_email_code,
        p_telex_code         => l_telex_code,
        p_web_code           => l_web_code,
        p_edi_code           => NULL,
        p_eft_code           => NULL,
        p_sms_code           => l_sms_code,
        p_bus_object         => p_bus_object,
        x_bus_object         => l_cp_bus_object
      );
    END IF;

    IF(l_ps) THEN
      get_ps_from_rec(
        p_bus_object         => p_bus_object,
        x_bus_object         => l_ps_bus_object
      );
    END IF;

    FOR i IN 1..p_oc_objs.COUNT LOOP
      IF(p_oc_objs(i).person_profile_obj IS NULL) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'PERSON_CONTACT');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;

      IF(l_ocr AND
        (p_oc_objs(i).org_contact_role_objs IS NULL OR
         p_oc_objs(i).org_contact_role_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'ORG_CONTACT_ROLE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_cpref AND
         (p_oc_objs(i).contact_pref_objs IS NULL OR
          p_oc_objs(i).contact_pref_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'ORG_CONTACT: CONTACT_PREFERENCE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;

      IF(l_phone_code IS NOT NULL OR l_telex_code IS NOT NULL OR
         l_email_code IS NOT NULL OR l_web_code IS NOT NULL OR
         l_sms_code IS NOT NULL) THEN
        -- check contact point business object for org contact
        l_valid_obj := is_cp_bo_comp(
                         p_phone_objs             => p_oc_objs(i).phone_objs,
                         p_email_objs             => p_oc_objs(i).email_objs,
                         p_telex_objs             => p_oc_objs(i).telex_objs,
                         p_web_objs               => p_oc_objs(i).web_objs,
                         p_edi_objs               => NULL,
                         p_eft_objs               => NULL,
                         p_sms_objs               => p_oc_objs(i).sms_objs,
                         p_bus_object             => l_cp_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;
      IF(l_ps) THEN
        -- check contact point business object for org contact
        l_valid_obj := is_ps_bo_comp(
                         p_ps_objs                => p_oc_objs(i).party_site_objs,
                         p_bus_object             => l_ps_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;
    END LOOP;

    RETURN TRUE;
  END is_oc_bo_comp;

-- FUNCTION is_org_bo_comp
--
-- DESCRIPTION
--     Return true if organization object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_organization_obj       Organization business objects.
--     p_bus_object             Business object structure for organization.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION is_org_bo_comp(
    p_organization_obj        IN     HZ_ORGANIZATION_BO,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
  ) RETURN BOOLEAN IS
    l_bus_object              COMPLETENESS_REC_TYPE;
    l_cp_bus_object           COMPLETENESS_REC_TYPE;
    l_ps_bus_object           COMPLETENESS_REC_TYPE;
    l_oc_bus_object           COMPLETENESS_REC_TYPE;
    l_valid_obj               BOOLEAN;

    l_pref                    BOOLEAN;
    l_credit                  BOOLEAN;
    l_rel                     BOOLEAN;
    l_class                   BOOLEAN;
    l_fin_report              BOOLEAN;
    l_cpref                   BOOLEAN;
    l_cert                    BOOLEAN;
    l_fin_prof                BOOLEAN;
    l_ps                      BOOLEAN;
    l_oc                      BOOLEAN;
    l_ext                     BOOLEAN;

    l_phone_code              VARCHAR2(30);
    l_telex_code              VARCHAR2(30);
    l_email_code              VARCHAR2(30);
    l_web_code                VARCHAR2(30);
    l_edi_code                VARCHAR2(30);
    l_eft_code                VARCHAR2(30);
  BEGIN
    l_pref       := FALSE;
    l_credit     := FALSE;
    l_rel        := FALSE;
    l_class      := FALSE;
    l_fin_report := FALSE;
    l_cpref      := FALSE;
    l_cert       := FALSE;
    l_fin_prof   := FALSE;
    l_ps         := FALSE;
    l_oc         := FALSE;
    l_ext        := FALSE;

    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      -- get all entities of org, for org, the possible entites are
      -- HZ_PARTY_PREFERENCES, HZ_CREDIT_RATINGS, HZ_RELATIONSHIPS,
      -- HZ_CODE_ASSIGNMENTS, HZ_FINANCIAL_REPORTS, HZ_FINANCIAL_NUMBERS,
      -- HZ_CERTIFICATIONS, HZ_FINANCIAL_PROFILE, HZ_CONTACT_PREFERENCES
      IF(p_bus_object.tca_mandated_flag(i) = 'N' AND
         p_bus_object.user_mandated_flag(i) = 'Y' AND
         p_bus_object.business_object_code(i) = 'ORG' AND
         p_bus_object.child_bo_code(i) IS NULL) THEN
        CASE
          WHEN p_bus_object.entity_name(i) = 'HZ_PARTY_PREFERENCES' THEN
            l_pref := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_CREDIT_RATINGS' THEN
            l_credit := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_RELATIONSHIPS' THEN
            l_rel := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_CODE_ASSIGNMENTS' THEN
            l_class := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_CERTIFICATIONS' THEN
            l_cert := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_FINANCIAL_PROFILE' THEN
            l_fin_prof := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_CONTACT_PREFERENCES' THEN
            l_cpref := TRUE;
          WHEN p_bus_object.entity_name(i) = 'HZ_ORG_PROFILES_EXT_VL' THEN
            l_ext := TRUE;
        END CASE;
      ELSIF(p_bus_object.child_bo_code(i) IS NOT NULL AND
            p_bus_object.business_object_code(i) = 'ORG' AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        CASE
          WHEN p_bus_object.child_bo_code(i) = 'PHONE' THEN
            l_phone_code := 'PHONE';
          WHEN p_bus_object.child_bo_code(i) = 'TLX' THEN
            l_telex_code := 'TLX';
          WHEN p_bus_object.child_bo_code(i) = 'EMAIL' THEN
            l_email_code := 'EMAIL';
          WHEN p_bus_object.child_bo_code(i) = 'WEB' THEN
            l_web_code := 'WEB';
          WHEN p_bus_object.child_bo_code(i) = 'EDI' THEN
            l_edi_code := 'EDI';
          WHEN p_bus_object.child_bo_code(i) = 'EFT' THEN
            l_eft_code := 'EFT';
          WHEN p_bus_object.child_bo_code(i) = 'PARTY_SITE' THEN
            l_ps := TRUE;
          WHEN p_bus_object.child_bo_code(i) = 'ORG_CONTACT' THEN
            l_oc := TRUE;
          WHEN p_bus_object.child_bo_code(i) = 'FIN_REPORT' THEN
            l_fin_report := TRUE;
        END CASE;
      END IF;
    END LOOP;

    IF(l_phone_code IS NOT NULL OR l_telex_code IS NOT NULL OR
       l_email_code IS NOT NULL OR l_web_code IS NOT NULL OR
       l_edi_code IS NOT NULL OR l_eft_code IS NOT NULL) THEN
      get_cp_from_rec(
        p_phone_code         => l_phone_code,
        p_email_code         => l_email_code,
        p_telex_code         => l_telex_code,
        p_web_code           => l_web_code,
        p_edi_code           => l_edi_code,
        p_eft_code           => l_eft_code,
        p_sms_code           => NULL,
        p_bus_object         => p_bus_object,
        x_bus_object         => l_cp_bus_object
      );
    END IF;

    IF(l_ps) THEN
      get_ps_from_rec(
        p_bus_object         => p_bus_object,
        x_bus_object         => l_ps_bus_object
      );
    END IF;

    IF(l_oc) THEN
      get_bus_obj_struct(
        p_bus_object_code    => 'ORG_CONTACT',
        x_bus_object         => l_oc_bus_object
      );
    END IF;

      IF(l_pref AND
        (p_organization_obj.preference_objs IS NULL OR
         p_organization_obj.preference_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'PARTY_PREFERENCE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_credit AND
        (p_organization_obj.credit_rating_objs IS NULL OR
         p_organization_obj.credit_rating_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'CREDIT_RATING');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_rel AND
        (p_organization_obj.relationship_objs IS NULL OR
         p_organization_obj.relationship_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'RELATIONSHIP');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_class AND
        (p_organization_obj.class_objs IS NULL OR
         p_organization_obj.class_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'CLASSIFICATION');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_fin_report AND
        (p_organization_obj.financial_report_objs IS NULL OR
         p_organization_obj.financial_report_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'FINANCIAL_REPORT');
        fnd_msg_pub.add;
        RETURN FALSE;

        -- financial report always require financial number
        FOR j IN 1..p_organization_obj.financial_report_objs.COUNT LOOP
          IF(p_organization_obj.financial_report_objs(j).financial_number_objs IS NULL OR
             p_organization_obj.financial_report_objs(j).financial_number_objs.COUNT < 1) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
            fnd_message.set_token('OBJECT' ,'FINANCIAL_NUMBER');
            fnd_msg_pub.add;
            RETURN FALSE;
          END IF;
        END LOOP;
      END IF;
      IF(l_cert AND
        (p_organization_obj.certification_objs IS NULL OR
         p_organization_obj.certification_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'CERTIFICATION');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_fin_prof AND
        (p_organization_obj.financial_prof_objs IS NULL OR
         p_organization_obj.financial_prof_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'FINANCIAL_PROFILE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_cpref AND
        (p_organization_obj.contact_pref_objs IS NULL OR
         p_organization_obj.contact_pref_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'ORG: CONTACT_PREFERENCE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_ext AND
        (p_organization_obj.ext_attributes_objs IS NULL OR
         p_organization_obj.ext_attributes_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'ORG: EXTENSIBILITY');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;

      IF(l_phone_code IS NOT NULL OR l_telex_code IS NOT NULL OR
         l_email_code IS NOT NULL OR l_web_code IS NOT NULL OR
         l_edi_code IS NOT NULL OR l_eft_code IS NOT NULL) THEN
        -- check contact point business object for org
        l_valid_obj := is_cp_bo_comp(
                         p_phone_objs  => p_organization_obj.phone_objs,
                         p_email_objs  => p_organization_obj.email_objs,
                         p_telex_objs  => p_organization_obj.telex_objs,
                         p_web_objs    => p_organization_obj.web_objs,
                         p_edi_objs    => p_organization_obj.edi_objs,
                         p_eft_objs    => p_organization_obj.eft_objs,
                         p_sms_objs    => NULL,
                         p_bus_object  => l_cp_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;

      IF(l_ps) THEN
        -- check party site business object for org
        l_valid_obj := is_ps_bo_comp(
                         p_ps_objs     => p_organization_obj.party_site_objs,
                         p_bus_object  => l_ps_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;

      IF(l_oc) THEN
        -- check org contact business object for org
        l_valid_obj := is_oc_bo_comp(
                         p_oc_objs     => p_organization_obj.contact_objs,
                         p_bus_object  => l_oc_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;

    RETURN TRUE;
  END is_org_bo_comp;

-- FUNCTION is_cac_bo_comp
--
-- DESCRIPTION
--     Return true if customer account contact object is complete.
--     Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cac_objs               List of customer account contact business objects.
--     p_bus_object             Business object structure for customer account contact.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION is_cac_bo_comp(
    p_cac_objs                IN     HZ_CUST_ACCT_CONTACT_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
  ) RETURN BOOLEAN IS
    l_valid_obj               BOOLEAN;
    l_rr                      BOOLEAN;
  BEGIN
    l_rr := FALSE;

    IF(p_cac_objs IS NULL OR p_cac_objs.COUNT < 1) THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
      fnd_message.set_token('OBJECT' ,'CUST_ACCT_CONTACT');
      fnd_msg_pub.add;
      RETURN FALSE;
    END IF;

    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      -- get all entities of cust acct contact, for cust acct contact, the possible entites are
      -- HZ_ROLE_RESPONSIBILITY
      IF(p_bus_object.tca_mandated_flag(i) = 'N' AND
         p_bus_object.user_mandated_flag(i) = 'Y' AND
         p_bus_object.business_object_code(i) = 'CUST_ACCT_CONTACT' AND
         p_bus_object.child_bo_code(i) IS NULL) THEN
        IF(p_bus_object.entity_name(i) = 'HZ_ROLE_RESPONSIBILITY') THEN
            l_rr := TRUE;
        END IF;
      END IF;
    END LOOP;

    FOR i IN 1..p_cac_objs.COUNT LOOP
      -- Check role responsibility objects
      IF(l_rr AND
        (p_cac_objs(i).contact_role_objs IS NULL OR
         p_cac_objs(i).contact_role_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'ROLE_RESPONSIBILITY');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
    END LOOP;

    RETURN TRUE;
  END is_cac_bo_comp;

-- FUNCTION is_cas_bo_comp
--
-- DESCRIPTION
--     Return true if customer account site object is complete.
--     Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cas_objs               List of customer account site business objects.
--     p_bus_object             Business object structure for customer account site.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION is_cas_bo_comp(
    p_cas_objs                IN     HZ_CUST_ACCT_SITE_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
  ) RETURN BOOLEAN IS
    l_valid_obj               BOOLEAN;
    l_casu                    BOOLEAN;
    l_cp                      BOOLEAN;
    l_cac                     BOOLEAN;
    l_cpa                     BOOLEAN;
    l_bau                     BOOLEAN;
    l_pm                      BOOLEAN;
    l_cac_bus_object          COMPLETENESS_REC_TYPE;
  BEGIN
    l_casu := FALSE;
    l_cp   := FALSE;
    l_cpa  := FALSE;
    l_cac  := FALSE;
    l_bau  := FALSE;
    l_pm   := FALSE;

    IF(p_cas_objs IS NULL OR p_cas_objs.COUNT < 1) THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
      fnd_message.set_token('OBJECT' ,'CUST_ACCT_SITE');
      fnd_msg_pub.add;
      RETURN FALSE;
    END IF;

    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      -- no entities of cust acct site
      IF(p_bus_object.child_bo_code(i) IS NOT NULL AND
         p_bus_object.business_object_code(i) = 'CUST_ACCT_SITE' AND
         p_bus_object.user_mandated_flag(i) = 'Y') THEN
        CASE
          WHEN(p_bus_object.child_bo_code(i) = 'CUST_ACCT_SITE_USE' AND
               p_bus_object.business_object_code(i) = 'CUST_ACCT_SITE') THEN
            l_casu := TRUE;
          WHEN(p_bus_object.child_bo_code(i) = 'CUST_ACCT_CONTACT' AND
               p_bus_object.business_object_code(i) = 'CUST_ACCT_SITE') THEN
            l_cac := TRUE;
        END CASE;
      ELSIF(p_bus_object.tca_mandated_flag(i) = 'N' AND
         p_bus_object.user_mandated_flag(i) = 'Y' AND
         p_bus_object.business_object_code(i) = 'CUST_ACCT_SITE_USE' AND
         p_bus_object.child_bo_code(i) IS NULL) THEN
        CASE
          WHEN(p_bus_object.entity_name(i) = 'RA_CUST_RECEIPT_METHODS') THEN
            l_pm := TRUE;
          WHEN(p_bus_object.entity_name(i) = 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V') THEN
            l_bau := TRUE;
        END CASE;
      ELSIF(p_bus_object.child_bo_code(i) = 'CUST_PROFILE' AND
            p_bus_object.business_object_code(i) = 'CUST_ACCT_SITE_USE' AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        l_cp := TRUE;
      ELSIF(p_bus_object.entity_name(i) = 'HZ_CUST_PROFILE_AMTS' AND
            p_bus_object.business_object_code(i) = 'CUST_PROFILE' AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        l_cpa := TRUE;
      END IF;
    END LOOP;

    IF(l_cac) THEN
      get_bus_obj_struct(
        p_bus_object_code    => 'CUST_ACCT_CONTACT',
        x_bus_object         => l_cac_bus_object
      );
    END IF;

    FOR i IN 1..p_cas_objs.COUNT LOOP
      IF(l_cac) THEN
        l_valid_obj := is_cac_bo_comp(
                         p_cac_objs    => p_cas_objs(i).cust_acct_contact_objs,
                         p_bus_object  => l_cac_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;

      IF(l_casu AND
        (p_cas_objs(i).cust_acct_site_use_objs IS NULL OR
         p_cas_objs(i).cust_acct_site_use_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'CUST_ACCT_SITE_USE');
        fnd_msg_pub.add;
        RETURN FALSE;

        FOR j IN 1..p_cas_objs(i).cust_acct_site_use_objs.COUNT LOOP
          IF(l_cp AND p_cas_objs(i).cust_acct_site_use_objs(j).site_use_profile_obj IS NULL) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
            fnd_message.set_token('OBJECT' ,'SITE_USE_PROFILE');
            fnd_msg_pub.add;
            RETURN FALSE;
          END IF;
          IF(l_cpa AND
            (p_cas_objs(i).cust_acct_site_use_objs(j).site_use_profile_obj.cust_profile_amt_objs IS NULL OR
             p_cas_objs(i).cust_acct_site_use_objs(j).site_use_profile_obj.cust_profile_amt_objs.COUNT < 1)) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
            fnd_message.set_token('OBJECT' ,'SITE_USE_PROFILE_AMOUNT');
            fnd_msg_pub.add;
            RETURN FALSE;
          END IF;
          -- for bank account use and payment method
          IF(l_bau AND
            (p_cas_objs(i).cust_acct_site_use_objs(j).bank_acct_use_objs IS NULL OR
             p_cas_objs(i).cust_acct_site_use_objs(j).bank_acct_use_objs.COUNT < 1)) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
            fnd_message.set_token('OBJECT' ,'BANK_ACCOUNT');
            fnd_msg_pub.add;
            RETURN FALSE;
          END IF;
          IF(l_pm AND
            (p_cas_objs(i).cust_acct_site_use_objs(j).payment_method_obj IS NULL)) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
            fnd_message.set_token('OBJECT' ,'PAYMENT_METHOD');
            fnd_msg_pub.add;
            RETURN FALSE;
          END IF;
        END LOOP;
      END IF;
    END LOOP;

    RETURN TRUE;
  END is_cas_bo_comp;

-- FUNCTION is_ca_bo_comp
--
-- DESCRIPTION
--     Return true if customer account object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_ca_objs                List of customer account business objects.
--     p_bus_object             Business object structure for customer account.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION is_ca_bo_comp(
    p_ca_objs                 IN     HZ_CUST_ACCT_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
  ) RETURN BOOLEAN IS
    l_valid_obj               BOOLEAN;
    l_carel                   BOOLEAN;
    l_cas                     BOOLEAN;
    l_cac                     BOOLEAN;
    l_cp                      BOOLEAN;
    l_cpa                     BOOLEAN;
    l_bau                     BOOLEAN;
    l_pm                      BOOLEAN;
    l_cas_bus_object          COMPLETENESS_REC_TYPE;
    l_cac_bus_object          COMPLETENESS_REC_TYPE;
  BEGIN
    l_carel := FALSE;
    l_cas   := FALSE;
    l_cac   := FALSE;
    l_cp    := FALSE;
    l_cpa   := FALSE;
    l_bau   := FALSE;
    l_pm    := FALSE;

    IF(p_ca_objs IS NULL OR p_ca_objs.COUNT < 1) THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
      fnd_message.set_token('OBJECT' ,'CUST_ACCT');
      fnd_msg_pub.add;
      RETURN FALSE;
    END IF;

    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      -- get all entities of cust acct, for cust acct, the possible entites are
      -- HZ_BANK_ACCOUNT_USE, HZ_PAYMENT_METHOD, HZ_CUST_ACCT_RELATE
      IF(p_bus_object.tca_mandated_flag(i) = 'N' AND
         p_bus_object.user_mandated_flag(i) = 'Y' AND
         p_bus_object.business_object_code(i) = 'CUST_ACCT' AND
         p_bus_object.child_bo_code(i) IS NULL) THEN
        CASE
          WHEN(p_bus_object.entity_name(i) = 'HZ_CUST_ACCT_RELATE_ALL') THEN
            l_carel := TRUE;
          WHEN(p_bus_object.entity_name(i) = 'RA_CUST_RECEIPT_METHODS') THEN
            l_pm := TRUE;
          WHEN(p_bus_object.entity_name(i) = 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V') THEN
            l_bau := TRUE;
        END CASE;
      -- Get other business object
      ELSIF(p_bus_object.child_bo_code(i) IS NOT NULL AND
            p_bus_object.business_object_code(i) = 'CUST_ACCT' AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        CASE
          WHEN (p_bus_object.child_bo_code(i) = 'CUST_ACCT_SITE') THEN
            l_cas := TRUE;
          WHEN (p_bus_object.child_bo_code(i) = 'CUST_ACCT_CONTACT') THEN
            l_cac := TRUE;
          ELSE
            null;
        END CASE;
      ELSIF(p_bus_object.child_bo_code(i) IS NOT NULL AND
            p_bus_object.business_object_code(i) = 'CUST_PROFILE' AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        IF(p_bus_object.entity_name(i) = 'HZ_CUST_PROFILE_AMTS') THEN
          l_cpa := TRUE;
        END IF;
      END IF;
    END LOOP;

    -- customer profile is mandatory for customer account
    l_cp := TRUE;

    IF(l_cas) THEN
      get_bus_obj_struct(
        p_bus_object_code    => 'CUST_ACCT_SITE',
        x_bus_object         => l_cas_bus_object
      );
    END IF;

    IF(l_cac) THEN
      get_bus_obj_struct(
        p_bus_object_code    => 'CUST_ACCT_CONTACT',
        x_bus_object         => l_cac_bus_object
      );
    END IF;

    FOR i IN 1..p_ca_objs.COUNT LOOP
      IF(l_cas) THEN
        l_valid_obj := is_cas_bo_comp(
                         p_cas_objs    => p_ca_objs(i).cust_acct_site_objs,
                         p_bus_object  => l_cas_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;

      IF(l_cac) THEN
        l_valid_obj := is_cac_bo_comp(
                         p_cac_objs    => p_ca_objs(i).cust_acct_contact_objs,
                         p_bus_object  => l_cac_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;

      IF(l_carel AND
        (p_ca_objs(i).acct_relate_objs IS NULL OR
         p_ca_objs(i).acct_relate_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'CUSTOMER_ACCOUNT_RELATE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;

-- for bank account use and payment method
      IF(l_bau AND
        (p_ca_objs(i).bank_acct_use_objs IS NULL OR
         p_ca_objs(i).bank_acct_use_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'BANK_ACCOUNT');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_pm AND
        (p_ca_objs(i).payment_method_obj IS NULL)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'PAYMENT_METHOD');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;

      IF(l_cp AND p_ca_objs(i).cust_profile_obj IS NULL) THEN
        RETURN FALSE;
      ELSE
        IF(l_cpa AND
          (p_ca_objs(i).cust_profile_obj.cust_profile_amt_objs IS NULL OR
           p_ca_objs(i).cust_profile_obj.cust_profile_amt_objs.COUNT < 1)) THEN
          fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
          fnd_message.set_token('OBJECT' ,'CUSTOMER_PROFILE_AMOUNT');
          fnd_msg_pub.add;
          RETURN FALSE;
        END IF;
      END IF;
    END LOOP;

    RETURN TRUE;
  END is_ca_bo_comp;

-- FUNCTION is_pca_bo_comp
--
-- DESCRIPTION
--     Return true if person customer object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_person_obj             Person business object.
--     p_ca_objs                List of customer account objects.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION is_pca_bo_comp(
    p_person_obj              IN     HZ_PERSON_BO,
    p_ca_objs                 IN     HZ_CUST_ACCT_BO_TBL
  ) RETURN BOOLEAN IS
    l_per_bus_object          COMPLETENESS_REC_TYPE;
    l_ca_bus_object           COMPLETENESS_REC_TYPE;
    l_valid_obj               BOOLEAN;
  BEGIN
    IF(p_person_obj IS NULL) THEN
      RETURN FALSE;
    END IF;
    IF(p_ca_objs IS NULL OR p_ca_objs.COUNT < 1) THEN
      RETURN FALSE;
    END IF;

    -- check person object for person cust acct
    get_bus_obj_struct(
      p_bus_object_code         => 'PERSON',
      x_bus_object              => l_per_bus_object
    );
    l_valid_obj := is_person_bo_comp(
                     p_person_obj  => p_person_obj,
                     p_bus_object  => l_per_bus_object
                   );
    IF NOT(l_valid_obj) THEN
      RETURN FALSE;
    END IF;

    -- check cust account for person cust acct
    get_bus_obj_struct(
      p_bus_object_code         => 'CUST_ACCT',
      x_bus_object              => l_ca_bus_object
    );
    l_valid_obj := is_ca_bo_comp(
                     p_ca_objs    => p_ca_objs,
                     p_bus_object => l_ca_bus_object
                   );
    IF NOT(l_valid_obj) THEN
      RETURN FALSE;
    END IF;

    RETURN TRUE;
  END is_pca_bo_comp;

-- FUNCTION is_oca_bo_comp
--
-- DESCRIPTION
--     Return true if organization customer object is complete.
--     Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_org_obj                Organization business object.
--     p_ca_objs                List of customer account objects.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION is_oca_bo_comp(
    p_org_obj                 IN     HZ_ORGANIZATION_BO,
    p_ca_objs                 IN     HZ_CUST_ACCT_BO_TBL
  ) RETURN BOOLEAN IS
    l_org_bus_object          COMPLETENESS_REC_TYPE;
    l_ca_bus_object           COMPLETENESS_REC_TYPE;
    l_valid_obj               BOOLEAN;
  BEGIN
    IF(p_org_obj IS NULL) THEN
      RETURN FALSE;
    END IF;
    IF(p_ca_objs IS NULL OR p_ca_objs.COUNT < 1) THEN
      RETURN FALSE;
    END IF;

    -- check organization object for org cust acct
    get_bus_obj_struct(
      p_bus_object_code         => 'ORG',
      x_bus_object              => l_org_bus_object
    );
    l_valid_obj := is_org_bo_comp(
                     p_organization_obj => p_org_obj,
                     p_bus_object       => l_org_bus_object
                   );
    IF NOT(l_valid_obj) THEN
      RETURN FALSE;
    END IF;

    -- check cust account for org cust acct
    get_bus_obj_struct(
      p_bus_object_code         => 'CUST_ACCT',
      x_bus_object              => l_ca_bus_object
    );
    l_valid_obj := is_ca_bo_comp(
                     p_ca_objs          => p_ca_objs,
                     p_bus_object       => l_ca_bus_object
                   );
    IF NOT(l_valid_obj) THEN
      RETURN FALSE;
    END IF;

    RETURN TRUE;
  END is_oca_bo_comp;

-- FUNCTION get_bus_object_struct
--
-- DESCRIPTION
--     Get contact point business object structure.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_bus_object_code        Business object code, such as 'PARTY_SITE',
--                              'ORG_CONTACT'
--   OUT:
--     x_bus_object             Business object structure.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE get_bus_obj_struct(
    p_bus_object_code         IN         VARCHAR2,
    x_bus_object              OUT NOCOPY COMPLETENESS_REC_TYPE
  ) IS
    CURSOR get_bus_obj(l_bus_obj VARCHAR2) IS
    SELECT d.business_object_code, d.child_bo_code, d.tca_mandated_flag,
           d.user_mandated_flag, d.root_node_flag, d.entity_name
    FROM hz_bus_obj_definitions d
    start with d.business_object_code = l_bus_obj and d.user_mandated_flag = 'Y'
    connect by prior d.child_bo_code = d.business_object_code and d.user_mandated_flag = 'Y'
    group by d.business_object_code, d.child_bo_code, d.tca_mandated_flag,
             d.user_mandated_flag, d.root_node_flag, d.entity_name;
  BEGIN
    OPEN get_bus_obj(p_bus_object_code);
    FETCH get_bus_obj BULK COLLECT
      INTO x_bus_object.business_object_code,
           x_bus_object.child_bo_code,
           x_bus_object.tca_mandated_flag,
           x_bus_object.user_mandated_flag,
           x_bus_object.root_node_flag,
           x_bus_object.entity_name;
    CLOSE get_bus_obj;
  END get_bus_obj_struct;

-- FUNCTION get_cp_bus_obj_struct
--
-- DESCRIPTION
--     Get contact point business object structure.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_phone_code             'PHONE'.
--     p_email_code             'EMAIL'.
--     p_telex_code             'TLX'.
--     p_web_code               'WEB'.
--     p_edi_code               'EDI'.
--     p_eft_code               'EFT'.
--     p_sms_code               'SMS'.
--   OUT:
--     x_bus_object             Contact point business object structure.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE get_cp_bus_obj_struct(
    p_phone_code              IN         VARCHAR2,
    p_email_code              IN         VARCHAR2,
    p_telex_code              IN         VARCHAR2,
    p_web_code                IN         VARCHAR2,
    p_edi_code                IN         VARCHAR2,
    p_eft_code                IN         VARCHAR2,
    p_sms_code                IN         VARCHAR2,
    x_bus_object              OUT NOCOPY COMPLETENESS_REC_TYPE
  ) IS
    CURSOR get_cp_bus_obj(l_phone VARCHAR2, l_email VARCHAR2,
                          l_telex VARCHAR2, l_web VARCHAR2, l_edi VARCHAR2,
                          l_eft VARCHAR2, l_sms VARCHAR2) IS
    SELECT d.business_object_code, d.child_bo_code, d.tca_mandated_flag,
           d.user_mandated_flag, d.root_node_flag, d.entity_name
    FROM hz_bus_obj_definitions d
    start with d.business_object_code in (l_phone, l_email, l_telex, l_web, l_edi, l_eft, l_sms) and d.user_mandated_flag = 'Y'
    connect by prior d.child_bo_code = d.business_object_code
                and d.user_mandated_flag = 'Y'
    group by d.business_object_code, d.child_bo_code, d.tca_mandated_flag,
             d.user_mandated_flag, d.root_node_flag, d.entity_name;
  BEGIN
    OPEN get_cp_bus_obj(p_phone_code, p_email_code, p_telex_code,
                        p_web_code, p_edi_code, p_eft_code, p_sms_code);
    FETCH get_cp_bus_obj BULK COLLECT
      INTO x_bus_object.business_object_code,
           x_bus_object.child_bo_code,
           x_bus_object.tca_mandated_flag,
           x_bus_object.user_mandated_flag,
           x_bus_object.root_node_flag,
           x_bus_object.entity_name;
    CLOSE get_cp_bus_obj;
  END get_cp_bus_obj_struct;

-- PRIVATE PROCEDURE get_cp_from_rec
--
-- DESCRIPTION
--     Extract business object structure of contact point.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_phone_code             'PHONE'.
--     p_email_code             'EMAIL'.
--     p_telex_code             'TLX'.
--     p_web_code               'WEB'.
--     p_edi_code               'EDI'.
--     p_eft_code               'EFT'.
--     p_sms_code               'SMS'.
--   OUT:
--     x_bus_object             Business object structure of contact point.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE get_cp_from_rec(
    p_phone_code              IN         VARCHAR2,
    p_email_code              IN         VARCHAR2,
    p_telex_code              IN         VARCHAR2,
    p_web_code                IN         VARCHAR2,
    p_edi_code                IN         VARCHAR2,
    p_eft_code                IN         VARCHAR2,
    p_sms_code                IN         VARCHAR2,
    p_bus_object              IN         COMPLETENESS_REC_TYPE,
    x_bus_object              OUT NOCOPY COMPLETENESS_REC_TYPE
  ) IS
    l_count                   NUMBER;
  BEGIN
    l_count := 0;
    x_bus_object.business_object_code := boc_tbl();
    x_bus_object.child_bo_code := cbc_tbl();
    x_bus_object.tca_mandated_flag := tmf_tbl();
    x_bus_object.user_mandated_flag := umf_tbl();
    x_bus_object.root_node_flag := rnf_tbl();
    x_bus_object.entity_name := ent_tbl();
    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      IF(p_bus_object.business_object_code(i) = p_phone_code OR
         p_bus_object.business_object_code(i) = p_email_code OR
         p_bus_object.business_object_code(i) = p_telex_code OR
         p_bus_object.business_object_code(i) = p_web_code OR
         p_bus_object.business_object_code(i) = p_edi_code OR
         p_bus_object.business_object_code(i) = p_eft_code OR
         p_bus_object.business_object_code(i) = p_sms_code) THEN
          l_count := l_count + 1;
          x_bus_object.business_object_code.EXTEND;
          x_bus_object.child_bo_code.EXTEND;
          x_bus_object.tca_mandated_flag.EXTEND;
          x_bus_object.user_mandated_flag.EXTEND;
          x_bus_object.root_node_flag.EXTEND;
          x_bus_object.entity_name.EXTEND;
          x_bus_object.business_object_code(l_count) := p_bus_object.business_object_code(i);
          x_bus_object.child_bo_code(l_count) := p_bus_object.child_bo_code(i);
          x_bus_object.tca_mandated_flag(l_count) := p_bus_object.tca_mandated_flag(i);
          x_bus_object.user_mandated_flag(l_count) := p_bus_object.user_mandated_flag(i);
          x_bus_object.root_node_flag(l_count) := p_bus_object.root_node_flag(i);
          x_bus_object.entity_name(l_count) := p_bus_object.entity_name(i);
      END IF;
    END LOOP;
  END get_cp_from_rec;

-- PRIVATE PROCEDURE get_ps_from_rec
--
-- DESCRIPTION
--     Extract business object structure of party site.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_bus_object             Business object structure.
--   OUT:
--     x_bus_object             Business object structure of party site.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  PROCEDURE get_ps_from_rec(
    p_bus_object              IN         COMPLETENESS_REC_TYPE,
    x_bus_object              OUT NOCOPY COMPLETENESS_REC_TYPE
  ) IS
    l_count                   NUMBER;
    l_phone                   VARCHAR2(30);
    l_telex                   VARCHAR2(30);
    l_email                   VARCHAR2(30);
    l_web                     VARCHAR2(30);
    l_edi                     VARCHAR2(30);
    l_eft                     VARCHAR2(30);
    l_sms                     VARCHAR2(30);
  BEGIN
    l_count := 0;
    x_bus_object.business_object_code := boc_tbl();
    x_bus_object.child_bo_code := cbc_tbl();
    x_bus_object.tca_mandated_flag := tmf_tbl();
    x_bus_object.user_mandated_flag := umf_tbl();
    x_bus_object.root_node_flag := rnf_tbl();
    x_bus_object.entity_name := ent_tbl();
    -- find all rows related to PARTY_SITE
    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      IF(p_bus_object.business_object_code(i) = 'PARTY_SITE') THEN
        l_count := l_count + 1;
        x_bus_object.business_object_code.EXTEND;
        x_bus_object.child_bo_code.EXTEND;
        x_bus_object.tca_mandated_flag.EXTEND;
        x_bus_object.user_mandated_flag.EXTEND;
        x_bus_object.root_node_flag.EXTEND;
        x_bus_object.entity_name.EXTEND;
        x_bus_object.business_object_code(l_count) := p_bus_object.business_object_code(i);
        x_bus_object.child_bo_code(l_count) := p_bus_object.child_bo_code(i);
        x_bus_object.tca_mandated_flag(l_count) := p_bus_object.tca_mandated_flag(i);
        x_bus_object.user_mandated_flag(l_count) := p_bus_object.user_mandated_flag(i);
        x_bus_object.root_node_flag(l_count) := p_bus_object.root_node_flag(i);
        x_bus_object.entity_name(l_count) := p_bus_object.entity_name(i);
      END IF;
    END LOOP;

    -- find all PARTY_SITE rows with child_bo_code, all rows must be CONTACT POINT
    FOR i IN 1..x_bus_object.business_object_code.COUNT LOOP
      IF(x_bus_object.child_bo_code(i) IS NOT NULL) THEN
        CASE
          WHEN x_bus_object.child_bo_code(i) = 'PHONE' THEN
            l_phone := x_bus_object.child_bo_code(i);
          WHEN x_bus_object.child_bo_code(i) = 'TLX' THEN
            l_telex := x_bus_object.child_bo_code(i);
          WHEN x_bus_object.child_bo_code(i) = 'EMAIL' THEN
            l_email := x_bus_object.child_bo_code(i);
          WHEN x_bus_object.child_bo_code(i) = 'WEB' THEN
            l_web := x_bus_object.child_bo_code(i);
          WHEN x_bus_object.child_bo_code(i) = 'EDI' THEN
            l_edi := x_bus_object.child_bo_code(i);
          WHEN x_bus_object.child_bo_code(i) = 'EFT' THEN
            l_eft := x_bus_object.child_bo_code(i);
          WHEN x_bus_object.child_bo_code(i) = 'SMS' THEN
            l_sms := x_bus_object.child_bo_code(i);
          ELSE -- for 'LOCATION'
            NULL;
        END CASE;
      END IF;
    END LOOP;

    -- find all contact point rows for PARTY_SITE
    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      IF(p_bus_object.business_object_code(i) = l_phone OR
         p_bus_object.business_object_code(i) = l_telex OR
         p_bus_object.business_object_code(i) = l_email OR
         p_bus_object.business_object_code(i) = l_web OR
         p_bus_object.business_object_code(i) = l_edi OR
         p_bus_object.business_object_code(i) = l_eft OR
         p_bus_object.business_object_code(i) = l_sms) THEN
        l_count := l_count + 1;
        x_bus_object.business_object_code.EXTEND;
        x_bus_object.child_bo_code.EXTEND;
        x_bus_object.tca_mandated_flag.EXTEND;
        x_bus_object.user_mandated_flag.EXTEND;
        x_bus_object.root_node_flag.EXTEND;
        x_bus_object.entity_name.EXTEND;
        x_bus_object.business_object_code(l_count) := p_bus_object.business_object_code(i);
        x_bus_object.child_bo_code(l_count) := p_bus_object.child_bo_code(i);
        x_bus_object.tca_mandated_flag(l_count) := p_bus_object.tca_mandated_flag(i);
        x_bus_object.user_mandated_flag(l_count) := p_bus_object.user_mandated_flag(i);
        x_bus_object.root_node_flag(l_count) := p_bus_object.root_node_flag(i);
        x_bus_object.entity_name(l_count) := p_bus_object.entity_name(i);
      END IF;
    END LOOP;
  END get_ps_from_rec;

-- FUNCTION get_id_from_ososr
--
-- DESCRIPTION
--     Get TCA Id based on original system and original system reference.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_os                     Original system
--     p_osr                    Original system reference
--     p_owner_table_name       Owner table name
-- NOTES
--
-- MODIFICATION HISTORY
--
--   13-Jul-2005    Arnold Ng   o Created.

  FUNCTION get_id_from_ososr(
    p_os                 IN VARCHAR2,
    p_osr                IN VARCHAR2,
    p_owner_table_name   IN VARCHAR2
  ) RETURN NUMBER IS
    l_count              NUMBER;
    l_owner_table_id     NUMBER;
    l_return_status      VARCHAR2(30);
  BEGIN
    l_count := HZ_MOSR_VALIDATE_PKG.get_orig_system_ref_count(
                 p_orig_system           => p_os,
                 p_orig_system_reference => p_osr,
                 p_owner_table_name      => p_owner_table_name);

    IF(l_count = 1) THEN
      -- Get owner_table_id
      HZ_ORIG_SYSTEM_REF_PUB.get_owner_table_id(
        p_orig_system           => p_os,
        p_orig_system_reference => p_osr,
        p_owner_table_name      => p_owner_table_name,
        x_owner_table_id        => l_owner_table_id,
        x_return_status         => l_return_status);
    END IF;

    RETURN l_owner_table_id;
  END get_id_from_ososr;

-- FUNCTION is_cas_v2_bo_comp
--
-- DESCRIPTION
--     Return true if customer account site object is complete.
--     Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_cas_v2_objs               List of customer account site business objects.
--     p_bus_object             Business object structure for customer account site.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   1-FEB-2008    vsegu   o Created.

  FUNCTION is_cas_v2_bo_comp(
    p_cas_v2_objs                IN     HZ_CUST_ACCT_SITE_V2_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
  ) RETURN BOOLEAN IS
    l_valid_obj               BOOLEAN;
    l_casu                    BOOLEAN;
    l_cp                      BOOLEAN;
    l_cac                     BOOLEAN;
    l_cpa                     BOOLEAN;
    l_bau                     BOOLEAN;
    l_pm                      BOOLEAN;
    l_cac_bus_object          COMPLETENESS_REC_TYPE;
  BEGIN
    l_casu := FALSE;
    l_cp   := FALSE;
    l_cpa  := FALSE;
    l_cac  := FALSE;
    l_bau  := FALSE;
    l_pm   := FALSE;

    IF(p_cas_v2_objs IS NULL OR p_cas_v2_objs.COUNT < 1) THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
      fnd_message.set_token('OBJECT' ,'CUST_ACCT_SITE');
      fnd_msg_pub.add;
      RETURN FALSE;
    END IF;

    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      -- no entities of cust acct site
      IF(p_bus_object.child_bo_code(i) IS NOT NULL AND
         p_bus_object.business_object_code(i) = 'CUST_ACCT_SITE' AND
         p_bus_object.user_mandated_flag(i) = 'Y') THEN
        CASE
          WHEN(p_bus_object.child_bo_code(i) = 'CUST_ACCT_SITE_USE' AND
               p_bus_object.business_object_code(i) = 'CUST_ACCT_SITE') THEN
            l_casu := TRUE;
          WHEN(p_bus_object.child_bo_code(i) = 'CUST_ACCT_CONTACT' AND
               p_bus_object.business_object_code(i) = 'CUST_ACCT_SITE') THEN
            l_cac := TRUE;
        END CASE;
      ELSIF(p_bus_object.tca_mandated_flag(i) = 'N' AND
         p_bus_object.user_mandated_flag(i) = 'Y' AND
         p_bus_object.business_object_code(i) = 'CUST_ACCT_SITE_USE' AND
         p_bus_object.child_bo_code(i) IS NULL) THEN
        CASE
          WHEN(p_bus_object.entity_name(i) = 'RA_CUST_RECEIPT_METHODS') THEN
            l_pm := TRUE;
          WHEN(p_bus_object.entity_name(i) = 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V') THEN
            l_bau := TRUE;
        END CASE;
      ELSIF(p_bus_object.child_bo_code(i) = 'CUST_PROFILE' AND
            p_bus_object.business_object_code(i) = 'CUST_ACCT_SITE_USE' AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        l_cp := TRUE;
      ELSIF(p_bus_object.entity_name(i) = 'HZ_CUST_PROFILE_AMTS' AND
            p_bus_object.business_object_code(i) = 'CUST_PROFILE' AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        l_cpa := TRUE;
      END IF;
    END LOOP;

    IF(l_cac) THEN
      get_bus_obj_struct(
        p_bus_object_code    => 'CUST_ACCT_CONTACT',
        x_bus_object         => l_cac_bus_object
      );
    END IF;

    FOR i IN 1..p_cas_v2_objs.COUNT LOOP
      IF(l_cac) THEN
        l_valid_obj := is_cac_bo_comp(
                         p_cac_objs    => p_cas_v2_objs(i).cust_acct_contact_objs,
                         p_bus_object  => l_cac_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;

      IF(l_casu AND
        (p_cas_v2_objs(i).cust_acct_site_use_objs IS NULL OR
         p_cas_v2_objs(i).cust_acct_site_use_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'CUST_ACCT_SITE_USE');
        fnd_msg_pub.add;
        RETURN FALSE;

        FOR j IN 1..p_cas_v2_objs(i).cust_acct_site_use_objs.COUNT LOOP
          IF(l_cp AND p_cas_v2_objs(i).cust_acct_site_use_objs(j).site_use_profile_obj IS NULL) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
            fnd_message.set_token('OBJECT' ,'SITE_USE_PROFILE');
            fnd_msg_pub.add;
            RETURN FALSE;
          END IF;
          IF(l_cpa AND
            (p_cas_v2_objs(i).cust_acct_site_use_objs(j).site_use_profile_obj.cust_profile_amt_objs IS NULL OR
             p_cas_v2_objs(i).cust_acct_site_use_objs(j).site_use_profile_obj.cust_profile_amt_objs.COUNT < 1)) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
            fnd_message.set_token('OBJECT' ,'SITE_USE_PROFILE_AMOUNT');
            fnd_msg_pub.add;
            RETURN FALSE;
          END IF;
          -- for bank account use and payment method
          IF(l_bau AND
            (p_cas_v2_objs(i).cust_acct_site_use_objs(j).bank_acct_use_objs IS NULL OR
             p_cas_v2_objs(i).cust_acct_site_use_objs(j).bank_acct_use_objs.COUNT < 1)) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
            fnd_message.set_token('OBJECT' ,'BANK_ACCOUNT');
            fnd_msg_pub.add;
            RETURN FALSE;
          END IF;
          IF(l_pm AND
            (p_cas_v2_objs(i).cust_acct_site_use_objs(j).payment_method_objs IS NULL OR
             p_cas_v2_objs(i).cust_acct_site_use_objs(j).payment_method_objs.COUNT < 1)) THEN
            fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
            fnd_message.set_token('OBJECT' ,'PAYMENT_METHOD');
            fnd_msg_pub.add;
            RETURN FALSE;
          END IF;
        END LOOP;
      END IF;
    END LOOP;

    RETURN TRUE;
  END is_cas_v2_bo_comp;

-- FUNCTION is_ca_v2_bo_comp
--
-- DESCRIPTION
--     Return true if customer account object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_ca_v2_objs                List of customer account business objects.
--     p_bus_object             Business object structure for customer account.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   1-FEB-2008    vsegu   o Created.

  FUNCTION is_ca_v2_bo_comp(
    p_ca_v2_objs                 IN     HZ_CUST_ACCT_V2_BO_TBL,
    p_bus_object              IN     COMPLETENESS_REC_TYPE
  ) RETURN BOOLEAN IS
    l_valid_obj               BOOLEAN;
    l_carel                   BOOLEAN;
    l_cas                     BOOLEAN;
    l_cac                     BOOLEAN;
    l_cp                      BOOLEAN;
    l_cpa                     BOOLEAN;
    l_bau                     BOOLEAN;
    l_pm                      BOOLEAN;
    l_cas_bus_object          COMPLETENESS_REC_TYPE;
    l_cac_bus_object          COMPLETENESS_REC_TYPE;
  BEGIN
    l_carel := FALSE;
    l_cas   := FALSE;
    l_cac   := FALSE;
    l_cp    := FALSE;
    l_cpa   := FALSE;
    l_bau   := FALSE;
    l_pm    := FALSE;

    IF(p_ca_v2_objs IS NULL OR p_ca_v2_objs.COUNT < 1) THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_OBJ');
      fnd_message.set_token('OBJECT' ,'CUST_ACCT');
      fnd_msg_pub.add;
      RETURN FALSE;
    END IF;

    FOR i IN 1..p_bus_object.business_object_code.COUNT LOOP
      -- get all entities of cust acct, for cust acct, the possible entites are
      -- HZ_BANK_ACCOUNT_USE, HZ_PAYMENT_METHOD, HZ_CUST_ACCT_RELATE
      IF(p_bus_object.tca_mandated_flag(i) = 'N' AND
         p_bus_object.user_mandated_flag(i) = 'Y' AND
         p_bus_object.business_object_code(i) = 'CUST_ACCT' AND
         p_bus_object.child_bo_code(i) IS NULL) THEN
        CASE
          WHEN(p_bus_object.entity_name(i) = 'HZ_CUST_ACCT_RELATE_ALL') THEN
            l_carel := TRUE;
          WHEN(p_bus_object.entity_name(i) = 'RA_CUST_RECEIPT_METHODS') THEN
            l_pm := TRUE;
          WHEN(p_bus_object.entity_name(i) = 'IBY_FNDCPT_PAYER_ASSGN_INSTR_V') THEN
            l_bau := TRUE;
        END CASE;
      -- Get other business object
      ELSIF(p_bus_object.child_bo_code(i) IS NOT NULL AND
            p_bus_object.business_object_code(i) = 'CUST_ACCT' AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        CASE
          WHEN (p_bus_object.child_bo_code(i) = 'CUST_ACCT_SITE') THEN
            l_cas := TRUE;
          WHEN (p_bus_object.child_bo_code(i) = 'CUST_ACCT_CONTACT') THEN
            l_cac := TRUE;
          ELSE
            null;
        END CASE;
      ELSIF(p_bus_object.child_bo_code(i) IS NOT NULL AND
            p_bus_object.business_object_code(i) = 'CUST_PROFILE' AND
            p_bus_object.user_mandated_flag(i) = 'Y') THEN
        IF(p_bus_object.entity_name(i) = 'HZ_CUST_PROFILE_AMTS') THEN
          l_cpa := TRUE;
        END IF;
      END IF;
    END LOOP;

    -- customer profile is mandatory for customer account
    l_cp := TRUE;

    IF(l_cas) THEN
      get_bus_obj_struct(
        p_bus_object_code    => 'CUST_ACCT_SITE',
        x_bus_object         => l_cas_bus_object
      );
    END IF;

    IF(l_cac) THEN
      get_bus_obj_struct(
        p_bus_object_code    => 'CUST_ACCT_CONTACT',
        x_bus_object         => l_cac_bus_object
      );
    END IF;

    FOR i IN 1..p_ca_v2_objs.COUNT LOOP
      IF(l_cas) THEN
        l_valid_obj := is_cas_v2_bo_comp(
                         p_cas_v2_objs    => p_ca_v2_objs(i).cust_acct_site_objs,
                         p_bus_object  => l_cas_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;

      IF(l_cac) THEN
        l_valid_obj := is_cac_bo_comp(
                         p_cac_objs    => p_ca_v2_objs(i).cust_acct_contact_objs,
                         p_bus_object  => l_cac_bus_object
                       );
        IF NOT(l_valid_obj) THEN
          RETURN FALSE;
        END IF;
      END IF;

      IF(l_carel AND
        (p_ca_v2_objs(i).acct_relate_objs IS NULL OR
         p_ca_v2_objs(i).acct_relate_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'CUSTOMER_ACCOUNT_RELATE');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;

-- for bank account use and payment method
      IF(l_bau AND
        (p_ca_v2_objs(i).bank_acct_use_objs IS NULL OR
         p_ca_v2_objs(i).bank_acct_use_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'BANK_ACCOUNT');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;
      IF(l_pm AND
        (p_ca_v2_objs(i).payment_method_objs IS NULL OR
         p_ca_v2_objs(i).payment_method_objs.COUNT < 1)) THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
        fnd_message.set_token('OBJECT' ,'PAYMENT_METHOD');
        fnd_msg_pub.add;
        RETURN FALSE;
      END IF;

      IF(l_cp AND p_ca_v2_objs(i).cust_profile_obj IS NULL) THEN
        RETURN FALSE;
      ELSE
        IF(l_cpa AND
          (p_ca_v2_objs(i).cust_profile_obj.cust_profile_amt_objs IS NULL OR
           p_ca_v2_objs(i).cust_profile_obj.cust_profile_amt_objs.COUNT < 1)) THEN
          fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
          fnd_message.set_token('OBJECT' ,'CUSTOMER_PROFILE_AMOUNT');
          fnd_msg_pub.add;
          RETURN FALSE;
        END IF;
      END IF;
    END LOOP;

    RETURN TRUE;
  END is_ca_v2_bo_comp;

-- FUNCTION is_pca_v2_bo_comp
--
-- DESCRIPTION
--     Return true if person customer object is complete.  Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_person_obj             Person business object.
--     p_ca_v2_objs             List of customer account objects.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   1-FEB-2008    vsegu   o Created.

  FUNCTION is_pca_v2_bo_comp(
    p_person_obj              IN     HZ_PERSON_BO,
    p_ca_v2_objs              IN     HZ_CUST_ACCT_V2_BO_TBL
  ) RETURN BOOLEAN IS
    l_per_bus_object          COMPLETENESS_REC_TYPE;
    l_ca_bus_object           COMPLETENESS_REC_TYPE;
    l_valid_obj               BOOLEAN;
  BEGIN
    IF(p_person_obj IS NULL) THEN
      RETURN FALSE;
    END IF;
    IF(p_ca_v2_objs IS NULL OR p_ca_v2_objs.COUNT < 1) THEN
      RETURN FALSE;
    END IF;

    -- check person object for person cust acct
    get_bus_obj_struct(
      p_bus_object_code         => 'PERSON',
      x_bus_object              => l_per_bus_object
    );
    l_valid_obj := is_person_bo_comp(
                     p_person_obj  => p_person_obj,
                     p_bus_object  => l_per_bus_object
                   );
    IF NOT(l_valid_obj) THEN
      RETURN FALSE;
    END IF;

    -- check cust account for person cust acct
    get_bus_obj_struct(
      p_bus_object_code         => 'CUST_ACCT',
      x_bus_object              => l_ca_bus_object
    );
    l_valid_obj := is_ca_v2_bo_comp(
                     p_ca_v2_objs    => p_ca_v2_objs,
                     p_bus_object => l_ca_bus_object
                   );
    IF NOT(l_valid_obj) THEN
      RETURN FALSE;
    END IF;

    RETURN TRUE;
  END is_pca_v2_bo_comp;

-- FUNCTION is_oca_v2_bo_comp
--
-- DESCRIPTION
--     Return true if organization customer object is complete.
--     Otherwise, return false.
--
-- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS
--   IN:
--     p_org_obj                Organization business object.
--     p_ca_v2_objs                List of customer account objects.
-- NOTES
--
-- MODIFICATION HISTORY
--
--   1-FEB-2008    vsegu   o Created.

  FUNCTION is_oca_v2_bo_comp(
    p_org_obj                 IN     HZ_ORGANIZATION_BO,
    p_ca_v2_objs              IN     HZ_CUST_ACCT_V2_BO_TBL
  ) RETURN BOOLEAN IS
    l_org_bus_object          COMPLETENESS_REC_TYPE;
    l_ca_bus_object           COMPLETENESS_REC_TYPE;
    l_valid_obj               BOOLEAN;
  BEGIN
    IF(p_org_obj IS NULL) THEN
      RETURN FALSE;
    END IF;
    IF(p_ca_v2_objs IS NULL OR p_ca_v2_objs.COUNT < 1) THEN
      RETURN FALSE;
    END IF;

    -- check organization object for org cust acct
    get_bus_obj_struct(
      p_bus_object_code         => 'ORG',
      x_bus_object              => l_org_bus_object
    );
    l_valid_obj := is_org_bo_comp(
                     p_organization_obj => p_org_obj,
                     p_bus_object       => l_org_bus_object
                   );
    IF NOT(l_valid_obj) THEN
      RETURN FALSE;
    END IF;

    -- check cust account for org cust acct
    get_bus_obj_struct(
      p_bus_object_code         => 'CUST_ACCT',
      x_bus_object              => l_ca_bus_object
    );
    l_valid_obj := is_ca_v2_bo_comp(
                     p_ca_v2_objs          => p_ca_v2_objs,
                     p_bus_object       => l_ca_bus_object
                   );
    IF NOT(l_valid_obj) THEN
      RETURN FALSE;
    END IF;

    RETURN TRUE;
  END is_oca_v2_bo_comp;

END HZ_REGISTRY_VALIDATE_BO_PVT;

/
