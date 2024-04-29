--------------------------------------------------------
--  DDL for Package Body FND_OID_USERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OID_USERS" as
/* $Header: AFSCOURB.pls 120.6 2005/11/03 16:12:34 ssallaka noship $ */
--
/*****************************************************************************/
-- Start of Package Globals

G_MODULE_SOURCE   constant varchar2(80) := 'fnd.plsql.oid.fnd_oid_users.';

-- End of Package Globals
--
-------------------------------------------------------------------------------
procedure hz_create(
    p_ldap_message  in          fnd_oid_util.ldap_message_type
  , x_return_status out nocopy  varchar2
) is

  l_module_source varchar2(256);
  l_tca_error     exception;
  x_location_id   number;
  l_party_return_status  varchar2(1);

begin
  l_module_source := G_MODULE_SOURCE || 'hz_create';

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
      'p_ldap_message.sn = ' || p_ldap_message.sn
      || ', p_ldap_message.givenName = ' || p_ldap_message.givenName
      || ', p_ldap_message.telephoneNumber = ' || p_ldap_message.telephoneNumber
      || ', p_ldap_message.homePhone = ' || p_ldap_message.homePhone
      || ', p_ldap_message.mail = ' || p_ldap_message.mail
      || ', p_ldap_message.c = ' || p_ldap_message.c
      || ', p_ldap_message.street = ' || p_ldap_message.street);
  end if;

  if ( (p_ldap_message.sn is not null)
      or (p_ldap_message.givenName is not null) )
  then
    fnd_oid_users.create_party(p_ldap_message => p_ldap_message,
                               x_return_status => x_return_status);
  end if;

  if (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Party ' ||
       p_ldap_message.givenName || ', ' || p_ldap_message.sn || ' created successfully');
     end if;

    if (p_ldap_message.telephoneNumber is not null)
    then
      fnd_oid_users.create_phone_contact_point(
                              p_ldap_message => p_ldap_message,
                              p_contact_point_purpose => G_BUSINESS,
                              x_return_status => x_return_status);
    end if;

    if (p_ldap_message.homePhone is not null)
    then
      fnd_oid_users.create_phone_contact_point(
                              p_ldap_message => p_ldap_message,
                              p_contact_point_purpose => G_PERSONAL,
                              x_return_status => x_return_status);
    end if;

    if (p_ldap_message.mail is not null)
    then
      fnd_oid_users.create_email_contact_point(
                              p_ldap_message => p_ldap_message,
                              x_return_status => x_return_status);
    end if;

    if ( (p_ldap_message.c is not null) and (p_ldap_message.street is not null) )
    then
      fnd_oid_users.create_location(
                              p_ldap_message => p_ldap_message,
                              x_return_status => x_return_status);
    end if;
  else
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Party creation ' ||
       p_ldap_message.givenName || ', ' || p_ldap_message.sn || ' failed.');
     end if;
  end if;
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
    when others then
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
      end if;
end hz_create;
--
-------------------------------------------------------------------------------
procedure create_party(
    p_ldap_message  in          fnd_oid_util.ldap_message_type
  , x_return_status out nocopy  varchar2
) is

  l_module_source varchar2(256);
  l_orig_sys_rec  hz_orig_system_ref_pub.orig_sys_reference_rec_type;
  l_tca_error     exception;
  x_person_rec    hz_party_v2pub.person_rec_type;
  x_msg_count     number;
  x_msg_data      varchar2(2000);
  x_party_id      number;
  x_party_number  varchar2(2000);
  x_profile_id    number;
  x_customer_id   number;
  x_employee_id   number;

begin
  l_module_source := G_MODULE_SOURCE || 'create_party';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  fnd_oid_users.get_person_rec(p_ldap_message => p_ldap_message,
                               p_action_type => G_CREATE,
                               x_person_rec => x_person_rec,
                               x_return_status => x_return_status);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  hz_party_v2pub.create_person(p_init_msg_list => fnd_api.G_TRUE,
                               p_person_rec => x_person_rec,
                               x_party_id => x_party_id,
                               x_party_number => x_party_number,
                               x_profile_id => x_profile_id,
                               x_return_status => x_return_status,
                               x_msg_count => x_msg_count,
                               x_msg_data => x_msg_data);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  fnd_oid_users.create_orig_system_reference(
                               p_ldap_message => p_ldap_message,
                               p_tag => G_PERSON,
                               p_owner_table_name => G_HZ_PARTIES,
                               p_owner_table_id => x_party_id,
                               p_status => G_ACTIVE,
                               x_return_status => x_return_status);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

    --Bug fix 4311778
  fnd_user_pkg.DERIVE_CUSTOMER_EMPLOYEE_ID(
    user_name       => p_ldap_message.object_name,
    person_party_id => x_party_id,
    customer_id => x_customer_id,
    employee_id => x_employee_id);

  update fnd_user
  set person_party_id = x_party_id, customer_id = x_customer_id,
      employee_id = x_employee_id
  where user_name = p_ldap_message.object_name;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Linked user '
      || p_ldap_message.object_name || ' to party number ' || x_party_id);
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      if (x_msg_count > 0)
      then
        for i in 1..x_msg_count
        loop
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, x_msg_data);
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, i || '.'
            || SubStr(fnd_msg_pub.get(p_encoded => fnd_api.g_false), 1, 255));
        end loop;
      else
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
          , 'x_return_status = ' || x_return_status);
      end if;
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;

