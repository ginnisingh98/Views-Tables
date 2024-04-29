--------------------------------------------------------
--  DDL for Package Body FND_SSO_REGISTRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SSO_REGISTRATION" AS
/* $Header: AFSCORGB.pls 120.11.12010000.12 2015/11/16 16:52:32 ctilley ship $*/
-- package internal globals
G_MODULE_SOURCE  constant varchar2(80) := 'fnd.plsql.oid.fnd_sso_registration.';

/* TDA */

type permited_operation is record (
    enabled boolean,
    identity_add varchar2(4000),
    identity_update varchar2(4000),
    identity_delete varchar2(4000),
    subscription_add varchar2(4000),
    subscription_delete varchar2(4000),
    subscription_update varchar2(4000) );

type realm_type is  RECORD (
  seq pls_integer ,
  guid raw(16),
  dn varchar2(4000) ,
  loaded boolean,
  appsToOiD permited_operation,
  oidToApps permited_operation,
  ldap_data FND_LDAP_UTIL.ldap_record_type
  )
  ;

type realm_table_type is table of realm_type index by binary_integer;

realm_table realm_table_type;

defaultRealm_cache varchar2(200) := null;

/*
** Name      : getAttribute
** Type      : Private
** Desc      : returns the first value of an OiD attribute
** Parameters  :
**       ldap: ldap sesion
**       dn : OiD Entry
**       attrName: attributeName
**       filterExp: additional filter.
** Exceptions: DBMS_LDAP exceptions
**             NOte that this DBMS_LDAP exception maybe risen by other reasons
**
*/
function getAttribute(ldap in out nocopy dbms_ldap.session,dn in  varchar2, attrName in varchar2, filterExp in varchar2 default 'objectclass=*')
 return varchar2
 is
  result pls_integer;
  l_attrs dbms_ldap.string_collection;
  l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_result varchar2(4000);

 BEGIN
   l_attrs(0):= attrName;
   result := dbms_ldap.search_s(ld => ldap
                             , base => dn
			     , scope => dbms_ldap.SCOPE_BASE
			     , filter => filterExp
			     , attrs => l_attrs
			     , attronly => 0
                             , res => l_message);
      l_entry := dbms_ldap.first_entry(ldap, l_message);
      if (l_entry is null ) then
         return null;
      end if;
      l_attrs := dbms_ldap.get_values(ldap, l_entry, attrName);
      l_result := l_attrs(0);
      return l_result;
	-- Bug 6129943
      exception when dbms_ldap.general_error then
          return null;
       when others then
	  raise;
 END getAttribute;


/*
** Name      : parse_ops
** Type      : Private
** Desc      : Retrive povisioning profile attributes and parse it into INTERNAL TDA.
** Parameters  :
**       ldap: ldap sesion
**       dn : OiD Entry
**       attrName: attributeName - multivalued
** Exceptions: DBMS_LDAP exceptions
**             NOte that this DBMS_LDAP exception maybe risen by other reasons
**
*/
function parse_ops(ldap in out nocopy dbms_ldap.session, dn in varchar2, attrname in varchar2)
    return permited_operation
is
   r permited_operation;
   l_result pls_integer;
   l_attrs dbms_ldap.string_collection;
   l_entry dbms_ldap.message;
   l_message	dbms_ldap.message;
   vals dbms_ldap.string_collection;
   i pls_integer;
   i1 pls_integer;
   i2 pls_integer;
   i3 pls_integer;
   i4 pls_integer;
   ent varchar2(100);
   op varchar2(100);
   lista varchar2(4000);
   v2 varchar2(4000);
  invalid_operation exception;
PRAGMA EXCEPTION_INIT (invalid_operation, -20002);

