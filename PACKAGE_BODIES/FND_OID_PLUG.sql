--------------------------------------------------------
--  DDL for Package Body FND_OID_PLUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OID_PLUG" AS
/* $Header: AFSCOPGB.pls 120.1.12010000.20 2015/11/16 16:43:04 ctilley ship $ */


g_realm varchar2(4000);
g_user_search varchar2(4000);
G_NICKNAMEATT varchar2(4000);

g_user_repo varchar2(4000);
g_cnatt varchar2(4000);

G_STATIC_DESC  varchar2(100):='STATIC';
/*

PREFERENCES
==============



REALM:
NICKNAMEATTR:
COMMONNAMEATTR:
SEARCH_BASE:
CREATE_BASE:

PLUGIN_NAME: if null, all above are filled with defaults.
    if not null all are null and the plugin must implement
            getRealm(Username)
            getDN(username)
            getUserRepository(username)
            getRDN(username)



*/
/*
* Constants
*/
G_MODULE_SOURCE varchar2(100):= 'fnd.plsql.oid.fnd_oid_plug.';
G_PREF_USER varchar2(20):='#INTERNAL';
G_PREF_MODULE varchar2(20):='OID_CONF';

/**
* OPTION opt_mode
* ============
*            If the option has the opt_mode 'STATIC' the value in the preference is the one to use.
*    If it is 'DYNAMIC' then the value is a PL/SQL statement to execute.
*    If it is 'RUNTIME' then the preference value is not relevant, and the actual must be recalculated
*    For example 'RUNTIME','NICKNAME_ATTR' means there will be a QUERY to ldap to calculate the value,
*  and the result will be cached in the package.
*     'NOCACHE' is the same as 'RUNTIME' but the value is calculated every time. Not implemented
* for now, since values are oftenly catched in other places too, so it may inefective unless a detailed
* analysis is done for the value,i.e., remove from ALL the code any place where nicknameAttName is cached
*
**/

G_STATIC pls_integer := 0;
G_DYNAMIC pls_integer := 1;
G_RUNTIME pls_integer := 2;


type  option_type_rec is record  (
   opt_mode pls_integer,
   val varchar2(4000)
);

type option_type is table of option_type_rec index by varchar2(30);

g_option option_type;

/*
* GLOBALS
*/
plugin_type  pls_integer := null;
invalid_deployment exception;
single_init boolean := false;
g_cached_realm varchar2(4000);

validated boolean:= false; -- plugin version




FUNCTION loadOption( name in varchar2, opt in out nocopy option_type_rec) return boolean
IS

val varchar2(40);
found boolean := TRUE;
l_module_source varchar2(200) := G_MODULE_SOURCE || 'loadOption: ';

BEGIN
      val := fnd_preference.get(G_PREF_USER,G_PREF_MODULE,name||'_opt_mode');
      IF val is null then found := FALSE;
      ELSIF (val='STATIC') THEN opt.opt_mode:=0;
      ELSIF (val='DYNAMIC') THEN opt.opt_mode:=1;
      ELSIF (val='RUNTIME') THEN opt.opt_mode:=1;
      ELSE raise invalid_deployment;
      END IF;
      IF found THEN
         opt.val := fnd_preference.get(G_PREF_USER,G_PREF_MODULE,name);
         found := opt.val is not null;
         if (found) THEN
             g_option(name):= opt;
         END IF;
      END IF;
      return found;
    EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

END loadOption;

PROCEDURE saveOption( name in varchar2, opt_mode in pls_INTEGER , value in varchar2)
is
l_module_source varchar2(200) := G_MODULE_SOURCE || 'saveOption: ';
BEGIN
  if (opt_mode=0) THEN
   fnd_preference.put(G_PREF_USER,G_PREF_MODULE,name||'_opt_mode','STATIC');
  elsif (opt_mode=1) THEN
   fnd_preference.put(G_PREF_USER,G_PREF_MODULE,name||'_opt_mode','DYNAMIC');
  elsif (opt_mode=2) THEN
   fnd_preference.put(G_PREF_USER,G_PREF_MODULE,name||'_opt_mode','RUNTIME');
  else
    raise invalid_deployment;
  END IF;
  fnd_preference.put(G_PREF_USER,G_PREF_MODULE,name,value);

  if (g_option.exists(name)) then
            g_option.delete(name); --cancel the cache
  end if;
      EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

END saveOption;


PROCEDURE deleteOption( name in varchar2)
is
l_module_source varchar2(200) := G_MODULE_SOURCE || 'saveOption: ';
BEGIN
   fnd_preference.remove(G_PREF_USER,G_PREF_MODULE,name);
   fnd_preference.remove(G_PREF_USER,G_PREF_MODULE,name||'_opt_mode');
   if (g_option.exists(name)) then
            g_option.delete(name); --cancel the cache
  end if;

END deleteOption;
FUNCTION getOption(name in varchar, opt in out nocopy option_type_rec) return boolean
IS
l_module_source varchar2(200):= G_MODULE_SOURCE || 'getOption: ';
BEGIN
   IF (g_option.exists(name)) then
       opt.opt_mode := g_option(name).opt_mode;
       opt.val := g_option(name).val;
       return true;
   else return loadOption(name,opt);
   END IF;
  EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

END getOption;

/*
* FOWARD declarations
*/
function get_username_from_guid(p_user_guid IN fnd_user.user_guid%type ) return varchar2;





procedure getDefaultRealm(realm out nocopy varchar2)  IS
opt option_type_rec;
b boolean;
BEGIN

   if NOT getOption('DEFAULT_REALM',opt) THEN
          raise CONFIGURATION_ERROR;
   END IF;
   IF opt.opt_mode=G_STATIC THEN
       realm := opt.val;
   ELSIF opt.opt_mode=G_RUNTIME THEN
       realm := FND_SSO_REGISTRATION.getDefaultRealm;
   ELSIF opt.opt_mode=G_DYNAMIC THEN
      execute immediate opt.val using realm;
   END IF;

END getDefaultRealm;

procedure getDefaultCreateBase(realm in varchar2, parentDN out nocopy varchar2 )  IS
opt option_type_rec;

BEGIN
    if NOT getOption('DEFAULT_CREATE_BASE',opt) THEN
       raise configuration_error;
   END IF;
   IF opt.opt_mode=G_STATIC THEN
       parentDN := opt.val;
   ELSIF opt.opt_mode=G_RUNTIME THEN
       parentDN := FND_SSO_REGISTRATION.get_realm_attribute(realm,'orclCommonCreateUserBase');
   ELSIF opt.opt_mode=G_DYNAMIC THEN
      execute immediate opt.val using realm,parentDN;
   END IF;
END getDefaultCreateBase;

procedure getCreateBase( user_id in INTEGER, user_name in varchar2,realm in varchar2, parentDn out nocopy varchar2)  IS
opt option_type_rec;
BEGIN
    if NOT getOption('CREATE_BASE',opt) THEN
          raise CONFIGURATION_ERROR;
   END IF;
   IF opt.opt_mode=G_STATIC THEN
       parentDN := opt.val;
   ELSIF opt.opt_mode=G_RUNTIME THEN
       getDefaultCreateBase(realm,parentDN);
   ELSIF opt.opt_mode=G_DYNAMIC THEN
      execute immediate opt.val using user_id,user_name,realm,parentDN;
   END IF;

END getCreateBase;

procedure getRealm( user_id in INTEGER, user_name in varchar2, realmDn out nocopy varchar2)  IS
opt option_type_rec;
BEGIN
    if NOT getOption('REALM',opt) THEN
          raise CONFIGURATION_ERROR;
   END IF;
   IF opt.opt_mode=G_STATIC THEN
       realmDn := opt.val;
   ELSIF opt.opt_mode=G_RUNTIME THEN
       getDefaultRealm(realmDn);
   ELSIF opt.opt_mode=G_DYNAMIC THEN
      execute immediate opt.val using user_id,user_name,realmDn;
   END IF;
END getRealm;

/*
** Name      : getLdapDirType
** Desc      : FND_SSO_REGISTRATION.getLdapDirType returns OUD if the ldap server is OUD
**           : 'OID' otherwise.  Sets the preference value - LDAPDIRTYPE
**           : Bug 19904770 : Support OUD please see also 20364313
** Pre-Reqs   :
** Parameters  :
** Notes      :
*/
function getLdapDirType return varchar2 IS
opt option_type_rec;
b boolean;
l_module_source VARCHAR2(1000);
BEGIN
  l_module_source               := G_MODULE_SOURCE || 'getLdapDirType: ';

  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  END IF;

  IF (NOT getOption('LDAP_DIR_TYPE',opt) )THEN

    IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Not found - getLdapDirType');
    END IF;

    opt.opt_mode := G_STATIC;
    opt.val := FND_SSO_REGISTRATION.getLdapDirType;
    if (opt.val is not null) then
       saveOption('LDAP_DIR_TYPE',opt.opt_mode,opt.val);
    end if;
  END IF;

   IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End - return '||opt.val);
   END IF;

   return opt.val;