end create_party;
--
-------------------------------------------------------------------------------
procedure create_phone_contact_point(
    p_ldap_message          in          fnd_oid_util.ldap_message_type
  , p_contact_point_purpose in          varchar2
  , x_return_status         out nocopy  varchar2
) is

  l_module_source     varchar2(256);
  x_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
  l_phone_rec         hz_contact_point_v2pub.phone_rec_type;
  l_tca_error         exception;
  x_contact_point_id  number;
  x_msg_count         number;
  x_msg_data          varchar2(2000);

begin
  l_module_source := G_MODULE_SOURCE || 'create_phone_contact_point';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  fnd_oid_users.get_contact_point_rec(
                        p_ldap_message => p_ldap_message,
                        p_contact_point_type => G_PHONE,
                        p_contact_point_purpose => p_contact_point_purpose,
                        p_action_type => G_CREATE,
                        x_contact_point_rec => x_contact_point_rec,
                        x_return_status => x_return_status);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  l_phone_rec.phone_line_type := G_GEN;

  if (p_contact_point_purpose = G_BUSINESS)
  then
    l_phone_rec.raw_phone_number := p_ldap_message.telephoneNumber;
  elsif (p_contact_point_purpose = G_PERSONAL)
  then
    l_phone_rec.phone_number := p_ldap_message.homePhone;
  end if;

  hz_contact_point_v2pub.create_phone_contact_point(
                              p_init_msg_list => fnd_api.G_TRUE,
                              p_contact_point_rec => x_contact_point_rec,
                              p_phone_rec => l_phone_rec,
                              x_contact_point_id => x_contact_point_id,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  fnd_oid_users.create_orig_system_reference(
                               p_ldap_message => p_ldap_message,
                               p_tag => p_contact_point_purpose,
                               p_owner_table_name => G_HZ_CONTACT_POINTS,
                               p_owner_table_id => x_contact_point_id,
                               p_status => G_ACTIVE,
                               x_return_status => x_return_status);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      if (x_msg_count > 0)
      then
        for i in 1..x_msg_count
        loop
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, x_msg_data);
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, i || '.'
            || SubStr(fnd_msg_pub.get(p_encoded => fnd_api.g_false), 1, 255));
        end loop;
      else
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
          , 'x_return_status = ' || x_return_status);
      end if;
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end create_phone_contact_point;
--
-------------------------------------------------------------------------------
procedure create_email_contact_point(
    p_ldap_message  in          fnd_oid_util.ldap_message_type
  , x_return_status out nocopy  varchar2
) is

  l_module_source     varchar2(256);
  p_init_msg_list     varchar2(2000);
  l_tca_error         exception;
  x_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
  p_email_rec         hz_contact_point_v2pub.email_rec_type;
  x_contact_point_id  number;
  x_msg_count         number;
  x_msg_data          varchar2(2000);

begin
  l_module_source := G_MODULE_SOURCE || 'create_email_contact_point';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  fnd_oid_users.get_contact_point_rec(
                        p_ldap_message => p_ldap_message,
                        p_contact_point_type => G_EMAIL,
                        p_contact_point_purpose => NULL,
                        p_action_type => G_CREATE,
                        x_contact_point_rec => x_contact_point_rec,
                        x_return_status => x_return_status);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  p_email_rec.email_address := p_ldap_message.mail;

  hz_contact_point_v2pub.create_email_contact_point(
                        p_init_msg_list => fnd_api.G_TRUE,
                        p_contact_point_rec => x_contact_point_rec,
                        p_email_rec => p_email_rec,
                        x_contact_point_id => x_contact_point_id,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  fnd_oid_users.create_orig_system_reference(
                        p_ldap_message => p_ldap_message,
                        p_tag => G_EMAIL,
                        p_owner_table_name => G_HZ_CONTACT_POINTS,
                        p_owner_table_id => x_contact_point_id,
                        p_status => G_ACTIVE,
                        x_return_status => x_return_status);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      if (x_msg_count > 0)
      then
        for i in 1..x_msg_count
        loop
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, x_msg_data);
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, i || '.'
            || SubStr(fnd_msg_pub.get(p_encoded => fnd_api.g_false), 1, 255));
        end loop;
      else
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
          , 'x_return_status = ' || x_return_status);
      end if;
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end create_email_contact_point;
--
-------------------------------------------------------------------------------
procedure create_location(
    p_ldap_message  in          fnd_oid_util.ldap_message_type
  , x_return_status out nocopy  varchar2
) is

  l_module_source varchar2(256);
  p_init_msg_list varchar2(2000);
  l_tca_error     exception;
  x_location_rec  hz_location_v2pub.location_rec_type;
  x_msg_count     number;
  x_msg_data      varchar2(2000);
  x_location_id   number;

