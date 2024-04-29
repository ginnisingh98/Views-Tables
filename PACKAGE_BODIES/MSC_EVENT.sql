--------------------------------------------------------
--  DDL for Package Body MSC_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_EVENT" as
/* $Header: MSCEVNTB.pls 120.1 2005/07/05 12:36:32 vpillari noship $ */

function user_name_changed ( p_subscription_guid in     raw
                           , p_event             in out nocopy wf_event_t
                           ) return varchar2 is
  cursor dblink is
  select trim(a2m_dblink)
  from   mrp_ap_apps_instances;
  db     varchar2(2000);
  updsql varchar2(32000);
  key    varchar2(401);
  newVal varchar2(200);
  oldVal varchar2(200);

begin
  log('start');
  open   dblink;
  fetch  dblink into db;
  close  dblink;
  key    := p_event.getEventKey();
  newVal := substr(key,1,instr(key,':')-1);
  oldVal := substr(key,instr(key,':')+1);
  if db is not null then
    updsql := 'update msc_planners'||'@'||db;
  else
    updsql := 'update msc_planners ';
  end if;
  updsql := updsql||' set user_name = '''||newVal||
            ''' where '||' user_name = '''||oldVal||'''';
  execute immediate updsql;
  log('after update ');
  return SUCCESS;
exception
  when others then
    return ( handleError ( PKG_NAME
                         , 'user_name_changed'
                         , p_event
                         , p_subscription_guid
                         , ERROR
                         ));

end user_name_changed;

function handleError     ( p_pkg_name          in     varchar2
                         , p_function_name     in     varchar2
                         , p_event             in out nocopy wf_event_t
                         , p_subscription_guid in     raw
                         , p_error_type        in     varchar2
                         ) return varchar2 is

  l_error_type varchar2(100);

begin
  if p_error_type in (ERROR,WARNING) then
    l_error_type := p_error_type;
  else
    l_error_type := p_error_type;
  end if;
  if l_error_type = WARNING then
     wf_core.context ( p_pkg_name
                     , p_function_name
                     , p_event.getEventName()
                     , p_subscription_guid
                     );
     wf_event.setErrorInfo (p_event, WARNING);
     return WARNING;
  else
     wf_core.context ( p_pkg_name
                     , p_function_name
                     , p_event.getEventName()
                     , p_subscription_guid
                     );
     wf_event.setErrorInfo (p_event, ERROR);
     return ERROR;
  end if;
end handleError;


procedure log (msg in varchar2) is
begin
  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level ) then
    fnd_log.string ( fnd_log.level_statement
                   , PKG_NAME
                   , msg
                   );
  end if;
end log;

end msc_event;

/
