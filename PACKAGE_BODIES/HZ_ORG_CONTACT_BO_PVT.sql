--------------------------------------------------------
--  DDL for Package Body HZ_ORG_CONTACT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORG_CONTACT_BO_PVT" AS
/*$Header: ARHBOCVB.pls 120.7.12000000.2 2007/02/22 23:35:33 awu ship $ */

  -- PRIVATE PROCEDURE assign_org_contact_role_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from org contact role object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_ocr_obj            Org contact role object.
  --     p_oc_id              Org contact Id.
  --     p_ocr_os             Org contact original system.
  --     p_ocr_osr            Org contact original system reference.
  --   IN/OUT:
  --     px_org_contact_role_rec   Org contact role plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_org_contact_role_rec(
    p_ocr_obj                    IN            HZ_ORG_CONTACT_ROLE_OBJ,
    p_oc_id                      IN            NUMBER,
    p_ocr_os                     IN            VARCHAR2,
    p_ocr_osr                    IN            VARCHAR2,
    px_org_contact_role_rec      IN OUT NOCOPY HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_org_contact_role_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from org contact role object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_ocr_obj            Org contact role object.
  --     p_oc_id              Org contact Id.
  --     p_ocr_os             Org contact original system.
  --     p_ocr_osr            Org contact original system reference.
  --   IN/OUT:
  --     px_org_contact_role_rec   Org contact role plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_org_contact_role_rec(
    p_ocr_obj                    IN            HZ_ORG_CONTACT_ROLE_OBJ,
    p_oc_id                      IN            NUMBER,
    p_ocr_os                     IN            VARCHAR2,
    p_ocr_osr                    IN            VARCHAR2,
    px_org_contact_role_rec      IN OUT NOCOPY HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE
  ) IS
  BEGIN
    px_org_contact_role_rec.org_contact_role_id           := p_ocr_obj.org_contact_role_id;
    px_org_contact_role_rec.role_type                     := p_ocr_obj.role_type;
    IF(p_ocr_obj.primary_flag in ('Y','N')) THEN
      px_org_contact_role_rec.primary_flag                  := p_ocr_obj.primary_flag;
    END IF;
    px_org_contact_role_rec.org_contact_id                := p_oc_id;
    px_org_contact_role_rec.orig_system                   := p_ocr_os;
    px_org_contact_role_rec.orig_system_reference         := p_ocr_osr;
    px_org_contact_role_rec.role_level                    := p_ocr_obj.role_level;
    px_org_contact_role_rec.primary_contact_per_role_type := p_ocr_obj.primary_contact_per_role_type;
    IF(p_ocr_obj.status in ('A','I')) THEN
      px_org_contact_role_rec.status                        := p_ocr_obj.status;
    END IF;
    px_org_contact_role_rec.created_by_module             := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_org_contact_role_rec;

  -- PROCEDURE create_org_contact_roles
  --
  -- DESCRIPTION
  --     Create org contact roles.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_ocr_objs           List of org contact role objects.
  --     p_oc_id              Org contact Id.
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

  PROCEDURE create_org_contact_roles(
    p_ocr_objs              IN OUT NOCOPY HZ_ORG_CONTACT_ROLE_OBJ_TBL,
    p_oc_id                 IN            NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_ocr_id              NUMBER;
    l_ocr_rec             HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_org_contact_roles_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_org_contact_roles(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create contact preferences
    IF(p_ocr_objs IS NOT NULL) THEN
      FOR i IN 1..p_ocr_objs.COUNT LOOP
        assign_org_contact_role_rec(
          p_ocr_obj                => p_ocr_objs(i),
          p_oc_id                  => p_oc_id,
          p_ocr_os                 => p_ocr_objs(i).orig_system,
          p_ocr_osr                => p_ocr_objs(i).orig_system_reference,
          px_org_contact_role_rec  => l_ocr_rec
        );

        HZ_PARTY_CONTACT_V2PUB.create_org_contact_role(
          p_org_contact_role_rec      => l_ocr_rec,
          x_org_contact_role_id       => l_ocr_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_org_contact_bo_pvt.create_org_contact_roles, org contact id: '||p_oc_id,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        -- assign org_contact_role_id
        p_ocr_objs(i).org_contact_role_id := l_ocr_id;
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
        hz_utility_v2pub.debug(p_message=>'create_org_contact_roles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_org_contact_roles_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ORG_CONTACT_ROLES');
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
        hz_utility_v2pub.debug(p_message=>'create_org_contact_roles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_org_contact_roles_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ORG_CONTACT_ROLES');
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
        hz_utility_v2pub.debug(p_message=>'create_org_contact_roles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO create_org_contact_roles_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ORG_CONTACT_ROLES');
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
        hz_utility_v2pub.debug(p_message=>'create_org_contact_roles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_org_contact_roles;

  -- PROCEDURE save_org_contact_roles
  --
  -- DESCRIPTION
  --     Create or update org contact roles.
  PROCEDURE save_org_contact_roles(
    p_ocr_objs                   IN OUT NOCOPY HZ_ORG_CONTACT_ROLE_OBJ_TBL,
    p_oc_id                      IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_ocr_id              NUMBER;
    l_ocr_rec             HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE;
    l_ovn                 NUMBER := NULL;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_org_contact_roles_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_org_contact_roles(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create/Update org contact roles
    IF(p_ocr_objs IS NOT NULL) THEN
      FOR i IN 1..p_ocr_objs.COUNT LOOP
        assign_org_contact_role_rec(
          p_ocr_obj               => p_ocr_objs(i),
          p_oc_id                 => p_oc_id,
          p_ocr_os                => p_ocr_objs(i).orig_system,
          p_ocr_osr               => p_ocr_objs(i).orig_system_reference,
          px_org_contact_role_rec => l_ocr_rec
        );

        -- check if the contact pref record is create or update
        hz_registry_validate_bo_pvt.check_org_contact_role_op(
          p_org_contact_id       => p_oc_id,
          px_org_contact_role_id => l_ocr_rec.org_contact_role_id,
          p_role_type            => l_ocr_rec.role_type,
          x_object_version_number => l_ovn
        );

        IF(l_ovn = -1) THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_org_contact_bo_pvt.check_org_contact_role_op, org contact id: '||p_oc_id,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
          FND_MSG_PUB.ADD;
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
          FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ORG_CONTACT_ROLES');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF(l_ocr_rec.org_contact_role_id IS NULL) THEN
          HZ_PARTY_CONTACT_V2PUB.create_org_contact_role(
            p_org_contact_role_rec      => l_ocr_rec,
            x_org_contact_role_id       => l_ocr_id,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
          );

          -- assign org_contact_role_id
          p_ocr_objs(i).org_contact_role_id := l_ocr_id;
        ELSE
          -- clean up created_by_module for update
          l_ocr_rec.created_by_module := NULL;
          HZ_PARTY_CONTACT_V2PUB.update_org_contact_role(
            p_org_contact_role_rec      => l_ocr_rec,
            p_object_version_number     => l_ovn,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
          );

          -- assign org_contact_role_id
          p_ocr_objs(i).org_contact_role_id := l_ocr_rec.org_contact_role_id;
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_org_contact_bo_pvt.save_org_contact_roles, org contact id: '||p_oc_id,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;
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
        hz_utility_v2pub.debug(p_message=>'save_org_contact_roles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_org_contact_roles_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ORG_CONTACT_ROLES');
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
        hz_utility_v2pub.debug(p_message=>'save_org_contact_roles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_org_contact_roles_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ORG_CONTACT_ROLES');
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
        hz_utility_v2pub.debug(p_message=>'save_org_contact_roles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO save_org_contact_roles_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_ORG_CONTACT_ROLES');
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
        hz_utility_v2pub.debug(p_message=>'save_org_contact_roles(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_org_contact_roles;

  -- PROCEDURE save_org_contacts
  --
  -- DESCRIPTION
  --     Create or update org contacts.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_oc_objs            List of org contact business objects.
  --     p_create_update_flag Create or update flag.
  --     p_parent_org_id      Parent organization Id.
  --     p_parent_org_os      Parent organization original system.
  --     p_parent_org_osr     Parent organization original system reference.
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

  PROCEDURE save_org_contacts(
    p_oc_objs             IN OUT NOCOPY HZ_ORG_CONTACT_BO_TBL,
    p_create_update_flag  IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    p_parent_org_id       IN OUT NOCOPY NUMBER,
    p_parent_org_os       IN OUT NOCOPY VARCHAR2,
    p_parent_org_osr      IN OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_oc_id               NUMBER;
    l_oc_os               VARCHAR2(30);
    l_oc_osr              VARCHAR2(255);
    l_parent_org_id       NUMBER;
    l_parent_org_os       VARCHAR2(30);
    l_parent_org_osr      VARCHAR2(255);
    l_cbm                 VARCHAR2(30);
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_org_contacts(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_parent_org_id := p_parent_org_id;
    l_parent_org_os := p_parent_org_os;
    l_parent_org_osr:= p_parent_org_osr;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    IF(p_create_update_flag = 'C') THEN
      -----------------------------
      -- Create logical org contact
      -----------------------------
      FOR i IN 1..p_oc_objs.COUNT LOOP
        HZ_ORG_CONTACT_BO_PUB.do_create_org_contact_bo(
          p_init_msg_list      => fnd_api.g_false,
          p_validate_bo_flag   => fnd_api.g_false,
          p_org_contact_obj    => p_oc_objs(i),
          p_created_by_module  => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source         => p_obj_source,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          x_org_contact_id     => l_oc_id,
          x_org_contact_os     => l_oc_os,
          x_org_contact_osr    => l_oc_osr,
          px_parent_org_id     => l_parent_org_id,
          px_parent_org_os     => l_parent_org_os,
          px_parent_org_osr    => l_parent_org_osr
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_org_contact_bo_pvt.save_org_contacts, parent id: '||l_parent_org_id||' '||l_parent_org_os||'-'||l_parent_org_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
      END LOOP;
    ELSE
      ------------------------------------
      -- Create/Update logical org contact
      ------------------------------------
      FOR i IN 1..p_oc_objs.COUNT LOOP
        HZ_ORG_CONTACT_BO_PUB.do_save_org_contact_bo(
          p_init_msg_list      => fnd_api.g_false,
          p_validate_bo_flag   => fnd_api.g_false,
          p_org_contact_obj    => p_oc_objs(i),
          p_created_by_module  => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source         => p_obj_source,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          x_org_contact_id     => l_oc_id,
          x_org_contact_os     => l_oc_os,
          x_org_contact_osr    => l_oc_osr,
          px_parent_org_id     => l_parent_org_id,
          px_parent_org_os     => l_parent_org_os,
          px_parent_org_osr    => l_parent_org_osr
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_org_contact_bo_pvt.save_org_contacts, parent id: '||l_parent_org_id||' '||l_parent_org_os||'-'||l_parent_org_osr,
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
        hz_utility_v2pub.debug(p_message=>'save_org_contacts(-)',
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
        hz_utility_v2pub.debug(p_message=>'save_org_contacts(-)',
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
        hz_utility_v2pub.debug(p_message=>'save_org_contacts(-)',
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
        hz_utility_v2pub.debug(p_message=>'save_org_contacts(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_org_contacts;

END hz_org_contact_bo_pvt;

/
