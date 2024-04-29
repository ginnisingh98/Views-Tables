--------------------------------------------------------
--  DDL for Package FND_LDAP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LDAP_UTIL" AUTHID CURRENT_USER as
/* $Header: AFSCOLTS.pls 120.8.12010000.7 2015/10/01 19:46:04 ctilley ship $ */
--
/*****************************************************************************/

type ldap_user_type is record (
    object_name                 varchar2(1024)
  , uid                         varchar2(1024)
  , sn                          varchar2(4000)
  , cn                          varchar2(4000)
  , userPassword                varchar2(4000)
  , telephoneNumber             varchar2(4000)
  , street                      varchar2(4000)
  , postalCode                  varchar2(4000)
  , physicalDeliveryOfficeName  varchar2(4000)
  , st                          varchar2(4000)
  , l                           varchar2(4000)
  , displayName                 varchar2(4000)
  , givenName                   varchar2(4000)
  , homePhone                   varchar2(4000)
  , mail                        varchar2(4000)
  , c                           varchar2(4000)
  , facsimileTelephoneNumber    varchar2(4000)
  , description                 varchar2(4000)
  , orclisEnabled               varchar2(4000)
  , orclActiveStartDate         varchar2(4000)
  , orclActiveEndDate           varchar2(4000)
  , orclGUID                    varchar2(4000)
);


type ldap_record_values  is table of dbms_ldap.STRING_COLLECTION index by varchar2(200);

type ldap_record_type is record (
   dn varchar2(4000),
   data ldap_record_values
);


-- Start of Package Globals

  G_SUCCESS             constant  pls_integer := 1;
  G_FAILURE             constant  pls_integer := 0;
  G_TRUE                constant  pls_integer := 1;
  G_FALSE               constant  pls_integer := 0;

  G_ENABLED             constant varchar2(10) := 'ENABLED';
  G_DISABLED            constant varchar2(10) := 'DISABLED';


  G_MAIL constant varchar2(4) := 'MAIL';
  G_FACSIMILETELEPHONENUMBER constant varchar2(24) := 'FACSIMILETELEPHONENUMBER';
	G_COM_PROD_ORCLECTX constant varchar2(4000) := 'cn=Common,cn=Products,cn=OracleContext';

  G_INTERNAL            constant varchar2(9) := '#INTERNAL';
  G_LDAP_SYNCH          constant varchar2(10) := 'LDAP_SYNCH';
  G_HOST                constant varchar2(4) := 'HOST';
  G_PORT                constant varchar2(4) := 'PORT';
  G_USERNAME            constant varchar2(8) := 'USERNAME';
  G_EPWD                constant varchar2(4) := 'EPWD';
  G_LDAP_PWD            constant varchar2(8) := 'LDAP_PWD';
  G_DBLDAPAUTHLEVEL     constant varchar2(15) := 'dbldapauthlevel';
  G_DBWALLETDIR         constant varchar2(11) := 'dbwalletdir';
  G_DBWALLETPASS        constant varchar2(12) := 'dbwalletpass';
 -- default DAS operation url base
   G_DEFAULT_BASE constant varchar2(100) := 'cn=OperationURLs,cn=DAS,cn=Products,cn=OracleContext';
-- End of Package Globals
--
-------------------------------------------------------------------------------
/*
** Name      : get_oid_session
** Type      : Public, FND Internal
** Desc      :
** Pre-Reqs   :
** Parameters  :
*/
function get_oid_session return dbms_ldap.session;

function c_get_oid_session(flag in out nocopy pls_integer) return dbms_ldap.session;
procedure c_unbind(ldap in out nocopy dbms_ldap.session , flag in out nocopy pls_integer);
--
-------------------------------------------------------------------------------
/*
** Name      : unbind
** Type      : Public, FND Internal
** Desc      : This function unbinds an ldap_session
** Pre-Reqs   :
** Parameters  :
** Notes      :
*/
function unbind(p_session in out nocopy dbms_ldap.session) return pls_integer;
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
** Name      : get_users_nodes
** Type      : Public, FND Internal
** Desc      : This function gets the value of orclcommondefaultusercreatebase
               from OID
** Pre-Reqs   :
** Parameters  :
** Notes      :
** DEPRECATED AND REMOVED, use
**     get_user_create_base(username)
**     get_user_search_base(username)