begin
  r.identity_add :=null;
  r.identity_update :=null;
  r.identity_delete :=null;
  r.subscription_add :=null;
  r.subscription_delete :=null;
  r.subscription_update:=null;
  r.enabled := true; -- else this method shouldn't had been called
  l_attrs(0) := attrname;
  l_result := dbms_ldap.search_s(ld => ldap,
          base => dn,
          scope => dbms_ldap.SCOPE_BASE,
          filter => 'objectclass=*',
          attrs => l_attrs,
          attronly => 0,
          res => l_message);
   l_entry := dbms_ldap.first_entry(ldap,l_message);
   vals := dbms_ldap.get_values(ldap,l_entry,attrname);
   for i in vals.first..vals.last loop
      v2 :=vals(i);
      i1 := instr(vals(i),':',1);
      i2 := instr(vals(i),':',i1+1);
      ent := substr(vals(i),1,i1-1);
      v2 := substr(vals(i),i2+1);
      i3 := instr(v2,'(',1);
      if (i3=0) then
        op := v2;
        lista := '*';
      else
         op := substr(v2,1,i3-1);
         i4 := instr(v2,')',i3);
         lista := ','||replace(substr(v2,i3+1,i4-i3-1),' ','')||',';
         if (lista=',*,') then lista:='*'; end if;
      end if;
      if (ent='IDENTITY') THEN
          if (op='ADD') THEN
            r.identity_add := lista;
          elsif(op='MODIFY') then
            r.identity_update := lista;
          elsif (op='DELETE') then
            r.identity_delete := lista;
          else
            raise invalid_operation;
          end if;
      ELSIF (ent='SUBSCRIPTION') THEN
          if (op='ADD') THEN
              r.subscription_add := lista;
          elsif (op='MODIFY') THEN
              r.subscription_update := lista;
          elsif (op='DELETE') THEN
              r.subscription_delete := lista;
          else
              raise invalid_operation;
          end if;
      else
          raise invalid_operation;
      END IF;
   end loop;
   return r;
end parse_ops;


/*
** Name      : load_realm
** Type      : Private
** Desc      : Load a realm pemited operations into cache
** Parameters  :
**       r : realm. The filed r.dn is used to start
**       dn : OiD Entry
**       attrName: attributeName - multivalued
** Exceptions: DBMS_LDAP exceptions,
**              NO_DATA_FOUND : if the dn is not at realm.
**
*/

procedure load_realm( r in out nocopy realm_type)

is
flag pls_integer;
ldap dbms_ldap.session;
appdn varchar2(4000);
provcontainer varchar2(4000);
appguid raw(16);
provProfileDn varchar2(4000);
guid raw(16);
provStatus varchar2(1000);
l_result pls_integer;
l_module_source varchar2(4000);
l_session_flag boolean := false;
begin
   l_module_source := G_MODULE_SOURCE||'load_realm';

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_PROCEDURe, l_module_source, 'BEGIN' );
   end if;

   ldap := fnd_ldap_util.c_get_oid_session(flag);
   l_session_flag := true; /* fix for bug 8271359 */

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'DN='||r.dn );
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag = true ' );
   end if;

   r.guid := getAttribute(ldap,r.dn,'orclGuid');

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'r.guid is '|| r.guid );
   end if;

   IF NOT FND_LDAP_UTIL.loadldaprecord(ldap,r.ldap_data.data,r.ldap_data.dn,'cn=Common,cn=Products,cn=OracleContext,'||r.dn,FND_LDAP_UTIL.G_DN_KEY) THEN
      -- cannot find the specified REalm
          if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
              fnd_log.string(fnd_log.LEVEL_UNEXPECTED, 'FND_SSO_REGISTRATION.load_realm', 'Requested Realm not found dn="'||r.dn||'"');
          end if;
          raise no_data_found;
   END IF;

   if (r.guid is null) then
      raise no_data_found;
   end if;

   -- Bug 19904770
   -- DIP provisioning container locatio in the DIT is not the same between OID
   -- and OUD. Should requests the provisioning container location
   -- prior building the dn
   -- Get the application dn
   appdn := fnd_ldap_util.get_orclappname;

    -- Get the guid of the application entry
   appguid :=fnd_ldap_util.get_guid_for_dn(ldap,appdn);

   -- Bug 19904770: Get the provisioning container DN to support both OID and OUD
   -- provProfileDn := 'orclODIPProfileName='||r.guid||'_'||appguid||',cn=Provisioning Profiles, cn=Changelog Subscriber, cn=Oracle Internet Directory';

   provcontainer := fnd_ldap_util.get_provprofilecontainer;
   provProfileDn := 'orclODIPProfileName='||r.guid||'_'||appguid|| ',' || provcontainer;

   -- does the provisioning profile exists
   provStatus := getAttribute(ldap,provProfileDn,'orclStatus','objectclass=orclODIPProvisioningIntegrationProfileV2');
   if (provStatus is null or provStatus<>'ENABLED')
   then
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
        then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'provStatus is null or provStatus<>ENABLED' );
        end if;

        r.appsToOiD.enabled := false;
        r.oidToApps.enabled := false;
   else
        -- OID->Apps
        provStatus := getAttribute(ldap,'cn=OIDToApplication,'||provProfileDn,'orclStatus');
        if (provStatus is null or provStatus<>'ENABLED')
        then

            if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
            then
                fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'OIDToApplication provStatus is null or provStatus<>ENABLED' );
            end if;

            r.oidToApps.enabled := false;
        else
            r.oidToApps := parse_ops(ldap, 'cn=OIDToApplication,'||provProfileDn, 'orclodipprovisioningeventsubscription');
        end if;
         -- Apps->OiD
        provStatus := getAttribute(ldap,'cn=ApplicationToOID,'||provProfileDn,'orclStatus');
        if (provStatus is null or provStatus<>'ENABLED')
        then
            if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
            then
                 fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'ApplicationToOID provStatus is null or provStatus<>ENABLED' );
            end if;
            r.appsToOiD.enabled := false;
        else
           r.appsToOiD := parse_ops(ldap, 'cn=ApplicationToOID,'||provProfileDn, 'orclodipprovisioningeventpermittedoperations');
        end if;
   end if;
   fnd_ldap_util.c_unbind(ldap,flag);
   l_session_flag := false;
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag : = false ' );
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION CLOSED NORMALLY : ' );
   end if;
   r.loaded := true;
   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'END');
   end if;
