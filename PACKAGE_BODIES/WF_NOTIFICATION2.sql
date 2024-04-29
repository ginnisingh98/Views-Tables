--------------------------------------------------------
--  DDL for Package Body WF_NOTIFICATION2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_NOTIFICATION2" as
/* $Header: wfntf2b.pls 115.0 2003/03/03 20:02:05 ctilley noship $ */


--   Return MORE_INFO_ROLE from a notification.
-- IN
--   nid - Notification Id
-- RETURNS
--
function GetMoreInfoRole(
  nid in number)
return varchar2
is
  l_more_info_role varchar2(320);
begin
  if (nid is null) then
    wf_core.token('NID', to_char(nid));
    wf_core.raise('WFSQL_ARGS');
  end if;
  -- Get more_info_role
  begin
    select WN.MORE_INFO_ROLE
    into l_more_info_role
    from WF_NOTIFICATIONS WN
    where WN.NOTIFICATION_ID = nid;
  exception
    when no_data_found then
      wf_core.token('NID', to_char(nid));
      wf_core.raise('WFNTF_NID');
  end;

  return(l_more_info_role);

exception
  when others then
    Wf_Core.Context('Wf_Notification2', 'GetMoreInfoRole', to_char(nid));
    raise;
end GetMoreInfoRole;


end WF_NOTIFICATION2;


/