END getldapdirtype;

/*
** Name      : getLdapDirProv
** Desc      : FND_SSO_REGISTRATION.getLdapDirProv returns the provisioning container DN
**             specific for the directory type.
**             Sets the preference value - LDAPDIRPROV if not set
**           : Bug 19904770 : Support OUD please see also 20364313
** Pre-Reqs   :
** Parameters  :
** Notes      :
*/
function getLdapDirProv return varchar2 IS
opt option_type_rec;
b boolean;
l_module_source VARCHAR2(1000);
BEGIN
  l_module_source               := G_MODULE_SOURCE || 'getLdapDirProv: ';

  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  END IF;
  IF (NOT getOption('LDAP_DIR_PROV',opt) )THEN

     IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Not found - getLdapDirProv');
    END IF;

    opt.opt_mode := G_STATIC;
    opt.val := FND_SSO_REGISTRATION.getLdapDirProv;
    if (opt.val is not null) then
       saveOption('LDAP_DIR_PROV',opt.opt_mode,opt.val);
    end if;
  END IF;

   IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End - return '||opt.val);
   END IF;

   return opt.val;

END getLdapDirProv;

/**
* PRIVATE FUNCTIONS
*/

/*
* Validate Template
*     Given a plug in , we need to validate if
*             1) declares the function
*             2) has the same paratermer
* We validate EXACT MATCH: that is parameters must have the same NAME and TYPE.
* RETURN: TRUE if all test passed
*         FALSE : if sometyhign different was detected
*  OUT: error_msg: whe return false, a message indicating the problem
*
*/
  function validateTemplate (template in varchar2 , name VARCHAR2, error_msg out nocopy varchar2) return boolean is

      prop_overload     DBMS_DESCRIBE.NUMBER_TABLE;
      prop_position     DBMS_DESCRIBE.NUMBER_TABLE;
      prop_c_level      DBMS_DESCRIBE.NUMBER_TABLE;
      prop_arg_name     DBMS_DESCRIBE.VARCHAR2_TABLE;
      prop_dty          DBMS_DESCRIBE.NUMBER_TABLE;
      prop_def_val      DBMS_DESCRIBE.NUMBER_TABLE;
      prop_p_opt_mode       DBMS_DESCRIBE.NUMBER_TABLE;
      prop_length       DBMS_DESCRIBE.NUMBER_TABLE;
      prop_precision    DBMS_DESCRIBE.NUMBER_TABLE;
      prop_scale        DBMS_DESCRIBE.NUMBER_TABLE;
      prop_radix        DBMS_DESCRIBE.NUMBER_TABLE;
      prop_spare        DBMS_DESCRIBE.NUMBER_TABLE;

      exp_overload     DBMS_DESCRIBE.NUMBER_TABLE;
      exp_position     DBMS_DESCRIBE.NUMBER_TABLE;
      exp_c_level      DBMS_DESCRIBE.NUMBER_TABLE;
      exp_arg_name     DBMS_DESCRIBE.VARCHAR2_TABLE;
      exp_dty          DBMS_DESCRIBE.NUMBER_TABLE;
      exp_def_val      DBMS_DESCRIBE.NUMBER_TABLE;
      exp_p_opt_mode       DBMS_DESCRIBE.NUMBER_TABLE;
      exp_length       DBMS_DESCRIBE.NUMBER_TABLE;
      exp_precision    DBMS_DESCRIBE.NUMBER_TABLE;
      exp_scale        DBMS_DESCRIBE.NUMBER_TABLE;
      exp_radix        DBMS_DESCRIBE.NUMBER_TABLE;
      exp_spare        DBMS_DESCRIBE.NUMBER_TABLE;
      datatypes dbms_ldap.string_collection;
      idx          INTEGER := 0;

  BEGIN
      DBMS_DESCRIBE.DESCRIBE_PROCEDURE(name, null, null,prop_overload,prop_position,prop_c_level,prop_arg_name,
              prop_dty,prop_def_val,prop_p_opt_mode,prop_length,prop_precision,prop_scale,prop_radix,prop_spare);

      DBMS_DESCRIBE.DESCRIBE_PROCEDURE(template, null, null,
              exp_overload,exp_position, exp_c_level,exp_arg_name,exp_dty,
              exp_def_val,exp_p_opt_mode, exp_length,exp_precision, exp_scale,exp_radix,exp_spare);

      error_msg :=null;
      while idx is not null LOOP
         BEGIN
          idx := idx + 1;
          if (prop_arg_name(idx)<>exp_arg_name(idx) ) THEN
              error_msg :='Parameter '||idx||':Expected name '||exp_arg_name(idx)||' but found '||prop_arg_name(idx);
          ELSIF (prop_dty(idx)<>exp_dty(idx)) THEN
              error_msg :='Parameter '||idx||': incorrect datatype for  '||exp_arg_name(idx);
          ELSIF (prop_dty(idx)<>exp_dty(idx)) THEN
              error_msg :='Parameter '||idx||': incorrect in/out opt_mode for  '||exp_arg_name(idx);
          END IF;
          if (error_msg is not null) then
             return false;
          END IF;
          EXCEPTION WHEN NO_DATA_FOUND THEN idx:= null;
          END;
      END LOOP;
      return true;
  EXCEPTION
     WHEN OTHERS THEN
        error_msg := 'Error:'||sqlcode||' - '||sqlerrm;
        return false;


  END validateTemplate;




function getRealmNickNameattr(realm in varchar2) return varchar2
is
--ldap dbms_ldap.session;
ret varchar2(80):= null;
realm_idx pls_integer;
--flag pls_integer;
l_module_source varchar2(1000) ;
BEGIN
      l_module_source := G_MODULE_SOURCE || 'getRealmNickNameattr: ';

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin realm='||realm);
      end if;

      ret:= FND_SSO_REGISTRATION.get_realm_attribute(realm,'orclCommonNickNameAttribute');

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END nicknameAttr='||ret);
      end if;
    return ret;
    EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

end getRealmNickNameattr;



function PluginVersion return NUMBER

is
l_version varchar2(4000);
l_plug_ver number;
l_module_source varchar2(1000);
BEGIN
     l_module_source := G_MODULE_SOURCE || 'PluginVersion';

     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
     end if;

     l_version := FND_PREFERENCE.get('#INTERNAL','OID_CONF','PLUGIN_VERSION');

     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Retrieved PLUGIN_VERSION preference');
     end if;

     if (l_version is not null) THEN

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
          fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'plugin version is: '||l_version);
        end if;

       -- Converting to force NLS numeric format regardless of user preference.
       -- Reference bug 9358444
          l_plug_ver := to_number(l_version,'9D9','NLS_NUMERIC_CHARACTERS=''.,''');

         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
         then
            fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'Converted value: '||to_char(l_plug_ver));
         end if;

          return l_plug_ver;

     ELSIF FND_PREFERENCE.exists('#INTERNAL','OID_CONF','CREATE_BASE') THEN

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
           fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'CREATE_BASE exists - PLUGIN_VERSION did not - return 1.0');
        end if;

            return 1.0;
     ELSE

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
           fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'Neither preference exists - return 0.9');
        end if;

            return 0.9;
     END IF;

    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
     end if;

END PluginVersion;
/*
* The syntax changed from previous versions.
* And needs to be represented in the new syntax.
* However, the only supported deployments where
*     setPlugin()
*     setPlugin(defaultCreateBase);
* we only concern about them
* So, with the exception of the defaultCreateBase, everything comes from the defaultRealm
* Upgrades to version 1.1
*
*/
procedure UpgradePlugin
IS
type params_t  is table of varchar2(4000) index by varchar2(200);
type list_t is table of varchar2(200) ;

old_val params_t;
params list_t;
version number;
l_module_source varchar2(200) := G_MODULE_SOURCE || 'UpgradePlugin: ';


