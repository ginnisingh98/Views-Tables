--------------------------------------------------------
--  DDL for Package Body HZ_ORIG_SYSTEM_REF_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORIG_SYSTEM_REF_BO_PUB" AS
/*$Header: ARHBOSBB.pls 120.4.12000000.3 2007/04/06 19:32:06 awu ship $ */

  -- PRIVATE PROCEDURE assign_orig_sys_ref
  --
  -- DESCRIPTION
  --     Assign attribute value from object to plsql record
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_orig_sys_obj       Original system reference object.
  --   OUT:
  --     x_orig_sys_rec       Original system plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_orig_sys_ref(
    p_orig_sys_obj        IN            HZ_ORIG_SYS_REF_OBJ,
    x_orig_sys_rec        OUT NOCOPY    HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_orig_sys_ref
  --
  -- DESCRIPTION
  --     Assign attribute value from object to plsql record
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_orig_sys_obj       Original system reference object.
  --   OUT:
  --     x_orig_sys_rec       Original system plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE assign_orig_sys_ref(
    p_orig_sys_obj        IN            HZ_ORIG_SYS_REF_OBJ,
    x_orig_sys_rec        OUT NOCOPY    HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE
  ) IS
  BEGIN
    x_orig_sys_rec.orig_system := p_orig_sys_obj.orig_system;
    x_orig_sys_rec.orig_system_reference := p_orig_sys_obj.orig_system_reference;
-- Bug 5931699
    if p_orig_sys_obj.object_type = 'ORG_CONTACT'
    then
        x_orig_sys_rec.owner_table_name := 'HZ_ORG_CONTACTS';
    else
        x_orig_sys_rec.owner_table_name := HZ_REGISTRY_VALIDATE_BO_PVT.get_owner_table_name(p_orig_sys_obj.object_type);
    end if;
 --   x_orig_sys_rec.owner_table_name := HZ_REGISTRY_VALIDATE_BO_PVT.get_owner_table_name(p_orig_sys_obj.object_type);
    x_orig_sys_rec.owner_table_id := p_orig_sys_obj.object_id;
    x_orig_sys_rec.status := p_orig_sys_obj.status;
    x_orig_sys_rec.reason_code := p_orig_sys_obj.reason_code;
    x_orig_sys_rec.start_date_active := p_orig_sys_obj.start_date_active;
    x_orig_sys_rec.end_date_active := p_orig_sys_obj.end_date_active;
    x_orig_sys_rec.created_by_module := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    x_orig_sys_rec.attribute_category := p_orig_sys_obj.attribute_category;
    x_orig_sys_rec.attribute1 := p_orig_sys_obj.attribute1;
    x_orig_sys_rec.attribute2 := p_orig_sys_obj.attribute2;
    x_orig_sys_rec.attribute3 := p_orig_sys_obj.attribute3;
    x_orig_sys_rec.attribute4 := p_orig_sys_obj.attribute4;
    x_orig_sys_rec.attribute5 := p_orig_sys_obj.attribute5;
    x_orig_sys_rec.attribute6 := p_orig_sys_obj.attribute6;
    x_orig_sys_rec.attribute7 := p_orig_sys_obj.attribute7;
    x_orig_sys_rec.attribute8 := p_orig_sys_obj.attribute8;
    x_orig_sys_rec.attribute9 := p_orig_sys_obj.attribute9;
    x_orig_sys_rec.attribute10 := p_orig_sys_obj.attribute10;
    x_orig_sys_rec.attribute11 := p_orig_sys_obj.attribute11;
    x_orig_sys_rec.attribute12 := p_orig_sys_obj.attribute12;
    x_orig_sys_rec.attribute13 := p_orig_sys_obj.attribute13;
    x_orig_sys_rec.attribute14 := p_orig_sys_obj.attribute14;
    x_orig_sys_rec.attribute15 := p_orig_sys_obj.attribute15;
    x_orig_sys_rec.attribute16 := p_orig_sys_obj.attribute16;
    x_orig_sys_rec.attribute17 := p_orig_sys_obj.attribute17;
    x_orig_sys_rec.attribute18 := p_orig_sys_obj.attribute18;
    x_orig_sys_rec.attribute19 := p_orig_sys_obj.attribute19;
    x_orig_sys_rec.attribute20 := p_orig_sys_obj.attribute20;
    x_orig_sys_rec.old_orig_system_reference := p_orig_sys_obj.old_orig_system_reference;
  END assign_orig_sys_ref;

  -- PROCEDURE create_orig_sys_refs_bo
  --
  -- DESCRIPTION
  --     Create original system references
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_orig_sys_refs      List of original system reference objects.
  --     p_created_by_module  Created by module.
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

  PROCEDURE create_orig_sys_refs_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_orig_sys_refs       IN            HZ_ORIG_SYS_REF_OBJ_TBL,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) IS
    l_otn                 VARCHAR2(30);
    l_ososr_rec           HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
    l_debug_prefix        VARCHAR2(30);
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_osr_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_orig_sys_ref_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    FOR i IN 1..p_orig_sys_refs.COUNT LOOP
      IF(p_orig_sys_refs(i).object_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NULL_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'object_id');
        FND_MSG_PUB.ADD();
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(p_orig_sys_refs(i).orig_system IS NULL) THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NULL_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'object_id');
        FND_MSG_PUB.ADD();
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(p_orig_sys_refs(i).orig_system_reference IS NULL) THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NULL_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'object_id');
        FND_MSG_PUB.ADD();
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(p_orig_sys_refs(i).orig_system_ref_id IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_CANNOT_PASS_PK');
        FND_MSG_PUB.ADD();
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      assign_orig_sys_ref(
        p_orig_sys_obj     => p_orig_sys_refs(i),
        x_orig_sys_rec     => l_ososr_rec
      );

      HZ_ORIG_SYSTEM_REF_PUB.create_orig_system_reference(
        p_init_msg_list          => p_init_msg_list,
        p_orig_sys_reference_rec => l_ososr_rec,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
      );
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
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_orig_sys_ref_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_osr_bo_pub;
      x_return_status := fnd_api.g_ret_sts_error;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'ORIG_SYSTEM');
      FND_MSG_PUB.ADD;
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
        hz_utility_v2pub.debug(p_message=>'create_orig_sys_refs_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_osr_bo_pub;
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
        hz_utility_v2pub.debug(p_message=>'create_orig_sys_refs_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO create_osr_bo_pub;
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
        hz_utility_v2pub.debug(p_message=>'create_orig_sys_refs_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_orig_sys_refs_bo;

  PROCEDURE create_orig_sys_refs_bo(
    p_orig_sys_refs       IN            HZ_ORIG_SYS_REF_OBJ_TBL,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
  BEGIN
    create_orig_sys_refs_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_orig_sys_refs       => p_orig_sys_refs,
      p_created_by_module   => p_created_by_module,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => l_msg_data
    );
    x_msg_data := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => x_msg_count,
                    x_msg_data        => l_msg_data);
  END create_orig_sys_refs_bo;

  -- PROCEDURE update_orig_sys_refs_bo
  --
  -- DESCRIPTION
  --     Update original system references
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_orig_sys_refs      List of original system reference objects.
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

  PROCEDURE update_orig_sys_refs_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_orig_sys_refs       IN            HZ_ORIG_SYS_REF_OBJ_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) IS
    l_otn                 VARCHAR2(30);
    l_ovn                 NUMBER;
    l_ososr_rec           HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;
    l_debug_prefix        VARCHAR2(30);
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT update_osr_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_orig_sys_ref_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    FOR i IN 1..p_orig_sys_refs.COUNT LOOP
      IF(p_orig_sys_refs(i).object_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NULL_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'object_id');
        FND_MSG_PUB.ADD();
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(p_orig_sys_refs(i).orig_system IS NULL) THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NULL_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'orig_system');
        FND_MSG_PUB.ADD();
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(p_orig_sys_refs(i).orig_system_reference IS NULL) THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NULL_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'orig_system_reference');
        FND_MSG_PUB.ADD();
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(p_orig_sys_refs(i).old_orig_system_reference IS NULL) THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NULL_PARAM');
        FND_MESSAGE.SET_TOKEN('PARAMETER', 'old_orig_system_reference');
        FND_MSG_PUB.ADD();
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      assign_orig_sys_ref(
        p_orig_sys_obj     => p_orig_sys_refs(i),
        x_orig_sys_rec     => l_ososr_rec
      );

      l_ososr_rec.created_by_module := null;
      HZ_ORIG_SYSTEM_REF_PUB.update_orig_system_reference(
        p_orig_sys_reference_rec => l_ososr_rec,
        p_object_version_number  => l_ovn,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
      );
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
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_orig_sys_ref_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_osr_bo_pub;
      x_return_status := fnd_api.g_ret_sts_error;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'ORIG_SYSTEM');
      FND_MSG_PUB.ADD;
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
        hz_utility_v2pub.debug(p_message=>'update_orig_sys_refs_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_osr_bo_pub;
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
        hz_utility_v2pub.debug(p_message=>'update_orig_sys_refs_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO update_osr_bo_pub;
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
        hz_utility_v2pub.debug(p_message=>'update_orig_sys_refs_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END update_orig_sys_refs_bo;

  PROCEDURE update_orig_sys_refs_bo(
    p_orig_sys_refs       IN            HZ_ORIG_SYS_REF_OBJ_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
  BEGIN
    update_orig_sys_refs_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_orig_sys_refs       => p_orig_sys_refs,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => l_msg_data
    );
    x_msg_data := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => x_msg_count,
                    x_msg_data        => l_msg_data);
  END update_orig_sys_refs_bo;

  -- PROCEDURE remap_internal_identifiers_bo
  --
  -- DESCRIPTION
  --     Remap original system references
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_orig_sys_refs      List of original system reference objects.
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

  PROCEDURE remap_internal_identifiers_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_orig_sys_refs       IN            REMAP_ORIG_SYS_REC,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) IS
    l_otn                 VARCHAR2(30);
    l_debug_prefix        VARCHAR2(30);
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT remap_osr_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_orig_sys_ref_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    FOR i IN 1..p_orig_sys_refs.object_type.COUNT LOOP
      l_otn := HZ_REGISTRY_VALIDATE_BO_PVT.get_owner_table_name(p_orig_sys_refs.object_type(i));
      HZ_ORIG_SYSTEM_REF_PUB.remap_internal_identifier(
        p_old_owner_table_id    => p_orig_sys_refs.old_object_id(i),
        p_new_owner_table_id    => p_orig_sys_refs.new_object_id(i),
        p_owner_table_name      => l_otn,
        p_orig_system           => p_orig_sys_refs.object_os(i),
        p_orig_system_reference => p_orig_sys_refs.object_osr(i),
        p_reason_code           => p_orig_sys_refs.reason_code(i),
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data
      );
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
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'remap_internal_identifiers_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO remap_osr_bo_pub;
      x_return_status := fnd_api.g_ret_sts_error;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_ENTITY_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY', 'ORIG_SYSTEM');
      FND_MSG_PUB.ADD;
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
        hz_utility_v2pub.debug(p_message=>'remap_internal_identifiers_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO remap_osr_bo_pub;
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
        hz_utility_v2pub.debug(p_message=>'remap_internal_identifiers_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO remap_osr_bo_pub;
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
        hz_utility_v2pub.debug(p_message=>'remap_internal_identifiers_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END remap_internal_identifiers_bo;

  PROCEDURE remap_internal_identifiers_bo(
    p_orig_sys_refs       IN            REMAP_ORIG_SYS_REC,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
  BEGIN
    remap_internal_identifiers_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_orig_sys_refs       => p_orig_sys_refs,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => l_msg_data
    );
    x_msg_data := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => x_msg_count,
                    x_msg_data        => l_msg_data);
  END remap_internal_identifiers_bo;

END HZ_ORIG_SYSTEM_REF_BO_PUB;

/