begin
  l_module_source := G_MODULE_SOURCE || 'create_location';

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  fnd_oid_users.get_location_rec(p_ldap_message => p_ldap_message,
                                 x_location_rec => x_location_rec);
  --Verify whether country is null since get_location_rec may nullify country
  if (x_location_rec.country is not null) then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Country is not null' || x_location_rec.country);
    end if;
    hz_location_v2pub.create_location(p_init_msg_list => fnd_api.G_TRUE,
                                    p_location_rec => x_location_rec,
                                    x_location_id => x_location_id,
                                    x_return_status => x_return_status,
                                    x_msg_count => x_msg_count,
                                    x_msg_data => x_msg_data);

    if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
    then
      raise l_tca_error;
    end if;

    fnd_oid_users.create_party_site(
            p_ldap_message => p_ldap_message,
            p_location_id => x_location_id,
            x_return_status => x_return_status);

    if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
    then
      raise l_tca_error;
    end if;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      if (x_msg_count > 0)
      then
        for i in 1..x_msg_count
        loop
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, x_msg_data);
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, i || '.'
            || SubStr(fnd_msg_pub.get(p_encoded => fnd_api.g_false), 1, 255));
        end loop;
      else
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
          , 'x_return_status = ' || x_return_status);
      end if;
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end create_location;
--
-------------------------------------------------------------------------------
procedure create_party_site(
    p_ldap_message  in          fnd_oid_util.ldap_message_type
  , p_location_id   in          number
  , x_return_status out nocopy  varchar2
) is

  l_module_source     varchar2(256);
  p_init_msg_list     varchar2(2000);
  l_tca_error         exception;
  x_party_site_rec    hz_party_site_v2pub.party_site_rec_type;
  x_msg_count         number;
  x_msg_data          varchar2(2000);
  x_party_site_id     number;
  x_party_site_number varchar2(2000);

begin
  l_module_source := G_MODULE_SOURCE || 'create_party_site';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  fnd_oid_users.get_party_site_rec(
                              p_ldap_message => p_ldap_message,
                              p_action_type => G_CREATE,
                              x_party_site_rec => x_party_site_rec,
                              x_return_status => x_return_status);
  x_party_site_rec.location_id := p_location_id;

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  hz_party_site_v2pub.create_party_site(
                              p_init_msg_list => fnd_api.G_TRUE,
                              P_party_site_rec => x_party_site_rec,
                              x_party_site_id => x_party_site_id,
                              x_party_site_number => x_party_site_number,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  fnd_oid_users.create_orig_system_reference(
                               p_ldap_message => p_ldap_message,
                               p_tag => G_LOCATION,
                               p_owner_table_name => G_HZ_PARTY_SITES,
                               p_owner_table_id => x_party_site_id,
                               p_status => G_ACTIVE,
                               x_return_status => x_return_status);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      if (x_msg_count > 0)
      then
        for i in 1..x_msg_count
        loop
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, x_msg_data);
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, i || '.'
            || SubStr(fnd_msg_pub.get(p_encoded => fnd_api.g_false), 1, 255));
        end loop;
      else
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
          , 'x_return_status = ' || x_return_status);
      end if;
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end create_party_site;
--
-------------------------------------------------------------------------------
procedure hz_update(
    p_ldap_message  in          fnd_oid_util.ldap_message_type
  , x_return_status out nocopy  varchar2
) is

  l_module_source varchar2(256);
  l_party_id      number;

begin
  l_module_source := G_MODULE_SOURCE || 'hz_update';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  if ((p_ldap_message.sn is not null and p_ldap_message.sn <> G_UNKNOWN)
      or (p_ldap_message.givenName is not null and p_ldap_message.givenName <> G_UNKNOWN))
  then
    fnd_oid_users.update_party(p_ldap_message => p_ldap_message,
                               x_return_status => x_return_status);
  end if;
  --adding a check for '*UNKNOWN*' string as well.
  -- bug 4411121
  if (p_ldap_message.telephoneNumber is not null and p_ldap_message.telephoneNumber <> G_UNKNOWN)
  then
    fnd_oid_users.update_phone_contact_point(
                            p_ldap_message => p_ldap_message,
                            p_contact_point_purpose => G_BUSINESS,
                            x_return_status => x_return_status);
  end if;

  if (p_ldap_message.homePhone is not null and p_ldap_message.homePhone <> G_UNKNOWN)
  then
    fnd_oid_users.update_phone_contact_point(
                            p_ldap_message => p_ldap_message,
                            p_contact_point_purpose => G_PERSONAL,
                            x_return_status => x_return_status);
  end if;

  if (p_ldap_message.mail is not null and p_ldap_message.mail <> G_UNKNOWN)
  then
    fnd_oid_users.update_email_contact_point(
                            p_ldap_message => p_ldap_message,
                            x_return_status => x_return_status);
  end if;

  if ( (p_ldap_message.c is not null and p_ldap_message.c <> G_UNKNOWN) or
       (p_ldap_message.street is not null and p_ldap_message.street <> G_UNKNOWN) or
       (p_ldap_message.postalCode is not null and p_ldap_message.postalCode <> G_UNKNOWN) or
       (p_ldap_message.st is not null and p_ldap_message.st <> G_UNKNOWN) or
       (p_ldap_message.l is not null and p_ldap_message.l <> G_UNKNOWN) or
       (p_ldap_message.physicalDeliveryOfficeName is not null and p_ldap_message.physicalDeliveryOfficeName <> G_UNKNOWN)
       )
  then
    fnd_oid_users.update_party_site(p_ldap_message => p_ldap_message,
                                    x_return_status => x_return_status);

    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
     fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Update party site status: ' || x_return_status);
    end if;

  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
    when others then
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
      end if;

