--------------------------------------------------------
--  DDL for Package Body FND_OID_BULKLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OID_BULKLOAD" as
/* $Header: AFSCOBLB.pls 120.4 2007/02/19 07:27:08 bmasa ship $ */
--
-- Start of Package Globals

  G_MODULE_SOURCE  constant varchar2(80) := 'fnd.plsql.oid.fnd_oid_bulkload.';
  G_CREATED	   constant varchar2(1) := 'Y';
  G_LINKED	   constant varchar2(1) := 'L';
  G_FAILED	   constant varchar2(1) := 'N';
  G_NOT_LINKED	   constant varchar2(1) := 'D';
  G_ALREADY_LINKED constant varchar2(1) := 'G';
  G_DUP_TRUE	   constant varchar2(1) := 'T';

-- End of Package Globals
--
-------------------------------------------------------------------------------
procedure import_user(p_ldap_user in fnd_oid_util.ldap_message_type,
		      p_duplicate in varchar2, x_ret_status out nocopy varchar2, p_tca_record  in varchar2 default 'Y') is

  l_module_source varchar2(256);
  l_user_count number;
  l_user_id number;
  l_user_name fnd_user.user_name%type;
  l_description fnd_user.description%type;
  l_fax fnd_user.fax%type;
  l_email_address fnd_user.email_address%type;
  l_user_guid fnd_user.user_guid%type;

begin

  fnd_global.apps_initialize(0, -1, -1);

  l_module_source := G_MODULE_SOURCE || 'import_user: ';
  x_ret_status := G_FAILED;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  l_user_name := p_ldap_user.object_name;
  l_description := p_ldap_user.description;
  l_fax := p_ldap_user.facsimileTelephoneNumber;
  l_email_address := p_ldap_user.mail;
  l_user_guid := p_ldap_user.orclGUID;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'user name = ' || l_user_name);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'desc = ' || l_description);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'fax = ' || l_fax);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'email = ' || l_email_address);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'user guid = ' || l_user_guid);
  end if;

  select count(user_name) into l_user_count
  from fnd_user
  where user_name = l_user_name;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'user count for ' || l_user_name || ' = ' || l_user_count);
  end if;

  if (l_user_count = 0) then
    fnd_user_pkg.CreateUser(x_user_name => l_user_name,
			    x_owner => 'CUST',
			    x_unencrypted_password => fnd_web_sec.EXTERNAL_PWD,
			    x_description => l_description,
			    x_fax => l_fax,
			    x_email_address => l_email_address,
			    x_user_guid => l_user_guid,
			    x_change_source =>  fnd_user_pkg.change_source_oid);

/*  fnd_oid_util.send_subscription_add_to_OID(p_orcl_guid=>l_user_guid); */

    fnd_oid_subscriptions.assign_default_resp(p_user_name => l_user_name);

    if(p_tca_record= 'N') then
	x_ret_status := G_CREATED;
    else
	fnd_oid_users.hz_create(p_ldap_message => p_ldap_user,
			    x_return_status => x_ret_status);

    	if (x_ret_status = fnd_api.G_RET_STS_SUCCESS) then
      		x_ret_status := G_CREATED;
    	end if;
    end if;
  else /* count_user <> 0 */
    select count(user_name) into l_user_count
    from fnd_user
    where user_name = l_user_name
    and   user_guid is not null;

    if (l_user_count = 0) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'user guid for ' || l_user_name || ' is null');
      end if;
      if (p_duplicate = G_DUP_TRUE) then
        fnd_user_pkg.UpdateUser(x_user_name => l_user_name,
     			        x_owner => 'CUST',
   			        x_description => l_description,
			        x_fax => l_fax,
			        x_email_address => l_email_address,
			        x_user_guid => l_user_guid,
				x_change_source =>  fnd_user_pkg.change_source_oid);
	x_ret_status := G_LINKED;
      else
        x_ret_status := G_NOT_LINKED;
      end if;
    else
      x_ret_status := G_ALREADY_LINKED;
    end if;

  end if;

  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'x_ret_status =' || x_ret_status);
  end if;

end import_user;
--
-------------------------------------------------------------------------------

end fnd_oid_bulkload;


/
