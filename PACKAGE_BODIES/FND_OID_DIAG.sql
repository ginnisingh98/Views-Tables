--------------------------------------------------------
--  DDL for Package Body FND_OID_DIAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OID_DIAG" as
/* $Header: AFSCODIB.pls 120.11.12010000.1 2008/07/25 14:21:12 appldev ship $ */
--
-------------------------------------------------------------------------------
  is_dbms_ldap_available boolean :=false;
  is_oid_enabled boolean :=false;
  ldapSession dbms_ldap.session;
  errNumber number := 1;
  helpNumber number := 1;
  currentMethod varchar2(256);
  statusStr varchar2(50);
  errStr varchar2(4000);
  fixInfo varchar2(4000);
  isFatal varchar2(50);
  --oidAdmin varchar2(256);
  --oidPwd varchar2(256);
  orclAppName varchar2(256);
  orclDefaultSubscriber varchar2(256);
  eBusContainer varchar2(256);
  svcContainer varchar2(256);
  appGuid varchar2(256);
  realmGuid varchar2(256);
  orclodipprofileinterfacename varchar2(256);
  orclodipprofileinterfacetype varchar2(256);
  orclodipprovisioningappname varchar2(256);
  orclodipprofileinterfaceci varchar2(256);
  orclodipprofileschedule varchar2(256);
  orclserviceinstancelocation varchar2(1000);
  orclservicesublocation varchar2(1000);
  orclstatus varchar2(256);
  tableOpen boolean := false;
  procedure getOrclApp(p_app in out nocopy varchar2);
--
-------------------------------------------------------------------------------
procedure eventsTest;
procedure subscriptionsTest;
procedure passwordTest;
procedure identityRealmTest;
procedure containerTest;
procedure svcContainerTest;
procedure appGuidTest;
procedure realmGuidTest;
procedure provisionTest;
procedure oidToAppTest;
procedure appToOIDTest;
procedure dasTest;
procedure oidSubsTest;
procedure linkTest;
procedure usersTest;
procedure dasSearchTest(dasName in varchar2);
function checkEvent(eventName in varchar2) return varchar2;
function checkSub(subName in varchar2) return varchar2;
function getApp return varchar2;
procedure printAttr(ldapentry in dbms_ldap.message, attrName in varchar2);
procedure beginTable(title in varchar2, colspan in pls_integer default 2);
procedure endTable;
procedure insertRow(text in varchar2);
procedure insertColumn(text in varchar2);
procedure beginRow;
procedure endRow;
function constructErr(str in varchar2) return varchar2;
function constructHelp(str in varchar2) return varchar2;
--
-------------------------------------------------------------------------------
procedure init is

report jtf_diag_report;
reportClob clob;
result pls_integer;

begin
  currentMethod := 'init';
  statusStr := 'SUCCESS';
  errStr := '@html';
  fixInfo := '@html';
  isFatal := 'FALSE';
  errStr := errStr || '<html><body><ol>';
  fixInfo := fixInfo || '<html><body><ol>';

  /* Now this is part of the test
  ldapSession := fnd_oid_util.get_oid_session;
  orclAppName := fnd_preference.get(p_user_name => '#INTERNAL',
                                    p_module_name => 'LDAP_SYNCH',
                                    p_pref_name => 'USERNAME');
  getOrclApp(orclAppName);
  */

exception
when no_data_found then
  statusStr := 'FAILURE';
  errStr := constructErr('Oracle Application Common Name not found in Workflow Preferences');
  fixInfo := constructHelp('Oracle Application Common Name must be registered in Workflow Preferences');
  isFatal := 'FALSE';
  report := jtf_diagnostic_adaptutil.constructReport(statusStr,
                                      errStr, fixInfo, isFatal);
  reportClob := jtf_diagnostic_adaptutil.getReportClob;
when others then
  statusStr := 'FAILURE';
  errStr := constructErr(sqlerrm || ' occured in ' || currentMethod);
  fixInfo := constructHelp('Contact System Adminstrator');
  isFatal := 'FALSE';
  report := jtf_diagnostic_adaptutil.constructReport(statusStr,
                                      errStr, fixInfo, isFatal);
  reportClob := jtf_diagnostic_adaptutil.getReportClob;
end init;
--
-------------------------------------------------------------------------------
procedure getDefaultTestParams(defaultInputValues out nocopy jtf_diag_inputtbl) is
begin
  currentMethod := 'getDefaultTestParams';
end getDefaultTestParams;
--
-------------------------------------------------------------------------------
procedure cleanup is

report jtf_diag_report;
reportClob clob;
result pls_integer;

begin
  currentMethod := 'cleanup';
  result := fnd_oid_util.unbind(ldapSession);

exception
when others then
  statusStr := 'FAILURE';
  errStr := constructErr(sqlerrm || ' occured in ' || currentMethod);
  fixInfo := constructHelp('Contact System Adminstrator');
  isFatal := 'FALSE';
  report := jtf_diagnostic_adaptutil.constructReport(statusStr,
                                      errStr, fixInfo, isFatal);
  reportClob := jtf_diagnostic_adaptutil.getReportClob;

end cleanup;
--
-------------------------------------------------------------------------------
procedure getComponentName(compName out nocopy varchar2) is
begin
  currentMethod := 'getComponentName';
  compName := 'OID Setup Tests';
end getComponentName;
--
-------------------------------------------------------------------------------
procedure getTestDesc(descStr out nocopy varchar2) is
begin
  currentMethod := 'getTestDesc';
  descStr := 'Tests OID setup';
end getTestDesc;
--
-------------------------------------------------------------------------------
procedure getTestName(testName out nocopy varchar2) is
begin
  currentMethod := 'getTestName';
  testName := 'OID Setup Test';