BEGIN

     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
         fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'BEGIN' );
     end if;
     version := PluginVersion;
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'current version:'||version );
     end if;

     if (version > 1.0 ) THEN
          -- no changes needed this time
	     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
	     then
		 fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END(no changes)' );
	     end if;
          return ;
     END IF;
     if (version=1.0) THEN
	     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
	     then
		 fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'upgrading from 1.0');
	     end if;
        params := list_t('CN_ATT_CACHED','CREATE_BASE','NICK_ATT_CACHED','REALM','SEARCH_BASE_CACHED','TYPE');
            for p in params.first .. params.last loop
                 old_val(params(p)) := FND_PREFERENCE.GET('#INTERNAL','OID_CONF',params(p));
	     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
	     then
		 fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'old '||params(p)||'='||old_val(params(p)) );
	     end if;
        end loop;

     ELSE
	     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
	     then
		 fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'very old or non existent registration');
	     end if;
       old_val('REALM') := fnd_sso_registration.getdefaultrealm;
       old_val('CREATE_BASE') := FND_SSO_REGISTRATION.get_realm_attribute(old_val('REALM') ,'orclCommonUserCreatebase');
       old_val('CN_ATT_CACHED') := FND_SSO_REGISTRATION.get_realm_attribute(old_val('REALM') ,'orclCommonNamingAttribute');
       -- remove null values from the list
       if old_val('REALM') is null then old_val.delete('REALM'); end if;
       if old_val('CREATE_BASE') is null then old_val.delete('CREATE_BASE'); end if;
       if old_val('CN_ATT_CACHED') is null then old_val.delete('CN_ATT_CACHED'); end if;

     END IF;


     -- remove all
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'removing previous preferences');
     end if;
     FND_PREFERENCE.DELETE_ALL('#INTERNAL','OID_CONF');

     if NOT old_val.exists('REALM') THEN
         old_val('REALM') := fnd_sso_registration.getdefaultrealm;
     END IF;
     if NOT old_val.exists('CREATE_BASE') THEN
        old_val('CREATE_BASE') := FND_SSO_REGISTRATION.get_realm_attribute(old_val('REALM') ,'orclCommonUserCreatebase');
     END IF;

     if NOT old_val.exists('CN_ATT_CACHED') THEN
        old_val('CN_ATT_CACHED') := FND_SSO_REGISTRATION.get_realm_attribute(old_val('REALM') ,'orclCommonNamingAttribute');
     END IF;

     saveOption('DEFAULT_REALM',G_STATIC,old_val('REALM'));
     saveOption('REALM',G_STATIC,old_val('REALM'));
     saveOption('DEFAULT_CREATE_BASE',G_STATIC,old_val('CREATE_BASE'));
     saveOption('CREATE_BASE',G_STATIC,old_val('CREATE_BASE'));
     saveOption('RDN',G_STATIC,old_val('CN_ATT_CACHED') );
     saveOption('LDAP_DIR_TYPE',G_STATIC,FND_SSO_REGISTRATION.getLDAPDirType);
     saveOption('LDAP_DIR_PROV',G_STATIC,FND_SSO_REGISTRATION.getLDAPDirProv);

     FND_PREFERENCE.put('#INTERNAL','OID_CONF','PLUGIN_VERSION','1.1');
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
          params := list_t('DEFAULT_REALM','REALM','DEFAULT_CREATE_BASE','CREATE_BASE','RDN','PLUGIN_VERSION','LDAP_DIR_TYPE','LDAP_DIR_PROV');
          for p in params.first .. params.last loop
		 fnd_log.string(fnd_log.LEVEL_STATEMENT,  l_module_source,' pref set :  '||params(p)||'='||FND_PREFERENCE.GET('#INTERNAL','OID_CONF',params(p)));
          end loop;
     end if;
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
         fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'BEGIN' );
     end if;
    EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

END UpgradePlugin;

procedure    validateVersion
IS
BEGIN
  IF (NOT validated) THEN
     if PluginVersion<1.1 THEN
         UpgradePlugin;
     END IF;
     validated:=true;
  END IF;
END    validateVersion;




--
procedure SetPlugIn (
p_defaultRealm in varchar2 default null,
p_default_user_repository in varchar2 default null,
plugin_name in varchar2 default null
)
is
l_module_source VARCHAR2(1000)  := G_MODULE_SOURCE || 'SetPlugin(package): ';
i pls_integer;
c pls_integer;
o dba_objects.owner%type;
n dba_objects.object_name%type;
errmsg varchar2(4000);
opt option_type_rec;
val varchar2(4000);
realm varchar2(4000);
usePlugin boolean := false;
idx pls_integer;
ldap dbms_ldap.session;
flag pls_integer ;
guid varchar2(4000);
testing_mode pls_integer := 1;
l_session_flag boolean := false;

BEGIN
   -- if there is no session , create one , so we cann LOG acctions
   -- VALIDATE THERE IS A PACKAGE
   UpgradePlugin;
   ldap:= FND_LDAP_UTIl.c_get_oid_session(flag);
   l_session_flag := true; /* fix for bug 8271359 */

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag = true ' );
   end if;

   if (plugin_name is not null ) THEN
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'plugin_name is: '||plugin_name);
      end if;
     n:= upper(plugin_name);
     i:= instr(plugin_name,'.');
     IF (i=0) THEN
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Verify plugin package is valid ' );
        end if;

         select count(*) into c  from user_objects where object_name=n
         and object_type in ('PACKAGE','PACKAGE BODY') and status='VALID';
         IF (c<>2) THEN
            raise_application_error(-20100,'Check existence and validity of '||plugin_name||' body and specs');
         END IF;
     ELSE
         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Verify plugin package for owner is valid ' );
         end if;
            o:= substr(upper(plugin_name),0,i-1);
            n:= substr(upper(plugin_name),i+1);
            select count(*) into c  from dba_objects where
            owner=o and
            object_name=n and
            object_type in ('PACKAGE','PACKAGE BODY') and status='VALID';

             IF (c<>2) THEN
                 raise_application_error(-20100,'Check existence and validity of '||plugin_name||' body and specs');
             END IF;
     END IF;
     usePlugin:=true;
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'usePlugin set to true');
      end if;
   ELSE
      usePlugin :=false;
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'usePlugin set to false');
      end if;
   END IF;

   -- DEPLOY WHAT PACKAGE PROVIDES
if (testing_mode=1) THEN
   if usePlugin AND ValidateTemplate('FND_OID_PLUG.getDefaultRealm_Template',plugin_name||'.getDefaultRealm',errmsg) THEN
       saveOption('DEFAULT_REALM',G_DYNAMIC,'BEGIN '||plugin_name||'.getDefaultRealm(:1); END;');
   ELSE
      if (p_defaultRealm is not null) THEN
        if (p_defaultRealm<>FND_SSO_REGISTRATION.getdefaultrealm) THEN
             raise_application_error(-20100,'Only default realm can be used');
          END IF;
       END IF;

       if (p_defaultRealm is not null and getOption('DEFAULT_REALM',opt) and opt.opt_mode=G_STATIC and opt.val=p_defaultRealm) THEN
            -- NO CHANGES
            val := null;
       ELSE
           val := p_defaultRealm;
           if (val is null) THEN
              val := FND_SSO_REGISTRATION.getdefaultrealm;
           END IF;
           if ( getOption('DEFAULT_REALM',opt) and opt.opt_mode=G_STATIC and opt.val=val) THEN
               -- no changes
               val:= null;
           ELSE
                saveOption('DEFAULT_REALM',G_STATIC,val);
                -- delete all realm related  options
                deleteOption('REALM');
                deleteOption('DEFAULT_CREATE_BASE');
                deleteOption('CREATE_BASE');
            END IF;
      END IF;
   END IF;
ELSIF testing_mode=1 THEN

    saveOption('DEFAULT_REALM',G_STATIC,FND_SSO_REGISTRATION.getdefaultrealm);

END IF;

if (testing_mode=1) THEN
   if usePlugin AND ValidateTemplate('FND_OID_PLUG.getRealm_Template',plugin_name||'.getRealm',errmsg) THEN
        saveOption('REALM',G_DYNAMIC,'BEGIN '||plugin_name||'.getRealm(:1,:2); END;');
   ELSE

        if getOption('DEFAULT_REALM',opt) THEN
            saveOption('REALM',opt.opt_mode,opt.val);
        ELSE
               val := p_defaultRealm;
               if (val is null) THEN
                   val := FND_SSO_REGISTRATION.getdefaultrealm;
               END IF;
               saveOption('REALM',G_STATIC,val);
        END IF;
   END IF;
ELSIF (testing_mode=0) THEN
            saveOption('REALM',G_STATIC,FND_SSO_REGISTRATION.getdefaultrealm);

END IF;

