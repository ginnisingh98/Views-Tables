--------------------------------------------------------
--  DDL for Package Body WF_AGENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_AGENTS_PKG" as
/* $Header: WFEVAGTB.pls 120.2 2005/09/02 15:20:58 vshanmug ship $ */
m_table_name       varchar2(255) := 'WF_AGENTS';
m_package_version  varchar2(30)  := '1.0';
-----------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID           in out nocopy varchar2,
  X_GUID            in      raw,
  X_NAME            in      varchar2,
  X_SYSTEM_GUID     in      raw,
  X_PROTOCOL        in      varchar2,
  X_ADDRESS         in      varchar2,
  X_QUEUE_HANDLER   in      varchar2,
  X_QUEUE_NAME      in      varchar2,
  X_DIRECTION       in      varchar2,
  X_STATUS          in      varchar2,
  X_DISPLAY_NAME    in      varchar2,
  X_DESCRIPTION     in      varchar2,
  X_TYPE            in      varchar2,
  X_JAVA_QUEUE_HANDLER   in varchar2
) is
  cursor C is select rowid from wf_agents where guid = X_GUID;
begin
  insert into wf_agents (
     guid,
     name,
     system_guid,
     protocol,
     address,
     queue_handler,
     queue_name,
     direction,
     status,
     display_name,
     description,
     type,
     java_queue_handler
  ) values (
     X_GUID,
     X_NAME,
     X_SYSTEM_GUID,
     X_PROTOCOL,
     X_ADDRESS,
     X_QUEUE_HANDLER,
     X_QUEUE_NAME,
     X_DIRECTION,
     X_STATUS,
     X_DISPLAY_NAME,
     X_DESCRIPTION,
     X_TYPE,
     X_JAVA_QUEUE_HANDLER
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  else
    wf_event.raise('oracle.apps.wf.event.agent.create',x_guid);
  end if;
  close c;

exception
  when others then
    wf_core.context('Wf_Agents_Pkg', 'Insert_Row', x_guid,
        x_protocol );
    raise;
end INSERT_ROW;
-----------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_GUID            in      raw,
  X_NAME            in      varchar2,
  X_SYSTEM_GUID     in      raw,
  X_PROTOCOL        in      varchar2,
  X_ADDRESS         in      varchar2,
  X_QUEUE_HANDLER   in      varchar2,
  X_QUEUE_NAME      in      varchar2,
  X_DIRECTION       in      varchar2,
  X_STATUS          in      varchar2,
  X_DISPLAY_NAME    in      varchar2,
  X_DESCRIPTION     in      varchar2,
  X_TYPE            in      varchar2,
  X_JAVA_QUEUE_HANDLER in   varchar2
) is
begin
  if (x_type is null) then
    update wf_agents set
      name            = X_NAME,
      system_guid     = X_SYSTEM_GUID,
      protocol        = X_PROTOCOL,
      address         = X_ADDRESS,
      queue_handler   = X_QUEUE_HANDLER,
      queue_name      = X_QUEUE_NAME,
      direction       = X_DIRECTION,
      status          = X_STATUS,
      display_name    = X_DISPLAY_NAME,
      description     = X_DESCRIPTION,
      java_queue_handler = X_JAVA_QUEUE_HANDLER
    where guid = X_GUID;
  else
    update wf_agents set
      name            = X_NAME,
      system_guid     = X_SYSTEM_GUID,
      protocol        = X_PROTOCOL,
      address         = X_ADDRESS,
      queue_handler   = X_QUEUE_HANDLER,
      queue_name      = X_QUEUE_NAME,
      direction       = X_DIRECTION,
      status          = X_STATUS,
      display_name    = X_DISPLAY_NAME,
      description     = X_DESCRIPTION,
      type            = X_TYPE,
      java_queue_handler = X_JAVA_QUEUE_HANDLER
    where guid = X_GUID;
  end if;

  if (sql%notfound) then
    raise no_data_found;
  else
    wf_event.raise('oracle.apps.wf.event.agent.update',x_guid);
  end if;

exception
  when others then
    wf_core.context('Wf_Agents_Pkg', 'Update_Row', x_guid,
        x_protocol );
    raise;