end getTestName;
--
-------------------------------------------------------------------------------
function getTestMode return integer is
begin
  currentMethod := 'getTestMode';
  return jtf_diagnostic_adaptutil.BOTH_MODE;
end getTestMode;
--
-------------------------------------------------------------------------------
procedure dbms_ldap_test is
  context number := 1;
  schema  varchar2(30);
  part1   varchar2(30);
  part2   varchar2(30);
  dblink  varchar2(128);
  part1_type number;
  object_number number;
 trace_level pls_integer;
begin
  currentMethod := 'dbms_ldap_test';
  is_dbms_ldap_available := false;
  beginTable('DBMS_LDAP test');
  begin
	  dbms_utility.name_resolve('dbms_ldap', context, schema,part1, part2, dblink, part1_type, object_number);

          if (schema<>'SYS' OR part1<>'DBMS_LDAP' OR part1_type<>9 )
	  then
                   statusStr := 'FAILURE';
                   errStr := constructErr('DBMS_LDAP resolves to '||schema||'.'||'DBMS_LDAP and not to PACKAGE SYS.DBMS_LDAP');
                   fixInfo := constructHelp('Check DBA_OBJECTS, if it is necesary recreate it Section 5, on Note 233436.1');
                   isFatal := 'TRUE';
                   insertRow('DBMS_LDAP resolves to '||schema||'.'||'DBMS_LDAP and not to PACKAGE SYS.DBMS_LDAP');
		   endTable;
		   return;

	  end if;

	  exception
	    when others then
	      case when sqlcode = -6564 then
                   statusStr := 'FAILURE';
                   errStr := constructErr('Package DBMS_LDAP is not accessible');
                   fixInfo := constructHelp('See Section 5, on Note 233436.1');
                   isFatal := 'TRUE';
                   insertRow('Package DBMS_LDAP is not accessible');
		   endTable;
		   return;
	      else
                   statusStr := 'FAILURE';
                   errStr := constructErr('Error '||sqlerrm||'(' || sqlcode || ') during dbms_ldap validation');
                   fixInfo := constructHelp('Try to recreate the packaeg as  on Note 233436.1');
                   isFatal := 'TRUE';
                   insertRow('Error '||sqlerrm||'(' || sqlcode || ') during dbms_ldap validation');
		   endTable;
		   return;
	      end case;
  end;
  -- being there doesn't mean it's working
  -- For example, dbms_ldap depends on  dbms_random, remove the last one, and dbms_ldap becomes invalid
	  begin
	      trace_level := dbms_ldap.get_trace_level;
	      exception when others then
                   statusStr := 'FAILURE';
                   errStr := constructErr('Error '||sqlerrm||'(' || sqlcode || ') durint dbms_ldap validation');
                   fixInfo := constructHelp('Try to recreate the packaeg as  on Note 233436.1');
                   isFatal := 'TRUE';
                   insertRow('Error '||sqlerrm||'(' || sqlcode || ') durint dbms_ldap validation');
		   endTable;
		   return;
	  end;
	  is_dbms_ldap_available:=true;
	  insertRow(' SYS.DBMS_LDAP is available');
	  endTable;
end dbms_ldap_test;
--
-------------------------------------------------------------------------------
procedure profile_test
is
 sso varchar2(100);
 sync varchar2(100);
 defined boolean;
begin
  currentMethod := 'profile_test';
  is_oid_enabled:=false;
  beginTable('Profiles ');
  fnd_profile.get_specific('APPS_SSO',-1,null,null,sso,defined,null,null);
  if (not defined) then
          statusStr := 'FAILURE';
          errStr := constructErr('APPS_SSO is not defined ');
          fixInfo := constructHelp('!');
          isFatal := 'TRUE';
          insertRow('APPS_SSO is not defined ');
          endTable;
	  return;
   end if;
  fnd_profile.get_specific('APPS_SSO_LDAP_SYNC',-1,null,null,sync,defined,null,null);
  if (not defined) then
          statusStr := 'FAILURE';
          errStr := constructErr('APPS_SSO_LDAP_SYNC is not defined ');
          fixInfo := constructHelp('!');
          isFatal := 'TRUE';
          insertRow('APPS_SSO_LDAP_SYNC is not defined ');
          endTable;
	  return;
   end if;
   insertRow(' APPS_SSO= '||sso);
   insertRow(' APPS_SSO_LDAP_SYNC= '||sync);
   if ( sync ='Y')
   then
   	is_oid_enabled:= true;
	insertRow('OiD synchronization is enabled');
   else
        is_oid_enabled:=false;
	insertRow('OiD synchronization is NOT enabled');
   end if ;
   endTable;
   return;



end profile_test;
--
-------------------------------------------------------------------------------
procedure preference_test
is
  host  varchar2(100);
  port  varchar2(100);
  pwd  varchar2(100);
