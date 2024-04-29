--------------------------------------------------------
--  DDL for Package Body WF_EVENT_SYNCHRONIZE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_EVENT_SYNCHRONIZE_PKG" as
/* $Header: WFEVSYNB.pls 120.6.12010000.2 2017/01/03 16:01:54 rmajeed ship $ */
------------------------------------------------------------------------------
/*
** PRIVATE global variable
*/
-- g_begin_clob     varchar2(100) := '<oracle.apps.wf.event.all.sync>'||wf_core.newline;
g_begin_clob     varchar2(100) := '<oracle.apps.wf.event.all.sync>';
g_end_clob       varchar2(100) := '</oracle.apps.wf.event.all.sync>';
g_begin_string   varchar2(100) := '<WF_TABLE_DATA>';
g_end_string     varchar2(100) := '</WF_TABLE_DATA>';
g_system         varchar2(100) := '<WF_SYSTEMS>';
g_agent          varchar2(100) := '<WF_AGENTS>';
g_agent_group    varchar2(100) := '<WF_AGENT_GROUPS>';
g_event          varchar2(100) := '<WF_EVENTS>';
g_event_group    varchar2(100) := '<WF_EVENT_GROUPS>';
g_event_sub      varchar2(100) := '<WF_EVENT_SUBSCRIPTIONS>';
g_objecttype     varchar2(100);
g_qowner         varchar2(30);

------------------------------------------------------------------------------
function SYNCHRONIZE (
 P_SUBSCRIPTION_GUID    in      raw,
 P_EVENT                in out nocopy  wf_event_t
) return varchar2 is
/*
** Synchronize - Rule Function for Local Sync Event, return varchar2
**               Parameters:  p_Subscription_Guid
**                            p_Event
**
*/
l_clob   clob;
l_result varchar2(100);
begin

  dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);
  wf_event_synchronize_pkg.CreateSyncClob(p_eventdata => l_clob);

  p_event.SetEventData(l_clob);

  l_result := wf_rule.default_rule(p_subscription_guid, p_event);

  return (l_result);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'SYNCHRONIZE', p_event.event_name,
                                                    p_event.event_key,
                                                    'ERROR'); raise;
   return('ERROR');
end;
------------------------------------------------------------------------------
/*
** SynchronizeUpload   - Rule Function for External Sync Event, return varchar2
**                      Parameters:     p_Subscription_Guid
**                                      p_Event
**
*/
function SYNCHRONIZEUPLOAD (
 P_SUBSCRIPTION_GUID    in      raw,
 P_EVENT                in out nocopy  wf_event_t
) return varchar2 is

l_result varchar2(100);
begin

  wf_event_synchronize_pkg.uploadsyncclob(p_event.event_data);

  l_result := wf_rule.default_rule(p_subscription_guid, p_event);

  return (l_result);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'SYNCHRONIZEUPLOAD', p_event.event_name,
                                                    p_event.event_key,
                                                    'ERROR'); raise;
   return('ERROR');
end;
------------------------------------------------------------------------------
/*
** CreateSyncClob - Called by CreateFile or by Sync Event, returns CLOB
**                  Parameters: ObjectType <may be null>
**                              ObjectKey <may be null>
*/
procedure CREATESYNCCLOB (
 P_OBJECTTYPE  in  varchar2,
 P_OBJECTKEY   in  varchar2,
 P_ISEXACTNUM  in  integer,
 P_OWNERTAG    in  varchar2,
 P_EVENTDATA   out nocopy clob
) is

syncclob clob;
l_ObjectKey varchar2(100);
p_isexact       boolean;

begin
  g_objecttype := upper(p_objecttype);

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.CREATESYNCCLOB.Begin',
                      'Entered Create Sync Clob');
  end if;

  IF (p_isexactnum = 1) THEN
    p_isexact := true;
  ELSE
    p_isexact := false;
  END IF;

  IF p_ObjectKey IS NOT NULL THEN
    l_ObjectKey := '%'||p_ObjectKey||'%';
  END IF;

  dbms_lob.createtemporary(p_eventdata, FALSE, DBMS_LOB.CALL);

  dbms_lob.writeappend(p_eventdata, length(g_begin_clob), g_begin_clob);

  --
  -- Might have to change these to constants for MLS
  --
  -- Bug 2558446: Events, Subscriptions and Agents/Systems downloaded in separate
  -- Files.
  IF g_objecttype in ('SYSTEMS', 'AGENTS', 'AGENTGROUPS') THEN
-- Systems, Agents, Agent Groups in one file
    dbms_lob.append(p_eventdata,
                    wf_event_synchronize_pkg.GetSystems(l_ObjectKey));
    dbms_lob.append(p_eventdata,
                    wf_event_synchronize_pkg.GetAgents(l_ObjectKey,p_isexact));
    dbms_lob.append(p_eventdata,
                    wf_event_synchronize_pkg.GetAgentGroups(l_ObjectKey));
  ELSIF g_objecttype = 'EVENTS' THEN
-- Download event and event groups
    dbms_lob.append(p_eventdata,
                    wf_event_synchronize_pkg.GetEvents(l_ObjectKey, p_ownertag));

    dbms_lob.append(p_eventdata,
                    wf_event_synchronize_pkg.GetEventGroups(l_ObjectKey,p_ownertag));
  ELSIF g_objecttype = 'EVENT_GROUPS' THEN
-- Download event groups
    dbms_lob.append(p_eventdata,
                    wf_event_synchronize_pkg.GetGroups(l_ObjectKey, p_ownertag));

        -- EVENT_GROUPS option now downloads only GROUP type objects. Not members
    -- dbms_lob.append(p_eventdata,
    --                 wf_event_synchronize_pkg.GetEventGroupByGroup(l_ObjectKey,p_ownertag));
  ELSIF g_objecttype = 'SUBSCRIPTIONS' THEN
-- Download subscriptions in one file
    dbms_lob.append(p_eventdata,
                    wf_event_synchronize_pkg.GetSubscriptions(l_ObjectKey,p_isexact, p_ownertag));

  ELSE          -- including ALL

    dbms_lob.append(p_eventdata,
                        wf_event_synchronize_pkg.GetSystems(l_ObjectKey));
    dbms_lob.append(p_eventdata,
                        wf_event_synchronize_pkg.GetAgents(l_ObjectKey,p_isexact));
    dbms_lob.append(p_eventdata,
                        wf_event_synchronize_pkg.GetAgentGroups(l_ObjectKey));
    dbms_lob.append(p_eventdata,
                        wf_event_synchronize_pkg.GetEvents(l_ObjectKey, p_ownertag));
    dbms_lob.append(p_eventdata,
                        wf_event_synchronize_pkg.GetSubscriptions(l_ObjectKey,p_isexact, p_ownertag));
    dbms_lob.append(p_eventdata,
                        wf_event_synchronize_pkg.GetEventGroups(l_ObjectKey, p_ownertag));

  END IF;

  dbms_lob.writeappend(p_eventdata, length(g_end_clob), g_end_clob);

  --return (syncclob);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'CREATESYNCCLOB', g_objecttype,
                    p_ObjectKey ,null);
    raise;
end;
------------------------------------------------------------------------------
/*
** CreateFile - Called from SQL*Plus, creates Sync File
**              Parameters: Directory
**                          Filename
**                          ObjectType
**                          ObjectKey
**
*/
procedure CREATEFILE (
 P_DIRECTORY   in  varchar2,
 P_FILENAME    in  varchar2,
 P_OBJECTTYPE  in  varchar2,
 P_OBJECTKEY   in  varchar2,
 P_ISEXACT     in  boolean
) is