end UPDATE_ROW;
-----------------------------------------------------------------------------
procedure LOAD_ROW (
  X_GUID            in      raw,
  X_NAME            in      varchar2,
  X_SYSTEM_GUID     in      raw,
  X_PROTOCOL        in      varchar2,
  X_ADDRESS         in      varchar2,
  X_QUEUE_HANDLER   in      varchar2,
  X_QUEUE_NAME      in      varchar2,
  X_DIRECTION       in      varchar2,
  X_STATUS          in      varchar2,
  X_DISPLAY_NAME    in      varchar2,
  X_DESCRIPTION     in      varchar2,
  X_TYPE            in      varchar2,
  X_JAVA_QUEUE_HANDLER   in varchar2
) is
  row_id  varchar2(64);
begin
  begin
    if (x_type is null) then
      WF_AGENTS_PKG.UPDATE_ROW (
        X_GUID            => X_GUID,
        X_NAME            => X_NAME,
        X_SYSTEM_GUID     => X_SYSTEM_GUID,
        X_PROTOCOL        => X_PROTOCOL,
        X_ADDRESS         => X_ADDRESS,
        X_QUEUE_HANDLER   => X_QUEUE_HANDLER,
        X_QUEUE_NAME      => X_QUEUE_NAME,
        X_DIRECTION       => X_DIRECTION,
        X_STATUS          => X_STATUS,
        X_DISPLAY_NAME    => X_DISPLAY_NAME,
        X_DESCRIPTION     => X_DESCRIPTION,
        X_JAVA_QUEUE_HANDLER => X_JAVA_QUEUE_HANDLER
      );
    else
      WF_AGENTS_PKG.UPDATE_ROW (
        X_GUID            => X_GUID,
        X_NAME            => X_NAME,
        X_SYSTEM_GUID     => X_SYSTEM_GUID,
        X_PROTOCOL        => X_PROTOCOL,
        X_ADDRESS         => X_ADDRESS,
        X_QUEUE_HANDLER   => X_QUEUE_HANDLER,
        X_QUEUE_NAME      => X_QUEUE_NAME,
        X_DIRECTION       => X_DIRECTION,
        X_STATUS          => X_STATUS,
        X_DISPLAY_NAME    => X_DISPLAY_NAME,
        X_DESCRIPTION     => X_DESCRIPTION,
        X_TYPE            => X_TYPE,
        X_JAVA_QUEUE_HANDLER => X_JAVA_QUEUE_HANDLER
      );
    end if;

    -- Invalidate cache
    wf_bes_cache.SetMetaDataUploaded();
  exception
    when no_data_found then
      wf_core.clear;
      if (x_type is null) then
        WF_AGENTS_PKG.INSERT_ROW(
          X_ROWID           => row_id,
  	  X_GUID            => X_GUID,
	  X_NAME            => X_NAME,
	  X_SYSTEM_GUID     => X_SYSTEM_GUID,
	  X_PROTOCOL        => X_PROTOCOL,
	  X_ADDRESS         => X_ADDRESS,
	  X_QUEUE_HANDLER   => X_QUEUE_HANDLER,
	  X_QUEUE_NAME      => X_QUEUE_NAME,
	  X_DIRECTION       => X_DIRECTION,
	  X_STATUS          => X_STATUS,
	  X_DISPLAY_NAME    => X_DISPLAY_NAME,
	  X_DESCRIPTION     => X_DESCRIPTION,
          X_JAVA_QUEUE_HANDLER => X_JAVA_QUEUE_HANDLER
        );
      else
        WF_AGENTS_PKG.INSERT_ROW(
	  X_ROWID           => row_id,
	  X_GUID            => X_GUID,
	  X_NAME            => X_NAME,
	  X_SYSTEM_GUID     => X_SYSTEM_GUID,
	  X_PROTOCOL        => X_PROTOCOL,
	  X_ADDRESS         => X_ADDRESS,
	  X_QUEUE_HANDLER   => X_QUEUE_HANDLER,
	  X_QUEUE_NAME      => X_QUEUE_NAME,
	  X_DIRECTION       => X_DIRECTION,
	  X_STATUS          => X_STATUS,
	  X_DISPLAY_NAME    => X_DISPLAY_NAME,
	  X_DESCRIPTION     => X_DESCRIPTION,
	  X_TYPE            => X_TYPE,
          X_JAVA_QUEUE_HANDLER => X_JAVA_QUEUE_HANDLER
        );
      end if;
  end;

exception
  when others then
    wf_core.context('Wf_Agents_Pkg', 'Load_Row', x_guid,
        x_protocol );
    raise;