begin
    currentMethod := 'preference_test';
    ldapSession := null;
    orclAppName := fnd_preference.get(p_user_name => '#INTERNAL', p_module_name => 'LDAP_SYNCH', p_pref_name => 'USERNAME');
    pwd :=fnd_preference.eget('#INTERNAL','LDAP_SYNCH', 'EPWD', 'LDAP_PWD');
    host := fnd_preference.get('#INTERNAL', 'LDAP_SYNCH', 'HOST');
    port := fnd_preference.get('#INTERNAL', 'LDAP_SYNCH', 'PORT');
    beginTable('OiD connect parameters ');
    if (orclAppName is null) then
	insertRow('AppDN is null');
        statusStr := 'FAILURE';
        errStr := constructErr('AppDN is not defined');
        fixInfo := constructHelp('Run the registration utilitity');
        isFatal := 'TRUE';
   else
    	insertRow(' AppDn: '||orclAppName);
    end if;
    if (pwd is null)
    then
	insertRow('Password  is null');
        statusStr := 'FAILURE';
        errStr := constructErr('AppDN password is not defined');
        fixInfo := constructHelp('Run the registration utilitity');
        isFatal := 'TRUE';
    end if;

    if (host is null)
    then
	insertRow('OiD host   is null');
        statusStr := 'FAILURE';
        errStr := constructErr('OiD host is not defined');
        fixInfo := constructHelp('Run the registration utilitity');
        isFatal := 'TRUE';
    else
	insertRow('OiD host: '||host);
    end if;
    if (port is null)
    then
	insertRow('OiD port   is null');
        statusStr := 'FAILURE';
        errStr := constructErr('OiD port is not defined');
        fixInfo := constructHelp('Run the registration utilitity');
        isFatal := 'TRUE';
    else
	insertRow('OiD port: '||port);
    end if;
    getOrclApp(orclAppName);
     begin
	     ldapSession := fnd_oid_util.get_oid_session;
     exception
        when others then
	insertRow('Failed to connect to OiD ');
        statusStr := 'FAILURE';
        errStr := constructErr('Error connecting to OiD '||sqlcode|| ' ' ||sqlerrm);
        fixInfo := constructHelp('Run the registration utilitity');
        isFatal := 'TRUE';
	ldapSession := null;
     end;


end preference_test;
--
-------------------------------------------------------------------------------
procedure runtest(inputs in jtf_diag_inputtbl,
		              report out nocopy jtf_diag_report,
		              reportClob out nocopy clob) is

begin
  currentMethod := 'runtest';
  jtf_diagnostic_adaptutil.setUpVars;
  jtf_diagnostic_adaptutil.addStringToReport('@html');
  jtf_diagnostic_coreapi.insert_style_sheet;
  --oidAdmin := jtf_diagnostic_adaptutil.getInputValue('OIDPWD', inputs);
  --oidPwd := jtf_diagnostic_adaptutil.getInputValue('OIDPWD', inputs);

  profile_test;
  if (not is_oid_enabled) then
     jtf_diagnostic_adaptutil.addStringToReport('No additional test executed');

  else
      dbms_ldap_test;
      if (is_dbms_ldap_available) then
	  preference_test;

	  if (ldapSession is not null) then
              /* Check whether the workflow events are enabled */
              eventsTest;

              /* Check whether the workflow event subscriptions are enabled */
              subscriptionsTest;

              /* Not required:  Validate the password in Workflow and OID match */
              -- passwordTest;

              /* Check the Identity Realm in OID matches the one used by workflow */
              identityRealmTest;

              /* Check Oracle Application Common Name in OID matches the one workflow searches */
              containerTest;

              /* Validate the Service Container has been created under the correct realm */
              svcContainerTest;

              /* Validate the Global UID for this application exists in OID */
              appGuidTest;

              /* Validate the Global UID for identity management realm exists in OID */
              realmGuidTest;

              /* Get the Provisional profile details from OID */
               provisionTest;

              /* Determine whether Provisioning has been configured for OID to EBusiness */
              oidToAppTest;

              /* Determine whether Provisioning has been configured for EBusiness to OID */
              appToOIDTest;

              /* Check EBusiness is a member of all the DAS's */
              --dasTest;

              /* Check Subscriptions have been created in OID */
              oidSubsTest;

              /* Check Service Instance is correctly linked to the Subscription Instance in OID */
              linkTest;

              usersTest;
	 else
           jtf_diagnostic_adaptutil.addStringToReport('Cannot connect to OiD, test terminated');
	 end if;
     else
        jtf_diagnostic_adaptutil.addStringToReport('Cannot continue testing, DBMS_LDAP is not available');
     end if;
  end if;

  if (tableOpen) then
    endTable;
  end if;
  if (statusStr = 'SUCCESS') then
    jtf_diagnostic_adaptutil.addStringToReport('Test completed successfully<br>');
  elsif (statusStr = 'WARNING') then
    jtf_diagnostic_adaptutil.addStringToReport('Test succeeded with warnings<br>');
  else
    jtf_diagnostic_adaptutil.addStringToReport('Test failed<br>');
  end if;

  errStr := errStr || '</ol></body></html>';
  fixInfo := fixInfo || '</ol></body></html>';
  report := jtf_diagnostic_adaptutil.constructReport(statusStr,
                                      errStr, fixInfo, isFatal);
  reportClob := jtf_diagnostic_adaptutil.getReportClob;

exception
when others then
  --jtf_diagnostic_coreapi.errorprint('Error: '||sqlerrm);
  --jtf_diagnostic_coreapi.ActionErrorPrint('Contact System Adminstrator');
  if (tableOpen) then
    endTable;
  end if;
  jtf_diagnostic_adaptutil.addStringToReport('Test failed<br>');
  statusStr := 'FAILURE';
  errStr := constructErr(sqlerrm || ' occured in ' || currentMethod);
  fixInfo := constructHelp('Contact System Adminstrator');
  errStr := errStr || '</ol></body></html>';
  fixInfo := fixInfo || '</ol></body></html>';
  isFatal := 'FALSE';
  report := jtf_diagnostic_adaptutil.constructReport(statusStr,
                                      errStr, fixInfo, isFatal);
  reportClob := jtf_diagnostic_adaptutil.getReportClob;
end runtest;
--
-------------------------------------------------------------------------------
procedure eventsTest is

  TYPE EventsList IS TABLE OF VARCHAR2(50);
  events EventsList;
  event varchar2(100);
  l_status varchar2(10);
  i pls_integer;

