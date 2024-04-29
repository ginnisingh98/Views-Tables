--------------------------------------------------------
--  DDL for Package Body WF_EVENT_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_EVENT_GROUPS_PKG" as
/* $Header: WFEVGRPB.pls 120.3 2005/10/19 05:25:49 vshanmug ship $ */
m_table_name       varchar2(255) := 'WF_EVENT_GROUPS';
m_package_version  varchar2(30)  := '1.0';
-----------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID           in out nocopy  varchar2,
  X_GROUP_GUID      in      raw,
  X_MEMBER_GUID     in      raw
) is
  cursor C is select rowid
              from   wf_event_groups
              where  group_guid  = X_GROUP_GUID
              and    member_guid = X_MEMBER_GUID;
begin
  insert into wf_event_groups (
    group_guid,
    member_guid
  ) values (
    X_GROUP_GUID,
    X_MEMBER_GUID
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  else
    wf_event.raise('oracle.apps.wf.event.group.create',x_group_guid||'/'||x_member_guid);
  end if;
  close c;

exception
  when others then
    wf_core.context('Wf_Event_Groups_Pkg', 'Insert_Row', x_group_guid, x_member_guid);
    raise;

end INSERT_ROW;
-----------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_GROUP_GUID      in      raw,
  X_MEMBER_GUID     in      raw
) is
begin
  update wf_event_groups set
    group_guid      = X_GROUP_GUID,
    member_guid     = X_MEMBER_GUID
  where  group_guid  = X_GROUP_GUID
   and    member_guid = X_MEMBER_GUID;

  if (sql%notfound) then
    raise no_data_found;
  else
    wf_event.raise('oracle.apps.wf.event.group.update',x_group_guid||'/'||x_member_guid);
  end if;

exception
  when others then
    wf_core.context('Wf_Event_Groups_Pkg', 'Update_Row', x_group_guid,
        x_member_guid);
    raise;
end UPDATE_ROW;
-----------------------------------------------------------------------------
procedure LOAD_ROW (
  X_GROUP_GUID      in      raw,
  X_MEMBER_GUID     in      raw
) is
  row_id  varchar2(64);
begin
  WF_EVENT_GROUPS_PKG.UPDATE_ROW (
    X_GROUP_GUID  => X_GROUP_GUID,
    X_MEMBER_GUID => X_MEMBER_GUID
  );

exception
  when no_data_found then
    wf_core.clear;
    WF_EVENT_GROUPS_PKG.INSERT_ROW(
      X_ROWID       => row_id,
      X_GROUP_GUID  => X_GROUP_GUID,
      X_MEMBER_GUID => X_MEMBER_GUID
    );
  when others then
    wf_core.context('Wf_Event_Groups_Pkg', 'Load_Row', x_group_guid,
                x_member_guid);
    raise;
end LOAD_ROW;
-----------------------------------------------------------------------------

procedure DELETE_ROW (
  X_GROUP_GUID  in  raw,
  X_MEMBER_GUID in  raw
) is
begin
  wf_event.raise('oracle.apps.wf.event.group.delete',x_group_guid||'/'||x_member_guid);

  delete from wf_event_groups
  where  group_guid  = X_GROUP_GUID
  and    member_guid = X_MEMBER_GUID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('Wf_Event_Groups_Pkg', 'Delete_Row', x_group_guid,
       x_member_guid);
    raise;

end DELETE_ROW;
-----------------------------------------------------------------------------
function GENERATE (
  X_GROUP_GUID  in  raw,
  X_MEMBER_GUID in  raw
) return varchar2 is
  buf              varchar2(32000);
  l_doc            xmldom.DOMDocument;
  l_element        xmldom.DOMElement;
  l_root           xmldom.DOMNode;
  l_node           xmldom.DOMNode;
  l_header         xmldom.DOMNode;

begin
--  select DISPLAY_NAME, DESCRIPTION
--    into l_display_name, l_description
--    from wf_event_groups
--  where group_guid = x_guid
--    and member_guid = x_member_guid;

  l_doc := xmldom.newDOMDocument;
  l_root := xmldom.makeNode(l_doc);
  l_root := wf_event_xml.newtag (l_doc, l_root, wf_event_xml.masterTagName);
  l_header := wf_event_xml.newtag(l_doc, l_root, m_table_name);
  l_node := wf_event_xml.newtag(l_doc, l_header, wf_event_xml.versionTagName,
                                                 m_package_version);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'GROUP_GUID',
                                    rawtohex(x_GROUP_GUID));
  l_node := wf_event_xml.newtag(l_doc, l_header, 'MEMBER_GUID',
                                    rawtohex(x_MEMBER_GUID));

  xmldom.writeToBuffer(l_root, buf);
  return buf;

