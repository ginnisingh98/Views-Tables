--------------------------------------------------------
--  DDL for Package Body HZ_CONTACT_PREFERENCE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CONTACT_PREFERENCE_BO_PVT" AS
/*$Header: ARHBCTVB.pls 120.6 2006/05/18 22:25:22 acng noship $ */

  -- PRIVATE PROCEDURE assign_contact_pref_rec
  --
  -- DESCRIPTION
  --     Assign attributes from contact preference object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_contact_pref_obj   Contact preference object.
  --     p_contact_level_table_id   Contact level table Id.
  --     p_contact_level_table      Contact level table.
  --   IN/OUT:
  --     px_contact_pref_rec  Contact preference plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_contact_pref_rec(
    p_contact_pref_obj           IN            HZ_CONTACT_PREF_OBJ,
    p_contact_level_table_id     IN            NUMBER,
    p_contact_level_table        IN            VARCHAR2,
    px_contact_pref_rec          IN OUT NOCOPY HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE
  );

  -- PROCEDURE create_contact_preferences
  --
  -- DESCRIPTION
  --     Create contact preferences.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cp_pref_objs       List of contact preference objects.
  --     p_contact_level_table_id   Contact level table Id.
  --     p_contact_level_table      Contact level table.
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

  PROCEDURE create_contact_preferences(
    p_cp_pref_objs            IN OUT NOCOPY HZ_CONTACT_PREF_OBJ_TBL,
    p_contact_level_table_id  IN         NUMBER,
    p_contact_level_table     IN         VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix        VARCHAR2(30);
    l_contact_pref_id     NUMBER;
    l_contact_pref_rec    HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_contact_preferences_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_contact_preferences(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create contact preferences
    FOR i IN 1..p_cp_pref_objs.COUNT LOOP
      assign_contact_pref_rec(
        p_contact_pref_obj       => p_cp_pref_objs(i),
        p_contact_level_table_id => p_contact_level_table_id,
        p_contact_level_table    => p_contact_level_table,
        px_contact_pref_rec      => l_contact_pref_rec
      );

      HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference(
        p_contact_preference_rec    => l_contact_pref_rec,
        x_contact_preference_id     => l_contact_pref_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      -- If error happen, push message into stack, raise exception out of the loop.
      -- Reason is that we want to capture as manay as we can.
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_contact_preference_bo_pvt.create_contact_preferences: contact level table and id: '||p_contact_level_table||' '||p_contact_level_table_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign contact_preference_id
      p_cp_pref_objs(i).contact_preference_id := l_contact_pref_id;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_contact_preferences(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_contact_preferences_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CONTACT_PREFERENCES');
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
        hz_utility_v2pub.debug(p_message=>'create_contact_preferences(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_contact_preferences_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CONTACT_PREFERENCES');
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
        hz_utility_v2pub.debug(p_message=>'create_contact_preferences(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_contact_preferences_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CONTACT_PREFERENCES');
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
        hz_utility_v2pub.debug(p_message=>'create_contact_preferences(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_contact_preferences;

  -- PROCEDURE save_contact_preferences
  --
  -- DESCRIPTION
  --     Create or update contact preferences.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cp_pref_objs       List of contact preference objects.
  --     p_contact_level_table_id   Contact level table Id.
  --     p_contact_level_table      Contact level table.
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

  PROCEDURE save_contact_preferences(
    p_cp_pref_objs            IN OUT NOCOPY HZ_CONTACT_PREF_OBJ_TBL,
    p_contact_level_table_id  IN         NUMBER,
    p_contact_level_table     IN         VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2
  ) IS
    CURSOR get_contact_pref_id(l_contact_point_id NUMBER, l_contact_type VARCHAR2,
                               l_preference_code  VARCHAR2, l_preference_start_date DATE,
                               l_preference_end_date DATE)IS
    SELECT contact_preference_id
    FROM HZ_CONTACT_PREFERENCES
    WHERE contact_level_table_id = l_contact_point_id
    AND contact_type = l_contact_type
    AND preference_code = l_preference_code
    AND trunc(preference_start_date) = trunc(l_preference_start_date)
    AND trunc(nvl(preference_start_date,sysdate)) = trunc(nvl(l_preference_start_date,sysdate))
    AND rownum = 1;

    l_debug_prefix        VARCHAR2(30);
    l_contact_pref_id     NUMBER;
    l_contact_pref_rec    HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
    l_ovn                 NUMBER := NULL;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_contact_preferences_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_contact_preferences(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create/Update contact preferences
    FOR i IN 1..p_cp_pref_objs.COUNT LOOP
      assign_contact_pref_rec(
        p_contact_pref_obj       => p_cp_pref_objs(i),
        p_contact_level_table_id => p_contact_level_table_id,
        p_contact_level_table    => p_contact_level_table,
        px_contact_pref_rec      => l_contact_pref_rec
      );

      -- check if the contact pref record is create or update
      hz_registry_validate_bo_pvt.check_contact_pref_op(
        p_contact_level_table_id => p_contact_level_table_id,
        p_contact_level_table    => p_contact_level_table,
        px_contact_pref_id       => l_contact_pref_rec.contact_preference_id,
        p_contact_type           => l_contact_pref_rec.contact_type,
        p_preference_code        => l_contact_pref_rec.preference_code,
        p_preference_start_date  => l_contact_pref_rec.preference_start_date,
        p_preference_end_date    => l_contact_pref_rec.preference_end_date,
        x_object_version_number  => l_ovn
      );

      IF(l_ovn = -1) THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_contact_preference_bo_pvt.check_contact_pref_op: contact level table and id: '||p_contact_level_table||' '||p_contact_level_table_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
        FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CONTACT_PREFERENCES');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(l_ovn IS NULL) THEN
        HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference(
          p_contact_preference_rec    => l_contact_pref_rec,
          x_contact_preference_id     => l_contact_pref_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign contact_preference_id
        p_cp_pref_objs(i).contact_preference_id := l_contact_pref_id;
      ELSE
        -- clean up created_by_module during update
        l_contact_pref_rec.created_by_module := NULL;
        HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference(
          p_contact_preference_rec    => l_contact_pref_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        -- assign contact_preference_id
        p_cp_pref_objs(i).contact_preference_id := l_contact_pref_rec.contact_preference_id;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_contact_preference_bo_pvt.save_contact_preferences: contact level table and id: '||p_contact_level_table||' '||p_contact_level_table_id,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
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
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_contact_preferences(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_contact_preferences_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CONTACT_PREFERENCES');
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
        hz_utility_v2pub.debug(p_message=>'save_contact_preferences(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_contact_preferences_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CONTACT_PREFERENCES');
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
        hz_utility_v2pub.debug(p_message=>'save_contact_preferences(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_contact_preferences_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'HZ_CONTACT_PREFERENCES');
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
        hz_utility_v2pub.debug(p_message=>'save_contact_preferences(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_contact_preferences;

  -- PRIVATE PROCEDURE assign_contact_pref_rec
  --
  -- DESCRIPTION
  --     Assign attributes from contact preference object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_contact_pref_obj   Contact preference object.
  --     p_contact_level_table_id   Contact level table Id.
  --     p_contact_level_table      Contact level table.
  --   IN/OUT:
  --     px_contact_pref_rec  Contact preference plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_contact_pref_rec(
    p_contact_pref_obj           IN            HZ_CONTACT_PREF_OBJ,
    p_contact_level_table_id     IN            NUMBER,
    p_contact_level_table        IN            VARCHAR2,
    px_contact_pref_rec          IN OUT NOCOPY HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE
  ) IS
  BEGIN
    px_contact_pref_rec.contact_preference_id       := p_contact_pref_obj.contact_preference_id;
    px_contact_pref_rec.contact_level_table         := p_contact_level_table;
    px_contact_pref_rec.contact_level_table_id      := p_contact_level_table_id;
    px_contact_pref_rec.contact_type                := p_contact_pref_obj.contact_type;
    px_contact_pref_rec.preference_code             := p_contact_pref_obj.preference_code;
    px_contact_pref_rec.preference_topic_type       := p_contact_pref_obj.preference_topic_type;
    px_contact_pref_rec.preference_topic_type_id    := p_contact_pref_obj.preference_topic_type_id;
    px_contact_pref_rec.preference_topic_type_code  := p_contact_pref_obj.preference_topic_type_code;
    px_contact_pref_rec.preference_start_date       := p_contact_pref_obj.preference_start_date;
    px_contact_pref_rec.preference_end_date         := p_contact_pref_obj.preference_end_date;
    px_contact_pref_rec.preference_start_time_hr    := p_contact_pref_obj.preference_start_time_hr;
    px_contact_pref_rec.preference_end_time_hr      := p_contact_pref_obj.preference_end_time_hr;
    px_contact_pref_rec.preference_start_time_mi    := p_contact_pref_obj.preference_start_time_mi;
    px_contact_pref_rec.preference_end_time_mi      := p_contact_pref_obj.preference_end_time_mi;
    px_contact_pref_rec.max_no_of_interactions      := p_contact_pref_obj.max_no_of_interactions;
    px_contact_pref_rec.max_no_of_interact_uom_code := p_contact_pref_obj.max_no_of_interact_uom_code;
    px_contact_pref_rec.requested_by                := p_contact_pref_obj.requested_by;
    px_contact_pref_rec.reason_code                 := p_contact_pref_obj.reason_code;
    IF(p_contact_pref_obj.status in ('A','I')) THEN
      px_contact_pref_rec.status                    := p_contact_pref_obj.status;
    ELSE
      px_contact_pref_rec.status                    := null;
    END IF;
    px_contact_pref_rec.created_by_module           := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
  END assign_contact_pref_rec;

END hz_contact_preference_bo_pvt;

/