l_clob          clob;
l_clobsize      integer := 0;
l_isExactNum    integer := 1;

begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.CREATEFILE.Begin',
                      'Entered Create File');
  end if;

  if (p_isexact) then
    l_isExactNum := 1;
  else
    l_isExactNum := 0;
  end if;

  dbms_lob.createtemporary( l_clob, FALSE, DBMS_LOB.CALL);

  wf_event_synchronize_pkg.CreateSyncClob(p_ObjectType, p_ObjectKey, l_isExactNum, null, l_clob);

  if (dbms_lob.getlength(l_clob) = 0) then
    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.CREATEFILE.Clob_Size',
                        'l_clob null');
    end if;
  end if;

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.CREATEFILE.Create',
                      'Calling to CreateClob File');
  end if;

  wf_event_synchronize_pkg.CreateClobFile(p_Directory, p_Filename, l_clob);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'CREATEFILE', p_Directory||
                    '*'||p_Filename,p_ObjectType||'*'||p_ObjectKey ,null);
    raise;
end;
------------------------------------------------------------------------------
/*
** CreateClobFile - Given a Clob, we create a file
**                  Parameters: Directory Path
**                              Filename
**                              Clob
*/
procedure CREATECLOBFILE (
 P_DIRECTORY  in  varchar2,
 P_FILENAME   in  varchar2,
 P_CLOB       in  clob
) is

l_filehandle    UTL_FILE.FILE_TYPE;
l_clob          clob;

l_current_position      integer := 1;
l_amount_to_read        integer := 0;
l_messagedata           varchar2(32000);
l_length_end_string     integer := 16; -- Length of end tag
l_counter               integer := 0;
l_begin_position        integer := 0;
l_end_position          integer := 0;

begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      wf_log_pkg.string(wf_log_pkg.level_procedure,
                       'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.CREATECLOBFILE.Begin',
                       'Entered Create Clob File: '||p_Directory||'-'||p_Filename);
  end if;

  l_filehandle := UTL_FILE.FOPEN(p_Directory, p_Filename,'w');

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.CREATECLOBFILE.file_handle',
                      'Got file handle');
  end if;

  --
  -- At in Begin Sync Tag
  --
  utl_file.putf(l_filehandle, g_begin_clob);
  utl_file.new_line(l_filehandle, 1);

  --
  LOOP
        --
        -- We look through the CLOB for a each Object until there
        -- are none
        --
        l_counter := l_counter + 1;

        l_begin_position := dbms_lob.instr(p_clob, g_begin_string,
                                1, l_counter);

        EXIT when l_begin_position = 0; -- No More Event Objects left

        l_end_position   := dbms_lob.instr(p_clob , g_end_string,
                                1, l_counter);

        --
        -- Figure out the amount to read out of the CLOB, and subst
        --
        l_end_position := l_end_position + l_length_end_string;

        l_amount_to_read := l_end_position - l_begin_position;

        l_messagedata := dbms_lob.substr(p_clob, l_amount_to_read,
                                                l_begin_position);

        utl_file.putf(l_filehandle, l_messagedata);

        utl_file.new_line(l_filehandle, 1);

  END LOOP;

/**
  LOOP

        l_messagedata := dbms_lob.substr(p_clob, l_splice_size,
                                l_current_position);

        utl_file.putf(l_filehandle, l_messagedata);

        wf_log_pkg.string(6, 'WF_EVENT_SYNCHRONIZE_PKG.CREATEFILE',
                        substr(l_messagedata,1,l_splice_size));

        l_current_position := l_current_position + l_splice_size;

        EXIT WHEN l_current_position = l_clobsize;

        IF l_current_position + l_splice_size > l_clobsize THEN
                l_splice_size := l_clobsize  - l_current_position;
        END IF;

  END LOOP;
**/
  --
  -- Add in End Sync Tag
  --
  utl_file.putf(l_filehandle, g_end_clob);

  utl_file.new_line(l_filehandle, 1);

  utl_file.fclose(l_filehandle);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'CREATECLOBFILE', p_Directory||
                        '*'||p_Filename,null);
    raise;
end;
------------------------------------------------------------------------------
/*
** UploadFile - Called from SQL*Plus, uploads file into Event System
**              Parameters: Directory
**                          Filename
**
*/
procedure UPLOADFILE (
 P_DIRECTORY  in  varchar2,
 P_FILENAME   in  varchar2
) is

l_filehandle   UTL_FILE.FILE_TYPE;
l_workingclob  clob;
l_clob         clob;
l_buffer       varchar2(32000);
l_clobsize     integer;

begin

  if (p_directory is null or p_filename is null) then
    raise utl_file.invalid_path;
  end if;

  l_filehandle := UTL_FILE.FOPEN(p_Directory, p_Filename,'r');

  dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);

  LOOP
    begin
      dbms_lob.createtemporary( l_workingclob, FALSE, DBMS_LOB.CALL);

      utl_file.get_line(l_filehandle, l_buffer);

      if length(l_buffer) > 0 then
        dbms_lob.write(l_workingclob, length(l_buffer), 1, l_buffer);
        dbms_lob.append(l_clob,l_workingclob);
      end if;

      l_workingclob := null;
      l_buffer := '';

    exception
      when no_data_found then
        exit;
    end;
  END LOOP;

  --
  -- We have the Clob
  --
  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.UPLOADFILE.file_size',
                      'Clob Size is:'||l_clobsize);
     wf_log_pkg.string(wf_log_pkg.level_statement,
                      'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.UPLOADFILE.upload',
                      'About to Upload Clob');
  end if;

  wf_event_synchronize_pkg.uploadsyncclob( l_clob);

exception
  when utl_file.invalid_path then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'UPLOADFILE', p_Directory,
                        p_Filename,null);
    wf_core.raise('WFE_INVALID_PATH');
  when utl_file.invalid_mode then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'UPLOADFILE', p_Directory,
                        p_Filename,null);
    wf_core.raise('WFE_INVALID_MODE');
  when utl_file.invalid_operation then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'UPLOADFILE', p_Directory,
                        p_Filename,null);
    wf_core.raise('WFE_INVALID_OPERATION');
  when utl_file.read_error then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'UPLOADFILE', p_Directory,
                        p_Filename,null);
    wf_core.raise('WFE_READ_ERROR');
  when utl_file.internal_error then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'UPLOADFILE', p_Directory,
                        p_Filename,null);
    wf_core.raise('WFE_INTERNAL_ERROR');
  when utl_file.invalid_filehandle then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'UPLOADFILE', p_Directory,
                        p_Filename,null);
    wf_core.raise('WFE_INVALID_FILEHANDLE');
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'UPLOADFILE', p_Directory,
                        p_Filename,null);
    raise;
end;
------------------------------------------------------------------------------
/*
** UploadSyncClob - Called by UploadFile, takes a CLOB, splices it, and
**                  inserts objects into Event System
**                  Parameters: EventData
**
*/
procedure UPLOADSYNCCLOB (
 P_EVENTDATA  in  clob
) is

l_length_end_string integer := 16;
l_amount_to_read    integer := 0;
l_counter           integer := 0;
l_begin_position    integer := 0;
l_end_position      integer := 0;

l_messagedata       varchar2(32000);
l_objecttype        varchar2(100);
l_clobsize          integer;
l_splice            varchar2(4000);
l_error             varchar2(4000);

