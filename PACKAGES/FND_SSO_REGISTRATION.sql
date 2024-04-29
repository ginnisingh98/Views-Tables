--------------------------------------------------------
--  DDL for Package FND_SSO_REGISTRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SSO_REGISTRATION" AUTHID CURRENT_USER AS
/* $Header: AFSCORGS.pls 120.5.12010000.5 2015/03/11 14:01:35 ctilley ship $*/

--
-- Exception which is thrown when an invalid registration is detected

G_INVALID_SETUP_EXP EXCEPTION;

--
-------------------------------------------------------------------------------
/*
** Name       : isOperationPermited
** Type       : Public, FND Internal
** Desc       : Indicates if Provisioning  Profile AppsToOID at OiD permits operations
**              IDENTITY_ADD,INDENTITY_MODIFY,IDENTITY_DELETE
** Pre-Reqs   :
** Parameters :
**              p_operation pls_integer Indicates the operation who permission
**                                      is to be determined. It could take
**                                      values such as fnd_ldap_wrapper.G_CREATE,
**                                      fnd_ldap_wrapper.G_UPDATE,
**                                      fnd_ldap_wrapper.G_DELETE.
**              x_fnd_user              Always returns fnd_ldap_wrapper.SUCCESS
**                                      since FND operations are always allowed.
**              x_oid                   Returns fnd_ldap_wrapper.SUCCESS if the
**                                      provisioning profile permits apps to perform
**                                      the operation at hand in OID.
**              p_user_name Used for custom DIT.
**                          If not null fnd_oid_plug.getRealmDN(p_user_name) will be used as realm.
**              p_realm_dn Realm to check. Ignored when p_user_name is not null.
**                         If both are null fnd_oid_plug.get_default_realm() will be used.
**
** Returns :
*/
procedure is_operation_allowed(p_operation in pls_integer,
                               x_fnd_user out nocopy pls_integer,
                               x_oid out nocopy pls_integer,
                               p_user_name in varchar2 default null,
                               p_realm_dn in varchar2 default null);

--
-------------------------------------------------------------------------------
/*
** Name       : is_operation_allowed
** Type       : Public, FND Internal
** Desc       : Indicates if Provisioning  Profile AppsToOID at OiD permits operations
**              IDENTITY_ADD,INDENTITY_MODIFY,IDENTITY_DELETE
** Pre-Reqs   :
** Parameters :
**              p_operation pls_integer Indicates the operation who permission
**                                      is to be determined. It could take
**                                      values such as fnd_ldap_wrapper.G_CREATE,
**                                      fnd_ldap_wrapper.G_UPDATE,
**                                      fnd_ldap_wrapper.G_DELETE.
**              x_fnd_user              Always returns fnd_ldap_wrapper.SUCCESS
**                                      since FND operations are always allowed.
**              x_oid                   Returns fnd_ldap_wrapper.SUCCESS if the
**                                      provisioning profile permits apps to perform
**                                      the operation at hand in OID.
**              p_attribute : a comma separated list of attributes to check
**              p_user_name Used for custom DIT.
**                          If not null fnd_oid_plug.getRealmDN(p_user_name) will be used as realm.
**              p_realm_dn Realm to check. Ignored when p_user_name is not null.
**                         If both are null fnd_oid_plug.get_default_realm() will be used.
**
** Returns :
*/

procedure is_operation_allowed(p_direction in pls_integer default FND_LDAP_WRAPPER.G_EBIZ_TO_OID,
				 p_entity in pls_integer,
				 p_operation in pls_integer,
				 p_attribute in out nocopy varchar2,
				 x_fnd_user out nocopy pls_integer,
                                 x_oid out nocopy pls_integer,
                               p_user_name in varchar2 default null,
                               p_realm_dn in varchar2 default null
                                 );

procedure get_user_or_site_profile (  profile_name in varchar2 ,
   user_name_z in varchar2 default null ,
   val_z out nocopy varchar2 ,
   defined_z out nocopy boolean );

function find_realm_index( dn in  varchar2 ) return pls_integer ;
function find_realm(idx in pls_integer) return varchar2;


function get_realm_data ( realm_idx in pls_integer ) return FND_LDAP_UTIL.ldap_record_type;

function get_realm_attribute( realm_idx in pls_integer, attName in varchar2, att_idx in pls_integer default 0  ) return varchar2;


function get_realm_attribute( realmDN in varchar2, attName in varchar2, att_idx in pls_integer default 0  ) return varchar2;


function getRealmSearchBaseList( realm_idx in pls_integer ) return dbms_ldap.string_collection;

-- returns the realm wher dn is under any of the searchbase

function getUserRealmIndex(dn in varchar2) return pls_integer;
function getGuidRealm(l_guid in FND_USER.user_guid%type) return varchar2;

function getDefaultRealm(ldap in out  nocopy dbms_ldap.session ) return varchar2;

function getDefaultRealm return varchar2;

-- OUD Support - Bug 19904770
function getLdapDirProv return varchar2;

function getLdapDirType return varchar2;

end FND_SSO_REGISTRATION;


/
