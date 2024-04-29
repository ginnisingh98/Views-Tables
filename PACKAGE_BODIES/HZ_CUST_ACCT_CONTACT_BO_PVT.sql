--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCT_CONTACT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCT_CONTACT_BO_PVT" AS
/*$Header: ARHBCRVB.pls 120.5 2006/05/18 22:24:24 acng noship $ */

  -- PRIVATE PROCEDURE assign_role_responsibility_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from role responsibility object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_role_responsibility_obj    Role responsibility object.
  --     p_cust_account_role_id       Customer account role Id.
  --   IN/OUT:
  --     px_role_responsibility_rec   Role responsibility plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_role_responsibility_rec(
    p_role_responsibility_obj    IN            HZ_ROLE_RESPONSIBILITY_OBJ,
    p_cust_account_role_id       IN            NUMBER,
    px_role_responsibility_rec   IN OUT NOCOPY HZ_CUST_ACCOUNT_ROLE_V2PUB.ROLE_RESPONSIBILITY_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_role_responsibility_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from role responsibility object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_role_responsibility_obj    Role responsibility object.
  --     p_cust_account_role_id       Customer account role Id.
  --   IN/OUT:
  --     px_role_responsibility_rec   Role responsibility plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_role_responsibility_rec(
    p_role_responsibility_obj    IN            HZ_ROLE_RESPONSIBILITY_OBJ,
    p_cust_account_role_id       IN            NUMBER,
    px_role_responsibility_rec   IN OUT NOCOPY HZ_CUST_ACCOUNT_ROLE_V2PUB.ROLE_RESPONSIBILITY_REC_TYPE
  ) IS
  BEGIN
    px_role_responsibility_rec.responsibility_id     := p_role_responsibility_obj.responsibility_id;
    px_role_responsibility_rec.cust_account_role_id  := p_cust_account_role_id;
    px_role_responsibility_rec.responsibility_type   := p_role_responsibility_obj.responsibility_type;
    IF(p_role_responsibility_obj.primary_flag in ('Y','N')) THEN
      px_role_responsibility_rec.primary_flag          := p_role_responsibility_obj.primary_flag;
    END IF;
    px_role_responsibility_rec.attribute_category    := p_role_responsibility_obj.attribute_category;
    px_role_responsibility_rec.attribute1            := p_role_responsibility_obj.attribute1;
    px_role_responsibility_rec.attribute2            := p_role_responsibility_obj.attribute2;
    px_role_responsibility_rec.attribute3            := p_role_responsibility_obj.attribute3;
    px_role_responsibility_rec.attribute4            := p_role_responsibility_obj.attribute4;
    px_role_responsibility_rec.attribute5            := p_role_responsibility_obj.attribute5;
    px_role_responsibility_rec.attribute6            := p_role_responsibility_obj.attribute6;
    px_role_responsibility_rec.attribute7            := p_role_responsibility_obj.attribute7;
    px_role_responsibility_rec.attribute8            := p_role_responsibility_obj.attribute8;
    px_role_responsibility_rec.attribute9            := p_role_responsibility_obj.attribute9;
    px_role_responsibility_rec.attribute10           := p_role_responsibility_obj.attribute10;
    px_role_responsibility_rec.attribute11           := p_role_responsibility_obj.attribute11;
    px_role_responsibility_rec.attribute12           := p_role_responsibility_obj.attribute12;
    px_role_responsibility_rec.attribute13           := p_role_responsibility_obj.attribute13;
    px_role_responsibility_rec.attribute14           := p_role_responsibility_obj.attribute14;
    px_role_responsibility_rec.attribute15           := p_role_responsibility_obj.attribute15;
    px_role_responsibility_rec.created_by_module     := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_role_responsibility_rec;

  -- PROCEDURE create_role_responsbilities
  --
  -- DESCRIPTION
  --     Create role responsibilities.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_rr_objs            List of role responsibility objects.
  --     p_cac_id             Customer account contact Id.
  --   OUT:
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
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_role_responsibilities(
    p_rr_objs                 IN OUT NOCOPY HZ_ROLE_RESPONSIBILITY_OBJ_TBL,
    p_cac_id                  IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_rr_id                   NUMBER;
    l_rr_rec                  HZ_CUST_ACCOUNT_ROLE_V2PUB.ROLE_RESPONSIBILITY_REC_TYPE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_rr_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_role_responsibilities(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create role responsibilities
    FOR i IN 1..p_rr_objs.COUNT LOOP
      assign_role_responsibility_rec(
        p_role_responsibility_obj   => p_rr_objs(i),
        p_cust_account_role_id      => p_cac_id,
        px_role_responsibility_rec  => l_rr_rec
      );

      HZ_CUST_ACCOUNT_ROLE_V2PUB.create_role_responsibility (
        p_role_responsibility_rec   => l_rr_rec,
        x_responsibility_id         => l_rr_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_contact_bo_pvt.create_role_responsibilities, cust acct contact id: '||p_cac_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      -- assign role_responsibility_id
      p_rr_objs(i).responsibility_id := l_rr_id;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_role_responsibilities(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_rr_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ROLE_RESPONSIBILITY');
      FND_MSG_PUB.ADD;

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
        hz_utility_v2pub.debug(p_message=>'create_role_responsibilities(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_rr_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ROLE_RESPONSIBILITY');
      FND_MSG_PUB.ADD;

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
        hz_utility_v2pub.debug(p_message=>'create_role_responsibilities(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_rr_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ROLE_RESPONSIBILITY');
      FND_MSG_PUB.ADD;

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
        hz_utility_v2pub.debug(p_message=>'create_role_responsibilities(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_role_responsibilities;

  -- PROCEDURE save_role_responsbilities
  --
  -- DESCRIPTION
  --     Create or update role responsibilities.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_rr_objs            List of role responsibility objects.
  --     p_cac_id             Customer account contact Id.
  --   OUT:
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
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_role_responsibilities(
    p_rr_objs                 IN OUT NOCOPY HZ_ROLE_RESPONSIBILITY_OBJ_TBL,
    p_cac_id                  IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_rr_id                    NUMBER;
    l_rr_rec                   HZ_CUST_ACCOUNT_ROLE_V2PUB.ROLE_RESPONSIBILITY_REC_TYPE;
    l_ovn                      NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_rr_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_role_responsibilities(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create/Update role responsibilities
    FOR i IN 1..p_rr_objs.COUNT LOOP
      assign_role_responsibility_rec(
        p_role_responsibility_obj   => p_rr_objs(i),
        p_cust_account_role_id      => p_cac_id,
        px_role_responsibility_rec  => l_rr_rec
      );

      -- check if the role resp record is create or update
      hz_registry_validate_bo_pvt.check_role_resp_op(
        p_cust_acct_contact_id     => p_cac_id,
        px_responsibility_id       => l_rr_rec.responsibility_id,
        p_responsibility_type      => l_rr_rec.responsibility_type,
        x_object_version_number    => l_ovn
      );

      IF (l_ovn = -1) THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_contact_bo_pvt.check_role_resp_op, cust acct contact id: '||p_cac_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ROLE_RESPONSIBILITY');
        FND_MSG_PUB.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF(l_ovn IS NULL) THEN
        HZ_CUST_ACCOUNT_ROLE_V2PUB.create_role_responsibility (
          p_role_responsibility_rec   => l_rr_rec,
          x_responsibility_id         => l_rr_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign role_responsibility_id
        p_rr_objs(i).responsibility_id := l_rr_id;
      ELSE
        -- clean up created_by_module for update
        l_rr_rec.created_by_module := NULL;
        HZ_CUST_ACCOUNT_ROLE_V2PUB.update_role_responsibility (
          p_role_responsibility_rec   => l_rr_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign role_responsibility_id
        p_rr_objs(i).responsibility_id := l_rr_rec.responsibility_id;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_contact_bo_pvt.save_role_responsibilities, cust acct contact id: '||p_cac_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_role_responsibilities(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_rr_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ROLE_RESPONSIBILITY');
      FND_MSG_PUB.ADD;

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
        hz_utility_v2pub.debug(p_message=>'save_role_responsibilities(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_rr_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ROLE_RESPONSIBILITY');
      FND_MSG_PUB.ADD;

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
        hz_utility_v2pub.debug(p_message=>'save_role_responsibilities(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_rr_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ROLE_RESPONSIBILITY');
      FND_MSG_PUB.ADD;

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
        hz_utility_v2pub.debug(p_message=>'save_role_responsibilities(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_role_responsibilities;

  -- PROCEDURE save_cust_acct_contacts
  --
  -- DESCRIPTION
  --     Create or update customer account contact.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cac_objs           List of customer account contact objects.
  --     p_create_update_flag Create or update flag.
  --     p_parent_id          Parent Id.
  --     p_parent_os          Parent original system.
  --     p_parent_osr         Parent original system reference.
  --     p_parent_obj_type    Parent object type.
  --   OUT:
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
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_cust_acct_contacts(
    p_cac_objs                IN OUT NOCOPY HZ_CUST_ACCT_CONTACT_BO_TBL,
    p_create_update_flag      IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    p_parent_id               IN            NUMBER,
    p_parent_os               IN            VARCHAR2,
    p_parent_osr              IN            VARCHAR2,
    p_parent_obj_type         IN            VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_cac_id                  NUMBER;
    l_cac_os                  VARCHAR2(30);
    l_cac_osr                 VARCHAR2(255);
    l_parent_id               NUMBER;
    l_parent_os               VARCHAR2(30);
    l_parent_osr              VARCHAR2(255);
    l_parent_obj_type         VARCHAR2(30);
    l_cbm                     VARCHAR2(30);
  BEGIN
    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_contacts(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_parent_id := p_parent_id;
    l_parent_os := p_parent_os;
    l_parent_osr := p_parent_osr;
    l_parent_obj_type := p_parent_obj_type;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    IF(p_create_update_flag = 'C') THEN
      -- Create cust account contact
      FOR i IN 1..p_cac_objs.COUNT LOOP
        HZ_CUST_ACCT_CONTACT_BO_PUB.do_create_cac_bo(
          p_init_msg_list           => fnd_api.g_false,
          p_validate_bo_flag        => fnd_api.g_false,
          p_cust_acct_contact_obj   => p_cac_objs(i),
          p_created_by_module       => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source              => p_obj_source,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          x_cust_acct_contact_id    => l_cac_id,
          x_cust_acct_contact_os    => l_cac_os,
          x_cust_acct_contact_osr   => l_cac_osr,
          px_parent_id              => l_parent_id,
          px_parent_os              => l_parent_os,
          px_parent_osr             => l_parent_osr,
          px_parent_obj_type        => l_parent_obj_type
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_contact_bo_pvt.save_cust_acct_contacts, parent id: '||l_parent_id||' '||l_parent_os||'-'||l_parent_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
      END LOOP;
    ELSE
      -- Create/update cust account contact
      FOR i IN 1..p_cac_objs.COUNT LOOP
        HZ_CUST_ACCT_CONTACT_BO_PUB.do_save_cac_bo(
          p_init_msg_list           => fnd_api.g_false,
          p_validate_bo_flag        => fnd_api.g_false,
          p_cust_acct_contact_obj   => p_cac_objs(i),
          p_created_by_module       => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source              => p_obj_source,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          x_cust_acct_contact_id    => l_cac_id,
          x_cust_acct_contact_os    => l_cac_os,
          x_cust_acct_contact_osr   => l_cac_osr,
          px_parent_id              => l_parent_id,
          px_parent_os              => l_parent_os,
          px_parent_osr             => l_parent_osr,
          px_parent_obj_type        => l_parent_obj_type
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_contact_bo_pvt.save_cust_acct_contacts, parent id: '||l_parent_id||' '||l_parent_os||'-'||l_parent_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
      END LOOP;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_contacts(-)',
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
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_contacts(-)',
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
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_contacts(-)',
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
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_contacts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_cust_acct_contacts;

END hz_cust_acct_contact_bo_pvt;

/