if (testing_mode=1) THEN
   if usePlugin AND ValidateTemplate('FND_OID_PLUG.getDefaultCreateBase_Template',plugin_name||'.getDefaultCreateBase',errmsg) THEN
       saveOption('DEFAULT_CREATE_BASE',G_DYNAMIC,'BEGIN '||plugin_name||'.getDefaultCreateBase(:1,:2); END;');
   ELSE
     val := null;

      if (p_default_user_repository is not null) THEN

          -- validation
     BEGIN
         guid := FND_LDAP_UTIL.get_guid_for_dn(ldap,p_default_user_repository);
         EXCEPTION WHEN OTHERS THEN
                      guid:=NULL;
                      raise_application_error(-20100,'Given createBaseDn does not exists :'||p_default_user_repository );

      END;
          idx := FND_SSO_REGISTRATION.getuserrealmindex(p_default_user_repository);
          if (idx is not null and idx>=0 ) THEN
                  saveOption('DEFAULT_CREATE_BASE',G_STATIC,p_default_user_repository);
          ELSE
             raise_application_error(-20100,'Given createBaseDn is not part of any realm :'||p_default_user_repository );
          END IF;

      ELSE
          if getOption('REALM',opt) THEN
              if opt.opt_mode=G_DYNAMIC or opt.opt_mode=G_RUNTIME THEN
                  val := '1';
                  saveOption('DEFAULT_CREATE_BASE',G_RUNTIME,'VOID' );
              END IF;

          END IF;
          if (val is null ) THEN
                 getDefaultRealm(realm);
                 BEGIN
                      getDefaultCreateBase(realm,val);
                      EXCEPTION WHEN OTHERS THEN
                         val:= FND_SSO_REGISTRATION.get_realm_attribute(realm,'orclCommonUserCreateBase');
                  END;
                 if (val is null ) THEN
                    val := 'cn=Users,'||realm;
                 END IF;
                 BEGIN
                     guid := FND_LDAP_UTIL.get_guid_for_dn(ldap,val);
                     EXCEPTION WHEN OTHERS THEN
                       raise_application_error(-20100,'Default create user base does not exists:'||val);
                 END;

                 saveOption('DEFAULT_CREATE_BASE',G_STATIC,val);
          END IF;
      END IF;
   END IF;

ELSIF testing_mode=0 THEN
     saveOption('DEFAULT_CREATE_BASE',G_STATIC,
                 FND_SSO_REGISTRATION.get_realm_attribute(FND_SSO_REGISTRATION.getdefaultrealm,'orclCommonUserCreateBase'));

END IF;

if testing_mode=1 THEN
   if usePlugin AND ValidateTemplate('FND_OID_PLUG.getCreateBase_Template',plugin_name||'.getCreateBase',errmsg) THEN
       saveOption('CREATE_BASE',G_DYNAMIC,'BEGIN '||plugin_name||'.getCreateBase(:1,:2,:3,:4); END;' );

   ELSE
    val := null;
    if getOption('DEFAULT_CREATE_BASE',opt) THEN
         if opt.opt_mode=G_DYNAMIC or opt.opt_mode=G_RUNTIME THEN
              val := '1';
              saveOption('CREATE_BASE',G_DYNAMIC,'BEGIN FND_OID_PLUG.getCreateBase(:1,:2,:3,:4); END;' );
          END IF;
    END IF;
    if (val is null) THEN
        FND_OID_PLUG.getDefaultRealm(realm);
        FND_OID_PLUG.getDefaultCreateBase(realm,val);
        saveOption('CREATE_BASE',G_STATIC,val);
    END IF;
   END IF;
ELSIF testing_mode=0 THEN
     saveOption('CREATE_BASE',G_STATIC,
                 FND_SSO_REGISTRATION.get_realm_attribute(FND_SSO_REGISTRATION.getdefaultrealm,'orclCommonUserCreateBase'));

END IF;


   if usePlugin AND ValidateTemplate('FND_OID_PLUG.getRDN_Template',plugin_name||'.getRDN',errmsg) THEN
       saveOption('RDN',G_DYNAMIC,'BEGIN '||plugin_name||'.getRDN(:1,:2,:3,:4,:5); END;');

   ELSE
      val:= null;
      if getOption('REALM',opt) THEN
         if opt.opt_mode=G_DYNAMIC or opt.opt_mode=G_RUNTIME THEN
                saveOption('RDN',G_RUNTIME,'VOID');
                val:='VOID';
         END IF;
      END IF;
      if val is null THEN
          FND_OID_PLUG.getDefaultRealm(realm);
          val:= FND_SSO_REGISTRATION.get_Realm_Attribute(realm ,'orclCommonNamingAttribute');
          saveOption('RDN',G_STATIC,val);
      END IF;
   END IF;
   -- FixupLDAPUser
    if usePlugin AND ValidateTemplate('FND_OID_PLUG.FixupLDAPUser_Template',plugin_name||'.FixupLDAPUser',errmsg) THEN
       saveOption('FIXUP',G_DYNAMIC,'BEGIN '||plugin_name||'.FixupLDAPUser(:1,:2,:3); END;');

   ELSE
      saveOption('FIXUP',G_STATIC,'NONE');
   END IF;
   FND_LDAP_UTIl.c_unbind(ldap,flag);
   l_session_flag := false;
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag : = false ' );
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION CLOSED NORMALLY : ' );
   end if;

EXCEPTION  WHEN OTHERS THEN
         if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
         then
            fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
         end if;
         /* Fix for 8271359*/
         if l_session_flag = true then
            if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
            then
               fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in EXCEPTION BLOCK - START ' );
            end if;
           fnd_ldap_util.c_unbind(ldap,flag);

           if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
           then
               fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in EXCEPTION BLOCK - END ');
           end if;
         end if;

         raise;

   -- COMPLETE DEFAULTS
   -- CLEANUP

END SetPlugIn;

procedure setPlugin_old(
         default_realm in varchar2 default null,
         default_user_repository in varchar2 default null,
         plugin_name in varchar2 default null) AS
  ldap dbms_ldap.session;
  res pls_integer;
  flag pls_integer;
  l_module_source varchar2(1000) ;
  isDynamic boolean:= false;
  errmsg varchar2(4000);
  l_session_flag boolean := false;
BEGIN
      l_module_source := G_MODULE_SOURCE || 'setPlugin: ';

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin' );
      end if;
      /*
   if (plugin_name is not null) then
    -- if ( validateTemplate('FND_OID_PLUG.getRDN',plugin_name||'.getRDN',msg) )THEN
     --       fnd_preference.put(G_PREF_USER,G_PREF_MODULE,L_RDN,'begin '||plugin_name||'.getRDN(:1,:2,:3:,:4,:5); end;');
    --        isDynamic := true;
    -- ELSE
    --  if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    --  then
    --    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'getRDN setup failed: '|| msg );
    --    msg:=null;
    --  end if;
    -- END IF;


     if ( validateTemplate('FND_OID_PLUG.getParentDN',plugin_name||'.getParentDN',errmsg) )THEN
      null;
     END IF;
     if ( validateTemplate('FND_OID_PLUG.getRealm',plugin_name||'.getRealm',errmsg) )THEN
      null;
     END IF;
     if ( validateTemplate('FND_OID_PLUG.fixup',plugin_name||'.fixup',errmsg) )THEN
      null;
     END IF;


      fnd_preference.put(G_PREF_USER,G_PREF_MODULE,L_TYPE,G_DYNAMIC_DESC);
      fnd_preference.put(G_PREF_USER,G_PREF_MODULE,L_REALM,'begin :1 := '||plugin_name||'.Realm(:2); end;');
      fnd_preference.put(G_PREF_USER,G_PREF_MODULE,L_REPOSITORY,'begin :1 := '||plugin_name||'.UserRepository(:2); end;');
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End' );
      end if;
      return;
   else
   */
     ldap := fnd_ldap_util.c_get_oid_session(flag);
     l_session_flag := true; /* fix for bug 8271359 */

     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag = true ' );
     end if;

     if (default_realm is not null) then
          g_realm := default_realm;
     else
         g_realm :=  FND_LDAP_UTIl.getLDAPAttribute(ldap,'cn=Common,cn=Products,cn=OracleContext','orclDefaultSubscriber');
    end if;

    if (default_user_repository is not null) then
         g_user_repo := default_user_repository;
    else
         g_user_repo := FND_LDAP_UTIl.getLDAPAttribute(ldap,'cn=Common,cn=Products,cn=OracleContext,'||g_realm,'orclcommondefaultusercreatebase');
    end if;
    if (g_user_repo is null) then
         g_user_repo := 'cn=Users,'||g_realm;
    end if;



    g_user_search := FND_LDAP_UTIL.getLDAPAttribute(ldap,'cn=Common,cn=Products,cn=OracleContext,'||g_realm,'orclcommonusersearchbase');

    if (g_user_search is null) then
         g_user_search := 'cn=Users,'||g_realm;
    end if;

    g_cnatt := FND_LDAP_UTIL.getLDAPAttribute(ldap,'cn=Common,cn=Products,cn=OracleContext,'||g_realm,'orclcommonnamingattribute');
    if (g_cnatt is null) then
         g_cnatt := 'cn';
    end if;

    g_nicknameatt := FND_LDAP_UTIL.getLDAPAttribute(ldap,'cn=Common,cn=Products,cn=OracleContext,'||g_realm,'orclcommonnicknameattribute');
    if (g_nicknameatt is null) then
         g_nicknameatt := 'uid';
    end if;


    fnd_preference.put(G_PREF_USER,G_PREF_MODULE,L_TYPE,G_STATIC_DESC);
    fnd_preference.put(G_PREF_USER,G_PREF_MODULE,L_REALM,g_realm);
    fnd_preference.put(G_PREF_USER,G_PREF_MODULE,L_CN_ATT,g_cnatt);
    fnd_preference.put(G_PREF_USER,G_PREF_MODULE,L_NICK_ATT,g_nicknameatt);
    fnd_preference.put(G_PREF_USER,G_PREF_MODULE,L_SEARCH,g_user_search);
    fnd_preference.put(G_PREF_USER,G_PREF_MODULE,L_REPOSITORY,g_user_repo);

    fnd_ldap_util.c_unbind(ldap,flag);
    l_session_flag := false;
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag : = false ' );
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION CLOSED NORMALLY : ' );
    end if;