exception
  when others then
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
end load_realm;


/*
** Name      : load_realm
** Type      : Private
** Desc      : Given a DN , try to load realm definitions, if it succeed then add is to the cache.
** Parameters  :
**       r : realm. The filed r.dn is used to start
**       dn : OiD Entry
**       attrName: attributeName - multivalued
** Exceptions: DBMS_LDAP exceptions,
**              NO_DATA_FOUND : if the dn is not at realm.
**
*/

function add_realm(dn in varchar2) return pls_integer
is
i pls_integer ;
r realm_type;
  begin
    i:= realm_table.count;
    r.dn := dn;
    r.seq := i;
    r.guid :=null;
    load_realm(r);
    if (r.loaded) then
        realm_table(i):=r;
    end if;
    return i;
end add_realm;

FUNCTION isSon
  (son    IN VARCHAR2,
   parent IN VARCHAR2)
  RETURN BOOLEAN
                                 IS
  l1 dbms_ldap.string_collection := dbms_ldap.explode_dn(upper(son),0);
  l2 dbms_ldap.string_collection := dbms_ldap.explode_dn(upper(parent),0);
  d pls_integer;
  i pls_integer;
BEGIN

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, G_MODULE_SOURCE||'.isSon: ', 'Son ' || son || 'Parent ' || parent);
  end if;

  d       := l1.count         - l2.count;
  i       := l1.count         -1;
  WHILE (i>=d) AND (l1(i)=l2(i-d))
  LOOP
    i:= i-1;
  END LOOP;
  RETURN (i<d);
END isSon;

function getUserRealmIndex(dn in varchar2)
   return pls_integer
is
  searchBase dbms_ldap.string_collection;
BEGIN

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, G_MODULE_SOURCE||'.getUserRealmIndex ', 'dn: ' ||dn);
  end if;

  for r in realm_table.first .. realm_table.last loop
      begin
      searchBase := getRealmSearchBaseList(r);
      for i in searchBase.first .. searchBase.last loop
          if (isSon(dn,searchBase(i))) then
              if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
              then
                  fnd_log.string(fnd_log.LEVEL_STATEMENT, G_MODULE_SOURCE||'.getUserRealmIndex: ', 'isSon dn ' || dn || 'searchBase(i) ' || searchBase(i));
              end if;
             return r;
          end if;
      end loop;
      EXCEPTION WHEN OTHERS THEN NULL;
      END;
  end loop;
  return -1;
END getUserRealmIndex;

function getRealmSearchBaseList( realm_idx in pls_integer ) return dbms_ldap.string_collection
is

emptyCollection dbms_ldap.string_collection;
ret dbms_ldap.string_collection;
dn varchar2(4000);
BEGIN

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, G_MODULE_SOURCE||'.getRealmSearchBaseList: ', 'Begin - realm_idx ' || realm_idx );
  end if;

  if (realm_idx>=0) THEN
  -- 19904770 - NOT NEEDED?
    dn := realm_table(realm_idx).ldap_data.dn;
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, G_MODULE_SOURCE||'.getRealmSearchBaseList: ', 'dn ' || dn );
    end if;
    ret:= realm_table(realm_idx).ldap_data.data('orclcommonusersearchbase');
    return ret;
  else
    return emptyCollection;
  END IF;
