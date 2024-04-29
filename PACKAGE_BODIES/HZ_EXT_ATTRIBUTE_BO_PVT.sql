--------------------------------------------------------
--  DDL for Package Body HZ_EXT_ATTRIBUTE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXT_ATTRIBUTE_BO_PVT" AS
/*$Header: ARHBEXVB.pls 120.5 2007/11/27 10:32:12 kguggila ship $ */

  -- PROCEDURE save_ext_attributes
  --
  -- DESCRIPTION
  --     Create or update extensibility attributes.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_ext_attr_objs      List of extensibility attribute objects.
  --     p_parent_obj_id      Parent object Id.
  --     p_parent_obj_type    Parent object type.
  --     p_create_or_update   Create or update flag.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_errorcode          Error code.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_ext_attributes(
    p_ext_attr_objs           IN         HZ_EXT_ATTRIBUTE_OBJ_TBL,
    p_parent_obj_id           IN         NUMBER,
    p_parent_obj_type         IN         VARCHAR2,
    p_create_or_update        IN         VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_errorcode               OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30);
    l_user_attr_data_table    EGO_USER_ATTR_DATA_TABLE;
    l_user_attr_row_table     EGO_USER_ATTR_ROW_TABLE;
    l_attr_group_type         VARCHAR2(40);
    l_trans_type              VARCHAR2(10);
    l_current_row             NUMBER;
    l_row_count               NUMBER;
    l_failed_row_id_list      VARCHAR2(10000);
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_ext_attributes_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_ext_attributes(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    CASE
      WHEN p_parent_obj_type = 'ORG' THEN
        l_attr_group_type := 'HZ_ORG_PROFILES_GROUP';
      WHEN p_parent_obj_type = 'PERSON' THEN
        l_attr_group_type := 'HZ_PERSON_PROFILES_GROUP';
      WHEN p_parent_obj_type = 'PARTY_SITE' THEN
        l_attr_group_type := 'HZ_PARTY_SITES_GROUP';
      WHEN p_parent_obj_type = 'LOCATION' THEN
        l_attr_group_type := 'HZ_LOCATIONS_GROUP';
    END CASE;

    IF(p_create_or_update = 'C') THEN
      l_trans_type := EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE;
    ELSE
      l_trans_type := EGO_USER_ATTRS_DATA_PVT.G_SYNC_MODE;
    END IF;

    -- Initialize Row and Data Table
    l_user_attr_row_table := EGO_USER_ATTR_ROW_TABLE();
    l_user_attr_data_table := EGO_USER_ATTR_DATA_TABLE();
    l_current_row := NULL;
    l_row_count := 1;
    FOR i IN 1..p_ext_attr_objs.COUNT LOOP
      IF(p_ext_attr_objs(i).row_identifier IS NULL) THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE', 'hz_ext_attribute_bo_pvt.save_ext_attributes');
        FND_MESSAGE.SET_TOKEN('ERROR', 'row identifier is null');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF((l_current_row IS NULL) OR
         (NOT (l_current_row = p_ext_attr_objs(i).row_identifier))) THEN
        l_user_attr_row_table.EXTEND;
       -- Start bug 6503079
	/*l_user_attr_row_table(l_row_count) := EGO_USER_ATTR_ROW_OBJ(
                                                p_ext_attr_objs(i).row_identifier, null, 222, l_attr_group_type,
                                                p_ext_attr_objs(i).attr_group_name,
                                                null, null, null, l_trans_type
                                              );*/
	  l_user_attr_row_table(l_row_count) :=  EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(
									p_ext_attr_objs(i).row_identifier,
	                                                                null,
									222,
									l_attr_group_type,
									p_ext_attr_objs(i).attr_group_name,
									null,
									null,
									null,
									null,
									null,
									null,
									l_trans_type);
	-- End bug 6503079
        l_current_row := p_ext_attr_objs(i).row_identifier;
        l_row_count := l_row_count + 1;
      END IF;

      l_user_attr_data_table.EXTEND;
      l_user_attr_data_table(i) := EGO_USER_ATTR_DATA_OBJ(
                                     p_ext_attr_objs(i).row_identifier,
                                     p_ext_attr_objs(i).attr_name,
                                     p_ext_attr_objs(i).attr_value_str,
                                     p_ext_attr_objs(i).attr_value_num,
                                     p_ext_attr_objs(i).attr_value_date,
                                     null, null, null
                                   );
    END LOOP;

    CASE
      WHEN p_parent_obj_type = 'ORG' THEN
        HZ_EXTENSIBILITY_PUB.Process_Organization_Record(
          p_api_version               => 1.0,
          p_org_profile_id            => p_parent_obj_id,
          p_attributes_row_table      => l_user_attr_row_table,
          p_attributes_data_table     => l_user_attr_data_table,
          p_add_errors_to_fnd_stack   => FND_API.G_TRUE,
          x_failed_row_id_list        => l_failed_row_id_list,
          x_return_status             => x_return_status,
          x_errorcode                 => x_errorcode,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );
      WHEN p_parent_obj_type = 'PERSON' THEN
        HZ_EXTENSIBILITY_PUB.Process_Person_Record(
          p_api_version               => 1.0,
          p_person_profile_id         => p_parent_obj_id,
          p_attributes_row_table      => l_user_attr_row_table,
          p_attributes_data_table     => l_user_attr_data_table,
          p_add_errors_to_fnd_stack   => FND_API.G_TRUE,
          x_failed_row_id_list        => l_failed_row_id_list,
          x_return_status             => x_return_status,
          x_errorcode                 => x_errorcode,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );
      WHEN p_parent_obj_type = 'PARTY_SITE' THEN
        HZ_EXTENSIBILITY_PUB.Process_PartySite_Record(
          p_api_version               => 1.0,
          p_party_site_id             => p_parent_obj_id,
          p_attributes_row_table      => l_user_attr_row_table,
          p_attributes_data_table     => l_user_attr_data_table,
          p_add_errors_to_fnd_stack   => FND_API.G_TRUE,
          x_failed_row_id_list        => l_failed_row_id_list,
          x_return_status             => x_return_status,
          x_errorcode                 => x_errorcode,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );
      WHEN p_parent_obj_type = 'LOCATION' THEN
        HZ_EXTENSIBILITY_PUB.Process_Location_Record(
          p_api_version               => 1.0,
          p_location_id               => p_parent_obj_id,
          p_attributes_row_table      => l_user_attr_row_table,
          p_attributes_data_table     => l_user_attr_data_table,
          p_add_errors_to_fnd_stack   => FND_API.G_TRUE,
          x_failed_row_id_list        => l_failed_row_id_list,
          x_return_status             => x_return_status,
          x_errorcode                 => x_errorcode,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );
    END CASE;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'hz_ext_attribute_bo_pvt.save_ext_attributes');
      FND_MESSAGE.SET_TOKEN('ERROR', 'save ext attributes, parent type and id: '||p_parent_obj_type||' '||p_parent_obj_id);
      FND_MSG_PUB.ADD;
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
        hz_utility_v2pub.debug(p_message=>'save_ext_attributes(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_ext_attributes_pvt;
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
        hz_utility_v2pub.debug(p_message=>'save_ext_attributes(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_ext_attributes_pvt;
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
        hz_utility_v2pub.debug(p_message=>'save_ext_attributes(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_ext_attributes_pvt;
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
        hz_utility_v2pub.debug(p_message=>'save_ext_attributes(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_ext_attributes;

END hz_ext_attribute_bo_pvt;

/