**
*/
 -- function get_users_nodes return dbms_ldap.string_collection;

-------------------------------------------------------------------------------
/*
** Name      : get_user_create_base
** Type      : Public, FND Internal
** Desc      : This function returns the DN where the user should be created
** Pre-Reqs   :
** Parameters  :
** Notes      :
**
*/
--function get_user_create_base(username in out nocopy varchar2) return varchar2;

-------------------------------------------------------------------------------
/*
** Name      : get_user_search_base
** Type      : Public, FND Internal
** Desc      : This function returns the DN where the user can be searched
** Pre-Reqs   :get_user_create_base
** Parameters  :
** Notes      :
**
*/
--function get_users_search_base(username in out nocopy varchar2) return varchar2;


--
-------------------------------------------------------------------------------
/*
** Name      : get_search_nodes
** Type      : Public, FND Internal
** Desc      : This function gets the value of orclcommonusersearchbase
               from OID
** Pre-Reqs   :
** Parameters  :
** Notes      : REMOVED , use get_User_create_base(username)/ get_user_search_base(username)
*/
-- function get_search_nodes return dbms_ldap.string_collection;
--
-------------------------------------------------------------------------------
/*
** Name      : get_mandatory_user_attrib
** Type      : Public, FND Internal
** Desc      : This function gets the value of orclcommonnicknameattribute from
               OID
** Pre-Reqs   :
** Parameters  :
** Notes      :
*/
--function get_orclcommonnicknameattr(username in out nocopy varchar2)  return varchar2;
--
-------------------------------------------------------------------------------
/*
** Name      : get_dn_for_guid
** Type      : Public, FND Internal
** Desc      : This function gets the dn for user specified by the guid
** Pre-Reqs   :
** Parameters : orcl_guid
** Notes      :
*/
function get_dn_for_guid(p_orclguid in fnd_user.user_guid%type) return varchar2;
--
-------------------------------------------------------------------------------
/*
** Name      : get_dn_for_guid
** Type      : Public, FND Internal
** Desc      : This function gets the dn for user specified by the guid
** Pre-Reqs   :
** Parameters : orcl_guid
** Notes      :
*/
function get_dn_for_guid(p_orclguid in fnd_user.user_guid%type,
			 p_ldap_session in dbms_ldap.session) return varchar2;
--
-------------------------------------------------------------------------------
/*
** Name      : get_default_realm
** Type      : Public, FND Internal
** Desc      : This function gets the default realm from OID
** Pre-Reqs   :
** Parameters :
** Notes      : removed , use get_realm(username) instead
*/
-- function get_default_realm return varchar2;

-------------------------------------------------------------------------------
/*
** Name      : get_realm
** Type      : Public, FND Internal
** Desc      : This function gets the default realm from OID
** Pre-Reqs   :
** Parameters :
** Notes      : removed , use get_realm(username) instead
*/
-- function get_default_realm(username in out nocopy varchar2) return varchar2;

--
-------------------------------------------------------------------------------
/*
** Name      : get_guid_for_dn
** Type      : Private (? , probably others will need this ,
**              is it a candidate for the API ?
** Desc      : Given and DN return its orclguid
**             if DN is not found, the raise "NO_DATA_FOUND'

** Parameters  :
**        aDN: the application DN, for example
**              orclApplicationCommonName=PROD1,cn=EBusiness,cn=Products,cn=OracleContext,dc=us,dc=oracle,dc=com
** Returns :
**      Its orclguid
**       If it is NULL then the DN does not have a orcGuild attribute
** Exceptions:
**      DATA_NOT_FOUND if search_s raise DBMS_LDAP.GENERAL_EXCEPTION
**             NOte that this DBMS_LDAP exception maybe risen by other reasons
**
*/
function get_guid_for_dn(ldapSession in dbms_ldap.session,p_dn in varchar2) return varchar2;