END getRealmSearchBaseList;


function find_realm_index(dn in varchar2) return pls_integer
is
i pls_integer ;
begin
  if (realm_table.count>0) then
   for i in realm_table.first .. realm_table.last loop
      if (realm_table(i).dn = dn) then
        return i;
      end if;
   end loop;
  end if;
  return -1;
end find_realm_index;

/*
** Name      : find_realm
** Type      : Private
** Desc      : Given a DN , returns its index in the cache realm_table.
**             If is not in the cache, will call add_realm.
** Parameters  :
**       dn : OiD Entry
** Exceptions: DBMS_LDAP exceptions,
**              NO_DATA_FOUND : if the dn is not at realm.
**
*/

function find_realm(dn in varchar2) return pls_integer
is
i pls_integer ;
begin
   i := find_realm_index(dn);
   if (i=-1) THEN
       return add_realm(dn);
   ELSE
      return i;
   END IF;
end find_realm;

function find_realm(idx in pls_integer) return varchar2
is

begin
  if (realm_table.exists(idx)) THEN
    return realm_table(idx).dn;
  ELSE
    return null;
  END IF;

end find_realm;

function get_realm_data ( realm_idx in pls_integer ) return FND_LDAP_UTIL.ldap_record_type
is
BEGIN
  if (realm_table.exists(realm_idx) ) then
     return realm_table(realm_idx).ldap_data;
  ELSE
     return null;
  END IF;
end get_realm_data;

function get_realm_attribute( realm_idx in pls_integer,
     attName in  varchar2, att_idx in pls_integer default 0  ) return varchar2
   is
   l FND_LDAP_UTIL.ldap_record_type;
BEGIN
   l := get_realm_data(realm_idx);
   if (l.data.exists(lower(attName))  ) THEN
          return l.data(lower(attName))(att_idx);

   END IF;
     return null;

END get_realm_attribute;

function get_realm_attribute( realmDN in varchar2,
     attName in  varchar2, att_idx in pls_integer default 0  ) return varchar2
   is
idx pls_integer;
BEGIN
   idx := find_realm_index(realmDN);
   return get_realm_attribute(idx,attName,att_idx);
END get_realm_attribute;

--
---------------------------------------------

/*
** Name      : requestedRealm
** Type      : Private
** Desc      : a user_name anda realm_dn (maybe both null) returns the realm to use
**     requestedRealm
*/
function requestedRealm(p_user_name in varchar2, p_realm_dn in varchar2) return varchar2
is
begin
  if (p_user_name is not null) then
      return fnd_oid_plug.getRealmDN(p_user_name);
  elsif (p_realm_dn is not null) then
      return p_realm_dn;
  else
      return fnd_oid_plug.get_default_realm;
  end if;
end requestedRealm;
--
----------------------------------------------------


/*
** Name      : check_operation
** Type      : Private
** Desc      : Old usage of is_operation_allowed, when no direction or entity is given.
*/

function check_operation( allowed_op in out nocopy permited_operation, op in   pls_integer )
   return pls_integer
is
res boolean;
l_module_source varchar2(4000):= G_MODULE_SOURCE||'check_operation';
BEGIN

  res := false;
  if allowed_op.enabled then
     case op
     WHEN fnd_ldap_wrapper.G_CREATE THEN res:= (allowed_op.identity_add is not null ) and (allowed_op.subscription_add is not null) ;
     WHEN fnd_ldap_wrapper.G_UPDATE THEN res:= (allowed_op.identity_update is not null ) and (allowed_op.subscription_update is not null) ;
     WHEN fnd_ldap_wrapper.G_MODIFY THEN res:= (allowed_op.identity_update is not null ) and (allowed_op.subscription_update is not null) ;
     WHEN fnd_ldap_wrapper.G_DELETE THEN res:= (allowed_op.identity_delete is not null ) and (allowed_op.subscription_delete  is not null) ;
     ELSE

          if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
              fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'Invalid operation: op='||op);
              if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid opertaion fnd_ldap_wrapper.G_CREATE ='||fnd_ldap_wrapper.G_CREATE );
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid opertaion fnd_ldap_wrapper.G_UPDATE ='||fnd_ldap_wrapper.G_UPDATE );
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid opertaion fnd_ldap_wrapper.G_MODIFY ='||fnd_ldap_wrapper.G_MODIFY );
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid opertaion fnd_ldap_wrapper.G_DELETE ='||fnd_ldap_wrapper.G_DELETE );

              end if;
          end if;

          raise case_not_found;
     END CASE;

  END if;

 if res then
    return  fnd_ldap_util.G_SUCCESS;
 else
    return  fnd_ldap_util.G_FAILURE;
 end if;