begin
  --
  LOOP
    --
    -- We look through the CLOB for a each Object until there
    -- are none
    --
    l_counter := l_counter + 1;

    l_begin_position := dbms_lob.instr(p_eventdata, g_begin_string,
                                       1, l_counter);

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       -- This is for logging only
       -- BINDVAR_SCAN_IGNORE[3]
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.UPLOADSYNCCLOB.pos',
                        'Begin Pos '||l_begin_position);
    end if;

    EXIT when l_begin_position = 0; -- No More Event Objects left

    l_end_position := dbms_lob.instr(p_eventdata, g_end_string,
                                     1, l_counter);

    --
    -- Figure out the amount to read out of the CLOB, and subst
    --
    l_end_position := l_end_position + l_length_end_string;

    l_amount_to_read := l_end_position - l_begin_position;

    l_messagedata := dbms_lob.substr(p_eventdata, l_amount_to_read,
                                     l_begin_position);

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.UPLOADSYNCCLOB.data',
                        'Message Data: '||substr(l_messagedata,1,100));
    end if;

    --
    -- Get Object Type, and then call to UploadObject
    --
    l_objecttype := wf_event_synchronize_pkg.GetObjectType(l_messagedata);

    if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
       wf_log_pkg.string(wf_log_pkg.level_statement,
                        'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.UPLOADSYNCCLOB.object',
                        'Object Type: '||l_objecttype);
    end if;

    wf_event_synchronize_pkg.UploadObject(l_objecttype, l_messagedata,l_error);

  END LOOP;

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'UPLOADSYNCCLOB', l_counter,
                                                substr(l_messagedata,1,100),
                    null);
    raise;
end;
------------------------------------------------------------------------------
/*
** GetSystems   - Get's all systems that match the key, returns CLOB
**
*/
function GETSYSTEMS (
 P_KEY   in varchar2
) return clob is

l_clob      clob;
returnclob  clob;

cursor systems is
select guid from wf_systems
where name like nvl(p_key,'%');

begin

  dbms_lob.createtemporary(returnclob, FALSE, DBMS_LOB.CALL);

  FOR g IN systems LOOP

    dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);

    -- Get our XML document
    l_clob := wf_event_functions_pkg.generate('oracle.apps.wf.event.system.update', g.guid);

    -- Add this to our return CLOB
    dbms_lob.append(returnclob, l_clob);

    -- Kill the Loop CLOB
    l_clob := null;

  END LOOP;

  return (returnclob);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'GetSystems', p_key,null,
                                                    'ERROR'); raise;
end;
------------------------------------------------------------------------------
/*
** GetAgents    - Get's all systems that match the key, returns CLOB
**
*/
function GETAGENTS (
 P_KEY          in      varchar2,
 P_ISEXACT      in      boolean
) return clob is

l_clob          clob;
l_clob_len      integer := 0;
returnclob      clob;
l_tmpStr        varchar2(32000);
l_tmpStrLen     integer := 0;
l_guid          raw(16);
l_searchPos     number default 1;

cursor agents(xguid raw) is
select guid from wf_agents
where name like nvl(p_key,'%')
and (xguid is null or system_guid=xguid);

begin
  -- Download local agents only when ObjectType is SYSTEMS, AGENTS, or EVENT
  IF (upper(g_ObjectType) = 'SYSTEMS' OR
      upper(g_ObjectType) = 'AGENTS' OR
--      upper(g_ObjectType) = 'AGENTGROUPS' OR
--      upper(g_ObjectType) = 'EVENT' OR
--      upper(g_ObjectType) = 'SUBSCRIPTIONS' OR
--      upper(g_ObjectType) = 'GROUPS' OR
      upper(g_ObjectType) = 'EVENTS') THEN
    l_guid := hextoraw(wf_core.translate('WF_SYSTEM_GUID'));
  ELSE
    l_guid := hextoraw(null);
  END IF;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.GETAGENTS.Begin',
                      'Entered GetAgents');
  end if;

  dbms_lob.createtemporary(returnclob, FALSE, DBMS_LOB.CALL);

  FOR g IN agents(l_guid) LOOP

    dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);

    -- Get our XML document
    l_clob := wf_event_functions_pkg.generate('oracle.apps.wf.event.agent.update', g.guid);

    if (p_isexact = false) then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                          'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.GETAGENTS.set_pound',
                          'Substitute with pounds.');
      end if;

      l_clob_len := dbms_lob.getlength(l_clob);
      dbms_lob.read(l_clob, l_clob_len, 1, l_tmpStr);

      -- # replacement in <GUID>, <SYSTEM_GUID>, and <ADDRESS> field
      l_tmpStr := SetPound(1,l_tmpStr,'<GUID>','</GUID>','NEW',null);
      l_tmpStr := SetPound(1,l_tmpStr,'<SYSTEM_GUID>','</SYSTEM_GUID>','LOCAL',null);
      l_tmpStr := SetPound(1,l_tmpStr,'<ADDRESS>','.','OWNER',null);
      l_searchPos := instr(l_tmpStr, '<ADDRESS>');
      l_tmpStr := SetPound(l_searchPos,l_tmpStr,'@','</ADDRESS>','SID',null);
      l_tmpStr := SetPound(1,l_tmpStr,'<QUEUE_NAME>','.','OWNER',null);
      l_tmpStrLen := length(l_tmpStr);

      dbms_lob.erase(l_clob, l_clob_len, 1);
      dbms_lob.write(l_clob, l_tmpStrLen, 1, l_tmpStr);
    end if;

    -- Add this to our return CLOB
    dbms_lob.append(returnclob, l_clob);

    -- Kill the Loop CLOB
    l_clob := null;

  END LOOP;

  return (returnclob);


exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'GetAgents', p_key,null,
                                                    'ERROR'); raise;
end;
------------------------------------------------------------------------------
/*
** GetAgentGroups    - Get's all agent groups that match the key, returns CLOB
**
*/
function GETAGENTGROUPS (
 P_KEY          in      varchar2
) return clob is

l_clob          clob;
returnclob      clob;

cursor agent_groups is
select g.name||'/'||a.name GUID
from   wf_agents g, wf_agents a,wf_agent_groups ag
where  g.guid=ag.group_guid
and    a.guid=ag.member_guid
and    (p_key is null or a.name like p_key);

/*select wag.group_guid||'/'||wag.member_guid GUID from wf_agent_groups wag
where exists
        (       select 'x'
                from wf_agents
                where guid = wag.member_guid
                and name like nvl(p_key,'%')
        );*/

begin

  dbms_lob.createtemporary(returnclob, FALSE, DBMS_LOB.CALL);

  FOR g IN agent_groups LOOP

    dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);

    -- Get our XML document
    l_clob := wf_event_functions_pkg.generate('oracle.apps.wf.event.agentgroup.update', g.guid);

    -- Add this to our return CLOB
    dbms_lob.append(returnclob, l_clob);

    -- Kill the Loop CLOB
    l_clob := null;

  END LOOP;

  return (returnclob);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'GetAgentGroups', p_key,null,
                                                    'ERROR'); raise;
end;

------------------------------------------------------------------------------
/*
** GetEvents    - Get's all events that match the key, returns CLOB
**
*/

function GETEVENTS (
 P_KEY          in      varchar2,
 P_OWNERTAG     in      varchar2
) return clob is

l_clob      clob;
returnclob  clob;

-- we want to get only EVENT type objects here
cursor events is
select guid
from   wf_events
where  type = 'EVENT'
and    name like p_key
and    owner_tag like nvl(p_ownertag, '%');

cursor events_all is
select guid
from   wf_events
where  type = 'EVENT'
and    owner_tag like nvl(p_ownertag, '%');

