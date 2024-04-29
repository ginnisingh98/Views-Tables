--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_SITE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_SITE_BO_PVT" AS
/*$Header: ARHBPSVB.pls 120.6 2006/05/18 22:28:14 acng noship $ */

  -- PRIVATE PROCEDURE assign_party_site_use_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from party site use object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_site_use_obj Party site use object.
  --     p_party_site_id      Party site Id.
  --   IN/OUT:
  --     px_party_site_use_rec  Party site use plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_party_site_use_rec(
    p_party_site_use_obj         IN            HZ_PARTY_SITE_USE_OBJ,
    p_party_site_id              IN            NUMBER,
    px_party_site_use_rec        IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_party_site_use_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from party site use object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_party_site_use_obj Party site use object.
  --     p_party_site_id      Party site Id.
  --   IN/OUT:
  --     px_party_site_use_rec  Party site use plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_party_site_use_rec(
    p_party_site_use_obj         IN            HZ_PARTY_SITE_USE_OBJ,
    p_party_site_id              IN            NUMBER,
    px_party_site_use_rec        IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE
  ) IS
  BEGIN
    px_party_site_use_rec.party_site_use_id := p_party_site_use_obj.party_site_use_id;
    px_party_site_use_rec.comments          := p_party_site_use_obj.comments;
    px_party_site_use_rec.site_use_type     := p_party_site_use_obj.site_use_type;
    px_party_site_use_rec.party_site_id     := p_party_site_id;
    IF(p_party_site_use_obj.primary_per_type in ('Y','N')) THEN
      px_party_site_use_rec.primary_per_type  := p_party_site_use_obj.primary_per_type;
    END IF;
    IF(p_party_site_use_obj.status in ('A','I')) THEN
      px_party_site_use_rec.status            := p_party_site_use_obj.status;
    END IF;
    px_party_site_use_rec.created_by_module := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_party_site_use_rec;

  -- PROCEDURE create_party_site_uses
  --
  -- DESCRIPTION
  --     Create party site uses.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_psu_objs           List of party site use objects.
  --     p_ps_id              Party site Id.
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
  --

  PROCEDURE create_party_site_uses(
    p_psu_objs                   IN OUT NOCOPY HZ_PARTY_SITE_USE_OBJ_TBL,
    p_ps_id                      IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  )IS
    l_debug_prefix        VARCHAR2(30);
    l_psu_id              NUMBER;
    l_psu_rec             HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_party_site_uses_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_party_site_uses(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create contact preferences
    FOR i IN 1..p_psu_objs.COUNT LOOP
      assign_party_site_use_rec(
        p_party_site_use_obj => p_psu_objs(i),
        p_party_site_id      => p_ps_id,
        px_party_site_use_rec => l_psu_rec
      );

      HZ_PARTY_SITE_V2PUB.create_party_site_use(
        p_party_site_use_rec        => l_psu_rec,
        x_party_site_use_id         => l_psu_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_site_bo_pvt.create_party_site_uses: party_site_id: '||p_ps_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      -- assign party_site_id and party_site_use_id
      p_psu_objs(i).party_site_use_id := l_psu_id;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_party_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_party_site_uses_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_SITE_USES');
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
        hz_utility_v2pub.debug(p_message=>'create_party_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_party_site_uses_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_SITE_USES');
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
        hz_utility_v2pub.debug(p_message=>'create_party_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_party_site_uses_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_SITE_USES');
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
        hz_utility_v2pub.debug(p_message=>'create_party_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_party_site_uses;

  -- PROCEDURE save_party_site_uses
  --
  -- DESCRIPTION
  --     Create or update party site uses.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_psu_objs           List of party site use objects.
  --     p_ps_id              Party site Id.
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
  --

  PROCEDURE save_party_site_uses(
    p_psu_objs                   IN OUT NOCOPY HZ_PARTY_SITE_USE_OBJ_TBL,
    p_ps_id                      IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  )IS
    l_debug_prefix        VARCHAR2(30);
    l_psu_id              NUMBER;
    l_psu_rec             HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
    l_ovn                 NUMBER := NULL;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_party_site_uses_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_party_site_uses(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create/Update party site use
    FOR i IN 1..p_psu_objs.COUNT LOOP
      assign_party_site_use_rec(
        p_party_site_use_obj => p_psu_objs(i),
        p_party_site_id      => p_ps_id,
        px_party_site_use_rec => l_psu_rec
      );

      -- check if the contact pref record is create or update
      hz_registry_validate_bo_pvt.check_party_site_use_op(
        p_party_site_id       => p_ps_id,
        px_party_site_use_id  => l_psu_rec.party_site_use_id,
        p_site_use_type       => l_psu_rec.site_use_type,
        x_object_version_number => l_ovn
      );

      IF(l_ovn = -1) THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_site_bo_pvt.check_party_site_use_op: party_site_id: '||p_ps_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_SITE_USES');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_ovn IS NULL) THEN
        HZ_PARTY_SITE_V2PUB.create_party_site_use(
          p_party_site_use_rec        => l_psu_rec,
          x_party_site_use_id         => l_psu_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign party_site_use_id
        p_psu_objs(i).party_site_use_id := l_psu_id;
      ELSE
        -- clean up created_by_module for update
        l_psu_rec.created_by_module := NULL;
        HZ_PARTY_SITE_V2PUB.update_party_site_use(
          p_party_site_use_rec        => l_psu_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign party_site_use_id
        p_psu_objs(i).party_site_use_id := l_psu_rec.party_site_use_id;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_site_bo_pvt.save_party_site_uses: party_site_id: '||p_ps_id,
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
        hz_utility_v2pub.debug(p_message=>'save_party_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_party_site_uses_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_SITE_USES');
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
        hz_utility_v2pub.debug(p_message=>'save_party_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_party_site_uses_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_SITE_USES');
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
        hz_utility_v2pub.debug(p_message=>'save_party_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_party_site_uses_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_PARTY_SITE_USES');
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
        hz_utility_v2pub.debug(p_message=>'save_party_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_party_site_uses;

  -- PROCEDURE save_party_sites
  --
  -- DESCRIPTION
  --     Create or update party sites.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_ps_objs            List of party site objects.
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
  --

  PROCEDURE save_party_sites(
    p_ps_objs                    IN OUT NOCOPY HZ_PARTY_SITE_BO_TBL,
    p_create_update_flag         IN         VARCHAR2,
    p_obj_source                 IN         VARCHAR2 := null,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_parent_id                  IN         NUMBER,
    p_parent_os                  IN         VARCHAR2,
    p_parent_osr                 IN         VARCHAR2,
    p_parent_obj_type            IN         VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_party_site_id       NUMBER;
    l_party_site_os       VARCHAR2(30);
    l_party_site_osr      VARCHAR2(255);
    l_parent_id           NUMBER;
    l_parent_os           VARCHAR2(30);
    l_parent_osr          VARCHAR2(255);
    l_parent_obj_type     VARCHAR2(30);
    l_cbm                 VARCHAR2(30);
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_party_sites(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_parent_id := p_parent_id;
    l_parent_os := p_parent_os;
    l_parent_osr:= p_parent_osr;
    l_parent_obj_type := p_parent_obj_type;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    IF(p_create_update_flag = 'C') THEN
      ----------------------------
      -- Create logical party site
      ----------------------------
      FOR i IN 1..p_ps_objs.COUNT LOOP
        HZ_PARTY_SITE_BO_PUB.do_create_party_site_bo(
          p_init_msg_list      => fnd_api.g_false,
          p_validate_bo_flag   => FND_API.G_FALSE,
          p_party_site_obj     => p_ps_objs(i),
          p_created_by_module  => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source         => p_obj_source,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          x_party_site_id      => l_party_site_id,
          x_party_site_os      => l_party_site_os,
          x_party_site_osr     => l_party_site_osr,
          px_parent_id         => l_parent_id,
          px_parent_os         => l_parent_os,
          px_parent_osr        => l_parent_osr,
          px_parent_obj_type   => l_parent_obj_type
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_site_bo_pvt.save_party_sites_bo, parent id: '||l_parent_id||' '||l_parent_os||'-'||l_parent_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
      END LOOP;
    ELSE
      -----------------------------------
      -- Create/Update logical party site
      ------------------------------------
      FOR i IN 1..p_ps_objs.COUNT LOOP
        HZ_PARTY_SITE_BO_PUB.do_save_party_site_bo(
          p_init_msg_list      => fnd_api.g_false,
          p_validate_bo_flag   => FND_API.G_FALSE,
          p_party_site_obj     => p_ps_objs(i),
          p_created_by_module  => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source         => p_obj_source,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          x_party_site_id      => l_party_site_id,
          x_party_site_os      => l_party_site_os,
          x_party_site_osr     => l_party_site_osr,
          px_parent_id         => l_parent_id,
          px_parent_os         => l_parent_os,
          px_parent_osr        => l_parent_osr,
          px_parent_obj_type   => l_parent_obj_type
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_party_site_bo_pvt.save_party_sites_bo, parent id: '||l_parent_id||' '||l_parent_os||'-'||l_parent_osr,
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
        hz_utility_v2pub.debug(p_message=>'save_party_sites(-)',
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
        hz_utility_v2pub.debug(p_message=>'save_party_sites(-)',
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
        hz_utility_v2pub.debug(p_message=>'save_party_sites(-)',
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
        hz_utility_v2pub.debug(p_message=>'save_party_sites(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_party_sites;

END hz_party_site_bo_pvt;

/