END check_operation;
--
-------------------------------------------------------------------------------
function is_in_list( atr in varchar2, at_list in varchar2)
 return pls_integer
is
i pls_integer;
j pls_integer;
s varchar2(2000);
v_atr varchar2(4000);
v_at_list varchar2(4000);
is_present boolean := true;
l_module_source varchar2(4000);

begin
  l_module_source := G_MODULE_SOURCE||'is_in_list';

  if (at_list is null) then
     return fnd_ldap_util.G_FAILURE;
  end if;

  if (at_list = '*') then
     return fnd_ldap_util.G_SUCCESS;
  end if;

  -- Bug 8657894 - lowering attributes to ensure no case sensitivity
  v_atr     := lower(atr);
  v_at_list := lower(at_list);

  i:= 1;
  j:= instr(v_atr,',');
  if (j=0) then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'One attribute passed: '||v_atr);
     end if;
  -- Bug 8764215 - return success when an attribute is found, else keep processing
  -- the rest of the attributes in the list.  Added additional logging.

      if (instr(v_at_list,v_atr) > 0) then
         return fnd_ldap_util.G_SUCCESS;
      else
          return fnd_ldap_util.G_FAILURE;
      end if;
  else
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Multiple attributes passed: '||v_atr);
     end if;

     s := substr(v_atr,i,j-i);
     loop
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Check for attribute '||s);
        end if;

    -- Bug 8764215 - looking for the attribute in the list.  May or may not be surrounded by commas
    -- return success once an attribute is found, else keep processing the rest of the attributes
    -- in the list.  Added additional logging.


       if (instr(','||v_at_list||',',','||s||',')>0) then
         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Attribute is in list '||s);
          end if;

          return fnd_ldap_util.G_SUCCESS;
          -- return fnd_ldap_util.G_FAILURE;
       else
          is_present := false;
       end if;
       exit when j =0;
       i:=j+1;
       j:=instr(v_atr,',',i);
       if (j=0) then
         s:= substr(v_atr,i);
       else
         s := substr(v_atr,i,j-i);
       end if;
     end loop;
  end if;
  if (is_present) then
      return fnd_ldap_util.G_SUCCESS;
  else
      return fnd_ldap_util.G_FAILURE;
  end if;
END is_in_list;
--
-------------------------------------------------------------------------------
procedure is_operation_allowed(p_operation in pls_integer,
                               x_fnd_user out nocopy pls_integer,
                               x_oid out nocopy pls_integer,
                               p_user_name in varchar2 default null,
                               p_realm_dn in varchar2 default null
                               ) is
l_module_source   varchar2(256);
l_realm_dn varchar2(4000);
l_index pls_integer;
begin
  l_module_source := G_MODULE_SOURCE || 'is_operation_allowed: ';
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  l_realm_dn := requestedRealm(p_user_name,p_realm_dn);
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'realm:'||l_realm_dn);
  end if;

  l_index := find_realm(l_realm_dn);

  x_fnd_user := check_operation(realm_table(l_index).appsToOiD,p_operation);
  x_oid := check_operation(realm_table(l_index).oidToApps,p_operation);


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'out values x_fnd_user: '||x_fnd_user||' x_oid: '||x_oid);
  end if;

 if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

exception when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
	fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
       raise;
end is_operation_allowed;

procedure is_operation_allowed(p_direction in pls_integer default FND_LDAP_WRAPPER.G_EBIZ_TO_OID,
			       p_entity in pls_integer,
			       p_operation in pls_integer,
			       p_attribute in out nocopy varchar2,
                               x_fnd_user out nocopy pls_integer,
                               x_oid out nocopy pls_integer  ,
                               p_user_name in varchar2 default null,
                               p_realm_dn in varchar2 default null) is
