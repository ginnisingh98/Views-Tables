--------------------------------------------------------
--  DDL for Package Body HR_API_WF_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_API_WF_EVENTS" as
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $ */
g_package  varchar2(33) := '  hr_api_wf_events.';
--
function get_entity(p_package_name varchar2)
return varchar2 is
  l_entity varchar2(80);
begin
  l_entity:=lower(substrb(p_package_name,instrb(p_package_name,'_')+1
    ,instrb(p_package_name,'_',-1)-instrb(p_package_name,'_')-1));
  return l_entity;
end get_entity;
--
function get_event_name(p_package_name varchar2
                       ,p_procedure varchar2)
return varchar2 is

  l_product varchar2(7);
  l_3lc varchar2(3);
  l_entity varchar2(80);
  l_event varchar2(240);
begin
  l_event:='oracle.apps.';
  l_3lc:=lower(substrb(p_package_name,1,3));
  if (l_3lc='hr_') then
    l_product:='per';
  elsif (l_3lc='irc') then
    l_product:='per.irc';
  else
    l_product:=l_3lc;
  end if;

  l_event:=l_event||l_product||'.api.';
  l_entity:=get_entity(p_package_name);
  l_event:=l_event||l_entity||'.'||lower(substrb(p_procedure
  ,1,instrb(p_procedure,'_',-1)-1));
  return  l_event;
end get_event_name;
--
function get_package_name(p_package_name varchar2)
return varchar2 is
  l_package_name varchar2(80);
  l_underscore_position number;
begin
  l_underscore_position:=instrb(p_package_name,'_',-1);
  l_package_name:=lower(substrb(p_package_name,1,l_underscore_position))||'be'
  ||substrb(p_package_name,l_underscore_position+3);
  return l_package_name;
end get_package_name;
--
procedure create_business_event_code(p_hook_package varchar2) is
l_header dbms_sql.varchar2s;
l_body dbms_sql.varchar2s;
i number:=0;
j number:=0;
l_overload       dbms_describe.number_table;
l_position       dbms_describe.number_table;
l_level          dbms_describe.number_table;
l_argument_name  dbms_describe.varchar2_table;
l_datatype       dbms_describe.number_table;
l_default_value  dbms_describe.number_table;
l_in_out         dbms_describe.number_table;
l_length         dbms_describe.number_table;
l_precision      dbms_describe.number_table;
l_scale          dbms_describe.number_table;
l_radix          dbms_describe.number_table;
l_spare          dbms_describe.number_table;
l_package_name varchar2(80);
l_proc_name varchar2(80);
l_entity varchar2(80);
l_dt_flag number :=0;
l_dt_argument_name varchar2(30);
k number;
  --
  -- Cursor to select all the procedure names in a given hook package
  --
  cursor csr_procs is
    select ahk.hook_procedure
         , ahk.api_hook_type
         , ahk.api_hook_id
         , ahk.legislation_package
         , ahk.legislation_function
         , amd.module_name
         , amd.data_within_business_group
      from hr_api_modules  amd
         , hr_api_hooks    ahk
     where amd.api_module_id = ahk.api_module_id
       and ahk.hook_package  = p_hook_package
       and amd.api_module_type='BP'
       and ahk.api_hook_type='AP';
  --
  l_proc                varchar2(72) := g_package||'create_business_event_code';
  l_datatype_str varchar2(80);
  l_csr_sql integer;
  l_rows    number;
--
-- add body line adds a line to the body text with
-- a carriage return on the end
--
  procedure add_body_line(text varchar2) is
  begin
    l_body(j):=text||'
';
    j:=j+1;
  end;
--
-- add header line adds a line to the header text
-- with a carriage return on the end
--
  procedure add_header_line(text varchar2) is
  begin
    l_header(i):=text||'
';
    i:=i+1;
  end;