begin

  dbms_lob.createtemporary(returnclob, FALSE, DBMS_LOB.CALL);
  dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);

  if (p_key is not null OR p_key <> '') then

    FOR g IN events LOOP
      -- Get our XML document
      l_clob := wf_event_functions_pkg.generate('oracle.apps.wf.event.event.update', g.guid);
      -- Add this to our return CLOB
      dbms_lob.append(returnclob, l_clob);
      -- Kill the Loop CLOB
      dbms_lob.trim(l_clob, 0);
    END LOOP;

  else

    FOR g IN events_all LOOP
      -- Get our XML document
      l_clob := wf_event_functions_pkg.generate('oracle.apps.wf.event.event.update', g.guid);
      -- Add this to our return CLOB
      dbms_lob.append(returnclob, l_clob);
      -- Kill the Loop CLOB
      dbms_lob.trim(l_clob, 0);
    END LOOP;

  end if;

  return (returnclob);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'GetEvents', p_key,null,
                                                    'ERROR'); raise;
end;
------------------------------------------------------------------------------
/*
** GetEventGroups    - Get's all events that match the key, returns CLOB
**
*/
function GETEVENTGROUPS (
 P_KEY          in      varchar2,
 P_OWNERTAG     in      varchar2
) return clob is

l_clob      clob;
returnclob  clob;

-- Download all groups to which the given event or key belongs to
cursor event_groups is
select g.name||'/'||e.name names
from   wf_events g, wf_events e, wf_event_groups eg
where  g.guid = eg.group_guid
and    g.type = 'GROUP'
and    e.guid = eg.member_guid
and    e.name like p_key
and    e.owner_tag like nvl(p_ownertag, '%')
order by e.name;

cursor event_groups_all is
select g.name||'/'||e.name names
from   wf_events g, wf_events e, wf_event_groups eg
where  g.guid = eg.group_guid
and    g.type = 'GROUP'
and    e.guid = eg.member_guid
and    e.owner_tag like nvl(p_ownertag, '%')
order by e.name;

begin

  dbms_lob.createtemporary(returnclob, FALSE, DBMS_LOB.CALL);
  dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);

  if (p_key is not null OR p_key <> '') then

    FOR g IN event_groups LOOP
      -- Get our XML document
      l_clob := wf_event_functions_pkg.generate('oracle.apps.wf.event.group.update', g.names);
      -- Add this to our return CLOB
      dbms_lob.append(returnclob, l_clob);
      -- Kill the Loop CLOB
      dbms_lob.trim(l_clob, 0);
    END LOOP;

  else

    FOR g IN event_groups_all LOOP
      -- Get our XML document
      l_clob := wf_event_functions_pkg.generate('oracle.apps.wf.event.group.update', g.names);
      -- Add this to our return CLOB
      dbms_lob.append(returnclob, l_clob);
      -- Kill the Loop CLOB
      dbms_lob.trim(l_clob, 0);
    END LOOP;

  end if;

  return (returnclob);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'GetEventGroups', p_key,null,
                                                    'ERROR'); raise;
end;
------------------------------------------------------------------------------
/*
** GetGroups    - Get's all events of type GROUP that match the key, returns CLOB
**
*/

function GETGROUPS (
 P_KEY          in      varchar2,
 P_OWNERTAG     in      varchar2
) return clob is

l_clob      clob;
returnclob  clob;

cursor events is
select guid
from   wf_events
where  type = 'GROUP'
and    name like p_key
and    owner_tag like nvl(p_ownertag, '%');

cursor events_all is
select guid
from   wf_events
where  type = 'GROUP'
and    owner_tag like nvl(p_ownertag, '%');

begin

  dbms_lob.createtemporary(returnclob, FALSE, DBMS_LOB.CALL);
  dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);

  if (p_key is not null OR p_key <> '') then

    FOR g IN events LOOP
      -- Get our XML document
      l_clob := wf_event_functions_pkg.generate('oracle.apps.wf.event.event.update', g.guid);
      -- Add this to our return CLOB
      dbms_lob.append(returnclob, l_clob);
      -- Kill the Loop CLOB
      dbms_lob.trim(l_clob, 0);
    END LOOP;

  else

    FOR g IN events_all LOOP
      -- Get our XML document
      l_clob := wf_event_functions_pkg.generate('oracle.apps.wf.event.event.update', g.guid);
      -- Add this to our return CLOB
      dbms_lob.append(returnclob, l_clob);
      -- Kill the Loop CLOB
      dbms_lob.trim(l_clob, 0);
    END LOOP;

  end if;

  return (returnclob);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'GetGroups', p_key,null,
                                                    'ERROR'); raise;
end;
------------------------------------------------------------------------------
function GETEVENTGROUPBYGROUP (
 P_KEY          in      varchar2,
 P_OWNERTAG     in      varchar2
) return clob is

l_clob      clob;
returnclob  clob;

cursor event_groups is
select g.name||'/'||e.name names
from   wf_events g, wf_events e, wf_event_groups eg
where  g.guid = eg.group_guid
and    g.type = 'GROUP'
and    e.guid = eg.member_guid
and    (p_key is null or g.name like p_key )
and    (p_ownertag is null or g.owner_tag like p_ownertag)
order by g.name;

begin

  dbms_lob.createtemporary(returnclob, FALSE, DBMS_LOB.CALL);

  FOR g IN event_groups LOOP

    dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);

    -- Get our XML document
    l_clob := wf_event_functions_pkg.generate('oracle.apps.wf.event.group.update', g.names);

    -- Add this to our return CLOB
    dbms_lob.append(returnclob, l_clob);

    -- Kill the Loop CLOB
    l_clob := null;

  END LOOP;

  return (returnclob);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'GetEventGroupByGroup', p_key,null,
                                                    'ERROR'); raise;
end;

------------------------------------------------------------------------------
/*
** GetSubscriptions    - Get's all subscriptions that match the key, returns CLOB
**
*/
function GETSUBSCRIPTIONS (
 P_KEY          in      varchar2,
 P_ISEXACT      in      boolean,
 P_OWNERTAG     in      varchar2
) return clob is

l_clob          clob;
l_clob_len      integer := 0;
returnclob      clob;
l_tmpStr        varchar2(32000);
l_tmpStrLen     integer := 0;
l_guid          raw(16);
strGuid         varchar2(100) default null;

cursor event_subscriptions(xguid raw) is
select distinct(wes.guid) GUID from wf_event_subscriptions wes
where owner_tag like NVL(p_ownertag, '%')
 and exists
 ( select 'x'
  from wf_events
  where guid = wes.event_filter_guid
  and   name like nvl(p_key,'%')
  and   (xguid is null or system_guid=xguid)
 );

cursor agents(wfagt varchar2) is
select guid from wf_agents
where name = wfagt;

begin
  -- Download local event subscriptions only when ObjectType is SYSTEMS, AGENTS, or EVENT
  IF (upper(g_ObjectType) = 'SYSTEMS' OR
      upper(g_ObjectType) = 'AGENTS' OR
--      upper(g_ObjectType) = 'EVENT' OR
--      upper(g_ObjectType) = 'SUBSCRIPTIONS' OR
--      upper(g_ObjectType) = 'GROUPS' OR
      upper(g_ObjectType) = 'EVENTS') THEN
    l_guid := hextoraw(wf_core.translate('WF_SYSTEM_GUID'));
  ELSE
    l_guid := hextoraw(null);
  END IF;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.GETSUBSCRIPTIONS.Begin',
                      'Entered GetSubscriptions');
  end if;

  dbms_lob.createtemporary(returnclob, FALSE, DBMS_LOB.CALL);

  FOR g IN event_subscriptions(l_guid) LOOP

    dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);

    -- Get our XML document
    l_clob := wf_event_functions_pkg.generate('oracle.apps.wf.event.subscription.update', g.guid);

    if (p_isexact = false) then
      if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
         wf_log_pkg.string(wf_log_pkg.level_statement,
                          'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.GETSUBSCRIPTIONS.set_pound',
                          'Substitute with pounds.');
      end if;

      l_clob_len := dbms_lob.getlength(l_clob);
      dbms_lob.read(l_clob, l_clob_len, 1, l_tmpStr);

      -- # replacement in <GUID> and <SYSTEM_GUID> field
      l_tmpStr := SetPound(1,l_tmpStr,'<GUID>','</GUID>','NEW',null);
      l_tmpStr := SetPound(1,l_tmpStr,'<SYSTEM_GUID>','</SYSTEM_GUID>','LOCAL',null);

      -- set <OUT_AGENT_GUID/> and <TO_AGENT_GUID/>
