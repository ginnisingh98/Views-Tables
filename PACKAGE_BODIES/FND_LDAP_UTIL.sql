--------------------------------------------------------
--  DDL for Package Body FND_LDAP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LDAP_UTIL" as
/* $Header: AFSCOLTB.pls 120.16.12010000.15 2016/02/01 18:53:32 ctilley ship $ */
--
-- Start of Package Globals

  G_MODULE_SOURCE  constant varchar2(80) := 'fnd.plsql.oid.fnd_ldap_util.';
  G_TRACK_LDAP_STACK   constant boolean:= false;

  ldap_session_stack varchar2(4096):= null;

   g_das_product_base varchar2(1000) := NULL;
   g_das_base_url varchar2(1000) := NULL;
   g_das_relative_base constant varchar2(100) := 'cn=OperationUrls,cn=DAS,cn=Products,cn=OracleContext';


g_common_ldap dbms_ldap.session;
g_common_counter pls_integer :=0;


-- End of Package Globals
--
-------------------------------------------------------------------------------
  init boolean := false;
  nickname  varchar2(256) := null;
	r_init boolean := false;
  d_realm  varchar2(4000) := null;
--
-------------------------------------------------------------------------------
function get_oid_session return dbms_ldap.session is

  l_module_source varchar2(256);
  l_retval          pls_integer;
  l_host         varchar2(256);
  l_port         varchar2(256);
  l_user         varchar2(256);
  l_pwd          varchar2(256);
  l_ldap_auth    varchar2(256);
  l_db_wlt_url   varchar2(256);
  l_db_wlt_pwd   varchar2(256);
  l_session      dbms_ldap.session;

begin
  l_module_source := G_MODULE_SOURCE || 'get_oid_session: ';
  -- change it to FAILURE if open_ssl fails, else let the simple_bind_s
  -- go through
  l_retval := dbms_ldap.SUCCESS;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  dbms_ldap.use_exception := TRUE;

  l_host := fnd_preference.get(G_INTERNAL, G_LDAP_SYNCH, G_HOST);
  l_port := fnd_preference.get(G_INTERNAL, G_LDAP_SYNCH, G_PORT);
  l_user := fnd_preference.get(G_INTERNAL, G_LDAP_SYNCH, G_USERNAME);
  l_pwd  := fnd_preference.eget(G_INTERNAL, G_LDAP_SYNCH, G_EPWD, G_LDAP_PWD);
  l_ldap_auth := fnd_preference.get(G_INTERNAL, G_LDAP_SYNCH, G_DBLDAPAUTHLEVEL);
  l_db_wlt_url := fnd_preference.get(G_INTERNAL, G_LDAP_SYNCH, G_DBWALLETDIR);
  l_db_wlt_pwd := fnd_preference.eget(G_INTERNAL, G_LDAP_SYNCH, G_DBWALLETPASS, G_LDAP_PWD);

  l_session := DBMS_LDAP.init(l_host, l_port);

  -- Elan, 04/27/2004, Not disclosing the password - gets saved to the database
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source
    , 'l_host = ' || l_host || ', l_port = ' || l_port ||
    ', l_ldap_auth = ' || l_ldap_auth || ', l_db_wlt_url = ' ||
     l_db_wlt_url ||
     ', l_user = ' || l_user || ', l_pwd = ****');
  end if;

  if ( l_ldap_auth > 0 )
  then
    l_retval := dbms_ldap.open_ssl
      (l_session, 'file:'||l_db_wlt_url, l_db_wlt_pwd, l_ldap_auth);
  end if;

  --dbms_ldap.use_exception := false;
  --retval := dbms_ldap.open_ssl(my_session, ' ', ' ', 1);

  if (l_retval = dbms_ldap.SUCCESS) then
    l_retval := dbms_ldap.simple_bind_s(l_session, l_user, l_pwd);
  else
    fnd_message.set_name ('FND', 'FND_SSO_SSL_ERROR');
    raise_application_error(-20002, 'FND_SSO_SSL_ERROR');
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return l_session;

exception
when dbms_ldap.invalid_session then
  fnd_message.set_name ('FND', 'FND_SSO_INV_SESSION');
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;
when dbms_ldap.invalid_ssl_wallet_loc then
  fnd_message.set_name ('FND', 'FND_SSO_WALLET_LOC');
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;
when dbms_ldap.invalid_ssl_wallet_passwd then
  fnd_message.set_name ('FND', 'FND_SSO_WALLET_PWD');
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;
when dbms_ldap.invalid_ssl_auth_mode then
  fnd_message.set_name ('FND', 'FND_SSO_INV_AUTH_MODE');
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;

