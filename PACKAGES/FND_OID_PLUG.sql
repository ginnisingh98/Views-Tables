--------------------------------------------------------
--  DDL for Package FND_OID_PLUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OID_PLUG" AUTHID CURRENT_USER AS
/* $Header: AFSCOPGS.pls 120.0.12010000.7 2015/03/11 14:09:01 ctilley ship $ */



/*
  Pluggin administration functions
*/

/*
*** PLUGIN TYPES
* G_STATIC: realm and user create base are fixed
* G_DYNAMIC : realm and user create base depends on the user
*/
--G_STATIC integer := 0;
--G_DYNAMIC integer :=1 ;
/*
** CONFIG PREFERENCES
*
*/
G_CREATE_USER constant pls_integer:=0;
G_UPDATE_USER constant pls_integer:=1;

L_REALM  varchar2(30):='REALM';

L_REPOSITORY varchar2(30):='CREATE_BASE';
L_TYPE varchar2(30):='TYPE';

/*
** Config used to cache values
*/
L_CN_ATT varchar2(30):='CN_ATT_CACHED';
L_NICK_ATT varchar2(30):='NICK_ATT_CACHED';
L_SEARCH varchar2(30):='SEARCH_BASE_CACHED';
L_RDN varchar2(30):='RDN_CACHED';

CONFIGURATION_ERROR exception;


  --type ldap_record is table of dbms_ldap.STRING_COLLECTION index by varchar2(1000);

user_data FND_LDAP_UTIL.ldap_record_values;

 procedure SetPlugin(
p_defaultRealm in varchar2 default null,
p_default_user_repository in varchar2 default null,
plugin_name in varchar2 default null
);

 procedure setPlugin_old(
         default_realm in varchar2 default null,
         default_user_repository in varchar2 default null,
         plugin_name in varchar2 default null);


/**
** FND: ATG Internal: We are plannign to change them in the near future
**/
/*
** FND: ATG Internal
** Use By: FND_LDAP_USER
*/
function get_realm_dn( p_user_guid in raw default null, p_user_name in varchar2 default null) return varchar2;

function count_attributes( ldap in out nocopy dbms_ldap.session, dn in   varchar2, attName in   varchar2)
    return integer;

/*
** FND: ATG Internal
** Use By: FND_LDAP_USER
*/
function get_realm_from_user_dn(ldap in out nocopy dbms_ldap.session, user_dn in varchar2 ) return varchar2;
/*
** FND: ATG Internal
** Use By: FND_SSO_REGISTRATION
*/
function get_default_realm return varchar2;
/*
** FND: ATG Internal
** Use By: FND_SSO_REGISTRATION
*/
function getRealmDN(username in  varchar2) return varchar2;

/*
** FND: ATG Internal
** OUD Support added new APIs - ref bug 19904770
** Use By: FND_SSO_REGISTRATION
*/
function getLdapDirType return varchar2;

/*
** FND: ATG Internal
** OUD Support added new APIs - ref bug 19904770
** Use By: FND_SSO_REGISTRATION
*/
function getLdapDirProv return varchar2;

/*
** FND: ATG Internal
** DO NOT USE
** Heavy consumer !! Will search first in LDAP to see if the user exists!!
** Use By: FND_LDAP_MAPPER => Need to fix
*/
function getNickNameattr(username in varchar2) return varchar2;

/*
** FND: ATG Internal
** Use By: FND_LDAP_USER
*/
Procedure completeForCreate(ldap in dbms_ldap.session ,p_ldap_user IN OUT nocopy fnd_ldap_user.ldap_user_type );

/*
** FND: ATG INTERNAL
**
*/
PROCEDURE FixupLDAPUser( p_ldap_user    IN OUT nocopy FND_LDAP_USER.ldap_user_type, operation pls_integer);

FUNCTION Helper_NewEmptyCollection return DBMS_LDAP.STRING_COLLECTION;
/*
** FND: ATG Internal
** Use By: FND_SSO_REGISTRATION
** Currently return a list with the default realm
*/

function getRealmList return dbms_ldap.string_collection;


-- TEMPLATE
-- COPY + PASTE + IMPLEMENT
-- remove the '_template' from the name
-- DO NOT CHANGE parameter names or its datatypes
--procedure getRDN( username in varchar2, userid in pls_integer,
  -- RDN_attName in out nocopy varchar2, RND_value in out nocopy varchar2, replaceFlag out pls_integer);

procedure getDefaultRealm_Template(realm out nocopy varchar2);
procedure getDefaultCreateBase_Template(realm in varchar2, parentDN out nocopy varchar2 ) ;
procedure getCreateBase_Template( user_id in INTEGER, user_name in varchar2,realm in varchar2, parentDn out nocopy varchar2) ;
procedure getRealm_Template( user_id in INTEGER, user_name in varchar2, realmDn out nocopy varchar2) ;
procedure getRDN_Template( user_name in varchar2, user_id in pls_integer, RDN_attName in out nocopy varchar2,
   RND_value in out nocopy varchar2, replaceFlag in out nocopy pls_integer);
procedure fixupLDAPUser_Template( user_id in INTEGER, user_name in varchar2, operation in pls_integer) ;


-- Replace = 0 -> no, append it to the record
-- Replace = 1 -> yes, replace if the value is present
--- or use these values

G_NO_REPLACE_FLAG pls_integer := 0;
G_ADD_FLAG pls_integer := 0;
G_REPLACE_FLAG pls_integer := 1;




END FND_OID_PLUG;

/