end hz_update;
--
-------------------------------------------------------------------------------
procedure update_party(
    p_ldap_message  in          fnd_oid_util.ldap_message_type
  , x_return_status out nocopy  varchar2
) is

  l_module_source         varchar2(256);
  l_object_version_number number;
  l_tca_error             exception;
  x_person_rec            hz_party_v2pub.person_rec_type;
  x_msg_count             number;
  x_msg_data              varchar2(2000);
  x_party_id              number;
  x_party_number          varchar2(2000);
  x_profile_id            number;

begin
  l_module_source := G_MODULE_SOURCE || 'update_party';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  fnd_oid_users.get_person_rec(p_ldap_message => p_ldap_message,
                               p_action_type => G_UPDATE,
                               x_person_rec => x_person_rec,
                               x_return_status => x_return_status);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  select object_version_number
  into l_object_version_number
  from hz_parties where party_id = x_person_rec.party_rec.party_id;

  hz_party_v2pub.update_person(
      p_init_msg_list => fnd_api.G_TRUE
    , p_person_rec => x_person_rec
    , p_party_object_version_number => l_object_version_number
    , x_profile_id => x_profile_id
    , x_return_status => x_return_status
    , x_msg_count => x_msg_count
    , x_msg_data => x_msg_data);

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      if (x_msg_count > 0)
      then
        for i in 1..x_msg_count
        loop
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, x_msg_data);
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, i || '.'
            || SubStr(fnd_msg_pub.get(p_encoded => fnd_api.g_false), 1, 255));
        end loop;
      else
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
          , 'x_return_status = ' || x_return_status);
      end if;
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end update_party;
--
-------------------------------------------------------------------------------
procedure update_phone_contact_point(
    p_ldap_message          in          fnd_oid_util.ldap_message_type
  , p_contact_point_purpose in          varchar2
  , x_return_status         out nocopy  varchar2
) is

  l_module_source         varchar2(256);
  l_object_version_number number;
  l_tca_error             exception;
  x_contact_point_rec     hz_contact_point_v2pub.contact_point_rec_type;
  l_phone_rec             hz_contact_point_v2pub.phone_rec_type;
  x_contact_point_id      number;
  x_msg_count             number;
  x_msg_data              varchar2(2000);

begin
  l_module_source := G_MODULE_SOURCE || 'update_phone_contact_point';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  fnd_oid_users.get_contact_point_rec(
                          p_ldap_message => p_ldap_message,
                          p_contact_point_type => G_PHONE,
                          p_contact_point_purpose => p_contact_point_purpose,
                          p_action_type => G_UPDATE,
                          x_contact_point_rec => x_contact_point_rec,
                          x_return_status => x_return_status);
/*
  commented this code because anytime a phone record does not exist the return status is E
  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;
*/
  if (x_contact_point_rec.contact_point_id is not null)
  then

    select object_version_number
    into l_object_version_number
    from hz_contact_points
    where contact_point_id =   x_contact_point_rec.contact_point_id;


   if (p_contact_point_purpose = G_BUSINESS)
   then
     l_phone_rec.raw_phone_number := p_ldap_message.telephoneNumber;
   elsif (p_contact_point_purpose = G_PERSONAL)
   then
     l_phone_rec.phone_number := p_ldap_message.homePhone;
   end if;


    hz_contact_point_v2pub.update_phone_contact_point(
                          p_init_msg_list => fnd_api.G_TRUE,
                          p_contact_point_rec =>  x_contact_point_rec,
                          p_phone_rec => l_phone_rec,
                          p_object_version_number =>l_object_version_number,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data);

    if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
    then
      raise l_tca_error;
    end if;

  else

  fnd_oid_users.create_phone_contact_point(
                          p_ldap_message => p_ldap_message,
                          p_contact_point_purpose => p_contact_point_purpose,
                          x_return_status => x_return_status);
  end if;

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      if (x_msg_count > 0)
      then
        for i in 1..x_msg_count
        loop
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, x_msg_data);
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, i || '.'
            || SubStr(fnd_msg_pub.get(p_encoded => fnd_api.g_false), 1, 255));
        end loop;
      else
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
          , 'x_return_status = ' || x_return_status);
      end if;
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end update_phone_contact_point;
--
-------------------------------------------------------------------------------
procedure update_email_contact_point(
    p_ldap_message  in          fnd_oid_util.ldap_message_type
  , x_return_status out nocopy  varchar2
) is

  l_module_source         varchar2(256);
  l_object_version_number number;
  l_tca_error             exception;
  x_contact_point_rec     hz_contact_point_v2pub.contact_point_rec_type;
  p_email_rec           hz_contact_point_v2pub.email_rec_type;
  x_contact_point_id      number;
  x_msg_count             number;
  x_msg_data              varchar2(2000);

begin
  l_module_source := G_MODULE_SOURCE || 'update_email_contact_point';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  fnd_oid_users.get_contact_point_rec(
                        p_ldap_message => p_ldap_message,
                        p_contact_point_type => G_EMAIL,
                        p_contact_point_purpose => NULL,
                        p_action_type => G_UPDATE,
                        x_contact_point_rec => x_contact_point_rec,
                        x_return_status => x_return_status);