end get_oid_session;
--
-------------------------------------------------------------------------------
function unbind(p_session in out nocopy dbms_ldap.session) return pls_integer
is
  retval pls_integer;
  l_module_source varchar2(256);
begin

  l_module_source := G_MODULE_SOURCE || 'unbind: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  retval := dbms_ldap.unbind_s(p_session);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return retval;

exception
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;

end unbind;
--
-------------------------------------------------------------------------------
/* this procedure removes any " in the appName. Some deployments have this special character */
procedure removeExtraQuotes(p_app in out nocopy varchar2) is

quotesIndex pls_integer;
strLength pls_integer;
l_module_source varchar2(256);

begin

  l_module_source := G_MODULE_SOURCE || 'removeExtraQuotes: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  strLength := length(p_app);

  while instr(p_app, '"') <> 0 loop
    quotesIndex := instr(p_app, '"');
    p_app := Substr(p_app, 0, quotesIndex-1) || Substr(p_app, quotesIndex+1, strLength);
  end loop;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

exception
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;

end removeExtraQuotes;
---------------------------------------------------------------
-- The username to connecto oid
function get_orclappname return varchar2 is

l_module_source   varchar2(256);
orclAppName varchar2(256);

begin

  l_module_source := G_MODULE_SOURCE || 'get_orclappname: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  -- Bug 5001849 use FND API instead of directly doing a select against
  -- fnd_user_preferences

   orclAppName := fnd_preference.get(p_user_name => '#INTERNAL',
                                    p_module_name => 'LDAP_SYNCH',
                                    p_pref_name => 'USERNAME');

  removeExtraQuotes(orclAppName);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return orclAppName;

exception
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;

end get_orclappname;


--
-------------------------------------------------------------------------------
-- DELETED
--   function get_users_nodes return dbms_ldap.string_collection
--
-------------------------------------------------------------------------------
function get_dn_for_guid(p_orclguid in fnd_user.user_guid%type) return varchar2 is

l_module_source   varchar2(256);
result pls_integer;
l_dn  varchar2(1000);
l_base varchar2(1000);
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;
l_ldap_session dbms_ldap.session;

begin

  l_module_source := G_MODULE_SOURCE || 'get_dn_for_GUID: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  l_base := '';
  l_ldap_session := get_oid_session;

  result := dbms_ldap.search_s(ld => l_ldap_session
                             , base => l_base
			     , scope => dbms_ldap.SCOPE_SUBTREE
			     , filter => 'orclguid='||p_orclguid
			     , attrs => l_attrs
			     , attronly => 0
			     , res => l_message);
   l_entry := dbms_ldap.first_entry(l_ldap_session, l_message);

   if (l_entry is null) then
     l_dn := null;
   else
     l_dn := dbms_ldap.get_dn(l_ldap_session, l_entry);
   end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'GUID::'||p_orclguid||' DN::'||l_dn);
  end if;

  result := unbind(l_ldap_session);

  if (l_dn is null) then
    raise no_data_found;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return l_dn;

exception
when no_data_found then
  fnd_message.set_name ('FND', 'FND_SSO_USER_NOT_FOUND');
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'No user found with the given GUID');
  end if;
  raise;
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;

end get_dn_for_GUID;
--
-------------------------------------------------------------------------------
function get_dn_for_guid(p_orclguid in fnd_user.user_guid%type,
			 p_ldap_session in dbms_ldap.session) return varchar2 is

l_module_source   varchar2(256);
result pls_integer;
l_dn  varchar2(1000);
l_base varchar2(1000);
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;

begin

  l_module_source := G_MODULE_SOURCE || 'get_dn_for_GUID: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  l_base := '';

  result := dbms_ldap.search_s(ld => p_ldap_session
                             , base => l_base
			     , scope => dbms_ldap.SCOPE_SUBTREE
			     , filter => 'orclguid='||p_orclguid
			     , attrs => l_attrs
			     , attronly => 0
			     , res => l_message);
   l_entry := dbms_ldap.first_entry(p_ldap_session, l_message);

   if (l_entry is null) then
     l_dn := null;
   else
     l_dn := dbms_ldap.get_dn(p_ldap_session, l_entry);
   end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'GUID::'||p_orclguid||' DN::'||l_dn);
  end if;

  if (l_dn is null) then
    raise no_data_found;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return l_dn;