--      l_tmpStr := SetNull(1,l_tmpStr,'OUT_AGENT_GUID');
--      l_tmpStr := SetNull(1,l_tmpStr,'TO_AGENT_GUID');

      l_tmpStr := getAgent('<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>',l_tmpStr);
      l_tmpStr := getAgent('<OUT_AGENT_GUID>','</OUT_AGENT_GUID>',l_tmpStr);
      l_tmpStr := getAgent('<TO_AGENT_GUID>','</TO_AGENT_GUID>',l_tmpStr);

      /**
      Bug 3191978
      The above code will genericall replace all agent_guids with
      their corresponding agent name

      FOR a IN agents('WF_IN') LOOP
        strGuid := a.guid; -- rawtohex(a.guid);
        l_tmpStr := SetPound(1,l_tmpStr,'<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','WF_IN',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','WF_IN',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<TO_AGENT_GUID>','</TO_AGENT_GUID>','WF_IN',strGuid);
      END LOOP;

      FOR b IN agents('WF_OUT') LOOP
        strGuid := b.guid; -- rawtohex(b.guid);
        l_tmpStr := SetPound(1,l_tmpStr,'<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','WF_OUT',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','WF_OUT',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<TO_AGENT_GUID>','</TO_AGENT_GUID>','WF_OUT',strGuid);
      END LOOP;

      FOR c IN agents('WF_ERROR') LOOP
        strGuid := c.guid; -- rawtohex(c.guid);
        l_tmpStr := SetPound(1,l_tmpStr,'<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','WF_ERROR',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','WF_ERROR',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<TO_AGENT_GUID>','</TO_AGENT_GUID>','WF_ERROR',strGuid);
      END LOOP;

      FOR c IN agents('WF_REPLAY_OUT') LOOP
        strGuid := c.guid; -- rawtohex(c.guid);
        l_tmpStr := SetPound(1,l_tmpStr,'<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','WF_REPLAY_OUT',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','WF_REPLAY_OUT',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<TO_AGENT_GUID>','</TO_AGENT_GUID>','WF_REPLAY_OUT',strGuid);
      END LOOP;

      FOR c IN agents('WF_CONTROL') LOOP
        strGuid := c.guid; -- rawtohex(c.guid);
        l_tmpStr := SetPound(1,l_tmpStr,'<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','WF_CONTROL',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','WF_CONTROL',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<TO_AGENT_GUID>','</TO_AGENT_GUID>','WF_CONTROL',strGuid);
      END LOOP;

      FOR c IN agents('WF_JMS_IN') LOOP
        strGuid := c.guid; -- rawtohex(c.guid);
        l_tmpStr := SetPound(1,l_tmpStr,'<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','WF_JMS_IN',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','WF_JMS_IN',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<TO_AGENT_GUID>','</TO_AGENT_GUID>','WF_JMS_IN',strGuid);
      END LOOP;

      FOR c IN agents('WF_JMS_OUT') LOOP
        strGuid := c.guid; -- rawtohex(c.guid);
        l_tmpStr := SetPound(1,l_tmpStr,'<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','WF_JMS_OUT',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','WF_JMS_OUT',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<TO_AGENT_GUID>','</TO_AGENT_GUID>','WF_JMS_OUT',strGuid);
      END LOOP;

      FOR c IN agents('WF_NOTIFICATION_IN') LOOP
        strGuid := c.guid; -- rawtohex(c.guid);
        l_tmpStr := SetPound(1,l_tmpStr,'<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','WF_NOTIFICATION_IN',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','WF_NOTIFICATION_IN',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<TO_AGENT_GUID>','</TO_AGENT_GUID>','WF_NOTIFICATION_IN',strGuid);
      END LOOP;

      FOR c IN agents('WF_NOTIFICATION_OUT') LOOP
        strGuid := c.guid; -- rawtohex(c.guid);
        l_tmpStr := SetPound(1,l_tmpStr,'<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','WF_NOTIFICATION_OUT',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','WF_NOTIFICATION_OUT',strGuid);
        l_tmpStr := SetPound(1,l_tmpStr,'<TO_AGENT_GUID>','</TO_AGENT_GUID>','WF_NOTIFICATION_OUT',strGuid);
      END LOOP;
      **/
      l_tmpStrLen := length(l_tmpStr);

      dbms_lob.erase(l_clob, l_clob_len, 1);
      dbms_lob.write(l_clob, l_tmpStrLen, 1, l_tmpStr);
    end if;

    -- Add this to our return CLOB
    dbms_lob.append(returnclob, l_clob);

    -- Kill the Loop CLOB
    l_clob := null;

  END LOOP;

  return (returnclob);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'GetSubscriptions', p_key,null,
                                                    'ERROR'); raise;
end;
------------------------------------------------------------------------------
/*
** GetObjectType - Receives a string and determines what event object type
**                 it is.
**
*/
function GETOBJECTTYPE(
 P_MESSAGEDATA  in  varchar2
) return varchar2 is

l_return varchar2(100);

begin

  IF instr(p_messagedata, g_system, 1, 1) > 0 THEN
    l_return := g_system;
  ELSIF instr(p_messagedata, g_agent, 1, 1) > 0 THEN
    l_return := g_agent;
  ELSIF instr(p_messagedata, g_agent_group, 1, 1) > 0 THEN
    l_return := g_agent_group;
  ELSIF instr(p_messagedata, g_event, 1, 1) > 0 THEN
    l_return := g_event;
  ELSIF instr(p_messagedata, g_event_group, 1, 1) > 0 THEN
    l_return := g_event_group;
  ELSIF instr(p_messagedata, g_event_sub, 1, 1) > 0 THEN
    l_return := g_event_sub;
  END IF;

  return (l_return);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'GetObjectType',
                    substr(p_messagedata,1,100),null,
                                        'ERROR'); raise;
end;
------------------------------------------------------------------------------
/*
** UploadObject    - Receives a string and calls appropriate table handler
**
**
*/
procedure UploadObject(
 P_OBJECTTYPE   in  varchar2,
 P_MESSAGEDATA  in  varchar2,
 P_ERROR        out nocopy  varchar2
) is

begin

  IF p_objecttype = g_system THEN
    wf_systems_pkg.receive(p_messagedata);
  ELSIF p_objecttype = g_agent THEN
    wf_agents_pkg.receive(p_messagedata);
  ELSIF p_objecttype = g_agent_group THEN
    wf_agent_groups_pkg.receive(p_messagedata);
  ELSIF p_objecttype = g_event THEN
    wf_events_pkg.receive(p_messagedata);
  ELSIF p_objecttype = g_event_group THEN
    wf_event_groups_pkg.receive2(p_messagedata,p_error);
  ELSIF p_objecttype = g_event_sub THEN
    wf_event_subscriptions_pkg.receive(p_messagedata);
  END IF;