begin
  currentMethod := 'eventsTest';

  beginTable('Business Events');
  insertRow('<TR><TH>Event</TH><TH>Status</TH></TR>');
 -- SEE fndoidsynce.wfx
  events := EventsList('oracle.apps.fnd.identity.add','ENABLED',
                       'oracle.apps.fnd.identity.delete','ENABLED',
                       'oracle.apps.fnd.identity.modify','ENABLED',
                       'oracle.apps.fnd.oidsync.error','ENABLED',
                       'oracle.apps.fnd.oidsync.resend','ENABLED',
                       'oracle.apps.fnd.ondemand.create','ENABLED',
                       'oracle.apps.fnd.subscription.add','ENABLED',
                       'oracle.apps.fnd.subscription.delete','ENABLED',
                       'oracle.apps.global.user.change','ENABLED');

  i:=1;
  while (i<events.count) loop
    event := events(i);
      beginRow;
      insertColumn(event);
    l_status := checkEvent(event);
    if (l_status <> events(i+1) ) then
      insertColumn(l_status||' <em> Incorrect </em>');
      statusStr := 'FAILURE';
      errStr :=  constructErr(event || ' is '||l_status);
      fixInfo := constructHelp(event || ' should be '||events(i+1));
      isFatal := 'FALSE';
    else
      insertColumn(l_status);
    end if;
      endRow;
    i:=i+2;
  end loop;

  endTable;
exception
when no_data_found then
  statusStr := 'FAILURE';
  errStr :=  constructErr(event || ' is not created');
  fixInfo := constructHelp(event || ' should be created');
  isFatal := 'FALSE';

end eventsTest;
--
-------------------------------------------------------------------------------
procedure subscriptionsTest is

  TYPE SubList IS TABLE OF VARCHAR2(50);
  subs SubList;
  l_subscription varchar2(100);
  l_event varchar2(100);
  l_status varchar2(10);
  i pls_integer;

  CURSOR c1(sub VARCHAR2) is

    select s.status, e.name
    from wf_events e, wf_event_subscriptions s
    where rule_function = sub and
    s.event_filter_guid = e.guid;

begin
  currentMethod := 'subscriptionsTest';

  beginTable('Business Event Subscriptions', 3);
-- see fndoidsyncs.wfx
    jtf_diagnostic_adaptutil.addStringToReport('<tr> <TH>Subscription</TH> <TH>Event</TH> <TH>Status</TH>');
  subs := SubList('fnd_oid_subscriptions.assign_def_resp',
                  'fnd_oid_subscriptions.event_error',
                  'fnd_oid_subscriptions.event_resend',
                  'fnd_oid_subscriptions.hz_identity_add',
                  'fnd_oid_subscriptions.hz_identity_delete',
                  'fnd_oid_subscriptions.hz_identity_modify',
                  'fnd_oid_subscriptions.hz_subscription_add',
                  'fnd_oid_subscriptions.hz_subscription_delete',
                  'fnd_oid_subscriptions.identity_add',
                  'fnd_oid_subscriptions.identity_delete',
                  'fnd_oid_subscriptions.identity_modify',
                  'fnd_oid_subscriptions.on_demand_user_create',
                  'fnd_oid_subscriptions.subscription_add',
                  'fnd_oid_subscriptions.subscription_delete',
                  'fnd_user_pkg.user_change');

  i:= 1;
  while (i<subs.count) loop
    l_subscription := subs(i);
    jtf_diagnostic_adaptutil.addStringToReport('<tr><td colspan=3 align=left>'|| subs(i)||'</td><tr>');

    open c1(l_subscription);
    loop

      fetch c1 into l_status, l_event;
      if (c1%ROWCOUNT = 0  ) then
        jtf_diagnostic_adaptutil.addStringToReport('<tr><td></td><td colspan=2> MISSING <em>INCORRECT</em></td><tr>');
        statusStr := 'FAILURE';
        errStr :=  constructErr(l_subscription ||  ' is not created');
        fixInfo := constructHelp(l_subscription || ' should be created');
        isFatal := 'FALSE';
      end if;
      exit when c1%NOTFOUND;

      jtf_diagnostic_adaptutil.addStringToReport('<tr><td></td><td>'||l_event||'</td><td>'||l_status);
    end loop;
    close c1;
    i:=i+2;

  end loop;

  endTable;
end subscriptionsTest;
--
-------------------------------------------------------------------------------
procedure passwordTest is

appsPwd varchar2(50);
result pls_integer;

begin
  currentMethod := 'passwordTest';
  select fnd_preference.eget('#INTERNAL','LDAP_SYNCH', 'EPWD', 'LDAP_PWD')
  into appsPwd
  from dual;

  result := dbms_ldap.compare_s(ld => ldapSession, dn => orclAppName,
                                attr => 'userpassword', value => appsPwd);

  if (result = dbms_ldap.COMPARE_FALSE) then
    statusStr := 'FAILURE';
    errStr :=  constructErr('Passwords do not match');
    fixInfo := constructHelp('TThe Application password in E-Business Suite matches the one registered in OID');
    isFatal := 'FALSE';
  else
    beginTable('The password registered in E-Business Workflow is the same password defined in OID for this application ');
    endTable;
  end if;

exception
when others then
  statusStr := 'FAILURE';
  errStr :=  constructErr('Password not registered with Workflow Global Preferences');
  fixInfo := constructHelp('Password must be registered with Workflow Global Preferences');
  isFatal := 'FALSE';

end passwordTest;
--
-------------------------------------------------------------------------------
procedure identityRealmTest is

result pls_integer;
l_message dbms_ldap.message := null;
l_entry dbms_ldap.message := null;
l_attrs dbms_ldap.string_collection;