exception
when no_data_found then
  fnd_message.set_name ('FND', 'FND_SSO_USER_NOT_FOUND');
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'No user found with the given GUID');
  end if;
  raise;
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;

end get_dn_for_GUID;
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
function get_guid_for_dn(ldapSession in dbms_ldap.session,p_dn in varchar2) return varchar2
is

  result pls_integer;
  l_message dbms_ldap.message := null; -- the query result set
  l_entry dbms_ldap.message := null; -- the entry
  l_attrs dbms_ldap.string_collection; -- lookup attributes
  l_guid varchar2(100); -- returning guid
  err varchar2(1000);
  l_module_source varchar2(256);
begin
  l_module_source := G_MODULE_SOURCE || 'get_guid_for_dn:';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'DN='||p_dn);
   end if;

  l_attrs(0) := 'orclGuid';
  begin
       result := dbms_ldap.search_s(ld => ldapSession,
          base => p_dn,
          scope => dbms_ldap.SCOPE_BASE,
          filter => 'objectclass=*',
          attrs => l_attrs,
          attronly => 0,
          res => l_message);
      exception
         when dbms_ldap.general_error then
                -- asume that DN not found
                -- is not accurate, but better that nothing
                err := SQLERRM;
                if (instr(err,'No such object')>1) then
                     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
                     then
                           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
			   ' DN not found : raise NO_DATA_FOUND');
                    end if;
                     raise NO_DATA_FOUND;
                else
                     if (fnd_log.LEVEL_EXCEPTION>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
                     then
                           fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, SQLERRM);
                           fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, ' from dbms_ldap.search_s, dn='||p_dn);
                    end if;
                    raise;
                end if;
  end;
  l_entry := dbms_ldap.first_entry(ldapSession, l_message);
  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'orclGuid');
  begin
     l_guid := l_attrs(0);
     exception
        when NO_DATA_FOUND then
           -- this entry does not have orclguid
           l_guid := null;
  end;


   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' END : guid='||l_guid);
   end if;
   return l_guid;

exception
	when others then
	    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
		then
		      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, ' for DN='||p_dn);
		      fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
	    end if;
	    raise;
end get_guid_for_dn;
--
-------------------------------------------------------------------------------
function get_default_realm(username in out nocopy varchar2) return varchar2 is

l_module_source   varchar2(256);
result pls_integer;
l_result varchar2(4000);
l_base varchar2(100);
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;
l_ldap_session dbms_ldap.session;

begin

  l_module_source := G_MODULE_SOURCE || 'get_default_realm ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
  l_result := FND_OID_PLUG.getRealmDN(username);
  if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'realm: '||l_result);
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

  return l_result;

exception
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;

end get_default_realm;
--
-------------------------------------------------------------------------------
-- DELETED
-- function get_search_nodes return dbms_ldap.string_collection is

--
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
procedure proxy_as_user(p_orclguid in fnd_user.user_guid%type, x_ldap_session out nocopy dbms_ldap.session) is

  l_module_source	varchar2(256);
  l_retval		pls_integer;
  l_dn			varchar2(512);

  proxy_failed_exp	exception;

  PRAGMA EXCEPTION_INIT (proxy_failed_exp, -20002);

begin
  l_module_source := G_MODULE_SOURCE || 'proxy_as_user: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  x_ldap_session := fnd_ldap_util.get_oid_session;
  l_dn := get_dn_for_guid(p_orclguid => p_orclguid, p_ldap_session => x_ldap_session);

  dbms_ldap.use_exception := true;

  l_retval := dbms_ldap.simple_bind_s(x_ldap_session, l_dn, null);

  if (l_retval = dbms_ldap.SUCCESS) then
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Proxied Successfully for User DN:' ||
      l_dn);
    end if;
  else
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Proxy Failed for User DN: ' ||
      l_dn);
    end if;
    raise proxy_failed_exp;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  --return l_session;

exception
when dbms_ldap.invalid_session then
  fnd_message.set_name ('FND', 'FND_SSO_INV_SESSION');
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;

