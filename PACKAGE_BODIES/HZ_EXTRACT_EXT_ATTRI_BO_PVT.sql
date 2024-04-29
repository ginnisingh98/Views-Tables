--------------------------------------------------------
--  DDL for Package Body HZ_EXTRACT_EXT_ATTRI_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTRACT_EXT_ATTRI_BO_PVT" AS
/*$Header: ARHEEXVB.pls 120.7 2007/11/27 10:35:36 kguggila ship $ */
/*
 * This package contains the private APIs for ssm information.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname customer account site
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf cGet APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_ext_attribute_bos
  --
  -- DESCRIPTION
  --     Get extensibility attributes information.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
--       p_ext_object_id          ext object ID.ex: party_id, party_site_id
  --     p_ext_object_name        ext object name. ex: HZ_PERSON_PROFILES, etc
  --
  --   OUT:
  --    x_ext_attribute_objs  Table of extensibility attribute objects.
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
  --   15-Aug-2005   AWU                Created.
  --


 FUNCTION get_extension_id(p_ext_object_name in varchar2, p_ext_object_id in number, p_attr_group_id in number) return number is

	cursor org_csr is
		select extension_id
		from hz_org_profiles_ext_b
		where organization_profile_id = p_ext_object_id
		and attr_group_id = p_attr_group_id;

	cursor person_csr is
		select extension_id
		from hz_per_profiles_ext_b
		where person_profile_id = p_ext_object_id
		and attr_group_id = p_attr_group_id;

	cursor psite_csr is
		select extension_id
		from hz_party_sites_ext_b
		where party_site_id = p_ext_object_id
		and attr_group_id = p_attr_group_id;

	cursor loc_csr is
		select extension_id
		from hz_locations_ext_b
		where location_id = p_ext_object_id
		and attr_group_id = p_attr_group_id;

l_extension_id number;

begin
	 if p_ext_object_name = 'HZ_ORGANIZATION_PROFILES'
    	 then
		open org_csr;
		fetch org_csr into l_extension_id;
		close org_csr;
		return l_extension_id;
    	 elsif p_ext_object_name = 'HZ_PERSON_PROFILES'
    	 then
		open person_csr;
		fetch person_csr into l_extension_id;
		close person_csr;
		return l_extension_id;
    	 elsif p_ext_object_name = 'HZ_PARTY_SITES'
    	 then
		open psite_csr;
		fetch psite_csr into l_extension_id;
		close psite_csr;
		return l_extension_id;

    	 elsif p_ext_object_name = 'HZ_LOCATIONS'
    	 then
		open loc_csr;
		fetch loc_csr into l_extension_id;
		close loc_csr;
		return l_extension_id;
	 end if;

end;

 PROCEDURE get_ext_attribute_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_ext_object_id           IN            NUMBER,
    p_ext_object_name           IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_ext_attribute_objs          OUT NOCOPY    HZ_EXT_ATTRIBUTE_OBJ_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is

	cursor c1 is
	--Start bug 6503079
		/*select EGO_ATTR_GROUP_REQUEST_OBJ(
			ATTR_GROUP_ID,
 			APPLICATION_ID,
 			ATTR_GROUP_TYPE,
 			ATTR_GROUP_NAME,
			NULL,
			NULL,
			NULL,
			NULL)*/
		select EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Request_Obj(
				ATTR_GROUP_ID,
	 			APPLICATION_ID,
	 			ATTR_GROUP_TYPE,
	 			ATTR_GROUP_NAME,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL)
	--End bug 6503079
		from ego_obj_attr_grp_assocs_v
		where object_name = p_ext_object_name;

