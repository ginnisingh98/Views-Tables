--------------------------------------------------------
--  DDL for Package Body HZ_PERSON_CUST_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PERSON_CUST_BO_PUB" AS
/*$Header: ARHBPABB.pls 120.20 2008/02/06 10:14:13 vsegu ship $ */
  PROCEDURE do_create_person_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_obj     IN OUT NOCOPY HZ_PERSON_CUST_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER
  );

  PROCEDURE do_update_person_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_cust_obj     IN OUT NOCOPY HZ_PERSON_CUST_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER
  );

  PROCEDURE do_save_person_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_obj     IN OUT NOCOPY HZ_PERSON_CUST_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER
  );

  -- PROCEDURE do_create_person_cust_bo
  --
  -- DESCRIPTION
  --     Create person customer account.
  PROCEDURE do_create_person_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_obj     IN OUT NOCOPY HZ_PERSON_CUST_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_person_os           VARCHAR2(30);
    l_person_osr          VARCHAR2(255);
    l_debug_prefix        VARCHAR2(30) := '';
    l_valid_obj           BOOLEAN;
    l_raise_event         BOOLEAN := FALSE;
    l_bus_object          HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
    l_cbm                 VARCHAR2(30);
    l_per_event_id        NUMBER;
    l_pc_event_id         NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_person_cust_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_person_cust_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Base on p_validate_bo_flag, check the completeness of business objects
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => 'PERSON_CUST',
        x_bus_object              => l_bus_object
      );

      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_pca_bo_comp(
                       p_person_obj => p_person_cust_obj.person_obj,
                       p_ca_objs    => p_person_cust_obj.account_objs
                     );

      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- find out if raise event at the end
      l_raise_event := HZ_PARTY_BO_PVT.is_raising_create_event(
                         p_obj_complete_flag => l_valid_obj );

      IF(l_raise_event) THEN
        -- Get event_id for person
        SELECT HZ_BUS_OBJ_TRACKING_S.nextval
        INTO l_per_event_id
        FROM DUAL;

        -- Get event_id for person customer
        SELECT HZ_BUS_OBJ_TRACKING_S.nextval
        INTO l_pc_event_id
        FROM DUAL;
      END IF;
    ELSE
      l_raise_event := FALSE;
    END IF;

    -- initialize Global variable to indicate the caller of V2API is from BO API
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    HZ_PERSON_BO_PUB.do_create_person_bo(
      p_init_msg_list          => fnd_api.g_false,
      p_validate_bo_flag       => FND_API.G_FALSE,
      p_person_obj             => p_person_cust_obj.person_obj,
      p_created_by_module      => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
      p_obj_source             => p_obj_source,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      x_person_id              => x_person_id,
      x_person_os              => l_person_os,
      x_person_osr             => l_person_osr
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    IF((p_person_cust_obj.account_objs IS NOT NULL) AND
       (p_person_cust_obj.account_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.save_cust_accts(
        p_ca_objs                => p_person_cust_obj.account_objs,
        p_create_update_flag     => 'C',
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_parent_id              => x_person_id,
        p_parent_os              => l_person_os,
        p_parent_osr             => l_person_osr,
        p_parent_obj_type        => 'PERSON'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -- raise event
    IF(l_raise_event) THEN
      -- raise create person event
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_person_id,
        p_bo_code          => 'PERSON',
        p_create_or_update => 'C',
        p_obj_source       => p_obj_source,
        p_event_id         => l_per_event_id
      );

      -- raise create person cust event
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_person_id,
        p_bo_code          => 'PERSON_CUST',
        p_create_or_update => 'C',
        p_obj_source       => p_obj_source,
        p_event_id         => l_pc_event_id
      );
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_person_cust_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_person_cust_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
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
        hz_utility_v2pub.debug(p_message=>'do_create_person_cust_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_person_cust_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
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
        hz_utility_v2pub.debug(p_message=>'do_create_person_cust_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_person_cust_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
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
        hz_utility_v2pub.debug(p_message=>'do_create_person_cust_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_person_cust_bo;

  PROCEDURE create_person_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_obj     IN            HZ_PERSON_CUST_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_pc_obj              HZ_PERSON_CUST_BO;
  BEGIN
    l_pc_obj := p_person_cust_obj;
    do_create_person_cust_bo(
      p_init_msg_list       => p_init_msg_list,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_person_cust_obj     => l_pc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_person_id           => x_person_id
    );
  END create_person_cust_bo;

  PROCEDURE create_person_cust_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_obj     IN            HZ_PERSON_CUST_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_pc_obj              HZ_PERSON_CUST_BO;
  BEGIN
    l_pc_obj := p_person_cust_obj;
    do_create_person_cust_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_person_cust_obj     => l_pc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_person_id           => x_person_id
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_pc_obj;
    END IF;
  END create_person_cust_bo;

  -- PROCEDURE do_update_person_cust_bo
  --
  -- DESCRIPTION
  --     Update person customer account.
  PROCEDURE do_update_person_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_cust_obj     IN OUT NOCOPY HZ_PERSON_CUST_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_person_os           VARCHAR2(30);
    l_person_osr          VARCHAR2(255);
    l_debug_prefix        VARCHAR2(30) := '';
    l_per_raise_event     BOOLEAN := FALSE;
    l_pc_raise_event      BOOLEAN := FALSE;
    l_cbm                 VARCHAR2(30);
    l_per_event_id        NUMBER;
    l_pc_event_id         NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_update_person_cust_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_person_cust_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    x_person_id := p_person_cust_obj.person_obj.person_id;
    l_person_os := p_person_cust_obj.person_obj.orig_system;
    l_person_osr:= p_person_cust_obj.person_obj.orig_system_reference;

    -- check input party_id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_person_id,
      px_os              => l_person_os,
      px_osr             => l_person_osr,
      p_obj_type         => 'PERSON',
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- get person_id and then call
    l_per_raise_event := HZ_PARTY_BO_PVT.is_raising_update_event(
                           p_party_id          => x_person_id,
                           p_bo_code           => 'PERSON'
                         );

    l_pc_raise_event := HZ_PARTY_BO_PVT.is_raising_update_event(
                          p_party_id          => x_person_id,
                          p_bo_code           => 'PERSON_CUST'
                        );

    IF(l_per_raise_event) THEN
      -- Get event_id for person
      SELECT HZ_BUS_OBJ_TRACKING_S.nextval
      INTO l_per_event_id
      FROM DUAL;
    END IF;

    IF(l_pc_raise_event) THEN
      -- Get event_id for person customer
      SELECT HZ_BUS_OBJ_TRACKING_S.nextval
      INTO l_pc_event_id
      FROM DUAL;
    END IF;

    -- acknowledge update_organization_bo not to raise event
    HZ_PARTY_BO_PVT.G_CALL_UPDATE_CUST_BO := 'Y';
    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    HZ_PERSON_BO_PUB.do_update_person_bo(
      p_init_msg_list          => fnd_api.g_false,
      p_person_obj             => p_person_cust_obj.person_obj,
      p_created_by_module      => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
      p_obj_source             => p_obj_source,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      x_person_id              => x_person_id,
      x_person_os              => l_person_os,
      x_person_osr             => l_person_osr
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    IF((p_person_cust_obj.account_objs IS NOT NULL) AND
       (p_person_cust_obj.account_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.save_cust_accts(
        p_ca_objs                => p_person_cust_obj.account_objs,
        p_create_update_flag     => 'U',
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_parent_id              => x_person_id,
        p_parent_os              => l_person_os,
        p_parent_osr             => l_person_osr,
        p_parent_obj_type        => 'PERSON'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -- raise event
    IF(l_per_raise_event) THEN
      -- raise update org event
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_person_id,
        p_bo_code          => 'PERSON',
        p_create_or_update => 'U',
        p_obj_source       => p_obj_source,
        p_event_id         => l_per_event_id
      );
    END IF;

    IF(l_pc_raise_event) THEN
      -- raise update org cust event
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_person_id,
        p_bo_code          => 'PERSON_CUST',
        p_create_or_update => 'U',
        p_obj_source       => p_obj_source,
        p_event_id         => l_pc_event_id
      );
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;
    HZ_PARTY_BO_PVT.G_CALL_UPDATE_CUST_BO := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_person_cust_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_person_cust_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;
      HZ_PARTY_BO_PVT.G_CALL_UPDATE_CUST_BO := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
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
        hz_utility_v2pub.debug(p_message=>'do_update_person_cust_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_person_cust_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;
      HZ_PARTY_BO_PVT.G_CALL_UPDATE_CUST_BO := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
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
        hz_utility_v2pub.debug(p_message=>'do_update_person_cust_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_update_person_cust_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;
      HZ_PARTY_BO_PVT.G_CALL_UPDATE_CUST_BO := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
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
        hz_utility_v2pub.debug(p_message=>'do_update_person_cust_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_person_cust_bo;

  PROCEDURE update_person_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_cust_obj     IN            HZ_PERSON_CUST_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_pc_obj    HZ_PERSON_CUST_BO;
  BEGIN
    l_pc_obj := p_person_cust_obj;
    do_update_person_cust_bo(
      p_init_msg_list       => p_init_msg_list,
      p_person_cust_obj     => l_pc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_person_id           => x_person_id
    );
  END update_person_cust_bo;

  PROCEDURE update_person_cust_bo(
    p_person_cust_obj     IN            HZ_PERSON_CUST_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_pc_obj              HZ_PERSON_CUST_BO;
  BEGIN
    l_pc_obj := p_person_cust_obj;
    do_update_person_cust_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_person_cust_obj     => l_pc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_person_id           => x_person_id
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_pc_obj;
    END IF;
  END update_person_cust_bo;

  -- PROCEDURE save_person_cust_bo
  --
  -- DESCRIPTION
  --     Create or update person customer account.
  PROCEDURE do_save_person_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_obj     IN OUT NOCOPY HZ_PERSON_CUST_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_person_id                NUMBER;
    l_person_os                VARCHAR2(30);
    l_person_osr               VARCHAR2(255);
    l_debug_prefix             VARCHAR2(30) := '';
    l_create_update_flag       VARCHAR2(1);
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_person_cust_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_person_id := p_person_cust_obj.person_obj.person_id;
    l_person_os := p_person_cust_obj.person_obj.orig_system;
    l_person_osr:= p_person_cust_obj.person_obj.orig_system_reference;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id      => l_person_id,
                              p_entity_os      => l_person_os,
                              p_entity_osr     => l_person_osr,
                              p_entity_type    => 'HZ_PARTIES',
                              p_parent_id      => NULL,
                              p_parent_obj_type=> NULL );

    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_create_update_flag = 'C') THEN
      do_create_person_cust_bo(
        p_init_msg_list       => fnd_api.g_false,
        p_validate_bo_flag    => p_validate_bo_flag,
        p_person_cust_obj     => p_person_cust_obj,
        p_created_by_module   => p_created_by_module,
        p_obj_source          => p_obj_source,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        x_person_id           => x_person_id
      );
    ELSIF(l_create_update_flag = 'U') THEN
      do_update_person_cust_bo(
        p_init_msg_list       => fnd_api.g_false,
        p_person_cust_obj     => p_person_cust_obj,
        p_created_by_module   => p_created_by_module,
        p_obj_source          => p_obj_source,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        x_person_id           => x_person_id
      );
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_person_cust_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_person_cust_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_person_cust_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_person_cust_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_person_cust_bo;

  PROCEDURE save_person_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_obj     IN            HZ_PERSON_CUST_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_pc_obj              HZ_PERSON_CUST_BO;
  BEGIN
    l_pc_obj := p_person_cust_obj;
    do_save_person_cust_bo(
      p_init_msg_list       => p_init_msg_list,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_person_cust_obj     => l_pc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => null,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      x_person_id           => x_person_id
    );
  END save_person_cust_bo;

  PROCEDURE save_person_cust_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_obj     IN            HZ_PERSON_CUST_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_pc_obj              HZ_PERSON_CUST_BO;
  BEGIN
    l_pc_obj := p_person_cust_obj;
    do_save_person_cust_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_person_cust_obj     => l_pc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_person_id           => x_person_id
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_pc_obj;
    END IF;
  END save_person_cust_bo;

  --------------------------------------
  --
  -- PROCEDURE get_person_cust_bo
  --
  -- DESCRIPTION
  --     Get a logical person customer.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
--       p_person_id          Person ID.
 --     p_person_os           Person orig system.
  --     p_person_osr         Person orig system reference.

  --   OUT:
  --     x_person_cust_obj         Logical person customer record.
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
  --   10-JUN-2005   AWU                Created.
  --

/*
The Get Person Customer API Procedure is a retrieval service that returns a full Person Customer business object.
The user identifies a particular Person Customer business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Person Customer business object is returned. The object consists of all data included within
the Person Customer business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Person Customer business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments

Person			Y	N	get_person_bo
Customer Account	Y	Y	get_cust_acct_bo	Called for each Customer Account object for the Person Customer

*/



 PROCEDURE get_person_cust_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_id           IN            NUMBER,
    p_person_os		IN	VARCHAR2,
    p_person_osr		IN	VARCHAR2,
    x_person_cust_obj     OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  )  is
 l_debug_prefix              VARCHAR2(30) := '';

  l_person_id  number;
  l_person_os  varchar2(30);
  l_person_osr varchar2(255);
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_person_id := p_person_id;
    	l_person_os := p_person_os;
    	l_person_osr := p_person_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_person_id,
      		px_os              => l_person_os,
      		px_osr             => l_person_osr,
      		p_obj_type         => 'PERSON',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_PERSON_CUST_BO_PVT.get_person_cust_bo(
    		p_init_msg_list   => fnd_api.g_false,
    		p_person_id => l_person_id,
    		p_action_type	  => NULL,
    		x_person_cust_obj => x_person_cust_obj,
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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_person_cust_bo(
    p_person_id           IN            NUMBER,
    p_person_os         IN      VARCHAR2,
    p_person_osr                IN      VARCHAR2,
    x_person_cust_obj     OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_person_cust_bo(
      p_init_msg_list   => fnd_api.g_true,
      p_person_id       => p_person_id,
      p_person_os       => p_person_os,
      p_person_osr      => p_person_osr,
      x_person_cust_obj => x_person_cust_obj,
      x_return_status   => x_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_person_cust_bo;

 --------------------------------------
  --
  -- PROCEDURE get_person_custs_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person Customers created business event and
  --the procedure returns database objects of the type HZ_PERSON_CUST CUSTOMER_BO for all of
  --the Person Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_objs   One or more created logical person customer.
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
  --   10-JUN-2005    AWU                Created.
  --



/*
The Get Person customers Created procedure is a service to retrieve all of the Person Customer business objects
whose creations have been captured by a logical business event. Each Person Customers Created
business event signifies that one or more Person Customer business objects have been created.
The caller provides an identifier for the Person Customers Created business event and the procedure
returns all of the Person Customer business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_PERSON_CUST_BO_PVT.get_person_cust_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_person_custs_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_cust_objs    OUT NOCOPY    HZ_PERSON_CUST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_custs_created(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'C',
			    p_bo_code => 'PERSON_CUST',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_PERSON_CUST_BO_PVT.get_person_custs_created(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
    		x_person_cust_objs  => x_person_cust_objs,
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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_custs_created (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_custs_created(-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_custs_created(-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_custs_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_person_custs_created(
    p_event_id            IN            NUMBER,
    x_person_cust_objs    OUT NOCOPY    HZ_PERSON_CUST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_person_custs_created(
      p_init_msg_list       => fnd_api.g_true,
      p_event_id            => p_event_id,
      x_person_cust_objs    => x_person_cust_objs,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_person_custs_created;




--------------------------------------
  --
  -- PROCEDURE get_person_custs_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person Customers update business event and
  --the procedure returns database objects of the type HZ_PERSON_CUST_BO for all of
  --the Person Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_objs   One or more created logical person.
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



/*
The Get Person Customers Updated procedure is a service to retrieve all of the Person Customer business objects whose updates
have been captured by the logical business event. Each Person Customers Updated business event signifies that one or more Person
Customer business objects have been updated.
The caller provides an identifier for the Person Customers Update business event and the procedure returns database objects of
the type HZ_PERSON_CUST_BO for all of the Person Customer business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure and returns
them to the caller.
*/

 PROCEDURE get_person_custs_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_cust_objs         OUT NOCOPY    HZ_PERSON_CUST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_custs_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'U',
			    p_bo_code => 'PERSON_CUST',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_PERSON_CUST_BO_PVT.get_person_custs_updated(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
    		x_person_cust_objs  => x_person_cust_objs,
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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_custs_updated (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_custs_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_custs_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_custs_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_person_custs_updated(
    p_event_id            IN            NUMBER,
    x_person_cust_objs         OUT NOCOPY    HZ_PERSON_CUST_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  )IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_person_custs_updated(
      p_init_msg_list      => fnd_api.g_true,
      p_event_id           => p_event_id,
      x_person_cust_objs   => x_person_cust_objs,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_person_custs_updated;

--------------------------------------
  --
  -- PROCEDURE get_person_cust_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person customer update business event and person id
  --the procedure returns one database object of the type HZ_PERSON_CUST_BO
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --     p_person_cust_id        Person customer identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_obj       One updated logical person.
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
  --   06-JUN-2005     AWU                Created.
  --

 PROCEDURE get_person_cust_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_person_cust_id           IN           NUMBER,
    x_person_cust_obj         OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => p_person_cust_id,
			    p_event_type => 'U',
			    p_bo_code => 'PERSON_CUST',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_PERSON_CUST_BO_PVT.get_person_cust_updated(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
		p_person_cust_id  => p_person_cust_id,
    		x_person_cust_obj  => x_person_cust_obj,
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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_updated (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_person_cust_updated(
    p_event_id            IN            NUMBER,
    p_person_cust_id           IN           NUMBER,
    x_person_cust_obj         OUT NOCOPY    HZ_PERSON_CUST_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_person_cust_updated(
      p_init_msg_list       => fnd_api.g_true,
      p_event_id            => p_event_id,
      p_person_cust_id      => p_person_cust_id,
      x_person_cust_obj     => x_person_cust_obj,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_person_cust_updated;

-- get TCA identifiers for create event
PROCEDURE get_ids_person_custs_created (
	p_init_msg_list		IN	VARCHAR2 := fnd_api.g_false,
	p_event_id		IN	NUMBER,
	x_person_cust_ids		OUT NOCOPY	HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL,
	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2

) is
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
        	hz_utility_v2pub.debug(p_message=>'get_ids_person_custs_created(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'C',
			    p_bo_code => 'PERSON_CUST',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => x_person_cust_ids,
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
        	hz_utility_v2pub.debug(p_message=>'get_ids_person_custs_created (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_ids_person_custs_created(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_ids_person_custs_created(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_ids_person_custs_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;


-- get TCA identifiers for update event
PROCEDURE get_ids_person_custs_updated (
	p_init_msg_list		IN	VARCHAR2 := fnd_api.g_false,
	p_event_id		IN	NUMBER,
	x_person_cust_ids		OUT NOCOPY	HZ_EXTRACT_BO_UTIL_PVT.BO_ID_TBL,
	x_return_status       OUT NOCOPY    VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
) is
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
        	hz_utility_v2pub.debug(p_message=>'get_ids_person_custs_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'U',
			    p_bo_code => 'PERSON_CUST',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.get_bo_root_ids(
    	p_init_msg_list       => fnd_api.g_false,
    	p_event_id            => p_event_id,
    	x_obj_root_ids        => x_person_cust_ids,
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
        	hz_utility_v2pub.debug(p_message=>'get_ids_person_custs_updated (-)',
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
        hz_utility_v2pub.debug(p_message=>'get_ids_person_custs_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_ids_person_custs_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_ids_person_custs_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

-- PROCEDURE do_create_person_cust_v2_bo
  --
  -- DESCRIPTION
  --     Create person customer account.
  PROCEDURE do_create_person_cust_v2_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_v2_obj     IN OUT NOCOPY HZ_PERSON_CUST_V2_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_person_os           VARCHAR2(30);
    l_person_osr          VARCHAR2(255);
    l_debug_prefix        VARCHAR2(30) := '';
    l_valid_obj           BOOLEAN;
    l_raise_event         BOOLEAN := FALSE;
    l_bus_object          HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
    l_cbm                 VARCHAR2(30);
    l_per_event_id        NUMBER;
    l_pc_event_id         NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_person_cust_v2_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_person_cust_v2_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Base on p_validate_bo_flag, check the completeness of business objects
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => 'PERSON_CUST',
        x_bus_object              => l_bus_object
      );

      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_pca_v2_bo_comp(
                       p_person_obj => p_person_cust_v2_obj.person_obj,
                       p_ca_v2_objs    => p_person_cust_v2_obj.account_objs
                     );

      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- find out if raise event at the end
      l_raise_event := HZ_PARTY_BO_PVT.is_raising_create_event(
                         p_obj_complete_flag => l_valid_obj );

      IF(l_raise_event) THEN
        -- Get event_id for person
        SELECT HZ_BUS_OBJ_TRACKING_S.nextval
        INTO l_per_event_id
        FROM DUAL;

        -- Get event_id for person customer
        SELECT HZ_BUS_OBJ_TRACKING_S.nextval
        INTO l_pc_event_id
        FROM DUAL;
      END IF;
    ELSE
      l_raise_event := FALSE;
    END IF;

    -- initialize Global variable to indicate the caller of V2API is from BO API
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    HZ_PERSON_BO_PUB.do_create_person_bo(
      p_init_msg_list          => fnd_api.g_false,
      p_validate_bo_flag       => FND_API.G_FALSE,
      p_person_obj             => p_person_cust_v2_obj.person_obj,
      p_created_by_module      => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
      p_obj_source             => p_obj_source,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      x_person_id              => x_person_id,
      x_person_os              => l_person_os,
      x_person_osr             => l_person_osr
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    IF((p_person_cust_v2_obj.account_objs IS NOT NULL) AND
       (p_person_cust_v2_obj.account_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.save_cust_accts(
        p_ca_v2_objs                => p_person_cust_v2_obj.account_objs,
        p_create_update_flag     => 'C',
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_parent_id              => x_person_id,
        p_parent_os              => l_person_os,
        p_parent_osr             => l_person_osr,
        p_parent_obj_type        => 'PERSON'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -- raise event
    IF(l_raise_event) THEN
      -- raise create person event
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_person_id,
        p_bo_code          => 'PERSON',
        p_create_or_update => 'C',
        p_obj_source       => p_obj_source,
        p_event_id         => l_per_event_id
      );

      -- raise create person cust event
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_person_id,
        p_bo_code          => 'PERSON_CUST',
        p_create_or_update => 'C',
        p_obj_source       => p_obj_source,
        p_event_id         => l_pc_event_id
      );
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_person_cust_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_person_cust_v2_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
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
        hz_utility_v2pub.debug(p_message=>'do_create_person_cust_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_person_cust_v2_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
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
        hz_utility_v2pub.debug(p_message=>'do_create_person_cust_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_person_cust_v2_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
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
        hz_utility_v2pub.debug(p_message=>'do_create_person_cust_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_person_cust_v2_bo;


  PROCEDURE create_person_cust_v2_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_v2_obj     IN            HZ_PERSON_CUST_V2_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_pc_obj              HZ_PERSON_CUST_V2_BO;
  BEGIN
    l_pc_obj := p_person_cust_v2_obj;
    do_create_person_cust_v2_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_person_cust_v2_obj     => l_pc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_person_id           => x_person_id
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_pc_obj;
    END IF;
  END create_person_cust_v2_bo;

-- PROCEDURE do_update_person_cust_v2_bo
  --
  -- DESCRIPTION
  --     Update person customer account.
  PROCEDURE do_update_person_cust_v2_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_cust_v2_obj     IN OUT NOCOPY HZ_PERSON_CUST_V2_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_person_os           VARCHAR2(30);
    l_person_osr          VARCHAR2(255);
    l_debug_prefix        VARCHAR2(30) := '';
    l_per_raise_event     BOOLEAN := FALSE;
    l_pc_raise_event      BOOLEAN := FALSE;
    l_cbm                 VARCHAR2(30);
    l_per_event_id        NUMBER;
    l_pc_event_id         NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_update_person_cust_v2_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_person_cust_v2_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    x_person_id := p_person_cust_v2_obj.person_obj.person_id;
    l_person_os := p_person_cust_v2_obj.person_obj.orig_system;
    l_person_osr:= p_person_cust_v2_obj.person_obj.orig_system_reference;

    -- check input party_id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_person_id,
      px_os              => l_person_os,
      px_osr             => l_person_osr,
      p_obj_type         => 'PERSON',
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- get person_id and then call
    l_per_raise_event := HZ_PARTY_BO_PVT.is_raising_update_event(
                           p_party_id          => x_person_id,
                           p_bo_code           => 'PERSON'
                         );

    l_pc_raise_event := HZ_PARTY_BO_PVT.is_raising_update_event(
                          p_party_id          => x_person_id,
                          p_bo_code           => 'PERSON_CUST'
                        );

    IF(l_per_raise_event) THEN
      -- Get event_id for person
      SELECT HZ_BUS_OBJ_TRACKING_S.nextval
      INTO l_per_event_id
      FROM DUAL;
    END IF;

    IF(l_pc_raise_event) THEN
      -- Get event_id for person customer
      SELECT HZ_BUS_OBJ_TRACKING_S.nextval
      INTO l_pc_event_id
      FROM DUAL;
    END IF;

    -- acknowledge update_organization_bo not to raise event
    HZ_PARTY_BO_PVT.G_CALL_UPDATE_CUST_BO := 'Y';
    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    HZ_PERSON_BO_PUB.do_update_person_bo(
      p_init_msg_list          => fnd_api.g_false,
      p_person_obj             => p_person_cust_v2_obj.person_obj,
      p_created_by_module      => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
      p_obj_source             => p_obj_source,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data,
      x_person_id              => x_person_id,
      x_person_os              => l_person_os,
      x_person_osr             => l_person_osr
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    IF((p_person_cust_v2_obj.account_objs IS NOT NULL) AND
       (p_person_cust_v2_obj.account_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.save_cust_accts(
        p_ca_v2_objs                => p_person_cust_v2_obj.account_objs,
        p_create_update_flag     => 'U',
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_parent_id              => x_person_id,
        p_parent_os              => l_person_os,
        p_parent_osr             => l_person_osr,
        p_parent_obj_type        => 'PERSON'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -- raise event
    IF(l_per_raise_event) THEN
      -- raise update org event
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_person_id,
        p_bo_code          => 'PERSON',
        p_create_or_update => 'U',
        p_obj_source       => p_obj_source,
        p_event_id         => l_per_event_id
      );
    END IF;

    IF(l_pc_raise_event) THEN
      -- raise update org cust event
      HZ_PARTY_BO_PVT.call_bes(
        p_party_id         => x_person_id,
        p_bo_code          => 'PERSON_CUST',
        p_create_or_update => 'U',
        p_obj_source       => p_obj_source,
        p_event_id         => l_pc_event_id
      );
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;
    HZ_PARTY_BO_PVT.G_CALL_UPDATE_CUST_BO := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_person_cust_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_person_cust_v2_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;
      HZ_PARTY_BO_PVT.G_CALL_UPDATE_CUST_BO := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
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
        hz_utility_v2pub.debug(p_message=>'do_update_person_cust_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_person_cust_v2_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;
      HZ_PARTY_BO_PVT.G_CALL_UPDATE_CUST_BO := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
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
        hz_utility_v2pub.debug(p_message=>'do_update_person_cust_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_update_person_cust_v2_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;
      HZ_PARTY_BO_PVT.G_CALL_UPDATE_CUST_BO := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
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
        hz_utility_v2pub.debug(p_message=>'do_update_person_cust_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_person_cust_v2_bo;

  PROCEDURE update_person_cust_v2_bo(
    p_person_cust_v2_obj     IN            HZ_PERSON_CUST_V2_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag     IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_pc_obj              HZ_PERSON_CUST_V2_BO;
  BEGIN
    l_pc_obj := p_person_cust_v2_obj;
    do_update_person_cust_v2_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_person_cust_v2_obj     => l_pc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_person_id           => x_person_id
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_pc_obj;
    END IF;
  END update_person_cust_v2_bo;

  -- PROCEDURE save_person_cust_v2_bo
  --
  -- DESCRIPTION
  --     Create or update person customer account.
  PROCEDURE do_save_person_cust_v2_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_v2_obj     IN OUT NOCOPY HZ_PERSON_CUST_V2_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_person_id                NUMBER;
    l_person_os                VARCHAR2(30);
    l_person_osr               VARCHAR2(255);
    l_debug_prefix             VARCHAR2(30) := '';
    l_create_update_flag       VARCHAR2(1);
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_person_cust_v2_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_person_id := p_person_cust_v2_obj.person_obj.person_id;
    l_person_os := p_person_cust_v2_obj.person_obj.orig_system;
    l_person_osr:= p_person_cust_v2_obj.person_obj.orig_system_reference;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id      => l_person_id,
                              p_entity_os      => l_person_os,
                              p_entity_osr     => l_person_osr,
                              p_entity_type    => 'HZ_PARTIES',
                              p_parent_id      => NULL,
                              p_parent_obj_type=> NULL );

    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_ID');
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'PERSON_CUST');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_create_update_flag = 'C') THEN
      do_create_person_cust_v2_bo(
        p_init_msg_list       => fnd_api.g_false,
        p_validate_bo_flag    => p_validate_bo_flag,
        p_person_cust_v2_obj     => p_person_cust_v2_obj,
        p_created_by_module   => p_created_by_module,
        p_obj_source          => p_obj_source,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        x_person_id           => x_person_id
      );
    ELSIF(l_create_update_flag = 'U') THEN
      do_update_person_cust_v2_bo(
        p_init_msg_list       => fnd_api.g_false,
        p_person_cust_v2_obj     => p_person_cust_v2_obj,
        p_created_by_module   => p_created_by_module,
        p_obj_source          => p_obj_source,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        x_person_id           => x_person_id
      );
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_person_cust_v2_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_person_cust_v2_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_person_cust_v2_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_person_cust_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_person_cust_v2_bo;

  PROCEDURE save_person_cust_v2_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_person_cust_v2_obj     IN            HZ_PERSON_CUST_V2_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_person_id           OUT NOCOPY    NUMBER
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_pc_obj              HZ_PERSON_CUST_V2_BO;
  BEGIN
    l_pc_obj := p_person_cust_v2_obj;
    do_save_person_cust_v2_bo(
      p_init_msg_list       => fnd_api.g_true,
      p_validate_bo_flag    => p_validate_bo_flag,
      p_person_cust_v2_obj     => l_pc_obj,
      p_created_by_module   => p_created_by_module,
      p_obj_source          => p_obj_source,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_person_id           => x_person_id
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_pc_obj;
    END IF;
  END save_person_cust_v2_bo;

--------------------------------------
  --
  -- PROCEDURE get_person_cust_v2_bo
  --
  -- DESCRIPTION
  --     Get a logical person customer.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
--       p_person_id          Person ID.
 --     p_person_os           Person orig system.
  --     p_person_osr         Person orig system reference.

  --   OUT:
  --     x_person_cust_v2_obj         Logical person customer record.
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
  --   1-FEB-2008   VSEGU                Created.
  --

/*
The Get Person Customer API Procedure is a retrieval service that returns a full Person Customer business object.
The user identifies a particular Person Customer business object using the TCA identifier and/or
the object Source System information. Upon proper validation of the object,
the full Person Customer business object is returned. The object consists of all data included within
the Person Customer business object, at all embedded levels. This includes the set of all data stored
in the TCA tables for each embedded entity.

To retrieve the appropriate embedded business objects within the Person Customer business object,
the Get procedure calls the equivalent procedure for the following embedded objects:

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments

Person			Y	N	get_person_bo
Customer Account	Y	Y	get_cust_acct_v2_bo	Called for each Customer Account object for the Person Customer

*/



 PROCEDURE get_person_cust_v2_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_person_id           IN            NUMBER,
    p_person_os		IN	VARCHAR2,
    p_person_osr		IN	VARCHAR2,
    x_person_cust_v2_obj     OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  )  is
 l_debug_prefix              VARCHAR2(30) := '';

  l_person_id  number;
  l_person_os  varchar2(30);
  l_person_osr varchar2(255);
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_v2_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_person_id := p_person_id;
    	l_person_os := p_person_os;
    	l_person_osr := p_person_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_person_id,
      		px_os              => l_person_os,
      		px_osr             => l_person_osr,
      		p_obj_type         => 'PERSON',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_PERSON_CUST_BO_PVT.get_person_cust_v2_bo(
    		p_init_msg_list   => fnd_api.g_false,
    		p_person_id => l_person_id,
    		p_action_type	  => NULL,
    		x_person_cust_v2_obj => x_person_cust_v2_obj,
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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_v2_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_v2_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_v2_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_person_cust_v2_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_person_cust_v2_bo(
    p_person_id           IN            NUMBER,
    p_person_os         IN      VARCHAR2,
    p_person_osr                IN      VARCHAR2,
    x_person_cust_v2_obj     OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_person_cust_v2_bo(
      p_init_msg_list   => fnd_api.g_true,
      p_person_id       => p_person_id,
      p_person_os       => p_person_os,
      p_person_osr      => p_person_osr,
      x_person_cust_v2_obj => x_person_cust_v2_obj,
      x_return_status   => x_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_person_cust_v2_bo;

--------------------------------------
  --
  -- PROCEDURE get_v2_person_custs_created
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person Customers created business event and
  --the procedure returns database objects of the type HZ_PERSON_CUST CUSTOMER_BO for all of
  --the Person Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_v2_objs   One or more created logical person customer.
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
  --   04-FEB-2008    VSEGU                Created.
  --



/*
The Get Person customers Created procedure is a service to retrieve all of the Person Customer business objects
whose creations have been captured by a logical business event. Each Person Customers Created
business event signifies that one or more Person Customer business objects have been created.
The caller provides an identifier for the Person Customers Created business event and the procedure
returns all of the Person Customer business objects from the business event. For each business object
creation captured in the business event, the procedure calls the generic Get operation:
HZ_PERSON_CUST_BO_PVT.get_person_cust_v2_bo

Gathering all of the returned business objects from those API calls, the procedure packages
them in a table structure and returns them to the caller.
*/


PROCEDURE get_v2_person_custs_created(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_cust_v2_objs    OUT NOCOPY    HZ_PERSON_CUST_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_custs_created(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'C',
			    p_bo_code => 'PERSON_CUST',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_PERSON_CUST_BO_PVT.get_v2_person_custs_created(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
    		x_person_cust_v2_objs  => x_person_cust_v2_objs,
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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_custs_created (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_custs_created(-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_custs_created(-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_custs_created(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_v2_person_custs_created(
    p_event_id            IN            NUMBER,
    x_person_cust_v2_objs    OUT NOCOPY    HZ_PERSON_CUST_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_v2_person_custs_created(
      p_init_msg_list       => fnd_api.g_true,
      p_event_id            => p_event_id,
      x_person_cust_v2_objs    => x_person_cust_v2_objs,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_v2_person_custs_created;


--------------------------------------
  --
  -- PROCEDURE get_v2_person_custs_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person Customers update business event and
  --the procedure returns database objects of the type HZ_PERSON_CUST_V2_BO for all of
  --the Person Customer business objects from the business event.

  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_v2_objs   One or more created logical person.
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



/*
The Get Person Customers Updated procedure is a service to retrieve all of the Person Customer business objects whose updates
have been captured by the logical business event. Each Person Customers Updated business event signifies that one or more Person
Customer business objects have been updated.
The caller provides an identifier for the Person Customers Update business event and the procedure returns database objects of
the type HZ_PERSON_CUST_V2_BO for all of the Person Customer business objects from the business event.
Gathering all of the returned database objects from those API calls, the procedure packages them in a table structure and returns
them to the caller.
*/

 PROCEDURE get_v2_person_custs_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    x_person_cust_v2_objs         OUT NOCOPY    HZ_PERSON_CUST_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_custs_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => null,
			    p_event_type => 'U',
			    p_bo_code => 'PERSON_CUST',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_PERSON_CUST_BO_PVT.get_v2_person_custs_updated(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
    		x_person_cust_v2_objs  => x_person_cust_v2_objs,
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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_custs_updated (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_custs_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_custs_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_custs_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_v2_person_custs_updated(
    p_event_id            IN            NUMBER,
    x_person_cust_v2_objs         OUT NOCOPY    HZ_PERSON_CUST_V2_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  )IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_v2_person_custs_updated(
      p_init_msg_list      => fnd_api.g_true,
      p_event_id           => p_event_id,
      x_person_cust_v2_objs   => x_person_cust_v2_objs,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_v2_person_custs_updated;

--------------------------------------
  --
  -- PROCEDURE get_v2_person_cust_updated
  --
  -- DESCRIPTION
  --The caller provides an identifier for the Person customer update business event and person id
  --the procedure returns one database object of the type HZ_PERSON_CUST_V2_BO
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_event_id           BES Event identifier.
  --     p_person_cust_id        Person customer identifier.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_person_cust_v2_obj       One updated logical person.
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
  --   04-FEB-2008     vsegu                Created.
  --

 PROCEDURE get_v2_person_cust_updated(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_event_id            IN           	NUMBER,
    p_person_cust_id           IN           NUMBER,
    x_person_cust_v2_obj         OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_cust_updated(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

	HZ_EXTRACT_BO_UTIL_PVT.validate_event_id(p_event_id => p_event_id,
			    p_party_id => p_person_cust_id,
			    p_event_type => 'U',
			    p_bo_code => 'PERSON_CUST',
			    x_return_status => x_return_status);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;

	HZ_EXTRACT_PERSON_CUST_BO_PVT.get_v2_person_cust_updated(
    		p_init_msg_list => fnd_api.g_false,
		p_event_id => p_event_id,
		p_person_cust_id  => p_person_cust_id,
    		x_person_cust_v2_obj  => x_person_cust_v2_obj,
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
        	hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_cust_updated (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_cust_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_cust_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_person_cust_bo_pub.get_v2_person_cust_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_v2_person_cust_updated(
    p_event_id            IN            NUMBER,
    p_person_cust_id           IN           NUMBER,
    x_person_cust_v2_obj         OUT NOCOPY    HZ_PERSON_CUST_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_v2_person_cust_updated(
      p_init_msg_list       => fnd_api.g_true,
      p_event_id            => p_event_id,
      p_person_cust_id      => p_person_cust_id,
      x_person_cust_v2_obj     => x_person_cust_v2_obj,
      x_return_status       => x_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_v2_person_cust_updated;

END hz_person_cust_bo_pub;

/