end proxy_as_user;
--
-------------------------------------------------------------------------------
/*
** Name      : get_attribute
** Type      : Private
**              is it a candidate for the API ?
** Desc      : Given a DN  and an attribut rename returns the value for that entry.
**             if DN is not found, the raise "NO_DATA_FOUND'

** Parameters  :
**        p_ldap_session: a valid connection
**         p_dn: DN
**        p_attr_name: Attribute name
**
**
** Returns :
**       The value.
**       Returns NULL in the cases that attribute is not present in the entry, or the DN does not exists
** Exceptions: NONE (? maybe change it to NODATAFOUND for the DN missing case)
**
*/


  FUNCTION get_attribute(p_ldap_session IN dbms_ldap.SESSION,   p_dn IN VARCHAR2,   p_attr_name IN VARCHAR2) RETURN VARCHAR2 IS l_module_source VARCHAR2(256);
  l_attrs dbms_ldap.string_collection;
  l_result VARCHAR2(1000);
  result pls_integer;
  l_entry dbms_ldap.message := NULL;
  l_message dbms_ldap.message := NULL;
  BEGIN
    l_module_source := g_module_source || 'get_Attribute ';

    IF(fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,   l_module_source,   'Begin ');
    END IF;
    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   l_module_source,   ' dn:' || p_dn || ' attr:' || p_attr_name);
    END IF;

    l_attrs(0) := p_attr_name;
    result := dbms_ldap.search_s(ld => p_ldap_session,   base => p_dn,
                  scope => dbms_ldap.scope_base,   filter => '(objectclass=*)',
                  attrs => l_attrs,   attronly => 0,   res => l_message);
    l_entry := dbms_ldap.first_entry(p_ldap_session,   l_message);
    l_attrs := dbms_ldap.get_values(p_ldap_session,   l_entry,   p_attr_name);
    BEGIN
        l_result := l_attrs(0);
        EXCEPTION WHEN NO_DATA_FOUND THEN
           IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
               fnd_log.string(fnd_log.level_statement,   l_module_source,   'attribute '||p_attr_name||' not present at '||p_dn);
           END IF;
          l_result := null; -- DN found, but does not contain the attribute
    END;

    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   l_module_source,   'END-> ' || l_result);
    END IF;
    return l_result;

   EXCEPTION
    WHEN dbms_ldap.general_error THEN
             BEGIN

              IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement,   l_module_source,   'END-> not found '||sqlerrm);
              END IF;
              return null; -- DN NOT FOUND
             END;
    WHEN OTHERS THEN

    IF(fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_error,   l_module_source,   sqlerrm);

      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,   l_module_source,   'END-> RAISE');
      END IF;

    END IF;

    RAISE;
  END get_attribute;

  --
-------------------------------------------------------------------------------
/*
** Name      : get_das_base_url
** Type      : Private
** Desc      : Returns the DAS url like 'http://xxx:123/oiddas/'
**             All the operations URL are relative to this.
** Parameters  :
**        p_ldap_session: a valid connection
**        p_realm_dn: The realm
**
**
** Returns :  and Url string
** Exceptions: NONE (? maybe change it to NODATAFOUND for the DN missing case)
**
**  Note:
**	Although it may seems it support multiple realms it does not.
**      Since the value is cached, only the first value will be returned after that, even for other realms.
**      THIS NEEDS TO BE FIXED for multiple realm support
*/


  FUNCTION get_das_base_url(p_ldap_session IN dbms_ldap.SESSION,   p_realm_dn IN VARCHAR2) RETURN VARCHAR2 IS

   l_module_source VARCHAR2(256);
  l_url VARCHAR2(2000);
  l_attrs dbms_ldap.string_collection;
  l_result VARCHAR2(1000);
  l_try VARCHAR2(1000);

  BEGIN
    l_module_source := g_module_source || 'get_DAS_BASE_URL ';

    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   l_module_source,   'Begin ');
    END IF;

    IF(g_das_base_url is not NULL) THEN

      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,   l_module_source,   'END (cached)-> ' || g_das_base_url);
      END IF;

      RETURN g_das_base_url;
    END IF;
    l_try :=  g_das_relative_base||','||p_realm_dn;
    l_result := get_attribute(p_ldap_session,l_try, 'orcldasurlbase' );
    if (l_result is not null)
    THEN
        g_das_product_base := l_try;
        g_das_base_url := l_result;
        IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string(fnd_log.level_statement,   l_module_source,   '    DAS_BASE_DN ' || g_das_product_base);
           fnd_log.string(fnd_log.level_statement,   l_module_source,   '    DAS_URL-> ' || g_das_base_url);
           fnd_log.string(fnd_log.level_statement,   l_module_source,   'END -> ' || g_das_base_url);
        END IF;

        return g_das_base_url;
    END IF;
     l_try :=  g_das_relative_base;
     l_result := get_attribute(p_ldap_session,l_try, 'orcldasurlbase' );
     if (l_result is not null)
     THEN
        g_das_product_base :=l_try;
        g_das_base_url := l_result;
        IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string(fnd_log.level_statement,   l_module_source,   '    DAS_BASE_DN ' || g_das_product_base);
           fnd_log.string(fnd_log.level_statement,   l_module_source,   '    DAS_URL-> ' || g_das_base_url);
           fnd_log.string(fnd_log.level_statement,   l_module_source,   'END -> ' || g_das_base_url);
        END IF;
        return g_das_base_url;
     END IF;
      /*
      * Incorrect settings or something
      */
      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.string(fnd_log.level_statement,   l_module_source,   'END-> FAILED ' );
      END IF;
      G_DAS_PRODUCT_BASE:=NULL;
      G_DAS_BASE_URL := NULL;
      return NULL;

  EXCEPTION WHEN others THEN

    IF(fnd_log.level_error >= fnd_log.g_current_runtime_level)
    THEN
         fnd_log.string(fnd_log.level_error,   l_module_source,   sqlerrm);
    END IF;

     fnd_message.set_name('FND',   'get_DAS_BASE_URL'); RETURN NULL;
  END get_das_base_url;
  --
  -------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