l_module_source   varchar2(256);
l_attr_present boolean := FALSE;
l_list varchar2(4000);
l_realm_dn varchar2(4000);
l_index pls_integer;
l_allowed permited_operation;
begin
  x_fnd_user :=fnd_ldap_util.G_SUCCESS;
  x_oid := fnd_ldap_util.G_FAILURE;
  l_module_source := G_MODULE_SOURCE || 'is_operation_allowed: ';
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  l_realm_dn := requestedRealm(p_user_name,p_realm_dn);
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'realm:'||l_realm_dn);
  end if;

  l_index := find_realm(l_realm_dn);
  CASE p_direction
  WHEN fnd_ldap_wrapper.G_EBIZ_TO_OID then l_allowed := realm_table(l_index).appsToOiD;
  WHEN fnd_ldap_wrapper.G_OID_TO_EBIZ then l_allowed := realm_table(l_index).OidToApps;
  ELSE
      if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
      then
          fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'Invalid direction:'||p_direction);
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
             fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid direction fnd_ldap_wrapper.G_EBIZ_TO_OID ='||fnd_ldap_wrapper.G_EBIZ_TO_OID );
             fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid opertaion fnd_ldap_wrapper.G_OID_TO_EBIZ ='||fnd_ldap_wrapper.G_OID_TO_EBIZ );
          end if;
       end if;
          raise case_not_found;
  END CASE;
  if (NOT l_allowed.enabled) then
       x_oid := fnd_ldap_util.G_FAILURE;
  else
    if(p_entity = fnd_ldap_wrapper.G_IDENTITY) THEN
          CASE p_operation
          WHEN fnd_ldap_wrapper.G_ADD    THEN l_list := l_allowed.identity_add;
          WHEN fnd_ldap_wrapper.G_UPDATE THEN l_list := l_allowed.identity_update;
          WHEN fnd_ldap_wrapper.G_MODIFY THEN l_list := l_allowed.identity_update;
          WHEN fnd_ldap_wrapper.G_DELETE THEN l_list := l_allowed.identity_delete;
          ELSE
          if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
              fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'Invalid operation:'||p_operation);
              if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid direction fnd_ldap_wrapper.G_ADD  ='||fnd_ldap_wrapper.G_ADD );
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid direction fnd_ldap_wrapper.G_UPDATE  ='||fnd_ldap_wrapper.G_UPDATE );
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid direction fnd_ldap_wrapper.G_MODIFY  ='||fnd_ldap_wrapper.G_MODIFY );
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid direction fnd_ldap_wrapper.G_DELETE  ='||fnd_ldap_wrapper.G_DELETE );
              end if;
          end if;

          raise case_not_found;
          END CASE;

    ELSIF (p_entity = fnd_ldap_wrapper.G_SUBSCRIPTION) THEN
          CASE p_operation
          WHEN fnd_ldap_wrapper.G_ADD    THEN l_list := l_allowed.subscription_add;
          WHEN fnd_ldap_wrapper.G_UPDATE THEN l_list := l_allowed.subscription_update;
          WHEN fnd_ldap_wrapper.G_MODIFY THEN l_list := l_allowed.subscription_update;
          WHEN fnd_ldap_wrapper.G_DELETE THEN l_list := l_allowed.subscription_delete;
          ELSE
         if (fnd_log.LEVEL_UNEXPECTED >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
          then
              fnd_log.string(fnd_log.LEVEL_UNEXPECTED, l_module_source, 'Invalid operation:'||p_operation);
              if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid direction fnd_ldap_wrapper.G_ADD  ='||fnd_ldap_wrapper.G_ADD );
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid direction fnd_ldap_wrapper.G_UPDATE  ='||fnd_ldap_wrapper.G_UPDATE );
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid direction fnd_ldap_wrapper.G_MODIFY  ='||fnd_ldap_wrapper.G_MODIFY );
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Valid direction fnd_ldap_wrapper.G_DELETE  ='||fnd_ldap_wrapper.G_DELETE );
              end if;
          end if;

          raise case_not_found;
        END CASE;

    ELSE
       raise case_not_found;
    END IF;
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Call is_in_list for: '||p_attribute);
      end if;
      x_oid := is_in_list(p_attribute, l_list);
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,
     'out values x_fnd_user: '||x_fnd_user||' x_oid: '||x_oid);
  end if;


 if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
 end if;

exception when others then
    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
        fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
    end if;
        raise;
end is_operation_allowed;