null;
exception
  when others then
    wf_core.context('Wf_Event_Groups_Pkg', 'Generate', x_group_guid,
       x_member_guid);
    raise;
end GENERATE;
-----------------------------------------------------------------------------
procedure CHECK_EVENT(X_MEMBER_GUID RAW,
		      X_ERROR out nocopy varchar2)is
event_count number;
begin
   Select 1 into event_count
   from   WF_EVENTS
   where  guid=X_MEMBER_GUID;
exception
  when no_data_found then
     x_error:='NON_EXIST_EVENT:'||X_MEMBER_GUID;
  when others then
    wf_core.context('Wf_Event_Groups_Pkg', 'Check_Event', x_member_guid);
    raise;
end CHECK_EVENT;
-----------------------------------------------------------------------------
procedure RECEIVE2 (
  X_MESSAGE     in varchar2,
  X_ERROR  out nocopy varchar2) is
  l_group_guid       varchar2(32);
  l_member_guid      varchar2(32);
  l_version          varchar2(80);
  l_message          varchar2(32000);

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

     if(l_node_name = 'GROUP_GUID') then
       l_group_guid := l_value;
     elsif(l_node_name = 'MEMBER_GUID') then
       l_member_guid := l_value;
     elsif(l_node_name = 'GROUP_NAME') then
       select guid
       into   l_group_guid
       from   wf_events
       where  name = l_value
       and    type = 'GROUP';
     elsif(l_node_name = 'MEMBER_NAME') then
       select guid
       into   l_member_guid
       from   wf_events
       where  name = l_value;
     elsif(l_node_name = wf_event_xml.versionTagName) then
       l_version := l_value;
     else
       Wf_Core.Token('REASON', 'Invalid column name found:' ||
           l_node_name || ' with value:'||l_value);
       Wf_Core.Raise('WFSQL_INTERNAL');
     end if;
  end loop;

  wf_event_groups_pkg.check_event(l_member_guid,x_error);

  wf_event_groups_pkg.load_row(
     X_GROUP_GUID      => l_group_guid,
     X_MEMBER_GUID     => l_member_guid
  );

exception
  when others then
    wf_core.context('Wf_Event_Groups_Pkg', 'Receive', x_message);
    raise;
end RECEIVE2;

-----------------------------------------------------------------------------
procedure RECEIVE (
  X_MESSAGE     in varchar2 ) is
  l_error          varchar2(4000);
begin
  RECEIVE2(X_MESSAGE,l_error);
end RECEIVE;
-----------------------------------------------------------------------------
function GENERATE2 (
  X_GROUP_NAME  in  varchar2,
  X_MEMBER_NAME in  varchar2
) return varchar2 is
  buf              varchar2(32000);
  l_doc            xmldom.DOMDocument;
  l_element        xmldom.DOMElement;
  l_root           xmldom.DOMNode;
  l_node           xmldom.DOMNode;
  l_header         xmldom.DOMNode;

begin

  l_doc := xmldom.newDOMDocument;
  l_root := xmldom.makeNode(l_doc);
  l_root := wf_event_xml.newtag (l_doc, l_root, wf_event_xml.masterTagName);
  l_header := wf_event_xml.newtag(l_doc, l_root, m_table_name);
  l_node := wf_event_xml.newtag(l_doc, l_header, wf_event_xml.versionTagName,
                                                 m_package_version);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'GROUP_NAME', x_group_name);
  l_node := wf_event_xml.newtag(l_doc, l_header, 'MEMBER_NAME', x_member_name);

  xmldom.writeToBuffer(l_root, buf);
  return buf;

null;
exception
  when others then
    wf_core.context('Wf_Event_Groups_Pkg', 'Generate2', x_group_name,
       x_member_name);
    raise;
end GENERATE2;

end WF_EVENT_GROUPS_PKG;

/
