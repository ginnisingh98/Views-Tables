--------------------------------------------------------
--  DDL for Package Body WF_SYSTEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_SYSTEMS_PKG" as
/* $Header: WFEVSYSB.pls 120.3 2005/09/02 16:07:55 vshanmug ship $ */

m_table_name       varchar2(255) := 'WF_SYSTEMS';
m_package_version  varchar2(30)  := '1.0';

-----------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID        in out nocopy varchar2,
  X_GUID         in     raw,
  X_NAME         in     varchar2,
  X_MASTER_GUID  in     raw,
  X_DISPLAY_NAME in     varchar2,
  X_DESCRIPTION  in     varchar2
) is
  cursor C is select rowid
              from   wf_systems
              where  guid  = X_GUID;
begin
  insert into wf_systems (
    guid,
    name,
    master_guid,
    display_name,
    description
  ) values (
    X_GUID,
    X_NAME,
    X_MASTER_GUID,
    X_DISPLAY_NAME,
    X_DESCRIPTION
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  else
    wf_event.raise('oracle.apps.wf.event.system.create',x_guid);
  end if;
  close c;
exception
  when others then
    wf_core.context('Wf_Systems_Pkg', 'Insert_row', x_guid, x_name);
    raise;

end INSERT_ROW;
-----------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_GUID         in raw,
  X_NAME         in varchar2,
  X_MASTER_GUID  in raw,
  X_DISPLAY_NAME in varchar2,
  X_DESCRIPTION  in varchar2
) is
begin
  update wf_systems
  set    name         = X_NAME,
         master_guid  = X_MASTER_GUID,
         display_name = X_DISPLAY_NAME,
         description  = X_DESCRIPTION
  where  guid = X_GUID;

  if (sql%notfound) then
    raise no_data_found;
  else
    wf_event.raise('oracle.apps.wf.event.system.update',x_guid);
  end if;
exception
  when others then
    wf_core.context('Wf_Systems_Pkg', 'Update_row', x_guid, x_name);
    raise;
end UPDATE_ROW;
-----------------------------------------------------------------------------
procedure DELETE_ROW (
  X_GUID  in  raw
) is
begin
  wf_event.raise('oracle.apps.wf.event.system.delete',x_guid);

  delete from wf_systems
  where  guid  = X_GUID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  -- Invalidate cache
  wf_bes_cache.SetMetaDataUploaded();
exception
  when others then
    wf_core.context('Wf_Systems_Pkg', 'Delete_row', x_guid);
    raise;
end DELETE_ROW;
-----------------------------------------------------------------------------
procedure LOAD_ROW (
  X_GUID         in raw,
  X_NAME         in varchar2,
  X_MASTER_GUID  in raw,
  X_DISPLAY_NAME in varchar2,
  X_DESCRIPTION  in varchar2
) is
  row_id  varchar2(64);
begin
  begin
    WF_SYSTEMS_PKG.UPDATE_ROW (
      X_GUID         => X_GUID,
      X_NAME         => X_NAME,
      X_MASTER_GUID  => X_MASTER_GUID,
      X_DISPLAY_NAME => X_DISPLAY_NAME,
      X_DESCRIPTION  => X_DESCRIPTION);

    -- Invalidate cache
    wf_bes_cache.SetMetaDataUploaded();
  exception
    when no_data_found then
      WF_SYSTEMS_PKG.INSERT_ROW(
        X_ROWID        => row_id,
        X_GUID         => X_GUID,
        X_NAME         => X_NAME,
        X_MASTER_GUID  => X_MASTER_GUID,
        X_DISPLAY_NAME => X_DISPLAY_NAME,
        X_DESCRIPTION  => X_DESCRIPTION);
  end;

exception
  when others then
    wf_core.context('Wf_Systems_Pkg', 'Load_row', x_guid, x_name);
    raise;
end LOAD_ROW;
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
  l_master_guid    raw(16);
  l_display_name   varchar2(80);
  l_description	   varchar2(240);

begin
  select name, master_guid, display_name, description
    into l_name, l_master_guid, l_display_name, l_description
    from wf_systems
  where guid = x_guid;

  l_doc := xmldom.newDOMDocument;
  l_root := xmldom.makeNode(l_doc);
  l_root := wf_event_xml.newtag (l_doc, l_root, wf_event_xml.masterTagName);
  l_header := wf_event_xml.newtag(l_doc, l_root, m_table_name);
  l_node := wf_event_xml.newtag(l_doc, l_header, wf_event_xml.versionTagName,
                                                 m_package_version);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'GUID',
                                    rawtohex(x_guid));
  l_node := wf_event_xml.newtag(l_doc, l_header, 'NAME',        l_name);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'MASTER_GUID',
                                    rawtohex(l_master_guid));
  l_node := wf_event_xml.newtag(l_doc, l_header, 'DISPLAY_NAME',
                                    l_display_name);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'DESCRIPTION', l_description);

  xmldom.writeToBuffer(l_root, buf);

  return buf;
exception
  when others then
    wf_core.context('Wf_Systems_Pkg', 'Generate', x_guid);
    raise;
end GENERATE;
-----------------------------------------------------------------------------
procedure RECEIVE (
  X_MESSAGE     in varchar2
) is
  l_guid    	   varchar2(32);
  l_name    	   varchar2(80);
  l_master_guid    varchar2(32);
  l_display_name   varchar2(80);
  l_description	   varchar2(240);
  l_version	   varchar2(80);
  l_message        varchar2(32000);

  l_node_name        varchar2(255);
  l_node             xmldom.DOMNode;
  l_child            xmldom.DOMNode;
  l_value            varchar2(32000);
  l_length           integer;
  l_node_list        xmldom.DOMNodeList;
begin

  l_message := x_message;
  l_message := WF_EVENT_SYNCHRONIZE_PKG.SetGUID(l_message); -- update #NEW
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
       l_guid := l_value;
     elsif(l_node_name = 'NAME') then
       l_name := l_value;
     elsif(l_node_name = 'MASTER_GUID') then
       l_master_guid := l_value;
     elsif(l_node_name = 'DISPLAY_NAME') then
       l_display_name := l_value;
     elsif(l_node_name = 'DESCRIPTION') then
       l_description := l_value;
     elsif(l_node_name = wf_event_xml.versionTagName) then
       l_version := l_value;
     else
       Wf_Core.Token('REASON', 'Invalid column name found:' ||
           l_node_name || ' with value:'||l_value);
       Wf_Core.Raise('WFSQL_INTERNAL');
     end if;
  end loop;

  load_row(l_guid, l_name, l_master_guid, l_display_name, l_description);
exception
  when others then
    wf_core.context('Wf_Systems_Pkg', 'Receive', x_message);
    raise;
end RECEIVE;
-----------------------------------------------------------------------------
end WF_SYSTEMS_PKG;

/