procedure get_user_or_site_profile (  profile_name in varchar2 ,
   user_name_z in varchar2 default null ,
   val_z out nocopy varchar2 ,
   defined_z out nocopy boolean )
is
l_done boolean;
l_user_id FND_USER.USER_ID%TYPE;
BEGIN
  val_z:= null;
  defined_z := false;
  if (profile_name is null ) then
    return;
  end if;

 if (user_name_z is not null) then
  BEGIN
     SELECT USER_ID into l_user_id from FND_USER
        WHERE user_name=user_name_z;
      EXCEPTION WHEN NO_DATA_FOUND THEN
         l_user_id := -1;
     END;
 else
    l_user_id := -1;
 end if;

     fnd_profile.GET_SPECIFIC(
         NAME_Z => upper(profile_name),
         USER_ID_Z => l_user_id,
         RESPONSIBILITY_ID_Z => -1,
         APPLICATION_ID_Z => -1,
         VAL_Z=>val_z,
         DEFINED_Z=>defined_z,
         ORG_ID_Z=>-1,
         SERVER_ID_Z =>-1);

END get_user_or_site_profile;

function getGuidRealm(l_guid  FND_USER.user_guid%type) return varchar2
IS
ldap dbms_ldap.session;
realm_idx pls_integer;
dn varchar2(4000);
flag  pls_integer;
l_module_source varchar2(1000);
l_session_flag boolean := false;
/*
realm varchar2(4000);
*/
BEGIN
  l_module_source := G_MODULE_SOURCE || 'getGuidRealm: ';
  ldap := fnd_ldap_util.c_get_oid_session(flag);
  l_session_flag := true; /* fix for bug 8271359 */
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
   then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag = true ' );
   end if;

  dn := FND_LDAP_UTIL.get_dn_for_guid(l_guid,ldap);
  realm_idx := getUserRealmIndex(dn);

  -- Bug 8661715 Potential ldap leak
  fnd_ldap_util.c_unbind(ldap,flag);
  l_session_flag := false;
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag : = false ' );
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION CLOSED NORMALLY : ' );
   end if;

  return realm_table(realm_idx).dn;

EXCEPTION WHEN OTHERS THEN
    if (l_session_flag = true) then
      if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
          fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in EXCEPTION BLOCK - START ' );
      end if;

      fnd_ldap_util.c_unbind(ldap,flag);

    if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in EXCEPTION BLOCK - END ');
      end if;
    end if;
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'END -> EXCEPTION WHEN OTHERS');
    end if;
END getGuidRealm;




function getDefaultRealm(ldap in out nocopy dbms_ldap.session )
return varchar2
IS
flag pls_integer;
l_module_source varchar2(1000) ;
l_session_flag boolean := false;

BEGIN
  l_module_source := G_MODULE_SOURCE || 'getDefaultRealm - session: ';

  IF (defaultRealm_cache is null) THEN

     if (ldap is null) then
         ldap := fnd_ldap_util.c_get_oid_session(flag);
         l_session_flag := true;  /* fix for bug 8271359 */

         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
             fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag = true ' );
         end if;
     end if;

     defaultRealm_cache := fnd_ldap_util.getLDAPAttribute(ldap,'cn=Common,cn=Products,cn=OracleContext','OrclDefaultSubscriber');

     if (l_session_flag=true) then
       fnd_ldap_util.c_unbind(ldap,flag);
       l_session_flag := false;

       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag : = false ' );
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION CLOSED NORMALLY : ' );
       end if;
     end if;

  END IF;

  return defaultRealm_cache;

EXCEPTION WHEN OTHERS THEN
  if l_session_flag = true then
       if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
           fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in EXCEPTION BLOCK - START ' );
       end if;
     fnd_ldap_util.c_unbind(ldap,flag);

     if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in EXCEPTION BLOCK - END ');
     end if;
  end if;
   if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
       fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION WHEN OTHERS');
   end if;
  raise;
END getDefaultRealm;



function getDefaultRealm
return varchar2
IS
flag pls_integer;
ldap dbms_ldap.session;
l_module_source varchar2(1000) ;
l_session_flag boolean := false;