--   end if;

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End' );
      end if;
EXCEPTION WHEN OTHERS THEN
         /* Fix for 8271359*/
    if l_session_flag = true then
       if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
           fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in EXCEPTION BLOCK - START ' );
       end if;
           fnd_ldap_util.c_unbind(ldap,flag);

       if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
           fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in EXCEPTION BLOCK - END ');
       end if;
    end if;

    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
     end if;
     raise;

  END setPlugin_old;

PROCEDURE upgrade_preferences is

l_realm varchar2(4000);
l_repo varchar2(4000);
ldap dbms_ldap.session;
flag pls_integer;
l_module_source varchar2(1000);
l_session_flag boolean := false;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'upgrade_preferences: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
    ldap := fnd_ldap_util.c_get_oid_session(flag);
    l_session_flag := true; /* fix for bug 8271359 */

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag = true ' );
    end if;
    l_realm :=  FND_LDAP_UTIL.getLDAPAttribute(ldap,'cn=Common,cn=Products,cn=OracleContext','orclDefaultSubscriber');
    l_repo :=  FND_LDAP_UTIL.getLDAPAttribute(ldap,'cn=Common,cn=Products,cn=OracleContext,'||l_realm,'orclcommondefaultusercreatebase');
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'AUTO UPGRADE');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, '=============');
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'realm:'||l_realm);
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'user creation base:'||l_repo);
  end if;

    setPlugin_old( default_realm => l_realm ,default_user_repository=>l_repo,plugin_name =>null);
    fnd_ldap_util.c_unbind(ldap,flag);
    l_session_flag := false;
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag : = false ' );
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION CLOSED NORMALLY : ' );
    end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'end');
  end if;


EXCEPTION WHEN OTHERS THEN
         /* Fix for 8271359*/
  if l_session_flag = true then
      if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
           fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in EXCEPTION BLOCK - START ' );
       end if;
           fnd_ldap_util.c_unbind(ldap,flag);

       if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
       then
           fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in EXCEPTION BLOCK - END ');
       end if;
  end if;

  if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_UNEXPECTED , l_module_source, 'Error '||sqlerrm);
  end if;

  raise;
END upgrade_preferences;


function pluginType_old return integer AS
val varchar2(20);
l_module_source varchar2(1000) ;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'pluginType: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
  return null;
END pluginType_old;


function sql_execute(stmt in varchar2, param in varchar ) return varchar2 as
c pls_integer;
res pls_integer;
result varchar2(4000);
l_module_source varchar2(1000) ;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'sql_execute: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
   c := dbms_sql.open_cursor;
   dbms_sql.parse(c, stmt, dbms_sql.NATIVE);
   dbms_sql.bind_variable(c, ':2', param);
   dbms_sql.bind_variable(c,':1',result,4000);
   res := dbms_sql.execute(c);
   dbms_sql.variable_value(c,':1',result);
   dbms_sql.close_cursor(c);

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END');
  end if;
   return result;
EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

END sql_execute;



FUNCTION getNewUserRealm(username in varchar2) return varchar2
IS
  opt option_type_rec;
  l_module_source varchar2(4000):=G_MODULE_SOURCE || 'getNewUserRalm: ';
BEGIN
  IF NOT getOption('REALM',opt )
  THEN
    return FND_SSO_REGISTRATION.getDefaultRealm();
  END IF;
  --AQUI
  CASE opt.opt_mode
  WHEN G_STATIC THEN BEGIN
            return opt.val;
        END;
  WHEN G_RUNTIME THEN BEGIN
             IF g_cached_realm is null THEN
                g_cached_realm:= FND_SSO_REGISTRATION.getDefaultRealm();
             END IF;
             return g_cached_realm;
         END;
  WHEN G_DYNAMIC THEN BEGIN
       return sql_execute(opt.val,username);
     END ;
  ELSE
     raise configuration_error;
  END CASE;
      EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;


END getNewUserRealm;
/*
* Do not use it. Too costly.
* Except when you rally want the realm for an EXISTING user.
* Preffer getRealmDNNewUser for new users
*
* CALCULATION steps
*    1- If the user exists in FND_USER and has a GUID return get_realm_from_guid
*          If guid is incorrec raise an error
*    2- IF user does not exist in FND_USER user FND_LDAP_USER.Search(username,ouy guid)
*           This function can be costly, but worst. It is possible on multiples realms
*           to have NON-UNIQUE usernames (non-wide uniqeu attributes, or differet nna ).
*            In that case ANY of those will be returned.
*
*/

function getRealmDN(username  varchar2) return varchar2 AS
    result varchar2(4000);
    l_module_source varchar2(1000) ;
    l_guid  FND_USER.user_guid%type;
    user_rec FND_LDAP_USER.ldap_user_type;
BEGIN
   validateVersion;

  l_module_source := G_MODULE_SOURCE || 'getRealmDN: ';
  result := null;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin '||username);
  end if;

  BEGIN
      select user_guid into l_guid from FND_USER
      where user_name=username;
      if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Found on FND_USER guid: '||NVL(l_guid,'**NULL*'));
       end if;

    EXCEPTION WHEN NO_DATA_FOUND THEN
         l_guid:=null;
  END;

  IF (l_guid IS NOT NULL )THEN
       result := FND_SSO_REGISTRATION.getGuidRealm(l_guid);

       if (result is null ) THEN

         if (fnd_log.LEVEL_EXCEPTION>= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Invalid GUID guid: '||l_guid);
         END IF;

          raise NO_DATA_FOUND;
       END IF;

  END IF;
  if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Looking at LDAP for the user '||username);
 end if;
  IF FND_LDAP_USER.SearchUser(username,user_rec) THEN
      if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'FOUND!! dn: '||user_rec.dn);
     end if;
      result := user_rec.realmDN;
  ELSE
      if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'NOT FOUND, will retrun real for new user then');
     end if;
     result := getNewUserRealm(username);
     if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'RealmDN:'||result);
     end if;
  END IF;
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ->'||result);
  end if;
  return result;
  EXCEPTION WHEN OTHERS THEN
        if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
          fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'ERROR:'||sqlerrm);
        end if;
        raise;
END getRealmDN;

function getUserRepository(p_ldap_user  IN OUT nocopy fnd_ldap_user.ldap_user_type ) return varchar2 AS
    result varchar2(4000);
    l_module_source varchar2(1000) ;
    opt option_type_rec;
    baseList dbms_ldap.string_collection;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'getUserRepository: ';
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin ');
  end if;

  IF (p_ldap_user.parent_DN is not null) THEN
     result:=p_ldap_user.parent_DN ;
  ELSIF getOption('CREATE_BASE',opt) THEN
     CASE opt.opt_MODE
       WHEN G_STATIC THEN result:= opt.val;
       WHEN G_RUNTIME THEN
          BEGIN
                result := fnd_sso_registration.get_realm_attribute(p_ldap_user.realmDN ,'orclCommonUserCreateBase',0);

          END ;
      WHEN G_DYNAMIC THEN
          BEGIN

            EXECUTE immediate opt.val  USING
                                IN p_ldap_user.user_id,
                                IN p_ldap_user.user_name,
                                IN p_ldap_user.realmDN,
                                OUT result;
          END;
      ELSE raise FND_OID_PLUG.CONFIGURATION_ERROR;
      END CASE;

  ELSE

     if (p_ldap_user.realmDN is null) THEN
        -- must set the realm before calling
        return null;
     END IF;
     result := fnd_sso_registration.get_realm_attribute(p_ldap_user.realmDN ,'orclCommonUserCreateBase',0);
  END IF;
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END-> '||result);
  end if;

  return result;
  EXCEPTION WHEN OTHERS THEN
        if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
          fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'ERROR:'||sqlerrm);
        end if;
        raise;