--
-------------------------------------------------------------------------------
/*
** Name      : proxy_as_user
** Type      : Public, FND Internal
** Desc      : This procedure proxies as the given user. This is used when we don't
**             want to expire a user's password in cases such as a user updating
**             one's own password
** Pre-Reqs   :
** Parameters : p_orclguid: GUID of the user that acts a proxy user
**              x_ldap_session: returns a valid OID session. Must be released bu caller of
**              the API
** Notes      :
*/
procedure proxy_as_user(p_orclguid in fnd_user.user_guid%type, x_ldap_session out nocopy dbms_ldap.session);
--
-------------------------------------------------------------------------------

 /*
 ** Name      : get_DAS_OperationUrl
 ** Type      : Public, FND Internal
 ** Desc      : This functions return and URL suitable for the requested operation
 **              Support multiple realms specific definitions.
 ** Pre-Reqs   :
 ** Parameters : p_orclguid: GUID of the user that acts a proxy user
 **              x_ldap_session: returns a valid OID session. Must be released bu caller of
 **              the API
 ** Notes      :
 **             There are  lot of Urls, most used maybe
 **                   Password Change
 **                   TimeZone
 **                   Edit My Profile
 **                   View User Profile
 **                   Reset Password
 */

 function get_DAS_OperationUrl(p_realm in varchar2, p_operation in varchar2) return varchar2;
 --
-------------------------------------------------------------------------------
/*
** Name      : add_attribute_M
** Type      : Public, FND Internal
** Desc      : This procedure add an attribute to an entry when then attribute has
**             multiple values
** Pre-Reqs   :
** Parameters : p_orclguid: GUID of the user that acts a proxy user
**              x_ldap_session: returns a valid OID session. Must be released bu caller of
**              the API
** Notes      :
*/
procedure add_attribute_M(x_ldap  in dbms_ldap.session, dn in varchar2, name in  varchar2, value in  varchar2 );
--
-------------------------------------------------------------------------------


/**
** INTERNAL ATG-SSO
**/

function getLDAPAttribute(
        ldap in out nocopy dbms_ldap.session,
        dn in  varchar2,
        attrName in varchar2,
        filterExp in varchar2 default 'objectclass=*')
 return varchar2;
--
------------------------------------------------------------------------------

G_GUID_KEY pls_integer :=0;
G_DN_KEY pls_integer :=1;

function loadLdapRecord( ldapSession in out nocopy dbms_ldap.session, rec in out nocopy ldap_record_type,
           key in varchar2, key_type in pls_integer default G_DN_KEY ) return boolean;

function loadLdapRecord( ldapSession in out nocopy dbms_ldap.session, rec in out nocopy ldap_record_values, dn out nocopy varchar2,
           key in varchar2, key_type in pls_integer default G_DN_KEY ) return boolean;

--Bug 19904770 : Support OUD
-------------------------------------------------------------------------------
/*
** Name      : get_provprofilecontainer
** Type      : Public, FND Internal
** Desc      : This function returns the provisioning container from Workflow
** Pre-Reqs   :
** Parameters  :
** Notes      :
*/
function get_provprofilecontainer return varchar2;

--Bug 19904770 : Support OUD
-------------------------------------------------------------------------------
/*
** Name      : is_oudldaptype
** Type      : Public, FND Internal
** Desc      : This function returns G_TRUE if the ldap server is OUD
**           : G_FALSE otherwise
** Pre-Reqs   :
** Parameters  :
** Notes      :
*/
function is_oudldaptype return pls_integer;


-- External/Internal Authentication - decouple APPS_SSO from sync
-- Ref bug 21882506
-------------------------------------------------------------------------------
/*
** Name      : isLDAPAccessible
** Type      : Public, FND Internal
** Desc      : This function returns G_TRUE if the ldap server is accessible
**           : G_FALSE otherwise
** Pre-Reqs   :
** Parameters  : None
** Notes      :  This is used to determine whether the LDAP server that is integrated
** is available and accessible
*/
function isLDAPAccessible return boolean;

/*
** Name      : isLDAPIntegrationEnabled
** Type      : Public, FND Internal
** Desc      : This function returns G_TRUE if an LDAP server is integrated with this EBS instance
**           : G_FALSE otherwise
** Pre-Reqs  :
** Parameters:  None
** Notes     :  This is used to determine whether the LDAP integration is enabled.
*/
function isLDAPIntegrationEnabled return boolean;


/*
** Name      : isLDAPIntegrationEnabled
** Type      : Public, FND Internal
** Desc      : This function returns G_TRUE if an LDAP server is integrated with this EBS instance
**           : G_FALSE otherwise
** Pre-Reqs  :
** Parameters:  None
** Notes     :  This is used to determine whether the LDAP server is integrated
**
*/
function isLDAPIntegrated return boolean;


end fnd_ldap_util;

/