/*
** Name      : get_das_operationurl
** Type      : Private (FND Internal)
** Desc      : Return URL for operation (For exmaple 'Password Change' at DAS.

** Parameters  :
**        p_realm: The realm , NULL for request default value.
**	p_operation: operation (see package schema for examples )
** Returns :
**	A URL string
** Exceptions: NONE
**
** Note: This function can be tested from SQL*Plus , for example
**		select  fnd_ldap_util.get_das_operationurl(null,'Password Change') from dual;
**
**                  http://rslnz.us.oracle.com:7777/oiddas/ui/oracle/ldap/das/mypage/AppChgPwdMyPage
*/

   FUNCTION get_das_operationurl(p_realm IN VARCHAR2,   p_operation IN VARCHAR2) RETURN VARCHAR2 IS


  l_result VARCHAR2(4000) := NULL;
  l_base VARCHAR2(4000) := NULL;
  l_ldap_session dbms_ldap.SESSION;
  l_module_source varchar2(2000);
  result pls_integer;
  BEGIN
    l_module_source := g_module_source || 'get_das_operationurl ';

    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   l_module_source,   'Begin ');
      fnd_log.string(fnd_log.level_statement,   l_module_source,   ' realm:' || p_realm || ' op:"' || p_operation||'"');
    END IF;

    l_ldap_session := fnd_ldap_util.get_oid_session;
    IF (p_realm is NOT null)
    THEN

       l_result := get_attribute(l_ldap_session,  'cn='|| p_operation||','|| g_das_relative_base||','||p_realm, 'orcldasurl' );
       l_base := get_das_base_url(l_ldap_session,p_realm);
      IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

         fnd_log.string(fnd_log.level_statement,   l_module_source,   ' op_url:' || l_result);
         fnd_log.string(fnd_log.level_statement,   l_module_source,   ' base:' || l_base);

      END IF;
    END IF;
    -- For no realm returned the default data (which is not the same
    -- as data for the default realm )
    if (p_realm is NULL or l_result is null)
    THEN
         IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,   l_module_source,   ' get default Urls');
         END IF;

        l_result := get_attribute(l_ldap_session,   'cn='||p_operation||','||g_das_relative_base, 'orcldasurl' );
        l_base := get_das_base_url(l_ldap_session,null);
         IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,   l_module_source,   ' op_url:' || l_result);
            fnd_log.string(fnd_log.level_statement,   l_module_source,   ' base:' || l_base);
         END IF;
  END IF;

    result := fnd_ldap_util.unbind(l_ldap_session);
    if (l_result is null or l_base is null)
    then
         IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,   l_module_source,   'END->NULLl:');
         END IF;
        return NULL;
    end if;
    IF(fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,   l_module_source,   'END-> ' || l_base||l_result);
    END IF;
    return l_base||l_result;

 EXCEPTION WHEN OTHERS THEN
    IF(fnd_log.level_error >= fnd_log.g_current_runtime_level)
    THEN
         fnd_log.string(fnd_log.level_error,   l_module_source,   sqlerrm);
    END IF;

     fnd_message.set_name('FND',   'get_DAS_BASE_URL');
     return null;
  END get_das_operationurl;