END getUserRepository;

function getNickNameattr(username in varchar2) return varchar2 AS

    result varchar2(4000);
    l_module_source varchar2(1000) ;
BEGIN
     validateVersion;
  l_module_source := G_MODULE_SOURCE || 'getNickNameattr: ';
  return FND_LDAP_USER.getnicknameattr(username);
END getNickNameattr;


PROCEDURE getRDN
  (
    username IN VARCHAR2,
    userid   IN pls_integer ,
    rdn_att  IN OUT nocopy VARCHAR2 ,
    rdn_val  IN OUT nocopy VARCHAR2 ,
    replaceFlag IN OUT nocopy BOOLEAN )
AS
  result        VARCHAR2(4000);
  l_module_source VARCHAR2(1000) ;
  q             VARCHAR2(1000);
  aux pls_integer;
  opt option_type_rec;
  idx pls_integer;

BEGIN
  l_module_source               := G_MODULE_SOURCE || 'getRDN: ';
  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  END IF;
  IF (NOT getOption('RDN',opt) )THEN
    opt.opt_mode:=G_STATIC;
    opt.val     := FND_SSO_REGISTRATION.get_Realm_Attribute( FND_SSO_REGISTRATION.getdefaultrealm,'orclCommonNamingAttribute');
    saveOption('RDN',opt.opt_mode,opt.val);
  END IF;
  CASE opt.opt_mode
  WHEN G_STATIC THEN
    BEGIN
      rdn_att     := opt.val;
      rdn_val     := username;
      replaceFlag := true;
    END;
  WHEN G_RUNTIME THEN
    BEGIN
      idx        := FND_SSO_REGISTRATION.getUserRealmIndex(username);
      rdn_att    := FND_SSO_REGISTRATION.get_Realm_Attribute(idx,'orclCommonNamingAttribute');
      rdn_val    := username;
      replaceFlag:= true;
    END ;
  WHEN G_DYNAMIC THEN
    BEGIN
      q                           := opt.val;
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Testing dynamic');
      END IF;
      EXECUTE immediate q USING IN username,
                                IN userid,
                                IN OUT rdn_att,
                                IN OUT rdn_val,
      OUT aux;
      replaceFlag                 := (AUX=1);
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'RND:'||rdn_att||'='||rdn_val);
      END IF;
    END;
  ELSE BEGIN

    raise FND_OID_PLUG.CONFIGURATION_ERROR;
    END;
  END CASE;
  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.
string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ->'||result);
  END IF;
  RETURN ;
EXCEPTION
WHEN OTHERS THEN
  IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
  END IF;
  raise;
END getRDN;

/*
function getSearchBase(username in  varchar2) return varchar2 AS
  res varchar2(1000);
  ldap dbms_ldap.session;
  dummy pls_integer;
    result varchar2(4000);
    l_module_source varchar2(1000) ;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'getSearchBase: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

    if (plugin_type is null) then plugin_type:=pluginType; end if;
   if (plugin_type=G_STATIC) then
       result:= g_user_search;
   else
      ldap := fnd_ldap_util.c_get_oid_session(dummy);
      result:=  FND_LDAP_UTIL.getLDAPAttribute(ldap,'cn=Common,cn=Products,cn=OracleContext,'||getRealmDN(username),'orclcommonusersearchbase');
      fnd_ldap_util.c_unbind(ldap,dummy);
   end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ->'||result);
  end if;


  return result;
      EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

END getSearchBase;
*/
/*
function getSearchFilter(username in varchar2) return varchar2 AS
    result varchar2(4000);
    l_module_source varchar2(1000) ;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'getSearchFilter: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

    if (plugin_type is null) then plugin_type:=pluginType; end if;
   if (plugin_type=G_STATIC) then
       result:= g_nicknameatt||'='||username;
   else
      result:=g_nicknameatt||'='||username;
   end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ->'||result);
  end if;


  return result;
      EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

  END getSearchFilter;
*/

function getNickNameAttributeFromRealm(realmDn in varchar2) return varchar2
is

  ldap dbms_ldap.session;
  dummy pls_integer;
  result varchar2(4000);
  l_module_source varchar2(1000) ;
  l_session_flag boolean := false;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'getNickNameAttributeFromRealm: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

     ldap := fnd_ldap_util.c_get_oid_session(dummy);
     l_session_flag := true; /* fix for bug 8271359 */

     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag = true ' );
     end if;

     result:= FND_LDAP_UTIL.getLDAPAttribute(ldap,'cn=Common,cn=Products,cn=OracleContext,'||realmDn,'orclcommonnicknameattribute');
     fnd_ldap_util.c_unbind(ldap,dummy);

     l_session_flag := false;
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag : = false ' );
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION CLOSED NORMALLY : ' );
     end if;

      if (result is null) then result:='uid'; end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ->'||result);
  end if;


  return result;
EXCEPTION WHEN OTHERS THEN
     if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
         then
            fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, sqlerrm);
         end if;
         /* Fix for 8271359*/
         if l_session_flag = true then
            if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
            then
               fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in EXCEPTION BLOCK - START ' );
            end if;
           fnd_ldap_util.c_unbind(ldap,dummy);

           if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
           then
               fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in EXCEPTION BLOCK - END ');
           end if;
     end if;

     if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
     end if;
      raise;

END getNickNameAttributeFromRealm;

function getUsernameFromEntry(attr_list ldap_attr_list) return varchar2
is
j pls_integer;
    result varchar2(4000);
    l_module_source varchar2(1000) ;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'getUsernameFromEntry: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

     if (attr_list is not null AND attr_list.count > 0)
   then
     for j in attr_list.first .. attr_list.last
     loop

        if(upper(attr_list(j).attr_name) = 'ORCLGUID') then
 	     result:= get_username_from_guid(attr_list(j).attr_value);
             if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
             then
               fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ->'||result);
             end if;

             return result;
        end if;
     end loop;
    end if;
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
         fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END -> raise NO_DATA_FOUND');
     end if;
    raise no_data_found;
        EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

end getUsernameFromEntry;

function get_entry_dn(ldap in out nocopy dbms_ldap.session, p_guid IN raw ) return varchar2
is
result pls_integer;
entry_dn varchar(4000);
  l_message dbms_ldap.message ;
  l_attrs dbms_ldap.string_collection;
  l_entry  dbms_ldap.message;

    l_module_source varchar2(1000) ;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'get_entry_dn: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

   l_attrs(0) := 'dn'; -- NO_ATTRS
   result := dbms_ldap.search_s(ld => ldap
                             , base => ''
			     , scope => dbms_ldap.SCOPE_SUBTREE
			     , filter => 'orclguid='||p_guid
			     , attrs => l_attrs
			     , attronly => 0
                             , res => l_message);
  l_entry := dbms_ldap.first_entry(ldap, l_message);
  entry_dn := dbms_ldap.get_dn(ldap,l_entry);
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ->'||entry_dn);
  end if;

  return entry_dn;
    EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

end get_entry_dn;

function get_realm_from_user_dn(ldap in out nocopy dbms_ldap.session, user_dn in varchar2 )
   return varchar2

is
cn_list dbms_ldap.STRING_COLLECTION;
len pls_integer;
i pls_integer;
j pls_integer;
dn varchar2(4000);
g varchar2(1000);
result varchar2(4000);
l_module_source varchar2(1000) ;
l_realm_idx pls_integer;
dev_version number := 2.0 ;
BEGIN
   validateVersion;

  l_module_source := G_MODULE_SOURCE || 'get_realm_from_user_dn: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin '||dev_version);
  end if;

  if (dev_version>=1.0 and dev_version<2.0) THEN
    cn_list := dbms_ldap.explode_dn(user_dn,0);
    len := cn_list.count;
    i:= 0;
    while (i<len) loop

        -- construct a new dn from 0..1
        dn := cn_list(i);
        j:=i+1;
        while(j<len) loop
           dn := dn||','||cn_list(j);
           j:=j+1;
        end loop;
        BEGIN
           g := FND_LDAP_UTIL.getLDAPAttribute(ldap,dn,'orclguid','objectclass=orclSubscriber');
           if (dev_version>=1.1) THEN -- we check something more
             g := FND_LDAP_UTIL.getLDAPAttribute(ldap,'cn=Common,cn=Products,cn=OracleContext,'||dn,'orclcommonnicknameattribute','objectclass=*');
           END IF;
        EXCEPTION
            WHEN DBMS_LDAP.general_error THEN
                g:= null;
            WHEN OTHERS THEN
                g:=null;
          END;
        if (g is not null) then
            if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
             then
               fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ->'||dn);
             end if;
            return dn;
        end if;
        i:=i+1;
    end loop;

  ELSIF dev_version=2.0 THEN
     l_realm_idx := fnd_sso_registration.getUserRealmIndex(dn);
     if (l_realm_idx is not null) then
        dn := fnd_sso_registration.find_realm(l_realm_idx);
        if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END->'||dn);
        end if;
        return dn;
     end if;
  else
      raise NO_DATA_FOUND;
  END IF;
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END NULL!');
  end if;
    return null;
 EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