/*exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'UploadObject',
                                        substr(p_messagedata,1,100),
                    p_objecttype,
                                        'ERROR'); raise;*/
end;
------------------------------------------------------------------------------
/*
** UpdateGUID- Update GUID in WF_RESOURCES table
**                      returns varchar2
**                      Parameters:     <can be null>
*/
procedure UpdateGUID (
 g_guid in varchar2
) is
ret number default 0; -- 0 means value didn't get update
l_guid raw(16) default null;
l_count number;
begin
  if g_guid is not null then
    select count(*)
    into l_count
    from WF_SYSTEMS;
    if (l_count = 0) then
      update WF_RESOURCES
      set text=g_guid
      where name='WF_SYSTEM_GUID';
    end if;
  end if;
exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'UpdateGUID');
    raise;
end;
------------------------------------------------------------------------------
/*
** ReplaceContent - Replace contant of a given tag, returns varchar2
*/
function ReplaceContent (
 begTag in varchar2,
 endTag in varchar2,
 replaceTarget in varchar2,
 newData in varchar2,
 dataStr in varchar2
) return varchar2 is
retStr varchar2(32000) default null;
beg_pos number default 1;
end_pos number default 1;
l_pos number default 1;
l_amount_to_read number default 0;
l_str varchar2(32000) default null;
l_str_new varchar2(32000) default null;

begin
  if dataStr is not null then
    retStr := dataStr;
    beg_pos := instr(dataStr, begTag);
    end_pos := instr(dataStr, endTag);
    l_amount_to_read := end_pos - beg_pos;
    if ((beg_pos <> 0) and
        (end_pos <> 0) and
        (l_amount_to_read > 0)) then
      l_str := substr(dataStr,beg_pos,l_amount_to_read);
      l_pos := instr(l_str, replaceTarget);
      if (l_pos > 1) then
        l_str_new := replace(l_str,replaceTarget,newData);
        retStr := replace(retStr,l_str,l_str_new);
      end if;
    end if;
  else
    retStr := dataStr;
  end if;
  return (retStr);
exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'ReplaceContent');
    raise;
end;
------------------------------------------------------------------------------
/*
** SetGUID - Generate new GUID when encounter #NEW tag, returns varchar2
**                      Parameters:     dataStr <can be null>
*/
function SetGUID (
 dataStr in varchar2
) return varchar2 is

g_guid varchar2(100) := '<GUID>#NEW</GUID>';
g_guid2 varchar2(100) := '<MEMBER_GUID>#NEW</MEMBER_GUID>';
g_beg_system varchar2(100) := '<WF_SYSTEMS>';
g_end_system varchar2(100) := '</WF_SYSTEMS>';
retStr varchar2(32000) default null;
l_guid raw(16) default null;

begin
  if dataStr is not null then
    l_guid := sys_guid();
    retStr := ReplaceContent(g_beg_system,g_end_system,g_guid,'<GUID>'||l_guid||'</GUID>',dataStr);

    if (retStr <> dataStr) then
      UpdateGUID(l_guid);
    end if;
    -- check the rest, including Agents
    retStr := replace(retStr,g_guid,'<GUID>'||l_guid||'</GUID>');
    retStr := replace(retStr,g_guid2,'<MEMBER_GUID>'||l_guid||'</MEMBER_GUID>');
  else
    retStr := dataStr;
  end if;
  return (retStr);
exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'SetGUID');
    raise;
end;
------------------------------------------------------------------------------
/*
** SetSYSTEMGUID - Set SYSTEM_GUID when encounter #LOCAL tag,
**                                      returns varchar2
**                      Parameters:     dataStr <can be null>
*/
function SetSYSTEMGUID (
 dataStr in varchar2
) return varchar2 is

g_sys_guid varchar2(100) := '<SYSTEM_GUID>#LOCAL</SYSTEM_GUID>';
retStr varchar2(32000) default null;
-- beg_pos number default 0;
l_sys_guid raw(16);

begin
  if dataStr is not null then
--      beg_pos := instr(dataStr, g_guid);
    l_sys_guid := hextoraw(wf_core.translate('WF_SYSTEM_GUID'));
    retStr := replace(dataStr,g_sys_guid,'<SYSTEM_GUID>'||l_sys_guid||'</SYSTEM_GUID>');
  else
    retStr := dataStr;
  end if;
  return (retStr);
exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'SetSYSTEMGUID');
    raise;
end;
------------------------------------------------------------------------------
/*
** GetSID - Get SID from database, returns varchar2
*/
function GetSID return varchar2 is

l_sid varchar2(1000);

begin
  -- get database sid
  begin
    select global_name
    into l_sid from global_name;
  exception
    when no_data_found then
      l_sid := 'EVENTSYSTEM';
  end;

  return upper(substr(l_sid,1,30));

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'GetSID');
    raise;
end;
------------------------------------------------------------------------------
/*
** GetQOwner - Get Queue Owner from database, returns varchar2
*/
function GetQOwner return varchar2 is

-- l_owner varchar2(1000);

begin
  -- get queue owner
  begin
    /*
    select owner
    into l_owner
    from all_queues
    where name='WF_IN';
    */
    --don't do this costly query substr it
    --off from wf_agents or since WF_IN is seeded
    --it should always be the schema
 /*  Bug3628261 - if no data found here NOSUCHTHING was returned
     instead we will just cache the WF_SCHEMA.
    select substr(queue_name,1,instr(queue_name,'.')-1)
    into   l_owner
    from   wf_agents
    where  name = 'WF_IN';
 */
   if (g_qowner is null) then
      g_qowner :=  upper(wf_core.translate('WF_SCHEMA'));
   end if;

  end;

  return (g_qowner);
exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'GetQOwner');
    raise;
end;
------------------------------------------------------------------------------
/*
** SetSID - Set SID when encounter #SID tag,
**                                      returns varchar2
**                      Parameters:     dataStr <can be null>
*/
function SetSID (
 dataStr in varchar2
) return varchar2 is
g_sid_name  varchar2(100) := '<NAME>#SID</NAME>';
g_sid_disp  varchar2(100) := '<DISPLAY_NAME>#SID</DISPLAY_NAME>';
g_sid_desc  varchar2(100) := '<DESCRIPTION>#SID</DESCRIPTION>';
g_beg_addr  varchar2(100) := '<ADDRESS>';
g_end_addr  varchar2(100) := '</ADDRESS>';
g_beg_qname varchar2(100) := '<QUEUE_NAME>';
g_end_qname varchar2(100) := '</QUEUE_NAME>';
tmpStr      varchar2(32000) default null;
retStr      varchar2(32000) default null;
l_sid       varchar2(1000) default null;
l_owner     varchar2(1000) default null;


begin
  if dataStr is not null then
    l_sid := GetSID();
    l_owner := GetQOwner();
    if l_sid is not null then
      tmpStr := dataStr;
      tmpStr := replace(tmpStr,g_sid_name,'<NAME>'||l_sid||'</NAME>');
      tmpStr := replace(tmpStr,g_sid_disp,'<DISPLAY_NAME>'||l_sid||'</DISPLAY_NAME>');
      tmpStr := replace(tmpStr,g_sid_desc,'<DESCRIPTION>'||l_sid||'</DESCRIPTION>');
      tmpStr := ReplaceContent(g_beg_addr,g_end_addr,'#SID',l_sid,tmpStr);
      tmpStr := ReplaceContent(g_beg_addr,g_end_addr,'#OWNER',l_owner,tmpStr);
