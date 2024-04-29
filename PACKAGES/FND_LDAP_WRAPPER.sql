--------------------------------------------------------
--  DDL for Package FND_LDAP_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LDAP_WRAPPER" AUTHID CURRENT_USER as
/* $Header: AFSCOLWS.pls 120.23.12010000.3 2010/07/27 17:00:15 ctilley ship $ */
--
/*****************************************************************************/

-- Start of Package Globals

  G_SUCCESS			constant  pls_integer := 1;
  G_FAILURE			constant  pls_integer := 0;
  G_TRUE			constant  pls_integer := 1;
  G_FALSE			constant  pls_integer := 0;

  G_CREATE			constant  pls_integer := 2;
  G_UPDATE			constant  pls_integer := 3;
  G_DELETE			constant  pls_integer := 4;
  G_NO_REGISTRATION		constant  pls_integer := 5;
  G_VALID_REGISTRATION		constant  pls_integer := 6;
  G_INVALID_REGISTRATION	constant  pls_integer := 7;

  G_EBIZ_TO_OID	constant	pls_integer := 8;
  G_OID_TO_EBIZ	constant	pls_integer := 9;

  G_IDENTITY			constant  pls_integer := 10;
  G_SUBSCRIPTION		constant  pls_integer := 11;

  G_ADD				constant  pls_integer := 12;
  G_MODIFY			constant  pls_integer := 13;

  registration_failure_exception	exception;