/*
  commented this out because an E is returned if the email does not exist
  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;
*/
  if (x_contact_point_rec.contact_point_id is not null)
  then

    select object_version_number
    into l_object_version_number
    from hz_contact_points
    where contact_point_id =   x_contact_point_rec.contact_point_id;

    p_email_rec.email_address := p_ldap_message.mail;

    hz_contact_point_v2pub.update_email_contact_point(
                          p_init_msg_list => fnd_api.G_TRUE,
                          p_contact_point_rec =>  x_contact_point_rec,
                          p_email_rec => p_email_rec,
                          p_object_version_number =>l_object_version_number,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data);

  else

  fnd_oid_users.create_email_contact_point(p_ldap_message => p_ldap_message,
                                           x_return_status => x_return_status);
  end if;

  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      if (x_msg_count > 0)
      then
        for i in 1..x_msg_count
        loop
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, x_msg_data);
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, i || '.'
            || SubStr(fnd_msg_pub.get(p_encoded => fnd_api.g_false), 1, 255));
        end loop;
      else
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
          , 'x_return_status = ' || x_return_status);
      end if;
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end update_email_contact_point;
--
-------------------------------------------------------------------------------
procedure update_party_site(
    p_ldap_message  in          fnd_oid_util.ldap_message_type
  , x_return_status out nocopy  varchar2
) is

  l_module_source         varchar2(256);
  l_object_version_number number;
  p_object_version_number number;
  l_tca_error             exception;
  x_party_site_rec        hz_party_site_v2pub.party_site_rec_type;
  x_party_site_id         number;
  x_msg_count             number;
  x_msg_data              varchar2(2000);
  x_location_rec  hz_location_v2pub.location_rec_type;
  l_location_id           number;

begin
  l_module_source := G_MODULE_SOURCE || 'update_party_site';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  fnd_oid_users.get_party_site_rec(
                              p_ldap_message => p_ldap_message,
                              p_action_type => G_UPDATE,
                              x_party_site_rec => x_party_site_rec,
                              x_return_status => x_return_status);

/* commenting this out as TCA returns Error if the party site is not found
  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;
*/

  if (x_party_site_rec.party_site_id is not null)
  then

    select location_id
    into l_location_id
    from hz_party_sites
    where party_site_id = x_party_site_rec.party_site_id;

    if (l_location_id is not NULL) then
      select object_version_number
      into l_object_version_number
      from hz_party_sites
      where party_site_id = x_party_site_rec.party_site_id;


      select object_version_number
      into p_object_version_number
      from hz_locations
      where location_id = l_location_id;

      fnd_oid_users.get_location_rec(p_ldap_message => p_ldap_message,
                                 x_location_rec => x_location_rec);

       x_location_rec.location_id := l_location_id;

        hz_location_v2pub.update_location (
           p_init_msg_list             => fnd_api.G_TRUE,
           p_location_rec              => x_location_rec,
           p_object_version_number     =>p_object_version_number,
           x_return_status             => x_return_status,
           x_msg_count                 => x_msg_count,
           x_msg_data                  => x_msg_data);



          hz_party_site_v2pub.update_party_site(
                          p_init_msg_list => fnd_api.G_TRUE,
                          p_party_site_rec =>  x_party_site_rec,
                          p_object_version_number =>l_object_version_number,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data);

         if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
         then
         raise l_tca_error;
         end if;
      else -- no location id
         if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
         then
         raise l_tca_error;
         end if;
      end if;
 else

  fnd_oid_users.create_location(p_ldap_message => p_ldap_message,
                                x_return_status => x_return_status);

 end if;
  if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
  then
    raise l_tca_error;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      if (x_msg_count > 0)
      then
        for i in 1..x_msg_count
        loop
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, x_msg_data);
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, i || '.'
            || SubStr(fnd_msg_pub.get(p_encoded => fnd_api.g_false), 1, 255));
        end loop;
      else
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
          , 'x_return_status = ' || x_return_status);
      end if;
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end update_party_site;
--
-------------------------------------------------------------------------------
procedure get_person_rec(
    p_ldap_message  in          fnd_oid_util.ldap_message_type
  , p_action_type   in          varchar2
  , x_person_rec    out nocopy  hz_party_v2pub.person_rec_type
  , x_return_status out nocopy  varchar2
) is

  l_module_source         varchar2(256);
  l_profile_defined       boolean;
  l_party_number          number;
  l_generate_party_number varchar2(1);
  l_party_rec             hz_party_v2pub.party_rec_type;
  l_object_version_number number;
  l_owner_table_id        number;
  l_orig_system_reference varchar2(200);
  l_tca_error             exception;