end LOAD_ROW;
-----------------------------------------------------------------------------
procedure DELETE_ROW (
  X_GUID            in      raw
) is
begin
  wf_event.raise('oracle.apps.wf.event.agent.delete',x_guid);

  delete from wf_agents where guid = X_GUID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  -- Invalidate cache
  wf_bes_cache.SetMetaDataUploaded();
exception
  when others then
    wf_core.context('Wf_Agents_Pkg', 'Delete_Row', x_guid);
    raise;
end DELETE_ROW;
-----------------------------------------------------------------------------
function GENERATE (
  X_GUID  in  raw
) return varchar2 is
  buf              varchar2(32000);
  l_doc            xmldom.DOMDocument;
  l_element        xmldom.DOMElement;
  l_root           xmldom.DOMNode;
  l_node           xmldom.DOMNode;
  l_header         xmldom.DOMNode;

  l_name           varchar2(80);
  l_system_guid    raw(16);
  l_protocol       varchar2(30);
  l_address        varchar2(240);
  l_queue_handler  varchar2(240);
  l_queue_name     varchar2(80);
  l_direction      varchar2(8);
  l_status         varchar2(8);
  l_display_name   varchar2(80);
  l_description	   varchar2(240);
  l_type           varchar2(8);
  l_javaqhandler   varchar2(240);

begin
  select name, system_guid, protocol, address, queue_handler,
         queue_name, direction, status, display_name, description,
         type,java_queue_handler
  into   l_name, l_system_guid, l_protocol, l_address, l_queue_handler,
         l_queue_name, l_direction, l_status, l_display_name, l_description,
         l_type,l_javaqhandler
  from   wf_agents
  where  guid = x_guid;

  l_doc    := xmldom.newDOMDocument;
  l_root   := xmldom.makeNode(l_doc);
  l_root   := wf_event_xml.newtag(l_doc, l_root, wf_event_xml.masterTagName);
  l_header := wf_event_xml.newtag(l_doc, l_root, m_table_name);

  l_node   := wf_event_xml.newtag(l_doc, l_header, wf_event_xml.versionTagName,
                                  m_package_version);
  l_node   := wf_event_xml.newtag(l_doc, l_header, 'GUID',
                                  rawtohex(x_guid));
  l_node   := wf_event_xml.newtag(l_doc, l_header, 'NAME',
                                  l_name);
  l_node   := wf_event_xml.newtag(l_doc, l_header, 'SYSTEM_GUID',
                                  rawtohex(l_system_guid));
  l_node   := wf_event_xml.newtag(l_doc, l_header, 'PROTOCOL',
                                  l_protocol);
  l_node   := wf_event_xml.newtag(l_doc, l_header, 'ADDRESS',
                                  l_address);
  l_node   := wf_event_xml.newtag(l_doc, l_header, 'QUEUE_HANDLER',
                                  l_queue_handler);
  --Bug 3328673
  --Add the new tag for java queue handler <this is a nullable column>
  l_node   := wf_event_xml.newtag(l_doc, l_header, 'JAVA_QUEUE_HANDLER',
                                  l_javaqhandler);

  l_node   := wf_event_xml.newtag(l_doc, l_header, 'QUEUE_NAME',
                                  l_queue_name);
  l_node   := wf_event_xml.newtag(l_doc, l_header, 'DIRECTION',
                                  l_direction);
  l_node   := wf_event_xml.newtag(l_doc, l_header, 'STATUS',
                                  l_status);
  l_node   := wf_event_xml.newtag(l_doc, l_header, 'DISPLAY_NAME',
                                  l_display_name);
  l_node   := wf_event_xml.newtag(l_doc, l_header, 'DESCRIPTION',
                                  l_description);
  l_node   := wf_event_xml.newtag(l_doc, l_header, 'TYPE',
                                  l_type);

  xmldom.writeToBuffer(l_root, buf);

  return buf;
exception
  when others then
    wf_core.context('Wf_Agents_Pkg', 'Generate', x_guid);
    raise;