begin
  currentMethod := 'identityRealmTest';

  result := dbms_ldap.search_s(ld => ldapSession, base => 'cn=Common,cn=Products,cn=OracleContext', scope => dbms_ldap.SCOPE_BASE,
  filter => 'objectclass=*', attrs => l_attrs, attronly => 0, res => l_message);

  -- get the first entry
  l_entry := dbms_ldap.first_entry(ldapSession, l_message);
  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'orcldefaultsubscriber');

  orclDefaultSubscriber := l_attrs(0);

  if instr(orclAppName, orclDefaultSubscriber) = 0 then
    statusStr := 'FAILURE';
    errStr := constructErr('Oracle Application Common Name does not contain ' || orclDefaultSubscriber);
    fixInfo := constructHelp('Oracle Application Common Name  should contain ' || orclDefaultSubscriber);
    isFatal := 'FALSE';
  else
    beginTable('The Identity Management Realm in OID matches the one registered in E-Business Suite');
    insertRow(orclDefaultSubscriber);
    endTable;
  end if;

exception
when others then
  statusStr := 'FAILURE';
  errStr :=  constructErr('Identity Management Realm could not be found');
  fixInfo := constructHelp('Identity Management Realm should be registered');
  isFatal := 'FALSE';

end identityRealmTest;
--
-------------------------------------------------------------------------------
procedure containerTest is

l_base varchar2(256);
l_dn varchar2(256);
result pls_integer;
success pls_integer;
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;
l_dn_norm varchar2(256);
l_orclAppName_norm varchar2(256);
l_result1 pls_integer;
l_result2 pls_integer;

begin
  currentMethod := 'containerTest';
  success := 0;
  l_base := 'cn=EBusiness,cn=Products,cn=OracleContext,' || orclDefaultSubscriber;

  result := dbms_ldap.search_s(ld => ldapSession, base => l_base,
  scope => dbms_ldap.SCOPE_ONELEVEL, filter => 'objectclass=*', attrs => l_attrs, attronly => 0, res => l_message);

  -- get the first entry

  l_entry := dbms_ldap.first_entry(ldapSession, l_message);

  while l_entry is not null loop
    l_dn := dbms_ldap.get_dn(ldapSession, l_entry);
    l_result1 := dbms_ldap_utl.normalize_dn_with_case(l_dn, 1, l_dn_norm);
    l_result2 := dbms_ldap_utl.normalize_dn_with_case(orclAppName, 1, l_orclAppName_norm);
    if ((l_dn_norm = l_orclAppName_norm) AND (l_result1 = DBMS_LDAP_UTL.SUCCESS) AND (l_result2 = DBMS_LDAP_UTL.SUCCESS)) then
      success := 1;
    end if;
    l_entry := dbms_ldap.next_entry(ldapSession, l_entry);
  end loop;

  if success = 0 then
    statusStr := 'FAILURE';
    errStr := constructErr('Application container is not created properly');
    fixInfo := constructHelp('Application container should be created properly');
    isFatal := 'FALSE';
  else
    beginTable('Oracle Application Common Name (orclApplCommonName) in E-Business Suite matches the one registered in OID');
    insertRow(orclAppName);
    endTable;
  end if;

exception
when others then
    statusStr := 'FAILURE';
    errStr := constructErr('Application container is not created properly');
    fixInfo := constructHelp('Application container should be created properly');
    isFatal := 'FALSE';
end containerTest;
--
-------------------------------------------------------------------------------
procedure svcContainerTest is

l_base varchar2(256);
result pls_integer;
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;

begin
  currentMethod := 'svcContainerTest';
  l_base := 'cn=Services, cn=OracleContext';

  result := dbms_ldap.search_s(ld => ldapSession, base => l_base,
  scope => dbms_ldap.SCOPE_ONELEVEL, filter => 'cn=EBusiness', attrs => l_attrs, attronly => 0, res => l_message);

  l_entry := dbms_ldap.first_entry(ldapSession, l_message);
  svcContainer := dbms_ldap.get_dn(ldapSession, l_entry);

  beginTable('The Service Container is created under the correct Realm');
  insertRow(svcContainer);
  endTable;

exception
when no_data_found then
    statusStr := 'FAILURE';
    errStr := constructErr('Service container is not created properly');
    fixInfo := constructHelp('Register the instance again');
    isFatal := 'FALSE';
end svcContainerTest;
--
-------------------------------------------------------------------------------
procedure appGuidTest is

result pls_integer;
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;

begin
  currentMethod := 'appGuidTest';

  l_attrs(0) := 'orclguid';

  result := dbms_ldap.search_s(ld => ldapSession, base => orclAppName,
  scope => dbms_ldap.SCOPE_BASE, filter => 'objectclass=*', attrs => l_attrs, attronly => 0, res => l_message);

  -- get the first entry

  l_entry := dbms_ldap.first_entry(ldapSession, l_message);
  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'orclguid');

  appGuid := l_attrs(0);

  if l_attrs(0) is null then
    statusStr := 'FAILURE';
    errStr := constructErr('Global UID for this application not found');
    fixInfo := constructHelp('Global UID for this application should be registered');
    isFatal := 'FALSE';
  else
    beginTable('Application GUID');
    insertRow(appGuid);
    endTable;
  end if;

exception
when no_data_found then
    statusStr := 'FAILURE';
    errStr := constructErr('Global UID for this application not found');
    fixInfo := constructHelp('Global UID for this application should be registered');
    isFatal := 'FALSE';
end appGuidTest;
--
-------------------------------------------------------------------------------
procedure realmGuidTest is

result pls_integer;
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;