-------------------------------------------------------------------------------------------------
---
procedure add_attribute_M(x_ldap  in dbms_ldap.session, dn in varchar2, name in  varchar2, value in  varchar2 )
IS
modArray  dbms_ldap.mod_array;
vals dbms_ldap.string_collection;
ret pls_integer;
l_module_source   varchar2(256):= G_MODULE_SOURCE || 'add_attribute_M: ';

BEGIN
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'dn='||dn);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'attribute='||name||' value='||value);
  end if;

    modArray := dbms_ldap.create_mod_array(num => 1);
    vals(0) := value;
    dbms_ldap.populate_mod_array(modptr=>modArray,mod_op=>dbms_ldap.mod_add,mod_type=>name,modval=>vals);
    ret := dbms_ldap.modify_s(ld=>x_ldap,entrydn=>dn,modptr=>modArray);
    dbms_ldap.free_mod_array(modptr => modArray);
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END');
  end if;

    exception when others then
       if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
         fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, sqlerrm);
       end if;
       raise;

END add_attribute_M;


function c_get_oid_session(flag in out nocopy pls_integer) return dbms_ldap.session
is
l_module_source   varchar2(256):= G_MODULE_SOURCE || 'c_get_oid_session: ';
BEGIN
/*
 * flag=-99 just to print the stack on the log
 */
  IF (flag=-99) THEN
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'DUMP ldap status for FND_LDAP_UTIL='||g_common_counter);
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'g_common_counter='||g_common_counter);
          IF (G_TRACK_LDAP_STACK) THEN
	     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ldap_session_stack);
          END IF;
      end if;
     return null;
  END IF;



   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'initialy g_common_counter='||g_common_counter);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'initialy flag='||flag);
  end if;

  if (g_common_counter=0) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'creating a new connection');
	IF (G_TRACK_LDAP_STACK) THEN
	    ldap_session_stack := dbms_utility.FORMAT_CALL_STACK;
	END IF;
      end if;
       g_common_ldap := get_oid_session;
  end if;
  flag := g_common_counter;
  g_common_counter := g_common_counter + 1;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'finally g_common_counter='||g_common_counter);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'finally flag='||flag);
  end if;
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END');
  end if;
  return g_common_ldap;

    exception when others then
       if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
         fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, sqlerrm);
       end if;
       raise;
END c_get_oid_session;

procedure c_unbind(ldap in out nocopy dbms_ldap.session , flag in out nocopy pls_integer)
is
  l_module_source   varchar2(256):= G_MODULE_SOURCE || 'c_unbind: ';
  ret pls_integer;
begin
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, '  incomming  g_common_counter='||g_common_counter);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, '  incomming  flag='||flag);
  end if;

   if (flag=0)then
      ret := unbind(g_common_ldap);
      g_common_counter := 0;
   elsif (g_common_counter>1) then
       g_common_counter := g_common_counter - 1;
       -- we don't wont to reach 0, because we will lose control.
   else
       if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
         fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'g_common_counter reached invalid value='||g_common_counter);
       end if;

   end if;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, '  final  g_common_counter='||g_common_counter);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, '  final  flag='||flag);
  end if;
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END');
  end if;
    exception when others then
       if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
         fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, sqlerrm);
       end if;
       raise;
end c_unbind;


 function getLDAPAttribute(ldap in out nocopy dbms_ldap.session,dn in  varchar2, attrName in varchar2, filterExp in varchar2 default 'objectclass=*')
 return varchar2
 is
  result pls_integer;
  l_attrs dbms_ldap.string_collection;
  l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_result varchar2(4000);
l_module_source varchar2(1000) ;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'getAttribute: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

   l_attrs(0):= attrName;
    result := dbms_ldap.search_s(ld => ldap
                             , base => dn
			     , scope => dbms_ldap.SCOPE_BASE
			     , filter => filterExp
			     , attrs => l_attrs
			     , attronly => 0
                             , res => l_message);
      l_entry := dbms_ldap.first_entry(ldap, l_message);
      if (l_entry is null ) then return null; end if;
      l_attrs := dbms_ldap.get_values(ldap, l_entry, attrName);
      l_result := l_attrs(0);
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'ldapsearch -b "'||dn||'" -s base "'||filterExp||'" '||attrName);
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'result:'||l_result);
      end if;

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ');
      end if;
      return l_result;


      exception when NO_DATA_FOUND then
        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
         fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END -> NULL');
        end if;
          return null;
END getLDAPAttribute;


function loadLdapRecord( ldapSession in out nocopy dbms_ldap.session, rec in out nocopy ldap_record_values, dn out nocopy varchar2,
           key in varchar2, key_type in pls_integer default G_DN_KEY ) return boolean