-- End of Package Globals
--
-------------------------------------------------------------------------------
/*
** Name      : change_user_name
** Type      : Public, FND Internal
** Desc      : This procedure changes a user name in OID
**             If the user doesn't exist, it
**             returns with G_FAILURE. If application is not SSO enabled, it
**             simply returns G_SUCCESS without doing anything.
** Pre-Reqs  :
** Parameters: x_result:
**             FND_LDAP_WRAPPER.G_SUCCESS if
**           - the user name is successfully changed in OID
**           - or application is not SSO enabled
**             FND_LDAP_WRAPPER.G_FAILURE if
**           - application is SSO enabled and user name change fails
** Notes     :
*/
procedure change_user_name(p_user_guid in raw,
                          p_old_user_name in varchar2,
                          p_new_user_name in varchar2,
                          x_result out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : synch_user_from_LDAP
** Type      : Public, FND Internal
** Desc      : This procedure takes a fnd_user username as input. It retrieves
**             the user attributes from OID and tries to create a new TCA record. If
**             one already exists then it simply updates the existing record.
**             If application is not SSO enabled, it simply returns FND_LDAP_WRAPPER. G_SUCCESS
**             without updating or creating a record in TCA.
** Pre-Reqs  :
** Parameters: USER_NAME WHOSE ATTRIBUTES NEED TO BE SYNCH WITH TCA
**             p_result:
**             FND_LDAP_WRAPPER.G_SUCCESS if a TCA record is successfully
**             created/updated or if the application is not SSO enabled.
**             It retunrns FND_LDAP_WRAPPER.G_FAILURE if
**           - application is SSO enabled and TCA update/creation fails.
** Notes     :
*/
procedure synch_user_from_LDAP(p_user_name in fnd_user.user_name%type
                               , p_result out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : create_user
** Type      : Public, FND Internal
** Desc      : This procedure creates a user in OID for the application it is
**             invoked from. If a user already exists with the same name, it
**             checks whether the profile APPS_SSO_LINK_SAME_NAMES is enabled.
*8	       If the profile is enabled, it simply links the users and returns
**	       G_SUCCESS with appropriate x_user_guid and x_password. If the
**	       profile is disabled, it returns with G_FAILURE. If application is
**	       not SSO enabled, it simply returns G_SUCCESS without creaing a
**	       user in OID so that caller of the API (FND_USER_PKG) can proceed.
** Pre-Reqs  :
** Parameters:
**	       p_user_name: user name
**             p_password: unencrypted password
**	       p_start_date: start date of the user, default sysdate
**	       p_end_date: end date of the user, default null
**             p_description: description of the user, default null
**             p_email_address: email address, default null
**             p_fax: fax, default null
**             p_expire_password:
**             - fnd_ldap_wrapper.G_TRUE if
**	       password to be expired on first login (for example when
**             admin creates a user)
**             - fnd_ldap_wrapper.G_FALSE if
**	       password NOT to be expired on first login (for example when
**             cerated via self service)
**             - default is fnd_ldap_wrapper.G_TRUE
**	       x_user_guid:
**             GUID of the user created
**             x_password:
**             EXTERNAL or null depending on APPS_SSO_LOCAL_LOGIN profile
**             x_result:
**             FND_LDAP_WRAPPER.G_SUCCESS if
**           - a user is successfully created in OID
**           - or application is not SSO enabled
**             FND_LDAP_WRAPPER.G_FAILURE if
**           - application is SSO enabled and user creation fails
** Notes     :
*/
procedure create_user(p_user_name in varchar2,
                     p_password in varchar2,
                     p_start_date in date default sysdate,
                     p_end_date in date default null,
                     p_description in varchar2 default null,
                     p_email_address in varchar2 default null,
                     p_fax in varchar2 default null,
		     p_expire_password in pls_integer default G_TRUE,
                     x_user_guid out nocopy raw,
                     x_password out nocopy varchar2,
                     x_result out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : delete_user
** Type      : Public, FND Internal
** Desc      : If the OID user was created from the same instance where the
**             fnd_user is now being rejected/released, *and* the OID user is
**             still inactive, then we will delete it.If either of these
**             criteria is not fulfilled, we can't touch the OID user even if
**             we delete the pending FND_USER record.
**             If application is not SSO enabled, it simply returns G_SUCCESS
**             without deleting the user in OID
** Pre-Reqs  :
** Parameters: p_user_name : user name to be deleted
**             p_result    :
**             FND_LDAP_WRAPPER.G_SUCCESS if
**           - the user is successfully deleted in OID
**           - or application is not SSO enabled
**             FND_LDAP_WRAPPER.G_FAILURE if
**           - application is SSO enabled and user deletion fails
** Notes     :
*/
procedure delete_user(p_user_guid in fnd_user.user_guid%type,
                     x_result out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : change_password
** Type      : Public, FND Internal
** Desc      : This function changes OID password for a user in OID.
**             If application is not SSO enabled, it simply returns
**             G_SUCCESS without changing password in OID
** Pre-Reqs  : User is already in FND_USER table
** Parameters: p_user_guid: user GUID
**	       p_user_name : user name
**	       p_expire_password :
**             - fnd_ldap_wrapper.G_TRUE if
**	       password to be expired on next login (for example when
**             admin updates a user password)
**             - fnd_ldap_wrapper.G_FALSE if
**	       password NOT to be expired on next login (for example when
**             a user updates his/her own password)
**             - default is fnd_ldap_wrapper.G_TRUE
**             x_password:
**             EXTERNAL or null depending on APPS_SSO_LOCAL_LOGIN profile
**	       x_result  :
**	       fnd_ldap_wrapper.G_SUCCESS if
**             - a password is successfully changed in OID
**             - or application is not SSO enabled
**             fnd_ldap_wrapper.G_FAILURE if
**             - application is SSO enabled and password change fails
** Notes     :
*/
procedure change_password(p_user_guid in raw,
			 p_user_name in varchar2,
			 p_new_pwd in varchar2,
			 p_expire_password in pls_integer default G_TRUE,
			 x_password out nocopy varchar2,
                         x_result out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : user_exists
** Type      : Public, FND Internal
** Desc      : This function creates a user in OID for the application it is
**             invoked from
** Notes     : This API doesn't check for profile values. Use fnd_ldap_wrapper
** Pre-Reqs  :
** Parameters: user_name : user name
** Returns   : FND_LDAP_WRAPPER.G_SUCCESS if
**           - the user exists
**             FND_LDAP_WRAPPER.G_FAILURE if
**           - application is SSO enabled and the user doesn't exist
**           - or application is not SSO enabled
*/
function user_exists(p_user_name in varchar2) return pls_integer;
--
-------------------------------------------------------------------------------
/*
** Name      : get_orcl_nickname
** Type      : Public, FND Internal
** Desc      : This procedure gets the attribute of the OID user linked to FND_USER
**             which is specified as the nickname attribute.
**             If the fnd user is not linked to OID user or if the application is not SSO enabled,
**             it returns null.
** Pre-Reqs  :
** Parameters:
**
** Notes     :
*/
function get_ldap_user_name(p_user_name in fnd_user.user_name%type) return varchar2;
--
-------------------------------------------------------------------------------
/*
** Name      : get_orclappname
** Type      : Public, FND Internal
** Desc      : This function returns orclAppName from Workflow
** Pre-Reqs   :
** Parameters  :
** Notes      :
*/
function get_orclappname return varchar2;
--
-------------------------------------------------------------------------------
/*
** Name      : link_user
** Type      : Public, FND Internal
** Desc      : This procedure links the user with a user with same name in OID.
**             If no user exists with the same name, it returns with G_FAILURE.
**             If application is not SSO enabled, it
**             simply returns G_SUCCESS without linking the user in OID
** Pre-Reqs  :
** Parameters: x_user_guid:
**             GUID of the user linked
**             x_password:
**             EXTERNAL or null
**             x_result:
**             FND_LDAP_WRAPPER.G_SUCCESS if
**           - a user is successfully linked to user in OID
**           - or application is not SSO enabled
**             FND_LDAP_WRAPPER.G_FAILURE if
**           - application is SSO enabled and user linking fails
** Notes     :
*/
procedure link_user(p_user_name in varchar2,
                     x_user_guid out nocopy raw,
                     x_password out nocopy varchar2,
                     x_result out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : unlink_user
** Type      : Public, FND Internal
** Desc      : This procedure unsubscribes the user in OID if there is no other FND user linked
**	       to the same OID user
**             If no user exists with the same name, it returns with G_FAILURE.
**             If application is not SSO enabled, it
**             simply returns G_SUCCESS without unlinking the user in OID
** Pre-Reqs  :
** Parameters: p_user_name:
**             Name of the user to be unlinked
**             x_password:
**             EXTERNAL or null
**             x_result:
**             FND_LDAP_WRAPPER.G_SUCCESS if
**           - a user is successfully unlinked
**           - or application is not SSO enabled
**             FND_LDAP_WRAPPER.G_FAILURE if
**           - application is SSO enabled and user unlinking fails
** Notes     :
*/
procedure unlink_user(p_user_guid in fnd_user.user_guid%type,
		      p_user_name in varchar2,
                      x_result out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : update_user
** Type      : Public, FND Internal
** Desc      : This procedure updates a user in OID for the application it is
**             invoked from. If the user doesn't exist, it
**             returns with G_FAILURE. If application is not SSO enabled, it
**             simply returns G_SUCCESS without doing anything.
** Pre-Reqs  : User is already in FND_USER table
** Parameters:
**             p_user_guid: user GUID
**	       p_user_name: user name
**             p_password: unencrypted password
**	       p_start_date: start date of the user, default sysdate
**	       p_end_date: end date of the user, default null
**             p_description: description of the user, default null
**             p_email_address: email address, default null
**             p_fax: fax, default null
**             p_expire_password:
**             - fnd_ldap_wrapper.G_TRUE if
**	       password to be expired on next login (for example when
**             admin updates a user password)
**             - fnd_ldap_wrapper.G_FALSE if
**	       password NOT to be expired on next login (for example when
**             a user updates his/her own password)
**             - default is fnd_ldap_wrapper.G_TRUE
**             x_password:
**             EXTERNAL or null depending on APPS_SSO_LOCAL_LOGIN profile
**	       x_result:
**             FND_LDAP_WRAPPER.G_SUCCESS if
**           - the user is successfully updated in OID
**           - or application is not SSO enabled
**             FND_LDAP_WRAPPER.G_FAILURE if
**           - application is SSO enabled and user update fails
** Notes     :
*/
procedure update_user(p_user_guid in raw,
                     p_user_name in varchar2,
                     p_password in varchar2 default null,
                     p_start_date in date default null,
                     p_end_date in date default null,
                     p_description in varchar2 default null,
                     p_email_address in varchar2 default null,
                     p_fax in varchar2 default null,
     		     p_expire_password in pls_integer default G_TRUE,
                     x_password out nocopy varchar2,
                     x_result out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : validate_login
** Type      : Public, FND Internal
** Desc      : This procedure validates a user for a given password
**             If application is not SSO enabled, it simply returns false.
** Pre-Reqs  :
** Parameters: p_user_name: user name
**             p_password: password
** Notes     :
*/
function validate_login(p_user_name in varchar2, p_password in varchar2) return boolean;
--
-------------------------------------------------------------------------------
/*
** Name      : is_operation_allowed
** Type      : Public, FND Internal
** Desc      : This procedure looks up the OID registration in
**             order to determine if the requested operation is allowed
** Pre-Reqs  :
** Parameters:
**             p_direction The direction in which the operation is being performed. Can be
**			   fnd_ldap_wrapper.G_EBIZ_TO_OID or fnd_ldap_wrapper.G_OID_TO_EBIZ.
**			   If not provided then defaulted to fnd_ldap_wrapper.G_EBIZ_TO_OID.
**	       p_entity	   The entity on which the operation is being performed. Has to be
**			   fnd_ldap_wrapper.G_IDENTITY or fnd_ldap_wrapper.G_SUBSCRIPTION
**	       p_operation The operation which is being performed. Has to be fnd_ldap_wrapper.G_ADD
**			   fnd_ldap_wrapper.G_MODIFY, fnd_ldap_wrapper.G_DELETE
**             p_user_name This represents the name of the user whose password is being changed.
**                         If no username or userid use Site level profile
**             p_user_id   This represents the user_id of the user whose password is being changed.
**                         If none provided use Site level profile
**	       x_attribute The attribute on which operation is being performed. If not passed then
**			   result will be positive even if a single attribute is allowed.
**	       x_fnd_user  fnd_ldap_wrapper.G_SUCCESS if FND operations is allowed else fnd_ldap_wrapper.G_FAILURE
**             x_oid       fnd_ldap_wrapper.G_SUCCESS if OID operations is allowed else fnd_ldap_wrapper.G_FAILURE
**
** Notes     :
*/
procedure is_operation_allowed(p_realm in varchar2, p_direction in pls_integer default G_EBIZ_TO_OID,
			       p_entity in pls_integer,
			       p_operation in pls_integer,
                               p_user_name in varchar2 default NULL,
                               p_user_id in number default NULL,
			       x_attribute in out nocopy varchar2,
			       x_fnd_user out nocopy pls_integer,
                               x_oid out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
To do
*/
procedure is_operation_allowed(p_realm in varchar2, p_operation in pls_integer,
                               x_fnd_user out nocopy pls_integer,
                               x_oid out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : get_registration
** Type      : Public, FND Internal
** Desc      : This procedure verifies if the deployment is registered with SSO and OID.
**             In addition it verifies that conditions for LDAP synchronization are valid.
**
** Pre-Reqs  :
** Parameters: pls_integer x_registration return value.
**
** Notes     :
*/

procedure get_registration(x_registration out nocopy pls_integer);
--
-------------------------------------------------------------------------------


function is_present(p_attribute in varchar2, p_template_attr_list  in varchar2) return boolean;

--
-------------------------------------------------------------------------------
/*
** Name      : get_realm_dn
** Type      : Public, FND SSO Internal
** Desc      : Wrapper for FND_OID_PLUG.get_realm_dn.
**             Retreives the realm of a user, given the guid or the username.
**             Guid has precedence
**
** Pre-Reqs  :
** Parameters: pls_integer x_registration return value.
**
** Notes     : OiD connection problems may raise exceptions.
**            Non existent users or guids raises NO_DATA_FOUND
**            For non SSO deployments returns alwas NULL.
*/
function get_realm_dn( p_user_guid in raw default null, p_user_name in varchar2 default null)
   return varchar2;

--
-------------------------------------------------------------------------------
/*
** Name      : oid_synchronization_enabled
** Type      : Public, FND SSO Internal
** Desc      : Indicates if instance is configured for provisioning and
**             synchronization.
**             If returns false, not attempt should be made to contact OiD.
**
** Pre-Reqs  :
** Parameters:
**
** Notes     : Simply looks for  the SITE profile APPS_SSO_LDAP_SYNC.
**             But this may change in the future.
*/
function oid_synchronization_enabled return boolean;

-------------------------------------------------------------------------------
/*
 * ** Name      : unlink_ebiz_user
 * ** Type      : Public, FND SSO Internal
 * ** Desc      : Used to unlink a specific E-Business Suite user or all users
 * **
 * ** Pre-Reqs  :
 * ** Parameters:
 * **
 * ** Notes     : API unlinks the EBS user by removing the user_guid from
 **               FND_USER and sets the profiles APPS_SSO_LOCAL_LOGIN and
 **               APPS_SSO_LDAP_SYNC accordingly
 * **             But this may change in the future.
 * */
procedure unlink_ebiz_user(p_user_name in varchar2);

end fnd_ldap_wrapper;

/