begin
  currentMethod := 'realmGuidTest';

  l_attrs(0) := 'orclguid';

  result := dbms_ldap.search_s(ld => ldapSession, base => orclDefaultSubscriber,
  scope => dbms_ldap.SCOPE_BASE, filter => 'objectclass=*', attrs => l_attrs, attronly => 0, res => l_message);

  -- get the first entry

  l_entry := dbms_ldap.first_entry(ldapSession, l_message);
  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'orclguid');

  realmGuid := l_attrs(0);

  if l_attrs(0) is null then
    statusStr := 'FAILURE';
    errStr := constructErr('Global UID for identity realm not found');
    fixInfo := constructHelp('Global UID for identity realm should be registered');
    isFatal := 'FALSE';
  else
    beginTable('Identity Management Realm GUID');
    insertRow(realmGuid);
    endTable;
  end if;

exception
when no_data_found then
    statusStr := 'FAILURE';
    errStr := constructErr('Global UID for identity realm not found');
    fixInfo := constructHelp('Global UID for identity realm should be registered');
    isFatal := 'FALSE';
end realmGuidTest;
--
-------------------------------------------------------------------------------
procedure provisionTest is

result pls_integer;
l_base varchar2(1000);
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;

begin
  currentMethod := 'provisionTest';

  l_base := 'orclODIPProfileName=' || realmGuid || '_' || appGuid || ',cn=Provisioning Profiles, cn=Changelog Subscriber, cn=Oracle Internet Directory';

  result := dbms_ldap.search_s(ld => ldapSession, base => l_base,
  scope => dbms_ldap.SCOPE_BASE, filter => 'objectclass=*', attrs => l_attrs, attronly => 0, res => l_message);

  -- get the first entry

  l_entry := dbms_ldap.first_entry(ldapSession, l_message);

  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'orclodipprofileinterfacename');
  orclodipprofileinterfacename := l_attrs(0);

  l_attrs := dbms_ldap.get_values(ldapSession, l_entry,'orclodipprofileinterfacetype');
  orclodipprofileinterfacetype := l_attrs(0);

  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'orclodipprovisioningappname');
  orclodipprovisioningappname := l_attrs(0);

--  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'orclodipprofileinterfaceconnectinformation');
--  orclodipprofileinterfaceci := l_attrs(0);

  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'orclodipprofileschedule');
  orclodipprofileschedule := l_attrs(0);

  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'orclstatus');
  orclstatus := l_attrs(0);

  if (orclodipprofileinterfacename is null) or  (orclodipprofileinterfacetype is null) or ( orclodipprovisioningappname is null) /*or (orclodipprofileinterfaceci is null)*/ or (orclodipprofileschedule is null) or (orclstatus is null)
  then
    statusStr := 'FAILURE';
    errStr := constructErr('Provisioning profile not found');
    fixInfo := constructHelp('Contact System Administrator');
    isFatal := 'FALSE';
  else
    beginTable('Provisioning Profile');
    insertRow('Profile Name = ' || l_base);
    insertRow('orclodipprofileinterfacename = ' || orclodipprofileinterfacename);
    insertRow('orclodipprofileinterfacetype = ' || orclodipprofileinterfacetype);
    insertRow('orclodipprovisioningappname = ' || orclodipprovisioningappname);
    --insertRow('orclodipprofileinterfaceconnectinformation = ' || orclodipprofileinterfaceci);
    insertRow('orclodipprofileschedule = ' || orclodipprofileschedule);
    insertRow('orclstatus = ' || orclstatus);
    endTable;
  end if;

exception
when others then
    statusStr := 'FAILURE';
    errStr := constructErr('Provisioning profile not found');
    fixInfo := constructHelp('Contact System Administrator');
    isFatal := 'FALSE';
end provisionTest;
--
-------------------------------------------------------------------------------
procedure oidToAppTest is

result pls_integer;
l_base varchar2(1000);
attrName varchar2(100);
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;
l_events dbms_ldap.string_collection;
l_status dbms_ldap.string_collection;
l_processingstatus dbms_ldap.string_collection;

begin
  currentMethod := 'oidToAppTest';

  l_base := 'cn=OIDTOApplication,orclODIPProfileName=' || realmGuid || '_' || appGuid || ',cn=Provisioning Profiles, cn=Changelog Subscriber, cn=Oracle Internet Directory';

  result := dbms_ldap.search_s(ld => ldapSession, base => l_base,
  scope => dbms_ldap.SCOPE_BASE, filter => 'objectclass=*', attrs => l_attrs, attronly => 0, res => l_message);

  -- get the first entry

  l_entry := dbms_ldap.first_entry(ldapSession, l_message);

  beginTable('Provisioning Profile Details for OID to Application');
  printAttr(l_entry, 'orclodipprovisioningeventsubscription');
  printAttr(l_entry, 'orclstatus');
  printAttr(l_entry, 'orclodipprofileprocessingstatus');
  endTable;

exception
when others then
    /*statusStr := 'FAILURE';
    errStr := constructErr('Provisioning profile not found');
    fixInfo := constructHelp('Contact System Administrator');
    isFatal := 'FALSE';*/
    beginTable('Provisioning Profile Details for OID to Application');
    insertRow('Provisioning profile not found for OID to Application');
    endTable;
end oidToAppTest;
--
-------------------------------------------------------------------------------
procedure appToOIDTest is

result pls_integer;
l_base varchar2(1000);
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;

begin
  currentMethod := 'ApplicationToOID';

  l_base := 'cn=ApplicationToOID,orclODIPProfileName=' || realmGuid || '_' || appGuid || ',cn=Provisioning Profiles, cn=Changelog Subscriber, cn=Oracle Internet Directory';

  result := dbms_ldap.search_s(ld => ldapSession, base => l_base,
  scope => dbms_ldap.SCOPE_BASE, filter => 'objectclass=*', attrs => l_attrs, attronly => 0, res => l_message);

  -- get the first entry

  l_entry := dbms_ldap.first_entry(ldapSession, l_message);

  beginTable('Provisioning Profile Details for Application to OID');
  printAttr(l_entry, 'orclodipprovisioningeventpermittedoperations');
  printAttr(l_entry, 'orclstatus');
  printAttr(l_entry, 'orclodipprofileprocessingstatus');
  endTable;