l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_attr_group_request_table EGO_ATTR_GROUP_REQUEST_TABLE;
l_attributes_row_table EGO_USER_ATTR_ROW_TABLE;
l_attributes_data_table EGO_USER_ATTR_DATA_TABLE;
l_pk_name varchar2(30);
l_errorcode varchar2(30);
l_parent_object_type varchar2(30);
l_row number := 1;
l_debug_prefix              VARCHAR2(30) := '';
begin

    l_attr_group_request_table := EGO_ATTR_GROUP_REQUEST_TABLE();
    l_attr_group_request_table.extend;

    x_ext_attribute_objs := HZ_EXT_ATTRIBUTE_OBJ_TBL();
    -- x_ext_attribute_objs.extend;

    open c1;
    fetch c1 BULK COLLECT into l_attr_group_request_table;
    close c1;

    if p_ext_object_name = 'HZ_ORGANIZATION_PROFILES'
    then
	l_pk_name := 'ORGANIZATION_PROFILE_ID';
	l_parent_object_type := 'ORG';
    elsif p_ext_object_name = 'HZ_PERSON_PROFILES'
    then
	l_pk_name := 'PERSON_PROFILE_ID';
	l_parent_object_type := 'PERSON';
    elsif p_ext_object_name = 'HZ_PARTY_SITES'
    then
	l_pk_name := 'PARTY_SITE_ID';
	l_parent_object_type := HZ_EXTRACT_BO_UTIL_PVT.get_parent_object_type('HZ_PARTIES',P_EXT_OBJECT_ID);
    elsif p_ext_object_name = 'HZ_LOCATIONS'
    then
	l_pk_name := 'LOCATION_ID';
	l_parent_object_type := 'PARTY_SITE';
    end if;

    l_pk_column_name_value_pairs :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY(
       EGO_COL_NAME_VALUE_PAIR_OBJ(l_pk_name, TO_CHAR(p_ext_object_id ))
      );

 EGO_USER_ATTRS_DATA_PUB.Get_User_Attrs_Data(
      p_api_version                   => 1.0
     ,p_object_name                   => p_ext_object_name
     ,p_pk_column_name_value_pairs    => l_pk_column_name_value_pairs
     ,p_attr_group_request_table      => l_attr_group_request_table
     ,p_user_privileges_on_object     => NULL
     ,p_entity_id                     => NULL
     ,p_entity_index                  => NULL
     ,p_entity_code                   => NULL
     ,p_debug_level                   => NULL
     ,p_init_error_handler            => NULL
     ,p_init_fnd_msg_list             => NULL
     ,p_add_errors_to_fnd_stack       => NULL
     ,p_commit                        => NULL
     ,x_attributes_row_table          => l_attributes_row_table
     ,x_attributes_data_table         => l_attributes_data_table
     ,x_return_status                 => x_return_status
     ,x_errorcode                     => l_errorcode
     ,x_msg_count                     => x_msg_count
     ,x_msg_data                      => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	FND_MESSAGE.SET_NAME('AR', 'ERROR IN EGO_USER_ATTRS_DATA_PUB.Get_User_Attrs_Data');
	FND_MSG_PUB.ADD;
      	RAISE FND_API.G_EXC_ERROR;
    END IF;
if (l_attributes_row_table is not null) and (l_attributes_data_table is not null)
then
    for i in 1..l_attributes_row_table.count loop
	for j in 1..l_attributes_data_table.count loop
		if l_attributes_row_table(i).ROW_IDENTIFIER = l_attributes_data_table(j).ROW_IDENTIFIER
		then
			x_ext_attribute_objs.extend;
			x_ext_attribute_objs(l_row) := HZ_EXT_ATTRIBUTE_OBJ(
                                -- row_identifier return is the extension id
				--get_extension_id(p_ext_object_name, p_ext_object_id,l_attributes_row_table(i).ATTR_GROUP_ID),
				l_attributes_row_table(i).ROW_IDENTIFIER,
                                null,
				l_attributes_row_table(i).ROW_IDENTIFIER,
				l_attributes_row_table(i).ATTR_GROUP_NAME,
				p_action_type,
				l_parent_object_type,
				p_ext_object_id,
				l_attributes_data_table(j).ATTR_NAME,
				l_attributes_data_table(j).ATTR_VALUE_STR,
				l_attributes_data_table(j).ATTR_VALUE_NUM,
				l_attributes_data_table(j).ATTR_VALUE_DATE,
				l_attributes_data_table(j).ATTR_DISP_VALUE,
				l_attributes_row_table(i).ATTR_GROUP_TYPE,
				l_attributes_row_table(i).ATTR_GROUP_ID);
		  l_row := l_row + 1;
		end if;
		end loop;
	end loop;
 end if;
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
        hz_utility_v2pub.debug(p_message=>'get_organizations_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_organizations_updated(-)',
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
        hz_utility_v2pub.debug(p_message=>'get_organizations_updated(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

END HZ_EXTRACT_EXT_ATTRI_BO_PVT;

/
