--------------------------------------------------------
--  DDL for Package FND_LDAP_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LDAP_USER" AUTHID CURRENT_USER as
/* $Header: AFSCOLUS.pls 120.20.12010000.6 2009/09/23 20:43:19 rsantis ship $ */
--
/*****************************************************************************/

-- Start of Package Globals

-- TDAs

-- type user_record_type is table of dbms_ldap.STRING_COLLECTION index by varchar2(200);

type ldap_user_type is record
(
  user_name FND_USER.USER_NAME%TYPE,  -- may have many, we just peek one, any
  user_guid FND_USER.USER_GUID%TYPE,
  user_id FND_USER.USER_ID%TYPE,
  RDN_ATT_NAME varchar2(80),
  RDN_VALUE varchar2(4000),
  NickName_ATT_NAME varchar2(80),
  parent_DN varchar2(4000),
  realmDN varchar2(4000),
  dn varchar2(4000),
  user_data  FND_LDAP_UTIL.ldap_record_values
);

-- End of Package Globals
--
-------------------------------------------------------------------------------
/*
** Name      : change_password
** Type      : Public, FND Internal
** Desc      : This function changes OID password for a user in OID.
** Pre-Reqs  :
** Parameters: p_user_guid: user GUID
**	       p_user_name : user name
**	       p_expire_password :
**             - fnd_ldap_wrapper.G_TRUE if
**	       password to be expired on next login (for example when
**             admin updates a user password)
**             - fnd_ldap_wrapper.G_FALSE if
**	       password NOT to be expired on next login (for example when
**             a user updates his/her own password)
**             x_password:
**             EXTERNAL or null depending on APPS_SSO_LOCAL_LOGIN profile
**	       x_result :
**	       fnd_ldap_wrapper.G_SUCCESS or
**             fnd_ldap_wrapper.G_FAILURE
** Notes     :
*/
procedure change_password(p_user_guid in raw,
			  p_user_name in varchar2,
			  p_new_pwd in varchar2,
			  p_expire_password in pls_integer,
                           x_password out nocopy varchar2,
                          x_result out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : change_user_name
** Type      : Public, FND Internal
** Desc      : This function creates a user name in OID
** Pre-Reqs   :
** Returns   : FND_LDAP_UTIL.G_SUCCESS if
**           - a user name is successfully changed in OID
**             FND_LDAP_UTIL.G_FAILURE if
**           - user name change fails
*/
procedure change_user_name(p_user_guid in raw,
                          p_old_user_name in varchar2,
                          p_new_user_name in varchar2,
                          x_result out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : create_user
** Type      : Public, FND Internal
** Desc      : This function creates a user in OID for the application it is
**             invoked from. It only creates a user if a user doesn't exists
**             already. If a user eixts with the same name, it will return
**             FND_LDAP_UTIL.G_FAILURE
** Pre-Reqs   :
** Parameters:
**
** Previous version:p_ldap_user : user record. See FND_LDAP_UTIL.ldap_user_type
**                          for more details
** Returns   : FND_LDAP_UTIL.G_SUCCESS if
**           - a user is successfully created in OID
**             FND_LDAP_UTIL.G_FAILURE if
**           - user creation fails
*/
--
-- DEPRECATED AND REMOVED
--function create_user(p_ldap_user in fnd_ldap_util.ldap_user_type) return pls_integer;
-- See private  functio
--- function pvt_create_user(p_ldap_user in out nocopy fnd_ldap_user.ldap_user_type) return pls_integer;
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
**	       profile is disabled, it throws an exception.
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
**	       x_user_guid:
**             GUID of the user created
**             x_password:
**             EXTERNAL or null depending on APPS_SSO_LOCAL_LOGIN profile
**             x_result: fnd_ldap_wrapper.G_SUCCESS
**	       or fnd_ldap_wrapper.G_FAILURE
** Pre-Reqs   :
** Throws   : user_create_failure if user creation fails
*/
procedure create_user(
                      p_realm in out nocopy varchar2,
                     p_user_name in varchar2,
                     p_password in varchar2,
                     p_start_date in date default sysdate,
                     p_end_date in date default null,
                     p_description in varchar2 default null,
                     p_email_address in varchar2 default null,
                     p_fax in varchar2 default null,
		                 p_expire_password in pls_integer ,
                     x_user_guid out nocopy raw,
                     x_password out nocopy varchar2,
                     x_result out nocopy pls_integer);
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
** Parameters: p_user_guid:
**             GUID of the user to be unlinked
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
** Name      : user_exists
** Type      : Public, FND Internal
** Desc      : This function creates a user in OID for the application it is
**             invoked from
** Notes     : This API doesn't check for profile values. Use fnd_ldap_wrapper
** Pre-Reqs  :
** Parameters: user_name : user name
** Returns   : FND_LDAP_UTIL.G_SUCCESS if
**           - the user exists
**             FND_LDAP_UTIL.G_FAILURE if
**           - the user doesn't exist
*/
function user_exists(p_user_name in varchar2) return pls_integer;
function user_exists(ldap in dbms_ldap.session,p_user_name in varchar2) return pls_integer;
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
** Pre-Reqs  :
** Parameters: p_user_name : user name to be deleted
**             p_result    :
**             FND_LDAP_UTIL.G_SUCCESS if
**           - the user is successfully deleted in OID
**             FND_LDAP_UTIL.G_FAILURE if
**           - if user deletion fails
** Notes     :
*/
procedure delete_user(p_user_guid in  fnd_user.user_guid%type,
                     x_result out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : update_user : RETIRED
** Type      : Public, FND Internal
** Desc      : This procedure updates a user in OID for the application it is
**             invoked from. If the user doesn't exist, it
**             returns with G_FAILURE.
** Pre-Reqs  :
** Parameters: p_user_guid: user GUID
**	       p_user_name: user name
**             p_password: unencrypted password
**	       p_start_date: start date of the user, default sysdate
**	       p_end_date: end date of the user, default null
**             p_description: description of the user, default null
**             p_email_address: email address, default null
**             p_fax: fax, default null
**             x_password:
**             EXTERNAL or null depending on APPS_SSO_LOCAL_LOGIN profile
**	       x_result:
**             FND_LDAP_UTIL.G_SUCCESS if
**           - the user is successfully updated in OID
**             FND_LDAP_UTIL.G_FAILURE if
**           - user update fails
** Notes     :
**     This is an old siganture. mainly we always need to know if we expire the password or not.
** THis supposed only to be called from FND_LDAP_WRAPPER.
procedure update_user(p_user_guid in raw,
                     p_user_name in varchar2,
                     p_password in varchar2 default null,
                     p_start_date in date default null,
                     p_end_date in date default null,
                     p_description in varchar2 default null,
                     p_email_address in varchar2 default null,
                     p_fax in varchar2 default null,
	 	                 x_password out nocopy varchar2,
                     x_result out nocopy pls_integer);
*/

--
-------------------------------------------------------------------------------
/*
** Name      : update_user
** Type      : Public, FND Internal
** Desc      : This procedure updates a user in OID for the application it is
**             invoked from. If the user doesn't exist, it
**             returns with G_FAILURE.
** Pre-Reqs  :
** Parameters: p_user_guid: user GUID
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
**             x_password:
**             EXTERNAL or null depending on APPS_SSO_LOCAL_LOGIN profile
**	       x_result:
**             FND_LDAP_UTIL.G_SUCCESS if
**           - the user is successfully updated in OID
**             FND_LDAP_UTIL.G_FAILURE if
**           - user update fails
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
		                 p_expire_password in pls_integer,
   		               x_password out nocopy varchar2,
                     x_result out nocopy pls_integer) ;

-------------------------------------------------------------------------------
/*
** Name      : get_user_guid_and_count
** Type      : Public, FND Internal
** Desc      : This procedure retrieves GUID from OID for the given userid
** Pre-Reqs  :
** Parameters: p_user_name: user name
** Parameters: out the number of entries fuond
** Notes     :
*/
 function get_user_guid_and_count(p_user_name in varchar2, n out nocopy pls_integer) return varchar2;
--
--
-------------------------------------------------------------------------------
/*
** Name      : get_user_guid
** Type      : Public, FND Internal
** Desc      : This procedure retrieves GUID from OID for the given user
** Pre-Reqs  :
** Parameters: p_user_name: user name
** Notes     :
*/
--function get_user_guid(p_user_name in varchar2) return raw;
--function get_user_guid(p_ldap_session in   dbms_ldap.session, p_user_name in varchar2) return raw ;
--function get_user_guid(p_ldap_session in   dbms_ldap.session, p_user_name in varchar2, dn out nocopy varchar2) return raw ;

--
-------------------------------------------------------------------------------
/*
** Name      : get_attribute_value
** Type      : Public, FND Internal
** Desc      : This procedure retrieves value for an attribute from OID given a **             user name
** Pre-Reqs  :
** Parameters: p_user_name: user name
**             p_attribute_name: attribute name
** Notes     : DEPRECATED, Reason: is to costly to located the user record using just the username
**
*/
/*
   function get_attribute_value(p_user_name in varchar2, p_attribute_name in varchar2) return varchar2;
*/
--
-------------------------------------------------------------------------------
/*
** Name      : user_exists_with_filter
** Type      : Public, FND Internal
** Desc      : This function queries the the OID based on the search filter constructed from the
               input attribute name and value pair.
** Pre-Reqs   :
** Parameters : p_attr_name, p_attr_value
** Notes      : REMOVED
*/
--function user_exists_with_filter(p_attr_name in varchar2, p_attr_value in varchar2) return pls_integer;
--
-------------------------------------------------------------------------------
/*
** Name      : validate_login
** Type      : Public, FND Internal
** Desc      : This procedure validates a user for a given password
**             Calling this API with invalid password will eventually LOCK the OiD Account.
**             It will return VALID only when the password is valid and the OiD Account is active and enabled.
**             When return INVALID will put on the FND Stack one of the following error codes
**                       FND_SSO_USER_PASSWD_EMPTY: wrong call parameters
**                       FND-9903: when OiD Setup is not correct
**                       FND_SSO_INV_AUTH_MODE: OiD SSL setup is incorrect
**                       FND_SSO_SYSTEM_NOT_AVAIL: Cannot connect to OiD
**                       FND-9914: Unexpected error connecting to OiD
**                       FND_SSO_NOT_LINKED: the given user name has no SSO associated
**                       FND_SSO_USER_NOT_FOUND: FND_USER.USER_GUID is invalid or corrupted
**                       FND_APPL_LOGIN_FAILED: Invalid Passowrd or unmanaged error validing password.
**                       FND_SSO_LOCKED: SSO Account is locked
**
**
**                       Only if the password is CORRECT , may fail with the following errors
**
**                       FND_SSO_NOT_ACTIVE: end_date is before today or start date is in the future.
**                       FND_SSO_PASSWORD_EXPIRED: SSO password is expired
**                       FND_SSO_USER_DISABLED:  SSO account is disabled
**
** Pre-Reqs  :
** Parameters: p_user_name: user name
**             p_password: password
** Notes     :
*/
function validate_login(p_user_name in varchar2, p_password in varchar2) return pls_integer;
--
-------------------------------------------------------------------------------


--type ldap_attribute_name_length as varchar2(200);
--type ldap_attribute_val_type is varchar2(32000);





/*
*
* API for intermediate LDAP_USER TDA
* INTERNAL ATG
*/

PROCEDURE setAttribute( usr in out nocopy ldap_user_type,
       attName in   varchar2,
       attVal in   varchar2,
       replaceIt in boolean default false );
PROCEDURE deleteAttribute( usr in out nocopy ldap_user_type,
       attName in varchar2,
       attVal in  varchar2 );
PROCEDURE deleteAttribute( usr in out nocopy ldap_user_type,
       attName in  varchar2);

FUNCTION getAttribute( usr in out nocopy ldap_user_type,
       attName in varchar2,
       attValIdx in pls_integer default 0 ) return varchar2;

FUNCTION attributePresent( usr in out nocopy ldap_user_type,
       attName in varchar2) return boolean;

/*
Record iteration: functions to traverse all the record ant its values,
, for example for printing.
*/
FUNCTION firstValue(usr in out nocopy ldap_user_type,
       attName in out nocopy varchar2,
       attValue in out nocopy varchar2,
       handle in out nocopy pls_integer ) return boolean; -- false when record is empty

/**
** FND - ATG Internal : do not use
** Used by : FND_LDAP_USER
*/

FUNCTION nextValue(usr in out nocopy ldap_user_type,
       attName in out nocopy varchar2,
       attValue in out nocopy varchar2,
       handle in out nocopy pls_integer ) return boolean; -- true if returned fields contains data


function get_username_from_guid(p_guid in fnd_user.user_guid%type)
    return varchar2;


/**
** FND - ATG Internal : do not use
** Used by : FND_OID_PLUG
*/
FUNCTION SearchUser (  username_z in varchar2,
    p_ldap_user IN OUT nocopy fnd_ldap_user.ldap_user_type)  return boolean;

-- LEGACY
----  DO NOT USE IT UNLESS THERE IS NO OPTION
----  MAY GENERATE UNNECESARY LDAP ACCESS.
/**
** FND - ATG Internal : do not use
** Used by : FND_OID_PLUG
*/
FUNCTION getNickNameAttr( username_z in varchar2) return varchar2;


function CanSync ( p_user_id in pls_integer, p_user_name in varchar2 ) return boolean;

end fnd_ldap_user;

/