exception
when others then
/*    statusStr := 'FAILURE';
    errStr := constructErr('Provisioning profile not found');
    fixInfo := constructHelp('Contact System Administrator');
    isFatal := 'FALSE';*/
    beginTable('Provisioning Profile Details for Application to OID');
    insertRow('Provisioning profile not found for Application to OID');
    endTable;
end appToOIDTest;
--
-------------------------------------------------------------------------------
procedure dasTest is

TYPE DasList IS TABLE OF VARCHAR2(50);
dasNames DasList;

begin
  currentMethod := 'dasTest';

  beginTable('E-Business Suite is a member of the following Groups');

  dasNames := DasList('cn=OracleDASCreateUser', 'cn=OracleDASEditUser', 'cn=OracleDASCreateGroup', 'cn=OracleDASDeleteGroup','cn=OracleDASEditGroup');

  for i in 1..dasNames.count loop
    dasSearchTest(dasNames(i));
    insertRow(dasNames(i));
  end loop;

  endTable;

exception
when others then
  statusStr := 'FAILURE';
  errStr := constructErr('EBusiness is not a member of Oracle DAS');
  fixInfo := constructHelp('Contact System Administrator');    isFatal := 'FALSE';
end dasTest;
--
-------------------------------------------------------------------------------
procedure oidSubsTest is

result pls_integer;
l_base varchar2(1000);
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_dn varchar2(256);
l_attrs dbms_ldap.string_collection;


begin
  currentMethod := 'oidSubsTest';

  l_base := 'cn=subscriptions,' || orclAppName;

  result := dbms_ldap.search_s(ld => ldapSession, base => l_base,
  scope => dbms_ldap.SCOPE_ONELEVEL, filter => 'objectclass=*', attrs => l_attrs, attronly => 0, res => l_message);

  -- get the first entry

  l_entry := dbms_ldap.first_entry(ldapSession, l_message);
  beginTable('Application Subscription List Configuration');
  while l_entry is not null loop
    l_dn := dbms_ldap.get_dn(ldapSession, l_entry);
    insertRow(l_dn);
    l_entry := dbms_ldap.next_entry(ldapSession, l_entry);
  end loop;

  endTable;

exception
when others then
    statusStr := 'FAILURE';
    errStr := constructErr('Subscriptions not properly created in OID');
    fixInfo := constructHelp('Contact System Administrator');
    isFatal := 'FALSE';
end oidSubsTest;
--
-------------------------------------------------------------------------------
procedure linkTest is

result pls_integer;
l_base varchar2(1000);
l_app varchar2(256);
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;

begin
  currentMethod := 'linkTest';

  l_app := getApp;
  l_base := 'cn=' || l_app || ',' || svcContainer || ',' || orclDefaultSubscriber;

  result := dbms_ldap.search_s(ld => ldapSession, base => l_base,
  scope => dbms_ldap.SCOPE_BASE, filter => 'objectclass=*', attrs => l_attrs, attronly => 0, res => l_message);

  -- get the first entry

  l_entry := dbms_ldap.first_entry(ldapSession, l_message);
  beginTable('Service Instance is correctly linked to the Subscription Instance');
  insertRow('DN = ' || l_base);

  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'orclserviceinstancelocation');
  orclserviceinstancelocation := l_attrs(0);
  insertRow('orclserviceinstancelocation = ' || orclserviceinstancelocation);

  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'orclservicesubscriptionlocation');
  orclservicesublocation := l_attrs(0);
  insertRow('orclservicesubscriptionlocation = ' || orclservicesublocation);

  endTable;

-- if the entry exists with a different DN, don't fail
/*  if (orclserviceinstancelocation is null) or  (orclservicesublocation is null)
  then
    statusStr := 'FAILURE';
    errStr := constructErr('Could not obtain the Service Instance details');
    fixInfo := constructHelp('Contact System Administrator');
    isFatal := 'FALSE';
  end if;
*/

exception
when others then
-- if the entry exists with a different DN, don't fail
  null;
/*    statusStr := 'FAILURE';
    errStr := constructErr('Could not obtain the Service Instance details');
    fixInfo := constructHelp('Contact System Administrator');
    isFatal := 'FALSE';*/
end linkTest;
--
-------------------------------------------------------------------------------
procedure usersTest
is

l_base varchar2(1000);
result pls_integer;
success pls_integer;
numberOfUsers pls_integer;
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;

begin
  currentMethod := 'usersTest';
  success := 0;

  l_base := 'cn=ACCOUNTS,cn=subscription_data,cn=subscriptions,' || orclAppName;

  l_attrs(0) := 'uniquemember';

  result := dbms_ldap.search_s(ld => ldapSession, base => l_base,
  scope => dbms_ldap.SCOPE_BASE, filter => 'objectclass=*', attrs => l_attrs, attronly => 0, res => l_message);

  -- get the first entry

  l_entry := dbms_ldap.first_entry(ldapSession, l_message);
  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'uniquemember');

  if (l_attrs.count < 10) then
    numberOfUsers := l_attrs.count-1;
  else
    numberOfUsers := 9;
  end if;

  beginTable('Subscribed Users (partial list)');
  for i in 0..numberOfUsers loop
    --if instr(orclAppName, l_attrs(i)) <> 0 then
    --success := 1;
    insertRow(l_attrs(i));
    --end if;
  end loop;
  endTable;