begin
  l_module_source := G_MODULE_SOURCE || 'get_person_rec';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  if (p_action_type = G_CREATE)
  then

    fnd_profile.get_specific(name_z        => G_HZ_GENERATE_PARTY_NUMBER,
                             val_z         => l_generate_party_number,
                             defined_z     => l_profile_defined);

    if (l_generate_party_number = G_NO)
    then
      select hz_party_number_s.nextval
      into l_party_number
      from dual;
      l_party_rec.party_number := l_party_number;
    end if;

    x_person_rec.created_by_module := G_FND_OID_SYNCH;

  elsif (p_action_type = G_UPDATE)
  then
    fnd_oid_users.get_orig_system_ref(
                      p_ldap_message => p_ldap_message,
                      p_tag => G_PERSON,
                      x_reference => l_orig_system_reference);
    hz_orig_system_ref_pub.get_owner_table_id(
        p_orig_system => G_FND_OID_SYNCH
      , p_orig_system_reference => l_orig_system_reference
      , p_owner_table_name => G_HZ_PARTIES
      , x_owner_table_id => l_owner_table_id
      , x_return_status => x_return_status);

    if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
    then
      raise l_tca_error;
    end if;

    l_party_rec.party_id := l_owner_table_id;
  end if;

  x_person_rec.party_rec := l_party_rec;

  if (p_ldap_message.sn is not null)
  then
    x_person_rec.person_last_name := p_ldap_message.sn;
  end if;

  if (p_ldap_message.givenName is not null)
  then
    x_person_rec.person_first_name := p_ldap_message.givenName;
  end if;

  x_return_status := fnd_api.G_RET_STS_SUCCESS;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
        , 'Error calling hz_orig_system_ref_pub.get_owner_table_id');
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end get_person_rec;
--
-------------------------------------------------------------------------------
procedure get_contact_point_rec(
    p_ldap_message          in          fnd_oid_util.ldap_message_type
  , p_contact_point_type    in          varchar2
  , p_contact_point_purpose in          varchar2
  , p_action_type           in          varchar2
  , x_contact_point_rec     out nocopy
      hz_contact_point_v2pub.contact_point_rec_type
  , x_return_status         out nocopy  varchar2
) is

  l_module_source         varchar2(256);
  l_party_id              number;
  l_object_version_number number;
  l_orig_system_reference varchar2(200);
  l_owner_table_id        number;
  l_tca_error             exception;

begin
  l_module_source := G_MODULE_SOURCE || 'get_contact_point_rec';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
      , 'p_action_type = ' || p_action_type );
  end if;

  if (p_action_type = G_CREATE)
  then

    select person_party_id
    into l_party_id
    from fnd_user where user_name = p_ldap_message.object_name;

    x_contact_point_rec.owner_table_id := l_party_id;
    x_contact_point_rec.contact_point_type := p_contact_point_type;
    if (p_contact_point_type = G_PHONE)
    then
      x_contact_point_rec.contact_point_purpose := p_contact_point_purpose;
    end if;
    x_contact_point_rec.owner_table_name := G_HZ_PARTIES;
    x_contact_point_rec.created_by_module := G_FND_OID_SYNCH;
    x_contact_point_rec.status := G_ACTIVE;

  elsif (p_action_type = G_UPDATE)
  then

    /* commenting out this line because we want to update the existing phone record and not inactivate it.
    x_contact_point_rec.status := G_INACTIVE;
    */

    if (p_contact_point_type = G_PHONE)
    then
      fnd_oid_users.get_orig_system_ref(
                      p_ldap_message => p_ldap_message,
                      p_tag => p_contact_point_purpose,
                      x_reference => l_orig_system_reference);
    else
      fnd_oid_users.get_orig_system_ref(
                      p_ldap_message => p_ldap_message,
                      p_tag => p_contact_point_type,
                      x_reference => l_orig_system_reference);
    end if;
    hz_orig_system_ref_pub.get_owner_table_id(
                      p_orig_system => G_FND_OID_SYNCH,
                      p_orig_system_reference => l_orig_system_reference,
                      p_owner_table_name => G_HZ_CONTACT_POINTS,
                      x_owner_table_id => l_owner_table_id,
                      x_return_status => x_return_status);

    if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
    then
      raise l_tca_error;
    end if;

    x_contact_point_rec.contact_point_id := l_owner_table_id;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
        , 'Error calling hz_orig_system_ref_pub.get_owner_table_id');
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end get_contact_point_rec;
--
-------------------------------------------------------------------------------
procedure get_location_rec(
    p_ldap_message  in          fnd_oid_util.ldap_message_type
  , x_location_rec  out nocopy  hz_location_v2pub.location_rec_type
) is

  cursor cur_fnd_territories is
    SELECT TERRITORY_CODE
    FROM   FND_TERRITORIES_VL
    WHERE  TERRITORY_CODE = p_ldap_message.c
        OR TERRITORY_SHORT_NAME = p_ldap_message.c
        OR DESCRIPTION = p_ldap_message.c;

  l_module_source varchar2(256);
  l_territory_code fnd_territories.TERRITORY_CODE%type;
  l_found         boolean;

begin
  l_module_source := G_MODULE_SOURCE || 'get_location_rec';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  l_found := false;
  l_territory_code := null;
  if (p_ldap_message.c is not null)
  then
--The following logic should removed once OID ensures that they send the correct
--"c" attribute based on the LDAP standard
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
      'Country from OID: '||p_ldap_message.c);
    end if;

    open cur_fnd_territories;
    fetch cur_fnd_territories into l_territory_code;
    l_found := cur_fnd_territories%found;

    if(l_found)
    then
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
                        'Setting country: '||l_territory_code);
      end if;
      x_location_rec.country := l_territory_code;
    else
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,
                        'Setting country to null');
      end if;
      x_location_rec.country := null;
     end if;
     close cur_fnd_territories;
  end if;

  if (p_ldap_message.street is not null) then
    x_location_rec.address1 := p_ldap_message.street;
  end if;

  if (p_ldap_message.postalCode is not null) then
    x_location_rec.postal_code := p_ldap_message.postalCode;
  end if;

  if (p_ldap_message.st is not null) then
    x_location_rec.state := p_ldap_message.st;
  end if;

  if (p_ldap_message.l is not null) then
    x_location_rec.city := p_ldap_message.l;
  end if;

  x_location_rec.created_by_module := G_FND_OID_SYNCH;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

  exception
    when others then
      if (cur_fnd_territories%isopen)
      then
        close cur_fnd_territories;
      end if;

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
      end if;