end get_realm_from_user_dn;


function get_username_from_guid(p_user_guid IN fnd_user.user_guid%type ) return varchar2
is
ldap dbms_ldap.session;
dummy pls_integer;
user_dn varchar2(4000);
realm_dn varchar2(4000);
user_name varchar2(1000);
nickNameAttr varchar2(50);
l_module_source varchar2(1000) ;
realm_idx pls_integer;
l_session_flag boolean := false;
BEGIN
  l_module_source := G_MODULE_SOURCE || 'get_username_from_guid: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
  if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'guid='||p_user_guid);
  end if;

   ldap := fnd_ldap_util.c_get_oid_session(dummy);
   l_session_flag := true; /* fix for bug 8271359 */

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag = true ' );
   end if;

  user_dn := get_entry_dn(ldap,p_user_guid);
  if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'guid=>DN:'||user_dn);
  end if;
  if user_dn is null then

              if (fnd_log.LEVEL_EXCEPTION>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
              then
                    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'DN not found , invalid GUID ');
              end if;
              fnd_message.set_name ('FND', 'FND_SSO_USER_NOT_FOUND');
              raise NO_DATA_FOUND ;
  end if;

  realm_dn := get_realm_from_user_dn(ldap,user_dn);
  if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'DN=>RealmDN:'||realm_dn);
  end if;
  if realm_dn is null then
              if (fnd_log.LEVEL_EXCEPTION>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
              then
                    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Cannot locate Realm for DN:'||user_dn);
              end if;
             fnd_message.set_name ('FND', 'FND-9903'); -- cannot find realm for user
             raise NO_DATA_FOUND ;
    end if;


  realm_idx := FND_SSO_REGISTRATION.find_realm_index(realm_dn);
  if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'RealmDN=>idx:'||realm_idx);
  end if;

  if realm_idx < 0  then
              if (fnd_log.LEVEL_EXCEPTION>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
              then
                    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Realm not loaded: Realm:'||realm_dn);
              end if;
             fnd_message.set_name ('FND', 'FND-9903'); -- cannot find realm idx
             raise NO_DATA_FOUND ;
  end if;

  --nickNameAttr:=FND_LDAP_UTIL.getLDAPAttribute(ldap,'cn=Common,cn=Products,cn=OracleContext,'||realm_dn,'orclCommonNicknameAttribute');
  nickNameAttr := FND_SSO_REGISTRATION.get_realm_attribute(realm_idx,'orclCommonNicknameAttribute');
  if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Realm=>NickNameAttrubute:'||nickNameAttr);
  end if;

  if nickNameAttr is null then
              if (fnd_log.LEVEL_EXCEPTION>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
              then
                    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Cannot read Realm nickname attribute, Realm:'||realm_dn);
              end if;

        fnd_message.set_name ('FND', 'FND-9903'); -- cannot find nickname attribute specification
         raise NO_DATA_FOUND ;
    end if;

  user_name := FND_LDAP_UTIL.getLDAPAttribute(ldap,user_dn,nickNameAttr);
  if (fnd_log.LEVEL_STATEMENT>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'DN+NickNameAttrubute=>user_name:'||user_name);
  end if;

  if user_name is null then
       if (fnd_log.LEVEL_EXCEPTION>= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
                    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'Record does not have '||nickNameAttr||' attribute DN:'||user_dn);
      end if;
      fnd_message.set_name ('FND', 'FND_SSO_USER_NOT_FOUND'); --user has no nickname
       raise NO_DATA_FOUND ;
  end if;
  fnd_ldap_util.c_unbind(ldap,dummy);
  l_session_flag := false;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag : = false ' );
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION CLOSED NORMALLY : ' );
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ->'||user_name);
  end if;

  return user_name;
EXCEPTION when NO_DATA_FOUND THEN
      fnd_ldap_util.c_unbind(ldap,dummy);
     if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, ' Not found guid='||p_user_guid);
      end if;
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ->EXCEPTION');
  end if;

      raise;
end get_username_from_guid;


function get_default_realm return varchar2
is
 res varchar2(1000);
  ldap dbms_ldap.session;
  dummy pls_integer;
    result varchar2(4000);
    l_module_source varchar2(1000) ;
BEGIN
   validateVersion;
  l_module_source := G_MODULE_SOURCE || 'get_default_realm: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;
   result := FND_SSO_REGISTRATION.getDefaultRealm;
   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ->'||result);
  end if;
  return result;
      EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

END get_default_realm;
---
----
----- INTERNAL SSO
------
FUNCTION get_realm_dn
  ( p_user_guid IN raw DEFAULT NULL,
    p_user_name IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
IS
  ldap dbms_ldap.session;
  flag pls_integer;
  result VARCHAR2(4000);
  l_module_source VARCHAR2(1000) ;
  l_dn VARCHAR2(4000);
  l_session_flag boolean := false;
BEGIN
  validateVersion;
  l_module_source := G_MODULE_SOURCE || 'get_realm_dn: ';

  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
    IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'guid:'||p_user_guid);
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'username:'||p_user_name);
    END IF;
  END IF;

  IF (p_user_guid IS NULL AND p_user_name IS NULL) THEN
    IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'No guid or  username=> returning the default realm');
    END IF;
    result:= FND_OID_PLUG.get_default_realm;
  ELSE
    ldap := fnd_ldap_util.c_get_oid_session(flag);
    l_session_flag := true; /* fix for bug 8271359 */

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
     then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag = true ' );
    end if;

    result := NULL;

    IF (p_user_guid IS NOT NULL) THEN
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Attempt to retreive the actual realm for that guid');
      END IF;
      l_dn := get_entry_dn(ldap,p_user_guid);
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'DN:'||l_dn);
      END IF;
      result :=get_realm_from_user_dn(ldap,l_dn);
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'GUID: realm:'||result);
      END IF;
    END IF;
    IF (result IS NULL AND p_user_name IS NOT NULL) THEN
      result := getRealmDN(p_user_name);
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Using username, realm:'||result);
      END IF;
    END IF;
    IF (result IS NULL) THEN
      result := get_default_realm;
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'fallback to default realm:'||result);
      END IF;
    END IF;
    fnd_ldap_util.c_unbind(ldap,flag);
    l_session_flag := false;
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag : = false ' );
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION CLOSED NORMALLY : ' );
    end if;

  END IF;
  IF (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END ->'||result);
  END IF;
  RETURN result;
EXCEPTION WHEN OTHERS THEN
  if l_session_flag = true then
     if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
         fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in EXCEPTION BLOCK - START ' );
     end if;
     fnd_ldap_util.c_unbind(ldap,flag);

     if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
         fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in EXCEPTION BLOCK - END ');
     end if;
  end if;
  IF (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'END ->'||sqlerrm);
  END IF;
  raise;
END get_realm_dn;

function count_attributes(ldap in out nocopy dbms_ldap.session, dn in  varchar2, attName in  varchar2)
    return integer
  is
  l_result pls_integer;
  l_attrs dbms_ldap.string_collection;
  l_message dbms_ldap.message := NULL;
  l_entry dbms_ldap.message := NULL;
  l_module_source varchar2(4000);
begin
  l_module_source := G_MODULE_SOURCE || 'count_attributes: ';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'dn:'||dn);
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'attribute:'||attName);
    end if;
  end if;
  l_attrs(0):= attName;
  l_result := dbms_ldap.search_s(ld => ldap
                             , base => dn
			     , scope => dbms_ldap.SCOPE_BASE
			     , filter => 'objectclass=*'
			     , attrs => l_attrs
			     , attronly => 0
                             , res => l_message);
   l_entry := dbms_ldap.first_entry(ldap, l_message);
   if (l_entry is null ) then
         if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
         then
             fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End(not found)');
         end if;
         return 0;
    end if;
    l_attrs := dbms_ldap.get_values(ldap, l_entry, attName);
    l_result := l_attrs.count;
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'result:'||l_result);
    end if;
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
         fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END');
    end if;
    return l_result;

    EXCEPTION when   others then
      if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
           fnd_log.string(fnd_log.LEVEL_UNEXPECTED , l_module_source, 'Error '||sqlerrm);
       end if;
       raise;