--
begin
  -- get the new package name
  l_package_name:=get_package_name(p_hook_package);
  -- create the package  header lines
  add_header_line('create or replace package '||l_package_name||' as ');
  add_body_line('create or replace package body '||l_package_name||' as ');
  add_header_line('--Code generated on '||to_char(sysdate,'DD/MM/YYYY HH:MI:SS'));
  add_header_line('/'||'* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*'||'/');
  add_body_line('--Code generated on '||to_char(sysdate,'DD/MM/YYYY HH:MI:SS'));
  add_body_line('/'||'* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*'||'/');
  -- loop over all of the procedures in the package
  for proc_rec in csr_procs loop
    --
    -- get a description of the procedure
    --
    l_dt_flag :=0;
    l_dt_argument_name := NULL;
    --
    hr_general.describe_procedure
    (object_name  => p_hook_package||'.'||proc_rec.hook_procedure
    ,reserved1    => ''
    ,reserved2    => ''
    ,overload     => l_overload
    ,position     => l_position
    ,level        => l_level
    ,argument_name=> l_argument_name
    ,datatype     => l_datatype
    ,default_value=> l_default_value
    ,in_out       => l_in_out
    ,length       => l_length
    ,precision    => l_precision
    ,scale        => l_scale
    ,radix        => l_radix
    ,spare        => l_spare);
    --
    l_proc_name:=lower(proc_rec.hook_procedure);
    -- add the procedure name line
    add_header_line('procedure '||l_proc_name||' (');
    add_body_line('procedure '||l_proc_name||' (');
    -- loop over all of the parameters in the package, writing
    -- them in to the procedure definition
    for k in l_argument_name.first .. l_argument_name.last loop
      --
      if l_datatype(k) = 1 then
        l_datatype_str := 'varchar2';
      elsif l_datatype(k) = 2 then
        l_datatype_str := 'number';
      elsif l_datatype(k) = 12 then
        l_datatype_str := 'date';
      elsif l_datatype(k) = 252 then
        l_datatype_str := 'boolean';
      elsif l_datatype(k) = 8 then
        l_datatype_str := 'long';
      else
        l_datatype_str := 'ERROR'||l_datatype_str;
      end if;
      --
      if lower(l_argument_name(k)) like '%effective_start_date' then
          l_dt_flag := 1;
          l_dt_argument_name := lower(l_argument_name(k));
      end if;
      add_header_line(rpad(lower(l_argument_name(k)),30)||' '||l_datatype_str||',');
      add_body_line(rpad(lower(l_argument_name(k)),30)||' '||l_datatype_str||',');
    end loop;
    -- remove the last comma and end the parameter list
    l_header(i-1):=rtrim(l_header(i-1),',
')||');
';
    l_body(j-1):=rtrim(l_body(j-1),',
')||') is
';
    -- write out the variables
    add_body_line('  l_event_key number;');
    add_body_line('  l_event_data clob;');
    add_body_line('  l_event_name varchar2(250);');
    add_body_line('  l_text varchar2(2000);');  --2753722
    add_body_line('  l_message varchar2(10);');
    add_body_line('  --');
    add_body_line('  cursor get_seq is');
    add_body_line('  select per_wf_events_s.nextval from dual;');
    add_body_line('  --');
    add_body_line('  l_proc varchar2(72):=''  '||l_package_name||'.'
   ||l_proc_name||''';');
    add_body_line('begin');
    add_body_line('  hr_utility.set_location(''Entering: ''||l_proc,10);');
    -- generate the event name
    add_body_line('  -- check the status of the business event');
    add_body_line('  l_event_name:='''||get_event_name(p_package_name=>l_package_name
   ,p_procedure=>l_proc_name)||''';');
    -- add the logic to call the business event
    add_body_line('  l_message:=wf_event.test(l_event_name);');
    add_body_line('  --');
    add_body_line('  if (l_message=''MESSAGE'') then');
    add_body_line('    hr_utility.set_location(l_proc,20);');
    add_body_line('    --');
    add_body_line('    -- get a key for the event');
    add_body_line('    --');
    add_body_line('    open get_seq;');
    add_body_line('    fetch get_seq into l_event_key;');
    add_body_line('    close get_seq;');
    add_body_line('    --');
    add_body_line('    -- build the xml data for the event');
    add_body_line('    --');
    -- build the XML to send with the message
    add_body_line('    dbms_lob.createTemporary(l_event_data,false,dbms_lob.call);');
    add_body_line('    l_text:=''<?xml version =''''1.0'''' encoding =''''ASCII''''?>'';');
    add_body_line('    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);');
    l_entity:=get_entity(p_package_name=>l_package_name);
    add_body_line('    l_text:=''<'||l_entity||'>'';');
    add_body_line('    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);');
    add_body_line('    --');
    -- loop over all of the parameters, building up the xml
    for k in l_argument_name.first .. l_argument_name.last loop
      --
      add_body_line('    l_text:=''<'||lower(substrb(l_argument_name(k),3))||'>'';');
      if l_datatype(k) = 2 then
        add_body_line('    l_text:=l_text||fnd_number.number_to_canonical('||lower(l_argument_name(k))||');');
      elsif l_datatype(k) = 12 then
        add_body_line('    l_text:=l_text||fnd_date.date_to_canonical('||lower(l_argument_name(k))||');');
      elsif l_datatype(k) = 252 then
        add_body_line('if('||l_argument_name(k)||') then');
        add_body_line('l_text:=l_text||''TRUE'';');
        add_body_line('else');
        add_body_line('l_text:=l_text||''FALSE'';');
        add_body_line('end if;');
      else
        add_body_line('    l_text:=l_text||irc_utilities_pkg.removeTags('||lower(l_argument_name(k))||');');
      end if;
      add_body_line('    l_text:=l_text||''</'||lower(substrb(l_argument_name(k),3))||'>'';');
      add_body_line('    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);');
      end loop;
    add_body_line('    l_text:=''</'||l_entity||'>'';');
    add_body_line('    --');
    add_body_line('    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);');
    add_body_line('    --');
    if (l_dt_flag = 1) then
        add_body_line('    if ' || l_dt_argument_name || ' is not NULL and');
        add_body_line('       ' || l_dt_argument_name || ' > trunc(SYSDATE) and');
        add_body_line('        fnd_profile.value(''HR_DEFER_FD_BE_EVENTS'') = ''Y'' then ');
        add_body_line('       -- raise the event with the event data, with send date set to effective date');
        add_body_line('       wf_event.raise(p_event_name=>l_event_name');
        add_body_line('                     ,p_event_key=>l_event_key');
        add_body_line('                     ,p_event_data=>l_event_data');
        add_body_line('                     ,p_send_date => ' || l_dt_argument_name || ');');
        add_body_line('        --');
        add_body_line('    else ');
        add_body_line('       -- raise the event with the event data');
        add_body_line('       wf_event.raise(p_event_name=>l_event_name');
        add_body_line('                     ,p_event_key=>l_event_key');
        add_body_line('                     ,p_event_data=>l_event_data);');
        add_body_line('    end if;');
    else
        add_body_line('    -- raise the event with the event data');
        add_body_line('    wf_event.raise(p_event_name=>l_event_name');
        add_body_line('                  ,p_event_key=>l_event_key');
        add_body_line('                  ,p_event_data=>l_event_data);');
    end if;

    -- add the rest of the logic for the non MESSAGE events
    add_body_line('  elsif (l_message=''KEY'') then');
    add_body_line('    hr_utility.set_location(l_proc,30);');
    add_body_line('    -- get a key for the event');
    add_body_line('    open get_seq;');
    add_body_line('    fetch get_seq into l_event_key;');
    add_body_line('    close get_seq;');
    if (l_dt_flag =1) then
        add_body_line('    if ' || l_dt_argument_name || ' is not NULL and');
        add_body_line('       ' || l_dt_argument_name || ' > trunc(SYSDATE) and');
        add_body_line('        fnd_profile.value(''HR_DEFER_FD_BE_EVENTS'') = ''Y'' then ');
        add_body_line('       -- this is a key event, so just raise the event');
        add_body_line('       -- without the event data, with send date set to effective date');
        add_body_line('       wf_event.raise(p_event_name=>l_event_name');
        add_body_line('                     ,p_event_key=>l_event_key');
        add_body_line('                     ,p_send_date => ' || l_dt_argument_name || ');');
        add_body_line('       --');
        add_body_line('    else');
        add_body_line('       -- this is a key event, so just raise the event');
        add_body_line('       -- without the event data');
        add_body_line('       wf_event.raise(p_event_name=>l_event_name');
        add_body_line('                     ,p_event_key=>l_event_key);');

        add_body_line('    end if;');
    else
        add_body_line('    -- this is a key event, so just raise the event');
        add_body_line('    -- without the event data');
        add_body_line('    wf_event.raise(p_event_name=>l_event_name');
        add_body_line('                  ,p_event_key=>l_event_key);');
    end if;
    add_body_line('  elsif (l_message=''NONE'') then');
    add_body_line('    hr_utility.set_location(l_proc,40);');
    add_body_line('    -- no event is required, so do nothing');
    add_body_line('    null;');
    add_body_line('  end if;');
    add_body_line('    hr_utility.set_location(''Leaving: ''||l_proc,50);');
    -- close off the procedure
    add_body_line('end '||l_proc_name||';');
  end loop;
  -- close off the packages
  add_body_line('end '||l_package_name||';');
  add_header_line('end '||l_package_name||';');
  -- build the neader
  l_csr_sql := dbms_sql.open_cursor;
  dbms_sql.parse( l_csr_sql, l_header,0,i-1,FALSE, dbms_sql.v7 );
  l_rows := dbms_sql.execute( l_csr_sql );
  dbms_sql.close_cursor( l_csr_sql );
--  for k in 0..j loop
--    dbms_output.put_line(l_body(k));
--  end loop;
  -- build the body
  l_csr_sql := dbms_sql.open_cursor;
  dbms_sql.parse( l_csr_sql, l_body,0,j-1,FALSE, dbms_sql.v7 );
  l_rows := dbms_sql.execute( l_csr_sql );
  dbms_sql.close_cursor( l_csr_sql );
end create_business_event_code;
--
procedure subscribe_business_event_code(p_hook_package varchar2
                                       ,p_regenerate   boolean) is
--
  cursor csr_api_hook is
    select ahm.api_module_id
         , ahk.api_hook_id
         , ahk.hook_procedure
      from hr_api_hooks   ahk
         , hr_api_modules ahm
     where ahk.hook_package    = p_hook_package
       and ahk.api_module_id   = ahm.api_module_id
       and ahm.api_module_type='BP'
       and ahk.api_hook_type='AP';
  --
  -- Declare local variables
  --
  l_object_version_number  number;
  l_api_hook_call_id       number;
  --
  l_package_name varchar2(80);

begin
  --
  l_package_name:=get_package_name(p_package_name=>p_hook_package);
  for hooks_rec in csr_api_hook loop
    --
    -- subscribe the procedure to the api hook
    --
    hr_app_api_hook_call_internal.create_app_api_hook_call
      (p_validate              => false
      ,p_effective_date        => to_date('2001/04/02', 'YYYY/MM/DD')
      ,p_api_hook_id           => hooks_rec.api_hook_id
      ,p_api_hook_call_type    => 'PP'
      ,p_sequence              => 1499
      ,p_application_id        => 800
      ,p_app_install_status    => 'I_OR_S'
      ,p_enabled_flag          => 'Y'
      ,p_call_package          => l_package_name
      ,p_call_procedure        => hooks_rec.hook_procedure
      ,p_api_hook_call_id      => l_api_hook_call_id
      ,p_object_version_number => l_object_version_number
      );
    if p_regenerate then
      --
      -- Re-create the user hook package bodies for
      -- the row handler API module
      --
      hr_api_user_hooks_utility.create_hooks_add_report(hooks_rec.api_module_id);
    end if;
  end loop;
end subscribe_business_event_code;
--
procedure register_business_event(p_hook_package varchar2) is
--
  cursor csr_api_hook is
    select ahk.hook_procedure
    from hr_api_hooks   ahk
    where ahk.hook_package    = p_hook_package
    and ahk.api_hook_type='AP';
  --
  cursor event_exists(p_event_name varchar2) is
    select GUID,STATUS
    from wf_events
    where name=p_event_name;
  --
  cursor appl_name(p_application_short_name varchar2) is
  select application_name
  from fnd_application_vl
  where application_short_name=p_application_short_name;
  --
  -- Declare local variables
  --
  --
  l_package_name varchar2(80);
  l_event_name varchar2(240);
  l_xml varchar2(32000);
  l_guid varchar2(250);
  l_name varchar2(250);
  l_product_code varchar2(30);
  l_application_name fnd_application_tl.application_name%type;
  l_status wf_events.status%type;
  --
begin
  --
  l_package_name:=get_package_name(p_package_name=>p_hook_package);
  l_product_code:=upper(substr(p_hook_package,1,3));
  if l_product_code='HR_' then
    l_product_code:='PER';
  end if;
  --
  open appl_name(l_product_code);
  fetch appl_name into l_application_name;
  close appl_name;
  --
  for hooks_rec in csr_api_hook loop
    l_event_name:=get_event_name(p_package_name=>p_hook_package
    ,p_procedure=>hooks_rec.hook_procedure);
    l_name:=nls_initcap(
      replace(
        substrb(hooks_rec.hook_procedure,1
         ,instrb(hooks_rec.hook_procedure,'_',-1)-1
        )
      ,'_',' ')
    );
    open event_exists(l_event_name);
    fetch event_exists into l_guid,l_status;
    if event_exists%found then
      close event_exists;
    l_xml:=
'<WF_TABLE_DATA>
  <WF_EVENTS>
    <VERSION>1.0</VERSION>
    <GUID>'||l_guid||'</GUID>';
    l_xml:=l_xml||'
    <NAME>'||l_event_name||'</NAME>';
    l_xml:=l_xml||'
    <TYPE>EVENT</TYPE>
    <STATUS>'||l_status||'</STATUS>
    <GENERATE_FUNCTION/>
    <OWNER_NAME>'||l_application_name||'</OWNER_NAME>
    <OWNER_TAG>'||l_product_code||'</OWNER_TAG>';
    l_xml:=l_xml||'
    <DISPLAY_NAME>'||l_name
    ||'</DISPLAY_NAME>';
    l_xml:=l_xml||'
    <DESCRIPTION>'||l_name
    ||' API</DESCRIPTION>';
    l_xml:=l_xml||'
  </WF_EVENTS>
</WF_TABLE_DATA>';
    else
      close event_exists;
    l_xml:=
'<WF_TABLE_DATA>
  <WF_EVENTS>
    <VERSION>1.0</VERSION>
    <GUID>#NEW</GUID>';
    l_xml:=l_xml||'
    <NAME>'||l_event_name||'</NAME>';
    l_xml:=l_xml||'
    <TYPE>EVENT</TYPE>
    <STATUS>DISABLED</STATUS>
    <GENERATE_FUNCTION/>
    <OWNER_NAME>'||l_application_name||'</OWNER_NAME>
    <OWNER_TAG>'||l_product_code||'</OWNER_TAG>';
    l_xml:=l_xml||'
    <DISPLAY_NAME>'||l_name
    ||'</DISPLAY_NAME>';
    l_xml:=l_xml||'
    <DESCRIPTION>'||l_name
    ||' API</DESCRIPTION>';
    l_xml:=l_xml||'
  </WF_EVENTS>
</WF_TABLE_DATA>';
    end if;
    wf_events_pkg.receive(l_xml);
  end loop;
end register_business_event;
--
procedure add_event(p_hook_package varchar2
                   ,p_regenerate   boolean) is
begin
  create_business_event_code(p_hook_package);
  subscribe_business_event_code(p_hook_package,p_regenerate);
  --
  -- Business Event registrations are now delivered as wfx files
  -- with irep annotations.
  --
  --register_business_event(p_hook_package);
  --
end add_event;
--
procedure add_events_for_api(p_api_package varchar2
                            ,p_regenerate  boolean) is
cursor get_hooks is
select distinct ah.hook_package
from hr_api_modules am
,    hr_api_hooks ah
where am.api_module_id=ah.api_module_id
and am.module_package=p_api_package
and am.api_module_type='BP'
and ah.api_hook_type='AP';
begin
  for hook_rec in get_hooks loop
    add_event(p_hook_package=>hook_rec.hook_package
             ,p_regenerate  =>p_regenerate);
  end loop;
end add_events_for_api;
--
function default_rule(p_subscription_guid in RAW,
                      p_event in out nocopy wf_event_t)
  return varchar2
is
begin
  select per_wf_events_s.nextval into p_event.Correlation_ID from dual;
  return WF_RULE.DEFAULT_RULE(p_subscription_guid, p_event);
end;
--
end hr_api_wf_events;

/