end get_location_rec;
--
-------------------------------------------------------------------------------
procedure get_party_site_rec(
    p_ldap_message    in          fnd_oid_util.ldap_message_type
  , p_action_type     in          varchar2
  , x_party_site_rec  out nocopy  hz_party_site_v2pub.party_site_rec_type
  , x_return_status   out nocopy  varchar2
) is

  l_module_source         varchar2(256);
  l_profile_defined       boolean;
  l_party_id              number;
  l_party_site_number     number;
  l_generate_ps_number    varchar2(1);
  l_object_version_number number;
  l_owner_table_id        number;
  l_orig_system_reference varchar2(200);
  l_tca_error             exception;

begin
  l_module_source := G_MODULE_SOURCE || 'get_party_site_rec';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  if (p_action_type = G_CREATE)
  then
    fnd_profile.get_specific(name_z        => G_HZ_GENERATE_PS_NUMBER,
                             val_z         => l_generate_ps_number,
                             defined_z     => l_profile_defined);

    if (l_generate_ps_number = G_NO)
    then
      select hz_party_site_number_s.nextval
      into l_party_site_number
      from dual;
      x_party_site_rec.party_site_number := l_party_site_number;
    end if;

    select person_party_id
    into l_party_id
    from fnd_user where user_name = p_ldap_message.object_name;

    x_party_site_rec.party_id := l_party_id;

  elsif (p_action_type = G_UPDATE)
  then
    fnd_oid_users.get_orig_system_ref(
                      p_ldap_message => p_ldap_message,
                      p_tag => G_LOCATION,
                      x_reference => l_orig_system_reference);
    hz_orig_system_ref_pub.get_owner_table_id(
        p_orig_system => G_FND_OID_SYNCH
      , p_orig_system_reference => l_orig_system_reference
      , p_owner_table_name => G_HZ_PARTY_SITES
      , x_owner_table_id => l_owner_table_id
      , x_return_status => x_return_status);

    if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
    then
      raise l_tca_error;
    end if;

    x_party_site_rec.party_site_id := l_owner_table_id;
   -- x_party_site_rec.status := G_INACTIVE;
  end if;

  if (p_ldap_message.physicalDeliveryOfficeName is not null) then
    x_party_site_rec.mailstop := p_ldap_message.physicalDeliveryOfficeName;
  end if;

  x_party_site_rec.created_by_module := G_FND_OID_SYNCH;

  x_return_status := fnd_api.G_RET_STS_SUCCESS;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
        , 'Error calling hz_orig_system_ref_pub.get_owner_table_id');
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end get_party_site_rec;
--
-------------------------------------------------------------------------------
procedure get_orig_system_ref(
    p_ldap_message  in          fnd_oid_util.ldap_message_type
  , p_tag	          in          varchar2
  , x_reference     out nocopy  varchar2
) is

  l_module_source varchar2(256);
  l_user_id       number;

begin
  l_module_source := G_MODULE_SOURCE || 'get_orig_system_ref';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  select user_id
  into l_user_id
  from fnd_user where user_name = upper(p_ldap_message.object_name);

  x_reference := p_tag || l_user_id;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
      , 'Orig System Reference = ' || x_reference);
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end get_orig_system_ref;
--
-------------------------------------------------------------------------------
procedure create_orig_system_reference(
    p_ldap_message	    in          fnd_oid_util.ldap_message_type
  , p_tag               in          varchar2
  , p_owner_table_name  in          varchar2
  , p_owner_table_id    in          number
  , p_status            in          varchar2
  , x_return_status     out nocopy  varchar2
) is

  l_module_source         varchar2(256);
  l_orig_sys_rec          hz_orig_system_ref_pub.orig_sys_reference_rec_type;
  l_orig_system_reference varchar2(2000);
  l_owner_table_id        number;
  l_tca_error             exception;
  l_debug_level           number;
  l_proc_level            number;
  x_msg_count             number;
  x_msg_data              varchar2(2000);