is
result pls_integer;
attrs     DBMS_LDAP.string_collection;
l_message  DBMS_LDAP.message;
l_entry DBMS_LDAP.message;
atName varchar2(300);
l_ber_elmt  DBMS_LDAP.ber_element;
l_module_source varchar2(1000) ;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'loadLdapRecord: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  attrs(0):='*';
  attrs(1):='orclguid';

 if (key_type=G_GUID_KEY) THEN

         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
         then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, G_MODULE_SOURCE||'.loadLdapRecord:', ' key_type G_GUID_KEY');
         end if;

          result := dbms_ldap.search_s(ld => ldapSession,
          base => '',
          scope => dbms_ldap.SCOPE_SUBTREE,
          filter => 'orclguid='||key,
          attrs => attrs,
          attronly => 0,
          res => l_message);
 ELSE -- default action
      BEGIN
         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
         then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, G_MODULE_SOURCE||'.loadLdapRecord:', ' key_type not G_GUID_KEY');
         end if;

         result:= dbms_ldap.search_s(ld => ldapSession,
          base => key,
          scope => dbms_ldap.SCOPE_BASE,
          filter => 'objectclass=*',
          attrs => attrs,
          attronly => 0,
          res => l_message);
        EXCEPTION WHEN dbms_ldap.general_error THEN
            result := dbms_ldap.NO_SUCH_OBJECT;
      END;
 END IF;
 if (result=DBMS_LDAP.SUCCESS) THEN
  l_entry := DBMS_LDAP.first_entry(ldapSession, l_message );
  if  l_entry is not null then
     dn := DBMS_LDAP.get_dn(ldapSession,l_entry);

     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, G_MODULE_SOURCE||'.loadLdapRecord: ', dn);
     end if;

     atName := DBMS_LDAP.first_attribute(ldapSession,l_entry, l_ber_elmt);
      while (atName is not null) loop

        -- Bug 19904770
        -- Load the attribute name is lower case to be able to search afterwards
        -- The attribute names are returned the way there are defined in
        -- the ldap schema. To avoid case mismatche, load in the cache, in lower
        -- case.
        if (lower(atName) <> 'jpegphoto') then
          -- Bug 16631656 - only retrieve the value if not jpegphoto
          rec(lower(atName)):=  DBMS_LDAP.get_values (ldapSession, l_entry,atName);
        end if;

          atName := DBMS_LDAP.next_attribute(ldapSession,l_entry,l_ber_elmt);

      end loop;
     end if;
  return true;
  ELSE
    dn:=null;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, G_MODULE_SOURCE||'.loadLdapRecord: ', 'null');
    end if;

    return false;
  END IF;



END loadLdapRecord;

function loadLdapRecord( ldapSession in out nocopy dbms_ldap.session, rec in out nocopy ldap_record_type,
           key in varchar2, key_type in pls_integer default G_DN_KEY ) return boolean

IS
 ret boolean;
 dn varchar2(4000);

BEGIN
  ret:= loadLdapRecord(ldapSession,rec.data,dn,key,key_type);
  if (ret) THEN
        rec.dn := dn;
  END IF;
  return ret;
END loadLdapRecord;

---------------------------------------------------------------
-- The provisioning container DN
-- Bug 19904770 : Support OUD
---------------------------------------------------------------
function get_provprofilecontainer return varchar2 is

l_module_source   varchar2(256);
l_ldapdirprov varchar(256);

begin

  l_module_source := G_MODULE_SOURCE || '.get_provprofilecontainer: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

   l_ldapdirprov := fnd_oid_plug.getLdapDirProv;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Provisioning container ' || l_ldapdirprov);
  end if;


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return l_ldapdirprov;

exception
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;

end get_provprofilecontainer;

--
-------------------------------------------------------------------------------
/*
** Name      : is_oudldaptype
** Type      : Public, FND Internal
** Desc      : This function returns G_TRUE if the ldap server is OUD
**           : G_FALSE otherwise
**           : Bug 19904770 : Support OUD please see also 20364313
** Pre-Reqs   :
** Parameters  :
** Notes      :
*/
function is_oudldaptype return pls_integer IS
l_module_source   varchar2(256);
l_ldapdirtype varchar2(256);
l_result pls_integer;
l_isoudldapdirtype pls_integer;