--    tmpStr := ReplaceContent(g_beg_qname,g_end_qname,'#SID',l_sid,tmpStr);
      tmpStr := ReplaceContent(g_beg_qname,g_end_qname,'#OWNER',l_owner,tmpStr);
      retStr := tmpStr;
    else
      retStr := dataStr;
    end if;
  end if;

  return (retStr);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'SetSID');
    raise;
end;
------------------------------------------------------------------------------
/*
** SetAgent - Set Agent SID when encounter #WF_IN, #WF_OUT, #WF_ERROR tag,
**                                      returns varchar2
**                      Parameters:     dataStr <can be null>
*/
function SetAgent (
 dataStr in varchar2
) return varchar2 is
tmpStr      varchar2(32000) default null;
retStr      varchar2(32000) default null;
l_wfin      varchar2(1000)  default null;
l_wfout     varchar2(1000)  default null;
l_wferror   varchar2(1000)  default null;
strGuid     varchar2(100)   default null;

cursor agent(str varchar2) is
select guid from wf_agents
where name=str
and system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID'));

begin
  if dataStr is not null then
    tmpStr := dataStr;
    FOR a IN agent('WF_IN') LOOP
      strGuid := a.guid;
      tmpStr := ReplaceContent('<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','#WF_IN',strGuid,tmpStr);
      tmpStr := ReplaceContent('<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','#WF_IN',strGuid,tmpStr);
      tmpStr := ReplaceContent('<TO_AGENT_GUID>','</TO_AGENT_GUID>','#WF_IN',strGuid,tmpStr);
    END LOOP;
    FOR b IN agent('WF_OUT') LOOP
      strGuid := b.guid; -- rawtohex(b.guid);
      tmpStr := ReplaceContent('<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','#WF_OUT',strGuid,tmpStr);
      tmpStr := ReplaceContent('<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','#WF_OUT',strGuid,tmpStr);
      tmpStr := ReplaceContent('<TO_AGENT_GUID>','</TO_AGENT_GUID>','#WF_OUT',strGuid,tmpStr);
    END LOOP;
    FOR c IN agent('WF_ERROR') LOOP
      strGuid := c.guid; -- rawtohex(c.guid);
      tmpStr := ReplaceContent('<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','#WF_ERROR',strGuid,tmpStr);
      tmpStr := ReplaceContent('<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','#WF_ERROR',strGuid,tmpStr);
      tmpStr := ReplaceContent('<TO_AGENT_GUID>','</TO_AGENT_GUID>','#WF_ERROR',strGuid,tmpStr);
    END LOOP;
    FOR c IN agent('WF_REPLAY_OUT') LOOP
      strGuid := c.guid; -- rawtohex(c.guid);
      tmpStr := ReplaceContent('<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','#WF_REPLAY_OUT',strGuid,tmpStr);
      tmpStr := ReplaceContent('<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','#WF_REPLAY_OUT',strGuid,tmpStr);
      tmpStr := ReplaceContent('<TO_AGENT_GUID>','</TO_AGENT_GUID>','#WF_REPLAY_OUT',strGuid,tmpStr);
    END LOOP;
    FOR c IN agent('WF_CONTROL') LOOP
      strGuid := c.guid; -- rawtohex(c.guid);
      tmpStr := ReplaceContent('<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','#WF_CONTROL',strGuid,tmpStr);
      tmpStr := ReplaceContent('<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','#WF_CONTROL',strGuid,tmpStr);
      tmpStr := ReplaceContent('<TO_AGENT_GUID>','</TO_AGENT_GUID>','#WF_CONTROL',strGuid,tmpStr);
    END LOOP;
    FOR c IN agent('WF_JMS_IN') LOOP
      strGuid := c.guid; -- rawtohex(c.guid);
      tmpStr := ReplaceContent('<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','#WF_JMS_IN',strGuid,tmpStr);
      tmpStr := ReplaceContent('<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','#WF_JMS_IN',strGuid,tmpStr);
      tmpStr := ReplaceContent('<TO_AGENT_GUID>','</TO_AGENT_GUID>','#WF_JMS_IN',strGuid,tmpStr);
    END LOOP;
    FOR c IN agent('WF_JMS_OUT') LOOP
      strGuid := c.guid; -- rawtohex(c.guid);
      tmpStr := ReplaceContent('<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','#WF_JMS_OUT',strGuid,tmpStr);
      tmpStr := ReplaceContent('<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','#WF_JMS_OUT',strGuid,tmpStr);
      tmpStr := ReplaceContent('<TO_AGENT_GUID>','</TO_AGENT_GUID>','#WF_JMS_OUT',strGuid,tmpStr);
    END LOOP;
    FOR c IN agent('WF_NOTIFICATION_IN') LOOP
      strGuid := c.guid; -- rawtohex(c.guid);
      tmpStr := ReplaceContent('<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','#WF_NOTIFICATION_IN',strGuid,tmpStr);
      tmpStr := ReplaceContent('<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','#WF_NOTIFICATION_IN',strGuid,tmpStr);
      tmpStr := ReplaceContent('<TO_AGENT_GUID>','</TO_AGENT_GUID>','#WF_NOTIFICATION_IN',strGuid,tmpStr);
    END LOOP;
    FOR c IN agent('WF_NOTIFICATION_OUT') LOOP
      strGuid := c.guid; -- rawtohex(c.guid);
      tmpStr := ReplaceContent('<SOURCE_AGENT_GUID>','</SOURCE_AGENT_GUID>','#WF_NOTIFICATION_OUT',strGuid,tmpStr);
      tmpStr := ReplaceContent('<OUT_AGENT_GUID>','</OUT_AGENT_GUID>','#WF_NOTIFICATION_OUT',strGuid,tmpStr);
      tmpStr := ReplaceContent('<TO_AGENT_GUID>','</TO_AGENT_GUID>','#WF_NOTIFICATION_OUT',strGuid,tmpStr);
    END LOOP;

    retStr := tmpStr;
  else
    retStr := dataStr;
  end if;
  return (retStr);

exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'SetAgent');
    raise;
end;

------------------------------------------------------------------------------
/*
** SetPound - Generate #xxx when encounter right tag, returns varchar2
**                      Parameters: startPos
**                                  dataStr
**                                  begTag
**                                  endTag
**                                  pound
**                                  matchStr
*/
function SetPound (
 startPos in number,
 dataStr  in varchar2,
 begTag   in varchar2,
 endTag   in varchar2,
 pound    in varchar2,
 matchStr in varchar2
) return varchar2 is

l_read_amt integer := 0;
l_cont_amt integer := 0;
l_str      varchar2(32000) default null;
retStr     varchar2(32000) default null;
l_str_new  varchar2(32000) default null;
l_content  varchar2(1000) default null;
l_pos      number default 1;
beg_pos    number default 0;
end_pos    number default 0;

begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.SETPOUND.Begin',
                      'Entered SetPound.');
  end if;

  if dataStr is not null then
    retStr := dataStr;
    beg_pos := instr(dataStr, begTag, startPos);
    end_pos := instr(dataStr, endTag, beg_pos);
    l_read_amt := end_pos - beg_pos;

    if ((beg_pos <> 0) and
        (end_pos <> 0) and
        (l_read_amt > 0)) then
      l_str := substr(dataStr,beg_pos,l_read_amt);

      l_pos := instr(dataStr, l_str);
      if (l_pos > 1) then
        if matchStr is not null then
          -- check if matchStr matches the content within the tags
          l_cont_amt := l_read_amt - length(begTag);
          l_content := substr(dataStr,beg_pos+length(begTag),l_cont_amt);
          if (l_content = matchStr) then
            l_str_new := begTag||'#'||pound;
            retStr := replace(retStr,l_str,l_str_new);
          end if;
        else
          l_str_new := begTag||'#'||pound;
          retStr := replace(retStr,l_str,l_str_new);
        end if;
      end if;
    end if;
  else
    retStr := dataStr;
  end if;
  return (retStr);
exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'SetPound');
    raise;
end;

------------------------------------------------------------------------------
/*
** SetNull - Return a null tag (in <tag\> format), returns varchar2
**                      Parameters: startPos
**                                  dataStr
**                                  tag
*/
function SetNull (
 startPos in number,
 dataStr  in varchar2,
 tag      in varchar2
) return varchar2 is

l_read_amt integer := 0;
l_str      varchar2(32000) default null;
retStr     varchar2(32000) default null;
l_str_new  varchar2(32000) default null;
l_pos      number default 1;
beg_pos    number default 0;
end_pos    number default 0;
endTagLen  number default 3; -- '</>'

begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.SETNULL.Begin',
                      'Entered SetNull.');
  end if;

  if dataStr is not null then
    retStr := dataStr;
    beg_pos := instr(dataStr, '<'||tag||'>', startPos);
    end_pos := instr(dataStr, '</'||tag||'>', beg_pos);
    l_read_amt := end_pos + endTagLen + length(tag) - beg_pos;

    if ((beg_pos <> 0) and
        (end_pos <> 0) and
        (l_read_amt > 0)) then
      l_str := substr(dataStr,beg_pos,l_read_amt);
      l_pos := instr(dataStr, l_str);
      if (l_pos > 1) then
        l_str_new := '<'||tag||'/>';
        retStr := replace(retStr,l_str,l_str_new);
      end if;
    end if;
  else
    retStr := dataStr;
  end if;
  return (retStr);
exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'SetNull');
    raise;
end;

------------------------------------------------------------------------------
/*
** CreateEmptyClob   - Creates a empty clob for Java to use, returns CLOB
*/
procedure CREATEEMPTYCLOB (
 P_OUTCLOB out nocopy      clob
) is
begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     wf_log_pkg.string(wf_log_pkg.level_procedure,
                      'wf.plsql.WF_EVENT_SYNCHRONIZE_PKG.CREATEEMPTYCLOB.Begin',
                      'Entered Create Empty Clob');
  end if;

  dbms_lob.createtemporary(p_outclob, FALSE, DBMS_LOB.CALL);
exception
  when others then
    wf_core.context('WF_EVENT_SYNCHRONIZE_PKG', 'CREATEEMPTYCLOB');
    raise;
end;
------------------------------------------------------------------------------
/*
** GetAgent   - Returns a string replacing the agent GUID with the
**              #<AGENT_NAME> .
*/
function GetAgent (
 begTag in varchar2,
 endTag in varchar2,
 dataStr in varchar2
) return varchar2 is
retStr varchar2(32000) default null;
beg_pos number default 1;
end_pos number default 1;
l_pos number default 1;
l_amount_to_read number default 0;
l_str varchar2(32000) default null;
l_str_new varchar2(32000) default null;
l_agtguid   varchar2(4000);
l_replaceTarget  varchar2(32000);

begin
  if dataStr is not null then
    retStr := dataStr;
    beg_pos := instr(dataStr, begTag);
    end_pos := instr(dataStr, endTag);
    l_amount_to_read := end_pos - beg_pos;
    if ((beg_pos <> 0) and
        (end_pos <> 0) and
        (l_amount_to_read > 0)) then
      l_str      := substr(dataStr,beg_pos,l_amount_to_read);
      l_pos      := length(begTag) +1 ;
      l_agtguid  := substr(l_str,l_pos);

      begin
        --Get the agent name from the guid given
        select name
        into   l_replaceTarget
        from   wf_agents
        where  guid = l_agtguid;
      exception
        when others then
          wf_core.token('GUID', l_agtguid);
          wf_core.raise('WFE_AGENT_NOTRESOLVE');
      end;

      l_replaceTarget := '#'||l_replaceTarget;

      if (l_pos > 1) then
        l_str_new := replace(l_str,l_agtguid,l_replaceTarget);
        retStr := replace(retStr,l_str,l_str_new);
      end if;
    end if;
  else
    retStr := dataStr;
  end if;
  return (retStr);
exception
  when others then
    wf_core.context('Wf_Event_Synchronize_Pkg', 'GetAgent');
    raise;
end;
--------------------------------------------------------------------------------------------
/*
** SetAgent2   - Returns a string replacing the agent the #<AGENT_NAME>
**               with the guid of the agent in the db.
*/
function SetAgent2 (
 begTag in varchar2,
 endTag in varchar2,
 dataStr in varchar2
) return varchar2 is
retStr varchar2(32000) default null;
beg_pos number default 1;
end_pos number default 1;
l_pos number default 1;
l_amount_to_read number default 0;
l_str varchar2(32000) default null;
l_str_new varchar2(32000) default null;
l_agtname  varchar2(40);
l_replaceTarget  varchar2(32000);
l_agt   varchar2(30);

begin
  if dataStr is not null then
    retStr := dataStr;
    beg_pos := instr(dataStr, begTag);
    end_pos := instr(dataStr, endTag);
    l_amount_to_read := end_pos - beg_pos;
    if ((beg_pos <> 0) and
        (end_pos <> 0) and
        (l_amount_to_read > 0)) then
      l_str      := substr(dataStr,beg_pos,l_amount_to_read);
      l_pos      := length(begTag) +1 ;
      l_agtname  := substr(l_str,l_pos);
      --Check if we have the # and strip it off
      --We check explicilty that its the first char as we
      --have not put any restriction on agent naming.
      --Else case we just passback the string
      if (instr(l_agtname , '#') = 1 ) then
         l_agt := substr(l_agtname,2);
      --Get the agent name from the guid given
         select guid
         into   l_replaceTarget
         from   wf_agents
         where  name = l_agt;

      if (l_pos > 1) then
           l_str_new := replace(l_str,l_agtname,l_replaceTarget);
           retStr := replace(retStr,l_str,l_str_new);
         end if;
      end if;
    end if;
  else
    retStr := dataStr;
  end if;
  return (retStr);
exception
  when no_data_found then
   wf_core.token('AGENT',l_agtname);
   wf_core.raise('WFE_SEEDAGT_NOTFOUND');
  when others then
    raise;
end;
--------------------------------------------------------------------------------------------
procedure CREATESYNCCLOB2 (
 P_OBJECTTYPE   in      varchar2 DEFAULT NULL,
 P_OBJECTKEY    in      varchar2 DEFAULT NULL,
 P_ISEXACTNUM   in      integer  DEFAULT 1,
 P_OWNERTAG     in      varchar2 DEFAULT NULL,
 P_EVENTDATA    out nocopy clob,
 P_ERROR_CODE   out nocopy varchar2,
 P_ERROR_MSG    out nocopy varchar2
)
is
begin
  Wf_Event_Synchronize_Pkg.CreateSyncClob(P_OBJECTTYPE, P_OBJECTKEY, P_ISEXACTNUM,
                                          P_OWNERTAG, P_EVENTDATA);
  p_error_code := null;
  p_error_msg := null;
exception
  when others then
    if (wf_core.error_name is not null) then
      p_error_code := wf_core.error_name;
      p_error_msg := wf_core.error_message;
    else
      raise;
    end if;
end CREATESYNCCLOB2;
--------------------------------------------------------------------------------------------

end WF_EVENT_SYNCHRONIZE_PKG;

/