begin
  l_module_source := G_MODULE_SOURCE || 'create_orig_sys_reference_rec';
  l_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_proc_level := FND_LOG.LEVEL_PROCEDURE;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  fnd_oid_users.get_orig_system_ref(
                              p_ldap_message => p_ldap_message,
                              p_tag => p_tag,
                              x_reference => l_orig_system_reference);

  l_orig_sys_rec.orig_system := G_FND_OID_SYNCH;
  l_orig_sys_rec.orig_system_reference := l_orig_system_reference;
  l_orig_sys_rec.owner_table_name := p_owner_table_name;
  l_orig_sys_rec.owner_table_id := p_owner_table_id;
  l_orig_sys_rec.status := p_status;
  l_orig_sys_rec.start_date_active := sysdate;
  l_orig_sys_rec.created_by_module := G_FND_OID_SYNCH;

  hz_orig_system_ref_pub.get_owner_table_id(
                            p_orig_system => G_FND_OID_SYNCH,
                            p_orig_system_reference => l_orig_system_reference,
                            p_owner_table_name => p_owner_table_name,
                            x_owner_table_id => l_owner_table_id,
                            x_return_status => x_return_status);

  if (x_return_status = fnd_api.G_RET_STS_UNEXP_ERROR)
  then
    raise l_tca_error;
  end if;

  if (l_owner_table_id is not null)
  then

    fnd_oid_users.update_orig_system_reference(
                          p_ldap_message => p_ldap_message,
                          p_tag => p_tag,
                          p_owner_table_name => p_owner_table_name,
                          p_owner_table_id => p_owner_table_id,
                          p_status => G_ACTIVE,
                          x_return_status => x_return_status);

    if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
    then
      raise l_tca_error;
    end if;

  else

    hz_orig_system_ref_pub.create_orig_system_reference(
                      p_init_msg_list => fnd_api.G_TRUE,
                      p_orig_sys_reference_rec => l_orig_sys_rec,
                      x_return_status => x_return_status,
                      x_msg_count => x_msg_count,
                      x_msg_data => x_msg_data);

    if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
    then
      raise l_tca_error;
    end if;

  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      if (x_msg_count > 0)
      then
        for i in 1..x_msg_count
        loop
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, x_msg_data);
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, i || '.'
            || SubStr(fnd_msg_pub.get(p_encoded => fnd_api.g_false), 1, 255));
        end loop;
      else
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
          , 'x_return_status = ' || x_return_status);
      end if;
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end create_orig_system_reference;
--
-------------------------------------------------------------------------------
procedure update_orig_system_reference(
    p_ldap_message	    in          fnd_oid_util.ldap_message_type
  , p_tag               in          varchar2
  , p_owner_table_name  in          varchar2
  , p_owner_table_id    in          number
  , p_status            in          varchar2
  , x_return_status     out nocopy  varchar2
) is

  l_module_source         varchar2(256);
  l_orig_system_reference varchar2(2000);
  l_orig_sys_rec          hz_orig_system_ref_pub.orig_sys_reference_rec_type;
  l_orig_system_ref_id    number;
  l_object_version_number number;
  l_tca_error             exception;
  x_msg_count             number;
  x_msg_data              varchar2(2000);

begin
  l_module_source := G_MODULE_SOURCE || 'get_orig_sys_reference_rec';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  l_orig_sys_rec.orig_system := G_FND_OID_SYNCH;
  fnd_oid_users.get_orig_system_ref(
                              p_ldap_message => p_ldap_message,
                              p_tag => p_tag,
                              x_reference => l_orig_system_reference);

  select orig_system_ref_id
  into l_orig_system_ref_id
  from hz_orig_sys_references
  where orig_system_reference = l_orig_system_reference;

  select object_version_number
  into l_object_version_number
  from hz_orig_sys_references
  where orig_system_ref_id = l_orig_system_ref_id;

  l_orig_sys_rec.orig_system_ref_id := l_orig_system_ref_id;
  l_orig_sys_rec.orig_system_reference := l_orig_system_reference;
  l_orig_sys_rec.owner_table_name := p_owner_table_name;
  l_orig_sys_rec.owner_table_id := p_owner_table_id;

  hz_orig_system_ref_pub.update_orig_system_reference(
                    p_init_msg_list => fnd_api.G_TRUE,
                    p_orig_sys_reference_rec => l_orig_sys_rec,
                    p_object_version_number => l_object_version_number,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);

if (x_return_status <> fnd_api.G_RET_STS_SUCCESS)
then
  raise l_tca_error;
end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when l_tca_error then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      if (x_msg_count > 0)
      then
        for i in 1..x_msg_count
        loop
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, x_msg_data);
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, i || '.'
            || SubStr(fnd_msg_pub.get(p_encoded => fnd_api.g_false), 1, 255));
        end loop;
      else
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source
          , 'x_return_status = ' || x_return_status);
      end if;
    end if;
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end update_orig_system_reference;
--
-------------------------------------------------------------------------------
procedure test is

  l_module_source varchar2(256);
  l_ldap_record   fnd_oid_util.ldap_message_type;
  l_return_status varchar2(2000);

begin
  l_module_source := G_MODULE_SOURCE || 'test: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  l_ldap_record.sn := 'FAZIL';
  l_ldap_record.object_name := 'FND95.2';
  l_ldap_record.givenName := 'SAAD';

  l_ldap_record.telephoneNumber := '333';
  l_ldap_record.homePhone := '222';
  l_ldap_record.mail := 'saadfazil@y.com';

  l_ldap_record.c := 'US';
  l_ldap_record.street := '600 orcl pkwy';
  l_ldap_record.postalCode := '94065';
  l_ldap_record.st := 'ca';
  l_ldap_record.l := 'rs';

  --fnd_oid_users.hz_create(p_ldap_message => l_ldap_record,
                          --x_return_status => l_return_status);
  fnd_oid_users.hz_update(p_ldap_message => l_ldap_record,
                          x_return_status => l_return_status);
  commit;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception
  when others then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, sqlerrm);
    end if;
end test;
--
-------------------------------------------------------------------------------
end fnd_oid_users;

/