begin

  l_module_source := G_MODULE_SOURCE || '.is_oudldaptype: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  l_ldapdirtype := fnd_oid_plug.getLdapDirType;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP Directory Type ' || l_ldapdirtype);
  end if;

  if (l_ldapdirtype = 'OUD') then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Setting l_isoudldapdirtype to true');
     end if;
     l_isoudldapdirtype := G_TRUE;
  else
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Setting l_isoudldapdirtype to false');
     end if;
     l_isoudldapdirtype := G_FALSE;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return l_isoudldapdirtype;

exception
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;

end is_oudldaptype;

----------------------------------------------------------------------------------
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
function isLDAPAccessible return boolean
is
retval boolean;
l_module_source varchar2(256);
l_ldap dbms_ldap.session;
dummy pls_integer;
l_realm varchar2(4000);

begin
  retval := false;

  l_module_source := G_MODULE_SOURCE||'isLDAPAccesible';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

   -- Call fnd_oid_utl.get_oid_session.  This will verify the preferences
   -- and verify that a LDAP connection is successful

   l_ldap := c_get_oid_session(dummy);

   if (l_ldap is not null) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP Session can be created - LDAP is integrated');
      end if;
      l_realm := fnd_oid_plug.get_default_realm;
      c_unbind(l_ldap,dummy);
      retval := true;
   end if;

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

   return retval;

  exception when others then
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Exception occurred - either LDAP is not integrated or is not accessible');
  end if;
  return retval;
end isLDAPAccessible;



----------------------------------------------------------------------------------
/*
** Name      : isLDAPIntegrationEnabled
** Type      : Public, FND Internal
** Desc      : This function returns G_TRUE if an LDAP server is integrated with this EBS instance
**           : G_FALSE otherwise
** Pre-Reqs  :
** Parameters:  None
** Notes     :  This is used to determine whether the LDAP integration is enabled.
*/
function isLDAPIntegrationEnabled return boolean
is
l_ldap_integration varchar2(30);
l_apps_sso varchar2(80);
l_profile_defined boolean;
l_orclappname varchar2(256);
l_module_source varchar2(256);
begin

  l_module_source := G_MODULE_SOURCE || 'isLDAPIntEnabled';

  l_ldap_integration := G_DISABLED;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

         l_ldap_integration := fnd_vault.get('FND','APPS_SSO_LDAP_INTEGRATION');

         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP Integration value is: '||l_ldap_integration);
   end if;


    if (l_ldap_integration = G_ENABLED) then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP Integration is enabled');
       end if;
       return true;
    elsif (l_ldap_integration = G_DISABLED) then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP Integration is disabled regardless');
       end if;
       return false;
    else
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP Integration not set - determine and set');
       end if;

       fnd_profile.get_specific(name_z => 'APPS_SSO',
                                val_z => l_apps_sso,
                                defined_z       => l_profile_defined);

       if (l_apps_sso in ('APPS_SSO', 'SSO_SDK') and isLDAPIntegrated) then
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP Integration not set but instance is integrated so set pref');
          end if;

          fnd_sso_util.enableLDAPIntegration;
          return true;
       else
          fnd_sso_util.disableLDAPIntegration;

         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'APPS_SSO is not SSO or LDAP is not Accessible ');
         end if;

         return false;
       end if;
    end if;

end isLDAPIntegrationEnabled;


----------------------------------------------------------------------------------
/*
** Name      : isLDAPIntegrated
** Type      : Public, FND Internal
** Desc      : This function returns G_TRUE if an LDAP server is integrated with this EBS instance
**           : G_FALSE otherwise
** Pre-Reqs  :
** Parameters:  None
** Notes     :  This is used to determine whether the LDAP server is integrated
**
*/
function isLDAPIntegrated return boolean
is
l_module_source varchar2(256);
l_host varchar2(256);
l_port varchar2(256);

begin

  l_module_source := G_MODULE_SOURCE||'isLDAPIntegrated';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

   -- Will change to using vault for registration
   l_host := fnd_preference.get(FND_LDAP_UTIL.G_INTERNAL, FND_LDAP_UTIL.G_LDAP_SYNCH, FND_LDAP_UTIL.G_HOST);
   l_port := fnd_preference.get(FND_LDAP_UTIL.G_INTERNAL, FND_LDAP_UTIL.G_LDAP_SYNCH, FND_LDAP_UTIL.G_PORT);


   if (l_host is null or l_port is null) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP is not integrated');
      end if;
      return false;
   end if;

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
   end if;

   return true;


  exception when others then
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Exception occurred - either LDAP is not integrated or is not accessible');
  end if;
  return false;
end isLDAPIntegrated;


end fnd_ldap_util;


/
