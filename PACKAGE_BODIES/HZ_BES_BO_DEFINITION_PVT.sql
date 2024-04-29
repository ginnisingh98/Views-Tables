--------------------------------------------------------
--  DDL for Package Body HZ_BES_BO_DEFINITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BES_BO_DEFINITION_PVT" AS
/* $Header: ARHBODVB.pls 120.2 2006/05/01 18:54:58 smattegu noship $ */

/**
 * PROCEDURE update_bod
 *
 * DESCRIPTION
 *   Update Business Object Definition
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_business_object_code         Business Object Code.
 *     p_child_bo_code                Child BO Code.
 *     p_entity_name                  Entity Name.
 *     p_user_mandated_flag           User Mandated Flag.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 */

PROCEDURE update_bod (
  p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
  p_business_object_code      IN  VARCHAR2,
  p_child_bo_code             IN  VARCHAR2,
  p_entity_name               IN  VARCHAR2,
  p_user_mandated_flag        IN  VARCHAR2,
  p_object_version_number     IN OUT NOCOPY  NUMBER,
  x_return_status             OUT NOCOPY     VARCHAR2,
  x_msg_count                 OUT NOCOPY     NUMBER,
  x_msg_data                  OUT NOCOPY     VARCHAR2
) IS
  l_debug_prefix              VARCHAR2(30) := '';
  l_tmf                       VARCHAR2(1);
  l_umf                       VARCHAR2(1);
  l_ovn                       NUMBER;
  l_bvn                       NUMBER;
  l_bo_found                  BOOLEAN;
  l_count                     NUMBER;
  l_top_bo                    VARCHAR2(30);
  l_req_id                    NUMBER;
BEGIN
  --Standard start of API savepoint
  SAVEPOINT update_bod_pvt;

  -- Debug info.
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug(p_message=>'update_bod (+)',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- check whether record has been updated by another user. If not, lock it.
  BEGIN
    SELECT OBJECT_VERSION_NUMBER,
           USER_MANDATED_FLAG,
           TCA_MANDATED_FLAG
    INTO   l_ovn, l_umf, l_tmf
    FROM   HZ_BUS_OBJ_DEFINITIONS
    WHERE  business_object_code = p_business_object_code
    AND    entity_name = p_entity_name
    AND    nvl(child_bo_code, 'X') = nvl(p_child_bo_code, 'X')
    FOR UPDATE NOWAIT;

    IF NOT((p_object_version_number IS NULL AND l_ovn IS NULL) OR
           (p_object_version_number IS NOT NULL AND l_ovn IS NOT NULL AND
            p_object_version_number = l_ovn)) THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
      FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_BUS_OBJ_DEFINITIONS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'business object definition');
      FND_MESSAGE.SET_TOKEN('VALUE', 'Business Object Code: '||p_business_object_code||' Entity Name: '||p_entity_name||' Child BO Code: '||p_child_bo_code);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END;

  p_object_version_number := nvl(l_ovn, 1) + 1;

  IF(l_tmf = 'Y') THEN
    IF(p_child_bo_code IS NULL) THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_BES_BO_BOD_MAND_ENT_ERROR');
      FND_MESSAGE.SET_TOKEN('ENTITY_NAME', p_entity_name);
    ELSE
      FND_MESSAGE.SET_NAME('AR', 'HZ_BES_BO_BOD_MAND_OBJ_ERROR');
      FND_MESSAGE.SET_TOKEN('CHILD_BO_CODE', p_child_bo_code);
    END IF;
    FND_MESSAGE.SET_TOKEN('BO_CODE', p_business_object_code);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Not doing any update if the existing flag setting is same as
  -- user pass in
  IF NOT(l_umf = p_user_mandated_flag) THEN
    UPDATE HZ_BUS_OBJ_DEFINITIONS
    SET object_version_number = p_object_version_number,
        user_mandated_flag = p_user_mandated_flag,
        last_update_date = HZ_UTILITY_V2PUB.last_update_date,
        last_updated_by = HZ_UTILITY_V2PUB.last_updated_by,
        last_update_login = HZ_UTILITY_V2PUB.last_update_login
    WHERE business_object_code = p_business_object_code
    AND entity_name = p_entity_name
    AND nvl(child_bo_code, 'X') = nvl(p_child_bo_code, 'X');

    -- Update bo version number
    FOR l_count in 1..4 LOOP
      CASE
        WHEN l_count = 1 THEN l_top_bo := 'ORG';
        WHEN l_count = 2 THEN l_top_bo := 'PERSON';
        WHEN l_count = 3 THEN l_top_bo := 'ORG_CUST';
        WHEN l_count = 4 THEN l_top_bo := 'PERSON_CUST';
      END CASE;

      HZ_BES_BO_UTIL_PKG.entity_in_bo(
        p_bo_code       => l_top_bo,
        p_ebo_code       =>p_business_object_code,
        p_child_bo_code => p_child_bo_code,
        p_entity_name   => p_entity_name,
        x_return_status => l_bo_found );

      IF(l_bo_found) THEN
        UPDATE HZ_BUS_OBJ_DEFINITIONS
        SET bo_version_number = nvl(bo_version_number,1) + 1,
            last_update_date = HZ_UTILITY_V2PUB.last_update_date,
            last_updated_by = HZ_UTILITY_V2PUB.last_updated_by,
            last_update_login = HZ_UTILITY_V2PUB.last_update_login
        WHERE business_object_code = l_top_bo
        AND root_node_flag = 'Y'
        AND child_bo_code IS NULL;
      END IF;
    END LOOP;

    --Run Concurrent Request
    --TCA Business Object Events: Generate Infrastructure Packages Program
    l_req_id := FND_REQUEST.SUBMIT_REQUEST(
                  'AR', 'ARHBOGEN', 'TCA BES - Generate Infrastructure',
                  sysdate, FALSE);

    IF(l_req_id IS NULL or l_req_id = 0) THEN
      FND_MESSAGE.SET_NAME('AR', 'AR_CUST_CONC_ERROR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  --Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

  -- Debug info.
  IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                                           p_msg_data=>x_msg_data,
                                           p_msg_type=>'WARNING',
                                           p_msg_level=>fnd_log.level_exception);
  END IF;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug(p_message=>'update_bod (-)',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_bod_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
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
      hz_utility_v2pub.debug(p_message=>'update_bod (-)',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_bod_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
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
      hz_utility_v2pub.debug(p_message=>'update_bod (-)',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO update_bod_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
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
      hz_utility_v2pub.debug(p_message=>'update_bod (-)',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
    END IF;
END update_bod;

END HZ_BES_BO_DEFINITION_PVT;

/