end GENERATE;
-----------------------------------------------------------------------------
procedure RECEIVE (
  X_MESSAGE     in varchar2
) is
  l_guid    	   raw(16);
  l_name           varchar2(80);
  l_system_guid    raw(16);
  l_protocol       varchar2(30);
  l_address        varchar2(240);
  l_queue_handler  varchar2(240);
  l_queue_name     varchar2(80);
  l_direction      varchar2(8);
  l_status         varchar2(8);
  l_display_name   varchar2(80);
  l_description	   varchar2(240);
  l_version	   varchar2(80);
  l_message        varchar2(32000);
  l_type           varchar2(8);

  l_node_name        varchar2(255);
  l_node             xmldom.DOMNode;
  l_child            xmldom.DOMNode;
  l_value            varchar2(32000);
  l_length           integer;
  l_node_list        xmldom.DOMNodeList;

  l_agent_guid       varchar2(32);
  l_javaqhandler     varchar2(240);

  /* Identical Row Cursor
  ** A row is considered identical if it has the same agent name.
  */
  cursor identical_row is
    select GUID
    from WF_AGENTS
    where NAME = l_name;

begin

  l_message := x_message;
  -- l_message := WF_EVENT_SYNCHRONIZE_PKG.SetGUID(l_message); -- update #NEW
  l_message := WF_EVENT_SYNCHRONIZE_PKG.SetSYSTEMGUID(l_message); -- update #LOCAL
  l_message := WF_EVENT_SYNCHRONIZE_PKG.SetSID(l_message); -- update #SID

  l_node_list := wf_event_xml.findTable(l_message, m_table_name);
  l_length := xmldom.getLength(l_node_list);

  -- loop through elements that we received.
  for i in 0..l_length-1 loop
     l_node := xmldom.item(l_node_list, i);
     l_node_name := xmldom.getNodeName(l_node);
     if xmldom.hasChildNodes(l_node) then
        l_child := xmldom.GetFirstChild(l_node);
        l_value := xmldom.getNodevalue(l_child);
     else
        l_value := NULL;
     end if;

     if(l_node_name = 'GUID') then
       -- l_guid := l_value;
       l_agent_guid := l_value;
     elsif(l_node_name = 'NAME') then
       l_name := l_value;
     elsif(l_node_name = 'SYSTEM_GUID') then
       l_system_guid := l_value;
     elsif(l_node_name = 'PROTOCOL') then
       l_protocol := l_value;
     elsif(l_node_name = 'ADDRESS') then
       l_address := l_value;
     elsif(l_node_name = 'QUEUE_HANDLER') then
       l_queue_handler := l_value;
     --Bug 3328673
     --Add support for java q handler in loader
     elsif(l_node_name = 'JAVA_QUEUE_HANDLER') then
       l_javaqhandler := l_value;

     elsif(l_node_name = 'QUEUE_NAME') then
       l_queue_name := l_value;
     elsif(l_node_name = 'DIRECTION') then
       l_direction := l_value;
     elsif(l_node_name = 'STATUS') then
       l_status := l_value;
     elsif(l_node_name = 'DISPLAY_NAME') then
       l_display_name := l_value;
     elsif(l_node_name = 'DESCRIPTION') then
       l_description := l_value;
     elsif(l_node_name = 'TYPE') then
       l_type := l_value;
     elsif(l_node_name = wf_event_xml.versionTagName) then
       l_version := l_value;
     else
       Wf_Core.Token('REASON', 'Invalid column name found:' ||
           l_node_name || ' with value:'||l_value);
       Wf_Core.Raise('WFSQL_INTERNAL');
     end if;
  end loop;

  if l_agent_guid = '#NEW' then
    -- A row is consigered identical if it has the same agent name
    open identical_row;
    fetch identical_row into l_guid;
    if (identical_row%notfound) then
      l_guid := sys_guid();
    end if;
    close identical_row;
  else
    l_guid := hextoraw(l_agent_guid);
  end if;

  wf_agents_pkg.load_row(
     X_GUID            => l_guid,
     X_NAME            => l_name,
     X_SYSTEM_GUID     => l_system_guid,
     X_PROTOCOL        => l_protocol,
     X_ADDRESS         => l_address,
     X_QUEUE_HANDLER   => l_queue_handler,
     X_QUEUE_NAME      => l_queue_name,
     X_DIRECTION       => l_direction,
     X_STATUS          => l_status,
     X_DISPLAY_NAME    => l_display_name,
     X_DESCRIPTION     => l_description,
     X_TYPE            => l_type,
     X_JAVA_QUEUE_HANDLER => l_javaqhandler);

exception
  when others then
    wf_core.context('Wf_Agents_Pkg', 'Receive', x_message);
    raise;
end RECEIVE;
-------------------------------------------------------------------------
end WF_AGENTS_PKG;

/