end usersTest;
--
-------------------------------------------------------------------------------
procedure dasSearchTest(dasName in varchar2)
is

l_base varchar2(1000);
result pls_integer;
success pls_integer;
l_message dbms_ldap.message := NULL;
l_entry dbms_ldap.message := NULL;
l_attrs dbms_ldap.string_collection;

begin
  currentMethod := 'dasSearchTest';
  success := 0;

  l_base := dasName || ',cn=Groups,cn=OracleContext,' || orclDefaultSubscriber;
  l_attrs(0) := 'uniquemember';

  result := dbms_ldap.search_s(ld => ldapSession, base => l_base,
  scope => dbms_ldap.SCOPE_BASE, filter => 'objectclass=*', attrs => l_attrs, attronly => 0, res => l_message);

  -- get the first entry

  l_entry := dbms_ldap.first_entry(ldapSession, l_message);
  l_attrs := dbms_ldap.get_values(ldapSession, l_entry, 'uniquemember');

  for i in 0..l_attrs.count-1 loop
    if instr(orclAppName, l_attrs(i)) <> 0 then
      success := 1;
    end if;
  end loop;

  if success = 0 then
    statusStr := 'FAILURE';
    errStr := constructErr('EBusiness is not a member of Oracle DAS');
    fixInfo := constructHelp('Contact System Administrator');
    isFatal := 'FALSE';
  end if;

end dasSearchTest;
--
-------------------------------------------------------------------------------
function checkEvent(eventName in varchar2)
return varchar2 is

l_status varchar2(10);

begin
  select status into l_status
  from wf_events
  where name = eventName;

  return l_status;
 exception
   when no_data_found then
	return '<i>not present</i>';
end checkEvent;
--
-------------------------------------------------------------------------------
function checkSub(subName in varchar2)
return varchar2 is

l_status varchar2(10);

begin
  select status into l_status
  from wf_event_subscriptions
  where  source_type = 'LOCAL' and
  rule_function = subName;

  return l_status;
end checkSub;
--
-------------------------------------------------------------------------------
function getApp
return varchar2 is

l_app varchar2(256);
leftIndex pls_integer;
rightIndex pls_integer;

begin

  leftIndex := instr(orclAppName, '=') + 1;
  rightIndex := instr(orclAppName, ',');
  l_app := Substr(orclAppName, leftIndex, rightIndex-leftIndex);

  return l_app;
end getApp;
--
-------------------------------------------------------------------------------
procedure printAttr(ldapentry in dbms_ldap.message, attrName in varchar2) is

l_attrs dbms_ldap.string_collection;
l_attrvalue varchar2(1000);

begin

  l_attrs := dbms_ldap.get_values(ldapSession, ldapentry, attrName);

  for i in 0..l_attrs.count-1 loop
    l_attrvalue := l_attrs(i);
    insertRow(attrName || ' = ' || l_attrvalue);
  end loop;

exception
when no_data_found then
  insertRow(attrName);
  --jtf_diagnostic_adaptutil.addStringToReport(title || ': ' || '<br><br>');

end printAttr;
--
-------------------------------------------------------------------------------
function constructErr(str in varchar2)
return varchar2 is

l_str varchar2(4000);

begin
  l_str := errStr || '<li>' || str || '</li>';
  return l_str;
end constructErr;
--
-------------------------------------------------------------------------------
function constructHelp(str in varchar2)
return varchar2 is

l_str varchar2(4000);

begin
  l_str := fixInfo || '<li>' || str || '</li>';
  return l_str;
end constructHelp;
--
-------------------------------------------------------------------------------
procedure beginTable(title in varchar2, colspan in pls_integer default 2) is

html varchar2(4000);

begin
  if (tableOpen) then
    endTable;
  end if;
  html := '<TABLE width=70% border=1><TR><TD colspan=' || colspan || '><B>' || title || '</B></TD></TR>';
  jtf_diagnostic_adaptutil.addStringToReport(html);
  tableOpen := true;
end beginTable;
--
-------------------------------------------------------------------------------
procedure endTable is

html varchar2(4000);

begin
  html := '</TABLE><BR><BR><!------------------------------------------------------>';
  jtf_diagnostic_adaptutil.addStringToReport(html);
  tableOpen := false;
end endTable;
--
-------------------------------------------------------------------------------
procedure insertRow(text in varchar2) is

html varchar2(4000);

begin
  html := '<TR><TD>' || text || '<BR></TD></TR>';
  jtf_diagnostic_adaptutil.addStringToReport(html);
end insertRow;
--
-------------------------------------------------------------------------------
procedure insertColumn(text in varchar2) is

html varchar2(4000);

begin
  html := '<TD>' || text || '<BR></TD>';
  jtf_diagnostic_adaptutil.addStringToReport(html);
end insertColumn;
--
-------------------------------------------------------------------------------
procedure beginRow is

html varchar2(4000);

begin
  html := '<TR>';
  jtf_diagnostic_adaptutil.addStringToReport(html);
end beginRow;
--
-------------------------------------------------------------------------------
procedure endRow is

html varchar2(4000);

begin
  html := '</TR>';
  jtf_diagnostic_adaptutil.addStringToReport(html);
end endRow;
--
-------------------------------------------------------------------------------
procedure getOrclApp(p_app in out nocopy varchar2) is

quotesIndex pls_integer;
strLength pls_integer;

begin

  strLength := length(p_app);

  while instr(p_app, '"') <> 0 loop
    quotesIndex := instr(p_app, '"');
    p_app := Substr(p_app, 0, quotesIndex-1) || Substr(p_app, quotesIndex+1, strLength);
  end loop;

end getOrclApp;
--
-------------------------------------------------------------------------------

end fnd_oid_diag;


/