end count_attributes;



function getRealmCommonNameAttribute(realm in varchar2) return varchar2
IS
idx pls_integer;
ret varchar2(200);
BEGIN
   idx := FND_SSO_REGISTRATION.find_realm_index(realm);
   ret := FND_SSO_REGISTRATION.get_realm_attribute(idx,'orclcommonnamingattribute');
   if (ret is null) then
    ret := 'uid';
   end if;
   return ret;
END getRealmCommonNameAttribute;

function getDN(p_ldap_user IN OUT nocopy fnd_ldap_user.ldap_user_type) return varchar2
is
l_module_source varchar2(1000) ;
name varchar2(200);
val VARCHAR2(2000);
replaceFlag boolean;
i pls_integer;
BEGIN
      l_module_source := G_MODULE_SOURCE || 'getDN: ';

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
      end if;
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' Caculating all for "'||p_ldap_user.user_name||'"');
      end if;

      p_ldap_user.realmDN:= getRealmDN(p_ldap_user.user_name);
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' Realm "'||p_ldap_user.realmDN||'"');
      end if;



  p_ldap_user.parent_DN := getUserRepository(p_ldap_user);

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' User repository  "'||p_ldap_user.parent_DN||'"');
      end if;

      name:= getRealmCommonNameAttribute(p_ldap_user.realmDN);
      val := p_ldap_user.user_name;

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' CommonName(realm) Attribute "'||name||'"');
      end if;

     FND_OID_PLUG.getRDN(p_ldap_user.user_name,p_ldap_user.user_id,name,val,replaceFlag);

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' Custom RDN: '||name||'='||val);
      end if;


  FND_LDAP_USER.setAttribute(p_ldap_user,name,val,replaceFlag);

  p_ldap_user.RDN_ATT_NAME := name;
  p_ldap_user.RDN_VALUE := val;

  p_ldap_user.dn :=   name||'='||val||','||p_ldap_user.parent_DN ;

  p_ldap_user.NickName_ATT_NAME := getRealmNickNameattr(p_ldap_user.realmDN);

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' Nicknameattribute : '|| p_ldap_user.NickName_ATT_NAME);
      end if;

  name:=p_ldap_user.NickName_ATT_NAME;
  val :=p_ldap_user.user_name;
  FND_LDAP_USER.setAttribute(p_ldap_user,name,val,true);

     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, ' replaced '|| p_ldap_user.NickName_ATT_NAME||'='||p_ldap_user.user_name);
      end if;
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'END->'||p_ldap_user.dn);
      end if;
      return p_ldap_user.dn;

EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, sqlerrm);
      end if;
      raise;
END getDN;

function Helper_NewEmptyCollection  return dbms_ldap.STRING_COLLECTION
is
t dbms_ldap.STRING_COLLECTION ;
begin
return t;
end Helper_NewEmptyCollection;

procedure copyData( d1 in out nocopy FND_LDAP_UTIl.ldap_record_values, d2 in out nocopy FND_LDAP_UTIL.ldap_record_values )
is
atName varchar2(4000);
idx pls_integer;
begin
   d2.delete;
   atName := d1.first;
   while atName is not null loop
      if d1.exists(atName) then
         idx := d1(atName).first;
         d2(atName) := Helper_NewEmptyCollection;
         while idx is not null loop
            d2(atName)(d2(atName).count) := d1(atName)(idx);
            idx := d1(atName).next(idx);
         end loop;
      end if;
      atName:= d1.next(atName);
   end loop;
end copyData;


Procedure completeForCreate(ldap in dbms_ldap.session ,p_ldap_user IN OUT nocopy fnd_ldap_user.ldap_user_type )
is
replaceFlag boolean;
rdn varchar2(200);
val varchar2(4000);
opt option_type_rec;
l_module_source varchar2(1000) ;

begin
      l_module_source := G_MODULE_SOURCE || 'completeForCreate: ';

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'BEGIN:'||p_ldap_user.dn);
      end if;

   validateVersion;

    if (p_ldap_user.realmDN is null) THEN
      p_ldap_user.realmDN := getNewUserRealm(p_ldap_user.user_name);
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'RealmDN set to:'||p_ldap_user.realmDN);
      end if;
   END IF;
   if (p_ldap_user.parent_DN is null) THEN
        p_ldap_user.parent_DN :=getUserRepository(p_ldap_user);
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'parent_DN set to:'||p_ldap_user.parent_DN);
      end if;

   END IF ;
   if (p_ldap_user.NickName_ATT_NAME is null ) THEN
       p_ldap_user.NickName_ATT_NAME :=FND_SSO_REGISTRATION.get_realm_attribute(p_ldap_user.realmDN,'orclCommonNickNameAttribute');
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'NickName_ATT_NAME set to:'||p_ldap_user.NickName_ATT_NAME);
      end if;
   END IF;
   iF (p_ldap_user.RDN_ATT_NAME is null or p_ldap_user.RDN_VALUE is null ) THEN
      getRDN(p_ldap_user.user_name,p_ldap_user.user_id,
             rdn,val, replaceFlag );
       p_ldap_user.RDN_ATT_NAME:= rdn;
       p_ldap_user.RDN_VALUE:=val;
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'RND set to:'||p_ldap_user.RDN_ATT_NAME||'='||p_ldap_user.RDN_VALUE);
      end if;

      FND_LDAP_USER.setAttribute(p_ldap_user, rdn,val,replaceFlag);

   END IF;
   p_ldap_user.dn :=  p_ldap_user.RDN_ATT_NAME||'='||p_ldap_user.RDN_VALUE
      ||','|| p_ldap_user.parent_DN;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'dn set to:'||p_ldap_user.dn);
  end if;


  EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, sqlerrm);
      end if;
      raise;
end completeForCreate;


function getRealmList return dbms_ldap.string_collection
IS
ret dbms_ldap.string_collection;
l_module_source varchar2(200)  := G_MODULE_SOURCE || 'getRealmList: ';

/*
* 1.0: just return the default realm
* 1.1: return all realms
*/
dev_version number := 1.0;

BEGIN
   validateVersion;

  if (dev_version=1.0) THEN
    -- just one realm for now
   ret(0) := get_default_realm();
   return ret;
  ELSIF dev_version=1.1 THEN
     -- return all realms
     return ret;
  ELSE
      raise NO_DATA_FOUND;
  END IF;
      EXCEPTION WHEN OTHERS THEN
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION:'||sqlerrm);
      end if;
      raise;

END getRealmList;


PROCEDURE FixupLDAPUser(p_ldap_user IN OUT nocopy FND_LDAP_USER.ldap_user_type, operation pls_integer) IS
opt option_type_rec;
l_module_source varchar2(400):=G_MODULE_SOURCE||'FixupLDAPUser';
BEGIN
 -- DataCreationFixup
  IF getOption('FIXUP',opt ) THEN
    IF opt.opt_mode=G_DYNAMIC  THEN
      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Calling Dynamic Fixup:'||opt.val);
      END IF;
      copyData(p_ldap_user.user_data,user_data);
      EXECUTE immediate opt.val USING  IN p_ldap_user.user_id, IN p_ldap_user.user_name,
                                 IN operation;
      copyData(user_data,p_ldap_user.user_data);

      IF (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Returned from  Fixup');
       END IF;
    END IF;
  END IF;
END FixupLDAPUser;

procedure getDefaultRealm_Template(realm out nocopy varchar2) IS
   BEGIN
    raise NO_DATA_FOUND;
END getDefaultRealm_Template;

procedure getDefaultCreateBase_Template(realm in varchar2, parentDN out nocopy varchar2 ) IS
BEGIN
  raise NO_DATA_FOUND;
END getDefaultCreateBase_Template;

procedure getCreateBase_Template(user_id in INTEGER,
  user_name in varchar2,
  realm in varchar2,
  parentDn out nocopy varchar2) IS
BEGIN
  raise NO_DATA_FOUND;
END getCreateBase_Template;

procedure getRealm_Template( user_id in INTEGER, user_name in varchar2, realmDn out nocopy varchar2) IS
BEGIN
  raise NO_DATA_FOUND;
END getRealm_Template;

procedure getRDN_Template(user_name in varchar2,
   user_id in pls_integer,
   RDN_attName in out nocopy varchar2,
   RND_value in out nocopy varchar2,
   replaceFlag in out nocopy  pls_integer) IS
BEGIN
   raise NO_DATA_FOUND;
END getRDN_Template;

procedure FixupLDAPUser_Template( user_id in INTEGER, user_name in varchar2, operation in pls_integer)
is BEGIN
       raise NO_DATA_FOUND;
END FixupLDAPUser_Template;


END FND_OID_PLUG;

/