BEGIN
  l_module_source := G_MODULE_SOURCE || 'getDefaultRealm: ';

  IF (defaultRealm_cache is null) THEN
      ldap := fnd_ldap_util.c_get_oid_session(flag);
      l_session_flag := true;  /* fix for bug 8271359 */

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag = true ' );
      end if;

      defaultRealm_cache := getDefaultRealm(ldap);
      fnd_ldap_util.c_unbind(ldap,flag);
      l_session_flag := false;

      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'l_session_flag : = false ' );
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LDAP SESSION CLOSED NORMALLY : ' );
      end if;
  END IF;

  return defaultRealm_cache;
EXCEPTION WHEN OTHERS THEN
  if l_session_flag = true then
       if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)  then
           fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closing in EXCEPTION BLOCK - START ' );
       end if;
     fnd_ldap_util.c_unbind(ldap,flag);

     if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, 'LDAP SESSION closed in EXCEPTION BLOCK - END ');
     end if;
  end if;
   if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
       fnd_log.string(fnd_log.LEVEL_EXCEPTION, l_module_source, 'EXCEPTION WHEN OTHERS');
   end if;

   raise;

END getDefaultRealm;

-------------------------------------------------------------------------------
/*
** Name      : getLdapDirType
** Type      : Public, FND Internal
** Desc      : This function returns 'OUD' if the ldap server is OUD
**           : 'OID' otherwise
**           : Bug 19904770 : Support OUD please see also 20364313
** Pre-Reqs   :
** Parameters  :
** Notes      :
*/
function getLdapDirType return varchar2 IS

  l_module_source   varchar2(256);
  l_ldap_session dbms_ldap.session;
  l_attr_value varchar2(256);
  l_ldapdirtype varchar2(256);
  flag pls_integer;

begin

  l_module_source := G_MODULE_SOURCE || 'getLdapDirType: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

   -- Bug 22098300: Check preferences before going to LDAP to get dir type
   l_ldapdirtype := fnd_preference.get('#INTERNAL','OID_CONF','LDAP_DIR_TYPE');

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Value of preference: '||l_ldapdirtype);
  end if;


 if (l_ldapdirtype is null) then

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Value of preference is null - try to get from LDAP{');
    end if;


  l_ldap_session := fnd_ldap_util.c_get_oid_session(flag);

  l_attr_value := fnd_ldap_util.getLDAPAttribute(
           ldap => l_ldap_session,
           dn => ' ',
           attrName => 'vendorversion');

  if ((l_attr_value is not null) and
      (instr(ltrim(lower(l_attr_value)),'oracle unified directory')>0)) then
    l_ldapdirtype := 'OUD';
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LdapDirType: is ' || l_ldapdirtype);
  end if;

  fnd_ldap_util.c_unbind(l_ldap_session, flag);

 end if;

   if (l_ldapdirtype is null) then

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
    then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'LdapDirType is null so defaulting to OID ');
    end if;

     l_ldapdirtype := 'OID';
  end if;


  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return l_ldapdirtype;

exception
when others then
  if (fnd_log.LEVEL_ERROR >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_ERROR, l_module_source, sqlerrm);
  end if;
  raise;
end getLdapDirType;


---------------------------------------------------------------
-- The provisioning container DN
-- Bug 19904770 : Support OUD
---------------------------------------------------------------
function getLdapDirProv return varchar2 is

  l_module_source   varchar2(256);
  l_ldaptype varchar(256);
  l_ldapdirprov varchar(256);

begin

  l_module_source := G_MODULE_SOURCE || '.getLdapDirProv: ';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Begin');
  end if;

  l_ldaptype := getLdapDirType;

  if (l_ldaptype = 'OUD') then
    l_ldapdirprov := 'cn=Profiles,cn=Provisioning,cn=Directory Integration Platform,cn=Products,cn=OracleContext';
  else
    -- default OID
    l_ldapdirprov := 'cn=Provisioning Profiles, cn=Changelog Subscriber, cn=Oracle Internet Directory';
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Provisioning container is ' || l_ldapdirprov);
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL)
  then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'End');
  end if;

  return l_ldapdirprov;

end getLdapDirProv;


PROCEDURE init
is
realms dbms_ldap.string_collection;
r varchar2(4000);
i pls_integer;
BEGIN

 -- THE plug shoud tell us what Realms to load
   realms := FND_OID_PLUG.getrealmlist;
   r := realms.first;
   WHILE r is not null loop
       i:= add_realm(realms(0));
       r := realms.next(r);
   end loop;
END init;

BEGIN
   init();
end FND_SSO_REGISTRATION;

/
